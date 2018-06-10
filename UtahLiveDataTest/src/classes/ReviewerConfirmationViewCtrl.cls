public with sharing class ReviewerConfirmationViewCtrl {
    public String recordName {get;set;}
    public String appId {get;set;} 
    public String annId {get;set;} 

    public String title{get;set;} 

    public ID recordId {get;set;}
    public String namespace;

    public PageReference savePage {get;set;}
    public PageReference cancelPage {get;set;}
    public String pageTemplateName {get;set;}
    public List<GNT.DynamicLayoutDefaultValueHelper> listDefaultValues {get;set;}
    String appName = GNT.UserPreferenceHelper.getStringValue('ActiveAppName__c');
    
    public ReviewerConfirmationViewCtrl(){
        recordId = ApexPages.CurrentPage().getParameters().get('id');
        namespace = AppUtils.getNamespacePrefix();
        
        system.debug('--inside ReviewerConfirmationViewCtrl-------------------------------------------');

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


      
       /* Review__c review = [Select Id, Name, Application__r.Name,Application__r.Title__c,Application__r.AnnouncementNumber__c  from Review__c where id=:recordId];
        title=review.Application__r.Title__c;
        appId=review.Application__r.Name;
        annId=review.Application__r.AnnouncementNumber__c;    */
        savePage = Page.ReviewerConfirmationView;
        savePage.getParameters().put('id', recordId);
        cancelPage = Page.ReviewerConfirmationView;
        cancelPage.getParameters().put('id', recordId);
     }

     public ReviewerConfirmationViewCtrl(ApexPages.StandardController stdController){
        system.debug('--inside ReviewerConfirmationViewCtrl---------------------3523523532----------------------');      
        recordId = ApexPages.CurrentPage().getParameters().get('Id');  
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


                pageTemplateName = 'ReviewerConfirmation';      
              }    
   
        public string getKeyValueMap(){
        Map<String,String> keyValueMap = new Map<String,String>();
        System.debug('RecordId: ' + recordId);
        keyValueMap.put('id',ApexPages.currentPage().getParameters().get('id'));       
        return JSON.serialize(keyValueMap);
    }    

      public PageReference redirect(){
        String nextAction=  ApexPages.CurrentPage().getParameters().get('nextAction');
        List<Review__c> reviewObjList =  [Select Id, Name, Recommendation__c,Compliant__c,ReviewDeclineReason__c,Status__c,ReviewAcceptanceStatus__c  from Review__c where id =:recordId Limit 1];
        Review__c review = reviewObjList[0];           
        if(review.ReviewAcceptanceStatus__c=='Declined' || review.ReviewDeclineReason__c!=null){
        review.Compliant__c='Review Declined';
        review.ReviewAcceptanceStatus__c='Declined';
        review.Rating__c='0';
        review.Status__c='Review Completed';
        update review;
        pageTemplateName = 'ReviewFormDeclined';
        return null ; 
        }
        else if(review.ReviewAcceptanceStatus__c=='Accepted'){
        PageReference reviewViewPage = new PageReference('/apex/ReviewAssignmentView');
        reviewViewPage.getParameters().put('id',ApexPages.currentPage().getParameters().get('id'));
        reviewViewPage.setRedirect(true);
        return reviewViewPage ;
        }

        if(nextAction =='Continue'){              
        review.ReviewAcceptanceStatus__c='Accepted';
        update review;
        PageReference reviewViewPage = new PageReference('/apex/ReviewAssignmentView');
        reviewViewPage.getParameters().put('id',ApexPages.currentPage().getParameters().get('id'));
        reviewViewPage.getParameters().put('taskId',ApexPages.currentPage().getParameters().get('taskId'));
        reviewViewPage.setRedirect(true);
        return reviewViewPage ;
       }
       
     return null ;
    } 
    
 
}