public with sharing class ApplicationAddCommentCtrl {
    public Application__c selectedApp {get;set;}
    
    public ApplicationAddCommentCtrl(){
        selectedApp = new Application__c();
        Id recordId = ApexPages.CurrentPage().getParameters().get('id');
        
        if(recordId != null){
            List<Application__c> appList = [Select Id, FinalApproverComments__c From Application__c where Id = :recordId];
            if(appList.isEmpty() != true){
                selectedApp = appList.get(0);
            }
        }
    }
    
    public void btnAddComment (){
        if(selectedApp != null){
            try{
                if(Schema.sObjectType.Application__c.isUpdateable()){
                    update selectedApp;
                }
            }
            catch(Exception e){
                selectedApp.addError('Exception Occured - ' + e );
            }
        }
    }
    
    public void btnCancel(){
        
    }
    
}