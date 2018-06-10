/**
Controller to handle Forgot Passowrd Functionality
 **********************************************************
 Audit History
 **********************************************************
 4/16/2014   Manasi Gangal Created
 5/14/2014   Nakul Kadam Updated forgotPassword()
 **********************************************************  
*/

public with sharing class CommunityForgotPasswordPageCtrl {
    
    public String communityBaseURL{get;set;}
    public String username { get; set; }
    
    
    public CommunityForgotPasswordPageCtrl(){
    	String internal = ApexPages.CurrentPage().getParameters().get('internal');
    	if(internal != null){
        	communityBaseURL = GNT.KeyValueStoreHelper.getTextValue('InternalLoginPage', true);
    	} else{
    		communityBaseURL = GNT.KeyValueStoreHelper.getTextValue('ExternalLoginPage', true);
    	}
    }
    
    public PageReference forgotPassword() {
        
        List<User> users = [select id, ContactId from User where username = :username limit 1];
        if(users.size() == 1){
            User user = users.get(0);
            if(user.ContactId != null){    // Community user
                Site.forgotPassword(username);
            }else{  // Internal User
                System.resetPassword(user.id,true);
            }
            return new PageReference('/apex/'+AppUtils.getNamespacePrefix() +'CommunityPasswordResetConfirm');
        }else{
            //ApexPages.Message errorMessage= new ApexPages.Message(ApexPages.Severity.ERROR,'Username doesn\'t exist. Please enter the correct username.');
            ApexPages.Message errorMessage= new ApexPages.Message(ApexPages.Severity.ERROR,GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTE-93278'));
            ApexPages.addMessage(errorMessage);
        }
        
        return null;
    }
    

    
   
}