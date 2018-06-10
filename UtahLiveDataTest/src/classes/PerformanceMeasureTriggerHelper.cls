/*
    This class has methods to execute methods related to Performance Measure Trigger
    **********************************************************
    Audit History
    **********************************************************
    10-07-2016             Davinder Singh     Created 
    **********************************************************  
*/

public class PerformanceMeasureTriggerHelper extends GNT.TriggerHelper{
    
    public static boolean skipTrigger = false;   

    public override void processAfterInsert() {
        if(skipTrigger==false){                
           validateAllocation(trigger.new); 
        }
    }
    
    public override void processAfterUpdate() {
        if(skipTrigger==false){       
           validateAllocation(trigger.new);    
        }
    }
       
    
    private void validateAllocation(List<PerformanceMeasure__c> termConditionList){                  
        Decimal totalAllocation=0;             
        
        for(PerformanceMeasure__c tc : termConditionList) {// Trigger.new        
            totalAllocation+=tc.Weightage__c;          
             if(totalAllocation>100){
                 //tc.addError('Total Weightage can not exceed 100%'); 
                 tc.addError(GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-80491'));                                           
              }        
        }            
    }

 }