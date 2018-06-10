global class FedFormulaAnnouncementApplicationBatch implements Database.Batchable<sObject>, Database.Stateful {
    public String query;
    public List<String> errors;
    public FileBatch__c fb;
    public List<Application__c> applications;

    global FedFormulaAnnouncementApplicationBatch(FileBatch__c fb, List<Application__c> applications) {
        this.fb = fb;
        this.applications = applications;
        errors = new List<String>();
    }

    global List<Application__c> start(Database.BatchableContext BC) {
        return this.applications;
    }
    global void execute(Database.BatchableContext BC, List<Application__c> scope) {
        Savepoint sp = Database.setSavepoint();
        try {
            System.debug('MANUALDEBUG >>> applications >>> exec >>> ' + this.applications.size() + ',:' + this.applications);
            insert this.applications;
            System.debug('MANUALDEBUG >>> applications >>> exec >>> end:::' + this.applications.size() + ',:' + this.applications);

        } catch (Exception e) {
            errors.add(e.getMessage());
            System.debug(e.getMessage());

            Database.rollback(sp);
            return;
        }
    }

    private void createTasks(List<Application__C> masterApplications) {
        List<Task> tasks = new List<Task>();
        List<Application__C> applications = [select id, Name, OwnerId, Announcement__r.Name, Announcement__r.AnnouncementName__c from Application__C Id where id IN: masterApplications];
        List<GNT.EmailFeeder> emails = new List<GNT.EmailFeeder>();
        for (Application__C application : applications) {
            List<Task> budgetCreationApprovalTask = GNT.TaskCreationHandler.createTasks(application.OwnerId,
                                                    application.Id, 'Fed Formula Application',
                                                    application.Name, null, false, null,
                                                    'Complete and Submit', application.Announcement__r.Name + ' - ' + application.Announcement__r.AnnouncementName__c, false
                                                                                       );

            if (budgetCreationApprovalTask != null && budgetCreationApprovalTask.size() > 0) {
                tasks.add(budgetCreationApprovalTask[0]);
                GNT.EmailFeeder email = new GNT.EmailFeeder().TargetObjectID(application.OwnerId).template('Application_Created').contextRecordId(application.Id);
                emails.add(email);
            }
        }
        if (tasks.size() > 0) {
            insert tasks;
            GNT.EmailFeeder.SendEmails(emails);
            System.debug('MANUALDEBUG >>> tasks >>> end:::' + tasks.size() + ',:' + tasks);
            System.debug('MANUALDEBUG >>> emails >>> end:::' +  emails);

        }

    }

    private void createShares(List<Application__C> masterApplications) {
        List<Application__C> applications = [select id, OwnerId, Announcement__R.Id, ExternalOrganization__c from Application__C where id IN: masterApplications ];
        Set<Id> organizationIds = new Set<Id>();
        Map<Id, Id> applicationOrganizationMap = new Map<Id, Id>();
        Set<Id> keyUserIds = new Set<Id>();

        for (Application__C app : applications) {
            organizationIds.add( app.ExternalOrganization__c);
            keyUserIds.add(app.OwnerId);
            if (!applicationOrganizationMap.containsKey(app.ExternalOrganization__c)) {
                applicationOrganizationMap.put(app.ExternalOrganization__c, app.Id);
            }
        }

        system.debug('applications size :' + applications.size() + applications);
        system.debug('organizations size :' + organizationIds.size() + organizationIds);
        system.debug('application organization size :' + applicationOrganizationMap.size());

        List<User> users = [select id, accountId from User where isActive = true and accountId in : organizationIds];

        Map<Id, Set<Id>> results = new Map<Id, Set<Id>>();

        for (Id id : organizationIds) {
            Set<Id> userIds = new Set<Id>();
            if (!results.containsKey(id)) {
                results.put(id, userIds);
            }
        }

        for (User u : users) {
            if (results.containsKey(u.AccountId) && !keyUserIds.contains(u.Id)) {
                Set<Id> resultUsers = results.get(u.AccountId);
                resultUsers.add(u.Id);
            }
        }

        List<Application__Share> applicationShares  = new List<Application__Share>();
        system.debug('results :' + results);
        for (Application__C app : applications) {
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
        if (applicationShares.size() > 0 && Schema.sObjectType.Application__Share.isCreateable()) {
            SystemContextMethodsHelper SystemContextMethodsHelper = new SystemContextMethodsHelper();
            SystemContextMethodsHelper.upsertApplicationShare(applicationShares);
        }
        //system.debug('MANUALDEBUG >>> SHARES:' + applicationShares.size() + ',' applicationShares);

    }



    global void finish(Database.BatchableContext BC) {
        if (errors.size() == 0) {
            createTasks(this.applications);
            createShares(this.applications);
            //fb.Status__c = 'Active';
            //update fb;

            /*
            if(fb.ActionType__c == 'Amend'){
                List<FileBatch__c> otherfbs = [SELECT Id, Status__c FROM FileBatch__c WHERE Id != :fb.Id AND Status__c = 'Active' AND FiscalYear__c = :fb.FiscalYear__c];

                for(FileBatch__c otherfb : otherfbs){
                    otherfb.Status__c = 'Replaced';
                }

                update otherfbs;
            }
            */
        }
    }

    public class MyException extends Exception {}
}