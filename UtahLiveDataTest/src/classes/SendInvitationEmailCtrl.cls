/*
    6/10/2014   Manasi Gangal       Created
   30/3/2015   Tanmay Deshpande   Added method checkIfInviteeAlreadyPresent
*/
public without sharing class SendInvitationEmailCtrl {

    public String toAddr { get; set; }
    public Boolean invitationSent {get; set;}
    public String successMsg {get; set;}
    public List<User> reviewersToBeActivated {get;set;}
    public Boolean toActivate{get;set;} 
    public List<Id> reviewersIdsToBeActivated{get;set;} 
   // public List<UserInvitation__c> userInvitationList;  
    public Boolean isAlreadyPresent;
    public String reviewPanelId;
    public SendInvitationEmailCtrl() {
        invitationSent = false;
        toActivate = false;  
        reviewPanelId = ApexPages.CurrentPage().getParameters().get('reviewPanelId');        
        //reviewersIdsToBeActivated = new List<Id>();     
    }
       
    
    public PageReference sendEmail() {
        try{
            toActivate = false;                                
            List<String> emails = splitEmails();
            Set<String> inputMails = new Set<String> ();            
            Map<String,String> emailToStatusMap = new Map<String,String>();            
            Set<String> emailsToBeReSent = new Set<String>();
            Set<String> emailsToBeSent = new Set<String>();
            Set<String> registeredReviewers = new Set<string>(); 
            Set<String> inactiveReviewers = new Set<String>();   
            Set<String> canceledInvitations = new Set<String>();        
            String successMessage = Label.SuccessMessageOnInvitation+' ';
            String reInvitationMessage = Label.ReinvitedReviewers+' ';
            String alreadyRegisteredMessage = Label.AlreadyRegisteredReviewers+' ';
            String activateReviewersMessage = Label.ActivateReviewers+' ';
            inputMails.addAll(emails);                               
            system.debug('inputMails-------'+inputMails);            
            emailToStatusMap = createEmailToStatusMap(inputMails);
            if(emailToStatusMap != null){
                for(String email : emailToStatusMap.keyset()){
                    String status = emailToStatusMap.get(email);
                    if(!(String.isEmpty(status))){
                        if(status.equalsIgnoreCase('invited') || status.equalsIgnoreCase('canceled') ){
                            emailsToBeReSent.add(email);
                        }else if(status.equalsIgnoreCase('registered')){
                            registeredReviewers.add(email);
                        }else if(status.equalsIgnoreCase('not invited')){
                            emailsToBeSent.add(email);
                        }
                    }               
                }
                if(emailsToBeSent.size() > 0){
                    createNewInvitations(emailsToBeSent);                   
                    writePageMessage(emailsToBeSent,successMessage);                    
                }  
                          
                if(emailsToBeReSent.size() > 0){
                    reSendInvitations(emailsToBeReSent);
                    writePageMessage(emailsToBeReSent,reInvitationMessage); 
                }
                
                if(registeredReviewers != null && registeredReviewers.size () > 0){
                    inactiveReviewers = checkIfReviewerIsActive(registeredReviewers);
                    if(inactiveReviewers != null && inactiveReviewers.size() > 0){
                        for(String inactive : inactiveReviewers){
                            registeredReviewers.remove(inactive);
                        }
                    }                   
                    if(registeredReviewers.size() > 0){
                        writePageMessage(registeredReviewers,alreadyRegisteredMessage);
                    }
                    if(inactiveReviewers.size() > 0){
                        writePageMessage(inactiveReviewers,activateReviewersMessage);
                    }
                }                             
            }                                                                                                                 
        }catch(Exception e){
            system.debug('Exception ==='+e);            
            //system.debug('field names------>>>>>'+e.getDmlFieldNames(0));
            //String errorField = e.getDmlFieldNames(0) + '';
            /*if(errorField.containsIgnoreCase('InviteeEmail__c')){   
                system.debug('Invalid Email');          
                ApexPages.Message invalidMail = new ApexPages.Message(ApexPages.Severity.ERROR,Label.invalidEMail);
                ApexPages.addMessage(invalidMail);
            }  */                    
        }        
        toAddr = '';
        return null;
    }
    
    private void writePageMessage(Set<String> emailSet, String message){
        system.debug('emailSet--------->>>>'+emailSet);
        system.debug('message--------->>>>'+message);
        message += '\n';
        for(String email : emailSet){
            message += email + ', ';
        }
        message = message.removeEnd(', ');
        message += '.';
        if(message.ContainsIgnoreCase('inactive users')){
            message += ' '+Label.ClickOnActivateReviewers;
        }
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,message));                                                                                               
    }
    
    
    private Set<String> checkIfReviewerIsActive(Set<String> registeredReviewers){
        Set<String> inactiveReviewers = new Set<String>();            
        List<User> inactiveReviewersList = [SELECT Id,Name,Email FROM User WHERE IsActive = FALSE AND Email IN :registeredReviewers AND IsReviewer__c = TRUE];      
        
        if(inactiveReviewersList.size() > 0){
            reviewersToBeActivated = new List<User>();
            for(User u : inactiveReviewersList){
                inactiveReviewers.add(u.Email);
                reviewersToBeActivated.add(u);
                toActivate = true;
            }
        }
        
        if(inactiveReviewers.size() > 0){
            return inactiveReviewers;
        }
        return null;        
    }
    
    private void createNewInvitations(Set<String> newInvites){
        /* List<UserInvitation__c> newUserInvitaionList = new List<UserInvitation__c>();
        for(String newEmail : newInvites){
            UserInvitation__c userInvite = new UserInvitation__c();
            userInvite.InviteeEmail__c = newEmail;
            userInvite.SecurityToken__c = GNT.AppUtils.generateToken(32);
            newUserInvitaionList.add(userInvite);
        } 
        if(newUserInvitaionList.size() > 0){
            insert newUserInvitaionList; 
        }  */     
    }
    
    private void reSendInvitations(Set<String> emailsToBeReSent){
       /* List<UserInvitation__c > userInvitationListToBeUpdated = new List<UserInvitation__c>();
        for(UserInvitation__c reInvite : userInvitationList){
            if(!(String.isEmpty(reInvite.Status__c)) && (reInvite.Status__c.equalsIgnoreCase('invited') || reInvite.Status__c.equalsIgnoreCase('canceled')) ){
                reInvite.Status__c = 'Invited';
                reInvite.SecurityToken__c = GNT.AppUtils.generateToken(32);        
                userInvitationListToBeUpdated.add(reInvite);                        
            }
        } 
        if(userInvitationListToBeUpdated.size() > 0){
            update userInvitationListToBeUpdated;
        }  */     
        
    }
    
    public Map<String,String> createEmailToStatusMap(Set<string> inputMails){
        system.debug('inputMails----->>>>'+inputMails);
        Map<String,String> emailToStatus = new Map<String,String>();
        // userInvitationList = new List<UserInvitation__c>();
        
        for(String email : inputMails){
            emailToStatus.put(email,'not invited');         
        }
        
        // userInvitationList = [SELECT Id,Name,Status__c,InviteeEmail__c,SecurityToken__c FROM UserInvitation__c WHERE InviteeEmail__c IN :inputMails];
        
        /* if(userInvitationList.size() > 0){
            for(UserInvitation__c invite : userInvitationList){
                emailToStatus.put(invite.InviteeEmail__c,invite.Status__c);
            }
        } */
        
        if(emailToStatus.size() > 0){
            return emailToStatus;
            system.debug('emailToStatus---->>>>'+emailToStatus);
        }
        return null;               
    }
    
    public PageReference ActivateReviewers(){
      
      if(toActivate){
        PageReference activationPage = new PageReference('/apex/'+AppUtils.getNamespacePrefix()+'ActivateReviewer');
        activationPage.getParameters().put('reiviewPanelId',reviewPanelId);
        activationPage.setRedirect(false);
        return activationPage;
      }
      return null;
    }
    
    private List<String> splitEmails() {
        toAddr=toAddr.trim();   
        toAddr = toAddr.toLowerCase();  
        String emailStr = toAddr.replace(';', ',');
        emailStr = emailStr.replace('\n', ',');
        emailStr = emailStr.replace(' ', ',');
        List<String> emails = new List<String>();
        for (String email : emailStr.split(',')) {
            email = email.trim();
            if (!String.isEmpty(email)) {
                emails.add(email);
            }
        }        
        return emails;
    }

                                  
     public String getKeyValueMap(){
      Map<String,Object> keyValueMap = new Map<String,Object>();
      List<String>deactivatedUsers = new List<String>();
      reviewersIdsToBeActivated = new List<Id>();              
      system.debug('reviewersToBeActivated----->>>>>'+reviewersToBeActivated);
      if(reviewersToBeActivated!=null && reviewersToBeActivated.size() > 0){
        for(User reviewer : reviewersToBeActivated){
          deactivatedUsers.add(reviewer.Email);
          reviewersIdsToBeActivated.add(reviewer.Id);
          //RecordIdStorageHelper.setRecordIds(reviewersIdsToBeActivated,'reviewersToBeActivated');
        }              
      }              
      system.debug('deactivatedUsers----------->>>>>'+deactivatedUsers);
      keyValueMap.put('reviewersToBeActivated',reviewersIdsToBeActivated);           
      return JSON.serialize(keyValueMap);
  }
    
}