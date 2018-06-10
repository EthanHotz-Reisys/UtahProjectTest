public class EntityHierarchyBatch implements Database.Batchable<ID> {
    private boolean broke;
    public EntityHierarchyBatch() {
        broke = false;
    }
    public List<ID> start( Database.BatchableContext BC ){
        Set<ID> ids = new Map<ID, Program__c>([select id from Program__c limit 10]).keySet();
        return new List<ID>(ids);
    }
    
    public void execute( Database.BatchableContext BC, List<ID> scope ) {
        ApplicationTriggerHelperUSBE.skipTrigger = true;
        GrantTriggerHelper.skipTrigger = true;
        AwardTriggerHelper.skipTrigger = true;
        USBEAwardTriggerHelper.skipTrigger = true;
        PanelUserTriggerHelper.skipAll = true;
        ReviewGroupTriggerHelper.skipTrigger = true;
        ReviewTriggerHelper.skipTrigger = true;
        RolesAndResponsibilitiesTriggerHelper.skipTrigger = true;
        ProgramTriggerHelperUSBE.skipTrigger = true;
        RolesAndRespTriggerHelperUSBE.skipTrigger = true;
        ReviewStepTriggerHelper.skipTrigger = true;
        ApplicationTriggerHelperUOVC.skipTrigger = true;
        ProgressReportsTriggerHelper.skipTrigger = true;
        TermConditionTriggerHelper.skipTrigger = true;
        BuildUpItemTriggerHelper.skipTrigger = true;
        BuildUpItemTriggerHelper.skipFromAmendment = true;
        GoalObjectiveTriggerHelper.skipTrigger = true;
        ReviewPanelTriggerHelper.skipTrigger = true;
        PanelUserTriggerHelper.skipAll = true;
        EntityHierarchyResolver resolver = new EntityHierarchyResolver();
        try {
            resolver.deleteEntities('Program__c', new Set<ID>(scope));
        } catch (Exception e) {
            broke = true;
            throw e;
        }
    }
    
    public void finish( Database.BatchableContext BC ){ 
        if (broke) { System.abortJob( bc.getJobID() );  }
        List< Program__c > count = [select id from Program__c];
        if (count.size() > 0) {
            Database.executeBatch(new EntityHierarchyBatch() , 9000);
        } else {
            ApplicationTriggerHelperUSBE.skipTrigger = false;
            GrantTriggerHelper.skipTrigger = false;
            AwardTriggerHelper.skipTrigger = false;
            USBEAwardTriggerHelper.skipTrigger = false;
            PanelUserTriggerHelper.skipAll = false;
            ReviewGroupTriggerHelper.skipTrigger = false;
            ReviewTriggerHelper.skipTrigger = false;
            RolesAndResponsibilitiesTriggerHelper.skipTrigger = false;
            ProgramTriggerHelperUSBE.skipTrigger = false;
            RolesAndRespTriggerHelperUSBE.skipTrigger = false;
            ReviewStepTriggerHelper.skipTrigger = false;
            ApplicationTriggerHelperUOVC.skipTrigger = false;
            ProgressReportsTriggerHelper.skipTrigger = false;
            TermConditionTriggerHelper.skipTrigger = false;
            BuildUpItemTriggerHelper.skipTrigger = false;
            BuildUpItemTriggerHelper.skipFromAmendment = false;
            GoalObjectiveTriggerHelper.skipTrigger = false;
            ReviewPanelTriggerHelper.skipTrigger = false;
            PanelUserTriggerHelper.skipAll = false;
            System.debug('Batch complete');
        }
    }
}