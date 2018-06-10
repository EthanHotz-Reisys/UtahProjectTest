trigger PaymentRequestTrigger on PaymentRequest__c (before insert, after insert, after update, before update) {
    List<PaymentRequest__c> USBEpayments = new List<PaymentRequest__c>();
    List<PaymentRequest__c> UOVCpayments = new List<PaymentRequest__c>();
    List<PaymentRequest__c> USBEMSPpayments = new List<PaymentRequest__c>();
    if (Trigger.isInsert) {
        for (PaymentRequest__c payment : Trigger.new) {
             if (payment.USBEPathway__c == 'MSP' || payment.USBEPathWay__c == '1-12th' || payment.USBEPathway__c == 'Lump-Sum-App' || payment.USBEPathWay__c == 'Lump-Sum-No-App') {
                USBEMSPpayments.add(payment);
            } else if (payment.ExternalOrgName__c == 'USBE') {
                USBEpayments.add(payment);
            } else if (payment.ExternalOrgName__c == 'UOVC') {
                UOVCpayments.add(payment);
            }
        }
    } else {
        for (PaymentRequest__c payment : Trigger.old) {
            if (payment.USBEPathway__c == 'MSP' || payment.USBEPathWay__c == '1-12th' || payment.USBEPathway__c == 'Lump-Sum-App' || payment.USBEPathWay__c == 'Lump-Sum-No-App') {
                USBEMSPpayments.add(payment);
            } else if (payment.ExternalOrgName__c == 'USBE') {
                USBEpayments.add(payment);
            } else if (payment.ExternalOrgName__c == 'UOVC') {
                UOVCpayments.add(payment);
            }
        }
    }

    if (USBEMSPpayments.size() > 0) {
        new MSPPaymentRequestTriggerHelper().process();
    } else if (USBEpayments.size() > 0) {
        new USBEPaymentRequestTriggerHelper().process();
    } else if (UOVCpayments.size() > 0) {
        new UOVCPaymentRequestTriggerHelper().process();
    } else {
        new PaymentRequestTriggerHelper().process();
    }
}