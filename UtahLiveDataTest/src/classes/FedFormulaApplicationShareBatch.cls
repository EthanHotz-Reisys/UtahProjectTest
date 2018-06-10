global class FedFormulaApplicationShareBatch implements Database.Batchable<sObject>, Database.Stateful {
    public String query;
    public List<String> errors;
    public FileBatch__c fb;
    public List<Application__c> applications;

    global FedFormulaApplicationShareBatch(FileBatch__c fb, List<Application__c> applications) {
        this.fb = fb;
        this.applications = applications;
        errors = new List<String>();
    }

    global List<Application__c> start(Database.BatchableContext BC) {
        system.debug(' manual >>> applications size :' + applications.size());
        return this.applications;
    }
    global void execute(Database.BatchableContext BC, List<Application__c> scope) {
        Savepoint sp = Database.setSavepoint();
        try {
            createShares(scope);

        } catch (Exception e) {
            errors.add(e.getMessage());
            System.debug(e.getMessage());
			Database.rollback(sp);
            return;
        }
    }

    private void createShares(List<Application__C> masterApplications) {
        system.debug(' manual >>> applications size :' + masterApplications.size());
        List<Application__C> tempApplications = [select id, OwnerId, ExternalOrganization__c from Application__C where id IN: masterApplications ];
        Set<Id> organizationIds = new Set<Id>();
        //Map<Id, Id> applicationOrganizationMap = new Map<Id, Id>();
        Set<Id> keyUserIds = new Set<Id>();

        for (Application__C app : tempApplications) {
            organizationIds.add( app.ExternalOrganization__c);
            keyUserIds.add(app.OwnerId);
            /*
            if (!applicationOrganizationMap.containsKey(app.ExternalOrganization__c)) {
                applicationOrganizationMap.put(app.ExternalOrganization__c, app.Id);
            }
            */
        }

        system.debug(' manual >>> tempApplications size :' + tempApplications.size());
        system.debug(' manual >>> organizations size :' + organizationIds.size());
        //system.debug(' manual >>> application organization size :' + applicationOrganizationMap.size());

        System.debug('organizationIds----------->' + organizationIds);
        List<User> users = [select id, accountId from User where isActive = true and accountId in : organizationIds];
        System.debug('users----------->' + users);

        Map<Id, Set<Id>> results = new Map<Id, Set<Id>>();

        for (Id id : organizationIds) {
            Set<Id> userIds = new Set<Id>();
            if (!results.containsKey(id)) {
                results.put(id, userIds);
            }
        }

        System.debug('results----------->' + results);
        
        for (User u : users) {
            if (results.containsKey(u.AccountId) && !keyUserIds.contains(u.Id)) {
                Set<Id> resultUsers = results.get(u.AccountId);
                resultUsers.add(u.Id);
            }
        }

        System.debug('results----------->' + results);

        List<Application__Share> applicationShares  = new List<Application__Share>();
        system.debug('results :' + results);
        for (Application__C app : tempApplications) {
            Id organizationId = app.ExternalOrganization__c;
            if (results.containsKey(organizationId) && results.get(organizationId).size() > 0) {
                Set<Id> organizationUserIds = results.get(organizationId);
                for (Id userId : organizationUserIds ) {
                    Application__Share share = new Application__Share();
                    share.ParentId = app.Id;
                    share.UserOrGroupId = userId;
                    share.AccessLevel = 'Read';
	                share.RowCause = Schema.Application__Share.RowCause.SharetoExternalUsers__C;
                    applicationShares.add(share);
                }
            }
        }
        System.debug('MANUALDEBUG >>> applicationShares >>> exec :::' + applicationShares.size());
        if (applicationShares.size() > 0 && Schema.sObjectType.Application__Share.isCreateable()) {
            SystemContextMethodsHelper contextHelper = new SystemContextMethodsHelper();
            contextHelper.upsertApplicationShare(applicationShares);
            System.debug('MANUALDEBUG >>> applicationShares >>> exec >>> end:::' + applicationShares.size());

        }
       

    }
    global void finish(Database.BatchableContext BC) {
       //system.debug('Application shares are completed'+ applicationShares.size());
       if (errors.size() == 0) {
             //System.debug('MANUALDEBUG >>> applicationShares >>> exec >>> end:::' + applicationShares);
           System.debug('MANUALDEBUG >>> applicationShares >>> exec >>> end:::');
            
        } else{
            for(String error : errors){
                fb.ErrorLog__c =  fb.ErrorLog__c + '; Application shares failed' + error;
            }

            fb.Status__c = 'Error';         
            update fb;  
        }
    }

}