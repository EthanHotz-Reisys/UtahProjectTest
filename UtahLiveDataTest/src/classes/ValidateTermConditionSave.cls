global class ValidateTermConditionSave extends GNT.BusinessRuleHandlerWithLayoutHolder {
    global override GNT.BusinessRuleResult execute(SObject record) {
        GNT.BusinessRuleResult result = new GNT.BusinessRuleResult();
        return result ;
    }
  
    global override GNT.BusinessRuleResult execute(SObject record, GNT.DynamicLayoutHolder holder) {
        GNT.BusinessRuleResult result = new GNT.BusinessRuleResult();
        Boolean allowSave = datesValidation(record);
        if(!allowSave){
            //result.errors.add('Clear the fixed dates since you have selected the Budget Period Start and End dates');
            result.errors.add(GNT.ErrorMessageHelper.fetchMessage('P26-GRNTR-65629'));
        }
        
        return result;
    }
    
    private boolean datesValidation(SObject record){
        if(record.get('ReportStartDate__c') == 'Budget Period Start Date' && record.get('ReportEndDate__c') == 'Budget Period End Date' ){
            if(record.get('FixedStartDate__c') != null  ||record.get('FixedEndDate__c') != null){
                return false;
            }
        }
        return true;
    }

   
}