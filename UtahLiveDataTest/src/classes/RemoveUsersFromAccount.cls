global with sharing class RemoveUsersFromAccount extends GNT.FlexTableActionHandler {
       global override Map<String,Object> clickHandler(){
       		Map<String,Object> resultMap = new Map<String,Object>();
       		String accountId = urlParams.get('id'); 
       		Account acct = [select id,Name,Code__c from Account where id=:accountId];
       		List<User> users = [select id,DepartmentCode__c,OrganizationAccountName__c from User where id=:selectedRecordIds];
       		for(User user : users) {
       			user.DepartmentCode__c = null;
       			user.OrganizationAccountName__c = null;
       		}
       		update users;
       		resultMap.put('Success','Notification send successfully.');
            resultMap.put('PageReference','	/apex/AssignUsersToOrg?id=' + accountId);
       		return resultMap;
       }
}