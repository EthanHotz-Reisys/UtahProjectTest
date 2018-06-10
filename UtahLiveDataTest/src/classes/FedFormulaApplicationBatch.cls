global class FedFormulaApplicationBatch implements Database.Batchable<sObject>, Database.Stateful {
    public String query;
    public List<String> errors;
    public FileBatch__c fb;
    public List<Application__c> applications;
    public Set<Id> applicationIds = new Set<Id>();
    public List<FedBudgetMain__C> newMainItems;
    public Set<Id> announcementIds = new Set<Id>();

    global FedFormulaApplicationBatch(FileBatch__c fb,  List<FedBudgetMain__C> newMainItems, List<Application__c> applications) {
        this.fb = fb;
        this.applications = applications;
        this.newMainItems = newMainItems;
        errors = new List<String>();
    }

    global List<Application__c> start(Database.BatchableContext BC) {
        for (Application__c application : this.applications) {
            announcementIds.add(application.Announcement__C);
        }
        return this.applications;
    }
    global void execute(Database.BatchableContext BC, List<Application__c> scope) {
        Savepoint sp = Database.setSavepoint();
        try {
            for (Application__c application : scope) {
                application.put('FederalProgram__c', '');
            }
            insert scope;
            for (Application__c application : scope) {
                applicationIds.add(application.id);

            }

        } catch (Exception e) {
            string message = 'Error::FedFormulaApplicationBatch' + e.getMessage()
                             + ',Stacktrace::' + e.getStackTraceString() + e.getCause();
            errors.add(message);
            System.debug(message);
            Database.rollback(sp);
        }
    }

    global void finish(Database.BatchableContext BC) {
        if (errors.size() == 0) {
            fb.Status__c = 'Active';
            update fb;
            insert this.newMainItems;
            System.debug('MANUALDEBUG >>> scope applications ids >>> exec >>> end:::' + applicationIds.size());
            System.debug('MANUALDEBUG >>> scope applications ids >>> exec >>> end:::' + applicationIds);
            List<Application__c> results = [Select id from Application__c where id in : applicationIds ];
            System.debug('MANUALDEBUG >>> results scope applications ids >>> exec >>> end:::' + results);
            Database.executeBatch(new FedFormulaApplicationShareBatch(this.fb, results), 2000);
            Database.executeBatch(new FedFormulaTaskBatch(this.fb, results), 20);

        } else {

            for (String error : errors) {
                fb.ErrorLog__c =  fb.ErrorLog__c + ';' + error;
            }
            fb.Status__c = 'Error';
            update fb;
            List<Announcement__C> announcements = [select id from Announcement__C where id IN : this.announcementIds];
            delete announcements;
        }
    }
}