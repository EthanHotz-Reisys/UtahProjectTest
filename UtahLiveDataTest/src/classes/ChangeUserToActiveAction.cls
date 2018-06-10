global with sharing class ChangeUserToActiveAction  extends GNT.FlexTableActionHandler{
    global override Map<String,Object> clickHandler(){ 
        Map<String,Object> resultMap = new Map<String,Object>();
        if(selectedRecordIds.size() == 0) {
        	resultMap.put('Message', 'Please select atleast one record');
        	return resultMap;
        }
        List<User> users = [select GNT__GGUserType__c from User where Id in :selectedRecordIds];
        for(User u : users) {
        	u.GNT__GGUserType__c = 'Active';
        }
        update users;
        resultMap.put('Message', 'Selected users changed to active.');
        return resultMap;
    }
}