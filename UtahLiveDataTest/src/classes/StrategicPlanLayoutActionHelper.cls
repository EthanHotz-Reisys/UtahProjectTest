global with sharing class StrategicPlanLayoutActionHelper extends GNT.DynamicLayoutActionRedirect {

    global override PageReference whenClicked(){ 
        Id recordId = apexpages.currentpage().getparameters().get('id');
        
        List<String> errors = new List<String>();     

        Integer cnt = [SELECT COUNT() from RolesAndResponsibilities__c WHERE StrategicPlan__c = :recordId];
        if(cnt == 0){
            //errors.add('Atleast one role & responsibility record is required.');
            errors.add(GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-09110'));
        }

        //TODO - check for attachment.
        
        
        if(errors.size() > 0){
            for(String error: errors){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, error));
            }
        }else{
            //update status to active
            StrategicPlan__c obj = new StrategicPlan__c(Id = recordId, Status__c = 'Active');
            update obj;
            
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Activated strategic plan successfully.'));
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-49935')));
            PageReference  pageref = Page.StrategicPlanView;
            pageref.getParameters().put('Id',recordId);
            pageref.setRedirect(true);
            return pageref;   
        }
        
        return null;
    }
}