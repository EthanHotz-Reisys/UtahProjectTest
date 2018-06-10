public with sharing class GoalEditCtrl {
    //Properties
    public ID recordId{get;set;}
    public PageReference deleteURL{get;set;}
    public PageReference savePage {get;set;}
    public PageReference cancelPage {get;set;}
    public String awardId='';
    public String programId='';
    public String announcementId='';
    public String applicationId = '';
    public String formId = '';
    public transient List<GNT.DynamicLayoutDefaultValueHelper> listDefaultValues {get;set;}
    public String pageTemplateName {get;set;}
    
    public GoalEditCtrl(ApexPages.StandardController stdController){
        recordId = ApexPages.CurrentPage().getParameters().get('id'); 
        awardId= ApexPages.CurrentPage().getParameters().get('awardId'); 
        programId= ApexPages.CurrentPage().getParameters().get('programid');
        announcementId= ApexPages.CurrentPage().getParameters().get('announcementid');
        applicationId = ApexPages.CurrentPage().getParameters().get('applicationid');
        formId = ApexPages.CurrentPage().getParameters().get('formid');
        String isParent=ApexPages.CurrentPage().getParameters().get('isParent');
        String goalId=ApexPages.CurrentPage().getParameters().get('goalId');
        String type=ApexPages.CurrentPage().getParameters().get('type');
        String year = ApexPages.CurrentPage().getParameters().get('year');
        GoalObjective__c goalObj = (GoalObjective__c)stdController.getRecord();
        if(year != null){
            if(type == 'ApplicationGoal'){
                pageTemplateName = 'Application Goal1';
            }else if(type == 'ApplicationObjective'){
                pageTemplateName = 'Application Objective1';
            }
        }else if(type=='AwardGoal'){
                pageTemplateName='Award Goal';
        }else if (type=='AwardObjective'){
                pageTemplateName='Award Objective';
        }else if (type=='ProgramGoal'){
                pageTemplateName='Program Goal';
        }else if (type=='ProgramObjective'){
                pageTemplateName='Program Objective';
        }else if (type=='AnnouncementGoal'){
                pageTemplateName='Announcement Goal';
        }else if (type=='AnnouncementObjective'){
                pageTemplateName='Announcement Objective';
        }else if(type == 'ApplicationGoal'){
            pageTemplateName = 'Application Goal';
        }else if(type == 'ApplicationObjective'){
            pageTemplateName = 'Application Objective';
        }
        else if(type == 'VocaApplicationGoal'){
            pageTemplateName = 'Voca Application Goal';
            
        }
        else if (type=='VocaApplicationObjective'){
            pageTemplateName = 'Voca Application Objective';
        }

        listDefaultValues = new List<GNT.DynamicLayoutDefaultValueHelper>();
        
        savePage = Page.GoalView;
        savePage.getParameters().put('id', recordId);
        
         if(stdController.getId() == null){   // New record
        if(awardId!=null){
             GNT.DynamicLayoutDefaultValueHelper dv1 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'Award__c',awardId,true);
            listDefaultValues.add(dv1); 
            if(isParent!=null && isParent=='Yes'){
                        GNT.DynamicLayoutDefaultValueHelper dv2 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'IsParent__c',true,true);
                        listDefaultValues.add(dv2);   
            }
            if(goalId!=null){
                        GNT.DynamicLayoutDefaultValueHelper dv3 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'ParentGoal__c',goalId,true);
                        listDefaultValues.add(dv3);          
             }
            savePage = Page.AwardView;
            savePage.getParameters().put('id', awardId);
        
        }
        else if(applicationId != null){
            GNT.DynamicLayoutDefaultValueHelper dv1 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'Application__c',applicationId,true);
            listDefaultValues.add(dv1);
            if(isParent!=null && isParent=='Yes'){
                        GNT.DynamicLayoutDefaultValueHelper dv2 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'IsParent__c',true,true);
                        listDefaultValues.add(dv2);   
            }
            if(goalId!=null){
                        GNT.DynamicLayoutDefaultValueHelper dv3 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'ParentGoal__c',goalId,true);
                        listDefaultValues.add(dv3);          
            }
            if(year != null){
                GNT.DynamicLayoutDefaultValueHelper dv4 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'Year__c',year,true);
                        listDefaultValues.add(dv4);
            }
            if(formId != null){
                GNT.DynamicLayoutDefaultValueHelper dv5 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'Form__c',formId,true);
                        listDefaultValues.add(dv5);
            }

        }
        else if(announcementId != null){
            GNT.DynamicLayoutDefaultValueHelper dv1 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'Announcement__c',announcementId,true);
            listDefaultValues.add(dv1);   
            if(isParent!=null && isParent=='Yes'){
                        GNT.DynamicLayoutDefaultValueHelper dv2 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'IsParent__c',true,true);
                        listDefaultValues.add(dv2);   
            }
            if(goalId!=null){
                        GNT.DynamicLayoutDefaultValueHelper dv3 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'ParentGoal__c',goalId,true);
                        listDefaultValues.add(dv3);          
            }
            savePage = Page.AwardView;
            savePage.getParameters().put('id', announcementId);

         }
        else if(programId!=null) {
            system.debug(' programId..'+programId);
            GNT.DynamicLayoutDefaultValueHelper dv1 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'Program__c',programId,true);
            listDefaultValues.add(dv1);   
            if(isParent!=null && isParent=='Yes'){
                        GNT.DynamicLayoutDefaultValueHelper dv2 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'IsParent__c',true,true);
                        listDefaultValues.add(dv2);   
            }
            if(goalId!=null){
                        GNT.DynamicLayoutDefaultValueHelper dv3 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'ParentGoal__c',goalId,true);
                        listDefaultValues.add(dv3);          
            }
            savePage = Page.AwardView;
            savePage.getParameters().put('id', programId);      
         }

         // end here
         }       
        
        if (!String.isEmpty(recordId)) {
            cancelPage = Page.GoalView;
            cancelPage.getParameters().put('id', recordId);   
        }        
        
    } 
    
    public string getKeyValueMap(){
        Map<String,String> keyValueMap = new Map<String,String>();        
        return JSON.serialize(keyValueMap);
    }

}