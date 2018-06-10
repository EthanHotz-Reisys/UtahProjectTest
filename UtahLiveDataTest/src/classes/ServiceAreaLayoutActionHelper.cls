global with sharing class ServiceAreaLayoutActionHelper extends GNT.DynamicLayoutActionRedirect {
    global override PageReference whenClicked(){ 
        Id recordId = apexpages.currentpage().getparameters().get('id');
        
        List<String> errors = new List<String>();     

        Integer cnt = [SELECT COUNT() from RolesAndResponsibilities__c WHERE ServiceArea__c = :recordId];
        if(cnt == 0){
            //errors.add('Atleast one reviewer role record is required.');
            errors.add(GNT.ErrorMessageHelper.fetchMessage('P17-GRNTE-60593'));
        }

        //Integer cnt1 = [SELECT COUNT() from KeyOutcome__c WHERE ServiceArea__c = :recordId];
        //if(cnt1 == 0){
        //    //errors.add('Atleast one Expected Outcome is required.');
        //    errors.add(GNT.ErrorMessageHelper.fetchMessage('P17-GRNTE-81321'));
        //}
        
        //TODO - check for attachment.
        
        
        if(errors.size() > 0){
            for(String error: errors){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, error));
            }
        }else{
            //update status to active
            ServiceArea__c obj = new ServiceArea__c(Id = recordId, Status__c = 'Active');
            update obj;
            
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Activated Project/Service Area successfully.'));
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-24133')));
            PageReference  pageref = Page.serviceareaview;
            pageref.getParameters().put('Id',recordId);
            pageref.setRedirect(true);
            return pageref;   
        }
        
        return null;
    }

}