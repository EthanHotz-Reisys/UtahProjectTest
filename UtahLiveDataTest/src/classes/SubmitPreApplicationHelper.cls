global with sharing class SubmitPreApplicationHelper extends GNT.DynamicLayoutActionRedirect{
	
	
	global override PageReference whenClicked(){ 
		Savepoint sp = Database.setSavepoint();
		 Id recordId = layoutHolder.getPrimarySObject().Id;
		 PreApplication__c preApp = [Select id, status__c from PreApplication__c where id = :recordId];
		try{
			
            //comment flag=true when it goes live
            preApp.Status__c='Submitted';
			update preApp;			
		}catch(Exception e){
			Database.rollback(sp);
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, e.getMessage())); 
		}	
		PageReference pageRef= new PageReference('/apex/PreApplicationView?id='+recordId);
		//pageRef.setRedirect(true);
		return pageRef;	
		//return null;		
	}
	

}