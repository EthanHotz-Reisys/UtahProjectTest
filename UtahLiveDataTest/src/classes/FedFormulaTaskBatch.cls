global class FedFormulaTaskBatch implements Database.Batchable<sObject>, Database.Stateful {
    public String query;
    public List<String> errors;
    public FileBatch__c fb;
    public List<Application__c> applications;

    global FedFormulaTaskBatch(FileBatch__c fb, List<Application__c> applications) {
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
            createTasks(scope);
        } catch (Exception e) {
            errors.add(e.getMessage());
            System.debug(e.getMessage());
            Database.rollback(sp);
            return;
        }
    }

    private void createTasks(List<Application__C> masterApplications) {
        List<Task> tasks = new List<Task>();
        Set<Id> appIds = new Set<Id>();
        Set<Id> leaIdList = new Set<Id>();
        List<Application__C> applications = [select id, Name, OwnerId, AnnouncementTitle__c, ExternalOrganization__c from Application__C Id where id IN: masterApplications];
        
        List<Id> queueIdList = new List<Id>();
        for(Application__c app : applications){
            queueIdList.add(app.OwnerId);
        }
        Map<Id, Group> queueIdMap = new Map<Id, Group>([SELECT Id, Name FROM Group WHERE Id IN :queueIdList]);

        List<GNT.EmailFeeder> emails = new List<GNT.EmailFeeder>();
        for (Application__C application : applications) {
            /*
            List<Task> budgetCreationApprovalTask = GNT.TaskCreationHandler.createTasks(application.OwnerId,
                                                    application.Id, 'Fed Formula Application',
                                                    application.Name, null, false, null,
                                                    'Complete and Submit', application.Name, false
                                                                                       );
            */
            List<Task> budgetCreationApprovalTask = GNT.TaskCreationHandler.createTasks(null,
                                                    application.Id, 'Application Invitation',
                                                    application.Name, queueIdMap.get(application.OwnerId).Name, false, null,
                                                    'Complete and Submit', application.AnnouncementTitle__c, false
                                                                                       );
            if (budgetCreationApprovalTask != null && budgetCreationApprovalTask.size() > 0) {
                for(Task t : budgetCreationApprovalTask){
                    tasks.add(t);
                    appIds.add(application.Id);
                    leaIdList.add(application.ExternalOrganization__c);
                }
            }
        }
        if (tasks.size() > 0) {
            insert tasks;
            List<User> leaUserList = [
                SELECT Id, Email, ProfileName__c, AccountId, ContactId 
                FROM User 
                WHERE AccountId IN: leaIdList AND (ProfileName__c = 'SPA' OR ProfileName__c = 'SPI')];
            Map<Id, List<User>> accountIdMapUserList = new Map<Id, List<User>>();
            for (User userIterator : leaUserList) {
                List<User> userList = accountIdMapUserList.get(userIterator.AccountId);
                if (userList == null) {
                    userList = new List<User>();
                    accountIdMapUserList.put(userIterator.AccountId, userList);
                }
                userList.add(userIterator);
            }
            AppUtils.TaskEmailWrapper taskEmailer = new AppUtils.TaskEmailWrapper();
            taskEmailer.setObjectList(new List<Id>(appIds));
            taskEmailer.setUserList(leaUserList);
            taskEmailer.setAccountIdMapUserList(accountIdMapUserList);
            taskEmailer.setEmailTemplateDevName('Application_Invite');
            String resultMessage = taskEmailer.massSendEmailMapOrg();
            System.debug('MANUALDEBUG >>> tasks >>> end:::' + tasks.size());
        }

    }

    global void finish(Database.BatchableContext BC) {
        system.debug('FedFormula Tasks creation completed');
    }
    
}