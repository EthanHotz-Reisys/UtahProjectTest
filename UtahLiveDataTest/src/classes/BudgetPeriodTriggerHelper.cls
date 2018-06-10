/*
    This is a helper class for the Budget Period Trigger

    *******************************************************************************************************************
    Audit History
    *******************************************************************************************************************
    2017-06-06  Davinder Singh     Created

    *******************************************************************************************************************
 */
public with sharing class BudgetPeriodTriggerHelper extends GNT.TriggerHelper {


    public override void processAfterInsert() {
        //insertAnnBudgetCategories(Trigger.New);
    }

    public override void processBeforeUpdate(){
        CreateChangeBudgetPeriodTask((List<BudgetPeriod__c>)Trigger.New);
    }

    public override void processAfterUpdate() {      
        
    }
    
    public override void processBeforeDelete() {
        deleteAnnBudgetCategories(Trigger.old);        
    }


    private void CreateChangeBudgetPeriodTask(List<BudgetPeriod__c> bpList){
        List<Id> ProgramIds = new List<Id>();
        for(BudgetPeriod__c bp : bpList){
            if(bp.ChangeRequired__c == true){
                bp.ChangeRequired__c = false;
                ProgramIds.add(bp.Program__c);
            }
        }

        List<Task> lstTasks = new List<Task>();
        List<Program__c> Programs = [Select Id, Name, OwnerId, ProgramName__c from Program__c where Id IN :ProgramIds];
        for(Program__c temp : Programs){
            Task changeTask = GNT.TaskCreationHandler.createTasks(temp.OwnerId, temp.Id, 'Change Program Budget Period', temp.Name, null, false, null, 'Other', temp.ProgramName__c, false).get(0);
            lstTasks.add(changeTask);
        }
        insert lstTasks;
    }

    // Delete Funding Announcement Budget Category when its BP for Announcement is deleted       
    private void deleteAnnBudgetCategories(List<BudgetPeriod__c> bpList){
        Set<Id> annIdSet = new Set<Id>();
        for (BudgetPeriod__c bp : bpList){
            if(bp.FundingOpportunity__c!=null){
                annIdSet.add(bp.FundingOpportunity__c);
            }
        }        
       List<FundingOpportunityBudgetCategory__c> annBCList = [Select Id, Name from FundingOpportunityBudgetCategory__c 
       where FundingOpportunity__c in : annIdSet and BudgetPeriod__c in : Trigger.oldMap.keySet()];
       if(annBCList.size()>0)
        delete annBCList;
    }
/*
    // Insert Funding Announcement Budget Category when new BP for Announcement is added
    private void insertAnnBudgetCategories(List<BudgetPeriod__c> bpList) {
        List<Id> annID = new List<Id>();
        Set<Id> annIdSet = new Set<Id>();
        Set<Id> pgmIdSet = new Set<Id>();
        Map<Id,BudgetPeriod__c> annIdBudgetPeriodMap = new Map<Id,BudgetPeriod__c>();
        for (BudgetPeriod__c bp : bpList){
            if(bp.FundingOpportunity__c!=null){
                annIdSet.add(bp.FundingOpportunity__c);
                annIdBudgetPeriodMap.put(bp.FundingOpportunity__c,bp);
            }
        }
        for(Announcement__c ann : [Select Id,Program__c from Announcement__c where Id in :annIdSet]){
            pgmIdSet.add(ann.Program__c);
        }        
        List<ProgramBudgetCategory__c> lstBudgetCat = [Select Id,Name,BudgetCategory__c from ProgramBudgetCategory__c where Program__c IN :pgmIdSet];          
        List<AnnouncementServiceArea__c> lstannServiceAreas = [Select Id,Name, Announcement__c from AnnouncementServiceArea__c where Announcement__c IN: annIdSet ];
        List<FundingOpportunityBudgetCategory__c> annBudgetCatlist = new List<FundingOpportunityBudgetCategory__c>();
        FundingOpportunityBudgetCategory__c obj1 ;
        for(AnnouncementServiceArea__c objSA : lstannServiceAreas) {
            for(ProgramBudgetCategory__c objBC : lstBudgetCat) {
                BudgetPeriod__c ObjBP = annIdBudgetPeriodMap.get(objSA.Announcement__c);
                obj1= new FundingOpportunityBudgetCategory__c();
                obj1.BudgetPeriod__c=objBP.Id;
                obj1.BudgetCategory__c=objBC.BudgetCategory__c;
                obj1.FundingOpportunity__c=objBP.FundingOpportunity__c;
                obj1.FundingOpportunityProjectArea__c=objSA.Id;                 
                annBudgetCatlist.add(obj1);
            }
        }
        if(annBudgetCatlist.size()>0) {
            insert annBudgetCatlist;           
        }
    }*/
 }