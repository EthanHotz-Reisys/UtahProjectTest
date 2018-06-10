global with sharing class CreateMSPPaymentRequestsActionHandler extends GNT.FlexTableActionHandler{

    global override Map<String,Object> clickHandler() {
        Map<String,Object> resultMap = new Map<String,Object>();
        MSPPaymentSchedule__c currentMps = [SELECT Id, FiscalYear__c, Status__c, ScheduleDate__c, MSPFileBatch__c, FirstApprover__c, FinalApprover__c, Pathway__c FROM MSPPaymentSchedule__c WHERE Id IN :selectedRecordIds LIMIT 1];
        Integer previousPaymentCount = [SELECT COUNT() FROM MSPPaymentSchedule__c WHERE ScheduleDate__c < :currentMps.ScheduleDate__c AND FiscalYear__c = :currentMps.FiscalYear__c];
        Integer previousPaidPaymentCount = [SELECT COUNT() FROM MSPPaymentSchedule__c WHERE ScheduleDate__c < :currentMps.ScheduleDate__c AND FiscalYear__c = :currentMps.FiscalYear__c AND Status__c = 'Sent to FINET'];
        if(previousPaymentCount != previousPaidPaymentCount){
            resultMap.put('Error','Please process previous payment schedule first');
            return resultMap;
        }

        if(currentMps.Status__c != 'Created'){
            resultMap.put('Error','Payment Requests already created for this schedule');
            return resultMap;           
        }

        //Group mspGroup = [SELECT Id, Name FROM Group WHERE Type = 'Regular' AND Name = 'USBEFINOPS'];
        //List<GroupMember> mspGroupMembers = [SELECT Id, UserOrGroupId FROM GroupMember WHERE GroupId = :mspGroup.Id];
        List<User> mspGroupMembers = [SELECT Id FROM User WHERE ProfileName__c IN('EXE','System Administrator')];
        Set<String> mspGroupMemberIds = new Set<String>();
        for(User gm : mspGroupMembers){
            //mspGroupMemberIds.add(gm.UserOrGroupId);
            mspGroupMemberIds.add(gm.Id);
        }
        if(!mspGroupMemberIds.contains(UserInfo.getUserId())){
            resultMap.put('Message','You cannot create MSP payments request');
            return resultMap;
        }
        
        FileBatch__c fb;
        if (currentMps.Pathway__c == 'MSP'){
        	fb = [SELECT Id, Status__c, FirstApprover__c, SecondApprover__c FROM FileBatch__c WHERE RecordType.Name = 'MSP' AND Status__c = 'Active' AND FiscalYear__c = :currentMps.FiscalYear__c];
        } else if (currentMps.Pathway__c == 'App12'){
        	fb = [SELECT Id, Status__c, FirstApprover__c, SecondApprover__c FROM FileBatch__c WHERE RecordType.Name = 'App12' AND Status__c = 'Active' AND FiscalYear__c = :currentMps.FiscalYear__c];
        }
        currentMps.MSPFileBatch__c = fb.Id;
        currentMps.Status__c = 'Processing';
        currentMps.FirstApprover__c = fb.FirstApprover__c;
        currentMps.FinalApprover__c = fb.SecondApprover__c;
        update currentMps;
        Database.executeBatch(new MSPPaymentCreationBatch(currentMps), 200);
        PageReference returnPage = Page.PhaseView;
        returnPage.getParameters().put('t','Monitoring'); 
        resultMap.put('PageReference',returnPage);
        return resultMap;
    }
}