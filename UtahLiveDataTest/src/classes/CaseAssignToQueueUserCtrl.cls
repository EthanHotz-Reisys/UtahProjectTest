public with sharing class CaseAssignToQueueUserCtrl {
    public CaseAssignToQueueUserCtrl() {
    	
    }
    
    public String getKeyValueMap() {
    	String queueId = ApexPages.CurrentPage().getParameters().get('queueId');
    	String caseId = ApexPages.CurrentPage().getParameters().get('caseId');
    	List<GroupMember> groupMembers = [Select UserOrGroupId From GroupMember where GroupId =:queueId];
    	String caseOwnerId = [select OwnerId from Case__c where Id =:caseId].OwnerId;
    	List<String> userIds = new List<String>();
    	for(GroupMember gm : groupMembers) {
    		if(caseOwnerId != gm.UserOrGroupId) {
	    		userIds.add(gm.UserOrGroupId);
    		}
    	}
    	Map<String, Object> keyValMap = new Map<String, Object>();
    	keyValMap.put('userIds', userIds);
    	keyValMap.put('caseId', caseId);
    	return JSON.serialize(keyValMap);
    }
}