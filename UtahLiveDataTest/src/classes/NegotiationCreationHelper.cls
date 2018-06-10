/*
     
    **********************************************************
    1/7/2016  Davinder Singh       Created
    **********************************************************  
*/

//Handles Negotiation creation from an application
global with sharing class NegotiationCreationHelper extends GNT.FlexTableActionHandler {

    global NegotiationCreationHelper() {}
    Map < String, Object > resultMap = new Map < String, Object > ();

    Id revStepId;
    Decimal recAmount, futureAmount;
    public override Map < String, Object > clickHandler() {

        revStepId = urlParams.get('id');

        Savepoint sp = Database.setSavePoint();
        try {
            if (selectedRecordIds == null || selectedRecordIds.size() == 0) {
                //resultMap.put('Message','No Application has been selected.');
                resultMap.put('Message', GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-20593'));
                return resultMap;
            }

            System.debug(LoggingLevel.ERROR, '**NegotiationCreationHelper--');

            ReviewStep__c revStep = [Select Id, Name,ReviewGroup__r.Announcement__r.OrganizationName__c, ReviewApprovalStatus__c, GrantCode__c from ReviewStep__c where Id =: revStepId];
            if (revStep.ReviewApprovalStatus__c != 'Approved' && revstep.ReviewGroup__r.Announcement__r.OrganizationName__c!='USBE') {
                //resultMap.put('Message','FDM must be approved');
                resultMap.put('Message', GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-06518'));
                return resultMap;
            }

            if (revStep.GrantCode__c == null || String.isEmpty(revStep.GrantCode__c)) {
                //resultMap.put('Message','Grant abbreviation field mandatory for creation of first award.');
                resultMap.put('Message', 'Grant abbreviation field mandatory for creation of negotiation.');
                return resultMap;
            }

            Set < Id > appIds = new Set < Id > ();
            String ns = AppUtils.getNamespacePrefix();
            List < ReviewStepApplication__c > revAppList = [Select Id, Name, Application__c, RecommendedAmount__c, RecommendedFutureAmount__c, AllocationPercentage__c from ReviewStepApplication__c where Id IN: selectedRecordIds];
            
            if(revAppList[0].AllocationPercentage__c == null){
                resultMap.put('Message', 'Calculation is required for negotiation creation');
                return resultMap;                
            }

            ReviewStepApplication__c rsa1 = revAppList[0];
            recAmount = rsa1.RecommendedAmount__c;
            futureAmount = rsa1.RecommendedFutureAmount__c;
            for (ReviewStepApplication__c rsa: revAppList) {
                appIds.add(rsa.Application__c);
            }
            List < Application__c > appList = [SELECT Id, Name, AwardDecisionStatus__c, AmountThisAction__c, ObligatedAmount__c FROM Application__c WHERE Id IN: appIds AND status__c NOT IN('Revision Initiated')];
            Application__c app = appList[0];
            if (app.AwardDecisionStatus__c == 'Award Created') {
                //resultMap.put('Message','Award is already created for selected application.');
                resultMap.put('Message', GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-22608'));
                return resultMap;
            } else if (app.AwardDecisionStatus__c == 'Revision Initiated' || app.AwardDecisionStatus__c == 'Revision Completed') {
                //resultMap.put('Message','Selected Application is under Negotiation process');
                resultMap.put('Message', GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-53644'));
                return resultMap;
            }

            if (appList != null && appList.size() > 0) {
                UpdateApplication(appList);
            } else {
                //resultMap.put('Message','Negotiation can not be initiated for selected applications.');
                resultMap.put('Message', GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-50828'));
                return resultMap;
            }
        } catch (Exception e) {
            //resultMap.put('Message','Error in initiating negotiation');
            resultMap.put('Message', GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-98286'));
            System.debug('**Error in initiating negotiation--' + e);
            Database.rollBack(sp);
            return resultMap;
        }
        //resultMap.put('Message','Negotiation has been initiated for selected applications.');
        resultMap.put('Message', GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-50829'));
        return resultMap;
    }

    private void UpdateApplication(List < Application__c > appList) {
        List < Application__c > newAppList = new List < Application__c > ();
        for (Application__c app: appList) {
            if (futureAmount == null)
                futureAmount = 0;
            app.status__c = 'Revision Initiated';
            app.awarddecisionstatus__c = 'Revision Initiated';
            app.AmountThisAction__c = recAmount;
            app.ObligatedAmount__c = recAmount + futureAmount;
            newAppList.add(app);
        }
        update newAppList;
        Id annId;
        ReviewGroup__c revGrp = [Select Id, Status__c, Announcement__c from ReviewGroup__c where Id IN(Select ReviewGroup__c from ReviewStep__c where id =: revStepId)];
        annId = revGrp.Announcement__c;
        //revGrp.status__c='Completed';
        //update revGrp;

        //update announcement's application review status

        Announcement__c ann = [Select Id, Name, ApplicationsReviewStatus__c, ApplicationswithNegotiationInProcess__c from Announcement__c where id =: annId];
        if (ann.ApplicationswithNegotiationInProcess__c == null) {
            ann.ApplicationswithNegotiationInProcess__c = 1;
        } else {
            ann.ApplicationswithNegotiationInProcess__c = ann.ApplicationswithNegotiationInProcess__c + 1;
        }
        update ann;

    }
}