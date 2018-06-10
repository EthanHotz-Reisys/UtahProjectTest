public with sharing class BatchConfigCtrl {
     public void refreshCache() {
	    try{
	         Database.executebatch(new GNT.ApprovalProcessCachebatch(UserInfo.getSessionId() ), 10);
	         ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Cache refresh is in progress. It may take few minutes.'));
	    	
       }catch(Exception e){
          ApexPages.AddMessages(e);
    	} 
    }
}