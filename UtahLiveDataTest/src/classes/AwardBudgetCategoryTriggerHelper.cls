/*
    ************************************************************************************
    Audit History
    ************************************************************************************
    8/19/2015       William Moore             Created
    05/04/2017      Sarat Mahavratayajula     Added      updateAwardBudgetCategoryTotal
    ************************************************************************************
*/
global with sharing class AwardBudgetCategoryTriggerHelper  extends GNT.TriggerHelper {

    private Map<Id, Map<Id, AwardBudgetCategory__c>> budgetCategoryMap;
    private Map<Id, AwardServiceArea__c> serviceAreaMap;
    //private Map<Id, Award__c> awardMap;
    global static boolean skipTrigger = false;
    
    public override void ProcessAfterInsert() {
        //CalculateAllocAmountinGrantServiceArea((List<AwardBudgetCategory__c>) Trigger.New);

    }

    public override void ProcessAfterUpdate() {
        //BOD
        //UpdateAllocAmountinGrantServiceArea((List<AwardBudgetCategory__c>) Trigger.New);
        System.debug(skipTrigger);
        if(!skipTrigger){
            updateGrantBudget();    
        }
        
        if (!skipTrigger) {
            updateBudgetRevision((List<AwardBudgetCategory__c>) Trigger.New);
        }
    }
    public override void ProcessAfterDelete() {
        deleteAwardBudgetcatInformation((List<AwardBudgetCategory__c>) Trigger.Old);
    }
    public override void processBeforeDelete() {

    }
    public override void ProcessbeforeInsert() {
        for (AwardBudgetCategory__c awardbudcat : (List<AwardBudgetCategory__c>) Trigger.New) {
            awardbudcat.RemainingAmount__c = awardbudcat.Amount1__c;
        }
    }
    public override void ProcessbeforeUpdate() {
        //updateAwardBudgetCategoryTotal((List<AwardBudgetCategory__c>) Trigger.New);
        if(!skipTrigger){
            for (AwardBudgetCategory__c awardbudcat : (List<AwardBudgetCategory__c>) Trigger.New) {
                AwardBudgetCategory__c awardbudcatold = (AwardBudgetCategory__c)trigger.oldmap.get(awardbudcat.id);
                if (awardbudcat.RemainingAmount__c == null) {
                    awardbudcat.RemainingAmount__c = 0;
                }
                Decimal delta = awardbudcat.Amount1__c -  awardbudcatold.Amount1__c;
                awardbudcat.RemainingAmount__c += delta;
            }
        }
        
    }

    /* private List<AwardBudgetCategory__c> populateMaps(List<AwardBudgetCategory__c> categories) {
        List<AwardBudgetCategory__c> abcs = new List<AwardBudgetCategory__c>();
        Set<Id> awards = new Set<Id>();
        for(AwardBudgetCategory__c abc: categories) {
            if(abc.AwardServiceArea__c != null) {
                abcs.add(abc);
                awards.add(abc.Award__c);
            }
        }
        if(abcs.size() > 0) {
            //awardMap = new Map<Id, Award__c>([SELECT AmountAwardedThisBudgetPeriod__c, Id FROM Award__c WHERE Id IN: awards]);
            List<AwardServiceArea__c> asas = [SELECT Id, DirectAmount__c, IndirectAmount__c, Adjustment__c, Award__c
                                                FROM AwardServiceArea__c WHERE Award__c IN: awards];
            serviceAreaMap = new Map<Id, AwardServiceArea__c>();
            for(AwardServiceArea__c asa: asas) {
                serviceAreaMap.put(asa.Id, asa);
            }
            List<AwardBudgetCategory__c> totalAbcs = [SELECT Adjustment__c, BudgetCategory__c, Award__c
                                                    FROM AwardBudgetCategory__c
                                                    WHERE AwardServiceArea__c = null AND Award__c IN: awards];
            budgetCategoryMap = new Map<Id, Map<Id, AwardBudgetCategory__c>>();
            for(AwardBudgetCategory__c abc: totalAbcs) {
                if(!budgetCategoryMap.containsKey(abc.Award__c)) {
                    budgetCategoryMap.put(abc.Award__c, new Map<Id, AwardBudgetCategory__c>());
                }
                budgetCategoryMap.get(abc.Award__c).put(abc.BudgetCategory__c, abc);
            }
        }
        return abcs;
    }*/

    /* private void CalculateAllocAmountinGrantServiceArea(List<AwardBudgetCategory__c> categories){
    List<Id> GrantserviceareaID = new List<Id>();
    for(AwardBudgetCategory__c awdbc:categories){
        GrantserviceareaID.add(awdbc.GrantServiceArea__c);
    }
    List<GrantServiceArea__c> GrantSAList = [Select Id,Name,AmountAllocated__c from GrantServiceArea__c where Id IN: GrantserviceareaID];
    List<GrantServiceArea__c> newGrantSAList = new list<GrantServiceArea__c>();
        for(GrantServiceArea__c grantsa: GrantSAList){
           Decimal sumTotal=0.0;
            for(AwardBudgetCategory__c  awdbc:categories){
              if(awdbc.GrantServiceArea__c==grantsa.Id) {
                 sumTotal = sumTotal+awdbc.Amount1__c;
            }
            grantsa.AmountAllocated__c = grantsa.AmountAllocated__c+sumTotal;
            newGrantSAList.add(grantsa);
        }
    }
     if(!newGrantSAList.isEmpty()) {
            update newGrantSAList;
        }
    }*/

    private void UpdateAllocAmountinGrantServiceArea(List<AwardBudgetCategory__c> categories) {
        List<Id> GrantserviceareaID = new List<Id>();
        for (AwardBudgetCategory__c awdbc : categories) {
            GrantserviceareaID.add(awdbc.GrantServiceArea__c);
        }
        List<GrantServiceArea__c> GrantSAList = [Select Id, Name, AmountAllocated__c from GrantServiceArea__c where Id IN: GrantserviceareaID];
        system.debug('***grantlist' + GrantSAList);
        system.debug('***catlist' + categories);
        Map<Id, AwardBudgetCategory__c> oldawdbcMap = (Map<Id, AwardBudgetCategory__c>)trigger.oldMap;
        List<GrantServiceArea__c> newGrantSAList = new list<GrantServiceArea__c>();
        for (GrantServiceArea__c grantsa : GrantSAList) {
            Decimal sumTotal = 0.0;
            for (AwardBudgetCategory__c  awdbc : categories) {
                if (awdbc.GrantServiceArea__c == grantsa.Id && awdbc.Amount1__c != oldawdbcMap.get(awdbc.Id).Amount1__c) {
                    sumTotal = sumTotal + awdbc.Amount1__c - oldawdbcMap.get(awdbc.Id).Amount1__c;
                    grantsa.AmountAllocated__c = grantsa.AmountAllocated__c + sumTotal;
                }
            }
            newGrantSAList.add(grantsa);
        }
        if (!newGrantSAList.isEmpty()) {
            system.debug('****List' + newGrantSAList);
            update newGrantSAList;
        }
    }

    private void deleteAwardBudgetcatInformation(List<AwardBudgetCategory__c> categories) {
        Set<Id> GrantserviceareaID = new Set<Id>();
        Decimal SumofTotal = 0.0;

        // for old trigger details
        for (AwardBudgetCategory__c awdbc : categories) {
            GrantserviceareaID.add(awdbc.GrantServiceArea__r.Id);
        }
        // Sum total before delete
        List<aggregateResult> results = [select Sum(Amount1__c) Total from AwardBudgetCategory__c where GrantServiceArea__r.Id in :GrantserviceareaID];
        if (results == null) {
            System.debug('results---->>>>' + results);
        }
        for (aggregateResult ar : results) {
            SumofTotal = (Decimal)ar.get('Total');
        }
        List<GrantServiceArea__c> GrantSAList = [Select Id, Name, AmountAllocated__c from GrantServiceArea__c where Id IN: GrantserviceareaID];
        Map<Id, AwardBudgetCategory__c> oldawdbcMap = (Map<Id, AwardBudgetCategory__c>)trigger.oldMap;
        List<GrantServiceArea__c> newGrantSAList = new list<GrantServiceArea__c>();
        for (GrantServiceArea__c grantsa : GrantSAList) {
            for (AwardBudgetCategory__c  awdbc : categories) {
                if (awdbc.GrantServiceArea__c == grantsa.Id ) {
                    SumofTotal = SumofTotal - awdbc.Amount1__c;
                }
                grantsa.AmountAllocated__c = SumofTotal;

            }
            newGrantSAList.add(grantsa);
        }
        if (!newGrantSAList.isEmpty()) {
            update newGrantSAList;
        }
    }

    private void updateAwardBudgetCategoryTotal(List<AwardBudgetCategory__c> categories) {
        Map<Id, List<AwardBudgetCategory__c>> awardToAwdBdgCatMap = new Map<Id, List<AwardBudgetCategory__c>>();

        for (AwardBudgetCategory__c awdBudCat : categories) {
            if (!awardToAwdBdgCatMap.containsKey(awdBudCat.Award__c)) {
                awardToAwdBdgCatMap.put(awdBudCat.Award__c, new List<AwardBudgetCategory__c>());
            }
            awardToAwdBdgCatMap.get(awdBudCat.Award__c).add(awdBudCat);
        }

        //for (Id awardKey : awardToAwdBdgCatMap.keySet()) {
            //List<AwardBudgetCategory__c> awardBudgetCategories = awardToAwdBdgCatMap.get(awardKey);
            //for (AwardBudgetCategory__c awdBudCat : awardBudgetCategories) {
                //awdBudCat.Amount__c = (awdBudCat.GrantorAmount__c == null ? 0 : awdBudCat.GrantorAmount__c) + 
                                        //(awdBudCat.GranteeAmount__c == null ? 0 : awdBudCat.GranteeAmount__c);
            //}
        //}
    }

    /* sync the grant YTD fields with award YTD fields */
    private void updateGrantBudget() {
        List<GrantBudgetCategory__c> updateList = new List<GrantBudgetCategory__c>();
        for (AwardBudgetCategory__c awbc : (List<AwardBudgetCategory__c>)trigger.new) {
            GrantBudgetCategory__c gbc = new GrantBudgetCategory__c();
            gbc.Id = awbc.GrantBudgetCategory__c;
            gbc.Grant__c = awbc.GrantId__c;
            /* gbc.CityAmount__c = awbc.CityAmount__c;
             gbc.BudgetCategory__c = awbc.BudgetCategory__c;
             gbc.BudgetPeriod__c = awbc.BudgetPeriod__c;
             gbc.DisallowedAmount__c = awbc.DisallowedAmount__c;
             gbc.YearToDateSpent__c = awbc.YearToDateSpent__c; */
            gbc.YTDReimbursementPaid__c = awbc.YTDReimbursementPaid__c ;
            gbc.YTDAdvanceApplied__c = awbc.YTDAdvanceApplied__c ;
            gbc.YTDAdvancePaid__c = awbc.YTDAdvancePaid__c ;
            gbc.YTDAdvanceAvailable__c = awbc.YTDAdvanceAvailable__c;
            gbc.YTDReimbursementAvailable__c = awbc.YTDReimbursementAvailable__c;


            updateList.add(gbc);
        }
        if (updateList.size() > 0) {
            upsert updateList;
        }
    }
    
    
    private void updateBudgetRevision(List<AwardBudgetCategory__c> awardBudgetCategoryTriggerList) {
        
        Set<Id> awardIdSet = new Set<Id>();
        for (AwardBudgetCategory__c abcIterator : awardBudgetCategoryTriggerList) {
            awardIdSet.add(abcIterator.Award__c);
        } 
        List<Award__c> awardList = new List<Award__c>([
            SELECT Id, GrantorOrganization__c, BudgetRevisionInitiated__c, RevisionTotalIndirectCost__c, IndirectCostPercentage__c, IndirectCostPercentageProposed__c, BudgetRevisionInitiatedByUSBE__c, ProgramBudgetTypeUSBE__c 
            FROM Award__c 
            WHERE Id IN: awardIdSet]);
        List<AwardBudgetCategory__c> awardBudgetCategoryList = new List<AwardBudgetCategory__c>([
            SELECT Id, ProposedBudgetRevision__c, Award__c, Amount__c, BudgetCategory__r.RowNumber__c, AdminCostValueProposed__c 
            FROM AwardBudgetCategory__c 
            WHERE Award__c IN: awardIdSet AND BudgetCategory__r.RowNumber__c != '570' AND BudgetCategory__r.RowNumber__c != '580' AND BudgetCategory__r.RowNumber__c != '599']);
        System.debug('MANUALDEBUG >>> awardBudgetCategoryList = ' + awardBudgetCategoryList);
        
        for (Award__c currentAward : awardList) {
            if (currentAward.GrantorOrganization__c == 'USBE' && currentAward.BudgetRevisionInitiated__c == 'In Progress') { 
                Decimal totalIndirectVal = 0;
                Decimal totalAdminIndirect = 0;
                for (AwardBudgetCategory__c abcList : awardBudgetCategoryList) {
                    System.debug('MANUALDEBUG >>> abcList cell = ' + abcList);
                    if (abcList.Award__c == currentAward.Id) {    
                        totalIndirectVal += abcList.ProposedBudgetRevision__c;
                        if (currentAward.ProgramBudgetTypeUSBE__c == 'CTE') {
                            totalAdminIndirect += abcList.AdminCostValueProposed__c;
                        }    
                    }               
                }
                if (currentAward.BudgetRevisionInitiatedByUSBE__c == 'Indirect Change') {
                    currentAward.RevisionTotalIndirectCost__c = (totalIndirectVal * (currentAward.IndirectCostPercentageProposed__c / 100)).setScale(2);    
                }
                else {
                    currentAward.RevisionTotalIndirectCost__c = (totalIndirectVal * (currentAward.IndirectCostPercentage__c / 100)).setScale(2);   
                }
                System.debug('MANUALDEBUG >>> updated indirect =  ' + totalIndirectVal);
                //update currentAward;
            }
        }
        update awardList;       
    }
    
}