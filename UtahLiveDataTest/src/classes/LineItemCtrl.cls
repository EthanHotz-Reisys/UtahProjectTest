public with sharing class LineItemCtrl {

    public ID recordId {get;set;}
    public String gridName {get;set;}
    public String category {get;set;}
    public String categorytype {get;set;}
    public Decimal grantorshareamount {get;set;}
    public Decimal requestedamount {get;set;}
    public String type{get; set;}
    public String viewCriteria {get;set;}
     
    public LineItemCtrl() {
        recordId = ApexPages.CurrentPage().getParameters().get('id'); 
        system.debug('--recordId--'+recordId);
        
        type =  ApexPages.CurrentPage().getParameters().get('type');
        system.debug('Type is '+type);
        if(type=='Award'){
            //gridName='LineItem';
            List<AwardBudgetCategory__c> awardbuilduplist = [select id,BudgetCategory__c,BudgetCategory__r.Type__c,BudgetCategory__r.Name
                                                                    from AwardBudgetCategory__c where id=:recordId];        
            if(awardbuilduplist[0].BudgetCategory__r.Type__c == 'Personnel'){
                gridName='PersonnelBuildUpAwardGrid';
            }else if(awardbuilduplist[0].BudgetCategory__r.Type__c == 'Fringe Benefits'){
                gridName='FringeBenefitsBuildUpAwardGrid';
            }else if(awardbuilduplist[0].BudgetCategory__r.Type__c == 'Contracted Fees'){
                gridName = 'ContractedFeesBuildUpAwardGrid';
            }else if(awardbuilduplist[0].BudgetCategory__r.Type__c == 'Equipment'){
                gridName = 'EquipmentBuildUpAwardGrid';
            }else if(awardbuilduplist[0].BudgetCategory__r.Type__c == 'Travel'){
                gridName = 'TravelBuildUpAwardGrid';
            }else if(awardbuilduplist[0].BudgetCategory__r.Type__c == 'Training'){
                gridName = 'TrainingBuildUpAwardGrid';
            }else if(awardbuilduplist[0].BudgetCategory__r.Type__c == 'Supplies'){
                gridName = 'SuppliesBuildUpAwardGrid';
            }else if(awardbuilduplist[0].BudgetCategory__r.Type__c == 'Other'){
                gridName = 'OtherBuildUpAwardGrid';
            }else{
                gridName='AppLineItem';
            }
            if(!awardbuilduplist.isempty()){
            category = awardbuilduplist[0].BudgetCategory__r.Name;
            categorytype = awardbuilduplist[0].BudgetCategory__r.Type__c;
            }
        }
        else if(type=='Application'){
            //gridName='AppLineItem';
            List<ApplicationBudgetCategory2__c> appbuilduplist = [select id,CategoryName__c,BudgetCategory__c,CatName__c,BudgetCategory__r.Type__c 
                                                                    from ApplicationBudgetCategory2__c where id=:recordId];
            if(appbuilduplist[0].BudgetCategory__r.Type__c == 'Personnel'){
                gridName='PersonnelBuildUpGrid';
            }else if(appbuilduplist[0].BudgetCategory__r.Type__c == 'Fringe Benefits'){
                gridName='FringeBenefitsBuildUpGrid';
            }else if(appbuilduplist[0].BudgetCategory__r.Type__c == 'Contracted Fees'){
                gridName = 'ContractedFeesBuildUpGrid';
            }else if(appbuilduplist[0].BudgetCategory__r.Type__c == 'Equipment'){
                gridName = 'EquipmentBuildUpGrid';
            }else if(appbuilduplist[0].BudgetCategory__r.Type__c == 'Travel'){
                gridName = 'TravelBuildUpGrid';
            }else if(appbuilduplist[0].BudgetCategory__r.Type__c == 'Training'){
                gridName = 'TrainingBuildUpGrid';
            }else if(appbuilduplist[0].BudgetCategory__r.Type__c == 'Supplies'){
                gridName = 'SuppliesBuildUpGrid';
            }else if(appbuilduplist[0].BudgetCategory__r.Type__c == 'Other'){
                gridName = 'OtherBuildUpGrid';
            }else{
                gridName='AppLineItem';
            }
            if(!appbuilduplist.isempty()){
            category = appbuilduplist[0].CatName__c;
            categorytype = appbuilduplist[0].BudgetCategory__r.Type__c;
            }
        }
        else if(type=='PreApplication'){
            gridName='PreAppLineItem';
            List<PreApplicationBudgetCategory__c> preappbuilduplist = [select id,BudgetCategory__c,CatName__c,BudgetCategory__r.Type__c 
                                                                    from PreApplicationBudgetCategory__c where id=:recordId];
            if(!preappbuilduplist.isempty()){
            category = preappbuilduplist[0].CatName__c;
            categorytype = preappbuilduplist[0].BudgetCategory__r.Type__c;
            }
        }
        else if(type=='Payment'){
            gridName='PaymentLineItems';
            List<PaymentBudgetCategory__c> paymentbuilduplist = [select id,BudgetCategory__c,BudgetCategoryName__c,BudgetCategory__r.Type__c,
                                                                AwardedBudget__c,RequestedExpense__c
                                                                from PaymentBudgetCategory__c where id=:recordId];
            if(!paymentbuilduplist.isempty()){
            category = paymentbuilduplist[0].BudgetCategoryName__c;
            categorytype = paymentbuilduplist[0].BudgetCategory__r.Type__c ;
            grantorshareamount = paymentbuilduplist[0].AwardedBudget__c;
            requestedamount = paymentbuilduplist[0].RequestedExpense__c;
            }
        }
        else if(type=='Amendment'){
            //gridName='AmendmentLineItem';
            List<AmendmentRequestBudgetCategory__c> amendmentBuildUpList = [select id,BudgetCategory__c,BudgetCategory__r.Type__c,
                                                                            BudgetCategory__r.Name
                                                                            from AmendmentRequestBudgetCategory__c where id=:recordId];
            if(amendmentBuildUpList[0].BudgetCategory__r.Type__c == 'Personnel'){
                gridName='PersonnelBuildUpAmendmentGrid';
            }else if(amendmentBuildUpList[0].BudgetCategory__r.Type__c == 'Fringe Benefits'){
                gridName='FringeBenefitsBuildUpAmendmentGrid';
            }else if(amendmentBuildUpList[0].BudgetCategory__r.Type__c == 'Contracted Fees'){
                gridName = 'ContractedFeesBuildUpAmendmentGrid';
            }else if(amendmentBuildUpList[0].BudgetCategory__r.Type__c == 'Equipment'){
                gridName = 'EquipmentBuildUpAmendmentGrid';
            }else if(amendmentBuildUpList[0].BudgetCategory__r.Type__c == 'Travel'){
                gridName = 'TravelBuildUpAmendmentGrid';
            }else if(amendmentBuildUpList[0].BudgetCategory__r.Type__c == 'Training'){
                gridName = 'TrainingBuildUpAmendmentGrid';
            }else if(amendmentBuildUpList[0].BudgetCategory__r.Type__c == 'Supplies'){
                gridName = 'SuppliesBuildUpAmendmentGrid';
            }else if(amendmentBuildUpList[0].BudgetCategory__r.Type__c == 'Other'){
                gridName = 'OtherBuildUpAmendmentGrid';
            }else{
                gridName='AmendmentLineItem';
            }
            if(!amendmentBuildUpList.isempty()){
            category = amendmentBuildUpList[0].BudgetCategory__r.Name;
            categorytype = amendmentBuildUpList[0].BudgetCategory__r.Type__c;
            }
        }        
        else if (type=='ApplicationUSBE') {
            List<ApplicationBudgetCategory2__c> appbuilduplist = [select id,BudgetCategory__c,CatName__c,BudgetCategory__r.RowNumber__c, Application__c, Application__r.ProgramBudgetTypeUSBE__c from ApplicationBudgetCategory2__c where id=:recordId];
            //if(appbuilduplist[0].BudgetCategory__r.RowNumber__c == '570' && appbuilduplist[0].Application__r.ProgramBudgetTypeUSBE__c == 'CTE') {
            //    gridName='PropertyIncludingEquipmentBuildUpGridCTE';
            //}
            if (appbuilduplist[0].BudgetCategory__r.RowNumber__c == '570') {
                gridName='PropertyIncludingEquipmentBuildUpGrid';
            }
            else { //Expand on this if we want to change additional edit buttons to buildup buttons
                gridName='PropertyIncludingEquipmentBuildUpGrid';
            }
        }
        else if (type == 'AwardUSBE') {
            List<AwardBudgetCategory__c> awardbuilduplist = [SELECT Id,BudgetCategory__c,BudgetCategory__r.Type__c,BudgetCategory__r.Name, BudgetCategory__r.RowNumber__c from AwardBudgetCategory__c where id=:recordId];        
            if(!awardbuilduplist.isempty()){
                category = awardbuilduplist[0].BudgetCategory__r.Name;
                categorytype = awardbuilduplist[0].BudgetCategory__r.Type__c;
            }
            gridName='PropertyIncludingEquipmentBuildUpAwardGrid';
        }
        else if (type == 'AmendmentUSBE') {
            List<AmendmentRequestBudgetCategory__c> budgetRevisionList = [SELECT Id,BudgetCategory__c,BudgetCategory__r.Type__c,BudgetCategory__r.Name, BudgetCategory__r.RowNumber__c FROM AmendmentRequestBudgetCategory__c WHERE Id =: recordId];
            gridName='PropertyIncludingEquipmentBuildUpAmendmentGrid';
            //viewCriteria = 'Active';
            viewCriteria = 'Created';
        }
        else if (type == 'AmendmentApprovalUSBE') {
            List<AmendmentRequestBudgetCategory__c> budgetRevisionList = [SELECT Id,BudgetCategory__c,BudgetCategory__r.Type__c,BudgetCategory__r.Name, BudgetCategory__r.RowNumber__c FROM AmendmentRequestBudgetCategory__c WHERE Id =: recordId];
            gridName='PropertyIncludingEquipmentBuildUpAmendmentGrid';
            viewCriteria = 'Created';
        }
    }
    
    public string getKeyValueMap(){
        Map<String,String> keyValueMap = new Map<String,String>();
        keyValueMap.put('parentId', recordId);
        keyValueMap.put('parentRecordIdOfFlexTable', recordId);
        keyValueMap.put('AwardBudgetCategory__c', recordId);
        keyValueMap.put('ApplicationBudgetCategory__c', recordId);
        keyValueMap.put('PaymentBudgetCategory__c', recordId);
        keyValueMap.put('AmendmentRequestBudgetCategory__c', recordId);
        keyValueMap.put('viewCriteria', viewCriteria);
        return JSON.serialize(keyValueMap);
    }
}