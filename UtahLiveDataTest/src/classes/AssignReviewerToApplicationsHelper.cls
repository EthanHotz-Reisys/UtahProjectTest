/*
    Class used to assign a Reviewer to multiple Applications / PreApplications
*/
public with sharing class AssignReviewerToApplicationsHelper extends GNT.FlexTableActionHandler {
    
    public override Map<String,Object> clickHandler(){
        SavePoint sp = Database.setSavepoint();
        Map<String,Object> resultMap = new Map<String,Object>();
        try{
            if(selectedRecordIds.size() > 0){
                String ns = AppUtils.getNamespacePrefix(); 
                Id panelId = urlParams.get('panelId');
                String tabName = urlParams.get('tabName');
                Id panelUserId = urlParams.get('id');
                
                ReviewPanel__c reviewPanel = [SELECT Id, RecordTypeId,TaskDueDate__c,DueDateOffset__c,EndDate__c FROM ReviewPanel__c WHERE Id=:panelId];
                PanelUser__c panelUser = [Select Id, Reviewer__c From PanelUser__c Where Id = :panelUserId];
                
                Id rpAppRecTypeId = Schema.SObjectType.ReviewPanel__c.getRecordTypeInfosByName().get('Application').getRecordTypeId();
                Id rpPreAppRecTypeId = Schema.SObjectType.ReviewPanel__c.getRecordTypeInfosByName().get('Pre-Application').getRecordTypeId();
                
                List<PanelApplication__c> panelAppList = [Select id, Application__c, PreApplication__c From PanelApplication__c Where Id IN : selectedRecordIds];       
                
                Map<Id, Id> pAppToIdMap = new Map<Id, Id>();
                for(PanelApplication__c pApp : panelAppList){
                    if(reviewPanel.RecordTypeId == rpAppRecTypeId){
                        pAppToIdMap.put(pApp.Id, pApp.Application__c);    
                    }else{
                        pAppToIdMap.put(pApp.Id, pApp.PreApplication__c);    
                    }
                }

                Map<Id,Review__c> reviewsMap = new Map<Id,Review__c>([SELECT Id,PanelApplication__c,PanelUser__c 
                                                                            FROM Review__c WHERE ReviewPanel__c =:panelId]);    
                                                                            
                Map<String,Review__c> appUserReviewMap = new Map<String,Review__c>();
                for(Review__c rev: reviewsMap.values()){
                    appUserReviewMap.put(rev.PanelApplication__c +''+ rev.PanelUser__c,rev);    
                }       
                
                List<Review__c> reviewsList = new List<Review__c>();
                
                for(String selectedId : selectedRecordIds){
                    Review__c review = new Review__c();
                    if(reviewPanel.RecordTypeId == rpAppRecTypeId){
                        review.Application__c = pAppToIdMap.get(selectedId);
                    }else{
                        review.PreApplication__c = pAppToIdMap.get(selectedId);
                    }
                    review.PanelApplication__c = selectedId;
                    review.PanelUser__c = panelUser.Id;            
                    review.ReviewPanel__c = panelId;             
                    review.Status__c = 'Assigned';  
                    if(appUserReviewMap.get(review.PanelApplication__c+''+review.PanelUser__c) == null){
                        reviewsList.add(review);
                    }
                }                        
                if(Schema.sObjectType.Review__c.isCreateable()){
                    insert reviewsList;
                }
                
                String PageReferenceURL = '/apex/'+ns+'ReviewPanelView?id=' + panelId;
                if(!String.isEmpty(tabName)){
                    PageReferenceURL+='&tabName='+tabName;
                }
                resultMap.put('PageReference',PageReferenceURL);
            }else{
                // resultMap.put('Message','Please select Applications to assign to this reviewer');
                resultMap.put('Message',GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-09605'));   
            }
            
        }catch(Exception e){
            resultMap.put('Message',e.getMessage());    
            Database.rollback(sp);
        }
        return resultMap;
    }
}