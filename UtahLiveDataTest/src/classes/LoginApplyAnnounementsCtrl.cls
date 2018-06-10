/**
 * An apex page controller that takes the user to the right 
 page based on login or prompt user to login.

 **********************************************************
 Audit History
 **********************************************************
 5/13/2014   Nakul Kadam Created
 **********************************************************  
*/
public with sharing class LoginApplyAnnounementsCtrl {

    public PageReference forwardToApplyPage() {
        Id annId = ApexPages.currentPage().getParameters().get('id');
        //string host = ApexPages.currentPage().getHeaders().get('host');
        String t = ApexPages.currentPage().getParameters().get('t');
        system.debug('Inside LoginApplyAnnounementsCtrl ----------------'+annId);
        system.debug('Inside LoginApplyAnnounementsCtrl -----UserInfo.getUserType()-----------'+UserInfo.getUserType());
        String ns = AppUtils.getNamespacePrefix(); 
        if(UserInfo.getUserType() == 'Guest'){
            if(Network.getNetworkId() == null){ // Internal Site user
                return new PageReference('/'+ns+'InternalLogin?applyId='+annId);
            }else{    // External Community user
                //return new PageReference('https://'+host+'/'+ns+'CommunityLogin?startURL=/'+annId+'?t='+t);
                return new PageReference('/'+ns+'ApplicantLogin2?startURL=/'+annId+'?t='+t);
            }
        }
       // return null;
       return new PageReference('/'+ns+'ApplicantLogin2?startURL=/'+annId+'?t='+t);
    }

}