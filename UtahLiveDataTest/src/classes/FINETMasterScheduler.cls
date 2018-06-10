public with sharing class FINETMasterScheduler implements Schedulable {
    public class PicklistFormatException extends Exception {}

    public void execute(SchedulableContext SC) {
        FINETBatchScheduleParent__c parent;
        Date today = DateTime.now().date();
        List<FINETBatchScheduleParent__c> parentList = [select ChildOrder__c, IsRunning__c, ScheduleDate__c, Status__c, ChildCount__c from FINETBatchScheduleParent__c where IsRunning__c = true and ScheduleDate__c =: today];
        if (parentList == null || parentList.size() == 0) {
            parentList = [select ChildOrder__c, IsRunning__c, ScheduleDate__c, Status__c, ChildCount__c from FINETBatchScheduleParent__c where ScheduleDate__c =: today];
            if (parentList == null || parentList.size() == 0) {
                Integ_CGIAdv_Utilities.sendErrorEmails('Error: no scheduled batch object found'); 
                return;
            }
            parent = parentList[0];
            parent.IsRunning__c = true;
            update parent;
        } else {
            parent = parentList[0];
        }
        integer i = Integer.valueOf(parent.ChildCount__c);
        Schema.DescribeFieldResult fieldResult = FINETBatchScheduleParent__c.ChildOrder__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        List<string> values = new List<string>();
        for (Schema.PicklistEntry entry : ple) { values.add(entry.getValue()); }
        if (i >= values.size()) {
            List<string> logs = new List<string>();
            for (FINETBatchScheduleChild__c c : [select id, Log__c from FINETBatchScheduleChild__c where FINETBatchScheduleParent__c =: parent.Id]) {
                logs.add(c.Log__c);
            }
            Integ_CGIAdv_Utilities.sendErrorEmails(logs);
            parent.IsRunning__c = false; 
            parent.Status__c = 'Complete';
            update parent;
            insert new FINETBatchScheduleParent__c(ScheduleDate__c = DateTime.now().addDays(1).date());
            return;
        }
        String job = values[i];
        String[] splitString = job.split('-');
        System.Type batchClass = System.Type.forName(splitString[2]);
        if (batchClass != null) {
            FINETBatchScheduleChild__c child = new FINETBatchScheduleChild__c(
                FINETBatchScheduleParent__c = parent.Id,
                Name = splitString[2],
                Status__c = 'Processing'
            );
            insert child;
            try {
                Schedulable s = (Schedulable)JSON.deserialize('{}', batchClass);
                DateTime newTime = DateTime.now().addMinutes(2);
                String cronTime = '0 ' + newTime.minute() + ' ' + newTime.hour() + ' ' + newTime.day() + ' ' + newTime.month() + ' ? ' + newTime.year();
                System.schedule(batchClass.toString() + '_' + cronTime, cronTime , s);
            } catch (Exception e) {
                System.debug('Class parsing error: ' + e);
                throw new Integ_CGIAdv_Utilities.BatchLogicException('Error parsing picklist class');
            }
        } else {
            throw new PicklistFormatException('The picklist value has been formatted incorrectly. Ensure the format is: "#-objectName-className"');
        }
    }
}