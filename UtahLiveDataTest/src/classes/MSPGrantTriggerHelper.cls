global with sharing class MSPGrantTriggerHelper extends GNT.TriggerHelper {
    public override void processAfterInsert() {
        shareToLea((List<Grant__c>)Trigger.new);
        //syncRolesAndRespWithProgram((List<Grant__c>) Trigger.New);
    }

    public void shareToLea(List<Grant__c> grantList) {
        List<Id> leaIds = new List<Id>();
        for (Grant__c grant : grantList) {
            leaIds.add(grant.InternalOrganization__c);
        }

        List<User> leaUsers = [SELECT Id, AccountId FROM User WHERE AccountId IN :leaIds AND IsActive = true];
        Map<String, List<User>> userMap = new Map<String, List<User>>();
        for (User u : leaUsers) {
            if (userMap.get(u.AccountId) == null) {
                List<User> ul = new List<User>();
                ul.add(u);
                userMap.put(u.AccountId, ul);
            } else {
                userMap.get(u.AccountId).add(u);
            }
        }


        List<Grant__Share> shareList = new List<Grant__Share>();
        for (Grant__c grant : grantList) {
            if (grant.InternalOrganization__c != null && userMap.get(grant.InternalOrganization__c) != null && grant.ExternalOrgName__c == 'USBE') {
                for (User u : userMap.get(grant.InternalOrganization__c)) {
                    Grant__Share share = new Grant__Share();
                    share.UserOrGroupId = u.Id;
                    share.AccessLevel = 'Read';
                    share.ParentId = grant.Id;
                    share.RowCause = Schema.Grant__Share.RowCause.SharetoExternalPOC__c;
                    shareList.add(share);
                }
            }
        }
        if (shareList.size() > 0 && Schema.sObjectType.Grant__Share.isCreateable()) {
            SystemContextMethodsHelper SystemContextMethodsHelper = new SystemContextMethodsHelper();
            SystemContextMethodsHelper.upsertGrantShare(shareList);
        }
    }

    //Sets the roles for the later awards for the updated Roles&Resp functionalities
    private void syncRolesAndRespWithProgram(List<Grant__c> grantList) {
        Map<Id, Id> programIdMapGrantId = new Map<Id, Id>();
        for (Grant__c grantIterator : grantList) {
            programIdMapGrantId.put(grantIterator.Program__c, grantIterator.Id);
        }
        // Fetch name of program approvers from R&R object
        List<RolesAndResponsibilities__c> grantRolesAndRespList = [
                    SELECT Id, Name__c, Announcement__c, BusinessRole__c, Responsibility__c
                    FROM RolesAndResponsibilities__c
                    WHERE Program__c IN: programIdMapGrantId.keySet()];
        System.debug('MANUALDEBUG >>> grantRolesAndRespList: ' + grantRolesAndRespList);
        if (grantRolesAndRespList != null && grantRolesAndRespList.size() > 0) {
            for (RolesAndResponsibilities__c rolesAndRespIterator : grantRolesAndRespList) {
                rolesAndRespIterator.Grant__c = programIdMapGrantId.get(rolesAndRespIterator.Program__c);
            }
        }
        try {
            System.debug('MANUALDEBUG >>> grantRolesAndRespList: ' + grantRolesAndRespList);
            update grantRolesAndRespList;
        } catch (Exception e) {
            System.debug('MANUALDEBUG >>> error: ' + e);
        }
    }
}