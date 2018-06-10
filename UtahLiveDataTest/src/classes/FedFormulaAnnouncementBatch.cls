global class FedFormulaAnnouncementBatch implements Database.Batchable<sObject>, Database.Stateful {
    public String query;
    public List<String> errors;
    public FileBatch__c fb;
    public List<Announcement__C> announcements;
    public  List<Application__C>  applications;
    public List<FedBudgetMain__C> newMainItems;


    global FedFormulaAnnouncementBatch(FileBatch__c fb, List<FedBudgetMain__C> newMainItems, List<Announcement__C> announcements, List<Application__c>  applications) {
        this.fb = fb;
        this.announcements = announcements;
        this.applications = applications;
        this.newMainItems = newMainItems;
        errors = new List<String>();
    }

    global List<Announcement__C> start(Database.BatchableContext BC) {
        return this.announcements;
    }

    global void execute(Database.BatchableContext BC, List<Announcement__C> scope) {
        Savepoint sp = Database.setSavepoint();

        try {
            System.debug('MANUALDEBUG >>> announcements >>> exec >>> ' + this.announcements.size());
            insert this.announcements;
        } catch (Exception e) {
            string message = 'Error::FedFormulaAnnouncementBatch' + e.getMessage()
                             + ',Stacktrace::' + e.getStackTraceString() + e.getCause();
            errors.add(message);
            System.debug(message);
            Database.rollback(sp);
            return;
        }
    }

    global void finish(Database.BatchableContext BC) {
        if (errors.size() == 0) {
            Id recordTypeId = Schema.SObjectType.Application__c.getRecordTypeInfosByName().get('Grantor').getRecordTypeId();
            Map<Id, Id> programs = new Map<Id, Id>();
            for (Announcement__c announcement : this.announcements) {
                announcement.FOAStatus__c = 'Published';
                announcement.Status__c = 'Published';
                if (!programs.containsKey(announcement.Program__c)) {
                    programs.put(announcement.Program__c, announcement.Id);
                }
            }
            for (Application__c application : this.applications) {
                if(application.Announcement__c == null){
                    application.Announcement__c = programs.get(application.FederalProgram__c);
                    application.put('FederalProgram__c', '');// .FederalProgram__c = '';
                }
                
            }
            System.debug('MANUALDEBUG >>> announcements >>> finish >>> ' + this.announcements);
            try {
                USBEAnnouncementTriggerHelper.skipTrigger = true;
                update this.announcements;
                USBEAnnouncementTriggerHelper.skipTrigger = false;


                System.debug('MANUALDEBUG >>> announcements >>> finish >>> ' + this.announcements.size());
                System.debug('MANUALDEBUG >>> applications >>> creation >>> ' + this.applications.size());

                /*for(Application__C app : this.applications){
                    system.debug('app>>>' + app.Announcement__c + ',' + app.BudgetAllocation__c);
                }*/
                Database.executeBatch(new FedFormulaApplicationBatch(this.fb, this.newMainItems, this.applications), 20);
            }
            catch(Exception e){
                string message = 'Error::FedFormulaAnnouncementnBatch' + e.getMessage()
                             + ',Stacktrace::' + e.getStackTraceString() + e.getCause();
                system.debug(message);
                USBEAnnouncementTriggerHelper.skipTrigger = false;
            }

        } else {
            for (String error : errors) {
                fb.ErrorLog__c =  fb.ErrorLog__c + ';' + error;
            }

            fb.Status__c = 'Error';
            update fb;
        }
    }
}