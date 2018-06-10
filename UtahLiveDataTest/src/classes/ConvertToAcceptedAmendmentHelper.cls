global with sharing class ConvertToAcceptedAmendmentHelper extends GNT.DynamicLayoutActionRedirect {
    global override PageReference whenClicked(){      
        String ns = AppUtils.getNamespacePrefix(); 
        Id recordId = apexpages.currentpage().getparameters().get('id');
        AmendmentRequest__c objamd = [SELECT Id,Status__c,Award__c FROM AmendmentRequest__c WHERE id =: recordId];
        objamd.Status__c = 'Accepted';
        update objamd;
        // ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Accepted by Grantor'));
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, GNT.ErrorMessageHelper.fetchMessage('P02-GRNTR-46124')));
        
         PageReference  returnPage = new PageReference('/apex/AwardView?id='+objamd.Award__c) ;
         returnPage.setRedirect(true);
         return returnPage;
         
            
    }

}