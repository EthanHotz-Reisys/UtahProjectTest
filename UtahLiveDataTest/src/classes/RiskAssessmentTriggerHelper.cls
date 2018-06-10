global with sharing class RiskAssessmentTriggerHelper extends GNT.TriggerHelper {
    global override void processAfterInsert() {
      //  updateGrantToPointToLatestRiskOnInsert();
      updateBudgetPeriod(Trigger.new);
    }
    
    global override void processBeforeInsert() {
       // lockRiskAssessmentForCloseout(Trigger.new);   
  //       GNT.NameTemplateTriggerHelper.beforeInsert(); 
    }

    global override void processBeforeDelete(){
     //   updateGrantToPointToLatestRiskOnDelete();       
    }

    global override void processBeforeUpdate() {

          if(trigger.isBefore && trigger.isUpdate){        
        calculateRating(); 
    }
        //lockRiskAssessmentForCloseout(Trigger.new);
    }


 private void updateBudgetPeriod(List<RiskAssessment__c> raList){
        Set<Id> grantSet = new Set<Id>();
        Set<Id> raSet = new Set<Id>();
        List<RiskAssessment__c> lstRA = new List<RiskAssessment__c>();

        system.debug('Inside updateBudgetPeriod');

        for(RiskAssessment__c ra : raList){

            grantSet.add(ra.Grant__c);
            raSet.add(ra.Id);
        }
        List<Award__c> awardList = [SELECT Id, BudgetStartEndDate__c FROM Award__c WHERE Grant__c IN :grantSet and Status__c ='Activated' Limit 1];
        
        system.debug('Inside updateBudgetPeriod--grantSet--'+grantSet);

        for(RiskAssessment__c ra : [Select Id, name, CurrentBudgetPeriod__c from RiskAssessment__c where Id IN : raSet]){
            if(awardList != null && !awardList.isEmpty() ){
                ra.CurrentBudgetPeriod__c=awardList[0].BudgetStartEndDate__c;

            }
            lstRA.add(ra);
        }
          system.debug('Inside updateBudgetPeriod');


        if(lstRa!=null && lstRa.size()>0)
        update lstRA;

    }

    /*
    private void lockRiskAssessmentForCloseout(List<RiskAssessment__c> raList){
        Set<Id> grantSet = new Set<Id>();
        Map<Id, Id> grantCloseoutMap = new Map<Id, Id>();
        for(RiskAssessment__c ra : raList){
            grantSet.add(ra.Grant__c);
        }
        List<Closeout__c> closeoutList = [SELECT Id, Grant__c, Status__c FROM Closeout__c WHERE Status__c IN ('Initiated By PM', 'Under PM Review', 'Approved By PM') AND Grant__c IN :grantSet];
        for(Closeout__c ct : closeoutList){
            grantCloseoutMap.put(ct.Grant__c, ct.Id);
        }
        for(RiskAssessment__c ra : raList){
            if(grantCloseoutMap != null && !grantCloseoutMap.isEmpty() && grantCloseoutMap.containsKey(ra.Grant__c)){
                //ra.addError('Closout is in progress for the Grant. Unable to complete request');
                ra.addError(GNT.ErrorMessageHelper.fetchMessage('M01-GRNTR-71821'));
            }
        }
    }
    

    private void updateGrantToPointToLatestRiskOnDelete(){
        Map<Id,Id> grantRiskMap =  new Map<Id,Id>();
        for(RiskAssessment__c ra : (List<RiskAssessment__c>)Trigger.old){            
              grantRiskMap.put(ra.Grant__c,ra.id);                  
        }
        
        List<Grant__c> grants = [SELECT Id,Name,(SELECT Id FROM Risk_Assessment__r ORDER BY CreatedDate LIMIT 1) 
            FROM Grant__c WHERE Id in :grantRiskMap.keySet()];
        
        List<Grant__c> grantsToBeUpdated = new List<Grant__c>();
        for(Grant__c grant :grants){
            if(grant.Risk_Assessment__r.size() > 0){
                system.debug('grant.Risk_Assessment__r[0]-----'+grant.Risk_Assessment__r[0]);
                //grant.LatestRiskAssessment__c = grant.Risk_Assessment__r[0].Id;
            }
            grantsToBeUpdated.add(grant);
            system.debug('grant-----'+grant);
        }
        
        if(grantsToBeUpdated.size() > 0){
            SystemContextMethodsHelper sc = new SystemContextMethodsHelper();
            system.debug('grantsToBeUpdated-----'+grantsToBeUpdated);
            sc.updateGrants(grantsToBeUpdated);
        }
    }

    private void updateGrantToPointToLatestRiskOnInsert(){
        Map<Id,Id> grantRiskMap =  new Map<Id,Id>();
        for(RiskAssessment__c ra : (List<RiskAssessment__c>)Trigger.new ){            
              grantRiskMap.put(ra.Grant__c,ra.id);                  
        }
        
        List<Grant__c> grants = [SELECT Id,Name FROM Grant__c WHERE Id in :grantRiskMap.keySet()];
        
        List<Grant__c> grantsToBeUpdated = new List<Grant__c>();
        
        for(Grant__c grant :grants){
            //grant.LatestRiskAssessment__c = grantRiskMap.get(grant.Id);
            grantsToBeUpdated.add(grant);
            system.debug('grant-----'+grant);
        }
        
        if(grantsToBeUpdated.size() > 0){
            system.debug('grantsToBeUpdated-----'+grantsToBeUpdated);
            SystemContextMethodsHelper sc = new SystemContextMethodsHelper();
            sc.updateGrants(grantsToBeUpdated);
        }
    }
*/

      private void calculateRating(){
        system.debug('Inside calculateRating---');

        for(RiskAssessment__c ra : (List<RiskAssessment__c>)Trigger.new ){
            RiskAssessment__c oldRisk = (RiskAssessment__c)Trigger.oldMap.get(ra.Id);
            system.debug('ra.FiscalRating__c is ---' +ra.FiscalRating__c);  
            system.debug(' ra.SumRating1__c---'+ra.SumRating1__c);
            system.debug('ra.SumRating2__c---'+ra.SumRating2__c);
            system.debug('ra.ProgramRating__c---'+ra.ProgramRating__c);
            system.debug('ra.GrantRating__c---'+ra.GrantRating__c);
            system.debug('oldRisk.ProgramRating__c---'+oldRisk.ProgramRating__c);
            system.debug('oldRisk.GrantRating__c---'+oldRisk.GrantRating__c);
            system.debug('ra.TotalSumofRating__c---'+ra.TotalSumofRating__c);
            if(ra.FiscalRating__c != oldRisk.FiscalRating__c){
            //if(ra.ProgramRating__c != oldRisk.ProgramRating__c || ra.GrantRating__c != oldRisk.GrantRating__c){
                //ra.TotalSumofRating__c = ra.ProgramRating__c + ra.GrantRating__c;
                ra.TotalSumofRating__c = ra.FiscalRating__c;        
            }            
           system.debug('**ra.TotalSumofRating__c---'+ra.TotalSumofRating__c);
           

            if(ra.TotalSumofRating__c >= 0 && ra.TotalSumofRating__c <= 25){
                ra.OverAll_Risk__c = 'Low';
            }else if(ra.TotalSumofRating__c >= 26 && ra.TotalSumofRating__c <= 50){
                ra.OverAll_Risk__c = 'Medium';
            }else if(ra.TotalSumofRating__c >= 51 && ra.TotalSumofRating__c <= 73){
                ra.OverAll_Risk__c = 'High';
            }   
        }
    }
    

       
        
}