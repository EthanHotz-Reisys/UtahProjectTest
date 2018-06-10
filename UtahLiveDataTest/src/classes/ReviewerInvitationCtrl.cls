/*  This class is to send an Invitation Email to Person Account SME Reviewers
    **********************************************************
    Audit History
    **********************************************************
    08/12/2015           Shrawan Rain              Created
    **********************************************************  
*/
public without sharing class ReviewerInvitationCtrl implements GNT.invokeEmailActionInterface {
    public Id recordId {get;set;}
    public String email {get; set;}
    public String emailTemplateName {get; set;}
    
    public Id targetId {get;set;}
    public String isBulkMode {get;set;}
    public Boolean isUser {get;set;}
    public ReviewerInvitationCtrl() {
        recordId = ApexPages.currentPage().getParameters().get('id');
        isBulkMode = ApexPages.currentPage().getParameters().get('bulkMode');
        System.debug('recordId--->>>'+recordId);
        fetchEmailCtrlData(recordId);   
    }
    
    public ReviewerInvitationCtrl getThis() {
        if(isBulkMode != 'true'){
            return this;    
        }else {
            return null;
        }
    }
    
    public void fetchEmailCtrlData(Id recordId){
        if(recordId != null && isBulkMode != 'true'){
            List<Contact> con = [SELECT Id, Email,accountid,account.parentId FROM Contact where Id =: recordId];
            if(con[0].account.parentId == null){
            emailTemplateName = 'AdditionalUserEmail';
            } else if(con[0].account.parentId != null) {
            emailTemplateName = 'ChildOrgUserEmail';
            }
            
            System.debug('con---->>>>'+con);
            if(con.size() > 0){
                email = con[0].Email;
                targetId = con[0].Id;
            }
        }
    }
    
    public String actionToInvokeBefore() {
        String message = '';
        String soql = 'SELECT Id, SecurityToken__c FROM Contact WHERE Id =: recordId LIMIT 1';
        Contact con = Database.query(soql);        
        System.debug('con---->>>'+con);        
        if(con != null){
            if(con.SecurityToken__c == null || con.SecurityToken__c == ''){
                con.SecurityToken__c = GNT.AppUtils.generateToken(32);
                System.debug('con.SecurityToken__c--->>>'+con.SecurityToken__c);
            }
            try{
                //update con;
                message = 'success';
            }
            catch(DMLException e){
                message = 'error';
                System.debug('The following exception has occured : ' + e.getMessage());
            }
        }
        return message;        
    }
    
    public String actionToInvokeAfter() {            
        String message = '';
        String soql = 'SELECT Id, ReviewerStatus__c FROM Contact WHERE Id =: recordId LIMIT 1';
        Contact con = Database.query(soql);        
        if(con != null){
            con.ReviewerStatus__c = 'Invitation Sent';
            try{
                update con;
                message = 'success';
            }
            catch(DMLException e){
                message = 'error';
                System.debug('The following exception has occured : ' + e.getMessage());
            }
        }
        return message;           
    }   
}