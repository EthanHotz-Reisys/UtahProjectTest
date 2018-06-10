/*
    All trigger logic on Program Object
    **********************************************************
    Audit History
    
    **********************************************************
    2014-02-26         Kunal Shah            Created 
    
    **********************************************************  
*/
public with sharing class ProgramTriggerHelper extends GNT.TriggerHelper{
    public static boolean skipTrigger = false;
    private Map<Id,String> recordIdNameMap = new Map<Id,String>();
    public override void processBeforeInsert(){
        if (skipTrigger==false) {
        GNT.NameTemplateTriggerHelper.beforeInsert();               
        }
        shareWithInternalUsers(Trigger.new);
        checkGovGrantsKey(Trigger.new);
    }               
    
    public override void processAfterInsert() {
        if (skipTrigger==false) {         
            //Logic to create Review Step Templates, Review Panels for Grantor Programs
            Map<Id,RecordType> recordIdMap = new  Map<Id,RecordType>([Select Id,Name from RecordType where sObjectType =:'Program__c']);
            for(String Key:recordIdMap.keyset()){
                recordIdNameMap.put(key, recordIdMap.get(key).Name); 
            }                                       
            List<Program__c> programList = new List<Program__c>();
            for(Program__c prg: (List<Program__c>)Trigger.new){
                if(recordIdNameMap.get(prg.RecordTypeId)=='Internal Program'){
                   programList.add(prg); 
                }         
            }
            createProgramSpecificRSTemplates(programList); 
            addDefaultPackages(programList);
            InsertBudgetPerioddates(programList);  
            insertOwnerinRolesandResp(programList);
            insertOwnerinProgramContact(programList);              
        }
        shareWithExe(Trigger.new); 
    }

     public override void processBeforeUpdate() {
        updateShareWithInternalUsers();
        //createSentToOwnerGratorTask();
        checkGovGrantsKey(Trigger.new);
     }
    
    public override void processAfterUpdate(){
        if (skipTrigger==false){
            //deleteApprovalProcess();
        }              
    }
    
    public void createProgramSpecificRSTemplates(List<Program__c> programlst){
        List<ReviewStepTemplate__c> lstRST = [
            SELECT Id,Name,StepNumber__c,Description__c 
            FROM ReviewStepTemplate__c
            WHERE DefaultStep__c=true AND CustomAppName__c='StateasGrantor' AND Announcement__c=null AND Program__c=null];
            System.debug('lstRST: ' + lstRST);
        GNT__PageTemplate__c rsLayoutForStep123 = [Select id From GNT__PageTemplate__c Where Name = :GNT.KeyValueStoreHelper.getTextValue('RST_Step123Layout', true)];
        GNT__PageTemplate__c rsLayoutForStep4 = [Select id From GNT__PageTemplate__c Where Name = :GNT.KeyValueStoreHelper.getTextValue('RST_StepLayout4', true)];
        GNT__PageTemplate__c panelLayout = [Select id From GNT__PageTemplate__c Where Name = :GNT.KeyValueStoreHelper.getTextValue('RST_PanelLayout', true)];
      //  GNT__Package__c prescreenPackage = [Select Id From GNT__Package__c Where Name = :GNT.KeyValueStoreHelper.getTextValue('RST_PrescreenReviewPackage', true)];
      //  GNT__Package__c externalPackage = [Select Id From GNT__Package__c Where Name = :GNT.KeyValueStoreHelper.getTextValue('RST_ExternalReviewPackage', true)];
      //  GNT__Package__c internalPackage = [Select Id From GNT__Package__c Where Name = :GNT.KeyValueStoreHelper.getTextValue('RST_InternalReviewPackage', true)];
      // Test debug statements which can be removed 
        EmailTemplate approvalTemplate = [Select DeveloperName From EmailTemplate Where DeveloperName = :GNT.KeyValueStoreHelper.getTextValue('RST_ApplicationPromotedEmail', true) LIMIT 1];       
        EmailTemplate rejectionTemplate = [Select DeveloperName From EmailTemplate Where DeveloperName = :GNT.KeyValueStoreHelper.getTextValue('RST_ApplicationRejectionEmail', true) LIMIT 1];
        String approvalTempName = approvalTemplate.DeveloperName;
        String rejectionTempName = rejectionTemplate.DeveloperName;
        List<ReviewStepTemplate__c> rstList = new List<ReviewStepTemplate__c>();
        List<ReviewPanelTemplate__c> rptList = new List<ReviewPanelTemplate__c>();
      //  Id rsLayoutId = rsLayoutForStep123.Id;
        Id rsLayoutId = rsLayoutForStep123.Id;
        for(Program__c prog : (List<Program__c>)trigger.new){ //
            for(ReviewStepTemplate__c rstObj : lstRST){             
                if (prog.ReviewProcess__c == 'One step review' && (rstObj.StepNumber__c == 1 || rstObj.StepNumber__c == 4)) { //This is a one-step review process, so only create the Prescreen and FDM review step templates
                    // create review step template
                    ReviewStepTemplate__c rst = createReviewStepTemplate(prog.Id,rstObj.Name,rstObj.Description__c ,rsLayoutId,Integer.valueOf(rstObj.StepNumber__c),  approvalTempName, rejectionTempName);
                    rstList.add(rst);
                }
                else if (prog.ReviewProcess__c != null && prog.ReviewProcess__c == 'No Review') {
                    continue;
                }
                else if (prog.ReviewProcess__c == null || prog.ReviewProcess__c == 'Three step review') {
                    // create review step template
                    ReviewStepTemplate__c rst = createReviewStepTemplate(prog.Id,rstObj.Name,rstObj.Description__c ,rsLayoutId,Integer.valueOf(rstObj.StepNumber__c),  approvalTempName, rejectionTempName);
                    rstList.add(rst);
                }
            }               
        }        
        insert rstList;
        for(ReviewStepTemplate__c rst : rstList){
            if(rst.StepNumber__c != 4){
                ReviewPanelTemplate__c rpt = createReviewPanelTemplate(rst, panelLayout.Id);
                rptList.add(rpt);
           }
        }        
        insert rptList; 
    }       
    
      private void addDefaultPackages(List<Program__c> lstPrograms){           
        List<BusinessPackage__c> programDefPack = new List<BusinessPackage__c>();
        List<BusinessPackage__c> defaultPackList = [
            Select GrantorOrgWideDefault__c,ApplicationName__c,PackageConfig__c,PackageType__c  
            from BusinessPackage__c 
            where PackageType__c in('App-Review') and ApplicationName__c=:'StateAsGrantor' and GrantorOrgWideDefault__c=:true ];

        List<BusinessPackage__c> defaultPackListOneStepApproval = [
            SELECT GrantorOrgWideDefault__c,ApplicationName__c,PackageConfig__c,PackageType__c  
            FROM BusinessPackage__c 
            WHERE PackageType__c IN('Application Review Package One Step') AND ApplicationName__c=:'StateAsGrantor' AND UniquePackageName__c = 'OneStepReviewPackage'];
            
        if( defaultPackList != null || defaultPackListOneStepApproval != null ){  // removing the Size check when moved to new org  && defaultPackList.size()==5
            for (Program__c prog: lstPrograms) {
                if (prog.OrganizationName__c == 'USBE' && prog.ReviewProcess__c == 'One step review') {
                    for(BusinessPackage__c pack: defaultPackListOneStepApproval){           
                        BusinessPackage__c defaultPack = new BusinessPackage__c();
                        defaultPack.Program__c = prog.Id;
                        defaultPack.PackageConfig__c = pack.PackageConfig__c;
                        defaultPack.PackageType__c  = pack.PackageType__c; 
                        programDefPack.add(defaultPack);       
                    }  
                }
                else if (prog.OrganizationName__c == 'USBE' && prog.ReviewProcess__c == 'No Review') {
                    continue;
                }
                else {
                    for(BusinessPackage__c pack: defaultPackList){           
                        BusinessPackage__c defaultPack = new BusinessPackage__c();
                        defaultPack.Program__c = prog.Id;
                        defaultPack.PackageConfig__c = pack.PackageConfig__c;
                        defaultPack.PackageType__c  = pack.PackageType__c; 
                        programDefPack.add(defaultPack);       
                    }           
                }
            }
            insert programDefPack;
        }  
    } 
        
    public ReviewStepTemplate__c createReviewStepTemplate(Id recordId, String name, String description ,Id revStepTemplateId,Integer stepNumber,  String approvalTemplate, String rejectionTemplate){        
        ReviewStepTemplate__c rst =  new ReviewStepTemplate__c();
        rst.ReviewLevelAcceptance__c = false;
        rst.UserType__c = 'Internal';
        rst.Name =name;
        rst.StepNumber__c = stepNumber;
        rst.RecordTypeId = Schema.SObjectType.ReviewStepTemplate__c.getRecordTypeInfosByName().get('Application').getRecordTypeId();
        rst.Description__c=description;
        rst.Program__c = recordId;
        rst.ReviewStepLayout__c = revStepTemplateId;
        rst.RejectionEmailTemplate__c = rejectionTemplate;
        rst.ApprovalEmailTemplate__c = approvalTemplate;
        rst.PanelHeadAssignNotificationTemplate__c = 'NotificationofPanelAssignment';
        return rst;
    }

    public ReviewPanelTemplate__c createReviewPanelTemplate(ReviewStepTemplate__c rst, Id panelLayoutId){
        ReviewPanelTemplate__c rpt = new ReviewPanelTemplate__c();
        rpt.RecordTypeId = Schema.SObjectType.ReviewPanelTemplate__c.getRecordTypeInfosByName().get('Application').getRecordTypeId();
        rpt.name = rst.name + ' Panel';
        rpt.Chair__c = UserInfo.getUserId();
        rpt.Sequence__c = 1;
        rpt.ReviewStepTemplate__c = rst.Id;
        rpt.IsDefaultPanel__c=true;
        rpt.ReviewFormConfig__c = rst.ReviewFormConfig__c;
        rpt.Description__c='Panel created for ' + rst.Description__c;
        rpt.PanelLayout__c = panelLayoutId;
        rpt.EndDate__c = System.Today() + 7;
        rpt.Purpose__c = rst.name +' Description';        
        if(rst.StepNumber__c == 2){
            rpt.UserType__c = 'External';
            rpt.ExcludeFromScoring__c = false;
        }else{
            rpt.UserType__c = 'Internal';
            rpt.ExcludeFromScoring__c = true;
        }
        return rpt;
    }
    
    /*Insert BudgetPeriod Records Based on Project Period Start Date and Project period End date*/
    private void InsertBudgetPerioddates(List<Program__c> lstPrograms){    
        List<BudgetPeriod__c> lstbp = new List<BudgetPeriod__c>();
        for(Program__c program : (List<Program__c>) lstPrograms){
            if (program.OrganizationName__c == 'USBE') {
                BudgetPeriod__c budgetPeriod = new BudgetPeriod__c();
                budgetPeriod.SupportYear__c = 'BP-01';
                budgetPeriod.BudgetStartDate__c = program.StartDate__c;
                budgetPeriod.BudgetEndDate__c = program.EndDate__c;
                budgetPeriod.SequenceNumber__c = 0;
                budgetPeriod.Program__c = program.id;
                lstbp.add(budgetPeriod);           
            }
            else {
                Date a = program.StartDate__c;
                Date b = program.EndDate__c;
                Date dtStart = a; 
                Date dtEnd = dtStart.adddays(365);
                Integer i=0;        
                while(dtEnd < = b){
                    BudgetPeriod__c bperiod = new  BudgetPeriod__c();
                    i=i+1;
                    if(i<=9){
                        bperiod.SupportYear__c = 'BP-0'+i;
                    }
                    else{
                        bperiod.SupportYear__c = 'BP-'+i;   
                    }
                    bperiod.Program__c = program.id;
                    //bperiod.Name = 'BP-'+program.FederalProgramCFDA__c+'-'+ dtEnd.Year();
                    bperiod.BudgetStartDate__c = dtStart;
                    bperiod.BudgetEndDate__c = dtEnd;
                    bperiod.SequenceNumber__c = i;
                    if(i==1){
                        bperiod.Status__c='Active';
                    }
                    lstbp.add(bperiod);
                    dtStart = dtEnd.addDays(1);
                    dtEnd = dtStart.adddays(365);
                }              
                if(dtStart<=b){ 
                    i=i+1; 
                    BudgetPeriod__c bperiod = new BudgetPeriod__c();
                    if(i<=9){
                        bperiod.SupportYear__c = 'BP-0'+i;
                    }
                    else{
                        bperiod.SupportYear__c = 'BP-'+i;   
                    }  
                    bperiod.Program__c = program.id;
                    // bperiod.Name = 'BP-'+program.FederalProgramCFDA__c+'-'+ dtEnd.Year(); 
                    bperiod.SequenceNumber__c = i;
                    if(i==1){
                        bperiod.Status__c='Active';
                    }
                    bperiod.BudgetStartDate__c = dtStart;
                    bperiod.BudgetEndDate__c = b;

                    lstbp.add(bperiod);
                }
            }            
        }    
    if(!lstbp.isempty()) 
        insert lstbp;
  }
  /* Insert owner of Award in Roles and Responsibility*/
    
      private void insertOwnerinRolesandResp(List<Program__c> programList){
        List<RolesAndResponsibilities__c> listrolesandresp = new List<RolesAndResponsibilities__c>();
        List<RecordType> recordTypeList = [select Id, Name,DeveloperName, SobjectType FROM RecordType where SobjectType=:AppUtils.getNamespacePrefix()+'RolesAndResponsibilities__c' and DeveloperName='Program'];
         for(Program__c program : (List<Program__c>) programList) {
                RolesAndResponsibilities__c rresp = new RolesAndResponsibilities__c();
                rresp.Program__c = program.id;
                rresp.Name__c = program.CreatedById;
                //rresp.Role__c = 'Other';
                rresp.BusinessRole__c= 'Owner';
                rresp.recordTypeId = recordTypeList[0].Id;
                listrolesandresp.add(rresp);            
        }         
        if(!listrolesandresp.isempty()){         
            insert listrolesandresp;
        }
    }

        private void deleteApprovalProcess() {
    List<Id> sentToOwnerProgramIds = new List<Id>();
    
    Map<Id, Program__c> oldPgm = (Map<Id, Program__c>)Trigger.oldMap;
    for(Program__c newPgmVal: (List<Program__c>)Trigger.new){
    if(newPgmVal.Status__c == 'Change Requested' && oldPgm.get(newPgmVal.Id).Status__c == 'Submitted for Approval') {
    Approval.ProcessWorkItemRequest pwr = new Approval.ProcessWorkItemRequest();
    List<ProcessInstance> procins = new List<ProcessInstance>([select Id from ProcessInstance where Status = 'Pending' and TargetObjectId = :newPgmVal.Id]);
    // Retrieve the process work instance id associated to the process instance
            List<ProcessInstanceWorkitem>  workitem = new List<ProcessInstanceWorkitem>([select Id from ProcessInstanceWorkitem where ProcessInstanceId = :procins[0].id]);
            if ((workitem != null) && (workitem.size() > 0))
            {
                pwr.SetComments('statusToUpdate');

                pwr.setWorkItemId(workitem[0].id);
                pwr.setAction('Removed'); 
                // Execute process request
                Approval.ProcessResult pr = Approval.process(pwr);
    }
    }
    }
    }
     //This method will be called after recall functionality.
    /*private void createSentToOwnerGratorTask() {
        List<Id> sentToOwnerProgramIds = new List<Id>();
        List<Task> appTaskList = new List<Task>();
        Map<Id, Program__c> oldPgm = (Map<Id, Program__c>)Trigger.oldMap;

        for(Program__c newPgmVal: (List<Program__c>)Trigger.new){
            if(newPgmVal.Status__c == 'Created' && oldPgm.get(newPgmVal.Id).Status__c == 'Change Requested') {
                sentToOwnerProgramIds.add(newPgmVal.Id);
                newPgmVal.Status__c = 'Change Requested';
            }
        }
        for(Id pgmId : sentToOwnerProgramIds) {
            appTaskList.add( GNT.TaskCreationHandler.createTasks(oldPgm.get(pgmId).OwnerId, pgmId, 'Program Sent To Owner', oldPgm.get(pgmId).Name, null, false, null, 'Other', oldPgm.get(pgmId).ProgramName__c, false).get(0));                
        }
        if(Schema.sObjectType.Program__c.isCreateable()){
            insert appTaskList;     
        }
        System.debug('appTaskList--------------------------->' + appTaskList);

    } */ 

     private void shareWithInternalUsers(List<Program__c> lstPrograms){
        for(Program__c prg: lstPrograms){ 
            prg.ProgGroupCode__c =prg.ProgramGroupCode__c;
        }          
    }   

    private void updateShareWithInternalUsers(){
        for(Program__c prog: (List<Program__c>) Trigger.new){
            Program__c oldProg = (Program__c) Trigger.oldMap.get(prog.Id);
              if(prog.ProgramGroupCode__c!=oldProg.ProgramGroupCode__c){
                prog.ProgGroupCode__c = prog.ProgramGroupCode__c;
              }           
        }          
    }
    
    private void shareWithExe(List<Program__c> lstPrograms){
        List<Program__Share> shares = new List<Program__Share>();
        List<User> exeList = [SELECT Id FROM User WHERE Profile.Name = 'EXE' AND IsActive = TRUE];
        
        for (Program__c program : lstPrograms){
            for (User exe : exeList){
                shares.add(new Program__Share(parentId = program.id, AccessLevel = 'Edit', UserOrGroupId = exe.Id, RowCause = Schema.Program__Share.RowCause.SharingForEXE__c));
            }
        }
        
        SystemContextMethodsHelper SystemContextMethodsHelper = new SystemContextMethodsHelper();
        SystemContextMethodsHelper.updatePrograms(shares); 
    }
    
      /* When the program is approved copy the name of Agency from Formula to Text for Internal and NGO programs */
    //private void copyAgencyNameToTextField(){
        
    //    Map<Id,RecordType> recordIdMap = new  Map<Id,RecordType>([Select Id,Name from RecordType where sObjectType =:'Program__c']);
    //    for(String Key:recordIdMap.keyset()){
    //            recordIdNameMap.put(key, recordIdMap.get(key).Name); 
    //    }
        
    //    for(Program__c prg: (List<Program__c>)Trigger.new){
             
    //          Program__c oldProg = (Program__c)Trigger.oldMap.get(prg.Id);
    //          Program__c newProg = (Program__c)Trigger.newMap.get(prg.Id);
             
    //         if((recordIdNameMap.get(prg.RecordTypeId)=='Internal Program' || recordIdNameMap.get(prg.RecordTypeId)=='NGO Program') &&
    //            (oldProg.Status__c != 'Approved' && newProg.Status__c == 'Approved')){
    //            prg.InternalOrganization__c = prg.OrganizationName__c;                      
    //        }        
    //    } 
    //}
    
    private void insertOwnerinProgramContact(List<Program__c> programList){
        List<ProgramContacts__c> programContact = new List<ProgramContacts__c>();
        List<Id> programOwnerIds = new List<Id>();
        Map<Id,Id> userToContact = new Map<Id,Id>();
        for(Program__c program: programList){
            programOwnerIds.add(program.CreatedById);
        }
        List<Contact> contactsList = [Select id,UserReference__c from Contact where UserReference__c = :programOwnerIds];
        for(Contact contactSingle : contactsList){
            userToContact.put(contactSingle.UserReference__c,contactSingle.Id);
        }
        for(Program__c program : programList){
            ProgramContacts__c progCont = new ProgramContacts__c();
            progCont.Program__c = program.Id;
            progCont.Contact__c = userToContact.get(program.CreatedById);
            programContact.add(progCont);
        }
        if(!programContact.isempty()){
            insert programContact;
        }
    }

    private void checkGovGrantsKey(List<Program__c> programnew) {
        Set<String> keySet = new Set<String>();
        Set<Id> programIds = new Set<Id>();
        for (Program__c program : programnew){
            if (program.ProgramKey__c != null){
                keySet.add(program.ProgramKey__c);
            }
            programIds.add(program.Id);
        }
        List<Program__c> programList = [Select Id,ProgramKey__c from Program__c where ProgramKey__c IN: keySet AND Id NOT IN: programIds];
        for (Program__c program : programList){
            for (Program__c newProgram : programnew){
                if (program.ProgramKey__c == newProgram.ProgramKey__c){
                    newProgram.addError('The GovGrants program key already exists please enter a unique value');
                }
            }
        }
    }
}