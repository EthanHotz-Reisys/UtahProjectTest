/**
 * An apex page controller that takes the user to the right 
  Contact edit page based on internal or external user

 **********************************************************
 Audit History
 **********************************************************
 5/30/2014   Nakul Kadam     Created
 **********************************************************  
*/
 
public with sharing class ContactRedirectCtrl{

    public ContactRedirectCtrl(ApexPages.StandardController controller) {

    }

    // Code we will invoke on page load.
    public PageReference forwardToProfilePage() {
        String ns = AppUtils.getNamespacePrefix(); 
        Id userId = System.currentPageReference().getParameters().get('id');
        if(Network.getNetworkId() == null){    // Internal User
            return new PageReference('/apex/'+ns+'ContactEdit?id='+userId );
        }else{    // External user
            return new PageReference('/apex/'+ns+'CommunityUserProfileEdit?id='+userId );
        }
        return null;
    }

}