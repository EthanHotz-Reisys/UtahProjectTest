public with sharing class ReviewerConfirmationEditCtrl {
    public String recordName {get;set;}
    public String appId {get;set;} 
    public String annId {get;set;} 

    public String title{get;set;} 

    public ID recordId {get;set;}
    public ID taskId {get;set;}
    public String namespace;

    public PageReference savePage {get;set;}
    public PageReference cancelPage {get;set;}
    public String pageTemplateName {get;set;}
    public List<GNT.DynamicLayoutDefaultValueHelper> listDefaultValues {get;set;}
    String appName = GNT.UserPreferenceHelper.getStringValue('ActiveAppName__c');
    
    public ReviewerConfirmationEditCtrl(){
        recordId = ApexPages.CurrentPage().getParameters().get('id');

        namespace = AppUtils.getNamespacePrefix();
        system.debug('--inside ReviewerConfirmationCtrl------*****************************************----');
        Review__c review = [Select Id, Name, Application__r.Name,Application__r.Title__c,Application__r.AnnouncementNumber__c  from Review__c where id=:recordId];
        title=review.Application__r.Title__c;
        appId=review.Application__r.Name;
        annId=review.Application__r.AnnouncementNumber__c;    
     }

     public ReviewerConfirmationEditCtrl(ApexPages.StandardController stdController){
        recordId = ApexPages.CurrentPage().getParameters().get('Id');
        taskId = ApexPages.CurrentPage().getParameters().get('taskId');  
        system.debug('*******************taskId is ' +taskId);
        system.debug('--inside ReviewerConfirmationCtrl-------------------------------------------');
        Review__c review = [SELECT Id, ReviewPanel__r.ReviewStep__r.ReviewFormConfig__r.Name, ReviewPanel__c,ReviewAcceptanceStatus__c,ReviewPanel__r.ReviewPackage__c,
        ReviewPanel__r.ReviewPackage__r.GNT__PageTemplateConfig__c, PanelApplication__c, Status__c, AcceptanceStatus__c,Application__c,Application__r.OwnerId, 
        PreApplication__c,PreApplication__r.OwnerId FROM Review__c WHERE id=:recordId]; 
   
        String nextAction=  ApexPages.CurrentPage().getParameters().get('nextAction');
        system.debug('--inside reviewCheck---nextAction---'+nextAction);
        List<Review__c> reviewObjList =  [Select Id, Name, Recommendation__c,ReviewDeclineReason__c,Status__c,ReviewAcceptanceStatus__c  from Review__c where id =:recordId Limit 1];
        Review__c review1 = reviewObjList[0];
        system.debug('--inside reviewCheck---review1---'+review1);
        if(nextAction=='Edit'){
            PageReference reviewEditPage = new PageReference('/apex/ReviewerConfirmation');
            reviewEditPage.getParameters().put('Id',ApexPages.currentPage().getParameters().get('id'));
            reviewEditPage.setRedirect(true);
           // return reviewEditPage ;
             }
         if(review.Status__c == 'Declined Due To Conflict' || review.Status__c == 'Declined Without Conflict'){
                pageTemplateName = 'ReviewFormDeclined';
            }
            else if(review.ReviewAcceptanceStatus__c=='Accepted'){
                pageTemplateName = review.ReviewPanel__r.ReviewStep__r.ReviewFormConfig__r.Name;
            }
            else{
                pageTemplateName = 'ReviewerConfirmation';      
            }
            savePage=Page.ReviewerConfirmationView;
            savePage.getParameters().put('id', recordId);
    }    
   
    public string getKeyValueMap(){
        Map<String,String> keyValueMap = new Map<String,String>();
        System.debug('RecordId: ' + recordId);
        keyValueMap.put('id',ApexPages.currentPage().getParameters().get('id'));
        system.debug('taskid in ReviewAssignmentEditCtrl is ' + ApexPages.currentPage().getParameters().get('taskId'));
        keyValueMap.put('taskId',ApexPages.currentPage().getParameters().get('taskId'));       
        return JSON.serialize(keyValueMap);
    }    
    
    public PageReference redirect(){
        String nextAction=  ApexPages.CurrentPage().getParameters().get('nextAction');
        system.debug('--inside reviewCheck---nextAction---'+nextAction);
         List<Review__c> reviewObjList =  [Select Id, Name, Recommendation__c,ReviewDeclineReason__c,Status__c,ReviewAcceptanceStatus__c  from Review__c where id =:recordId Limit 1];
            Review__c review = reviewObjList[0];
           
             system.debug('--inside reviewCheck---review---'+review);

            /* if(nextAction=='Edit'){
            PageReference reviewEditPage = new PageReference('/apex/ReviewerConfirmation');
            reviewEditPage.getParameters().put('Id',ApexPages.currentPage().getParameters().get('id'));
            reviewEditPage.setRedirect(true);
            return null ;
             }
*//*
             if(review.ReviewAcceptanceStatus__c=='Accepted'){
            PageReference reviewEditPage = new PageReference('/apex/ReviewAssignmentEdit');
            reviewEditPage.getParameters().put('Id',ApexPages.currentPage().getParameters().get('id'));
            reviewEditPage.setRedirect(true);
            return reviewEditPage ;
                }else if(review.ReviewAcceptanceStatus__c=='Declined'){
            PageReference newPage = new PageReference('/apex/PhaseView?t=Application');
            newPage.setRedirect(true);
            return newPage ;        
                }
     
*/
        if(nextAction =='Continue'){              
            review.ReviewAcceptanceStatus__c='Accepted';
            review.Comments__c='';
            update review;
            PageReference reviewEditPage = new PageReference('/apex/ReviewAssignmentEdit');
            reviewEditPage.getParameters().put('id',ApexPages.currentPage().getParameters().get('id'));
            reviewEditPage.getParameters().put('taskId',ApexPages.currentPage().getParameters().get('taskId'));
            system.debug('taskid in ReviewAssignmentEditCtrl is ' + ApexPages.currentPage().getParameters().get('taskId'));
            reviewEditPage.setRedirect(true);
            return reviewEditPage ;
            }
        else if (nextAction =='Decline'){
                  //update Review Record
            Id recordId=ApexPages.currentPage().getParameters().get('id');
            system.debug('--review.ReviewDeclineReason__c--'+review.ReviewDeclineReason__c);
            if(review.ReviewDeclineReason__c==null || review.ReviewDeclineReason__c=='None'|| review.ReviewDeclineReason__c==''){
               ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-69138'))); 
               return null;
            }
            review.Recommendation__c='Review Declined';
            review.Rating__c='0';
            review.ReviewAcceptanceStatus__c='Declined';
           // review.ReviewDeclineReason__c='Conflict of Interest';
            review.Status__c='Review Completed';
            update review;

            PageReference newPage = new PageReference('/apex/PhaseView?t=Application');
            newPage.setRedirect(true);
            return newPage ; 
        }   
        else {
             PageReference reviewEditPage = new PageReference('/apex/ReviewerConfirmationView');
            reviewEditPage.getParameters().put('id',ApexPages.currentPage().getParameters().get('id'));
            reviewEditPage.setRedirect(true);
            return null ;

              } 
     return null ;
    } 
}