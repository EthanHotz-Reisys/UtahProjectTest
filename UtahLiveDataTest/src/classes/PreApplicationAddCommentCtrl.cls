public with sharing class PreApplicationAddCommentCtrl {
    public Preapplication__c selectedPreApp {get;set;}
    
    public PreApplicationAddCommentCtrl(){
        selectedPreApp = new Preapplication__c();
        Id recordId = ApexPages.CurrentPage().getParameters().get('id');
        
        if(recordId != null){
            List<Preapplication__c> preAppList = [Select Id, FinalApproverComments__c From Preapplication__c where Id = :recordId];
            if(preAppList.isEmpty() != true){
                selectedPreApp = preAppList.get(0);
            }
        }
    }
    
    public void btnAddComment (){
        if(selectedPreApp != null){
            try{
                update selectedPreApp;
            }
            catch(Exception e){
                selectedPreApp.addError('Exception Occured - ' + e );
                //selectedPreApp.addError(GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTE-59415') + e );
            }
        }
    }
    
    public void btnCancel(){
        
    }
}