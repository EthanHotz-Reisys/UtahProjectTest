/*
    This class has methods to execute methods related to Goal Objective Trigger
    **********************************************************
    Audit History
    **********************************************************
    10-05-2016             Davinder Singh     Created 
    **********************************************************  
*/

public class GoalObjectiveTriggerHelper extends GNT.TriggerHelper{
    
    public static boolean skipTrigger = false;  

    public override void processBeforeInsert() {
        if(skipTrigger==false){                
           updateRecord(trigger.new);                 
        }
    }

    public override void processAfterInsert() {
        if(skipTrigger==false){                
           validateAllocation(trigger.new);      
           populateGoalObjectiveData(trigger.new);
           updateGoalObjectiveIndicator(trigger.new);
        }
    }
    
    public override void processAfterUpdate() {
        if(skipTrigger==false){       
           validateAllocation(trigger.new);               
           populateGoalObjectiveData(trigger.new);
        }
    }

    public override void processBeforeUpdate() {
        if(skipTrigger==false){
          for(GoalObjective__c goal : (List<GoalObjective__c>)Trigger.new){
            if(goal.AwardQ1__c!=null && goal.AwardQ1Comments__c == null){
              goal.addError('Please add comments for Achieved Q1');
            }else if(goal.AwardQ2__c!=null && goal.AwardQ2Comments__c == null){
              goal.addError('Please add comments for Achieved Q2');
            }else if(goal.AwardQ3__c!=null && goal.AwardQ3Comments__c == null){
              goal.addError('Please add comments for Achieved Q3');
            }else if(goal.AwardQ4__c!=null && goal.AwardQ4Comments__c == null){
              goal.addError('Please add comments for Achieved Q4');
            }
          }
        }
    }

    public override void processBeforeDelete() {
        if(skipTrigger==false){       
           deleteObjectives(trigger.old);                          
        }
    }

    public override void processAfterDelete() {
        if(skipTrigger==false){       
           updateGoalObjectiveIndicator(trigger.old);                          
        }
    }
    
    // Based on the Allocation % , allocation $ is calculated and updated in Record
    // This applies only for Grant/Award Record
    private void populateGoalObjectiveData(List<GoalObjective__c> termConditionList){
        List<Id> goalIds = new List<Id>();
        List<GoalObjective__c> tConditionList = new List<GoalObjective__c>();
        Boolean isObjectiveFlag=false;
        for(GoalObjective__c tc : termConditionList) {
         if(tc.recordtypeId==Schema.SObjectType.GoalObjective__c.getRecordTypeInfosByName().get('Program').getRecordTypeId())
         return;
         else{ 
          goalIds.add(tc.Id);
          isObjectiveFlag=tc.isParent__c==true?false:true;            
          }
        } 
        
        if(isObjectiveFlag){
          //tConditionList = [select Id, Award__r.YTDReimbursementPaid__c, Allocated__c,type__c,Award__r.TotalGrantAwardAmount__c, ParentGoal__r.Award__r.TotalGrantAwardAmount__c,ParentGoal__r.ExpenditureAmount__c,ParentGoal__r.AllocatedAmount__c FROM GoalObjective__c where ID in : goalIds];
          tConditionList = [select Id, Award__r.YTDReimbursementPaid__c, Allocated__c,type__c,Award__r.TotalGrantAwardAmount__c, ParentGoal__r.Award__r.TotalGrantAwardAmount__c,ParentGoal__r.ExpenditureAmount__c,ParentGoal__r.AllocatedAmount__c, QuantitativeNumberMeasures__c, Other__c, Description__c, ActivitiesAndMethods__c, MeasureEffectiveness__c, CombineTextQuestions__c,TargetedQ__c,Q1__c,Q2__c,Q3__c,Q4__c,AwardTotalQuantitative__c,AchievedQComments__c,AwardQ1__c,AwardQ2__c,AwardQ3__c,AwardQ4__c,AwardQ1Comments__c,AwardQ2Comments__c,AwardQ3Comments__c,AwardQ4Comments__c FROM GoalObjective__c where ID in : goalIds];     
        }
        else{        
          tConditionList = [select Id, ParentGoal__r.ExpenditureAmount__c, ParentGoal__r.AllocatedAmount__c, Allocated__c,type__c,Award__r.TotalGrantAwardAmount__c,ExpenditureAmount__c,Award__r.YTDReimbursementPaid__c,AllocatedAmount__c  FROM GoalObjective__c where ID in : goalIds];
        }
        
        for(GoalObjective__c obj : tConditionList) {
          if(obj.type__c=='Goal') {  // This is Goal Record
                  Decimal allocatedPercent = obj.Allocated__c==null?0:obj.Allocated__c;
                  Decimal totalAmount = obj.Award__r.TotalGrantAwardAmount__c == null ? 0 : obj.Award__r.TotalGrantAwardAmount__c;
                  Decimal totalExpenditure = obj.Award__r.YTDReimbursementPaid__c == null ? 0 : obj.Award__r.YTDReimbursementPaid__c;
                  Decimal allocatedAmount = (allocatedPercent*totalAmount)/100;
                  obj.AllocatedAmount__c=allocatedAmount;
                  Decimal expenditureAmount = (allocatedPercent*totalExpenditure)/100; 
                  obj.ExpenditureAmount__c=expenditureAmount;
              
            }
            else {  // This is Objective Record
                  Decimal allocatedPercent = obj.Allocated__c==null?0:obj.Allocated__c;
                  Decimal totalParentAmount = obj.ParentGoal__r.AllocatedAmount__c == null ? 0 : obj.ParentGoal__r.AllocatedAmount__c;
                  Decimal totalParentExpenditureAmount = obj.ParentGoal__r.ExpenditureAmount__c == null ? 0 : obj.ParentGoal__r.ExpenditureAmount__c;
                  Decimal allocatedAmount = (allocatedPercent*totalParentAmount )/100;
                  Decimal expenditureAmount = (allocatedPercent*totalParentExpenditureAmount )/100;
                  obj.AllocatedAmount__c=allocatedAmount;
                  obj.ExpenditureAmount__c=expenditureAmount;
            }
            
            //Consolidates the text questions for use in print to pdf, since formula fields don't support rich text fields
            obj.CombineTextQuestions__c = 'Quantitative Number Measures: ' + ((obj.QuantitativeNumberMeasures__c == null)? 'N/A' : obj.QuantitativeNumberMeasures__c) + '<br><br>' + 'Other: ' + ((obj.Other__c == null)? 'N/A' : obj.Other__c) + '<br><br>' + 'Objective Description: ' + ((obj.Description__c == null)? 'N/A' : obj.Description__c) + '<br><br>' + 'Activities And Methods: ' + ((obj.ActivitiesAndMethods__c == null)? 'N/A' : obj.ActivitiesAndMethods__c) + '<br><br>' + 'Indicate How You Will Measure The Effectiveness Of This Goal: ' + ((obj.MeasureEffectiveness__c == null)? 'N/A' : obj.MeasureEffectiveness__c);
            obj.AchievedQComments__c = 'Comments on Achieved Q1 :' + ((obj.AwardQ1Comments__c == null)? 'N/A' : obj.AwardQ1Comments__c) + '<br><br>' + 'Comments on Achieved Q2 :' + ((obj.AwardQ2Comments__c == null)? 'N/A' : obj.AwardQ2Comments__c) + '<br><br>' + 'Comments on Achieved Q3 :' + ((obj.AwardQ3Comments__c == null)? 'N/A' : obj.AwardQ3Comments__c) + '<br><br>' + 'Comments on Achieved Q4 :' + ((obj.AwardQ4Comments__c == null)? 'N/A' : obj.AwardQ4Comments__c) ;
            //system.debug('Targeted Q1 is ' +obj.Q1__c);
            //obj.TargetedQ__c = 'Q1:' +((obj.Q1__c == null)? 'N/A' : obj.Q1__c.format()) + '<br><br>' + 'Q2:' +((obj.Q2__c == null)? 'N/A' : obj.Q2__c.format()) + '<br><br>' +'Q3:' +((obj.Q3__c == null)? 'N/A' : obj.Q3__c.format()) + '<br><br>' +'Q4:' +((obj.Q4__c == null)? 'N/A' : obj.Q4__c.format()) ;
            //obj.AchievedQ__c = 'Q1:' +((obj.AwardQ1__c == null)? 'N/A' : obj.AwardQ1__c.format()) + '<br><br>' + 'Q2:' +((obj.AwardQ2__c == null)? 'N/A' : obj.AwardQ2__c.format()) + '<br><br>' +'Q3:' +((obj.AwardQ3__c == null)? 'N/A' : obj.AwardQ3__c.format()) + '<br><br>' +'Q4:' +((obj.AwardQ4__c == null)? 'N/A' : obj.AwardQ4__c.format()) ;
            obj.AchievedQ__c = 'Q1:' +((obj.AwardQ1__c == null)? 'N/A' : obj.AwardQ1__c.format()) + '<br><br>' + 'Q2:' +((obj.AwardQ2__c == null)? 'N/A' : obj.AwardQ2__c.format()) + '<br><br>' +'Q3:' +((obj.AwardQ3__c == null)? 'N/A' : obj.AwardQ3__c.format()) + '<br><br>' +'Q4:' +((obj.AwardQ4__c == null)? 'N/A' : obj.AwardQ4__c.format()) + '<br><br>' + 'Total Quantitative:'+((obj.AwardTotalQuantitative__c == null)? 'N/A' : obj.AwardTotalQuantitative__c.format())+ '<br><br>';
        }
        skipTrigger =true;
        update tConditionList; 

        //update Objective allocation if goal Allocation is changed
        if(Trigger.isUpdate && !isObjectiveFlag)
        updateObjectiveAllocation((Map<Id,GoalObjective__c>)Trigger.oldMap,(Map<Id,GoalObjective__c>)Trigger.newMap);       
    }
    
    // Validate Sum Total of Allocation % never exceeds 100%
    private void validateAllocation(List<GoalObjective__c> termConditionList){
        List<Id> targetIds = new List<Id>();
        List<Id> goalIds = new List<Id>();
        List<GoalObjective__c> tConditionList = new List<GoalObjective__c>();
        Boolean isObjectiveFlag=false;
        
        for(GoalObjective__c tc : termConditionList) {// looping over tigger.new  
         if(tc.recordtypeId==Schema.SObjectType.GoalObjective__c.getRecordTypeInfosByName().get('Program').getRecordTypeId())
         return;  
          else{
            goalIds.add(tc.Id);       
            if(tc.type__c=='Goal'){
                isObjectiveFlag=false;
                targetIds.add(tc.Award__c);
            }else if(tc.type__c=='Objective'){
                isObjectiveFlag=true;
                targetIds.add(tc.ParentGoal__c);
            }
          }
        } 
        
        if(!isObjectiveFlag){// select from goals, all child objectives
          tConditionList = [select Id,Allocated__c,type__c,ParentGoal__c FROM GoalObjective__c where Award__c in : targetIds and isParent__c=true and Id Not in :goalIds ];   
        }
        else{        // select award and then all goals
          tConditionList = [select Id,Allocated__c,type__c,Award__c FROM GoalObjective__c where ParentGoal__c in : targetIds and isParent__c=false and Id Not in :goalIds ];
        }
                
        Decimal totalAllocation=0;
        // Find Sum total of existing allocation % 
        for(GoalObjective__c obj : tConditionList ){
            totalAllocation+=obj.Allocated__c==null?0:obj.Allocated__c;                   
        }        
        
        for(GoalObjective__c tc : termConditionList) {// Trigger.new        
            totalAllocation+=tc.Allocated__c==null?0:tc.Allocated__c;            
             if(totalAllocation>100){
                 // tc.addError('Total Allocation can not exceed 100%');
                 //tc.addError(GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTE-67740'));                                           
              }        
        }            
    }

    // update Record Type based on if Award/Program is mapped
    private void updateRecord(List<GoalObjective__c> lstGoals){
      for(GoalObjective__c gobj : lstGoals){
        if(gobj.Program__c!=null){
          gobj.RecordTypeId = Schema.SObjectType.GoalObjective__c.getRecordTypeInfosByName().get('Program').getRecordTypeId();
          }else if(gobj.Award__c!=null){
          gobj.RecordTypeId = Schema.SObjectType.GoalObjective__c.getRecordTypeInfosByName().get('Award').getRecordTypeId();
          }else if(gobj.Application__c!=null){
          gobj.RecordTypeId = Schema.SObjectType.GoalObjective__c.getRecordTypeInfosByName().get('Application').getRecordTypeId();
        }
      }
    }

    private void updateObjectiveAllocation(Map<Id,GoalObjective__c> oldMap,Map<Id,GoalObjective__c> newMap){
      Set<Id> goalIds = new Set<Id>();
       for(Id goalId : newMap.keySet()){
            if(oldMap.get(goalId).Allocated__c != newMap.get(goalId).Allocated__c){
              System.debug('Different Values ');
              goalIds.add(goalId);
            }
          }

    // Query Objective Table
      List<GoalObjective__c>  ObjectivesList = [select Id,Name,Allocated__c,type__c,ParentGoal__r.Award__r.TotalGrantAwardAmount__c,ParentGoal__r.ExpenditureAmount__c,ParentGoal__r.AllocatedAmount__c FROM GoalObjective__c where ParentGoal__c in : goalIds];     
     
         for(GoalObjective__c obj : ObjectivesList) {    
                  System.debug('*obj*'+obj);                     
                  Decimal totalParentAmount = obj.ParentGoal__r.AllocatedAmount__c == null ? 0 : obj.ParentGoal__r.AllocatedAmount__c;
                  Decimal totalParentExpenditureAmount = obj.ParentGoal__r.ExpenditureAmount__c == null ? 0 : obj.ParentGoal__r.ExpenditureAmount__c ;
                  Decimal allocatedAmount = (obj.Allocated__c==null?0:obj.Allocated__c*totalParentAmount )/100;
                  Decimal expenditureAmount = (obj.Allocated__c==null?0:obj.Allocated__c*totalParentExpenditureAmount )/100;
                  obj.AllocatedAmount__c=allocatedAmount;
                  obj.ExpenditureAmount__c=expenditureAmount;         
        }

        skipTrigger =true;
        update ObjectivesList; 
    }  

    // When Goal is deleted, delete all child objectives
     private void deleteObjectives(List<GoalObjective__c> lstGoals){
      Set<Id> goalIds  = new Set<Id>();
       for(GoalObjective__c obj : lstGoals) {
          if(obj.type__c=='Goal') {
             goalIds.add(obj.Id);
          }
        }
        List<GoalObjective__c>  ObjectivesList = [select Id,Name FROM GoalObjective__c where ParentGoal__c in : goalIds];     
        if(ObjectivesList.size()>0)
        delete ObjectivesList;

     }

     private void updateGoalObjectiveIndicator(List<GoalObjective__c> lstGoals){
      Set<Id> formIds = new Set<Id>();
      for(GoalObjective__c goal : lstGoals){
        if(goal.Form__c != null && !formIds.contains(goal.Form__c)){
          formIds.add(goal.Form__c);
        }
      }

      if(formIds.size() == 0){
        return;
      }

      Map<Id, Form__c> formMap = new Map<Id, Form__c>([Select Id, GoalObjectiveIndicator__c from Form__c where Id In :formIds]);
      List<Form__c> checkGoal = [Select Id, (Select Id from Goals_Objectives__r where IsParent__c = true) from Form__c where Id In :formIds];

      List<GoalObjective__c> goodGoals = new List<GoalObjective__c>();

      Set<Id> updateForm = new Set<Id>();

      for(Form__c f : checkGoal){
        if(f.Goals_Objectives__r.size() > 0){
          for(GoalObjective__c g : f.Goals_Objectives__r){
            goodGoals.add(g);
          }
        }
      }

      List<GoalObjective__c> checkObjective = [Select Id, (Select Id from Goals_and_Objectives2__r), Form__c from GoalObjective__c where Id IN :goodGoals];
      for(GoalObjective__c g : checkObjective){
        if(g.Goals_and_Objectives2__r.size() > 2){
          if(!updateForm.contains(g.Form__c)){
            updateForm.add(g.Form__c);
          }
        }
      }

      for(Id i : formMap.keySet()){
        if(updateForm.contains(i)){
          formMap.get(i).GoalObjectiveIndicator__c = 'Yes';
        }else{
          formMap.get(i).GoalObjectiveIndicator__c = null;
        }
      }

      System.debug('FormMap-------------->' + formMap);

      update formMap.values();

     }
    
}