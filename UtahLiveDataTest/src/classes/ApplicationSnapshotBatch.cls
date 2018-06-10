global class ApplicationSnapshotBatch implements Database.Batchable<sObject>, Database.Stateful {
    public String query;
    public List<String> errors;
    public FileBatch__c fb;
    public List<Application__c> applications;

    global ApplicationSnapshotBatch(FileBatch__c fb, List<Application__c> applications) {
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
            createSnapshots(this.applications);
        } catch (Exception e) {
            errors.add(e.getMessage());
            System.debug(e.getMessage());
            Database.rollback(sp);
            return;
        }
    }
    
    private void createSnapshots(List<Application__c> applications){
        List<Id> idlist = new List<Id>();
        for (Application__c application : applications){
        	idlist.add(application.id);
        }
        if (idlist.size() > 0){
        	ApplicationSnapshotHelper snapshot = new ApplicationSnapshotHelper();
	        snapshot.createSnapshot(idlist);
        }
    }

    global void finish(Database.BatchableContext BC) {
    	system.debug('Application Snapshots completed');
    }
    
}