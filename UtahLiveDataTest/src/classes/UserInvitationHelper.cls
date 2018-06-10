/*  This class is to send an Invitation Email to Person Account SME Reviewers
    **********************************************************
    Audit History
    **********************************************************
    08/12/2015           swati singh 
    **********************************************************  
*/
public with sharing class UserInvitationHelper implements GNT.invokeEmailActionInterface {
    public Id recordId {get;set;}
    public String email {get; set;}
    public Id targetId {get;set;}
    
    public UserInvitationHelper() {
        recordId = ApexPages.currentPage().getParameters().get('id');
        System.debug('recordId--->>>'+recordId);
        fetchEmailCtrlData(recordId);   
    }
    
    public UserInvitationHelper getThis() {
        return this;
    }
    
    public void fetchEmailCtrlData(Id recordId){
        if(recordId != null){
            List<Contact> con = [SELECT Id, Email FROM Contact where Id =: recordId];
            System.debug('con---->>>>'+con);
            if(con.size() > 0){
                email = con[0].Email;
                targetId = con[0].Id;
                String[] toAddresses = new String[] {};
                 for(Contact ct : con){
                    toAddresses.add(ct.email);            
                 }  
              
                EmailTemplate templateId = [Select id from EmailTemplate where developername = 'AdditionalUserEmail'];
                Contact cont = [select id, Email from Contact where email <> null limit 1];
                Map<Id, String[]> recIdToAddressMap = new Map<Id, String[]> ();
                recIdToAddressMap.put(recordId, toAddresses);
                try{
            AppUtils.sendEmailUsingTemplate(templateId.Id, recIdToAddressMap, cont.Id, false);   
         }
         catch(Exception exc){
             system.debug(exc);
             //throw new CustomExceptions.RequiredException('An Error occured in notifying the Applicants');
             throw new CustomExceptions.RequiredException(GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-38725'));
         }
            }
        }
    }
    
    public String actionToInvokeBefore() {
        String soql = 'SELECT Id, SecurityToken__c FROM Contact WHERE Id =: recordId LIMIT 1';
        Contact con = Database.query(soql);
        System.debug('con---->>>'+con);
        String message = '';
        if(con != null){
            List<User> uList = [SELECT Id, ManagerId from User Where Id =: UserInfo.getUserId()];
           /* if(uList != null && uList.size() > 0){
                con.ReviewerApprover__c =  uList[0].ManagerId;  
                System.debug('con.ReviewerApprover__c--->'+con.ReviewerApprover__c);
            } */
            if(con.SecurityToken__c == null || con.SecurityToken__c == ''){
                con.SecurityToken__c = GNT.AppUtils.generateToken(32);
                System.debug('con.SecurityToken__c--->>>'+con.SecurityToken__c);
            }
            try{
               // update con;
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
        String soql = 'SELECT Id, ReviewerStatus__c FROM Contact WHERE Id =: recordId LIMIT 1';
        Contact con = Database.query(soql);
        String message = '';
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