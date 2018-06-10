global with sharing class RecreateMSPPaymentRequestsActionHandler extends GNT.FlexTableActionHandler{
    global override Map<String,Object> clickHandler() {
        Map<String,Object> resultMap = new Map<String,Object>();
        //Group mspGroup = [SELECT Id, Name FROM Group WHERE Type = 'Regular' AND Name = 'USBEFINOPS'];
        //List<GroupMember> mspGroupMembers = [SELECT Id, UserOrGroupId FROM GroupMember WHERE GroupId = :mspGroup.Id];
        List<User> mspGroupMembers = [SELECT Id FROM User WHERE ProfileName__c = 'EXE'];
        Set<String> mspGroupMemberIds = new Set<String>();
        for(User gm : mspGroupMembers){
            //mspGroupMemberIds.add(gm.UserOrGroupId);
            mspGroupMemberIds.add(gm.Id);
        }
        /*
        if(!mspGroupMemberIds.contains(UserInfo.getUserId())){
            resultMap.put('Error','You cannot create MSP payments request');
            return resultMap;
        }
        */
        MSPPaymentSchedule__c currentMps = [SELECT Id, FiscalYear__c, Status__c, ScheduleDate__c, FirstApprover__c, FinalApprover__c, Pathway__c FROM MSPPaymentSchedule__c WHERE Id IN :selectedRecordIds LIMIT 1];
        currentMps.Status__c = 'Processing';
        FileBatch__c fb = [SELECT Id, Status__c, FirstApprover__c, SecondApprover__c FROM FileBatch__c WHERE RecordType.Name = 'MSP' AND Status__c = 'Active' AND FiscalYear__c = :currentMps.FiscalYear__c];
        currentMps.MSPFileBatch__c = fb.Id;
        currentMps.FirstApprover__c = fb.FirstApprover__c;
        currentMps.FinalApprover__c = fb.SecondApprover__c;
        update currentMps;
        Database.executeBatch(new MSPPaymentsRecreateBatch(currentMps), 200);
        PageReference returnPage = Page.PhaseView;
        returnPage.getParameters().put('t','Monitoring'); 
        resultMap.put('PageReference',returnPage);
        return resultMap;
    }
}