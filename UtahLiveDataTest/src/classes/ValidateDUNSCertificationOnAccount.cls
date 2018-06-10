/*  **********************************************************
    Audit History
    **********************************************************
    08/06/2015   Shrawan Raina    Modified  Skipping validation for Person Account
*/

global class ValidateDUNSCertificationOnAccount extends GNT.BusinessRuleHandlerWithLayoutHolder{
    
    global override GNT.BusinessRuleResult execute(SObject record) {
        GNT.BusinessRuleResult result = new GNT.BusinessRuleResult();
        return result ;
    }
    
    global override GNT.BusinessRuleResult execute(SObject record, GNT.DynamicLayoutHolder holder) {
        System.debug('record------>>>'+record);
        GNT.BusinessRuleResult result = new GNT.BusinessRuleResult();
        if(record.Id != null){ //account is inserted so bussiness rule will be fired on update.     
            // Added to bypass validation for Person Account
            Account acc = [SELECT Id, recordTypeId FROM Account WHERE Id =: record.Id];
            String recordType = Schema.SObjectType.Account.getRecordTypeInfosById().get(acc.recordTypeId).getName().toLowerCase();
            if(recordType.equals('person account'))
                return result;
            List<GNT__AttachmentExtension__c> attachExtList = new List<GNT__AttachmentExtension__c>();
            List<Attachment> attachList = new List<Attachment>();
            attachList = [SELECT Id,Name FROM Attachment WHERE ParentId = :record.Id];
            List<Id> attachmentIds = new List<Id>();
            if(attachList.size () > 0){
                for(Attachment att :attachList){
                    attachmentIds.add(att.Id);
                }
                /*attachExtList = [SELECT Id,Name,GNT__Classification__c,
                        GNT__AttachmentName__c FROM GNT__AttachmentExtension__c 
                        WHERE GNT__AttachmentId__c IN :attachmentIds AND 
                        GNT__Classification__c LIKE '%DUNS Certification%']; */
                if(attachExtList.size () > 0){
                    
                }
                else{
                    result.errors.add(Label.DUNSCertificationErrorMessage);
                }
            }
            else{
                result.errors.add(Label.DUNSCertificationErrorMessage);
            }               
        }
        return result;
    }

}