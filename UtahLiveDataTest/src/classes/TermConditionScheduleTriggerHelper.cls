global class TermConditionScheduleTriggerHelper extends GNT.TriggerHelper{

    global override void processBeforeInsert() {       
       // updateGranteeNotifiedField(Trigger.new);
       insertReportStatusField(Trigger.new);    
    }
    
    global override void processBeforeUpdate() {
        //beginingAndEndDateValidation();
    }

    global override void processAfterInsert() {
        //updateGranteeNotifiedField(Trigger.new);
    }

    private void insertReportStatusField(List<TermConditionSchedule__c> termConditionSchedules) {
        for(TermConditionSchedule__c tcs : termConditionSchedules) {
            if(tcs.TaskCreated__c == null || tcs.TaskCreated__c == false) {
                tcs.ReportStatus__c = 'N/A';
            }
        }
    }
    //TanmayDeshpande 14-Sept-2015 Commenting following method definitions as they are not called in order to increase code coverage.

   /* private void updateGranteeNotifiedField(List<TermConditionSchedule__c> termConditionSchedules) {
       
       Map<id,List<TermConditionSchedule__c>> termConditionsMap = new Map<id,List<TermConditionSchedule__c>>();
        for(TermConditionSchedule__c tcs : termConditionSchedules) {
                if(!termConditionsMap.keyset().contains(tcs.TermAndCondition__c)) {
                    List<TermConditionSchedule__c> relatedSchedules = new List<TermConditionSchedule__c>();
                    relatedSchedules.add(tcs);
                    termConditionsMap.put(tcs.TermAndCondition__c,relatedSchedules);
                }
                else {
                    termConditionsMap.get(tcs.TermAndCondition__c).add(tcs);
                }
        }
        
        Map<id,List<TermConditionSchedule__c>> termConditionsOldMap = new Map<id,List<TermConditionSchedule__c>>();
        List<TermConditionSchedule__c> termCondSchedules = new List<TermConditionSchedule__c>([select id,StartDate__c 
                                                                                                from TermConditionSchedule__c 
                                                                                                where TermAndCondition__c in : termConditionsOldMap.keyset()]);
        for(TermConditionSchedule__c tcs : termCondSchedules ) {
                if(!termConditionsOldMap.keyset().contains(tcs.TermAndCondition__c)) {
                    List<TermConditionSchedule__c> relatedSchedules = new List<TermConditionSchedule__c>();
                    relatedSchedules.add(tcs);
                    termConditionsOldMap.put(tcs.TermAndCondition__c,relatedSchedules);
                }
                else {
                    termConditionsOldMap.get(tcs.TermAndCondition__c).add(tcs);
                }
        }
        
        Map<id,TermCondition__c> trmConds = new Map<id,TermCondition__c>([select id,Award__c,Award__r.AwardType__c 
                                                                            from TermCondition__c 
                                                                            where id in : termConditionsMap.keyset()]);
        List<TermConditionSchedule__c> tSchedules = new List<TermConditionSchedule__c>();
        Set<String> awardTypes = new Set<String>{'Supplemental','Extension With or Without Funds','Admin Changes ? POC and T&C','Transfer Award','Other admin changes. Change in agency etc.'};
        List<TermConditionSchedule__c> tcsToBeUpdated = new List<TermConditionSchedule__c>();
        for(TermConditionSchedule__c tSchedule : termConditionSchedules) {
           
           
            if(awardTypes.contains(trmConds.get(tSchedule.TermAndCondition__c).Award__r.AwardType__c) && tSchedule.EndDate__c <= System.today()) {
                for(TermConditionSchedule__c termCondSchedule : termConditionsMap.get(tSchedule.TermAndCondition__c) ) {
                    if(termConditionsOldMap.get(tSchedule.TermAndCondition__c) != null) {
                        for(TermConditionSchedule__c termCondScheduleOld : termConditionsOldMap.get(tSchedule.TermAndCondition__c) ) {
                    if(termCondSchedule.StartDate__c == termCondScheduleOld.StartDate__c) {
                         tSchedules.add(tSchedule);
                    }
                    
                }
                    }
                    else {
                         tSchedule.TaskCreated__c = true;
                        tcsToBeUpdated.add(tSchedule);
                    }
                    
               } 
            }
        }
        delete tSchedules;
        //update tcsToBeUpdated;
    }

    private void beginingAndEndDateValidation() {        
        
            Map<Id,List<TermConditionSchedule__c>> termCondScheduleMap = new Map<Id,List<TermConditionSchedule__c>>();
            List<Id> termConditionIds = new List<Id>();
            for( TermConditionSchedule__c tcs : (List<TermConditionSchedule__c>)Trigger.new) {
                termConditionIds.add(tcs.TermAndCondition__c);
            }

            List<TermConditionSchedule__c> tConditionSchedules = [SELECT StartDate__c, EndDate__c, DueDate__c,ReportingTaskCreationDate__c,TaskCreated__c, 
            TermAndCondition__c 
            FROM TermConditionSchedule__c 
            WHERE TermAndCondition__c in : termConditionIds];
            for(Id tcId : termConditionIds) {
                List<TermConditionSchedule__c> termCondSchedules = new List<TermConditionSchedule__c>();
                for(TermConditionSchedule__c tConds : tConditionSchedules) {
                    if(tConds.TermAndCondition__c == tcId) {
                        termCondSchedules.add(tConds);
                    }
                    termCondScheduleMap.put(tcId,termCondSchedules);    
                }                
            }
            for(TermConditionSchedule__c t : (List<TermConditionSchedule__c>)Trigger.new) {
                String combo = t.StartDate__c +''+t.EndDate__c;                
                List<TermConditionSchedule__c> schedules = termCondScheduleMap.get(t.TermAndCondition__c);
                for(TermConditionSchedule__c schedule : schedules) {
                    String existingCombo = schedule.StartDate__c+''+schedule.EndDate__c;
                    if(trigger.isBefore && trigger.isUpdate) {
                        if(combo.equals(existingCombo) && t.Id != schedule.Id) {
                            t.addError('Duplicate Combination of Start and End Date Exists');
                        }
                    }
                    else if(trigger.isBefore && trigger.isInsert) {
                        if(combo.equals(existingCombo)) {
                            t.addError('Duplicate Combination of Start and End Date Exists');
                        }
                    }
                    
                }
            }
    }*/
}