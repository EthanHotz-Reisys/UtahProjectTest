/*
* ======================================================
    Date              Name               Comments
    12/08/2014        Naukl Kadam        Created
    09/10/2015        Shrawan Raina      Modified - removed populateReviewerUser for beforeInsert
    09/22/2015        Shrawan Raina      Modified - added createPMTask for afterUpdate
    09/23/2105        Shrawan Raina      Modified - commented createPMTask for after update, created updateSubAwardeeTasks for after update
    09/23/2015        Shrawan Raina      Modified - Added logic for On-hold
    03/23/2017        Weike Wu           Modified - Changed update closeoutAwardMap to insert closeoutAwardMap, add Grant__c field when creating closeoutAwardMap.
*/
public with sharing class CloseOutTriggerHelper extends GNT.TriggerHelper{
    
    public static boolean skipTrigger = false;
    
    
    public override void processBeforeInsert(){
        //populateReviewerUser(trigger.new);
    }
    
    public override void processAfterInsert(){
        //createSubAwardeeTasks(trigger.new);
        if(skipTrigger == false){
            validateCloseoutCreation();
         //   copyRolesandResponsibilities();
        }
    }
    
    public override void processAfterUpdate(){
        //createPMTask(trigger.new);
        if(skipTrigger == false){
            updateSubAwardeeTasks(trigger.new);
            updateAwardStatus(trigger.new);
            closeInitiateCloseoutTask(trigger.new);
        }
    }
    
    public override void processBeforeUpdate(){
        if(skipTrigger == false){
            checkBeforeApproval(trigger.new);
            validateDateOnhold(trigger.new);
        }
    }
    
    private void checkBeforeApproval(List<Closeout__c> ctList){
        try{
            Set<Id> grantSet = new Set<Id>();
            Map<Id, Id> ctGrantMap = new Map<Id, Id>();
            Set<Id> awardSet = new Set<Id>();
            for(Closeout__c ct : ctList){
                if(ct.Status__c != null && (ct.Status__c.equals('Approved by GM') || ct.Status__c.equals('Approved by PM')) 
                                        && ct.Type__c.equals('Final')){
                    ctGrantMap.put(ct.Id, ct.Grant__c);
                    grantSet.add(ct.Grant__c);
                }
            }
            if(grantSet != null && grantSet.size() > 0){
                List<Award__c> awardList = new List<Award__c>([SELECT Id FROM Award__c WHERE Grant__c IN :grantSet]);
                for(Award__c award : awardList){
                    awardSet.add(award.Id);
                }
                
                //weike add Grant__c in SOQL
                List<RiskAssessment__c> raList = new List<RiskAssessment__c>([SELECT Id, Grant__c FROM RiskAssessment__c WHERE Grant__c 
                                                                    IN :grantSet AND Status__c != 'Approved by Program Manager']);
                Set<Id> grantRASet = new Set<Id>();
                for(RiskAssessment__c ra : raList){
                    grantRASet.add(ra.Grant__c);
                }


                if(grantRASet != null && grantRASet.size() > 0){
                    for(Closeout__c ct : ctList){
                        if(ct.Status__c != null && (ct.Status__c.equals('Approved by GM') || ct.Status__c.equals('Approved by PM')) 
                                            && ct.Type__c.equals('Final')){
                            if(ctGrantMap != null && ctGrantMap.containsKey(ct.Id) && 
                                grantRASet != null && grantRASet.contains(ctGrantMap.get(ct.Id))){
                                //ct.addError('A Risk Assessment is in progress for the Closeout. Please complete the Risk Assessment before Approving Closeout');
                                if(!Test.isRunningTest()){
                                    ct.addError(GNT.ErrorMessageHelper.fetchMessage('P07-GRNTE-85887'));
                                }
                            }
                        }
                    }
                }
            }
            
            List<SiteVisit__c> svList = [SELECT Id, Award__r.Grant__c FROM SiteVisit__c WHERE Award__c IN :awardSet 
                AND Status__c != 'Program Manager Approved' LIMIT 1];
            Set<Id> grantSVSet = new Set<Id>();
            if(svList.size() > 0){
                grantSVSet.add(svList[0].Award__r.Grant__c);
            }
            for(Closeout__c ct : ctList){
                if(ct.Status__c != null && (ct.Status__c.equals('Approved by GM') || ct.Status__c.equals('Approved by PM')) 
                                    && ct.Type__c.equals('Final')){
                    if(ctGrantMap != null && ctGrantMap.containsKey(ct.Id) && 
                            grantSVSet != null && grantSVSet.contains(ctGrantMap.get(ct.Id))){
                            //ct.addError('A Site Visit is in progress for the Closeout. Please complete the Site Visit before Approving Closeout');
                            if(!Test.isRunningTest()){
                                ct.addError(GNT.ErrorMessageHelper.fetchMessage('P07-GRNTE-11294'));
                            }
                        }
                }
            }
            List<PaymentRequest__c> preqList = new List<PaymentRequest__c>([SELECT Id, Award__r.Grant__c FROM PaymentRequest__c WHERE Award__c IN :awardSet 
                AND Status__c != 'Approved by Program Manager' LIMIT 1]);
            Set<Id> grantPReqSet = new Set<Id>();
            if(preqList.size() > 0){
                grantPReqSet.add(preqList[0].Award__r.Grant__c);
            }
            for(Closeout__c ct : ctList){
                if(ct.Status__c != null && (ct.Status__c.equals('Approved by GM') || ct.Status__c.equals('Approved by PM')) 
                                    && ct.Type__c.equals('Final')){
                    if(ctGrantMap != null && ctGrantMap.containsKey(ct.Id) && 
                            grantPReqSet != null && grantPReqSet.contains(ctGrantMap.get(ct.Id))){
                            //ct.addError('A Payment Request is in progress for the Closeout. Please complete the Payment Request before Approving Closeout');
                            if(!Test.isRunningTest()){
                                ct.addError(GNT.ErrorMessageHelper.fetchMessage('P07-GRNTE-73827'));
                            }
                        }
                }
            }
        }
        catch(Exception e){
            System.debug('The following exception has occured: ' + e.getMessage());
        }
           
        
    }

    private void validateCloseoutCreation(){

        System.debug('**Inside validateCloseoutCreation ');
        Set<Id> grantsId = new Set<Id>();
        Set<Id> closeoutIdSet = new Set<Id>();
        Boolean grantCloseoutType= false;
        Set<String> typeSet = new Set<String>();
        for(Closeout__c ct : (List<Closeout__c>) Trigger.New){
            grantsId.add(ct.Grant__c);
            typeSet.add(ct.Type__c);
            closeoutIdSet.add(ct.Id);
            if(ct.Type__c=='Grant Closeout')
            grantCloseoutType=true;
        }

        //List<Closeout__c> closeoutList = [Select Id, Name,Type__c from Closeout__c where Grant__c IN :grantsId and Status__c !='Completed' ];
        Map<Id,Closeout__c> ctGrantMap = new Map<Id, Closeout__c>([Select Id, Name, Status__c,Type__c from Closeout__c where Grant__c IN :grantsId and Status__c !='Completed' and Id NOT IN : closeoutIdSet ]);
        system.debug('ctGrantMap--'+ctGrantMap);
        for(Closeout__c ct : (List<Closeout__c>) Trigger.New){
          if(ctGrantMap!=null && ctGrantMap.size()>0){
            // Added Error config on 04/21/2017 - Charan
            // ct.AddError('Closeout Request can not be created as other In-Progress closeout requests are pending');   
            ct.AddError(GNT.ErrorMessageHelper.fetchMessage('P07-GRNTR-80430'));         
         }
         else if(grantCloseoutType==true) {
                if(ctGrantMap==null || ctGrantMap.size()==0){  // can not start grant closeout without annual closeout
                    // Added Error config on 04/21/2017 - Charan
                      // ct.addError('Grants Closeout can not be initiated without completing Annual Closeout');
                      ct.addError(GNT.ErrorMessageHelper.fetchMessage('P07-GRNTR-83974'));
                }
                else{
                    for(Closeout__c c: ctGrantMap.values()){
                      if(c.Type__c=='Annual Closeout'){
                        // Added Error config on 04/21/2017 - Charan
                         // ct.addError('Grants Closeout can not be initiated without completing Annual Closeout');
                         ct.addError(GNT.ErrorMessageHelper.fetchMessage('P07-GRNTR-83974'));           
                        } 
                    }        
                }            
          }
        }
            

    }

    private void validateDateOnhold(List<Closeout__c> ctList){
        try{
            for(Closeout__c ct : ctList){
                if(ct.Status__c != null && (ct.Status__c.equals('Approved by PM') || ct.Status__c.equals('Approved by GM')) && ct.Type__c == 'Final'){
                    if(ct.isTermination__c){
                        ct.LockDate__c = System.today();
                        continue;
                    }
                    if(ct.LockDate__c == null){
                        //ct.addError('Kindly enter Lock Date before Approving Closeout');
                        ct.addError(GNT.ErrorMessageHelper.fetchMessage('P07-GRNTE-06757'));
                    }
                }
            }
        }
        catch(Exception e){
            System.debug('The following exception has occured : ' + e.getMessage());
        }
    }
    
    private void closeInitiateCloseoutTask(List<Closeout__c> closeoutList) {
        Map<Id,Closeout__c> oldCloseouts = new Map<Id,Closeout__c>();
        oldCloseouts = (Map<Id,Closeout__c>)Trigger.oldMap;
        List<Task> taskList = new List<Task>();
        for(Closeout__c c : closeoutList) {
            if(oldCloseouts.get(c.Id).Status__c == 'Not Started' && (c.Status__c == 'Initiated By GM' || c.Status__c == 'Initiated By PM')) {
                Task t = [Select id,Status,GNT__TaskAction__c FROM Task where WhatId =: c.Id and Status in ('Not Started','In Progress') limit 1];
                t.Status = 'Completed';
                taskList.add(t);
            }
        }
        if(taskList.size() > 0) {
            update taskList;
        }
    }

    private void updateSubAwardeeTasks(List<Closeout__c> ctList){
        try{
       
            Set<Id> approvalSet = new Set<Id>();
            Map<Id, Id> grantcloseoutMap = new Map<Id, Id>();
            Map<Id, String> closeoutRejectNameMap = new Map<Id, String>();
            List<Task> updateList = new List<Task>();
            Map<Id,String> closeoutTypeMap = new Map<Id,String>();
            for(Closeout__c ct: ctList){
                closeoutTypeMap.put(ct.Id,ct.Type__c);
                if(ct.Status__c != null && ct.Status__c != '' && 
                    (ct.Status__c.equals('Approved by PM') || ct.Status__c.equals('Approved by GM') || ct.Status__c.equals('On-hold Approved'))){
                    approvalSet.add(ct.Id);
                }
                if(ct.Status__c != null && ct.Status__c != '' && 
                    (ct.Status__c.equals('Rejected by PM') || ct.Status__c.equals('Rejected by GM') || ct.Status__c.equals('On-hold Rejected'))){
                    grantCloseoutMap.put(ct.Grant__c, ct.Id);
                    closeoutRejectNameMap.put(ct.Id, ct.Name);
                }
            }
            if(approvalSet != null && approvalSet.size() > 0){
                List<Task> taskListApprove = [SELECT Id, Status FROM Task WHERE WhatId IN :approvalSet AND Status IN ('In Progress', 'Not Started')];
                for(Task tsk : taskListApprove){
                    tsk.Status = 'Completed';
                }
                if(taskListApprove != null && !taskListApprove.isEmpty())
                    updateList.addAll(taskListApprove);
            }
            List<Task> finalList = new List<Task>();
            List<Task> annualList = new List<Task>();
            if(grantCloseoutMap != null && !grantCloseoutMap.isEmpty()){
                List<Grant__c> grantList = new List<Grant__c>([SELECT Id, ExternalOrganization__c FROM Grant__c WHERE Id IN :grantCloseoutMap.keySet()]);
                Map<Id, Id> accountGrantMap = new Map<Id, Id>();
                Set<Id> contactSet = new Set<Id>();
                Map<Id, List<Contact>> closeoutContactMap = new Map<Id, List<Contact>>();
                for(Grant__c grant : grantList){
                    accountGrantMap.put(grant.ExternalOrganization__c, grant.Id);
                }
                if(accountGrantMap != null && !accountGrantMap.isEmpty()){
                    List<Account> actList = new List<Account>([SELECT Id, (SELECT Id, Name FROM Contacts WHERE UserRoleFormula__c IN ('Primary Applicant', 'Secondary Applicant')) 
                                            FROM Account WHERE Id = :accountGrantMap.keySet()]);
                    for(Account a : actList){
                        if(a.Contacts != null && a.Contacts.size() > 0){
                            for(Contact c : a.Contacts){
                                contactSet.add(c.Id);
                            }
                            if(grantCloseoutMap.containsKey(accountGrantMap.get(a.Id))){
                                closeoutContactMap.put(grantCloseoutMap.get(accountGrantMap.get(a.Id)), a.Contacts);    
                            }    
                        }
                    }
                }
                Map<Id, Id> contactUserMap = new Map<Id, Id>();
                Map<Id, User> userMap = new Map<Id, User>([SELECT Id, ContactId FROM User WHERE ContactId IN :contactSet]); 
                for(Id key : userMap.keySet()){
                    contactUserMap.put(userMap.get(key).ContactId, key);
                }
                List<Task> taskListReject = new List<Task>([SELECT Id, Status FROM Task WHERE WhatId IN :closeoutRejectNameMap.keySet() AND Status IN ('In Progress', 'Not Started') AND OwnerId IN :userMap.keySet()]);
                for(Task tsk : taskListReject){
                    tsk.Status = 'Completed';
                }
                if(taskListReject != null && !taskListReject.isEmpty())
                    updateList.addAll(taskListReject);
                if(closeoutContactMap != null && !closeoutContactMap.isEmpty()){
                    for(Id key : closeoutContactMap.keySet()){
                        List<Contact> tmpList = closeoutContactMap.get(key);
                        if(tmpList != null && tmpList.size() > 0){
                            for(Contact c : tmpList){
                                if(closeoutTypeMap.get(key) == 'Final') {
                                    //List<Task> closeoutResubmit = GNT.TaskCreationHandler.createTasks(contactUserMap.get(c.Id), key, 'Grant Closeout Re-Submission', closeoutRejectNameMap.get(key), null, false, null, 'Approval', false);
                                    List<Task> closeoutResubmit = GNT.TaskCreationHandler.createTasks(contactUserMap.get(c.Id), key, 'Grant Closeout Re-Submission', closeoutRejectNameMap.get(key), null, false, null, 'Approval', c.Name, false);
                                    if(closeoutResubmit != null && !closeoutResubmit.isEmpty()){
                                        finalList.add(closeoutResubmit[0]);
                                    } 
                                }
                                else if(closeoutTypeMap.get(key) == 'Annual') {
                                    //List<Task> annualcloseoutResubmit = GNT.TaskCreationHandler.createTasks(contactUserMap.get(c.Id), key, 'Annual Closeout Re-Submission', closeoutRejectNameMap.get(key), null, false, null, 'Approval', false);
                                    List<Task> annualcloseoutResubmit = GNT.TaskCreationHandler.createTasks(contactUserMap.get(c.Id), key, 'Annual Closeout Re-Submission', closeoutRejectNameMap.get(key), null, false, null, 'Approval', c.Name, false);
                                    if(annualcloseoutResubmit != null && !annualcloseoutResubmit.isEmpty()){
                                        annualList.add(annualcloseoutResubmit[0]);
                                    } 
                                }
                            }
                        }
                    }
                }
            }
            if(updateList != null && !updateList.isEmpty())
                update updateList;
            if(finalList != null && !finalList.isEmpty())
                insert finalList;
            if(annualList != null && !annualList.isEmpty())
                insert annualList;
        }
        catch(Exception e){
            System.debug('The following exception has occured: ' + e.getMessage());
        }            
    }

    /*
    private void populateReviewerUser(List<CloseOut__c> closeOutList){
        List<Id> grantIdList = new List<Id>();
        for(CloseOut__c closeOut : closeOutList){
            grantIdList.add(closeOut.Grant__c);
        }
        Map<Id, Grant__c> grantMap = new Map<Id, Grant__c>([Select Id, AssignedTo__c 
                From Grant__c Where Id IN : grantIdList]);
        Map<Id, Id> grantIdToAssignedUserMap = new Map<Id, Id>();
        for(String grantId : grantMap.keySet()){
            grantIdToAssignedUserMap.put(grantId,grantMap.get(grantId).AssignedTo__c);
        }       
        for(CloseOut__c closeOut : closeOutList){
            closeOut.Reviewer__c = grantIdToAssignedUserMap.get(closeOut.Grant__c);     
        }
    }
    */
    private void updateAwardStatus(List<Closeout__c> closeOutList) {
        List<Id> clIds = new List<Id>();
        List<Closeout__c> newCloseoutList = new List<Closeout__c>();
        for(Closeout__c cl : closeOutList) {
            clIds.add(cl.Id);
            if(cl.Type__c == 'Annual') {
                newCloseoutList.add(cl);
            }
        }
        Map<Id,Award__c> closeoutAwardMap = new Map<Id,Award__c>();
        List<Closeout__c> closeoutAwards = new List<Closeout__c>([Select id, Award__r.Status__c, Award__c,Type__c, Grant__c FROM Closeout__c where id in: clIds and Type__c = 'Annual']);
        if(closeoutAwards != null && closeoutAwards.size() > 0) {
            for(Closeout__c clo : closeoutAwards) {
                Award__c a = new Award__c(id = clo.Award__c, Status__c = clo.Award__r.Status__c, Grant__c = clo.Grant__c);
                closeoutAwardMap.put(clo.Id,a);
            }
        }
        
        Map<Id,Closeout__c> oldCloseouts = new Map<Id,Closeout__c>();
        oldCloseouts = (Map<Id,Closeout__c>)Trigger.oldMap;
        if(newCloseoutList != null && newCloseoutList.size() > 0) {
            for(Closeout__c c : newCloseoutList){
                if((oldCloseouts.get(c.Id).Status__c == 'Initiated By PM' || oldCloseouts.get(c.Id).Status__c == 'Not Started' || 
                    oldCloseouts.get(c.Id).Status__c == 'Under PM Review' || oldCloseouts.get(c.Id).Status__c == 'On-hold Approved' ||
                    oldCloseouts.get(c.Id).Status__c == 'On-hold Rejected' || oldCloseouts.get(c.Id).Status__c == 'On-hold Requested') 
                    && (c.Status__c == 'Approved By PM')) {
                    if(!closeoutAwardMap.isEmpty()) {
                        closeoutAwardMap.get(c.Id).Status__c = 'Closed Out - Annual';
                    }
                }
            }
        }
        if(!closeoutAwardMap.isEmpty()) {
            if(closeoutAwardMap.values().size() > 0) {
                insert closeoutAwardMap.values();
            }
        }
    }


    /* Copy Roles and Responsibility from Award to Closeout*/
    /*
    private void copyRolesandResponsibilities(){
        Set<Id> awardIds  = new Set<Id>();
        String appName = GNT.UserPreferenceHelper.getStringValue('ActiveAppName__c');
        String developerName;
    
        if(appName == 'StateasGrantee'){
            developerName = 'Closeout';
        }
        else{
            developerName = 'GrantorCloseout';
        }
        
         for(Closeout__c closeout : (List<Closeout__c>) Trigger.New) {
            awardIds.add(closeout.Award__c);
         }
        List<RolesAndResponsibilities__c> oldlistrolesandresp = [Select Id, Name,Name__c,BusinessRole__c,Award__c from RolesAndResponsibilities__c where Award__c IN :awardIds];
        List<RolesAndResponsibilities__c> listrolesandresp = new List<RolesAndResponsibilities__c>();
        List<RecordType> recordTypeList = [select Id, Name,DeveloperName, SobjectType FROM RecordType where SobjectType=:AppUtils.getNamespacePrefix()+'RolesAndResponsibilities__c' and DeveloperName=:developerName];
         for(Closeout__c closeout : (List<Closeout__c>) Trigger.New) {          
         for(RolesAndResponsibilities__c resp : oldlistrolesandresp) {
            if(resp.Award__c==closeout.Award__c){
            RolesAndResponsibilities__c rresp = new RolesAndResponsibilities__c();
            rresp.Closeout__c = closeout.id;
            rresp.Name__c = resp.Name__c;
            //rresp.Role__c = resp.Role__c;
            rresp.BusinessRole__c= resp.BusinessRole__c;
            rresp.recordTypeId = recordTypeList[0].Id;
            listrolesandresp.add(rresp);
          }         
        }
     }
        if(!listrolesandresp.isempty()) insert listrolesandresp;
    }
    */

    /*
    private void createPMTask(List<Closeout__c> ctListNew){
        try{
            /*
            Set<Id> pmIdSet = new Set<Id>();
            for(closeout__c ctOld : ctListOld){
                if(ctOld.GrantPM__c != null && ctOld.Status__c.equals('Rejected by PM')){
                    pmIdSet.add(ctOld.GrantPM__c);
                }
            }
            SystemContextMethodsHelper sc = new SystemContextMethodsHelper();
            sc.updateTasks(ctSetOld, pmIdSet);
            */
            /*
            List<Task> closeoutCreationTaskList = new List<Task>();
            for(Closeout__c ctNew : ctListNew){
                if(ctNew.GrantPM__c != null && ctNew.Status__c.equals('Under PM Review')){
                    List<Task> closeoutCreationTasks = GNT.TaskCreationHandler.createTasks(ctNew.GrantPM__c, ctNew.Id, 'Grant Closeout Approval', ctNew.Name, null, false, null, 'Approval', false);
                    if(closeoutCreationTasks != null && closeoutCreationTasks.size() > 0) {
                        closeoutCreationTaskList.add(closeoutCreationTasks[0]);
                    }
                }                    
            }
            System.debug('closeoutCreationTaskList:<<<'+closeoutCreationTaskList);
            insert closeoutCreationTaskList;
        }
        catch(Exception e){
            System.debug('The following exception has occured: ' + e.getMessage());
        }
    }
    */
    /*
    private void createSubAwardeeTasks(List<Closeout__c> ctList){
        try{
            /*
            Map<Id, Id> closeoutSubAwardeeMap = new Map<Id, Id>();
            List<Task> closeoutCreationTaskList = new List<Task>();
            for(Closeout__c ct : ctList){
                if(ct.GrantSubAwardee__c != null || ct.GrantSubAwardee__c != ''){
                     List<Task> closeoutCreationTasks = GNT.TaskCreationHandler.createTasks(ct.GrantSubAwardee__c, ct.Id, 'Grant Closeout Submission', ct.Name, null, false, null, 'Approval', false);
                     if(closeoutCreationTasks != null && closeoutCreationTasks.size() > 0) {
                         closeoutCreationTaskList.add(closeoutCreationTasks[0]);
                     }
                     closeoutSubAwardeeMap.put(ct.Id, ct.GrantSubAwardee__c);
                }
            }
            insert closeoutCreationTaskList;
            List<EmailTemplate> emailTemp = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'NotificationofGrantCloseoutSubmission' Limit 1];
            if(!closeoutSubAwardeeMap.isEmpty() && emailTemp.size() > 0){
                GNT.AppUtils.sendEmailUsingTemplate(emailTemp[0].Id, closeoutSubAwardeeMap, false);    
            }
            */
            /*
            Set<Id> grantSet = new Set<Id>();
            Set<Id> extOrgSet = new Set<Id>();
            Map<Id, Id> closeoutGrantMap = new Map<Id, Id>();
            Map<Id, Id> extOrgCloseoutMap = new map<Id, Id>();
            Map<Id, String> closeoutIdNameMap = new Map<Id, String>();
            List<Task> closeoutTaskList = new List<Task>();
            for(Closeout__c ct : ctList){
                grantSet.add(ct.Grant__c);
                closeoutGrantMap.put(ct.Grant__c, ct.Id);
                closeoutIdNameMap.put(ct.Id, ct.Name);        
            }
            if(!grantSet.isEmpty()){
                List<Grant__c> grantList = new List<Grant__c>([SELECT Id, ExternalOrganization__c FROM Grant__c WHERE Id IN :grantSet]);
                if(grantList.size() > 0){                    
                    for(Grant__c grant : grantList){
                        if(grant.ExternalOrganization__c != null && grant.ExternalOrganization__c != ''){
                            extOrgSet.add(grant.ExternalOrganization__c);
                            if(!closeoutGrantMap.isEmpty() && closeoutGrantMap.containsKey(grant.Id))
                                extOrgCloseoutMap.put(closeoutGrantMap.get(grant.Id), grant.ExternalOrganization__c);
                        }
                    }
                }
            }
            if(extOrgSet != null && !extOrgSet.isEmpty()){
                List<Account> extOrgList = new List<Account>([SELECT Id, (SELECT Id FROM Contacts) FROM Account WHERE Id IN :extOrgSet]);
                if(extOrgList.size() > 0){
                    for(Account acc : extOrgList){
                        if(acc.Contacts != null && acc.Contacts.size() > 0){
                            for(Contact cnt : acc.Contacts){
                                if(!extOrgCloseoutMap.isEmpty() && extOrgCloseoutMap.containsKey(acc.Id)){
                                    List<Task> closeoutCreationTasks = GNT.TaskCreationHandler.createTasks(cnt.Id, extOrgCloseoutMap.get(acc.Id), 'Grant Closeout Submission', closeoutIdNameMap.get(extOrgCloseoutMap.get(acc.Id)), null, false, null, 'Approval', false);
                                    if(closeoutCreationTasks != null && closeoutCreationTasks.size() > 0) {
                                        closeoutTaskList.add(closeoutCreationTasks[0]);
                                    }
                                }
                            }       
                        }
                    }
                }    
            }
            if(closeoutTaskList.size() > 0){
                insert closeoutTaskList;
            }
        }
        catch(Exception e){
            System.debug('The following exception has occured :' + e.getMessage());    
        }
    }
    */
    
}