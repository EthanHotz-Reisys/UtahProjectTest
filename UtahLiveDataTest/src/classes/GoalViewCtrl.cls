public with sharing class GoalViewCtrl {
    //Properties
    public ID recordId{get;set;}
    public PageReference deleteURL{get;set;}
    private String awardId;
    private String programId;
    private String announcementId;
    private String applicationid;
    private String year;
    public String pageTemplateName {get;set;}
    
    public GoalViewCtrl(ApexPages.StandardController stdController){

        recordId = ApexPages.CurrentPage().getParameters().get('id');
        GoalObjective__c goal = [Select Id, Name, Award__c,Application__c,RecordType.Name,Program__c,Announcement__c, type__c, Year__c from GoalObjective__c where Id=:recordId];
        awardId=goal.Award__c;
        programId=goal.Program__c;
        announcementId = goal.Announcement__c;
        applicationid = goal.Application__c;
        year = goal.Year__c;
        String recordType = goal.recordType.Name;   
        String type=ApexPages.CurrentPage().getParameters().get('type'); 

        if(recordType=='Award' && goal.type__c=='Objective'){
                pageTemplateName='Award Objective';
        }else if(recordType=='Award' && goal.type__c=='Goal'){
                pageTemplateName='Award Goal';
        } else if(recordType=='Program' && goal.type__c=='Objective'){
                pageTemplateName='Program Objective';
        }else if(recordType=='Program' && goal.type__c=='Goal'){
                pageTemplateName='Program Goal';
        }else if(recordType=='Announcement' && goal.type__c=='Objective'){
                pageTemplateName='Announcement Objective';
        }else if(recordType=='Announcement' && goal.type__c=='Goal'){
                pageTemplateName='Announcement Goal';
        }else if(recordType=='Application' && goal.Type__c=='Goal' && type =='VocaApplicationGoal'){
                pageTemplateName='Voca Application Goal';
        }else if(recordType=='Application' && goal.Type__c=='Objective' && type =='VocaApplicationObjective'){
                pageTemplateName='Voca Application Objective';
        }else if(recordType=='Application' && goal.type__c=='Goal'){
            if(year != null){
                pageTemplateName='Application Goal1';
            }else{        
                pageTemplateName='Application Goal';
            }
        
        }else if(recordType=='Application' && goal.type__c=='Objective'){
            if(year != null){
                pageTemplateName = 'Application Objective1';
            }else{
                pageTemplateName = 'Application Objective';
            }
        } 

    } 
    
    public string getKeyValueMap(){
        Map<String,String> keyValueMap = new Map<String,String>();
        keyValueMap.put('goalId',recordId);
        keyValueMap.put('awardId',awardId);
        keyValueMap.put('programid',programId);
        keyValueMap.put('announcementid',announcementId);
        keyValueMap.put('applicationid',applicationid);    
        return JSON.serialize(keyValueMap);
    }

}