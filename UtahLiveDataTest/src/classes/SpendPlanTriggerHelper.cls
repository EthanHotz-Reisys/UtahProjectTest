/*
    
    ***********************************************************
    Audit History
    ***********************************************************
    12/02/2016      Ramu Loke             Created
    *********************************************************** 
*/

public with sharing class SpendPlanTriggerHelper extends GNT.TriggerHelper {
	
	public override void processBeforeInsert() {
      checkforGrantSpendType();
    } 
    
    public override void processAfterInsert() {
       
    }  
         
    public override void processBeforeUpdate(){ 
       checkforGrantSpendType();
    }       

    public override void processAfterUpdate() { 
        
        
    }   
    
     public override void processBeforeDelete(){
         
    }
      
    
    public override void processAfterDelete(){
         
    }
    /* Check for duplicate Spend Types in Grant i.e; Same Spend Type */
    private void checkforGrantSpendType(){
        Set<Id> grantid = new Set<Id>();

        for(SpendPlan__c spendplan : (List<SpendPlan__c>)Trigger.new){
            if(spendplan.Grant__c != null){
                grantid.add(spendplan.Grant__c);  
            }                     
        }          
        if(grantid.size() > 0){
         Map<Id,List<SpendPlan__c>> parentSpendtypes = new Map<Id,List<SpendPlan__c>>();    
         String query =  'Select Id,Name,SpendType__c,Grant__c from SpendPlan__c where Grant__c in '+GNT.AppUtils.soqlList(grantid);
         List<SpendPlan__c> spendplanlst = Database.query(query);
 
            for(SpendPlan__c spendplan : (List<SpendPlan__c>)spendplanlst){
                for(SpendPlan__c spend : (List<SpendPlan__c>)Trigger.new){
                    if(spendplan.Grant__c == spend.Grant__c)
                        if(spend.SpendType__c.equals(spendplan.SpendType__c) ){
                            // spend.addError('Same Spend Type cannot be added again');
                            spend.addError(GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-34210'));
                            //role.addError(GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTE-77543'));
                        }
                    }
                }
            }    
    }
    
}