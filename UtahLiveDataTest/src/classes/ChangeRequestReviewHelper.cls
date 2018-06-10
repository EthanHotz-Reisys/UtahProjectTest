global with sharing class ChangeRequestReviewHelper extends GNT.FlexTableActionHandler {
    
    global override Map<String,Object> clickHandler(){
        Map<String,Object> resultMap = new Map<String,Object>();               
        String ns = AppUtils.getNamespacePrefix(); 
        Id recordId = urlParams.get('id');
        system.debug('selectedRecordIds ---'+selectedRecordIds );
        List<ChangeRequest__c> cr = [Select Application__c From ChangeRequest__c Where Id = : selectedRecordIds[0] LIMIT 1];
               
        String PageReferenceURL = '/apex/'+ns+'ChangeRequestApplicantAgreement?id=' + cr[0].Application__c;
        resultMap.put('PageReference',PageReferenceURL);
        return resultMap;
    }
    
}