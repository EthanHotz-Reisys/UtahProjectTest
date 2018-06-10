trigger AwardTrigger on Award__c (before insert, after insert, after update, before update, after delete, before delete) {
    List<Award__c> UOVCAwards = new List<Award__c>();
    List<Award__c> USBEAwards = new List<Award__c>();
    List<Award__c> USBEMSPAwards = new List<Award__c>();
    if (Trigger.isInsert) {
        for (Award__c award : Trigger.new) {
            if (award.GrantorOrganization__c == 'USBE' || award.GrantorOrganization__c == 'SYSTEM') {
                if (award.USBEPathway__c == 'MSP' || award.USBEPathway__c == 'LSNA') {
                    USBEMSPAwards.add(award);
                } else {
                    USBEAwards.add(award);
                }
            } else {
                UOVCAwards.add(award);
            }
        }
    } else {
        for (Award__c award : Trigger.old) {
            if (award.GrantorOrganization__c == 'USBE' || award.GrantorOrganization__c == 'SYSTEM') {
                if (award.USBEPathway__c == 'MSP' || award.USBEPathway__c == 'LSNA') {
                    USBEMSPAwards.add(award);
                } else {
                    USBEAwards.add(award);
                }
            } else {
                UOVCAwards.add(award);
            }
        }
    }
    System.debug('AWARDS HERE =====================>'+Trigger.new );
    if (UOVCAwards.size() > 0) {
        new AwardTriggerHelper().process();
    } else if (USBEAwards.size() > 0) {
        //new AwardTriggerHelper().process();
        new USBEAwardTriggerHelper().process();
    } else if (USBEMSPAwards.size() > 0) {
        new MSPAwardTriggerHelper().process();
    }
}