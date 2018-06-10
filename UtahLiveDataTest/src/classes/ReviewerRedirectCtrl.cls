public with sharing class ReviewerRedirectCtrl {

    public PageReference redirect() {
       String uniqueToken = ApexPages.currentPage().getParameters().get('t');
       /* List<UserInvitation__c> invitations = [select id,Status__c,InviteeEmail__c from UserInvitation__c where SecurityToken__c =:uniqueToken  
                      and status__c in ('Invited', 'Declined','Resent','Canceled') LIMIT 1];
       if(invitations != null && invitations.size() > 0){
       	   if(invitations[0].Status__c == 'Canceled'){
       	   	PageReference p = Page.ErrorMessage;
       	   	p.getParameters().put('isReviewer','true');
       	   	p.getParameters().put('isExternalReviewerRejected','true');
       	   	p.setRedirect(true);
       	   	return p; 
       	   }else{
       	   		Boolean byPassNDAPage = GNT.KeyValueStoreHelper.getBooleanValue('NDAPageRequired',true);
       	   		PageReference p;
       	   		if(byPassNDAPage!=null && byPassNDAPage==true){
	       	   		p = Page.NonDisclosureAgreement;
       	   		}else{
           			p = Page.CommunitySelfRegistration;	
       	   		}	
           		p.getParameters().put('isReviewer','true');
           		p.getParameters().put('t',uniqueToken);
           		p.setRedirect(true);
           		return p;
       	   }       	   
           
       } */
           PageReference p = Page.ErrorMessage;
           p.getParameters().put('isReviewer','true');
           p.setRedirect(true);  
           return p;
    }

}