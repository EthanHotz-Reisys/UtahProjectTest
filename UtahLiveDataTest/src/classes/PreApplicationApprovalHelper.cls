global with sharing class PreApplicationApprovalHelper extends GNT.FlexTableActionHandler {
	
	global override Map<String,Object> clickHandler(){
     	Map<String,Object> resultMap = new Map<String,Object>();
    	Id announcementId = ApexPages.CurrentPage().getParameters().get('id');
    	String ns = AppUtils.getNamespacePrefix(); 
    	//Get all the Applications for an Announcement and reset the SelectedForApprovalAction Flag
    	List<Preapplication__c> allPreApplicationList = [Select Id, SelectedforApprovalAction__c From Preapplication__c 
												Where Announcement__c = :announcementId LIMIT :GNT.AppUtils.SOQL_LIMIT];
												
		//Reset the SelectedForApprovalAction Flag
		for(Preapplication__c appInstance: allPreApplicationList){
			appInstance.SelectedforApprovalAction__c = false;
		}
		update allPreApplicationList;
		
		//Get the selected Application List and set the SelectedForApprovalAction Flag to true							
		List<Preapplication__c> selectedPreApplicationList = [Select Id, SelectedforApprovalAction__c From Preapplication__c 
												Where id in :selectedRecordIds LIMIT :GNT.AppUtils.SOQL_LIMIT];
		if(selectedPreApplicationList.isEmpty() != true){
			for(Preapplication__c appInstance : selectedPreApplicationList){
				appInstance.SelectedforApprovalAction__c = true;
			}
		}
		update selectedPreApplicationList;
		
        String PageReferenceURL = '/apex/'+ns+'ConfirmPreApplicationApproval?id=' + announcementId;
        resultMap.put('PageReference',PageReferenceURL);
	    return resultMap;
    }    
}