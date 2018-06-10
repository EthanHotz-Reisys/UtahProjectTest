global with sharing class WaiveRemainingFunds extends GNT.DynamicLayoutActionRedirect {
    global override PageReference whenClicked(){      
        String ns = AppUtils.getNamespacePrefix(); 
        List<String> errors = new List<String>();  
        Id recordId = apexpages.currentpage().getparameters().get('id');
        Award__c award = [SELECT Id FROM Award__c WHERE id =: recordId];
        GNT.TaskCreationHandler.createApprovalProcessTasks(award.Id, 'Approve Waive Remaining Funds', award.Name, null, System.TODAY() + 7, award.GrantAwardName__c, true);
        PageReference returnPage = Page.AwardView;
        returnPage.getParameters().put('Id', award.Id);
        returnPage.setRedirect(true);
        return returnPage;
    }
}