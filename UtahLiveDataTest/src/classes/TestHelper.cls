/*
    Used to setup test records for other test classes. It has several create() methods for
    various objects which can be used by individual controller and other classes 
    for testing purposes. It is recommended to have all data creation happens in this 
    class and let other classes use it by invoking them.
    
    *************************************************************************************************
    Audit History
    **************************************************************************************************
    2/24/2014        Manasi Gangal              Added few methods to create test data for Sidebar Component
    2/25/2014        Prem Pal                   Added few methods to create test data for FlextTable Component
    4/14/2014        Nakul Kadam                Added methods to create test data for GNT__ChartConfig__c, FundingSource, FundingSourceYear & updated getPhase()
    4/17/2014        Hafsa Syed                 Moved test data methods from PlanningChartsControllerTest.cls
    5/28/2014        Hafsa Syed                 Added getBusinessRuleConfig method
    5/29/2014        Ryan Chadiwck              Fixed getAnnouncment()
    6/20/2014        Ryan Chadwick              added getWorkItem, getTask, getAssignedTasks, getUnassignedTasks
    8/15/2014        Raghav Mehta               added getHelpConfig, getPackageMandatoryField, getThemeConfig, getTaskActionSummary, getTaskFieldMapping methods
    **************************************************************************************************************  
Deployment testing - Pankaj test Pankaj


*/
//Weike add @isTest(SeeAllData = true) make it not count in code coverage
@isTest(SeeAllData = true)
global  class TestHelper {
    //get admin user
    global static User getAdminUser(boolean create)
    {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        User u = new User(Alias = 'admtp', Email='sysAdmin@govbd.dev', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id,ManagerId=getStandardUser(true).Id, 
            TimeZoneSidKey='America/New_York', UserName='sysAdmin'+Math.random()+'@govbd.dev');
        if(create)
            insert u;
        return u;
        
    }

    global static User getAdminUserDept(boolean create)
    {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        User u = new User(Alias = 'admtp', Email='sysAdmin@govbd.dev', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/New_York', UserName='sysAdmin'+Math.random()+'@govbd.dev');
        if(create)
            insert u;
        return u;
    }
    
    global static User getStandardUser(boolean create)
    {
        system.debug('Inside getStandardUser method');
        Profile p = [SELECT Id,Name FROM Profile WHERE Name = 'Standard User'];
        User u = new User(Alias = 'standt', Email='standarduser@govbd.dev', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, ProfileName__c=p.Name,
            TimeZoneSidKey='America/New_York', UserName='standarduser'+Math.random()+'@govbd.dev');
        system.debug('**user u--'+u);
        if(create)
            insert u;
        return u;
    }
    
   global static GNT__TaskConfig__c getTaskConfig(string action,boolean create)
    {
        GNT__TaskConfig__c taskSummary = new GNT__TaskConfig__c();
        taskSummary.GNT__TaskAction__c = action;
        taskSummary.name = action;
        if(create)
            insert taskSummary;
        return taskSummary;
    }
    
    
    global static User getPortalUser(boolean create)
    {
        Contact contact;
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        User currentUser = TestHelper.getStandardUser(false);
        currentUser.UserRoleId = portalRole.id;
        insert currentUser ;
        
        system.runAs(currentUser){
            Account account = TestHelper.getAccount(false);
            account.ApplicantType__c = 'State governments';
            account.type = 'Customer';
            //account.EINo__c = 999;
            account.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('External').getRecordTypeId();
            insert account;
            
            contact = TestHelper.getContact(false);
            contact.AccountId= account.id;
            insert contact;
        }

        Profile profile = [select Id,name from Profile where UserLicense.Name like 'Partner Community' limit 1];
        
        User portalUser = new User(
            Username = System.now().millisecond() + 'test12345@test1.com',
            ContactId = contact.Id,
            ProfileId = profile.Id,
            Alias = 'test123',
            Email = 'test12345@test.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'McTesty',
            CommunityNickname = 'test12345',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US'
        );
        
        if(create)
            insert portalUser;
        return portalUser;
    }
    
    global static UserRegistration__c getUserRegistration(boolean create){    
        UserRegistration__c userRegister  = new UserRegistration__c(OrganizationName__c ='TestORG',LastName__c = 'Betty',username__c = System.now().millisecond() + 'test@123test.com', EINo__c = Math.Random(), Email__c = 'test15@test.com');
        if(create){
            insert userRegister ;
        }
        return userRegister ;
    }
    
    global static User getStandardPlatformUser(boolean create)
    {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard Platform User'];
        List<User> users = [Select Id, Name from User where username='standarduser@govbd.dev'];
        if (users.size() == 1) {
            return users.get(0);
        }
        User u = new User(Alias = 'standt', Email='standarduser@govbd.dev', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/New_York', UserName='standarduser@govbd.dev');
        if(create)
            insert u;
        return u;
    }
    global static Document createTestDocument(boolean create, string name){
         Document d = new Document();
         d.name = name;
         d.body = Blob.valueof('Test Data');
         d.AuthorId = UserInfo.getUserId();
         d.FolderId = UserInfo.getUserId();
         if(create){
             insert d;  
         }
         return d;
    }
    
    global static User getStandardUser(boolean create, string username)
    {
        User u;
        List<User> userList = [SELECT Id, Name FROM User WHERE Username = :username];
        
        if(userList.size() > 0)
        {
            u = userList.get(0);
        }
        else
        {
            
            Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User'];
            u = new User(Alias = 'user9idu',  
                EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                LocaleSidKey='en_US', ProfileId = p.Id, 
                TimeZoneSidKey='America/New_York');
            u.Username = username;
            u.Email = username;
            
            if(create) {
                insert u;
            }
        }
        return u;
    }
    
    //Create a sample contact record for a given account record id.
    global static Contact getContact(Boolean create) {
        Contact contact = new Contact(Firstname='FirstName', Lastname='LastName',Email='email@email.com', Title='Title',Phone ='123-123-1234');
        if (create) {  
            insert contact;
        }
        return contact;
    }
    
    global static ProcessInstanceWorkitem getWorkItem(){
        ProcessInstanceWorkitem witem;
        User tmpusr = getStandardPlatformUser(true);
        System.runAs( tmpusr ){
            witem = new ProcessInstanceWorkitem();
        }
        
        return witem;
    }

   
    global static Task getTask(Boolean create){
        Task tempTask = new Task();
        tempTask.ActivityDate = System.today();
        tempTask.GNT__ActivityDuplicateDate__c= System.today();
        tempTask.Description = 'The new phone books are here Im somebody again';
        tempTask.GNT__DocumentType__c = 'Applications';
        
        if(create){
            insert tempTask;
        }
        return tempTask;
    }
    
    global static List<Task> getAssignedTasks(Boolean create){
        List<Task> taskList = new List<Task>();
        
        String[] theDocs = new List<String> {'Announcement', 'Application', 'Pre-Application','Progress Report', 'Program',
                                'Funding Source', 'Funding Account', 'Review Award', 'Create Award', 
                                'Organization', 'User', 'Submission Package'};
        
        for( String docStr : theDocs ){
            Task tempTask = getTask(false);
            tempTask.GNT__WorkitemId__c = getWorkItem().Id;
            tempTask.GNT__DocumentType__c = docStr;
            taskList.add(tempTask);
        }
        if (create) {
            insert taskList;
        }
        return taskList;
    }
    
    global static FiscalYear__c getFiscalYear(boolean create){
        
        FiscalYear__c year=new FiscalYear__c();
        
        if (create) {
            insert year;
        }
        return year;
        
        
    }
    
    
    
    global static List<Task> getUnassignedTasks(Boolean create){
        List<Task> taskList = new List<Task>();
        
        String[] theDocs = new List<String> {'Announcement', 'Application', 'Pre-Application','Progress Report', 'Program',
                                'Funding Source', 'Funding Account', 'Review Award', 'Create Award', 
                                'Organization', 'User', 'Submission Package'};
        
        for( String docStr : theDocs ){
            Task tempTask = getTask(false);
            tempTask.GNT__WorkitemId__c = getWorkItem().Id;
            tempTask.GNT__GroupId__c = 'more garbage';
            tempTask.GNT__GroupName__c = 'System Administrator';
            tempTask.GNT__DocumentType__c = docStr;
            taskList.add(tempTask);
        }
        
        if (create) {
            insert taskList;
        }
        return taskList;
    }
    
    global static SiteVisitSchedule__c getSiteVisitSchedule(Boolean create) {
        GNT__PageTemplate__c pt = getPageTemplateConfig(true);
        GNT__Package__c pack = getPackage(false, pt);
        pack.GNT__SubmissionType__c = 'Site Visit Report';
        pack.GNT__LatestVersion__c = true;
        pack.GNT__Status__c = 'Active';
        insert pack;

        SiteVisitSchedule__c ss = new SiteVisitSchedule__c(SiteVisitReportPackage__c=pack.Id, Status__c='Finalized');

        if (create) {
            insert ss;
        }
        return ss;
    }

    global static SiteVisit__c getSiteVisit(Boolean create) {
        //SiteVisitSchedule__c ss = getSiteVisitSchedule(true);
        
        Grant__c grant = getGrant(false);
        grant.Status__c = 'Active';
        insert grant;

        SiteVisit__c sv = new SiteVisit__c(/*SiteVisitSchedule__c=ss.Id,*/ Status__c='Approved', Grant__c=grant.Id, 
            SiteVisitor__c=UserInfo.getUserId(), VisitDateandTime__c=DateTime.now() - 5, VisitEndDateTime__c = DateTime.now());

        if (create) {
            insert sv;
        }
        return sv;
    }

    global static SiteVisitActivity__c getSiteVisitActivity(Boolean create) {
        //SiteVisitSchedule__c ss = getSiteVisitSchedule(true);
        
        //Grant__c grant = getGrant(false);
        //grant.Status__c = 'Active';
        //insert grant;

        SiteVisit__c sv=getSiteVisit(true);
        SiteVisitActivity__c sva = new SiteVisitActivity__c(/*SiteVisitSchedule__c=ss.Id,*/SiteVisit__c=sv.id,ActivityDescription__c='test',Date__c=System.TODAY());

        if (create) {
            insert sva;
        }
        return sva;
    }

    global static GNT__PageTemplate__c getPageTemplateConfig(Boolean create) {
        GNT__PageLayoutConfig__c pageLayoutConfig =  getPageLayoutConfig(true);
        GNT__TabConfig__c tabConfig =  getTabConfig(pageLayoutConfig.Id,true);
        GNT__PageBlockConfig__c pageBlockConfig =  getPageBlockConfig(tabConfig.Id, true);
        GNT__PageBlockDetailConfig__c pageBlockDetailConfig = getPageBlockDetailConfig(pageBlockConfig.Id,true);
        
        GNT__PageTemplate__c template = new GNT__PageTemplate__c(Name='TestTemplate1'+System.now().millisecond(), GNT__EditLayoutConfig__c=pageLayoutConfig.Id,GNT__SObjectName__c ='Application__c',GNT__Description__c ='testDesc',
                                        GNT__ViewLayoutConfig__c=pageLayoutConfig.Id,GNT__PrintLayoutConfig__c = pageLayoutConfig.Id,
                                         RecordTypeId = Schema.SObjectType.GNT__PageTemplate__c.getRecordTypeInfosByName().get('Layout Form').getRecordTypeId(),GNT__OMBNumber__c='TestOmbNo',GNT__PackageType__c='TestPackageType');
        if (create) {  

            insert template;
        }
        return template;
    }
    

    global static GNT__PageTemplate__c getPageTemplateConfig(Boolean create,Id pageLayoutId) {

        GNT__PageTemplate__c template = new GNT__PageTemplate__c(Name='TestTemplate', GNT__EditLayoutConfig__c=pageLayoutId,
                                        GNT__ViewLayoutConfig__c=pageLayoutId,GNT__PrintLayoutConfig__c = pageLayoutId);
        if (create) {  
            insert template;
        }
        return template;
    }
    
    global static GNT__Package__c getPackage(Boolean create,GNT__PageTemplate__c pageTemplate) {
        Account acc = getAccount(true);        
        GNT__Package__c packageNew = new GNT__Package__c (GNT__PageTemplateConfig__c =pageTemplate.id,GNT__Status__c = 'Active',
                            GNT__SubmissionType__c = 'Application',GNT__LatestVersion__c=true,GNT__Description__c='testDescription1');
        if (create) {  
            insert packageNew ;
        }
        return packageNew ;
    }
    global static GNT__Package__c getPackage(Boolean create,String submissionType) {
        GNT__PageTemplate__c ptc = getPageTemplateConfig(true);
        GNT__Package__c packageNew = new GNT__Package__c (GNT__Status__c = 'Active',GNT__PageTemplateConfig__c =ptc.id,
                            RecordTypeId = Schema.SObjectType.GNT__Package__c.getRecordTypeInfosByName().get('Standard').getRecordTypeId(),
                            GNT__SubmissionType__c = submissionType,GNT__LatestVersion__c=true,GNT__Description__c='testDescription1');
        if (create) {  
            insert packageNew ;
        }
        return packageNew ;
    }
    
    global static GNT__PageLayoutActionConfig__c getPageLayoutActionConfig(Boolean create,Id pageConfigId) {
       GNT__PageLayoutActionConfig__c pageAction = new GNT__PageLayoutActionConfig__c(GNT__ActionURL__c='Test Btn',GNT__Type__c='Button',GNT__PageLayoutConfig__c=pageConfigId); 
         if (create) {  
            insert pageAction ;
        }
        return pageAction ;
    }
    
    global static GNT__PageLayoutConfig__c getPageLayoutConfig(Boolean create) {
        GNT__PageLayoutConfig__c pageLayout = new GNT__PageLayoutConfig__c(Name='Test View Layout', GNT__Description__c='Test Page Layout',
                    GNT__ObjectAPIName__c='Opportunity');
                    
        if (create) {  
            insert pageLayout;
        }
        return pageLayout;
    } 
   

    global static GNT__PageLayoutConfig__c getPageLayoutConfig(Boolean create, String objectAPIName ) {
        GNT__PageLayoutConfig__c pageLayout = new GNT__PageLayoutConfig__c(Name='Test View Layout', GNT__Description__c='Test Page Layout',
                    GNT__ObjectAPIName__c= objectAPIName);
        if (create) {  
            insert pageLayout;
        }
        return pageLayout;
    }   
    
    global static GNT__HelpConfig__c getHelpConfig(Boolean create) {
       
        return null;
    }
    
    global static GNT__HelpConfig__c getHelpConfigWithoutRecordType(Boolean create) {
        Id recTypeId = Schema.SObjectType.GNT__HelpConfig__c.getRecordTypeInfosByName().get('External Link').getRecordTypeId();
        GNT__HelpConfig__c helpConfig = new GNT__HelpConfig__c(RecordTypeId=recTypeId);
        if (create) {  
            insert helpConfig;
        }
        return helpConfig;
    }
    
    global static GNT__HelpConfig__c getHelpConfigWithRecordType(Boolean create, String name) {
        Id recTypeId = Schema.SObjectType.GNT__HelpConfig__c.getRecordTypeInfosByName().get(name).getRecordTypeId();
        GNT__HelpConfig__c helpConfig = new GNT__HelpConfig__c(RecordTypeId=recTypeId);
        if (create) {  
            insert helpConfig;
        }
        return helpConfig;
    }
    
    global static GNT__TabConfig__c getTabConfig(Id pageLayout,Boolean create) {
        GNT__TabConfig__c tabConfig = new GNT__TabConfig__c(GNT__IsActive__c=true,GNT__PageLayoutConfig__c=pageLayout,GNT__SortOrder__c=0,GNT__StandardTabName__c='Tab 1');
        if (create) {  
            insert tabConfig;
        }
        return tabConfig;
    }
    

    global static GNT__PageBlockConfig__c getPageBlockConfig(Id tabConfig, Boolean create) {
        Id recTypeId = Schema.SObjectType.GNT__PageBlockConfig__c.getRecordTypeInfosByName().get('Fields').getRecordTypeId();
        GNT__PageBlockConfig__c pageBlockConfig = new GNT__PageBlockConfig__c(GNT__BodyColumns__c='1',GNT__IsActive__c=true,GNT__PageBlockTitle__c='Test',
                    GNT__SortOrder__c=0,GNT__TabLayoutConfig__c=tabConfig,RecordTypeId=recTypeId);
        if (create) {  
            insert pageBlockConfig;
        }
        return pageBlockConfig;
    }
    
    global static GNT__PageBlockDetailConfig__c getPageBlockDetailConfig(Id pageBlockConfig, Boolean create) {
        
        Id recTypeId = Schema.SObjectType.GNT__PageBlockDetailConfig__c.getRecordTypeInfosByName().get('Field').getRecordTypeId();
        GNT__PageBlockDetailConfig__c pageBlockDetail = new GNT__PageBlockDetailConfig__c(GNT__IsActive__c=true,RecordTypeId=recTypeId,GNT__SortOrder__c=0,
                    GNT__PageBlockConfig__c=pageBlockConfig, GNT__FieldAPIName__c='Name',GNT__IsScoringQuestion__c=true);
        
        if (create) {  
            insert pageBlockDetail;
        }
        return pageBlockDetail;
    }
    
    global static GNT__PageBlockDetailConfig__c getPageBlockDetailConfigFieldSet(Id pageBlockConfig, Boolean create) {
        Id recTypeId = Schema.SObjectType.GNT__PageBlockDetailConfig__c.getRecordTypeInfosByName().get('Field Set').getRecordTypeId();
        GNT__PageBlockDetailConfig__c pageBlockDetail = new GNT__PageBlockDetailConfig__c(GNT__IsActive__c=true,RecordTypeId=recTypeId,GNT__SortOrder__c=0,
                    GNT__PageBlockConfig__c=pageBlockConfig, GNT__FieldAPIName__c='Id');
        if (create) {  
            insert pageBlockDetail;
        }
        return pageBlockDetail;
    }
    
    global static GNT__PageBlockDetailConfig__c getPageBlockDetailConfig2(Id pageBlockConfig, Boolean create) {
        Id recTypeId = Schema.SObjectType.GNT__PageBlockDetailConfig__c.getRecordTypeInfosByName().get('Field').getRecordTypeId();
        GNT__PageBlockDetailConfig__c pageBlockDetail = new GNT__PageBlockDetailConfig__c(GNT__IsActive__c=true,RecordTypeId=recTypeId,GNT__SortOrder__c=0,
                    GNT__PageBlockConfig__c=pageBlockConfig, GNT__FieldAPIName__c='Account.Name');
        if (create) {  
            insert pageBlockDetail;
        }
        return pageBlockDetail;
    }
    
    global static List<ID> setLayoutData() {
        List<ID> layoutIDs = new List<ID>();
        GNT__PageLayoutConfig__c pageLayoutConfig =  getPageLayoutConfig(true);
        GNT__TabConfig__c tabConfig =  getTabConfig(pageLayoutConfig.Id,true);
        GNT__PageBlockConfig__c pageBlockConfig =  getPageBlockConfig(tabConfig.Id, true);
        GNT__PageBlockDetailConfig__c pageBlockDetailConfig = getPageBlockDetailConfig(pageBlockConfig.Id,true); 
        GNT__PageLayoutActionConfig__c pageAction = getPageLayoutActionConfig(true,pageLayoutConfig.Id);
        layoutIDs.add(pageLayoutConfig.Id);
        layoutIDs.add(tabConfig.ID);
        layoutIDs.add(pageBlockConfig.Id);
        layoutIDs.add(pageBlockDetailConfig.Id);
        layoutIDs.add(pageAction.Id);
        return layoutIDs;       
    }

    global static List<ID> setLayoutData(String objectAPIName) {
        List<ID> layoutIDs = new List<ID>();
        GNT__PageLayoutConfig__c pageLayoutConfig =  getPageLayoutConfig(true,objectAPIName);
        GNT__TabConfig__c tabConfig =  getTabConfig(pageLayoutConfig.Id,true);
        GNT__PageBlockConfig__c pageBlockConfig =  getPageBlockConfig(tabConfig.Id, true);
        GNT__PageBlockDetailConfig__c pageBlockDetailConfig = getPageBlockDetailConfig(pageBlockConfig.Id,true); 
        GNT__PageLayoutActionConfig__c pageAction = getPageLayoutActionConfig(true,pageLayoutConfig.Id);
        layoutIDs.add(pageLayoutConfig.Id);
        layoutIDs.add(tabConfig.ID);
        layoutIDs.add(pageBlockConfig.Id);
        layoutIDs.add(pageBlockDetailConfig.Id);
        layoutIDs.add(pageAction.Id);
        return layoutIDs;       
    }
    
    global static List<ID> setLayoutDataRelationShipField() {
        List<ID> layoutIDs = new List<ID>();
        GNT__PageLayoutConfig__c pageLayoutConfig =  getPageLayoutConfig(true);
        GNT__TabConfig__c tabConfig =  getTabConfig(pageLayoutConfig.Id,true);
        GNT__PageBlockConfig__c pageBlockConfig =  getPageBlockConfig(tabConfig.Id, true);
        GNT__PageBlockDetailConfig__c pageBlockDetailConfig = getPageBlockDetailConfig2(pageBlockConfig.Id,true); 
        
        layoutIDs.add(pageLayoutConfig.Id);
        layoutIDs.add(tabConfig.ID);
        layoutIDs.add(pageBlockConfig.Id);
        layoutIDs.add(pageBlockDetailConfig.Id);
        return layoutIDs;       
    }
    global static GNT__PhaseConfig__c getPhase(boolean create) {
        GNT__PhaseConfig__c phase = new GNT__PhaseConfig__c();
        phase.Name = 'TestPhase';
        phase.GNT__TabName__c='PLANNING';
        phase.GNT__CustomAppName__c = 'StateasGrantor';
        phase.GNT__URL__c = '/apex/planning';
        phase.GNT__GroupName__c='2';
        phase.GNT__Sequence__c=2;
        phase.GNT__Abbreviation__c ='PL';
        phase.GNT__SObject__c = 'Accouncement__c;Program__c;Package__c'; 
        phase.GNT__AccordionHeader__c = 'Planning';
        phase.GNT__EnableSearch__c = true;
        phase.GNT__SidebarSearchLabel__c = 'Search';
        phase.GNT__SidebarRecentlyViewedLabel__c = 'Recently Viewed';
        phase.GNT__SidebarExternalLinksLabel__c = 'External Links';     
        phase.GNT__SearchResultPage__c ='/apex/planning';
        phase.GNT__SidebarComponentSequence__c = 'Search,Links,RecentlyViewed,SubMenu';
        phase.GNT__EnableExternalLinks__c = true;
     phase.GNT__FlexTableParameters__c = 'orgType=Organization';
        phase.GNT__Active__c= true;
        phase.GNT__PhaseType__c = 'Phase';
        phase.GNT__SelectedByDefault__c = true;
        
        if (create) {
            insert phase;
        } 
        return phase;    
    }
    
    global static GNT__PhaseConfig__c getDashboardPhase(boolean create) {
        GNT__PhaseConfig__c phase = new GNT__PhaseConfig__c();
        phase.Name = 'TestDashboardPhase';
        phase.GNT__CustomAppName__c = 'StateasGrantor';
        phase.GNT__Abbreviation__c ='PL';
        phase.GNT__SObject__c = ''; 
        phase.GNT__AccordionHeader__c = 'Dashboard';
        phase.GNT__EnableSearch__c = true;
        phase.GNT__SidebarSearchLabel__c = 'Search';
        phase.GNT__SidebarRecentlyViewedLabel__c = 'Recently Viewed';
        phase.GNT__SidebarExternalLinksLabel__c = 'External Links';
        phase.GNT__URL__c = '/apex/Dashboard';
        phase.GNT__SearchResultPage__c ='/apex/Dashboard';
        phase.GNT__SidebarComponentSequence__c = 'Search,Links,RecentlyViewed,SubMenu';
        phase.GNT__TabName__c='DASHBOARD';
        phase.GNT__GroupName__c='2';
        phase.GNT__Sequence__c=2;
        phase.GNT__Active__c= true;
        phase.GNT__PhaseType__c = 'Dashboard';
        phase.GNT__SelectedByDefault__c = true;
        
        if (create) {
            insert phase;
        } 
        return phase;    
    }
    
     global static GNT__ChartConfig__c getBoxChartConfig(Boolean create, Id phaseConfigId) {
        GNT__ChartConfig__c ChartConfig = new GNT__ChartConfig__c(Name='Summary',
                    GNT__Title__c='Progress',GNT__ChartPageURL__c='/apex/testPageUrl', GNT__PhaseConfig__c = phaseConfigId, 
                    RecordTypeId=getRecordType(Schema.SObjectType.GNT__ChartConfig__c, 'Box'));
        if (create) {  
            insert ChartConfig ;
        }
        return ChartConfig ;
    }
    global static GNT__ChartDetailConfig__c getBoxChartDetailConfig(Boolean create,Id ChartConfig) {
        GNT__ChartDetailConfig__c ChartDetailConfig = new GNT__ChartDetailConfig__c(GNT__DisplayDataType__c='Count', GNT__Title__c='Summary ', 
                     GNT__ChartConfig__c = ChartConfig);
                     
        if (create) {  
            insert ChartDetailConfig ;
        }
        return ChartDetailConfig ;
    }    
    global static GNT__ChartConfig__c getProgressChartConfig(Boolean create, Id phaseConfigId) {
        GNT__ChartConfig__c ChartConfig = new GNT__ChartConfig__c(Name='Progress', GNT__ObjectName__c=AppUtils.getNamespacePrefix()+'FundingSourceYear__c', 
                    GNT__Title__c='Progress',GNT__ChartPageURL__c='/apex/testPageUrl', GNT__PhaseConfig__c = phaseConfigId, 
                    RecordTypeId=getRecordType(Schema.SObjectType.GNT__ChartConfig__c, 'Progress Bar'));
        if (create) {  
            insert ChartConfig ;
        }
        return ChartConfig ;
    }
    global static GNT__ChartDetailConfig__c getProgressChartDetailConfig(Boolean create,Id ChartConfig) {
        GNT__ChartDetailConfig__c ChartDetailConfig = new GNT__ChartDetailConfig__c(GNT__DisplayDataType__c='Currency', GNT__Title__c='Program Progress', 
                     GNT__ChartConfig__c = ChartConfig);
                     
        if (create) {  
            insert ChartDetailConfig ;
        }
        return ChartDetailConfig ;
    }    
    global static GNT__ChartConfig__c getDonutChartConfig(Boolean create, Id phaseConfigId) {
        GNT__ChartConfig__c ChartConfig = new GNT__ChartConfig__c(Name='ProgramStatus', GNT__ObjectName__c=AppUtils.getNamespacePrefix()+'Program__c', 
                    GNT__Title__c='ProgramStatus',GNT__ChartPageURL__c='/apex/testPageUrl', GNT__PhaseConfig__c = phaseConfigId, 
                    RecordTypeId=getRecordType(Schema.SObjectType.GNT__ChartConfig__c, 'Pie - Semi Circle Donut'));
        if (create) {  
            insert ChartConfig ;
        }
        return ChartConfig ;
    }
    
     global static GNT__ChartDetailConfig__c getDonutChartDetailConfig(Boolean create,Id ChartConfig) {
        GNT__ChartDetailConfig__c ChartDetailConfig = new GNT__ChartDetailConfig__c(GNT__DisplayDataType__c='Count', GNT__Title__c='Program Status', 
                     GNT__ChartConfig__c = ChartConfig);
                     
        if (create) {  
            insert ChartDetailConfig ;
        }
        return ChartDetailConfig ;
    }
    

     global static GNT__ChartConfig__c getAnnouncementChartConfig(Boolean create, Id phaseConfigId) {
        GNT__ChartConfig__c ChartConfig = new GNT__ChartConfig__c(Name='Total Announcement', GNT__ObjectName__c='Announcement__c', 
                    GNT__Title__c='Total Announcement',GNT__ChartPageURL__c='/apex/testPageUrl', GNT__PhaseConfig__c = phaseConfigId, GNT__FilterFieldNames__c='FiscalYear__c', 
                    RecordTypeId=getRecordType(Schema.SObjectType.GNT__ChartConfig__c, 'Pie - Basic'));
        if (create) {  
            insert ChartConfig ;
        }
        
        return ChartConfig ;
    }
     global static GNT__ChartDetailConfig__c getPieChartDetailConfig(Boolean create,Id ChartConfig) {
        GNT__ChartDetailConfig__c ChartDetailConfig = new GNT__ChartDetailConfig__c(GNT__DisplayDataType__c='Count', GNT__Title__c='Announcement Status', 
                     GNT__ChartConfig__c = ChartConfig);
                     
        if (create) {  
            insert ChartDetailConfig ;
        }
        return ChartDetailConfig ;
    }
    //TODO: don't return any value and no need for input parameter. Also line wrap more than 80 characters.
    global static boolean createCustomSettings(Boolean create) {
        List<GNT__KeyValueStore__c> listCustomSetting = new List<GNT__KeyValueStore__c>();
        
        GNT__KeyValueStore__c FeedbackSupportEmail = new GNT__KeyValueStore__c(Name='FeedbackSupportEmail',GNT__TextValue__c='GovBDsupport@reisystems.com',
                        GNT__Description__c='Email address to send feedback of the customer in real time',GNT__BooleanValue__c=true,GNT__Admin_Question__c = 'Loren Ipsum');
        
        GNT__KeyValueStore__c keyValueEmail = new GNT__KeyValueStore__c(Name='exSendErrorEmailRealTime',GNT__TextValue__c='GovBDsupport@reisystems.com',
                        GNT__Description__c='Flag to indicate that the exception email should be sent in real time',GNT__BooleanValue__c=true,GNT__Admin_Question__c = 'Loren Ipsum');
        GNT__KeyValueStore__c keyValueEmailSubject = 
                new GNT__KeyValueStore__c(Name='exEmailSubject',GNT__TextValue__c='Please take the necessary steps', 
                GNT__Description__c='Subject of the Error Email which will be sent to the users',GNT__Admin_Question__c = 'Loren Ipsum');
        GNT__KeyValueStore__c keyValueSavetoSalesforce = new GNT__KeyValueStore__c(Name='exSavetoSalesforce',
                GNT__TextValue__c='Flag to indicate to save to SF',GNT__BooleanValue__c=true,GNT__Description__c='Flag to save to Salesforce',GNT__Admin_Question__c = 'Loren Ipsum'); 
        GNT__KeyValueStore__c keyValueexDispalyGenericErrorUI =  new GNT__KeyValueStore__c(Name='exDispalyGenericErrorUI',
                GNT__TextValue__c='Following Exception occured in the System',GNT__BooleanValue__c=true,GNT__Description__c='Flag to Display the Generic Message',GNT__Admin_Question__c = 'Loren Ipsum');  
        GNT__KeyValueStore__c keyRecentlyViewedRecordsLimit =  new GNT__KeyValueStore__c(Name='RecentlyViewedRecordsLimit',GNT__IntegerValue__c=10, 
                GNT__Description__c='Count of the recently v',GNT__Admin_Question__c = 'Loren Ipsum');   
        GNT__KeyValueStore__c keyHomeTabFlag =  new GNT__KeyValueStore__c(Name='homeTabFlag',GNT__BooleanValue__c=true,
                GNT__Description__c='Custom setting to hide the home tab',GNT__Admin_Question__c = 'Loren Ipsum');   
        GNT__KeyValueStore__c keyHidepublicSearch =  new GNT__KeyValueStore__c(Name='HidepublicSearch',GNT__BooleanValue__c=true,
                GNT__Description__c='Custom setting to hide the public Search',GNT__Admin_Question__c = 'Loren Ipsum');   
        GNT__KeyValueStore__c keyEnableSearchTypeAhead= new GNT__KeyValueStore__c(Name='EnableSearchTypeAhead',GNT__BooleanValue__c=true,
                GNT__Description__c='Custom setting to enable Type ahead search',GNT__Admin_Question__c = 'Loren Ipsum');
        GNT__KeyValueStore__c keySearchTypeAheadLimit= new GNT__KeyValueStore__c(Name='SearchTypeAheadLimit',GNT__IntegerValue__c=10,GNT__Description__c='Limit to SOSL query',GNT__Admin_Question__c = 'Loren Ipsum');
        GNT__KeyValueStore__c StateLogoDocumentName= new GNT__KeyValueStore__c(Name='StateLogoDocumentName',GNT__TextValue__c='Test Doc',GNT__Description__c='Logo Name',GNT__Admin_Question__c = 'Loren Ipsum');
        GNT__KeyValueStore__c SearchPageSize= new GNT__KeyValueStore__c(Name='SearchPageSize',GNT__IntegerValue__c=10,GNT__Description__c='Search Page record limit',GNT__Admin_Question__c = 'Loren Ipsum');
        GNT__KeyValueStore__c MaxViewHistorySize = new GNT__KeyValueStore__c(Name='MaxViewHistorySize',GNT__IntegerValue__c=10,GNT__Description__c='Max view history record limit',GNT__Admin_Question__c = 'Loren Ipsum');
        GNT__KeyValueStore__c FlexTableStandardObjects = new GNT__KeyValueStore__c(Name='FlexTableStandardObjects',GNT__TextValue__c='ProcessInstanceWorkItem;Task',
                GNT__Description__c='List of std objects that are not supported by std list contorller',GNT__Admin_Question__c = 'Loren Ipsum');
        GNT__KeyValueStore__c ExternalUserPublicGroup = new GNT__KeyValueStore__c(Name='ExternalUserPublicGroup',GNT__TextValue__c='AllExternalUsers',
                GNT__Description__c='This setting contains name of the Public Group which has all the Portal users as its members.',GNT__Admin_Question__c = 'Loren Ipsum');
         GNT__KeyValueStore__c ExternalLogin= new GNT__KeyValueStore__c(Name='ExternalLoginPage',GNT__TextValue__c='ExternalUser',
                GNT__Description__c='login page for external user',GNT__Admin_Question__c = 'Loren Ipsum');
                
        GNT__KeyValueStore__c awardApprovalEmail= new GNT__KeyValueStore__c(Name='AwardApprovalEmailTemplate',GNT__TextValue__c='AwardApproved',
                GNT__Description__c='This is AwardApprovalEmailTemplate',GNT__Admin_Question__c = 'Loren Ipsum');
                
        GNT__KeyValueStore__c awardRejectionEmail= new GNT__KeyValueStore__c(Name='AwardRejectionEmailTemplate',GNT__TextValue__c='AwardRejected',
                GNT__Description__c='This is AwardRejectionEmailTemplate',GNT__Admin_Question__c = 'Loren Ipsum');
        GNT__KeyValueStore__c InviteReviewerEmailTemplate= new GNT__KeyValueStore__c(Name='ReviewerInviteEmailTemplate',GNT__TextValue__c='ReviewerInvite',
                GNT__Description__c='This is Reviewer Invite EmailTemplate',GNT__Admin_Question__c = 'Loren Ipsum');        
        GNT__KeyValueStore__c IsExternalUserRegApprovalRequired= new GNT__KeyValueStore__c(Name='IsExternalUserRegApprovalRequired',GNT__BooleanValue__c=true,
                GNT__Description__c='IsExternalUserRegApprovalRequired',GNT__Admin_Question__c = 'Loren Ipsum');
        GNT__KeyValueStore__c autoCreateUserRegistrations= new GNT__KeyValueStore__c(Name='autoCreateUserRegistrations',GNT__BooleanValue__c=true,
                GNT__Description__c='autoCreateUserRegistrations?',GNT__Admin_Question__c = 'Loren Ipsum');
        
        User loginUser = [Select Username from User where Id=:UserInfo.getUserId()];
        
        GNT__KeyValueStore__c keyTaskDueDateOffset= new GNT__KeyValueStore__c(Name='TaskDueDateOffset',GNT__IntegerValue__c=10,GNT__Description__c='TaskDueDateOffset',GNT__Admin_Question__c = 'Loren Ipsum');        
      //  GNT__KeyValueStore__c keyQueueAdminUsername= new GNT__KeyValueStore__c(Name='QueueAdminUsername',GNT__TextValue__c=getStandardUser(true).Email,GNT__Description__c='Owner of the Task that is created from the Approval Process',GNT__Admin_Question__c = 'Loren Ipsum');
        GNT__KeyValueStore__c UsefulLinksExpandedItemsCount = new GNT__KeyValueStore__c(Name='UsefulLinksExpandedItemsCount',GNT__IntegerValue__c=6,GNT__Description__c='number of characters displayed for each useful link item on the Login Page',GNT__Admin_Question__c = 'Loren Ipsum');
        GNT__KeyValueStore__c UsefulLinksVisibleItemsCount = new GNT__KeyValueStore__c(Name='UsefulLinksVisibleItemsCount',GNT__IntegerValue__c=3,GNT__Description__c='number of Items to display when VIEW ALL items are clicked in the "Useful Links" section on the Login Page',GNT__Admin_Question__c = 'Loren Ipsum');
        GNT__KeyValueStore__c UsefulLinksCharacterCount = new GNT__KeyValueStore__c(Name='UsefulLinksCharacterCount',GNT__IntegerValue__c=150,GNT__Description__c='number of Items to display by default in the "Useful Links" section on the Login Page',GNT__Admin_Question__c = 'Loren Ipsum');
        GNT__KeyValueStore__c ApplicationRejectionEmailTemplate  = new GNT__KeyValueStore__c(Name='ApplicationRejectionEmailTemplate',GNT__TextValue__c = 'RejectionTemplateTest',GNT__Description__c='Application rejection template',GNT__Admin_Question__c = 'Loren Ipsum');
        GNT__KeyValueStore__c AutoCreateApplication  = new GNT__KeyValueStore__c(Name='AutoCreateApplication',GNT__BooleanValue__c = true,GNT__Description__c='Auto create application',GNT__Admin_Question__c = 'Loren Ipsum');
        GNT__KeyValueStore__c SetOWDEmail= new GNT__KeyValueStore__c(Name='SetOWDEmail',GNT__BooleanValue__c = true,GNT__Description__c='check if OWEmail required',GNT__Admin_Question__c = 'Loren Ipsum');
        GNT__KeyValueStore__c OWDName= new GNT__KeyValueStore__c(Name='OWDName',GNT__TextValue__c = 'GovGrants',GNT__Description__c='check if OWEmail required',GNT__Admin_Question__c = 'Loren Ipsum');
        GNT__KeyValueStore__c ExternalLoginValidationType= new GNT__KeyValueStore__c(Name='ExternalLoginValidationType',GNT__TextValue__c = 'EIN',GNT__Description__c='EIN',GNT__Admin_Question__c = 'Loren Ipsum');
        GNT__KeyValueStore__c adminProfileNames= new GNT__KeyValueStore__c(Name='AdminProfileNames',GNT__TextValue__c = 'System Administrator, PM', GNT__Description__c='List of admin profiel names',GNT__Admin_Question__c = 'Loren Ipsum');
       // GNT__KeyValueStore__c showDynaLayoutSetupLink= new GNT__KeyValueStore__c(Name='ShowDynaLayoutSetupLink',GNT__BooleanValue__c = true, GNT__Description__c='show dynamic layout?');
        GNT__KeyValueStore__c ndaApplicantHeader= new GNT__KeyValueStore__c(Name='NDAApplicantHeader',GNT__TextValue__c = 'NDA', GNT__Description__c='page header',GNT__Admin_Question__c = 'Loren Ipsum');
        GNT__KeyValueStore__c ndaReviewerHeader= new GNT__KeyValueStore__c(Name='NDAReviewerHeader',GNT__TextValue__c = 'NDA', GNT__Description__c='page header',GNT__Admin_Question__c = 'Loren Ipsum');
        GNT__KeyValueStore__c hideUserAvatar= new GNT__KeyValueStore__c(Name='HideUserAvatar',GNT__BooleanValue__c = true, GNT__Description__c='hide avatar',GNT__Admin_Question__c = 'Loren Ipsum');
        GNT__KeyValueStore__c reviewTasksFailureReciever= new GNT__KeyValueStore__c(Name='ReviewTasksFailureReciever',GNT__TextValue__c=loginUser.Username,GNT__Description__c='The user name specified here receives any error email, when the review tasks creation process fails.',GNT__Admin_Question__c = 'Loren Ipsum');
        GNT__KeyValueStore__c applicationRecommendationMatchParam = new GNT__KeyValueStore__c(Name='ApplicationRecommendationMatchParam',GNT__TextValue__c='GNT__Title__c:Title',GNT__Description__c='The fields to be matched between Application -> Contacts.',GNT__Admin_Question__c = 'Loren Ipsum');
        GNT__KeyValueStore__c preApplicationRecommendationMatchParam = new GNT__KeyValueStore__c(Name='PreApplicationRecommendationMatchParam',GNT__TextValue__c='GNT__Title__c:Title',GNT__Description__c='The fields to be matched between PreApplication -> Contacts.',GNT__Admin_Question__c = 'Loren Ipsum');
        GNT__KeyValueStore__c applicationScoringFactor = new GNT__KeyValueStore__c(Name='ApplicationScoringFactor',GNT__TextValue__c='NumberOfStepsAddedTo__c',GNT__Description__c='What is the API name of the field from application object that provides the weightage factor (which is a number)',GNT__Admin_Question__c = 'Loren Ipsum');
        GNT__KeyValueStore__c COIInfo = new GNT__KeyValueStore__c(Name='Conflict Of Interest Information',GNT__TextValue__c='COIReviewer',GNT__Description__c='COIReviewer',GNT__Admin_Question__c = 'Loren Ipsum');
        GNT__KeyValueStore__c techSupportEmail = new GNT__KeyValueStore__c(Name='TechSupportEmail',GNT__TextValue__c='abcd@xyzq.com',GNT__Description__c='TechSupportEmail',GNT__Admin_Question__c = 'TechSupportEmail');
        GNT__KeyValueStore__c MarkUserAsPrimary = new GNT__KeyValueStore__c(Name='Is First User the primary user',GNT__TextValue__c='test',GNT__BooleanValue__c = true,GNT__IntegerValue__c=1,GNT__Description__c='TechSupportEmail',GNT__Admin_Question__c = 'TechSupportEmail');
        GNT__KeyValueStore__c autoCreateUserRegistrationRecords= new GNT__KeyValueStore__c(Name='AutoCreateUserRegistrationRecords',GNT__TextValue__c=TestHelper.getStandardUser(true).Username,GNT__BooleanValue__c=true,GNT__Description__c='AutoCreateUserRegistrationRecords',GNT__Admin_Question__c ='Loren Ipsum');                          

        GNT__KeyValueStore__c approvalEmailTemplate= new GNT__KeyValueStore__c(Name='RST_ApplicationPromotedEmail',GNT__TextValue__c='ApplicationSubmissionEmailTemplate',GNT__BooleanValue__c=true,GNT__Description__c='ApplicationSubmissionEmailTemplate',GNT__Admin_Question__c ='Loren Ipsum');                          
        GNT__KeyValueStore__c rejectionEmailTemplate= new GNT__KeyValueStore__c(Name='RST_ApplicationRejectionEmail',GNT__TextValue__c='ApplicationSubmissionEmailTemplate',GNT__BooleanValue__c=true,GNT__Description__c='ApplicationSubmissionEmailTemplate',GNT__Admin_Question__c ='Loren Ipsum');                          
        GNT__KeyValueStore__c fDMEmailTemplate= new GNT__KeyValueStore__c(Name='FundingDecisionMemoTemplate',GNT__TextValue__c='FundingDecisionMemoTemplate',GNT__BooleanValue__c=true,GNT__Description__c='ApplicationSubmissionEmailTemplate',GNT__Admin_Question__c ='Loren Ipsum');                          

        //SM
        GNT__KeyValueStore__c rst123 = new GNT__KeyValueStore__c(Name='RST_Step123Layout',GNT__TextValue__c='ApplicationReviewStep',
                GNT__Description__c='This is the page template name of the review step layout for Prescreen, External and Internal review',GNT__Admin_Question__c = 'Loren Ipsum');        
        GNT__KeyValueStore__c rst4 = new GNT__KeyValueStore__c(Name='RST_StepLayout4',GNT__TextValue__c='ApplicationReviewStep',
                GNT__Description__c='This is the page template name of the review step layout for Prescreen, External and Internal review',GNT__Admin_Question__c = 'Loren Ipsum');        
        GNT__KeyValueStore__c panel123 = new GNT__KeyValueStore__c(Name='RST_PanelLayout',GNT__TextValue__c='ApplicationReviewStep',
                GNT__Description__c='This is the page template name of the review step layout for Prescreen, External and Internal review',GNT__Admin_Question__c = 'Loren Ipsum');        
        
        listCustomSetting.add(approvalEmailTemplate);
        listCustomSetting.add(rejectionEmailTemplate);
        listCustomSetting.add(ndaApplicantHeader);
        listCustomSetting.add(ndaReviewerHeader);
        listCustomSetting.add(awardApprovalEmail);
        listCustomSetting.add(awardRejectionEmail);
        listCustomSetting.add(keySearchTypeAheadLimit);
        listCustomSetting.add(MaxViewHistorySize );
        listCustomSetting.add(SearchPageSize);
        listCustomSetting.add(StateLogoDocumentName);
        listCustomSetting.add(keyValueEmail);
        listCustomSetting.add(keyValueEmailSubject);
        listCustomSetting.add(keyValueSavetoSalesforce); 
        listCustomSetting.add(keyValueexDispalyGenericErrorUI);
        listCustomSetting.add(keyRecentlyViewedRecordsLimit);
        listCustomSetting.add(keyHomeTabFlag); 
        listCustomSetting.add(keyHidepublicSearch);
        listCustomSetting.add(keyEnableSearchTypeAhead);
        listCustomSetting.add(FlexTableStandardObjects);
        listCustomSetting.add(keyTaskDueDateOffset);
     //   listCustomSetting.add(keyQueueAdminUsername);
        listCustomSetting.add(FeedbackSupportEmail);
        listCustomSetting.add(ExternalUserPublicGroup);
        listCustomSetting.add(InviteReviewerEmailTemplate);
        listCustomSetting.add(ExternalLogin);
        listCustomSetting.add(ApplicationRejectionEmailTemplate);
        listCustomSetting.add(AutoCreateApplication);
        listCustomSetting.add(SetOWDEmail);
        listCustomSetting.add(OWDName);
        listCustomSetting.add(IsExternalUserRegApprovalRequired);
        listCustomSetting.add(ExternalLoginValidationType);
        listCustomSetting.add(adminProfileNames);
        listCustomSetting.add(autoCreateUserRegistrations);
        listCustomSetting.add(hideUserAvatar);
        listCustomSetting.add(reviewTasksFailureReciever);
        listCustomSetting.add(applicationRecommendationMatchParam);
        listCustomSetting.add(preApplicationRecommendationMatchParam);
        listCustomSetting.add(applicationScoringFactor);
        listCustomSetting.add(COIInfo);
        listCustomSetting.add(techSupportEmail);
        listCustomSetting.add(MarkUserAsPrimary);
        listCustomSetting.add(autoCreateUserRegistrationRecords);
        listCustomSetting.add(rst123);
        listCustomSetting.add(rst4);
        listCustomSetting.add(panel123);

        GNT.UserPreferenceHelper.setBooleanValue('HideSidebar__c', true);
        GNT.UserPreferenceHelper.setBooleanValue('HideHeader__c', true);
        GNT.UserPreferenceHelper.setBooleanValue('SidebarSearchCollapsed__c', true);
        GNT.UserPreferenceHelper.setStringValue('ActiveAppName__c', 'StateasGrantor');
        GNT.UserPreferenceHelper.setStringValue('ProfileName__c','System Administrator');

         List<GNT__PageMessageStyleConfig__c> listPageMsgCustomSetting = new List<GNT__PageMessageStyleConfig__c>();
        GNT__PageMessageStyleConfig__c pageMessage = new GNT__PageMessageStyleConfig__c(Name='Success',GNT__BackgroundGradient1Color__c='Red',GNT__BackgroundGradient2Color__c='yellow',GNT__TextColor__c='green');
        listPageMsgCustomSetting.add(pageMessage); 
        
        if (create) {   
            insert listCustomSetting;
            insert listPageMsgCustomSetting;
            return true; 
        }
        else {
            return false;
        }
    }
    

    global static GNT__CustomAppConfig__c getCustomAppConfig(boolean create){
         GNT__CustomAppConfig__c customAppConfig = new GNT__CustomAppConfig__c();
         customAppConfig.GNT__Label__c = 'State as Grantor';
         customAppConfig.GNT__Active__c = true;
         customAppConfig.GNT__Sequence__c = 1;
         customAppConfig.Name = 'StateasGrantor';
         customAppConfig.GNT__URL__c = '/apex/PhaseView';
         customAppConfig.GNT__ReportsFolderName__c = 'State_as_Grantor';

         if(create){
             insert customAppConfig; 
         }
        return customAppConfig;
    }
    

    
    global static GNT__KeyValueStore__c getKeyValueStore(boolean create) {
        GNT__KeyValueStore__c KeyValueStore = new GNT__KeyValueStore__c();
        KeyValueStore.GNT__Description__c = 'Test';
        KeyValueStore.GNT__TextValue__c = 'Test Name';
        KeyValueStore.Name='Name';
        KeyValueStore.GNT__Admin_Question__c = 'Loren Ipsum';
                     
        if (create) {  
            insert KeyValueStore;
        }
        return KeyValueStore;
    }
    
    global static GNT__DynamicFieldConfig__c getDynamicFieldConfig(boolean create,String type) {
        String nameSpaceprefix  = AppUtils.getNamespacePrefix();
        GNT__DynamicFieldConfig__c dynFieldConf = new GNT__DynamicFieldConfig__c();
        dynFieldConf.Name = 'TestName';
        dynFieldConf.GNT__DisplayField__c =  nameSpaceprefix+ 'DisplayValue__c';
        dynFieldConf.GNT__Object__c = nameSpaceprefix +'Picklist__c';
        dynFieldConf.GNT__ReturnField__c = nameSpaceprefix + 'Value__c';
        dynFieldConf.GNT__Type__c = type;
        if(create) {
            insert dynFieldConf;
        }
        return dynFieldConf;
    }

    global static GNT__Picklist__c getPicklist (boolean create) {
        String nameSpaceprefix  = AppUtils.getNamespacePrefix();
        GNT__Picklist__c picklist = new GNT__Picklist__c();
        picklist.Name = 'TestName-0';
        picklist.GNT__DisplayValue__c =  'test1';
        picklist.GNT__Value__c = 'test1';
        picklist.GNT__GroupName__c = 'TestName';
        
        if(create) {
            insert picklist;
        }
        return picklist;
    }
     
    global static LEAPublicSchools__c getPublicSchool(boolean create,Id account,Id year){
        LEAPublicSchools__c pubschool=new LEAPublicSchools__c();
        pubschool.LEA__c=account;
        pubschool.LEANumberforREI__c='123456';
        pubschool.SchoolName__c='Dummy School';
        pubschool.SchoolNumber__c='21122';
        pubschool.SchoolYear__c=year;
        
          if(create) {
            insert pubschool;
        }
        return pubschool;
        
    } 
     
     
    global static GNT__ThemeConfig__c getThemeConfig(boolean create) {
        GNT__ThemeConfig__c themeConfig = new GNT__ThemeConfig__c(Name='SampleName',GNT__Sequence__c=99,GNT__PreviewImageDocumentName__c='Sample PreviewImageDocumentName',GNT__CSSDocumentName__c='Sample CSS Document Name');
                     
        if (create) {  
            insert themeConfig ;
        }
        return themeConfig ;
    }
    
    global static GNT__TaskConfig__c getTaskConfig(boolean create) {
        GNT__TaskConfig__c taskActionSummary = new GNT__TaskConfig__c(Name='SampleName');
                     
        if (create) {  
            insert taskActionSummary ;
        }
        return taskActionSummary ;
    }
            
    
     global static GNT__CustomAppPhaseConfig__c getCustomAppPhaseConfig(boolean create){
         GNT__CustomAppPhaseConfig__c customAppPhaseConfig= new GNT__CustomAppPhaseConfig__c();
         customAppPhaseConfig.GNT__TabName__c = 'Planning';
         customAppPhaseConfig.GNT__Active__c = true;
         customAppPhaseConfig.GNT__Sequence__c = 1;
         customAppPhaseConfig.Name = 'Planning';
         customAppPhaseConfig.GNT__URL__c = '/apex/PhaseView';
         customAppPhaseConfig.GNT__CustomAppName__c= 'StateasGrantor';
         customAppPhaseConfig.GNT__SelectedByDefault__c = true;
         customAppPhaseConfig.GNT__GroupName__c = 'g1';

         if(create){
             insert customAppPhaseConfig; 
         }
        return customAppPhaseConfig;
    }
    
    global static  GNT__ProfileDropDownConfig__c getProfileDropDownConfig(boolean create){
         GNT__ProfileDropDownConfig__c  profileDropDownConfig = new  GNT__ProfileDropDownConfig__c();
         profileDropDownConfig.GNT__Label__c = 'Grantor';
         profileDropDownConfig.GNT__Active__c = true;
         profileDropDownConfig.GNT__Sequence__c = 1;
         profileDropDownConfig.Name = 'Grantor';
         profileDropDownConfig.GNT__URL__c = '/apex/PhaseView';
         profileDropDownConfig.GNT__External_URL__c = '/apex/PhaseView';
        
         
         if(create){
             insert profileDropDownConfig ; 
         }
        return profileDropDownConfig ;
    }
    
    global static GNT__AccordionHeader__c getAccordionHeader(Id PhaseConfig,boolean create){
        GNT__AccordionHeader__c accordionHeader = new GNT__AccordionHeader__c();
        accordionHeader.Name='Test Header';
        accordionHeader.GNT__Sequence__c = 2;
        accordionHeader.GNT__PhaseConfig__c = PhaseConfig;

        if (create) {
            insert accordionHeader;
        }  
        return accordionHeader;    
     }
     
     global static GNT__AccordionSubHeader__c getAccordionSubHeader(Id AccordionHeader,boolean create){
        GNT__AccordionSubHeader__c accordionSubHeader = new GNT__AccordionSubHeader__c();
        accordionSubHeader.Name='Test SubHeader';
        accordionSubHeader.GNT__Sequence__c = 2;
        accordionSubHeader.GNT__AccordionHeader__c = AccordionHeader;
        accordionSubHeader.GNT__hide__c = false;

        if (create) {
            insert accordionSubHeader;
        } 
        return accordionSubHeader;    
     }
     
     global static GNT__AccordionContent__c getAccordionContent(Id AccordionSubHeader,boolean create){
        GNT__AccordionContent__c accordionContent = new GNT__AccordionContent__c();
        accordionContent.Name='Test Content';
        accordionContent.GNT__Sequence__c = 2;
        accordionContent.GNT__AccordionSubHeader__c = AccordionSubHeader;
        accordionContent.GNT__Link__c = '/apex/Planning';
        if (create) {
            insert accordionContent;
        } 
        return accordionContent;    
     }
    
    
    global static GNT__ExternalLinkConfig__c getExternalLinks(Id PhaseConfigId, boolean create) {
        GNT__ExternalLinkConfig__c externalLink = new GNT__ExternalLinkConfig__c(); 
        externalLink.Name = 'Link1';
        externalLink.GNT__PhaseConfig__c = PhaseConfigId; 
        externalLink.GNT__URL__c = 'www.hrsa.gov';
        externalLink.GNT__OpenNewWindow__c = true;
        externalLink.GNT__Active__c = true;
        externalLink.GNT__Sequence__c = Decimal.valueOf('2');
        if (create) {
            insert externalLink;
        }   
        return externalLink;    
    }   
    
    //TODO: Use Id instead of entire object as the parent for input parameters
    global static Program__c getProgram(Id accountId, boolean create ) {
        Id recTypeId = Schema.SObjectType.Program__c.getRecordTypeInfosByName().get('Internal Program').getRecordTypeId();
        Program__c program = new Program__c();
        program.Name = 'New Grants Program1';
        program.StartDate__c=Date.today()+1;
        program.EndDate__c=Date.today()+2;
        program.Account__c = accountId;
        program.Status__c = 'Created';
        program.ProgramApprover__c = getAdminUser(true).id;
        program.IsProjectServiceAreaneeded__c = 'No';
        program.Recordtypeid = recTypeId;
        program.FunderType__c = 'State';
        ProgramTriggerHelper.skiptrigger=true;
        if (create) {
            insert program;
        } 
        return program;         
    }  

    global static Program__c getGrantorProgram(Id accountId, boolean create ) {
        Id recTypeId = Schema.SObjectType.Program__c.getRecordTypeInfosByName().get('Internal Program').getRecordTypeId();
        Program__c program = new Program__c();
        program.Name = 'New Grants Program1';
        program.StartDate__c=Date.today() + 1;
        program.EndDate__c=Date.today()+2;
        program.Account__c = accountId;
        program.Status__c = 'Created';
        program.ProgramApprover__c = getAdminUser(true).id;
        program.IsProjectServiceAreaneeded__c = 'No';
        program.Recordtypeid = recTypeId;
        program.FunderType__c = 'State';
       // ProgramTriggerHelper.skiptrigger=true;
        if (create) {
            insert program;
        } 
        return program;         
    }  

    global static Program__c getProgram(Id accountId, boolean create,Id awardPackage) {
        Program__c program = new Program__c();
        program.Name = 'New Grants Program1';
        program.Account__c = accountId;
        //program.AwardPackage__c = awardPackage;
        if (create) {
            insert program;
        } 
        return program;         
    }  
     
    global static Account getAccount(boolean create) {
        Account account = new Account();
        account.Name = 'New Grants Account'+system.now()+Math.random();
        account.IsActiveAgency__c = True;
        Id recTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Internal').getRecordTypeId();     
        account.RecordTypeId = recTypeId;
        account.IsActiveAgency__c = true;
        account.IsGrantingAgency__c = true;
           
       account.Status__c = 'Active';      
        if (create) {
            insert account;
        }   
        return account;
    } 
        global static Account getAccount(Id parentId, boolean create) {
        Account account = new Account();
        account.Name = 'New Child Account'+Math.random();
        account.ParentId = parentId;
        account.Status__c = 'Active';
       
        if (create) {
            insert account;
        }   
        return account;
    } 
    
    
    global static USBELEACostRate__c getUSBELEACostRate(boolean create,Id accountId){
        
        USBELEACostRate__c usb=new USBELEACostRate__c();
        usb.Account__c=accountId;
        usb.RestrictedIndirectRate__c=12;
        usb.UnrestrictedIndirectRate__c=13;
        
        if(create){
            insert usb;
            }
          return usb;
    
    }
    
    global static R_VEND_CUST__c getR_VEND_CUST(boolean create){
        
        R_VEND_CUST__c vendor=new R_VEND_CUST__c();
        vendor.lgl_nm__c='John';
        vendor.tin__c='test';
        
         if(create){
             insert vendor;
            }
          return vendor;
        
    }
    
    global static R_AD__c getR_AD(boolean create,Id FINETVCUST){
        
        R_AD__c vendoradd=new R_AD__c ();
        Id vendor=FINETVCUST;
        vendoradd.city_nm__c='Washington';
        vendoradd.ctry__c='USA';
        vendoradd.prin_cntac__c='123456';
        vendoradd.FINETVCUST__c=vendor;
        
         if(create){
            insert vendoradd;
            }
          return vendoradd;
        
    }
    
    
     global static FINETVendorLink__c getFINETVendorLink(boolean create,Id accountId,Id FINETVCUST,Id FINETVCUSTADD){
     
       FINETVendorLink__c vendorlink=new FINETVendorLink__c ();
        vendorlink.InternalAccount__c=accountId;
        vendorlink.FINETVCUST__c=FINETVCUST;
        vendorlink.FINETVCUSTADD__c=FINETVCUSTADD;
        vendorlink.VendorPaymentType__c='GAX';
        
        if(create){
            insert vendorlink;
            }
          return vendorlink;
    
    }
    
    global static r_mjr_prog__c getMajorProgram(boolean create){
    
    r_mjr_prog__c mjrprg=new r_mjr_prog__c();
    mjrprg.MJR_PROG_CD__c='1234567';
    mjrprg.MJR_PROG_NM__c='Dummy Program';
    mjrprg.MJR_PROG_SH_NM__c='Johnny';
    
    if(create){
            insert mjrprg;
            }
          return mjrprg;
    
    }
    
    global static r_prog__c getr_prog(boolean create,Id mjrprg,Id accountid){
    
    r_prog__c program=new r_prog__c();
    program.DEPT_CD__c=accountid;
    program.FINETMajorProgram__c=mjrprg;
    program.PROG_CD__c='123456';
    program.PROG_NM__c='Dummy';
    program.AREA__c='DummyArea';
    program.PROG_SH_NM__c='Johnny';
    
     
    if(create){
            insert program;
            }
          return program;
    
    } 
    
    
    
     global static GNT__SearchConfig__c getSearchConfig(Id phaseId, boolean create) {
        GNT__SearchConfig__c searchConfig = new GNT__SearchConfig__c();
        searchConfig.GNT__PhaseConfig__c= phaseId;
        searchConfig.GNT__SObject__c = 'Program__c';
        if (create) { 
            insert searchConfig ;
        }   
        return searchConfig ;
    }   
    global static GNT__SearchConfig__c getFlexSearchConfig(Id phaseId, Id flexId,boolean create) {
        GNT__SearchConfig__c searchConfig = new GNT__SearchConfig__c();
        searchConfig.GNT__PhaseConfig__c= phaseId;
        searchConfig.GNT__FlexTableConfig__c= flexId;
        searchConfig.GNT__SObject__c = 'Program__c';
        if (create) { 
            insert searchConfig ;
        }   
        return searchConfig ;
    }
    
    global static GNT__UserPreferences__c getUserPreference(boolean create,string fieldName, string fieldValue){
        GNT.UserPreferenceHelper.setBooleanValue('HideSidebar__c', true);
        GNT.UserPreferenceHelper.setBooleanValue('SidebarSearchCollapsed__c', true);
        GNT.UserPreferenceHelper.setBooleanValue('SidebarMenuCollapsed__c', true);        
        GNT.UserPreferenceHelper.setStringValue(fieldName, fieldValue);
       
        return GNT__UserPreferences__c.getInstance();
    }
    
    global static GNT__CustomAppFooterConfig__c getCustomAppFooterConfig(boolean create){
        GNT__CustomAppFooterConfig__c customAppFooterConfig= new GNT__CustomAppFooterConfig__c();
        customAppFooterConfig.GNT__Active__c = true;
        customAppFooterConfig.GNT__Sequence__c = 1;
        customAppFooterConfig.Name = 'StateAsGrantor';
        customAppFooterConfig.GNT__TargetURL__c = '/apex/test';
        customAppFooterConfig.GNT__DisplayText__c = 'test';
        customAppFooterConfig.GNT__CustomAppName__c= 'StateasGrantor';
        if(create){
            insert customAppFooterConfig; 
        }
        return customAppFooterConfig;
    }
    
    global static GNT__DataTableConfig__c getFlexDataTableConfig(boolean create){
        GNT__DataTableConfig__c dataTableConfig  = new GNT__DataTableConfig__c();
        dataTableConfig.Name = 'TestDataTable';
        dataTableConfig.GNT__SObject__c = 'Announcement__c';
        dataTableConfig.GNT__FieldNames__c = 'Id, Name,' + AppUtils.getNameSpacePrefix() + 'Program__r.Name';  
        dataTableConfig.GNT__FilterCriteria__c = 'Name != {!name} AND Name not in {!nameList} AND EligibleApplicantTypes__c includes {!eligibleAppType}';
        dataTableConfig.GNT__Description__c='TestDescription';  
             
        if(create){
            insert dataTableConfig  ;
        } 
            return dataTableConfig;      
    }
    
    global static GNT__DataTableConfig__c getFlexDataTableConfigForReport(boolean create){
        GNT__DataTableConfig__c dataTableConfig  = new GNT__DataTableConfig__c();
        dataTableConfig.Name = 'TestDataTable';
        dataTableConfig.GNT__SObject__c = 'Report';
        dataTableConfig.GNT__FieldNames__c = 'Id, Name';          
        if(create){
            insert dataTableConfig  ;
        } 
            return dataTableConfig  ;      
    }
    global static GNT__DataTableConfig__c getDataTableConfig(boolean create){
        GNT__DataTableConfig__c dataTableConfig  = new GNT__DataTableConfig__c();
        dataTableConfig.Name = 'TestDataTable';
        dataTableConfig.GNT__SObject__c = 'Announcement__c';
        dataTableConfig.GNT__FieldNames__c = 'Id, Name';       
        dataTableConfig.GNT__OrderBy__c = 'Name'; 
         dataTableConfig.GNT__Description__c='testDescription';
           
        if(create){
            insert dataTableConfig  ;
        } 
            return dataTableConfig  ;      
    }
    global static GNT__DataTableAction__c  getDataTableAction(Id dataTableConfigId, boolean create){
        GNT__DataTableAction__c dataTableAction = new GNT__DataTableAction__c(); 
        dataTableAction.GNT__DataTableConfig__c = dataTableConfigId;  
        dataTableAction.Name = 'Test Action';   
        dataTableAction.GNT__Sequence__c = 1;  
        dataTableAction.GNT__ActionURL__c = '/test/URL?istest={!istest}';  
        
        if(create){
            insert dataTableAction ;
        } 
            return dataTableAction ;   
    }
    
    //TEST HELPER METHOD FOR REVIEW PANEL CHANGES 
    global static ReviewPanelTemplate__c getReviewPanelTemplate(Id rstId, String recType, Boolean create){
        GNT__Package__c pkg = getPackage(true,'Review');

        ReviewPanelTemplate__c rpt = new ReviewPanelTemplate__c();
        Id recTypeId = Schema.SObjectType.ReviewPanelTemplate__c.getRecordTypeInfosByName().get(recType).getRecordTypeId();     
        rpt.RecordTypeId = recTypeId;
        rpt.Chair__c = UserInfo.getUserId();
        rpt.Sequence__c = 1;
        rpt.ReviewStepTemplate__c = rstId;
        rpt.ReviewPackage__c = pkg.id;
        rpt.EndDate__c=Date.Today().addDays(10);
        if(create){
            
            insert rpt;
        }
        return rpt;
    }
    
    global static TaskScheduleDetail__c getTaskScheduleDetail( boolean create) {
        Announcement__c ann = TestHelper.getAnnouncement(true);
        TaskSchedule__c ts = new TaskSchedule__c ();
        ts.ParentId__c = ann.Id;
        insert ts;
        TaskScheduleGroup__c tsg = new TaskScheduleGroup__c ();
        tsg.Name='test';
        User u = getAdminUser(true);
        tsg.AssignedTo__c = u.Id;
        tsg.TaskSchedule__c = ts.Id;
        insert tsg;
        TaskScheduleDetail__c tsd = new TaskScheduleDetail__c();
        tsd.EndDate__c = date.newInstance(2015, 9, 22);
        tsd.AssignedTo__c = u.Id;
        tsd.TaskScheduleGroup__c = tsg.Id;
        if(create){
            insert tsd;
        }
        return tsd;
    }
    
    global static Announcement__c getAnnouncement( boolean create ){
        System.debug('in getAnnouncement');
        Account acc = new Account();
        acc.Name = 'test'+system.currentTimeMillis();
        acc.status__c = 'Active';
        
        AppUtils.skipAccountTrigger=true;
       // AppUtils.skipDOH_ProgramTrigger = true;
        GNT.AppUtils.skipPhaseConfigTrigger=true;
      //  AppUtils.skipDOH_UserTrigger=true;
        ProgramTriggerHelper.skipTrigger=true;

        //SM
        //ApplicationTriggerHelper.skipTrigger = true;

        //SM
        GNT__PageLayoutConfig__c pageLayoutConfig =  getPageLayoutConfig(true);
        TestHelper.ggsTempPack1_PageTemplate(true,pageLayoutConfig);

        //TestHelper.getEmailTemplate(true,'RST_ApplicationPromotedEmail','RST_ApplicationPromotedEmail');
        //TestHelper.getEmailTemplate(true,'RST_ApplicationRejectionEmail','RST_ApplicationRejectionEmail');
        
        Program__c program = TestHelper.getProgram(acc.id,false);
        program.status__c = 'Active';
        insert program;
        System.debug('SM Program' + program.Id);
        GNT.UserPreferenceHelper.setStringValue('ActiveAppName__c', 'StateasGrantee');
        Announcement__c announcement =  new Announcement__c();
        announcement.Name = 'New Announcement';
        announcement.Status__c = 'Active';
       // announcement.NOFAPublicationDate__c = System.today()- 2;
        announcement.ApplicationDeadlineWithDateTime__c = System.today() + 30;
        announcement.FiscalYear__c = System.today().year()+'';
        
        announcement.Program__c = program.Id;
        if(create){
            insert announcement;  
        ReviewStepTemplate__c template = TestHelper.getReviewStepTemplateAnn(announcement.Id, false, 'Application');
        template.Program__c = program.Id;
        insert template;
        ReviewPanelTemplate__c rpt = TestHelper.getReviewPanelTemplate(template.Id, 'Application', true);
        system.debug('Review Panel Template@@@@'+rpt);
        PanelUserTemplate__c put = TestHelper.getPanelUserTemplate(rpt.Id, true);     
        }else{
        ReviewStepTemplate__c template = TestHelper.getReviewStepTemplate(program.Id, true, 'Application');
        ReviewPanelTemplate__c rpt = TestHelper.getReviewPanelTemplate(template.Id, 'Application', true);
        PanelUserTemplate__c put = TestHelper.getPanelUserTemplate(rpt.Id, true);
    
        }
        System.debug('in getAnnouncement' + announcement.Id);
        return announcement;  
    }


        global static Announcement__c getAnnouncementWithCons( boolean create, boolean ConstructionPackageIncluded){
        System.debug('in getAnnouncement');
        Account acc = new Account();
        acc.Name = 'test'+system.currentTimeMillis();
        acc.status__c = 'Active';
        
        AppUtils.skipAccountTrigger=true;
       // AppUtils.skipDOH_ProgramTrigger = true;
        GNT.AppUtils.skipPhaseConfigTrigger=true;
      //  AppUtils.skipDOH_UserTrigger=true;
        ProgramTriggerHelper.skipTrigger=true;

        //SM
        //ApplicationTriggerHelper.skipTrigger = true;

        //SM
        GNT__PageLayoutConfig__c pageLayoutConfig =  getPageLayoutConfig(true);
        TestHelper.ggsTempPack1_PageTemplate(true,pageLayoutConfig);

        //TestHelper.getEmailTemplate(true,'RST_ApplicationPromotedEmail','RST_ApplicationPromotedEmail');
        //TestHelper.getEmailTemplate(true,'RST_ApplicationRejectionEmail','RST_ApplicationRejectionEmail');
        
        Program__c program = TestHelper.getProgram(acc.id,false);
        program.status__c = 'Active';
        insert program;
        System.debug('SM Program' + program.Id);
        GNT.UserPreferenceHelper.setStringValue('ActiveAppName__c', 'StateasGrantee');
        Announcement__c announcement =  new Announcement__c();
        announcement.Name = 'New Announcement';
        announcement.Status__c = 'Active';
       // announcement.NOFAPublicationDate__c = System.today()- 2;
        announcement.ApplicationDeadlineWithDateTime__c = System.today() - 1;
        announcement.FiscalYear__c = System.today().year()+'';
        announcement.ConstructionPackageIncluded__c = ConstructionPackageIncluded;
        announcement.Program__c = program.Id;
        if(create){
            insert announcement;  
        ReviewStepTemplate__c template = TestHelper.getReviewStepTemplateAnn(announcement.Id, false, 'Application');
        template.Program__c = program.Id;
        insert template;
        ReviewPanelTemplate__c rpt = TestHelper.getReviewPanelTemplate(template.Id, 'Application', true);
        system.debug('Review Panel Template@@@@'+rpt);
        PanelUserTemplate__c put = TestHelper.getPanelUserTemplate(rpt.Id, true);     
        }else{
        ReviewStepTemplate__c template = TestHelper.getReviewStepTemplate(program.Id, true, 'Application');
        ReviewPanelTemplate__c rpt = TestHelper.getReviewPanelTemplate(template.Id, 'Application', true);
        PanelUserTemplate__c put = TestHelper.getPanelUserTemplate(rpt.Id, true);
    
        }
        System.debug('in getAnnouncement' + announcement.Id);
        return announcement;  
    }


        global static Announcement__c getGrantorAnnouncementWithProgram( Boolean create, Program__c program ){
        System.debug('in getGrantorAnnouncement');
        Account acc = new Account();
        acc.Name = 'test'+system.currentTimeMillis();
        acc.status__c = 'Active';

        GNT.UserPreferenceHelper.setStringValue('ActiveAppName__c','StateAsGrantor');
        
        AppUtils.skipAccountTrigger=true;
       // AppUtils.skipDOH_ProgramTrigger = true;
        GNT.AppUtils.skipPhaseConfigTrigger=true;
      //  AppUtils.skipDOH_UserTrigger=true;
        ProgramTriggerHelper.skipTrigger=true;

        //SM
        //ApplicationTriggerHelper.skipTrigger = true;

        //SM
        GNT__PageLayoutConfig__c pageLayoutConfig =  getPageLayoutConfig(true);
        TestHelper.ggsTempPack1_PageTemplate(true,pageLayoutConfig);

        TestHelper.getEmailTemplate(false,'RST_ApplicationPromotedEmail','RST_ApplicationPromotedEmail');
        TestHelper.getEmailTemplate(false,'RST_ApplicationRejectionEmail','RST_ApplicationRejectionEmail');
        
        GNT.UserPreferenceHelper.setStringValue('ActiveAppName__c', 'StateAsGrantor');
        ReviewStepTemplate__c template = TestHelper.getReviewStepTemplate(program.Id, true, 'Application');
        ReviewPanelTemplate__c rpt = TestHelper.getReviewPanelTemplate(template.Id, 'Application', true);
        PanelUserTemplate__c put = TestHelper.getPanelUserTemplate(rpt.Id, true);
        Announcement__c announcement =  new Announcement__c();
        announcement.Name = 'New Announcement';
        announcement.Status__c = 'Active';
       announcement.ApplicationDeadlineWithDateTime__c = System.today() - 1;
        announcement.FiscalYear__c = System.today().year()+'';        
        announcement.Program__c = program.Id;
        announcement.ProgramApprover__c = getAdminUser(true).id;
        if(create){
            insert announcement;   
        }
        System.debug('in getGrantorAnnouncement' + announcement.Id);
        return announcement;  
    }


       global static Announcement__c getGrantorAnnouncement( Boolean create ){
        System.debug('in getGrantorAnnouncement');
        Account acc = new Account();
        acc.Name = 'test'+system.currentTimeMillis();
        acc.status__c = 'Active';

        GNT.UserPreferenceHelper.setStringValue('ActiveAppName__c','StateAsGrantor');
        
        AppUtils.skipAccountTrigger=true;
       // AppUtils.skipDOH_ProgramTrigger = true;
        GNT.AppUtils.skipPhaseConfigTrigger=true;
      //  AppUtils.skipDOH_UserTrigger=true;
        ProgramTriggerHelper.skipTrigger=true;

        //SM
        //ApplicationTriggerHelper.skipTrigger = true;

        //SM
        GNT__PageLayoutConfig__c pageLayoutConfig =  getPageLayoutConfig(true);
        TestHelper.ggsTempPack1_PageTemplate(true,pageLayoutConfig);

        TestHelper.getEmailTemplate(false,'RST_ApplicationPromotedEmail','RST_ApplicationPromotedEmail');
        TestHelper.getEmailTemplate(false,'RST_ApplicationRejectionEmail','RST_ApplicationRejectionEmail');
        
        Program__c program = TestHelper.getGrantorProgram(acc.id,false);
        program.status__c = 'Active';
        insert program;
        System.debug('SM Program' + program.Id);
        GNT.UserPreferenceHelper.setStringValue('ActiveAppName__c', 'StateAsGrantor');
        ReviewStepTemplate__c template = TestHelper.getReviewStepTemplate(program.Id, true, 'Application');
        ReviewPanelTemplate__c rpt = TestHelper.getReviewPanelTemplate(template.Id, 'Application', true);
        PanelUserTemplate__c put = TestHelper.getPanelUserTemplate(rpt.Id, true);
        Announcement__c announcement =  new Announcement__c();
        announcement.Name = 'New Announcement';
        announcement.Status__c = 'Active';
       announcement.ApplicationDeadlineWithDateTime__c = System.today() - 1;
        announcement.FiscalYear__c = System.today().year()+'';        
        announcement.Program__c = program.Id;
        announcement.ProgramApprover__c = getAdminUser(true).id;
        if(create){
            insert announcement;   
        }
        System.debug('in getGrantorAnnouncement' + announcement.Id);
        return announcement;  
    }


 global static Announcement__c getGrantorAnnouncementAll( Boolean create ){
        System.debug('in getGrantorAnnouncement');
        Account acc = new Account();
        acc.Name = 'test'+system.currentTimeMillis();
        acc.status__c = 'Active';

        GNT.UserPreferenceHelper.setStringValue('ActiveAppName__c','StateAsGrantor');
        
        AppUtils.skipAccountTrigger=true;
       // AppUtils.skipDOH_ProgramTrigger = true;
        GNT.AppUtils.skipPhaseConfigTrigger=true;
      //  AppUtils.skipDOH_UserTrigger=true;
       // ProgramTriggerHelper.skipTrigger=true;

        //SM
        //ApplicationTriggerHelper.skipTrigger = true;

        //SM
        GNT__PageLayoutConfig__c pageLayoutConfig =  getPageLayoutConfig(true);
        TestHelper.ggsTempPack1_PageTemplate(true,pageLayoutConfig);


       // TestHelper.getEmailTemplate(true,'RST_ApplicationPromotedEmail','ApplicationSubmissionEmailTemplate');
        //TestHelper.getEmailTemplate(true,'RST_ApplicationRejectionEmail','ApplicationSubmissionEmailTemplate');
        System.debug('*Before creating program*');
        Program__c program = TestHelper.getGrantorProgram(acc.id,false);
        program.status__c = 'Active';
        insert program;
        System.debug('SM Program' + program.Id);
        GNT.UserPreferenceHelper.setStringValue('ActiveAppName__c', 'StateAsGrantor');
        ReviewStepTemplate__c template = TestHelper.getReviewStepTemplate(program.Id, true, 'Application');
        ReviewPanelTemplate__c rpt = TestHelper.getReviewPanelTemplate(template.Id, 'Application', true);
        PanelUserTemplate__c put = TestHelper.getPanelUserTemplate(rpt.Id, true);
        Announcement__c announcement =  new Announcement__c();
        announcement.Name = 'New Announcement';
        announcement.Status__c = 'Active';
       announcement.ApplicationDeadlineWithDateTime__c = System.today() - 1;
        announcement.FiscalYear__c = System.today().year()+'';        
        announcement.Program__c = program.Id;
        announcement.ProgramApprover__c = getAdminUser(true).id;
        if(create){
            insert announcement;   
        }
        System.debug('in getGrantorAnnouncement' + announcement.Id);
        return announcement;  
    }


    global static Announcement__c getAnnouncement(Id  programId,boolean create ){        
        Announcement__c announcement =  new Announcement__c();
        announcement.Name = 'New Announcement';
        announcement.Status__c = 'Active';
        
        
       
        //announcement.NOFAPublicationDate__c = System.today();
        announcement.ApplicationDeadlineWithDateTime__c = System.today()+2;
        announcement.FiscalYear__c = System.today().year()+'';
        
       
        announcement.Program__c = programId;
        if(create){
            insert announcement;   
        }
        return announcement;  
    }
    
    global static PanelUserTemplate__c getPanelUserTemplate(Id reviewStepTempate,boolean create){
        PanelUserTemplate__c PanelUserTemplate = new PanelUserTemplate__c();
        PanelUserTemplate.Name = 'PanelUser1';
        PanelUserTemplate.Reviewer__c = UserInfo.getUserId();
        PanelUserTemplate.ReviewPanelTemplate__c = reviewStepTempate;
        if(create){
            insert PanelUserTemplate;   
        }
        return PanelUserTemplate;
    }
    
    global static ReviewStepTemplate__c getReviewStepTemplate(Id  programId,boolean create,String recType ){        
        ReviewStepTemplate__c reviewStepTemplate =  new ReviewStepTemplate__c();
        reviewStepTemplate.Name = 'New ReviewStepTemplate';
        Id recTypeId = Schema.SObjectType.ReviewStepTemplate__c.getRecordTypeInfosByName().get(recType).getRecordTypeId();     
        reviewStepTemplate.RecordTypeId = recTypeId;
        reviewStepTemplate.StepNumber__c=1;
        reviewStepTemplate.Program__c = programId;
        if(create){
            insert reviewStepTemplate;   
        }
        return reviewStepTemplate;  
    }

     global static ReviewStepTemplate__c getReviewStepTemplateAnn(Id  announcementId,boolean create,String recType){        
        ReviewStepTemplate__c reviewStepTemplate =  new ReviewStepTemplate__c();
        reviewStepTemplate.Name = 'New ReviewStepTemplate';
        Id recTypeId = Schema.SObjectType.ReviewStepTemplate__c.getRecordTypeInfosByName().get(recType).getRecordTypeId();     
        reviewStepTemplate.RecordTypeId = recTypeId;
        reviewStepTemplate.StepNumber__c=1;
        reviewStepTemplate.ApplicationAssignment__c='Auto-Assign to All';
        reviewStepTemplate.Announcement__c = announcementId;
        
        if(create){
            insert reviewStepTemplate;   
        }
        return reviewStepTemplate;  
    }
         
    global static Application__c getApplication(Id announcementId,boolean create){
        Account acc=getAccount(true);
        Contact contact = new Contact(Firstname='FirstName', Lastname='LastName',Email='email@email.com', Title='Title',Phone ='123-123-1234',Account=acc);
        insert contact;
        Application__c application = new Application__c();
        application.Announcement__c = announcementId;
        application.Name = 'APP-001';
        application.ApplicationType__c = 'TBD';
        application.ExternalOrganization__c=acc.id;
        application.ApplicationDeadlineWithDateTime__c = System.now() + 30;
        application.ProposalDescription__c = 'Test';
        
        

        if(create){
            insert application;
        }
        return application; 
    }

     global static Application__c getGrantorApplication(Id announcementId,boolean create){
        Account acc=getAccount(true);
       // Contact contact = new Contact(Firstname='FirstName', Lastname='LastName',Email='email@email.com', Title='Title',Phone ='123-123-1234',Account=acc);
        //insert contact;
        Application__c application = new Application__c();
        application.Announcement__c = announcementId;
        application.Name = 'APP-001';
        application.ApplicationType__c = 'TBD';
        application.ExternalOrganization__c=acc.id;
        
        

        if(create){
            insert application;
        }
        return application; 
    }


    global static Application__c getSubmittedApplication(Id announcementId,boolean create){
        Application__c application = new Application__c();
        application.Announcement__c = announcementId;
        application.Name = 'APP-001';
        application.ApplicationType__c = 'TBD';
        application.SubmittedOn__c = system.today();
        

        if(create){
            insert application;
        }
        return application; 
    }
  
    
    global static Application__c getApplicationHistory(Id announcementId, Id historyParentRecordId, boolean create){
        Application__c application = new Application__c();
        application.Announcement__c = announcementId;
        application.Name = 'APP-008';
        application.ApplicationType__c = 'TBD';
        application.IsHistory__c = true;
        application.HistoryReason__c = 'Simple Test History';
        application.HistoryParentId__c = historyParentRecordId;
        
        if(create){
            insert application;
        }
        return application; 
    }
    
    /*
        Creates an Announcement and attaches the attachment to the Announcement
    */
    global static Attachment getAttachment(Id parentId, boolean create){
        
        Attachment attachementInstance = new Attachment();
        attachementInstance.Name = 'Test Attachment';
        attachementInstance.Body = Blob.valueOf('This is a test body');
        attachementInstance.ParentId = parentId;
        
        if(create){
            insert attachementInstance;
        }
        return attachementInstance;
    }
    
    global static GNT__AttachmentExtension__c getAttachmentExtension(String classification, Id parentId, boolean create){
        Attachment attachementInstance = getAttachment(parentId, true);
        GNT__AttachmentExtension__c attachmentExtension = new GNT__AttachmentExtension__c();
        attachmentExtension.GNT__Classification__c = classification;
        attachmentExtension.GNT__Attachment__c = attachementInstance.Id;
        attachmentExtension.GNT__ParentId__c = parentId;
        
        if(create){
            insert attachmentExtension;
        }
        return attachmentExtension;
    }
    
    global static GNT__Highlight__c getHighlight(boolean create){
        GNT__Highlight__c highlightInstance = new GNT__Highlight__c();
        highlightInstance.GNT__Summary__c = 'Sample Highlight Summary';
        highlightInstance.GNT__StartDate__c = Date.today();
        highlightInstance.GNT__EndDate__c = Date.today().addDays(2);
        
        Id recordTypeId = Schema.Sobjecttype.GNT__Highlight__c.getRecordTypeInfosByName().get('Internal').getRecordTypeId();
        highlightInstance.RecordTypeId = recordTypeId;
        if(create){
            insert highlightInstance;
        }
        return highlightInstance;
    }
    
    global static GNT__RecordCopyConfig__c getCopyConfig(boolean create) {
        GNT__RecordCopyConfig__c record = new GNT__RecordCopyConfig__c( GNT__SourceObjectName__c='Account',  GNT__SourceFieldName__c='Name',  GNT__TargetObjectName__c='Contact',
                         GNT__TargetFieldName__c='Firstname');
        if (create) {
            insert record;
        }
        return record;
    }

     global static Grant__c getGrant(boolean create){
        Grant__c grants = new Grant__c();
        User u = getAdminUser(true);
        grants.recordTypeId = getRecordType(Schema.SObjectType.Grant__c, 'Grantor');
        grants.GranteePOC__c = u.Id;
        grants.Name='abcd';
        grants.ProjectPeriodStartDate__c=System.today();
        grants.ProjectPeriodEndDate__c=System.today();
            if(create){
                insert grants ;
            }
            return grants ;
     }
     
    
      global static Award__c getAwards(Id grantID,boolean create){
        Award__c awards  = new Award__c();
        awards.grant__c = grantID;
        awards.Name = Math.Random()+'AW12';
        awards.OrganizationName__c = 'Test Org';
        awards.OrganizationAddress__c = 'Test Address';
        awards.FiscalYear__c = '2013';
        awards.SupportYear__c = Decimal.valueOf('2013');
        awards.Status__c = 'Issued';
            if(create){
                insert awards;
            }
            return awards;
      }
    
    
    global static Application__c getupdatedApplication(Id applicationId, boolean submit){
      Application__c application = new Application__c(Id = applicationId);

      if(submit){
        application.Status__c =  'Submitted';
      }
      else if (submit == false){
         application.Status__c =  'Complete';
      }
      update application;
      return application; 
    } 
    
    global static boolean deleteApplication(Id applicationId){
      Application__c application = new Application__c(Id = applicationId);
      delete application;
     return true;   
    }     
    
    global static GNT__NameTemplateSequence__c getNameTemplateSequence(boolean create){
        GNT__NameTemplateSequence__c templateSeq = new GNT__NameTemplateSequence__c(); 
        templateSeq.Name = 'APP-New Announcement-TBD-';  // this will be equal to the formula name 
        String nameSpace = AppUtils.getNameSpacePrefix();
        templateSeq.GNT__ObjectName__c = nameSpace+'Application__c';
        templateSeq.GNT__StartSequence__c = 1000;
        templateSeq.GNT__Year__c = System.today().year();
        if(create){
            insert templateSeq;
        }
        return templateSeq;
    }
    
     
    global static GNT__NameTemplateConfig__c getNameTemplateConfig(boolean create){
        GNT__NameTemplateConfig__c config = new GNT__NameTemplateConfig__c();
        String nameSpace = AppUtils.getNameSpacePrefix();
        config.Name = nameSpace+'Application__c';   
        config.GNT__Active__c = true;   
        config.GNT__AutoNumberFormat__c = '{00000}-{YYYY}';
        config.GNT__StartNumber__c = 0;
        config.GNT__FormulaFieldName__c = AppUtils.getNameSpacePrefix()+'NameTemplate__c';
        config.GNT__SkipAutoNumberReset__c = false; 
        if(create){  
            insert config; 
        }
        return config; 
    }
    
    
   global static GNT__NameTemplateSequence__c getNameTemplateSequenceAnnouncement(boolean create){
        GNT__NameTemplateSequence__c templateSeq = new GNT__NameTemplateSequence__c(); 
        templateSeq.Name = 'ANN-New Grants Program1-';  // this will be equal to the formula name 
        String nameSpace = AppUtils.getNameSpacePrefix();
        templateSeq.GNT__ObjectName__c = nameSpace+'Announcement__c'; 
        templateSeq.GNT__StartSequence__c = 1000; 
        templateSeq.GNT__Year__c = System.today().year();
        if(create){ 
            insert templateSeq;
        }
        return templateSeq;
    }
     

    global static GNT__NameTemplateConfig__c getNameTemplateConfigAnnouncement(boolean create){
        GNT__NameTemplateConfig__c config = new GNT__NameTemplateConfig__c();
        String nameSpace = AppUtils.getNameSpacePrefix();
        config.Name = nameSpace+'Announcement__c';     
        config.GNT__Active__c = true;   
        config.GNT__AutoNumberFormat__c = '{00000}-{YYYY}';
        config.GNT__StartNumber__c = 0;
        config.GNT__FormulaFieldName__c = nameSpace+'NameTemplate__c'; 
        config.GNT__SkipAutoNumberReset__c = false;  
        if(create){  
            insert config; 
        }
        return config; 
    }
    
    global static String getFundsChartData(){
      String Year = '2014';
              return Year;
    } 
    
     global static Integer getActiveProgramData(){
     Integer Year = 2014;
              return Year;
    } 
    
   
    global static List<Document> createPostInstallScriptData(){ String ns = AppUtils.getNamespacePrefix(); 
        String csvBodyPostInstallScript = 'Name,' + ns+'Install__c,'+ns+'Sequence__c  \n' + ns+'NameTemplateConfig__c,true,1\n' +ns+ 
                'CustomAppConfig__c,true,2\n' +ns+ 'PhaseConfig__c,true,3';        
        String csvBodyNameTemplateConfig  = 'NAME,'+ns+'ACTIVE__C,'+ns+'AUTONUMBERFORMAT__C,'+ns+'FORMULAFIELDNAME__C,'+ns+'SKIPAUTONUMBERRESET__C,'+
                ns+'STARTNUMBER__C \n'+ns+'Application__c,TRUE,{000000}-{YY},'+ns+'NameTemplate__c,TRUE,2000';                                                 
        String csvCustomAppConfig ='NAME,'+ns+'ACTIVE__C,'+ns+'LABEL__C,'+ns+'SEQUENCE__C,'+ns+'GNT__URL__c,'+ns+
                'REPORTSFOLDERNAME__C \nStateAsGrantee,true,State as Grantee,1,/apex/PhaseView?t=GranteeHome,Admin';
        String csvPhaseConfig = 'ID,NAME,'+ns+'GNT__AccordionHeader__c,'+ns+'ACTIVE__C,'+ns+'BODYPAGEINCLUDEURL__C,'+ns+'BODYTABLE__C,'+ns+
                'CUSTOMAPPNAME__C,'+ns+'GNT__EnableExternalLinks__c,'+ns+'ENABLEMENU__C,'+ns+'ENABLERECENTLYVIEWED__C,'+ns+'ENABLESEARCH__C,'+
                ns+'GNT__GroupName__c,'+ns+'GNT__SObject__c,'+ns+'GNT__SearchResultPage__c,'+ns+'SELECTEDBYDEFAULT__C,'+ns+'SEQUENCE__C,'+ns+'GNT__SidebarComponentSequence__c,'+
                ns+'GNT__SidebarExternalLinksLabel__c,'+ns+'GNT__SidebarRecentlyViewedLabel__c,'+ns+'GNT__SidebarSearchLabel__c,'+ns+'GNT__TabName__c,'+
                ns+'GNT__URL__c,'+ns+'GNT__Abbreviation__c,'+ns+'BODYBOTTOMPAGEURL__C,'+ns+'FLEXTABLEPARAMETERS__C,'+ns+'PhaseType__c,'+ns+'TOTALCHARTSALLOWEDPERROW__C,'+
                ns+'TOTALCHARTSALLOWED__C'+
                '\n a0eG00000064gXmIAI,Admin,Actions,TRUE,,a0JG000000PsF88MAF,Admin,FALSE,TRUE,FALSE,FALSE,1,,,TRUE,1,SubMenu,,,,,Admin,' + 
                '/apex/PhaseView?t=Admin,Adm,,orgType=Division,Home,,,';
         
        List<Document> lstDocument = new List<Document>();  
        Folder folder = [Select Id From Folder  limit 1 ]; 
                     
         
        Document postInstallScript = new Document(Name= ns+'PostInstallConfig__c', Body = Blob.valueOf(csvBodyPostInstallScript) , FolderId =folder.Id);
        insert postInstallScript; 
        lstDocument.add(postInstallScript);
        Document nameTemplateConfigScript = new Document(Name= ns+'NameTemplateConfig__c', Body = Blob.valueOf(csvBodyNameTemplateConfig) , FolderId =folder.Id);
        insert nameTemplateConfigScript;
        lstDocument.add(nameTemplateConfigScript);
        Document customAppConfigScript = new Document(Name= ns+'CustomAppConfig__c', Body = Blob.valueOf(csvCustomAppConfig)  , FolderId =folder.Id);  
        insert customAppConfigScript; 
        
        Document phaseConfigScript = new Document(Name= ns+'PhaseConfig__c', Body = Blob.valueOf(csvPhaseConfig)  , FolderId =folder.Id);  
        insert phaseConfigScript;  
         
        
        List<GNT__CustomAppConfig__c> CustomAppConfiglst  = [Select Id ,Name from GNT__CustomAppConfig__c Limit 1000];
         
        
        lstDocument.add(customAppConfigScript);
        return lstDocument;
    } 
      
     
          
     global static GNT__ChartConfig__c getChartConfig(Boolean create) {
        GNT__PhaseConfig__c phase = getPhase(false);
        phase.GNT__Abbreviation__c = 'P01';
        insert phase;
        GNT__ChartConfig__c ChartConfig = new GNT__ChartConfig__c(GNT__ObjectName__c='Announcement__c',Name='Announcement Chart',GNT__Title__c='Announcement Chart',
                    GNT__PhaseConfig__c = phase.id);
        if (create) {  
            insert ChartConfig ;
        }
        return ChartConfig ;
    }
    
    global static Id getRecordType(DescribeSObjectResult sobjType, String recordTypeName) {
        return sobjType.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
    }
    
    global static GNT__ChartConfig__c getActiveProgramsChartConfig(Boolean create, Id phaseConfigId) {
        GNT__ChartConfig__c ChartConfig = new GNT__ChartConfig__c(Name='ActivePrograms', GNT__ObjectName__c='Program__c', GNT__Title__c='Total Active Programs',
                    GNT__ChartPageURL__c='/apex/testPageUrl', GNT__PhaseConfig__c = phaseConfigId, GNT__FilterFieldNames__c=AppUtils.getNamespacePrefix()+'StartDate__c;'+AppUtils.getNamespacePrefix()+'EndDate__c', 
                    RecordTypeId=getRecordType(Schema.SObjectType.GNT__ChartConfig__c, 'Bar - Stacked'));
        if (create) {  
            insert ChartConfig ;
        }
        return ChartConfig ;
    }
    
    global static GNT__ChartConfig__c getTotalFundingChartConfig(Boolean create, Id phaseConfigId) {
        GNT__ChartConfig__c ChartConfig = new GNT__ChartConfig__c(Name='TotalFunding', GNT__ObjectName__c='FundingSourceYear__c', GNT__Title__c='Total Funding',
                GNT__ChartPageURL__c='/apex/testPageUrl', GNT__PhaseConfig__c = phaseConfigId, GNT__FilterFieldNames__c=AppUtils.getNamespacePrefix()+'FiscalYear__c', 
                RecordTypeId=getRecordType(Schema.SObjectType.GNT__ChartConfig__c, 'Pie - Basic'));
        if (create) {  
            insert ChartConfig ;
        }
        return ChartConfig ;
    }
     global static GNT__ChartConfig__c getTotalFundingSourceYearChartConfig(Boolean create, Id phaseConfigId) {
        GNT__ChartConfig__c ChartConfig = new GNT__ChartConfig__c(Name='Funds Summary', GNT__ObjectName__c='FundingSourceYear__c', GNT__Title__c='Funds Summary',
                    GNT__ChartPageURL__c='/apex/testPageUrl', GNT__PhaseConfig__c = phaseConfigId, GNT__FilterFieldNames__c=AppUtils.getNamespacePrefix()+'FiscalYear__c', 
                    RecordTypeId=getRecordType(Schema.SObjectType.GNT__ChartConfig__c, 'Pie - Basic'));
        if (create) {  
            insert ChartConfig ;
        }
        return ChartConfig ;
    }
    global static GNT__ChartConfig__c getTotalAnnouncementChartConfig(Boolean create, Id phaseConfigId) {
        GNT__ChartConfig__c ChartConfig = new GNT__ChartConfig__c(Name='TotalAnnouncement', GNT__ObjectName__c=AppUtils.getNameSpacePrefix()+'Announcement__c', 
                    GNT__Title__c='Total Announcement',GNT__ChartPageURL__c='/apex/testPageUrl', GNT__PhaseConfig__c = phaseConfigId, GNT__FilterFieldNames__c=AppUtils.getNamespacePrefix()+'FiscalYear__c', 
                    RecordTypeId=getRecordType(Schema.SObjectType.GNT__ChartConfig__c, 'Bar - Stacked'));
        if (create) {  
            insert ChartConfig ;
        }
        return ChartConfig ;
    }
    
    global static FundingSource__c getFundingSource(Boolean create) {
        FundingSource__c fs = new FundingSource__c(OrganizationName__c ='TestOrganization'+System.today(), FundingSourceID__c=''+System.today(), 
                    Type__c='State', Status__c = 'Active');
        if (create) {  
            insert fs ;
        }
        return fs ;
    }
    
    global static FundingAccount__c getFundingAccount(Boolean create, Id fundingSourceId) {
     //   FundingAccount__c  fa= new FundingAccount__c(Name='Test Funding Account',FundingSource__c = fundingSourceId, Status__c = 'Active');
        FundingAccount__c  fa= new FundingAccount__c(FundingSource__c = fundingSourceId, Status__c = 'Active');
        if (create) {  
            insert fa ;
        }
        return fa ;
    }
    

 
    global static PreApplication__c getPreApplication(Boolean create){
        //GNT__PageTemplate__c pt = TestHelper.ggsTempPack1_PageTemplate(true);
        Announcement__c announcement = getAnnouncement(true);
        PreApplication__c preApp = new PreApplication__c(Name = 'Test Pre-Application',announcement__c = announcement.id);
        preApp.NumberOfReviewsInProgress__c = 0;
        preApp.NumberOfReviewsFinalized__c = 0;
        preApp.NumberOfReviewersAssigned__c = 0;
        preApp.NumberOfStepsAddedTo__c = 0;
        if (create) {  
            insert preApp ;
        }
        return preApp ;
       
    }
     global static PreApplication__c getPreApplication(Id announcementId,boolean create){
        PreApplication__c preApp = new PreApplication__c();
        preApp.Announcement__c = announcementId;
        if(create){
            insert preApp;
        }
        return preApp; 
    }

    global static PreApplication__c getSubmittedPreApplication(Id announcementId,boolean create){
        PreApplication__c preApp = new PreApplication__c();
        preApp.Announcement__c = announcementId;
        preApp.SubmittedOn__c  = system.today();
        if(create){
            insert preApp;
        }
        return preApp; 
    }
        
     global static ReviewGroup__c getReviewGroup(boolean create){
     ReviewGroup__c  reviewGrp = new ReviewGroup__c (Announcement__c = getGrantorAnnouncement(true).id,NumberOfReviewSteps__c= Decimal.valueOf('10.0'));
            if (create) {  
            insert reviewGrp ;
        }
        return reviewGrp ;
      } 
        

   global static ReviewGroup__c getReviewGroupAll(boolean create){
     ReviewGroup__c  reviewGrp = new ReviewGroup__c (Announcement__c = getGrantorAnnouncementAll(true).id,NumberOfReviewSteps__c= Decimal.valueOf('10.0'));
            if (create) {  
            insert reviewGrp ;
        }
        return reviewGrp ;
      } 

     global static ReviewStep__c getReviewStep(boolean create){
        ReviewStep__c reviewStep= new ReviewStep__c (ReviewGroup__c = getReviewGroup(true).id,name = 'Step 1',StepNumber__c=1);
        reviewStep.ReviewStepTemplate__c = [Select Id From ReviewStepTemplate__c Where Announcement__c = :reviewStep.ReviewGroup__r.Announcement__c Order by StepNumber__c LIMIT 1].Id;
        
        if (create) {  
            insert reviewStep;
        }
        return reviewStep;
       
     } 

     

     
      global static ReviewStepUser__c getReviewStepUser(boolean create){
      ReviewStepUser__c reviewStepUser= new ReviewStepUser__c(ReviewStep__c = getReviewStep(true).id,Reviewer__c=UserInfo.getUserId());
      if (create) {  
            insert reviewStepUser;
        }
        return reviewStepUser;
       
     } 

    
     global static PreApplication__c getupdatedPreApplication(Id preapplicationId, boolean submit){
     PreApplication__c preapplication = new PreApplication__c(Id = preapplicationId);

      if(submit){
        preapplication.Status__c =  'Submitted';
      }
      else if (submit == false){
         preapplication.Status__c =  'Complete';
      }
      update preapplication;
      return preapplication; 
    } 
    
    global static boolean deletePreApplication(Id preapplicationId){
      PreApplication__c preapp = new PreApplication__c(Id = preapplicationId);
      delete preapp;
      return true;  
    }   
    
    
    global static ProgramFundingAccount__c getProgramFundingAccount(Boolean create, Id fundingAccountId, Id programId){
         
        ProgramFundingAccount__c programFundingAccount = new ProgramFundingAccount__c(FundingAccount__c = fundingAccountId,Program__c = programId); 
        if(create){ 
            insert programFundingAccount;
        }
        return programFundingAccount;
    }
    
    /** assert equals **/
    global static void assertEquals(String[] expected, String[] actual) {
        System.assertEquals(expected.size(), actual.size());
        for(Integer i=0; i<expected.size(); i++) {
            System.assertEquals(expected[i], actual[i]);
        }
    }
  

    global static TermCondition__c getTermCondition(Boolean create, String recordType){
        GNT__PageTemplate__c pt = getPageTemplateConfig(true);
        GNT__Package__c pack = getPackage(false, pt);
        pack.GNT__SubmissionType__c = 'Post Award Submission';
        pack.GNT__LatestVersion__c = true;
        pack.GNT__Status__c = 'Active';
        insert pack;
        TermCondition__c obj = new TermCondition__c(UpcomingReportSubmissionDate__c=System.today(), SubmissionPackage__c = pack.id);
        obj.RecordTypeId = Schema.SObjectType.TermCondition__c.getRecordTypeInfosByName().get(recordType).getRecordTypeId();
        if(create){ 
            insert obj;
        }
        return obj;
    }    
    

    global static EmailTemplate getEmailTemplate(boolean create,String name,String developer){
        system.debug('Record Information : ' + [Select Id From Folder Where Name ='GovGrants_Email_Templates' and Type = 'Email' ]);
        List<Folder> lstFolder = [Select Id From Folder Where DeveloperName ='GovGrants_Email_Templates' and Type = 'Email' ];                                
        system.debug('Size of the folder : ' + lstFolder.size());
        EmailTemplate e;
        if(lstFolder.size() > 0){
            e=new EmailTemplate(TemplateType= 'Text', Name = name,FolderId=lstFolder.get(0).Id,developerName =developer);                    
        }        
        if (create) {  
            insert e;
        }
        return e;
    }

    global static GNT__GridHeaderConfig__c getGridHeader(Boolean create) {
        String ns = AppUtils.getNameSpacePrefix();
        GNT__GridHeaderConfig__c h = new  GNT__GridHeaderConfig__c(GNT__UniqueName__c='TestName' + String.valueOf(System.Now().getTime()),GNT__SObjectName__c=ns+'ApplicationBudgetCategory__c', GNT__GridTitle__c='test',
            GNT__DisplayFields__c='Name, ' + ns + 'Year1Amount__c, ' + ns + 'Year2Amount__c', GNT__ParentRelationshipField__c=ns+'Application__c',
            GNT__ReadOnlyFields__c=ns + 'Year3Amount__c', GNT__RowNumberIdentifierField__c=ns+'RowNumber__c');
        if (create) {
            insert h;
        }
        return h;
    }

    global static GNT__GridDetailConfig__c getGridDetail(Id headerId, Boolean create) {
        GNT__GridDetailConfig__c detail = new GNT__GridDetailConfig__c(GNT__GridHeaderConfig__c=headerId, GNT__RowNumber__c=1);
        if (create) {
            insert detail;
        }
        return detail;
    }

    global static Review__c getReview(boolean create){
        Announcement__c ann = getGrantorAnnouncement(true); 
        Application__c app = getApplication(ann.id,true);
    
        ReviewPanelTemplate__c panelTemplate = [SELECT ID,Name,ReviewStepTemplate__c, ReviewPackage__c from ReviewPanelTemplate__c where ReviewStepTemplate__r.Program__c = :ann.Program__c ];

        ReviewGroupTriggerHelper.skipTrigger = true;
        ReviewGroup__c reviewGroup = new ReviewGroup__c();
        reviewGroup.Announcement__c = ann.id;
        reviewGroup.NumberOfReviewSteps__c= Decimal.valueOf('1.0');
        insert reviewGroup;

        system.debug('*** review group' + reviewGroup.Id);
       
        ReviewStep__c reviewStep = [Select Id From ReviewStep__c Where ReviewGroup__c = :reviewGroup.Id];

        
        ReviewStepUser__c reviewStepUser = new ReviewStepUser__c();
        reviewStepUser.ReviewStep__c = reviewStep.id;
        reviewStepUser.Reviewer__c=UserInfo.getUserId();
        insert reviewStepUser;

        ReviewPanel__c reviewPanel = new ReviewPanel__c();
        reviewPanel.ReviewStep__c = reviewStep.id;
        reviewPanel.ReviewPackage__c = panelTemplate.ReviewPackage__c;
        reviewPanel.GroupId__c = 'testID';
        reviewPanel.Sequence__c = 1;
        User u = getAdminUser(true);
        reviewPanel.Chair__c = u.id;
        insert reviewPanel;

        PanelUser__c panelUser = new PanelUser__c();
        panelUser.Reviewer__c = getPortalUser(true).id;
        panelUser.ReviewPanel__c = reviewPanel.id;       
        insert panelUser; 

        PanelApplication__c panelApplication = new PanelApplication__c();
        panelApplication.Application__c = app.id;
        panelApplication.ReviewPanel__c = reviewPanel.id;
        insert panelApplication;

        Review__c review = new Review__c();
        review.Application__c = app.id;
        review.PanelApplication__c = panelApplication.id;
        review.PanelUser__c=panelUser.id;
        review.ReviewPanel__c = reviewPanel.id;
        review.Status__c = 'Review Completed';
        if(create){
            insert review;
        }
        return review;

    }


     global static Review__c getGrantorReview(Announcement__c ann, boolean create){
      //  Announcement__c ann = getGrantorAnnouncement(true); 
     //   Announcement__c ann = [Select Id,Program__c from Announcement__c where id=:annId ];
        Application__c app = getApplication(ann.id,true);
    
        ReviewPanelTemplate__c panelTemplate = [SELECT ID,Name,ReviewStepTemplate__c, ReviewPackage__c from ReviewPanelTemplate__c where ReviewStepTemplate__r.Program__c = :ann.Program__c Limit 1];

        ReviewGroup__c reviewGroup = new ReviewGroup__c();
        reviewGroup.Announcement__c = ann.id;
        reviewGroup.NumberOfReviewSteps__c= Decimal.valueOf('1.0');
        insert reviewGroup;

        ReviewStep__c reviewStep = new ReviewStep__c(ReviewGroup__c = reviewGroup.Id);
        //ReviewStep__c reviewStep = [Select Id From ReviewStep__c Where ReviewGroup__c = :reviewGroup.Id Limit 1];
        insert reviewStep;
        
        ReviewStepUser__c reviewStepUser = new ReviewStepUser__c();
        reviewStepUser.ReviewStep__c = reviewStep.id;
        reviewStepUser.Reviewer__c=UserInfo.getUserId();
        insert reviewStepUser;

        ReviewPanel__c reviewPanel = new ReviewPanel__c();
        reviewPanel.ReviewStep__c = reviewStep.id;
        reviewPanel.ReviewPackage__c = panelTemplate.ReviewPackage__c;
        reviewPanel.GroupId__c = 'testID';
        reviewPanel.Sequence__c = 1;
       // User u = getAdminUser(true);
      //  reviewPanel.Chair__c = u.id;
        insert reviewPanel;

        PanelUser__c panelUser = new PanelUser__c();
        panelUser.Reviewer__c = getPortalUser(true).id;
        panelUser.ReviewPanel__c = reviewPanel.id;       
        insert panelUser; 

        PanelApplication__c panelApplication = new PanelApplication__c();
        panelApplication.Application__c = app.id;
        panelApplication.ReviewPanel__c = reviewPanel.id;
        insert panelApplication;

        ReviewStepApplication__c reviewStepApp = new ReviewStepApplication__c();
        reviewStepApp.ReviewStep__c = reviewStep.Id;
        reviewStepApp.application__c = app.Id;
        reviewStepApp.Status__c = 'Approved';
        insert reviewStepApp;

        Review__c review = new Review__c();
        review.Application__c = app.id;
        review.PanelApplication__c = panelApplication.id;
        review.PanelUser__c=panelUser.id;
        review.ReviewPanel__c = reviewPanel.id;
        review.Status__c = 'Review Completed';
        review.ReviewStep__c=reviewStep.Id;
        review.Recommendation__c='Recommended';
        if(create){
            insert review;
        }
        return review;

    }

     global static Review__c getGrantorPreAppReview(Announcement__c ann, boolean create){
        PreApplication__c app = getPreApplication(ann.id,true);    
        ReviewPanelTemplate__c panelTemplate = [SELECT ID,Name,ReviewStepTemplate__c, ReviewPackage__c from ReviewPanelTemplate__c where ReviewStepTemplate__r.Program__c = :ann.Program__c Limit 1];
        ReviewGroup__c reviewGroup = new ReviewGroup__c();
        reviewGroup.Announcement__c = ann.id;
        reviewGroup.NumberOfReviewSteps__c= Decimal.valueOf('1.0');
        insert reviewGroup;
       
        ReviewStep__c reviewStep = [Select Id From ReviewStep__c Where ReviewGroup__c = :reviewGroup.Id Limit 1];
        
        ReviewStepUser__c reviewStepUser = new ReviewStepUser__c();
        reviewStepUser.ReviewStep__c = reviewStep.id;
        reviewStepUser.Reviewer__c=UserInfo.getUserId();
        insert reviewStepUser;

        ReviewPanel__c reviewPanel = new ReviewPanel__c();
        reviewPanel.ReviewStep__c = reviewStep.id;
        reviewPanel.ReviewPackage__c = panelTemplate.ReviewPackage__c;
        reviewPanel.GroupId__c = 'testID';
        reviewPanel.Sequence__c = 1;
       // User u = getAdminUser(true);
      //  reviewPanel.Chair__c = u.id;
        insert reviewPanel;

        PanelUser__c panelUser = new PanelUser__c();
        panelUser.Reviewer__c = getPortalUser(true).id;
        panelUser.ReviewPanel__c = reviewPanel.id;       
        insert panelUser; 

        PanelApplication__c panelApplication = new PanelApplication__c();
        panelApplication.Preapplication__c = app.id;
        panelApplication.ReviewPanel__c = reviewPanel.id;
        insert panelApplication;

        ReviewStepApplication__c reviewStepApp = new ReviewStepApplication__c();
        reviewStepApp.ReviewStep__c = reviewStep.Id;
        reviewStepApp.Preapplication__c = app.Id;
        reviewStepApp.Status__c = 'Approved';
        insert reviewStepApp;

        Review__c review = new Review__c();
        review.Preapplication__c = app.id;
        review.PanelApplication__c = panelApplication.id;
        review.PanelUser__c=panelUser.id;
        review.ReviewPanel__c = reviewPanel.id;
        review.Status__c = 'Review Completed';
        review.ReviewStep__c=reviewStep.Id;
        review.Recommendation__c='Recommended';
        if(create){
            insert review;
        }
        return review;

    }


    global static Review__c getReviewForAppAndPreApp(boolean create,Boolean trueForApp){
        Announcement__c ann = getGrantorAnnouncement(true); 
        Application__c app;
        PreApplication__c preApp;
       if(trueForApp ==true){
             app = getSubmittedApplication(ann.id,true);
        }else if(trueForApp == false){
             preApp = getSubmittedPreApplication(ann.id,true);
             
        }
        ReviewPanelTemplate__c panelTemplate = [SELECT ID,Name,ReviewStepTemplate__c, ReviewPackage__c from ReviewPanelTemplate__c where ReviewStepTemplate__r.Program__c = :ann.Program__c ];

        ReviewGroup__c reviewGroup = new ReviewGroup__c();
        reviewGroup.Announcement__c = ann.id;
        reviewGroup.NumberOfReviewSteps__c= Decimal.valueOf('1.0');  
        insert reviewGroup;        
       
        ReviewStep__c reviewStep = [Select Id From ReviewStep__c Where ReviewGroup__c = :reviewGroup.Id];
        
        ReviewStepUser__c reviewStepUser = new ReviewStepUser__c();
        reviewStepUser.ReviewStep__c = reviewStep.id;
        reviewStepUser.Reviewer__c=UserInfo.getUserId();
        insert reviewStepUser;

        ReviewPanel__c reviewPanel = new ReviewPanel__c();
        reviewPanel.ReviewStep__c = reviewStep.id;
        reviewPanel.ReviewPackage__c = panelTemplate.ReviewPackage__c;
        reviewPanel.GroupId__c = 'testID';
        reviewPanel.Sequence__c = 1;
        reviewPanel.AutoAssignSubmittedApplication__c = true;
        if(trueForApp == true){
            reviewPanel.RecordTypeId = Schema.SObjectType.ReviewPanel__c.getRecordTypeInfosByName().get('Application').getRecordTypeId();
        }else if(trueForApp == false){
            reviewPanel.RecordTypeId = Schema.SObjectType.ReviewPanel__c.getRecordTypeInfosByName().get('Pre-Application').getRecordTypeId();
        }
        User u = getAdminUser(true);
        reviewPanel.Chair__c = u.id;
        insert reviewPanel;

        PanelUser__c panelUser = new PanelUser__c();
        panelUser.Reviewer__c = getPortalUser(true).id;
        panelUser.ReviewPanel__c = reviewPanel.id;       
        insert panelUser; 

        PanelApplication__c panelApplication = new PanelApplication__c();
        if(trueForApp == true){
            panelApplication.Application__c = app.id;
        }else if(trueForApp == false){
            panelApplication.Preapplication__c = preApp.id;
        }
        panelApplication.ReviewPanel__c = reviewPanel.id;
        insert panelApplication;

        Review__c review = new Review__c();
        if(trueForApp == true){
            review.Application__c = app.id;
        }else if(trueForApp == false){
            review.PreApplication__c = preApp.id;
        }
        review.PanelApplication__c = panelApplication.id;
        review.PanelUser__c=panelUser.id;
        review.ReviewPanel__c = reviewPanel.id;
        review.Status__c = 'Review Completed';
        if(create){
            insert review;
        }
        return review;

    }
    global static Review__c getReview(boolean create,String recordType){
        Announcement__c ann = getAnnouncement(true); 
        Application__c app = getApplication(ann.id,true);
    
        ReviewPanelTemplate__c panelTemplate = [SELECT ID,Name,ReviewStepTemplate__c, ReviewPackage__c from ReviewPanelTemplate__c where ReviewStepTemplate__r.Program__c = :ann.Program__c ];
        

        ReviewGroup__c reviewGroup = new ReviewGroup__c();
        reviewGroup.Announcement__c = ann.id;
        reviewGroup.NumberOfReviewSteps__c= Decimal.valueOf('1.0');
        reviewGroup.RecordTypeId = Schema.SObjectType.ReviewGroup__c.getRecordTypeInfosByName().get(recordType).getRecordTypeId();
        insert reviewGroup;

       
        ReviewStep__c reviewStep = [Select Id From ReviewStep__c Where ReviewGroup__c = :reviewGroup.Id];

        ReviewStepUser__c reviewStepUser = new ReviewStepUser__c();
        reviewStepUser.ReviewStep__c = reviewStep.id;
        reviewStepUser.Reviewer__c=UserInfo.getUserId();
        insert reviewStepUser;

        ReviewPanel__c reviewPanel = new ReviewPanel__c();
        reviewPanel.ReviewStep__c = reviewStep.id;
        reviewPanel.ReviewPackage__c = panelTemplate.ReviewPackage__c;
        reviewPanel.GroupId__c = 'testID';
        User u = getAdminUser(true);
        reviewPanel.Chair__c = u.id;
        GNT__PageTemplate__c pt = getPageTemplateConfig(true);
        GNT__Package__c pack = getPackage(true, pt); 
        reviewPanel.ReviewPackage__c = pack.id; 
        reviewPanel.RecordTypeId = Schema.SObjectType.ReviewPanel__c.getRecordTypeInfosByName().get(recordType).getRecordTypeId();
        insert reviewPanel;
        
        PanelUserTemplate__c userTemplate = [SELECT ID,ReviewPanelTemplate__c, Reviewer__c from PanelUserTemplate__c where ReviewPanelTemplate__c = :panelTemplate.Id ];
        
        PanelUser__c panelUser = new PanelUser__c();
        panelUser.Reviewer__c = userTemplate.Reviewer__c;
        panelUser.ReviewPanel__c = reviewPanel.id;    
        insert panelUser; 

        PanelApplication__c panelApplication = new PanelApplication__c();
        panelApplication.Application__c = app.id;
        panelApplication.ReviewPanel__c = reviewPanel.id;
        panelApplication.RecordTypeId = Schema.SObjectType.PanelApplication__c.getRecordTypeInfosByName().get(recordType).getRecordTypeId();
        insert panelApplication;

        Review__c review = new Review__c();
        review.Application__c = app.id;
        review.PanelApplication__c = panelApplication.id;
        review.PanelUser__c=panelUser.id;
        review.ReviewPanel__c = reviewPanel.id;
        review.Status__c = 'Review Completed';
        review.Recommendation__c = 'Approved';
        if(create){
            insert review;
        }
        return review;

    }
 
    global static ContentVersion getContentVersion(boolean create) {
        
        ContentVersion cv = new ContentVersion();
        
        cv.versionData = Blob.valueOf('Unit Test Content Version');
        cv.title = 'testFile.txt';
        cv.pathOnClient ='/' + cv.title;
        if (create) {
            insert cv;
        }
        return cv;
    }
    global static CollaborationGroup getCollaborationGroup(boolean create) {
        CollaborationGroup cg = new CollaborationGroup();
        cg.Name = 'testGroup';
        cg.CollaborationType = 'Public';
        if (create) {
            insert cg;
        }
        return cg;
    }

    global static Closeout__c getCloseout(Id grantId, boolean create){
        Closeout__c ct = new Closeout__c();
        ct.Grant__c = grantId;
        ct.Status__c = 'Not Started';
        if(create)
            insert ct;
        return ct;
    }
    
    
     global static ReviewStepApplication__c getReviewStepApplication(boolean create){
     ReviewStepApplication__c reviewStepApplication = new ReviewStepApplication__c(ReviewStep__c = getReviewStep(true).id,
     Preapplication__c=getPreApplication(true).id,application__c = getApplication(getAnnouncement(true).id,true).id);
      if (create) {  
            insert reviewStepApplication ;
        }
        return reviewStepApplication ;
       
     } 
     
     global static ReviewStepApplication__c getReviewStepApplication1(Id stepId, boolean create){
         ReviewStepApplication__c reviewStepApplication = new ReviewStepApplication__c(ReviewStep__c = stepid,
         Preapplication__c=getPreApplication(true).id,application__c = getApplication(getAnnouncement(true).id,true).id);
         if (create) {  
                insert reviewStepApplication ;
         }
            return reviewStepApplication ;
           
     } 
     
     global static StrategicPlan__c getStrategicPlan(boolean create){
        StrategicPlan__c strategicPlan = new StrategicPlan__c(Agency__c = getAccount(true).id,StrategyTitle__c ='Sample strategy Title',
                                                    StrategyDescription__c='Description of strategy title',
                                                    StrategyOwner__c=getStandardUser(true).id);
        if (create){
            insert strategicPlan;
        }
        return strategicPlan;
     }
     //TODO : Make this function generic to accept recordtypeId and assign populated fields. This function is written to accep Program__c
     global static RolesAndResponsibilities__c getRolesAndResponsibilities(boolean create, Id programId){
        //Account acc = getAccount(true);
        RolesAndResponsibilities__c rolesAndResponsibilities = new RolesAndResponsibilities__c(Program__c = programId,
                                                                        BusinessRole__c='Program Approver');       
        if (create){
            insert rolesAndResponsibilities;
        }
        return rolesAndResponsibilities;
     }
     
     global static FOALead__c getFOALead(boolean create){
        FOALead__c fOALead = new FOALead__c(FundingOppURL__c='/apex/testPageUrl',SourceStatus__c='Open',
                                            Status__c='New Lead',StrategicPlan__c=getStrategicPlan(true).id,
                                            Justification__c='');
        if(create){
            insert fOALead;
        }
        return fOALead;
     }
     
     global static ProgramServiceArea__c getProgramServiceArea(boolean create, Id programId, Id serviceAreaId){
        ProgramServiceArea__c programServiceArea = new ProgramServiceArea__c(Program__c=programId,ServiceArea__c=serviceAreaId);
        if (create){
            insert programServiceArea;
        }
        return programServiceArea;
     }
     
     global static ServiceArea__c getServiceArea(boolean create){
        ServiceArea__c serviceArea = new ServiceArea__c(Title__c='Test Service Area',Default__c = true);
        if (create){
            insert serviceArea;
        }
        return serviceArea;
     }
     
     global static JXPrograms__c getJXPrograms(boolean create, Id pgmId){
        JXPrograms__c jXPrograms = new JXPrograms__c(InternalUniqueID__c='Test',StateProgram__c=pgmId);
        if (create){
            insert jXPrograms;
        }
        return jXPrograms;
     }
     
     global static PaymentRequest__c getPaymentRequest(boolean create){
        PaymentRequest__c paymentRequest = new PaymentRequest__c(Status__c='Created');
        if (create){
            insert paymentRequest;
        }
        return paymentRequest;
     }
     
     global static PaymentBudgetCategory__c getPaymentBudgetCategory(boolean create){
        PaymentBudgetCategory__c paymentBudgetCategory = new PaymentBudgetCategory__c(PaymentRequest__c=getPaymentRequest(true).Id);
        if (create){
            insert paymentBudgetCategory;
        }
        return paymentBudgetCategory;
     }
     
     global static AwardPaymentBudgetCategory__c getAwardPaymentBudgetCategory(boolean create, Id awardId){
        AwardPaymentBudgetCategory__c awardPaymentBudgetCategory = new AwardPaymentBudgetCategory__c(Award__c=awardId);
        if (create){
            insert awardPaymentBudgetCategory;  
        }
        return awardPaymentBudgetCategory;
     }
     
     global static GNT__KeyValueStore__c getggsTempPack1_KeyValueStore(boolean create, String value){
        GNT__KeyValueStore__c ggsTempPack1_KVS = new GNT__KeyValueStore__c(Name='Test',GNT__Application__c='Test',
                                                                GNT__TextValue__c = value,GNT__Admin_Question__c='Test',
                                                                GNT__Description__c='test');
        if (create) {
            insert ggsTempPack1_KVS;
        }
        return ggsTempPack1_KVS;
     }
     
     global static GNT__PageTemplate__c ggsTempPack1_PageTemplate(boolean create){
        GNT__PageTemplate__c ggsTempPack1_PageTemplate = new GNT__PageTemplate__c(Name = 'RST_Step123Layout', 
                                                                        GNT__DisplayName__c='RST_Step123Layout',GNT__Description__c='Test description');
        if(create){
            system.debug('***Entering method***');
            insert ggsTempPack1_PageTemplate;
            system.debug('Page Template ID : '+ ggsTempPack1_PageTemplate.Id);
        }
        return ggsTempPack1_PageTemplate;
     }
     
     //SM
     global static void ggsTempPack1_PageTemplate(boolean create,GNT__PageLayoutConfig__c pl){

        List<GNT__PageTemplate__c> pt = new List<GNT__PageTemplate__c>();

        GNT__PageTemplate__c ars1 = new GNT__PageTemplate__c(Name = 'ApplicationReviewStep', 
                                                                        GNT__DisplayName__c='ApplicationReviewStep',GNT__Description__c='Test description',
                                                                        GNT__EditLayoutConfig__c=pl.Id,GNT__OMBNumber__c = '1234',
                                                                        GNT__PackageType__c = 'Application',GNT__ViewLayoutConfig__c = pl.Id,
                                                                        GNT__PrintLayoutConfig__c = pl.Id);
        pt.add(ars1);

        GNT__PageTemplate__c ars2 = new GNT__PageTemplate__c(Name = 'ApplicationReviewStepSDDApprovalTemplate', 
                                                                        GNT__DisplayName__c='ApplicationReviewStepSDDApprovalTemplate',GNT__Description__c='Test description',
                                                                        GNT__EditLayoutConfig__c=pl.Id,GNT__OMBNumber__c = '1234',
                                                                        GNT__PackageType__c = 'Application',GNT__ViewLayoutConfig__c = pl.Id,
                                                                        GNT__PrintLayoutConfig__c = pl.Id);
        pt.add(ars2);
        GNT__PageTemplate__c ars3 = new GNT__PageTemplate__c(Name = 'Review Panel Application Template', 
                                                                        GNT__DisplayName__c='Review Panel Application Template',GNT__Description__c='Test description',
                                                                        GNT__EditLayoutConfig__c=pl.Id,GNT__OMBNumber__c = '1234',
                                                                        GNT__PackageType__c = 'Application',GNT__ViewLayoutConfig__c = pl.Id,
                                                                        GNT__PrintLayoutConfig__c = pl.Id);        
        pt.add(ars3);

        if(create){
            system.debug('***Entering method***');
            insert pt;
        }
        //return ggsTempPack1_PageTemplate;
     }

     global static GNT__EmailTemplateConfig__c getggsTempPack1_EmailTemplateConfig(boolean create){
        GNT__EmailTemplateConfig__c ggsTempPack1_EmailTemplateConfig = new GNT__EmailTemplateConfig__c(Name='GovGrants Email Templates',
                                                                                        GNT__EmailTemplateDeveloperName__c='GovGrants_Email_Templates');
        if (create) {
            insert ggsTempPack1_EmailTemplateConfig;
        }
        return ggsTempPack1_EmailTemplateConfig;
     }
     
     global static EmailTemplate getEmailTemplate2(boolean create){
        Folder folder = new Folder(Name='new'); 
        system.debug('Folder ID : ' + folder.Id);
        EmailTemplate emailTemplate = new EmailTemplate(Name='GovGrants_Email_Templates', DeveloperName='Application_Submission',
                                                        TemplateType='text',FolderId=folder.Id);
        if(create) {    
            insert emailTemplate;
        }
        return emailTemplate;
     }
     
      global static EmailTemplate getEmailTemplate3(boolean create,String name,String developer){
        system.debug('Record Information : ' + [Select Id From Folder  limit 1]);
        List<Folder> lstFolder = [Select Id From Folder limit 1 ];
        system.debug('Size of the folder : ' + lstFolder.size());
        EmailTemplate e;
        if(lstFolder.size() > 0){
            e=new EmailTemplate(TemplateType= 'Text', Name = name,FolderId=lstFolder.get(0).Id,developerName =developer);                    
        }        
        if (create) {  
            insert e;
        }
        return e;
    }

    global static List<BudgetCategory__c> getBudgetCategory(boolean create) {
        List<BudgetCategory__c> budgetCategories = new List<BudgetCategory__c>();
        Id recordTypeId = getRecordType(Schema.Sobjecttype.BudgetCategory__c, 'External');
        BudgetCategory__c budgetCategory1 = new BudgetCategory__c(RecordTypeId = recordTypeId,
                                            Name='Occupancy -Rent/Lease',
                                            CategoryDescription__c='Building Occupancy for project work',
                                            CategoryCode__c='FBC-51');
        BudgetCategory__c budgetCategory2 = new BudgetCategory__c(RecordTypeId = recordTypeId,
                                            Name='Salaries',
                                            CategoryDescription__c='Employee Salaries',
                                            CategoryCode__c='FBC-10');
        budgetCategories.add(budgetCategory1);
        budgetCategories.add(budgetCategory2);

        if(create){
            insert budgetCategories;
        }
        return budgetCategories;
    }
}