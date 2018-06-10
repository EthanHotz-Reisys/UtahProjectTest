global with sharing class ConvertToQualifiedLeadHelper extends GNT.DynamicLayoutActionRedirect {
    
    global override PageReference whenClicked(){      
        String ns = AppUtils.getNamespacePrefix();
        List<String> errors = new List<String>(); 
        Id recordId = apexpages.currentpage().getparameters().get('id');
        FOALead__c objFoaLead = [SELECT Id,DaysLeft__c,Status__c FROM FOALead__c WHERE id =: recordId];
        if(objFoaLead.DaysLeft__c == 0){
            errors.add('Lead cannot be Qualified if Application deadline is less than Today');
            errors.add(GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-59900'));
        }
        if(errors.size() > 0){
            for(String error: errors){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, error));
             }
        } else{
        	objFoaLead.Status__c = 'Qualified Lead';
        	update objFoaLead;
        //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Converted to Qualified Lead'));
        	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, GNT.ErrorMessageHelper.fetchMessage('P02-GRNTR-13701')));  
       	 	PageReference  returnPage = new PageReference('/apex/FOALeadView?id='+recordId); 
        	returnPage.setRedirect(true);
        	return returnPage;
        }
        return null;    
    }
}