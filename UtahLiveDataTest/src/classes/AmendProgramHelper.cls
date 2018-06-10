global with sharing class AmendProgramHelper extends GNT.DynamicLayoutActionRedirect{
    global override PageReference whenClicked(){      
        String ns = AppUtils.getNamespacePrefix();
        List<String> errors = new List<String>(); 
        Id recordId = apexpages.currentpage().getparameters().get('id');
        Program__c objprogram = [SELECT Id,Status__c FROM Program__c WHERE id =: recordId];
        
       
        	objprogram.Status__c = 'Being Amended';
        	update objprogram;
            PageReference  returnPage = new PageReference('/apex/ProgramView?id='+recordId); 
        	returnPage.setRedirect(true);
        	return returnPage;
        
           
    }
}