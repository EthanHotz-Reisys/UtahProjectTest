global with sharing class NewSiteVisitReportConditionHandler extends GNT.FlexTableActionHandler {
    public NewSiteVisitReportConditionHandler() {
        
    }

    global override Map<String,Object> clickHandler(){
        Map<String,Object> resultMap = new Map<String,Object>();
        String ns = AppUtils.getNamespacePrefix(); 
        Id awardId = urlParams.get('id');
        Award__c award = [select id,Grant__c,BudgetPeriodStartDate__c,BudgetPeriodEndDate__c,Status__c from Award__c where id =: awardId limit 1];
        Integer tc = [SELECT COUNT() FROM TermCondition__c WHERE RecordType.Name = 'Site Visit' AND Award__c =: awardId];
        system.debug('TC: '+tc);
        
        if(award.BudgetPeriodStartDate__c == null || award.BudgetPeriodEndDate__c == null) {
            resultMap.put('Message','Please enter Budget Period Dates before setting the report cycle');
            return resultMap;
        }
        /*if(award != null && (award.Status__c != 'Drafted')) {
             resultMap.put('Message','The cycle cannot be modified because the Award is in:'+award.Status__c);
             return resultMap;
        }*/

        else if(tc > 0) {
            //resultMap.put('Message','A Payment Request Condition has already been created !');
            TermCondition__c termCondition = [SELECT id FROM TermCondition__c WHERE RecordType.Name = 'Site Visit' AND Award__c =: awardId limit 1];                                      
            Id termConditionId = termCondition.Id;                                   
            String PageReferenceURL = '/apex/'+ns+'TermConditionEdit?customHeader=Create Site Visit Condition&recordType=SiteVisit&isProgram=false&awardId='+awardId+'&id='+termConditionId+'&grantId='+award.Grant__c;
            resultMap.put('PageReference',PageReferenceURL); 
        }
        else {
            String PageReferenceURL = '/apex/'+ns+'TermConditionEdit?customHeader=Create Site Visit Condition&recordType=SiteVisit&isProgram=false&awardId='+awardId+'&grantId='+award.Grant__c;
            resultMap.put('PageReference',PageReferenceURL); 
        }
                                                
        return resultMap;
    }    
}