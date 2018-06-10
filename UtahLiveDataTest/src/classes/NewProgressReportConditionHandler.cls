global with sharing class NewProgressReportConditionHandler extends GNT.FlexTableActionHandler {
    public NewProgressReportConditionHandler() {
        
    }

    global override Map<String,Object> clickHandler(){
        Map<String,Object> resultMap = new Map<String,Object>();
        String ns = AppUtils.getNamespacePrefix(); 
        Id awardId = urlParams.get('id');
        Award__c award = [select id,Grant__c,BudgetPeriodStartDate__c,BudgetPeriodEndDate__c,Status__c from Award__c where id =: awardId limit 1];
        system.debug('award: '+award+' awardId: '+awardId);
        Integer tc = [SELECT COUNT() FROM TermCondition__c WHERE RecordType.Name = 'Progress Report' AND Award__c =: awardId];
        system.debug('TC: '+tc);
        //if(award != null && (award.Status__c != 'In Progress' && award.Status__c != 'Drafted')) {
             //resultMap.put('Message','The Cycle cannot be set/edit because the Award is:'+award.Status__c);
        //}
        if(award.BudgetPeriodStartDate__c == null || award.BudgetPeriodEndDate__c == null) {
            resultMap.put('Message',GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-11385'));
            return resultMap;
        }
        /*if(award != null && award.Status__c != 'Drafted') {
             resultMap.put('Message','The cycle cannot be modified because the Award is in:'+award.Status__c);
             return resultMap;
        }*/
        if(tc > 0) {
            //resultMap.put('Message','A Progress Report Condition has already been created !');
            TermCondition__c termCondition = [SELECT id FROM TermCondition__c WHERE RecordType.Name = 'Progress Report' AND Award__c =: awardId limit 1];                                      
            Id termConditionId = termCondition.Id;
            //Id termConditionId = tcSchedule.TermAndCondition__c;                                      
            String PageReferenceURL = '/apex/'+ns+'TermConditionEdit?customHeader=Create Progress Report Condition&recordType=ProgressReport&isProgram=false&awardId='+awardId+'&id='+termConditionId+'&grantId='+award.Grant__c;
            resultMap.put('PageReference',PageReferenceURL); 
        }
        else {
            String PageReferenceURL = '/apex/'+ns+'TermConditionEdit?customHeader=Create Progress Report Condition&recordType=ProgressReport&isProgram=false&awardId='+awardId+'&grantId='+award.Grant__c;
            resultMap.put('PageReference',PageReferenceURL); 
        }
                                                
        return resultMap;
    }    
}