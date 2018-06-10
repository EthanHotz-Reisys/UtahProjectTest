/*
    This is a helper class for the Build up Trigger

    *******************************************************************************************************************
    Audit History
    *******************************************************************************************************************
    2016-04-18  Davinder Sigh     Created
    2016-04-21  Ramu Loke          Added addawardBuildUpInformation,updateAwardBuildUpInformation methods

    *******************************************************************************************************************
 */
public with sharing class BuildUpItemTriggerHelper extends GNT.TriggerHelper {

   //Shivankar: Added skipTrigger conditions
    public static boolean skipTrigger = false;
    public static boolean skipfromAmendment = false;

    public override void processAfterInsert() {

        if (skipTrigger==false && skipfromAmendment == false){
        //BOD
        //updatePreApplicationBuildUpInformation((List<BuildUpItem__c>)Trigger.New);
        updateApplicationBuildUpInformation((List<BuildUpItem__c>)Trigger.New);
        addPaymentBuildUpInformation((List<BuildUpItem__c>)Trigger.New);
        //BOD
        updateApplicationBCTotal((List<BuildUpItem__c>)Trigger.New);
        updateApplicationIndirectCost((List<BuildUpItem__c>)Trigger.New);
        addUpdateAmendmentBuildUpInformation((List<BuildUpItem__c>)Trigger.New);
        addUpdateAwardBuildUpInformation((List<BuildUpItem__c>)Trigger.New);
        }
    }



    public override void processBeforeDelete() {
        if (skipTrigger==false){
        //deletePreApplicationBuildUpInformation((List<BuildUpItem__c>)Trigger.Old);
        deleteApplicationBuildUpInformation((List<BuildUpItem__c>)Trigger.Old);
        deletepaymentBuildUpInformation((List<BuildUpItem__c>)Trigger.Old);
        deleteAwardBudCatBuildUpInformation((List<BuildUpItem__c>)Trigger.Old);
        deleteAmendmentBudCatBuildUpInformation((List<BuildUpItem__c>)Trigger.Old);   
        }
    }



    public override void processAfterDelete() {

        System.debug('Enter Delete----------------------------------');
        if (skipTrigger==false){
        updateApplicationBCTotal((List<BuildUpItem__c>)Trigger.Old);
        updateApplicationIndirectCost((List<BuildUpItem__c>)Trigger.Old);
        addUpdateAmendmentBuildUpInformation((List<BuildUpItem__c>)Trigger.Old);
        }
    }



    public override void processAfterUpdate() {

        if (skipTrigger==false && skipfromAmendment == false){
        //BOD
        //updatePreApplicationBuildUpInformation((List<BuildUpItem__c>)Trigger.New);
        updateApplicationBuildUpInformation((List<BuildUpItem__c>)Trigger.New);
        updatePaymentBuildUpInformation((List<BuildUpItem__c>)Trigger.New);
        updateApplicationBCTotal((List<BuildUpItem__c>)Trigger.New);
        updateApplicationIndirectCost((List<BuildUpItem__c>)Trigger.New);
        addUpdateAwardBuildUpInformation((List<BuildUpItem__c>)Trigger.New);
        addUpdateAmendmentBuildUpInformation((List<BuildUpItem__c>)Trigger.New);
        }
        
    }   



    /* Update Build Up total Information on app BC */
    private void updatePreApplicationBuildUpInformation(List<BuildUpItem__c> buildUpItems) {
        List<Id> appBCID = new List<Id>();
        for (BuildUpItem__c buildUpItem : buildUpItems) {
            appBCID.add(buildUpItem.PreApplicationBudgetCategory__c);
        }
        if (appBCID.size() > 0) {
            Map<Id, PreApplicationBudgetCategory__c> preappBCMap = new Map<Id, PreApplicationBudgetCategory__c>([Select Id, Name, Amount__c, GrantorAmount__c from PreApplicationBudgetCategory__c where Id IN: appBCID]);
            AggregateResult[] aggResults = [Select Sum(GrandTotal__c) grandTotal, Sum(GrantorAmount__c)  grantorAmount , Sum(GranteeAmount__c) granteeAmount , PreApplicationBudgetCategory__c abcId from BuildUpItem__c Where PreApplicationBudgetCategory__c IN :appBCID Group by PreApplicationBudgetCategory__c];
            List<PreApplicationBudgetCategory__c> newAppBCList = new list<PreApplicationBudgetCategory__c>();
        
            for (AggregateResult agg : aggResults) {
                system.debug('***agg**' + agg);
                Id abcId = String.valueOf(agg.get('abcId'));
                PreApplicationBudgetCategory__c abc = preappBCMap.get(abcId);
                if (abc != null) {
                    abc.Amount__c = (Decimal)(agg.get('grandTotal'));
                    abc.GrantorAmount__c = Double.valueOf(agg.get('grantorAmount')) ;
                    abc.GranteeAmount__c = Double.valueOf(agg.get('granteeAmount')) ;
                    system.debug('***abc**' + abc);
                    newAppBCList.add(abc);
                }
            }
            if (!newAppBCList.isEmpty()) {
                update newAppBCList;
            }    
        }    
    }
   


    /* Update Build Up total Information on app BC */
    private void updateApplicationBuildUpInformation(List<BuildUpItem__c> buildUpItems) {
        List<Id> appBCID = new List<Id>();
        for (BuildUpItem__c buildUpItem : buildUpItems) {
            appBCID.add(buildUpItem.ApplicationBudgetCategory__c);
        }
        if (appBCID.size() > 0) {
            Map<Id, ApplicationBudgetCategory2__c> appBCMap = new Map<Id, ApplicationBudgetCategory2__c>([Select Id, Name, Amount__c, GrantorAmount__c from ApplicationBudgetCategory2__c where Id IN: appBCID]);
            AggregateResult[] aggResults = [Select Sum(GrandTotal__c) grandTotal, Sum(GrantorAmount__c)  grantorAmount , Sum(GranteeAmount__c) granteeAmount , ApplicationBudgetCategory__c abcId from BuildUpItem__c Where ApplicationBudgetCategory__c IN :appBCID Group by ApplicationBudgetCategory__c];
            List<ApplicationBudgetCategory2__c> newAppBCList = new list<ApplicationBudgetCategory2__c>();
        
            for (AggregateResult agg : aggResults) {
                system.debug('***agg**' + agg);
                Id abcId = String.valueOf(agg.get('abcId'));
                ApplicationBudgetCategory2__c abc = appBCMap.get(abcId);
                if (abc != null) {
                    abc.Amount__c = (Decimal)(agg.get('grandTotal'));
                    abc.GrantorAmount__c = Double.valueOf(agg.get('grantorAmount')) ;
                    abc.GranteeAmount__c = Double.valueOf(agg.get('granteeAmount')) ;
                    newAppBCList.add(abc);
                }
            }
            if (!newAppBCList.isEmpty()) {
                update newAppBCList;
            }    
        }
    }



    /* Delete Build Up total Information on app BC */
    private void deleteApplicationBuildUpInformation(List<BuildUpItem__c> buildUpItems) {
        List<Id> appBCID = new List<Id>();
        // for old trigger details
        for (BuildUpItem__c buildUpItem : buildUpItems) {
            appBCID.add(buildUpItem.ApplicationBudgetCategory__c);
        }
        if (appBCID.size() > 0) {
            List<ApplicationBudgetCategory2__c> appBCList = [Select Id,Name, Amount__c, GrantorAmount__c, GranteeAmount__c
                    from ApplicationBudgetCategory2__c
                    where Id IN: appBCID ];
            Map<Id,ApplicationBudgetCategory2__c> appBCMap = new Map<Id,ApplicationBudgetCategory2__c>(appBCList);
            List<ApplicationBudgetCategory2__c> newAppBCList = new List<ApplicationBudgetCategory2__c>();
            for (BuildUpItem__c  buildUpItem : buildUpItems) {
                if(buildUpItem.ApplicationBudgetCategory__c!=null){
                        ApplicationBudgetCategory2__c appBC = appBCMap.get(buildUpItem.ApplicationBudgetCategory__c);
                        appBC.Amount__c = appBC.Amount__c - buildUpItem.GrandTotal__c;
                        appBC.GrantorAmount__c = appBC.GrantorAmount__c - buildUpItem.GrantorAmount__c;
                        appBC.GranteeAmount__c = appBC.GranteeAmount__c - buildUpItem.GranteeAmount__c;
                        newAppBCList.add(appBC);
                    }
                }                    
            if (!newAppBCList.isEmpty()) {
                update newAppBCList;
            }    
        }
    }



    /* Delete Build Up total Information on preapp BC */
    private void deletePreApplicationBuildUpInformation(List<BuildUpItem__c> buildUpItems) {
        List<Id> appBCID = new List<Id>();        
        // for old trigger details
        for (BuildUpItem__c buildUpItem : buildUpItems) {
            appBCID.add(buildUpItem.PreApplicationBudgetCategory__c);
        }
        if (appBCID.size() > 0) {
            List<PreApplicationBudgetCategory__c> appBCList = [Select Id,Name, Amount__c, GrantorAmount__c, GranteeAmount__c
                    from PreApplicationBudgetCategory__c
                    where Id IN: appBCID ];
            Map<Id,PreApplicationBudgetCategory__c> appBCMap = new Map<Id,PreApplicationBudgetCategory__c>(appBCList);
            List<PreApplicationBudgetCategory__c> newAppBCList = new List<PreApplicationBudgetCategory__c>();
                for (BuildUpItem__c  buildUpItem : buildUpItems) {
                    if(buildUpItem.PreApplicationBudgetCategory__c!=null){
                        PreApplicationBudgetCategory__c appBC = appBCMap.get(buildUpItem.PreApplicationBudgetCategory__c);
                        appBC.Amount__c = appBC.Amount__c - buildUpItem.GrandTotal__c;
                        appBC.GrantorAmount__c = appBC.GrantorAmount__c - buildUpItem.GrantorAmount__c;
                        appBC.GranteeAmount__c = appBC.GranteeAmount__c - buildUpItem.GranteeAmount__c;
                        newAppBCList.add(appBC);
                    }
                }                    
            if (!newAppBCList.isEmpty()) {
                update newAppBCList;
            }    
        }      
    }



    /* Add Build Up total Information on Award Budget category---By Ramu */
    private void addPaymentBuildUpInformation(List<BuildUpItem__c> buildUpItems) {
        Set<Id> paymentBCID = new Set<Id>();
        for (BuildUpItem__c buildUpItem : buildUpItems) {
            paymentBCID.add(buildUpItem.PaymentBudgetCategory__c);
        }
        if (paymentBCID.size() > 0) {
            List<PaymentBudgetCategory__c> paymentBCList = [Select Id, Name, RequestedExpense__c from PaymentBudgetCategory__c where Id IN: paymentBCID];
            List<PaymentBudgetCategory__c> newpaymentBCList = new list<PaymentBudgetCategory__c>();
            for (PaymentBudgetCategory__c paymentBC : paymentBCList) {
                Decimal sumTotal = 0.0;
                for (BuildUpItem__c  buildUpItem : buildUpItems) {
                    if (buildUpItem.PaymentBudgetCategory__c == paymentBC.Id) {
                        sumTotal = sumTotal + buildUpItem.TotalDirect__c;
                    }
                    paymentBC.RequestedExpense__c = paymentBC.RequestedExpense__c + sumTotal;

                }
                newpaymentBCList.add(paymentBC);
            }
            if (!newpaymentBCList.isEmpty()) {
                update newpaymentBCList;
            }    
        }
    }



    /* Update Build Up total Information on Award BC --by Ramu*/
    private void updatePaymentBuildUpInformation(List<BuildUpItem__c> buildUpItems) {
        Set<Id> paymentBCID = new Set<Id>();
        for (BuildUpItem__c buildUpItem : buildUpItems) {
            paymentBCID.add(buildUpItem.PaymentBudgetCategory__c);
        }
        if (paymentBCID.size() > 0) {
            List<PaymentBudgetCategory__c> paymentBCList = [Select Id, Name, RequestedExpense__c from PaymentBudgetCategory__c where Id IN: paymentBCID];
            Map<Id, BuildUpItem__c> oldBuildupMap = (Map<Id, BuildUpItem__c>)trigger.oldMap;
            List<PaymentBudgetCategory__c> newpaymentBCList = new list<PaymentBudgetCategory__c>();
            for (PaymentBudgetCategory__c paymentBC : paymentBCList) {
                Decimal sumTotal = 0.0;
                for (BuildUpItem__c  buildUpItem : buildUpItems) {
                    if (buildUpItem.PaymentBudgetCategory__c == paymentBC.Id) {
                        sumTotal = sumTotal + buildUpItem.TotalDirect__c - oldBuildupMap.get(buildUpItem.Id).TotalDirect__c;
                    }
                    paymentBC.RequestedExpense__c = paymentBC.RequestedExpense__c + sumTotal;

                }
                newpaymentBCList.add(paymentBC);
            }
            if (!newpaymentBCList.isEmpty()) {
                update newpaymentBCList;
            }    
        }
    }



    /* Delete Build Up total Information on Award BC */
    private void deletepaymentBuildUpInformation(List<BuildUpItem__c> buildUpItems) {
        Set<Id> paymentBCID = new Set<Id>();
        Decimal SumofTotal = 0.0;
        // for old trigger details
        for (BuildUpItem__c buildUpItem : buildUpItems) {
            paymentBCID.add(buildUpItem.PaymentBudgetCategory__c);
        }
        if (paymentBCID.size() > 0) {
            // Sum total before delete
            List<aggregateResult> results = [select Sum(TotalDirect__c) Total from BuildUpItem__c where PaymentBudgetCategory__c in :paymentBCID];
            for (AggregateResult ar : results) {
                SumofTotal = (Decimal)ar.get('Total');
            }

            List<PaymentBudgetCategory__c> paymentBCList = [Select Id, Name, RequestedExpense__c from PaymentBudgetCategory__c where Id IN: paymentBCID];
            Map<Id, BuildUpItem__c> oldBuildupMap = (Map<Id, BuildUpItem__c>)trigger.oldMap;
            List<PaymentBudgetCategory__c> newpaymentBCList = new list<PaymentBudgetCategory__c>();
            for (PaymentBudgetCategory__c paymentBC : paymentBCList) {
                for (BuildUpItem__c  buildUpItem : buildUpItems) {
                    if (buildUpItem.PaymentBudgetCategory__c == paymentBC.Id ) {
                        SumofTotal = SumofTotal - buildUpItem.TotalDirect__c;
                    }
                    paymentBC.RequestedExpense__c = SumofTotal;

                }
                newpaymentBCList.add(paymentBC);
            }
            if (!newpaymentBCList.isEmpty()) {
                update newpaymentBCList;
            }    
        }
    }



    private void addUpdateAwardBuildUpInformation(List<BuildUpItem__c> buildUpItems) {
        set<Id> awdBudCatIds = new set<Id>();
        
        /*
        List<BuildUpItem__c> getBuildUpListUSBE = new List<BuildUpItem__c>([
            SELECT Id, AwardBudgetCategory__c, AwardBudgetCategory__r.RowNumberFormula__c, EquipmentCost__c, CurrentActiveAwardBudgetBuildup__c  
            FROM BuildUpItem__c 
            WHERE AwardBudgetCategory__c =: buildUpItems[0].AwardBudgetCategory__c AND AwardBudgetCategory__r.RowNumberFormula__c = '570' AND CurrentActiveAwardBudgetBuildup__c = 'Created']);
        Decimal sumEquipmentCostUSBE = 0.00;
        if (!getBuildUpListUSBE.isEmpty()) {
            for (BuildUpItem__c buildUpItemIterator : getBuildUpListUSBE) {
                sumEquipmentCostUSBE += buildUpItemIterator.EquipmentCost__c;
            }
        }
        */  

        for (BuildUpItem__c buildUpItem : buildUpItems) {
            if (buildUpItem.AwardBudgetCategory__c != null) {
                awdBudCatIds.add(buildUpItem.AwardBudgetCategory__c);
            }
        }

        if (awdBudCatIds.size() > 0) {
            List<BuildUpItem__c> getBuildUpListUSBE = new List<BuildUpItem__c>([
                SELECT Id, AwardBudgetCategory__c, AwardBudgetCategory__r.RowNumberFormula__c, EquipmentCost__c, CurrentActiveAwardBudgetBuildup__c  
                FROM BuildUpItem__c 
                WHERE AwardBudgetCategory__c IN: awdBudCatIds AND AwardBudgetCategory__r.RowNumberFormula__c = '570' AND CurrentActiveAwardBudgetBuildup__c = 'Created']);
            Map<Id, Decimal> sumEquipmentCostUSBE = new Map<Id, Decimal>();
            if (!getBuildUpListUSBE.isEmpty()) {
                for (Id abcIdIterator : awdBudCatIds) {
                    Decimal sumEquipCostUSBE = 0.00;
                    for (BuildUpItem__c buildUpItemIterator : getBuildUpListUSBE) {
                        if (buildUpItemIterator.AwardBudgetCategory__c == abcIdIterator) {
                            sumEquipCostUSBE += buildUpItemIterator.EquipmentCost__c;
                        }
                    }
                    sumEquipmentCostUSBE.put(abcIdIterator, sumEquipCostUSBE);    
                }           
            }

            Map<Id, AwardBudgetCategory__c> awdBudCatMap = new Map<Id, AwardBudgetCategory__c>(
                [Select Id, Name, Amount__c, GrantorAmount__c, ProposedBudgetRevision__c
                 from AwardBudgetCategory__c
                 where Id IN: awdBudCatIds]);
            AggregateResult[] aggResults = [Select Sum(GrandTotal__c) grandTotal, Sum(GrantorAmount__c)  grantorAmount, Sum(GranteeAmount__c) granteeAmount, Sum(EquipmentCost__c) equipmentAmount, AwardBudgetCategory__c awbId
                                            from BuildUpItem__c
                                            Where AwardBudgetCategory__c IN :awdBudCatIds Group by AwardBudgetCategory__c];
            
            List<AwardBudgetCategory__c> newAwdBudCatList = new list<AwardBudgetCategory__c>();
            for (AggregateResult agg : aggResults) {
                Id awbId = String.valueOf(agg.get('awbId'));
                AwardBudgetCategory__c awardBudgetCategory = awdBudCatMap.get(awbId);
                if (awardBudgetCategory != null) {
                    awardBudgetCategory.Amount__c = Double.valueOf(agg.get('grandTotal'));
                    awardBudgetCategory.GrantorAmount__c = Double.valueOf(agg.get('grantorAmount')) ;
                    awardBudgetCategory.GranteeAmount__c = Double.valueOf(agg.get('granteeAmount')) ;
                    //awardBudgetCategory.ProposedBudgetRevision__c = Double.valueOf(agg.get('equipmentAmount'));
                    //awardBudgetCategory.ProposedBudgetRevision__c = sumEquipmentCostUSBE;
                    awardBudgetCategory.ProposedBudgetRevision__c = sumEquipmentCostUSBE.get(awbId);
                    newAwdBudCatList.add(awardBudgetCategory);
                }
            }
            if (!newAwdBudCatList.isEmpty()) {
                update newAwdBudCatList;    
            }
        }
    }



    /* Delete Build Up total Information on AwardBudgetCategories */
    private void deleteAwardBudCatBuildUpInformation(List<BuildUpItem__c> buildUpItems) {
        Set<Id> awdBudCatIds = new Set<Id>();
        for (BuildUpItem__c buildUpItem : buildUpItems) {
            if (buildUpItem.AwardBudgetCategory__c != null) {
                awdBudCatIds.add(buildUpItem.AwardBudgetCategory__c);
            }
        }
        if (awdBudCatIds.size() > 0) {
            List<AwardBudgetCategory__c> awardBudgetCategoriesList = [Select Id, Name, Amount__c, GrantorAmount__c, GranteeAmount__c
                    from AwardBudgetCategory__c
                    where Id IN: awdBudCatIds];
            Map<Id, AwardBudgetCategory__c> awdBudCatMap = new Map<Id, AwardBudgetCategory__c>(awardBudgetCategoriesList);
            for (BuildUpItem__c buildUpItem : buildUpItems) {
                if (buildUpItem.AwardBudgetCategory__c != null) {
                    AwardBudgetCategory__c awardBudgetCategory = awdBudCatMap.get(buildUpItem.AwardBudgetCategory__c);
                    awardBudgetCategory.Amount__c = awardBudgetCategory.Amount__c - buildUpItem.GrandTotal__c;
                    awardBudgetCategory.GrantorAmount__c = awardBudgetCategory.GrantorAmount__c - buildUpItem.GrantorAmount__c;
                    awardBudgetCategory.GranteeAmount__c = awardBudgetCategory.GranteeAmount__c - buildUpItem.GranteeAmount__c;
                }
            }
            update awardBudgetCategoriesList;    
        }
    }



    private void addUpdateAmendmentBuildUpInformation(List<BuildUpItem__c> buildUpItems) {
        List<Id> PersonnelABC = new List<Id>();
        List<Id> EquipmentABC = new List<Id>();
        List<Id> BenefitABC = new List<Id>();
        List<Id> ContractedABC = new List<Id>();
        List<Id> TravelABC = new List<Id>();
        List<Id> TrainingABC = new List<Id>();
        List<Id> SuppliesABC = new List<Id>();
        List<Id> OtherABC = new List<Id>();
        List<Id> AllABC = new List<Id>();

        System.debug('buildUpItems------------------------>' + buildUpItems);

        for (BuildUpItem__c buildUpItem : buildUpItems) {
            if(buildUpItem.Type__c == 'Personnel'){
                PersonnelABC.add(buildUpItem.AmendmentRequestBudgetCategory__c);
            }else if(buildUpItem.Type__c == 'Equipment'){
                EquipmentABC.add(buildUpItem.AmendmentRequestBudgetCategory__c);
            }else if(buildUpItem.Type__c == 'Fringe Benefits'){
                BenefitABC.add(buildUpItem.AmendmentRequestBudgetCategory__c);
            }else if(buildUpItem.Type__c == 'Contracted Fees'){
                ContractedABC.add(buildUpItem.AmendmentRequestBudgetCategory__c);
            }else if(buildUpItem.Type__c == 'Training'){
                TrainingABC.add(buildUpItem.AmendmentRequestBudgetCategory__c);
            }else if(buildUpItem.Type__c == 'Travel'){
                TravelABC.add(buildUpItem.AmendmentRequestBudgetCategory__c);
            }else if(buildUpItem.Type__c == 'Supplies'){
                SuppliesABC.add(buildUpItem.AmendmentRequestBudgetCategory__c);
            }else if(buildUpItem.Type__c == 'Other'){
                OtherABC.add(buildUpItem.AmendmentRequestBudgetCategory__c);
            }
            AllABC.add(buildUpItem.AmendmentRequestBudgetCategory__c);
        }
        System.debug('AllABC------------------------>' + AllABC);
        List<AggregateResult[]> reList = new List<AggregateResult[]>();

        if (AllABC.size() > 0) {
            
            AggregateResult[] aggResults;
            AggregateResult[] aggResults1;
            AggregateResult[] aggResults2;
            AggregateResult[] aggResults3;
            AggregateResult[] aggResults4;
            AggregateResult[] aggResults5;
            AggregateResult[] aggResults6;
            AggregateResult[] aggResults7;
            if (PersonnelABC.size() > 0) { aggResults = [Select AmendmentRequestBudgetCategory__c ABCId, MatchType__c Type, Grouping(MatchType__c) IsBCTotal, Sum(TotalSalary__c) total from BuildUpItem__c Where AmendmentRequestBudgetCategory__c IN :PersonnelABC Group by ROLLUP(AmendmentRequestBudgetCategory__c, MatchType__c)]; }
            if (EquipmentABC.size() > 0) { aggResults1 = [Select AmendmentRequestBudgetCategory__c ABCId, MatchType__c Type, Grouping(MatchType__c) IsBCTotal, Sum(EquipmentCost__c) total from BuildUpItem__c Where AmendmentRequestBudgetCategory__c IN :EquipmentABC Group by ROLLUP(AmendmentRequestBudgetCategory__c, MatchType__c)]; }
            if (BenefitABC.size() > 0) { aggResults2 = [Select AmendmentRequestBudgetCategory__c ABCId, MatchType__c Type, Grouping(MatchType__c) IsBCTotal, Sum(TotalFBCost__c ) total from BuildUpItem__c Where AmendmentRequestBudgetCategory__c IN :BenefitABC Group by ROLLUP(AmendmentRequestBudgetCategory__c, MatchType__c)]; }
            if (ContractedABC.size() > 0) { aggResults3 = [Select AmendmentRequestBudgetCategory__c ABCId, MatchType__c Type, Grouping(MatchType__c) IsBCTotal, Sum(ContractedFees__c) total from BuildUpItem__c Where AmendmentRequestBudgetCategory__c IN :ContractedABC Group by ROLLUP(AmendmentRequestBudgetCategory__c, MatchType__c)]; }
            if (TrainingABC.size() > 0) { aggResults4 = [Select AmendmentRequestBudgetCategory__c ABCId, MatchType__c Type, Grouping(MatchType__c) IsBCTotal, Sum(TotalCost__c) total from BuildUpItem__c Where AmendmentRequestBudgetCategory__c IN :TrainingABC Group by ROLLUP(AmendmentRequestBudgetCategory__c, MatchType__c)]; }
            if (TravelABC.size() > 0) { aggResults5 = [Select AmendmentRequestBudgetCategory__c ABCId, MatchType__c Type, Grouping(MatchType__c) IsBCTotal, Sum(TravelCost__c) total from BuildUpItem__c Where AmendmentRequestBudgetCategory__c IN :TravelABC Group by ROLLUP(AmendmentRequestBudgetCategory__c, MatchType__c)]; }
            if (SuppliesABC.size() > 0) { aggResults6 = [Select AmendmentRequestBudgetCategory__c ABCId, MatchType__c Type, Grouping(MatchType__c) IsBCTotal, Sum(SupplyCost__c) total from BuildUpItem__c Where AmendmentRequestBudgetCategory__c IN :SuppliesABC Group by ROLLUP(AmendmentRequestBudgetCategory__c, MatchType__c)]; }
            if (OtherABC.size() > 0) { aggResults7 = [Select AmendmentRequestBudgetCategory__c ABCId, MatchType__c Type, Grouping(MatchType__c) IsBCTotal, Sum(SupplyCost__c) total from BuildUpItem__c Where AmendmentRequestBudgetCategory__c IN :OtherABC Group by ROLLUP(AmendmentRequestBudgetCategory__c, MatchType__c)];         }
            
            /*
            AggregateResult[] aggResults = [Select ApplicationBudgetCategory__c ABCId, MatchType__c Type, Grouping(MatchType__c) IsBCTotal, Sum(TotalSalary__c) total from BuildUpItem__c Where ApplicationBudgetCategory__c IN :PersonnelABC Group by ROLLUP(ApplicationBudgetCategory__c, MatchType__c)];
            AggregateResult[] aggResults1 = [Select ApplicationBudgetCategory__c ABCId, MatchType__c Type, Grouping(MatchType__c) IsBCTotal, Sum(EquipmentCost__c) total from BuildUpItem__c Where ApplicationBudgetCategory__c IN :EquipmentABC Group by ROLLUP(ApplicationBudgetCategory__c, MatchType__c)];
            AggregateResult[] aggResults2 = [Select ApplicationBudgetCategory__c ABCId, MatchType__c Type, Grouping(MatchType__c) IsBCTotal, Sum(TotalFBCost__c ) total from BuildUpItem__c Where ApplicationBudgetCategory__c IN :BenefitABC Group by ROLLUP(ApplicationBudgetCategory__c, MatchType__c)];
            AggregateResult[] aggResults3 = [Select ApplicationBudgetCategory__c ABCId, MatchType__c Type, Grouping(MatchType__c) IsBCTotal, Sum(ContractedFees__c) total from BuildUpItem__c Where ApplicationBudgetCategory__c IN :ContractedABC Group by ROLLUP(ApplicationBudgetCategory__c, MatchType__c)];
            AggregateResult[] aggResults4 = [Select ApplicationBudgetCategory__c ABCId, MatchType__c Type, Grouping(MatchType__c) IsBCTotal, Sum(TotalCost__c) total from BuildUpItem__c Where ApplicationBudgetCategory__c IN :TrainingABC Group by ROLLUP(ApplicationBudgetCategory__c, MatchType__c)];
            AggregateResult[] aggResults5 = [Select ApplicationBudgetCategory__c ABCId, MatchType__c Type, Grouping(MatchType__c) IsBCTotal, Sum(TravelCost__c) total from BuildUpItem__c Where ApplicationBudgetCategory__c IN :TravelABC Group by ROLLUP(ApplicationBudgetCategory__c, MatchType__c)];
            AggregateResult[] aggResults6 = [Select ApplicationBudgetCategory__c ABCId, MatchType__c Type, Grouping(MatchType__c) IsBCTotal, Sum(SupplyCost__c) total from BuildUpItem__c Where ApplicationBudgetCategory__c IN :SuppliesABC Group by ROLLUP(ApplicationBudgetCategory__c, MatchType__c)];
            AggregateResult[] aggResults7 = [Select ApplicationBudgetCategory__c ABCId, MatchType__c Type, Grouping(MatchType__c) IsBCTotal, Sum(SupplyCost__c) total from BuildUpItem__c Where ApplicationBudgetCategory__c IN :OtherABC Group by ROLLUP(ApplicationBudgetCategory__c, MatchType__c)];  
            */
            /*
            AggregateResult[] aggResults = [
                SELECT ApplicationBudgetCategory__c ABCId, MatchType__c Type, Grouping(MatchType__c) IsBCTotal, Sum(TotalSalary__c) total 
                FROM BuildUpItem__c 
                WHERE ApplicationBudgetCategory__c IN :PersonnelABC AND (Type__c = 'Personnel' OR Type__c = 'Equipment' OR Type__c = 'Fringe Benefits' OR Type__c = 'Contracted Fees' OR Type__c = 'Training' OR Type__c = 'Travel' OR Type__c = 'Supplies' OR Type__c ='Other') 
                GROUP BY ROLLUP(ApplicationBudgetCategory__c, MatchType__c)];
            //AND Type__c == 'Personnel' OR Type__c == 'Equipment' OR Type__c == 'Fringe Benefits' OR Type__c == 'Contracted Fees' OR Type__c == 'Training' OR Type__c == 'Travel' OR Type__c == 'Supplies' OR Type__c =='Other'
            */
            reList.add(aggResults);
            
            reList.add(aggResults1);
            reList.add(aggResults2);
            reList.add(aggResults3);
            reList.add(aggResults4);
            reList.add(aggResults5);
            reList.add(aggResults6);
            reList.add(aggResults7);
            
            Map<Id, AmendmentRequestBudgetCategory__c> appBCMap = new Map<Id, AmendmentRequestBudgetCategory__c>([Select Id, Name,BudgetCategory__r.Name,Federal__c, InKindMatch__c, CashMatch__c, Amount__c from AmendmentRequestBudgetCategory__c where Id IN :AllABC AND CatName__c != 'Indirect Costs']);
            Set<ID> newAppBCList = new Set<ID>();
            List<AmendmentRequestBudgetCategory__c> re = new List<AmendmentRequestBudgetCategory__c>();
            System.debug('agg--------------------------------------->' + reList);

            for(AggregateResult[] aggre : reList){
                Set<String> bcType = new Set<String>();
                if (aggre != null) {
                    for (AggregateResult agg : aggre) {
                        System.debug('agg--------------------------------------->' + agg);
                        Id abcId = String.valueOf(agg.get('ABCId'));
                        AmendmentRequestBudgetCategory__c abc = appBCMap.get(abcId);
                        if (abc != null) {
                            if(agg.get('IsBCTotal') != 1){
                                if(agg.get('Type') == 'Federal'){
                                    abc.Federal__c = ((Decimal)(agg.get('total'))).setScale(2);
                                    if(!bcType.contains('Federal')){
                                        bcType.add('Federal');
                                    }
                                }else if(agg.get('Type') == 'In-Kind'){
                                    abc.InKindMatch__c = ((Decimal)(agg.get('total'))).setScale(2);
                                    if(!bcType.contains('In-Kind')){
                                        bcType.add('In-Kind');
                                    }
                                }else if(agg.get('Type') == 'Cash'){
                                    abc.CashMatch__c = ((Decimal)(agg.get('total'))).setScale(2);
                                    if(!bcType.contains('Cash')){
                                        bcType.add('Cash');
                                    }
                                }
                                if(!bcType.contains('Federal')){
                                    abc.Federal__c = 0;
                                }
                                if(!bcType.contains('In-Kind')){
                                    abc.InKindMatch__c = 0;
                                }
                                if(!bcType.contains('Cash')){
                                    abc.CashMatch__c = 0;
                                }
                                if(abc.BudgetCategory__r.Name == 'Equipment'){
                                    //abc.TotalGrantCost__c = abc.Federal__c;
                                    abc.Amount__c = abc.Federal__c + abc.InKindMatch__c + abc.CashMatch__c;
                                }
                                else{
                                    //abc.TotalGrantCost__c = abc.Federal__c + abc.Federal__c * abc.Application__r.IndirectCostPercentage__c / 100;
                                    abc.Amount__c = abc.Federal__c + abc.InKindMatch__c + abc.CashMatch__c;
                                }
                                if(!newAppBCList.contains(abcId)){
                                    newAppBCList.add(abcId);
                                    re.add(abc);
                                }
                            }
                            else{
                                bcType = new Set<String>();
                            }
                        }
                    }    
                }
                
            }
            if(Trigger.isAfter && Trigger.isDelete){
                for(Id abcId : appBCMap.keySet()){
                    if(!newAppBCList.contains(abcId)){
                        AmendmentRequestBudgetCategory__c abc = appBCMap.get(abcId);
                        abc.Federal__c = 0;
                        abc.InKindMatch__c = 0;
                        abc.CashMatch__c = 0;
                        //abc.TotalGrantCost__c = 0;
                        abc.Amount__c = 0;
                        re.add(abc);
                    }
                }
            }
            if (!newAppBCList.isEmpty() || re.size() != 0) {
                System.debug(re);
                update re;
            }

            //Map<Id, ApplicationBudgetCategory2__c> appBCMap = new Map<Id, ApplicationBudgetCategory2__c>([Select Id, Name, Amount__c, GrantorAmount__c from ApplicationBudgetCategory2__c where Id IN: appBCID]);
            //AggregateResult[] aggResults = [Select Sum(GrandTotal__c) grandTotal, Sum(GrantorAmount__c)  grantorAmount , Sum(GranteeAmount__c) granteeAmount , ApplicationBudgetCategory__c abcId from BuildUpItem__c Where ApplicationBudgetCategory__c IN :appBCID Group by ApplicationBudgetCategory__c];
            //List<ApplicationBudgetCategory2__c> newAppBCList = new list<ApplicationBudgetCategory2__c>();
        
            //for (AggregateResult agg : aggResults) {
            //    system.debug('***agg**' + agg);
            //    Id abcId = String.valueOf(agg.get('abcId'));
            //    ApplicationBudgetCategory2__c abc = appBCMap.get(abcId);
            //    if (abc != null) {
            //        abc.Amount__c = (Decimal)(agg.get('grandTotal'));
            //        abc.GrantorAmount__c = Double.valueOf(agg.get('grantorAmount')) ;
            //        abc.GranteeAmount__c = Double.valueOf(agg.get('granteeAmount')) ;
            //        newAppBCList.add(abc);
            //    }
            //}
            //if (!newAppBCList.isEmpty()) {
            //    update newAppBCList;
            //}    
        }
    }



    /* Delete Build Up total Information on AmendmentBudgetCategories */
    private void deleteAmendmentBudCatBuildUpInformation(List<BuildUpItem__c> buildUpItems) {
        Set<Id> amdBudCatIds = new Set<Id>();
        for (BuildUpItem__c buildUpItem : buildUpItems) {
            if (buildUpItem.AmendmentRequestBudgetCategory__c != null) {
                amdBudCatIds.add(buildUpItem.AmendmentRequestBudgetCategory__c);
            }
        }
        if (amdBudCatIds.size() > 0) {
            List<AmendmentRequestBudgetCategory__c> amendmentBudgetCategoriesList = [Select Id, Name, Amount__c, GrantorAmount__c, GranteeAmount__c
                    from AmendmentRequestBudgetCategory__c
                    where Id IN: amdBudCatIds];
            Map<Id, AmendmentRequestBudgetCategory__c> amdBudCatMap =
                new Map<Id, AmendmentRequestBudgetCategory__c>(amendmentBudgetCategoriesList);
            for (BuildUpItem__c buildUpItem : buildUpItems) {
                if (buildUpItem.AmendmentRequestBudgetCategory__c != null) {
                    AmendmentRequestBudgetCategory__c amendmentBudgetCategory = amdBudCatMap.get(buildUpItem.AmendmentRequestBudgetCategory__c);
                    //amendmentBudgetCategory.Amount__c = amendmentBudgetCategory.Amount__c - buildUpItem.GrandTotal__c;
                    //amendmentBudgetCategory.GrantorAmount__c = amendmentBudgetCategory.GrantorAmount__c - buildUpItem.GrantorAmount__c;
                    //amendmentBudgetCategory.GranteeAmount__c = amendmentBudgetCategory.GranteeAmount__c - buildUpItem.GranteeAmount__c;
                }
            }
            update amendmentBudgetCategoriesList;
        } 
    }

    private void updateApplicationBCTotal(List<BuildUpItem__c> buildUpItems) {
        
        List<Id> PersonnelABC = new List<Id>();
        List<Id> EquipmentABC = new List<Id>();
        List<Id> BenefitABC = new List<Id>();
        List<Id> ContractedABC = new List<Id>();
        List<Id> TravelABC = new List<Id>();
        List<Id> TrainingABC = new List<Id>();
        List<Id> SuppliesABC = new List<Id>();
        List<Id> OtherABC = new List<Id>();
        List<Id> AllABC = new List<Id>();

        System.debug('buildUpItems------------------------>' + buildUpItems);

        for (BuildUpItem__c buildUpItem : buildUpItems) {
            if(buildUpItem.Type__c == 'Personnel'){
                PersonnelABC.add(buildUpItem.ApplicationBudgetCategory__c);
            }else if(buildUpItem.Type__c == 'Equipment'){
                EquipmentABC.add(buildUpItem.ApplicationBudgetCategory__c);
            }else if(buildUpItem.Type__c == 'Fringe Benefits'){
                BenefitABC.add(buildUpItem.ApplicationBudgetCategory__c);
            }else if(buildUpItem.Type__c == 'Contracted Fees'){
                ContractedABC.add(buildUpItem.ApplicationBudgetCategory__c);
            }else if(buildUpItem.Type__c == 'Training'){
                TrainingABC.add(buildUpItem.ApplicationBudgetCategory__c);
            }else if(buildUpItem.Type__c == 'Travel'){
                TravelABC.add(buildUpItem.ApplicationBudgetCategory__c);
            }else if(buildUpItem.Type__c == 'Supplies'){
                SuppliesABC.add(buildUpItem.ApplicationBudgetCategory__c);
            }else if(buildUpItem.Type__c == 'Other'){
                OtherABC.add(buildUpItem.ApplicationBudgetCategory__c);
            }
            AllABC.add(buildUpItem.ApplicationBudgetCategory__c);
        }
        System.debug('AllABC------------------------>' + AllABC);
        List<AggregateResult[]> reList = new List<AggregateResult[]>();

        if (AllABC.size() > 0) {
            
            AggregateResult[] aggResults;
            AggregateResult[] aggResults1;
            AggregateResult[] aggResults2;
            AggregateResult[] aggResults3;
            AggregateResult[] aggResults4;
            AggregateResult[] aggResults5;
            AggregateResult[] aggResults6;
            AggregateResult[] aggResults7;
            if (PersonnelABC.size() > 0) { aggResults = [Select ApplicationBudgetCategory__c ABCId, MatchType__c Type, Grouping(MatchType__c) IsBCTotal, Sum(TotalSalary__c) total from BuildUpItem__c Where ApplicationBudgetCategory__c IN :PersonnelABC Group by ROLLUP(ApplicationBudgetCategory__c, MatchType__c)]; }
            if (EquipmentABC.size() > 0) { aggResults1 = [Select ApplicationBudgetCategory__c ABCId, MatchType__c Type, Grouping(MatchType__c) IsBCTotal, Sum(EquipmentCost__c) total from BuildUpItem__c Where ApplicationBudgetCategory__c IN :EquipmentABC Group by ROLLUP(ApplicationBudgetCategory__c, MatchType__c)]; }
            if (BenefitABC.size() > 0) { aggResults2 = [Select ApplicationBudgetCategory__c ABCId, MatchType__c Type, Grouping(MatchType__c) IsBCTotal, Sum(TotalFBCost__c ) total from BuildUpItem__c Where ApplicationBudgetCategory__c IN :BenefitABC Group by ROLLUP(ApplicationBudgetCategory__c, MatchType__c)]; }
            if (ContractedABC.size() > 0) { aggResults3 = [Select ApplicationBudgetCategory__c ABCId, MatchType__c Type, Grouping(MatchType__c) IsBCTotal, Sum(ContractedFees__c) total from BuildUpItem__c Where ApplicationBudgetCategory__c IN :ContractedABC Group by ROLLUP(ApplicationBudgetCategory__c, MatchType__c)]; }
            if (TrainingABC.size() > 0) { aggResults4 = [Select ApplicationBudgetCategory__c ABCId, MatchType__c Type, Grouping(MatchType__c) IsBCTotal, Sum(TotalCost__c) total from BuildUpItem__c Where ApplicationBudgetCategory__c IN :TrainingABC Group by ROLLUP(ApplicationBudgetCategory__c, MatchType__c)]; }
            if (TravelABC.size() > 0) { aggResults5 = [Select ApplicationBudgetCategory__c ABCId, MatchType__c Type, Grouping(MatchType__c) IsBCTotal, Sum(TravelCost__c) total from BuildUpItem__c Where ApplicationBudgetCategory__c IN :TravelABC Group by ROLLUP(ApplicationBudgetCategory__c, MatchType__c)]; }
            if (SuppliesABC.size() > 0) { aggResults6 = [Select ApplicationBudgetCategory__c ABCId, MatchType__c Type, Grouping(MatchType__c) IsBCTotal, Sum(SupplyCost__c) total from BuildUpItem__c Where ApplicationBudgetCategory__c IN :SuppliesABC Group by ROLLUP(ApplicationBudgetCategory__c, MatchType__c)]; }
            if (OtherABC.size() > 0) { aggResults7 = [Select ApplicationBudgetCategory__c ABCId, MatchType__c Type, Grouping(MatchType__c) IsBCTotal, Sum(SupplyCost__c) total from BuildUpItem__c Where ApplicationBudgetCategory__c IN :OtherABC Group by ROLLUP(ApplicationBudgetCategory__c, MatchType__c)];         }
            
            /*
            AggregateResult[] aggResults = [Select ApplicationBudgetCategory__c ABCId, MatchType__c Type, Grouping(MatchType__c) IsBCTotal, Sum(TotalSalary__c) total from BuildUpItem__c Where ApplicationBudgetCategory__c IN :PersonnelABC Group by ROLLUP(ApplicationBudgetCategory__c, MatchType__c)];
            AggregateResult[] aggResults1 = [Select ApplicationBudgetCategory__c ABCId, MatchType__c Type, Grouping(MatchType__c) IsBCTotal, Sum(EquipmentCost__c) total from BuildUpItem__c Where ApplicationBudgetCategory__c IN :EquipmentABC Group by ROLLUP(ApplicationBudgetCategory__c, MatchType__c)];
            AggregateResult[] aggResults2 = [Select ApplicationBudgetCategory__c ABCId, MatchType__c Type, Grouping(MatchType__c) IsBCTotal, Sum(TotalFBCost__c ) total from BuildUpItem__c Where ApplicationBudgetCategory__c IN :BenefitABC Group by ROLLUP(ApplicationBudgetCategory__c, MatchType__c)];
            AggregateResult[] aggResults3 = [Select ApplicationBudgetCategory__c ABCId, MatchType__c Type, Grouping(MatchType__c) IsBCTotal, Sum(ContractedFees__c) total from BuildUpItem__c Where ApplicationBudgetCategory__c IN :ContractedABC Group by ROLLUP(ApplicationBudgetCategory__c, MatchType__c)];
            AggregateResult[] aggResults4 = [Select ApplicationBudgetCategory__c ABCId, MatchType__c Type, Grouping(MatchType__c) IsBCTotal, Sum(TotalCost__c) total from BuildUpItem__c Where ApplicationBudgetCategory__c IN :TrainingABC Group by ROLLUP(ApplicationBudgetCategory__c, MatchType__c)];
            AggregateResult[] aggResults5 = [Select ApplicationBudgetCategory__c ABCId, MatchType__c Type, Grouping(MatchType__c) IsBCTotal, Sum(TravelCost__c) total from BuildUpItem__c Where ApplicationBudgetCategory__c IN :TravelABC Group by ROLLUP(ApplicationBudgetCategory__c, MatchType__c)];
            AggregateResult[] aggResults6 = [Select ApplicationBudgetCategory__c ABCId, MatchType__c Type, Grouping(MatchType__c) IsBCTotal, Sum(SupplyCost__c) total from BuildUpItem__c Where ApplicationBudgetCategory__c IN :SuppliesABC Group by ROLLUP(ApplicationBudgetCategory__c, MatchType__c)];
            AggregateResult[] aggResults7 = [Select ApplicationBudgetCategory__c ABCId, MatchType__c Type, Grouping(MatchType__c) IsBCTotal, Sum(SupplyCost__c) total from BuildUpItem__c Where ApplicationBudgetCategory__c IN :OtherABC Group by ROLLUP(ApplicationBudgetCategory__c, MatchType__c)];  
            */
            /*
            AggregateResult[] aggResults = [
                SELECT ApplicationBudgetCategory__c ABCId, MatchType__c Type, Grouping(MatchType__c) IsBCTotal, Sum(TotalSalary__c) total 
                FROM BuildUpItem__c 
                WHERE ApplicationBudgetCategory__c IN :PersonnelABC AND (Type__c = 'Personnel' OR Type__c = 'Equipment' OR Type__c = 'Fringe Benefits' OR Type__c = 'Contracted Fees' OR Type__c = 'Training' OR Type__c = 'Travel' OR Type__c = 'Supplies' OR Type__c ='Other') 
                GROUP BY ROLLUP(ApplicationBudgetCategory__c, MatchType__c)];
            //AND Type__c == 'Personnel' OR Type__c == 'Equipment' OR Type__c == 'Fringe Benefits' OR Type__c == 'Contracted Fees' OR Type__c == 'Training' OR Type__c == 'Travel' OR Type__c == 'Supplies' OR Type__c =='Other'
            */
            reList.add(aggResults);
            
            reList.add(aggResults1);
            reList.add(aggResults2);
            reList.add(aggResults3);
            reList.add(aggResults4);
            reList.add(aggResults5);
            reList.add(aggResults6);
            reList.add(aggResults7);
            
            Map<Id, ApplicationBudgetCategory2__c> appBCMap = new Map<Id, ApplicationBudgetCategory2__c>([Select Id, Name,BudgetCategory__r.Name,Federal__c, InKind__c, CashMatch__c, Amount__c, Application__r.IndirectCostPercentage__c, TotalGrantCost__c from ApplicationBudgetCategory2__c where Id IN :AllABC AND CatName__c != 'Indirect Costs']);
            Set<ID> newAppBCList = new Set<ID>();
            List<ApplicationBudgetCategory2__c> re = new List<ApplicationBudgetCategory2__c>();
            System.debug('agg--------------------------------------->' + reList);

            for(AggregateResult[] aggre : reList){
                Set<String> bcType = new Set<String>();
                if (aggre != null) {
                    for (AggregateResult agg : aggre) {
                        System.debug('agg--------------------------------------->' + agg);
                        Id abcId = String.valueOf(agg.get('ABCId'));
                        ApplicationBudgetCategory2__c abc = appBCMap.get(abcId);
                        if (abc != null) {
                            if(agg.get('IsBCTotal') != 1){
                                if(agg.get('Type') == 'Federal'){
                                    abc.Federal__c = ((Decimal)(agg.get('total'))).setScale(2);
                                    if(!bcType.contains('Federal')){
                                        bcType.add('Federal');
                                    }
                                }else if(agg.get('Type') == 'In-Kind'){
                                    abc.InKind__c = ((Decimal)(agg.get('total'))).setScale(2);
                                    if(!bcType.contains('In-Kind')){
                                        bcType.add('In-Kind');
                                    }
                                }else if(agg.get('Type') == 'Cash'){
                                    abc.CashMatch__c = ((Decimal)(agg.get('total'))).setScale(2);
                                    if(!bcType.contains('Cash')){
                                        bcType.add('Cash');
                                    }
                                }
                                if(!bcType.contains('Federal')){
                                    abc.Federal__c = 0;
                                }
                                if(!bcType.contains('In-Kind')){
                                    abc.InKind__c = 0;
                                }
                                if(!bcType.contains('Cash')){
                                    abc.CashMatch__c = 0;
                                }
                                if(abc.BudgetCategory__r.Name == 'Equipment'){
                                    abc.TotalGrantCost__c = abc.Federal__c;
                                    abc.Amount__c = abc.Federal__c + abc.InKind__c + abc.CashMatch__c;
                                }
                                else{
                                    abc.TotalGrantCost__c = abc.Federal__c + abc.Federal__c * abc.Application__r.IndirectCostPercentage__c / 100;
                                    abc.Amount__c = abc.Federal__c + abc.InKind__c + abc.CashMatch__c;
                                }
                                if(!newAppBCList.contains(abcId)){
                                    newAppBCList.add(abcId);
                                    re.add(abc);
                                }
                            }
                            else{
                                bcType = new Set<String>();
                            }
                        }
                    }    
                }
                
            }
            if(Trigger.isAfter && Trigger.isDelete){
                for(Id abcId : appBCMap.keySet()){
                    if(!newAppBCList.contains(abcId)){
                        ApplicationBudgetCategory2__c abc = appBCMap.get(abcId);
                        abc.Federal__c = 0;
                        abc.InKind__c = 0;
                        abc.CashMatch__c = 0;
                        abc.TotalGrantCost__c = 0;
                        abc.Amount__c = 0;
                        re.add(abc);
                    }
                }
            }
            if (!newAppBCList.isEmpty() || re.size() != 0) {
                System.debug(re);
                update re;
            }

            //Map<Id, ApplicationBudgetCategory2__c> appBCMap = new Map<Id, ApplicationBudgetCategory2__c>([Select Id, Name, Amount__c, GrantorAmount__c from ApplicationBudgetCategory2__c where Id IN: appBCID]);
            //AggregateResult[] aggResults = [Select Sum(GrandTotal__c) grandTotal, Sum(GrantorAmount__c)  grantorAmount , Sum(GranteeAmount__c) granteeAmount , ApplicationBudgetCategory__c abcId from BuildUpItem__c Where ApplicationBudgetCategory__c IN :appBCID Group by ApplicationBudgetCategory__c];
            //List<ApplicationBudgetCategory2__c> newAppBCList = new list<ApplicationBudgetCategory2__c>();
        
            //for (AggregateResult agg : aggResults) {
            //    system.debug('***agg**' + agg);
            //    Id abcId = String.valueOf(agg.get('abcId'));
            //    ApplicationBudgetCategory2__c abc = appBCMap.get(abcId);
            //    if (abc != null) {
            //        abc.Amount__c = (Decimal)(agg.get('grandTotal'));
            //        abc.GrantorAmount__c = Double.valueOf(agg.get('grantorAmount')) ;
            //        abc.GranteeAmount__c = Double.valueOf(agg.get('granteeAmount')) ;
            //        newAppBCList.add(abc);
            //    }
            //}
            //if (!newAppBCList.isEmpty()) {
            //    update newAppBCList;
            //}    
        }      
    }



    private void updateApplicationIndirectCost(List<BuildUpItem__c> buildUpItems){
        System.debug('Enter Update Indirect Cost');
        Set<Id> abcIds = new Set<Id>();
        for(BuildUpItem__c item : buildUpItems){
            if(item.ApplicationBudgetCategory__c != null && !abcIds.contains(item.ApplicationBudgetCategory__c)){
                abcIds.add(item.ApplicationBudgetCategory__c);
            }
        }
        if(abcIds.size() >= 0){
            List<ApplicationBudgetCategory2__c> abcList = [Select Application__c from ApplicationBudgetCategory2__c where Id IN :abcIds];
            Set<Id> appIds = new Set<Id>();
            for(ApplicationBudgetCategory2__c abc : abcList){
                if(!appIds.contains(abc.Application__c)){
                    appIds.add(abc.Application__c);
                }
            }

            AggregateResult[] aggs = [Select Application__c appId, Sum(Federal__c)indSum from ApplicationBudgetCategory2__c where Application__c IN :appIds AND CatName__c NOT IN ('Indirect Costs', 'Equipment') Group By Application__c];
            Map<String, Decimal> appIndMap = new Map<String, Decimal>();  
            for(AggregateResult agg : aggs){
                appIndMap.put(String.valueOf(agg.get('appId')), (Decimal)agg.get('indSum'));
            }

            List<ApplicationBudgetCategory2__c> updateAbc = new List<ApplicationBudgetCategory2__c>();

            List<Application__c> appList = [Select Id, IndirectCostPercentage__c, (Select Id, Federal__c, InKind__c, CashMatch__c, Amount__c, Application__c from Application_Budget_Categories__r where CatName__c = 'Indirect Costs') from Application__c where Id IN :appIds];
            for(Application__c app : appList){
                for(ApplicationBudgetCategory2__c abc : app.Application_Budget_Categories__r){
                    abc.Federal__c = appIndMap.get(app.Id) * app.IndirectCostPercentage__c / 100;
                    abc.InKind__c = 0;
                    abc.CashMatch__c = 0;
                    abc.Amount__c = abc.Federal__c;
                    updateAbc.add(abc);
                }
            }
            update updateAbc;    
        }   
    }

    private void updateAmendmentIndirectCost(List<BuildUpItem__c> buildUpItems){
        System.debug('Enter Update Indirect Cost');
        Set<Id> abcIds = new Set<Id>();
        for(BuildUpItem__c item : buildUpItems){
            if(item.AmendmentRequestBudgetCategory__c != null && !abcIds.contains(item.AmendmentRequestBudgetCategory__c)){
                abcIds.add(item.AmendmentRequestBudgetCategory__c);
            }
        }
        if(abcIds.size() >= 0){
            List<AmendmentRequestBudgetCategory__c> abcList = [Select AmendmentRequest__c from AmendmentRequestBudgetCategory__c where Id IN :abcIds];
            Set<Id> amdIds = new Set<Id>();
            for(AmendmentRequestBudgetCategory__c abc : abcList){
                if(!amdIds.contains(abc.AmendmentRequest__c)){
                    amdIds.add(abc.AmendmentRequest__c);
                }
            }

            AggregateResult[] aggs = [Select AmendmentRequest__c amdId, Sum(Federal__c)indSum from AmendmentRequestBudgetCategory__c where AmendmentRequest__c IN :amdIds AND CatName__c NOT IN ('Indirect Costs', 'Equipment') Group By AmendmentRequest__c];
            Map<String, Decimal> appIndMap = new Map<String, Decimal>();  
            for(AggregateResult agg : aggs){
                appIndMap.put(String.valueOf(agg.get('amdId')), (Decimal)agg.get('indSum'));
            }

            List<AmendmentRequestBudgetCategory__c> updateAbc = new List<AmendmentRequestBudgetCategory__c>();

            List<AmendmentRequest__c> amdList = [Select Id, IndirectCostPercentage__c, (Select Id, Federal__c, InKindMatch__c, CashMatch__c, Amount__c, AmendmentRequest__c from AmendmentRequestBudget_Categories__r where CatName__c = 'Indirect Costs') from AmendmentRequest__c where Id IN :amdIds];
            for(AmendmentRequest__c amd : amdList){
                for(AmendmentRequestBudgetCategory__c abc : amd.AmendmentRequestBudget_Categories__r){
                    abc.Federal__c = appIndMap.get(amd.Id) * amd.IndirectCostPercentage__c / 100;
                    abc.InKindMatch__c = 0;
                    abc.CashMatch__c = 0;
                    abc.Amount__c = abc.Federal__c;
                    updateAbc.add(abc);
                }
            }
            update updateAbc;    
        }   
    }
}