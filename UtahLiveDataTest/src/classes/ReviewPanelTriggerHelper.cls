/*
    Trigger Helper class for Review Panel Object
    ***********************************************************
    Audit History
    ***********************************************************
    11/13/2014      Nakul         Created
    *********************************************************** 
*/
public with sharing class ReviewPanelTriggerHelper extends GNT.TriggerHelper{
     public static Boolean skipTrigger= false;
    public override void processBeforeInsert(){
        setGroupId();
    }
    
    public override void processAfterInsert(){
        if (!skipTrigger){
            createPanelUsers(Trigger.New);
            autoAssignApplicationsToPanels(Trigger.Newmap.keySet());
       //     notifyPanelHeadFuture(Trigger.Newmap.keySet());
        }
    }
    
    public override void processBeforeUpdate(){
        setGroupId();
    }
    
    public override void processAfterUpdate(){
        shareReviews();
        notifyPanelHead();
    }
    
    /* udpate review share if the panel's chair is updated*/
    private void shareReviews(){
    	Set<Id> revPanelIdSet = new Set<Id>();
    	Set<Id> oldChairIdSet = new Set<Id>();
    	for(ReviewPanel__c revPanel : (List<ReviewPanel__c>)trigger.new){
    		ReviewPanel__c oldReviewPanel = (ReviewPanel__c)trigger.oldMap.get(revPanel.Id);
    		if(revPanel.Chair__c != oldReviewPanel.Chair__c){
    			revPanelIdSet.add(revPanel.Id);
    			oldChairIdSet.add(oldReviewPanel.Chair__c);
    		}
    	}
    	if(revPanelIdSet.size() >0){
    		shareReviewsFuture(revPanelIdSet, oldChairIdSet);
    	}
    }
    
    private void notifyPanelHead(){
    	Set<Id> revPanelIdSet = new Set<Id>();
    	for(ReviewPanel__c revPanel : (List<ReviewPanel__c>)trigger.new){
    		ReviewPanel__c oldReviewPanel = (ReviewPanel__c)trigger.oldMap.get(revPanel.Id);
    		if(revPanel.Chair__c != null && revPanel.Chair__c != oldReviewPanel.Chair__c){
    			revPanelIdSet.add(revPanel.Id);
    		}
    	}
    /*	if(revPanelIdSet.size() >0){
    		notifyPanelHeadFuture(revPanelIdSet);
    	}*/
    }
    
    
   /* @future
    private static void notifyPanelHeadFuture(Set<Id> revPanelIdSet){
    	Map<Id, String> panelIdToTemplateMap = new Map<Id, String>();
    	Map<Id, String> panelIdToTemplateNameMap = new Map<Id, String>();
    	Map<Id, String[]> panelIdToEmailMap = new Map<Id, String[]>();
    	Map<String, Id> templateNameToIdMap = new Map<String, Id>();
    	
    	List<ReviewPanel__c> lstPanels = [SELECT Id, Chair__r.Email, ReviewStep__r.PanelHeadAssignNotificationTemplate__c 
    										From ReviewPanel__c Where ID IN :revPanelIdSet ];
    	for(ReviewPanel__c panel : lstPanels){
    		panelIdToTemplateNameMap.put(panel.id, panel.ReviewStep__r.PanelHeadAssignNotificationTemplate__c);
    		String[] toAddresses = new String[] {panel.Chair__r.Email};
    		panelIdToEmailMap.put(panel.Id, toAddresses);
    	}
    	
    	List<Contact> cont = [select id, Email from Contact where Email <> null limit 1];
    	if(cont.size() > 0){
    		List<EmailTemplate> emailTemplateList = [Select Id, DeveloperName From EmailTemplate Where DeveloperName IN :panelIdToTemplateNameMap.values()];
    		for(EmailTemplate temp : emailTemplateList){
    			templateNameToIdMap.put(temp.DeveloperName, temp.Id);
    		}
    		for(Id panelId : panelIdToTemplateNameMap.keySet()){
    			String templateName = panelIdToTemplateNameMap.get(panelId);
    			Id templateId = templateNameToIdMap.get(templateName);
    			panelIdToTemplateMap.put(panelId, templateId);
    		}
    		if(panelIdToTemplateMap.size() > 0){
    		 AppUtils.sendEmailUsingTemplate(panelIdToTemplateMap, panelIdToEmailMap, cont[0].Id, false);
    		}
    	}
    }
    */
    @future
    private static void shareReviewsFuture(Set<Id> revPanelIdSet, Set<Id> oldChairIdSet){
    	List<Review__Share> shareList = new List<Review__Share>();
    	List<Review__c> reviews = [Select id, ReviewPanel__r.Chair__c From Review__c Where ReviewPanel__c IN : revPanelIdSet];
    	
    	List<Review__Share> oldShare = [Select id From Review__Share Where AccessLevel = 'edit' 
    									AND ParentId IN :reviews AND UserOrGroupId IN :oldChairIdSet];
    	delete oldShare;
    	
    	for(Review__c review : reviews){
    		Review__Share share = new Review__Share();
            share.ParentId = review.Id;
            share.UserOrGroupId = review.ReviewPanel__r.Chair__c;
            share.AccessLevel = 'edit';
            share.RowCause = Schema.Review__Share.RowCause.SharetoPanelExecutiveUser__c;
            shareList.add(share);
    	}
    	if(shareList.size() > 0){
    		SystemContextMethodsHelper SystemContextMethodsHelper = new SystemContextMethodsHelper();
        SystemContextMethodsHelper.insertReviewShare(shareList);
    	}
    }
    /*
        Auto populate the grp Id using the group name.
    */
    private void setGroupId(){
        Set<String> grpNameSet = new Set<String>();
        Map<String, Id> groupNameToIdMap = new Map<String, Id>();
        
        for(ReviewPanel__c panel : (List<ReviewPanel__c>) trigger.new){
            grpNameSet.add(panel.GroupName__c);
        }
        
        List<Group> grpList = [Select Id, DeveloperName From Group Where DeveloperName = :grpNameSet AND type = 'Queue'];
        for(Group grp : grpList){
            groupNameToIdMap.put(grp.DeveloperName, grp.Id);
        }
        
        for(ReviewPanel__c panel : (List<ReviewPanel__c>) trigger.new){
            panel.GroupId__c = groupNameToIdMap.get(panel.GroupName__c);
        }
    }
    
    /*
        Copy all Applications & PreApplications from Review panel
        and populate Panel Applications under all the Panels (where AutoAssignSubmittedApp = true) 
        of the review step where step number = 1
    */
    private void autoAssignApplicationsToPanels(Set<Id> newReviewPanelIdList){
        List<ReviewPanel__c> panelAppList = new List<ReviewPanel__c>();
        List<ReviewPanel__c> panelPreAppList = new List<ReviewPanel__c>();
        
        Set<Id> rpAppAnnouncementsSet = new Set<Id>();
        Set<Id> rpPreAppAnnouncementSet = new Set<Id>();
        
        List<ReviewPanel__c> newReviewPanelList = [SELECT Id, RecordTypeId, ReviewStep__r.StepNumber__c,ReviewStep__r.AnnouncementId__c,
                                                   AutoAssignSubmittedApplication__c FROM ReviewPanel__c WHERE Id IN : newReviewPanelIdList];
        
        Id rpAppRecTypeId = Schema.SObjectType.ReviewPanel__c.getRecordTypeInfosByName().get('Application').getRecordTypeId();
        Id rpPreAppRecTypeId = Schema.SObjectType.ReviewPanel__c.getRecordTypeInfosByName().get('Pre-Application').getRecordTypeId();
        
        for(ReviewPanel__c panel : newReviewPanelList){
        	
        
        	
            if(panel.ReviewStep__r.StepNumber__c == 1 && panel.RecordTypeId == rpAppRecTypeId){ 
            	
                panelAppList.add(panel);
                rpAppAnnouncementsSet.add(panel.ReviewStep__r.AnnouncementId__c);
            }else if(panel.ReviewStep__r.StepNumber__c == 1 && panel.RecordTypeId == rpPreAppRecTypeId){
            	
                panelPreAppList.add(panel);
                rpPreAppAnnouncementSet.add(panel.ReviewStep__r.AnnouncementId__c);
            }
        }
        
        List<PanelApplication__c> panelApplications = new List<PanelApplication__c>();
        Id panelAppRecTypeId = Schema.SObjectType.PanelApplication__c.getRecordTypeInfosByName().get('Application').getRecordTypeId();
        Id panelPreAppRecTypeId = Schema.SObjectType.PanelApplication__c.getRecordTypeInfosByName().get('Pre-Application').getRecordTypeId();
        
        if(panelAppList.size() > 0){
            for(Application__c app : [SELECT Id,Announcement__c FROM Application__c WHERE Announcement__c IN :rpAppAnnouncementsSet AND SubmittedOn__c != null]){
                
                for(ReviewPanel__c panel : panelAppList){
                    Id panelAnnId = panel.ReviewStep__r.AnnouncementId__c;
                    Id appAnnId = app.Announcement__c;
                    
                    
                    if(panelAnnId == appAnnId && panel.AutoAssignSubmittedApplication__c){
                        
                        panelApplications.add(new PanelApplication__c(ReviewPanel__c = panel.Id, Application__c = app.Id, RecordTypeId = panelAppRecTypeId));
                    }
                }
            }
        }
        if(panelPreAppList.size() > 0){ 
           
            for(PreApplication__c preApp : [SELECT Id,Announcement__c FROM PreApplication__c WHERE Announcement__c IN :rpPreAppAnnouncementSet AND SubmittedOn__c != null]){
            
                for(ReviewPanel__c panel : panelPreAppList){
                    Id panelAnnId = panel.ReviewStep__r.AnnouncementId__c;
                    Id preappAnnId = preApp.Announcement__c;
                    if(panelAnnId == preappAnnId && panel.AutoAssignSubmittedApplication__c){
                         
                        panelApplications.add(new PanelApplication__c(ReviewPanel__c = panel.Id, PreApplication__c = preApp.Id, RecordTypeId = panelPreAppRecTypeId));
                    }
                }
            }
        }
        
        if(panelApplications.size() > 0){
            
            insert panelApplications;
        }
    }

    private void createPanelUsers(List<ReviewPanel__c> reviewPanelList){
        Set<Id> reviewPanelTemplateIdsSet = new Set<Id>();
        for(ReviewPanel__c reviewPanelInstance : reviewPanelList){
            reviewPanelTemplateIdsSet.add(reviewPanelInstance.ReviewPanelTemplate__c);             
        }

        //fetch all review panel templates
        Map<Id,ReviewPanelTemplate__c> rptMap = new Map<Id,ReviewPanelTemplate__c>([SELECT Id,Name,  
                                                            RecordTypeId,(SELECT Id,Name,Reviewer__c,
                                                            ReviewPanelTemplate__c FROM 
                                                            ReviewPanelTemplate__c.Panel_User_Templates__r) 
                                                            FROM ReviewPanelTemplate__c WHERE Id IN :reviewPanelTemplateIdsSet]);
        
        
        //Get the record type ids for Review Panel
        Id rpRecTypeIdApp = Schema.SObjectType.ReviewPanel__c.getRecordTypeInfosByName().get('Application').getRecordTypeId();
        Id rpRecTypeIdPreApp = Schema.SObjectType.ReviewPanel__c.getRecordTypeInfosByName().get('Pre-Application').getRecordTypeId();

        //Get the record type ids for Panel User Template
        
        
        
        //Get the record type ids for Panel User
        
        

        List<PanelUser__c> puList = new List<PanelUser__c>();
        for(ReviewPanel__c reviewPanelInstance : reviewPanelList){
        	
            ReviewPanelTemplate__c rpt = rptMap.get(reviewPanelInstance.ReviewPanelTemplate__c);
            if(rpt != null){
	            List<PanelUserTemplate__c> putList = rpt.Panel_User_Templates__r;
	
	            for(PanelUserTemplate__c puTemplate : putList ){
	                PanelUser__c panelUser = new PanelUser__c();
	                Boolean createPanelUser = true;
	
	                // There are no record types for the PanelUser Sobject.
	                
	
	                if(createPanelUser == true){
	                    panelUser.Reviewer__c = puTemplate.Reviewer__c;
	                    panelUser.ReviewPanel__c = reviewPanelInstance.id;
	                    puList.add(panelUser);
	                }
	            }
            }
        }

         if(puList.size()>0){
            insert puList;
         }
    }
}