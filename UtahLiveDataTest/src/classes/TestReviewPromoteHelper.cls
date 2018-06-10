@isTest(SeeAllData = false)
private class TestReviewPromoteHelper{
    @IsTest(SeeAllData=false)
    private static void testReviewPromoteHelper1(){
        UserTriggerHelper.skipTrigger=true;
        User u = TestHelper.getAdminUser(true); 
        
            System.runAs(u){
            Group group1 = [Select DeveloperName, Type from Group where DeveloperName = 'OGM' and Type = 'Queue'];
            GroupMember gm = new GroupMember(UserOrGroupId = u.Id, GroupId = group1.Id);
            insert gm;
            AppUtils.skipStepReviewTrigger = true;
            ProgramTriggerHelper.skipTrigger=true;
            AnnouncementTriggerHelper.skipTrigger=true;
            ApplicationTriggerHelper.skipTrigger=true;
            ReviewStepTriggerHelper.skipTrigger=true;
            ReviewPanelTriggerHelper.skipTrigger = true;
            ReviewGroupTriggerHelper.skipTrigger = true;
            
            ReviewStepTemplate__c rst = new ReviewStepTemplate__c();
            rst.DefaultStep__c=true;
            rst.CustomAppName__c='StateasGrantor';
            rst.Description__c='Step 1';
            rst.StepNumber__c=1;
           // insert rst;
            TestHelper.CreateCustomSettings(true);
            Announcement__c  ann = TestHelper.getGrantorAnnouncementAll(true);
            Application__c app = TestHelper.getApplication(ann.Id, true);
           
            
            ReviewGroup__c reviewGroup = TestHelper.getReviewGroup(true);
            reviewGroup.Announcement__c = ann.Id;
            update reviewGroup;


            ReviewStep__c rs= new ReviewStep__c (OGMNotifiedOfRejections__c = true, Status__c = 'In Progress', Description__c = 'test', ReviewGroup__c = reviewGroup.Id,Name = 'Step 1',StepNumber__c=1);
            rs.ReviewStepTemplate__c = [Select Id From ReviewStepTemplate__c Where Announcement__c = :rs.ReviewGroup__r.Announcement__c Order by StepNumber__c LIMIT 1].Id;
            insert rs;


            ReviewPanel__c reviewPanel = new ReviewPanel__c(ReviewStep__c = rs.Id);
            insert reviewPanel;
            Review__c review = TestHelper.getGrantorReview(ann,true);
            review.Status__c = 'Review Completed';
            review.Recommendation__c = 'Recommended';
            review.ReviewPanel__c = reviewPanel.Id;
            review.ReviewStep__c = rs.Id;
            review.Application__c = app.Id;
            update review;
            ReviewStepApplication__c rsa = new ReviewStepApplication__c(Application__c = app.Id, ReviewStep__c = rs.Id);
            //rsa.ReviewStep__c = rs.Id;
            insert rsa;
            

            
            Test.startTest();
            //ReviewStep__c rs =[Select Id, Name, StepNumber__c,Description__c,ReviewGroup__c from ReviewStep__c where ReviewGroup__r.Announcement__c=:ann.Id Limit 1];
            //rs.status__c='In Progress';
            //update rs;
            system.debug('*rs*'+rs);
            Review__c rev = [Select Id, Name, ReviewPanel__r.ReviewStep__r.Id,Application__c from Review__c where id = : review.Id];
            
            //ReviewStepApplication__c rsa = [Select Id, Name from ReviewStepApplication__c where ReviewStep__c=:rev.ReviewPanel__r.ReviewStep__r.Id];
            List<String> IdSet = new List<String>();
            IdSet.add(rsa.Id);
            String idStr = rev.ReviewPanel__r.ReviewStep__r.Id;
            
            ReviewStep__c nextStep = new ReviewStep__c();
            nextStep.stepnumber__c=2;
            nextStep.Description__c='Step 2';
            nextStep.ReviewGroup__c=rs.ReviewGroup__c;
            insert nextStep;        
            
             ReviewPromoteHelper rph = new ReviewPromoteHelper();
             rph.selectedRecordIds = IdSet;
             rph.urlParams.put('id', idStr);
             rph.urlParams.put('action', 'test');
             rph.ClickHandler();
             Test.stopTest();
        }
    }
    @IsTest(SeeAllData=false)
    private static void testReviewPromoteHelper2(){
        UserTriggerHelper.skipTrigger=true;
        User u = TestHelper.getAdminUser(true); 
        
            System.runAs(u){
            Group group1 = [Select DeveloperName, Type from Group where DeveloperName = 'OGM' and Type = 'Queue'];
            GroupMember gm = new GroupMember(UserOrGroupId = u.Id, GroupId = group1.Id);
            insert gm;
            AppUtils.skipStepReviewTrigger = true;
            ProgramTriggerHelper.skipTrigger=true;
            AnnouncementTriggerHelper.skipTrigger=true;
            ApplicationTriggerHelper.skipTrigger=true;
            ReviewStepTriggerHelper.skipTrigger=true;
            ReviewPanelTriggerHelper.skipTrigger = true;
            ReviewGroupTriggerHelper.skipTrigger = true;
            
            ReviewStepTemplate__c rst = new ReviewStepTemplate__c();
            rst.DefaultStep__c=true;
            rst.CustomAppName__c='StateasGrantor';
            rst.Description__c='Step 1';
            rst.StepNumber__c=1;
           // insert rst;
            TestHelper.CreateCustomSettings(true);
            Announcement__c  ann = TestHelper.getGrantorAnnouncementAll(true);
            PreApplication__c papp = TestHelper.getPreApplication(true);
            Application__c app = TestHelper.getApplication(ann.Id, true);
           
            
            ReviewGroup__c reviewGroup = TestHelper.getReviewGroup(true);
            reviewGroup.Announcement__c = ann.Id;
            update reviewGroup;

            Id recordTypeId1 = TestHelper.getRecordType(Schema.Sobjecttype.ReviewStep__c,'Pre-Application');

            ReviewStep__c rs= new ReviewStep__c (OGMNotifiedOfRejections__c = true, Status__c = 'In Progress', Description__c = 'test', ReviewGroup__c = reviewGroup.Id,Name = 'Step 1',StepNumber__c=1);
            rs.ReviewStepTemplate__c = [Select Id From ReviewStepTemplate__c Where Announcement__c = :rs.ReviewGroup__r.Announcement__c Order by StepNumber__c LIMIT 1].Id;
            rs.RecordTypeId = recordTypeId1;
            insert rs;


            ReviewPanel__c reviewPanel = new ReviewPanel__c(ReviewStep__c = rs.Id);
            insert reviewPanel;
            Review__c review = TestHelper.getGrantorReview(ann,true);
            review.Status__c = 'Review Completed';
            review.Recommendation__c = 'Recommended';
            review.ReviewPanel__c = reviewPanel.Id;
            review.ReviewStep__c = rs.Id;
            review.Application__c = app.Id;
            review.PreApplication__c = papp.Id;
            update review;
            ReviewStepApplication__c rsa = new ReviewStepApplication__c(PreApplication__c = papp.Id, Application__c = app.Id, ReviewStep__c = rs.Id);
            //rsa.ReviewStep__c = rs.Id;
            insert rsa;
            

            
            Test.startTest();
            //ReviewStep__c rs =[Select Id, Name, StepNumber__c,Description__c,ReviewGroup__c from ReviewStep__c where ReviewGroup__r.Announcement__c=:ann.Id Limit 1];
            //rs.status__c='In Progress';
            //update rs;
            system.debug('*rs*'+rs);
            Review__c rev = [Select Id, Name, ReviewPanel__r.ReviewStep__r.Id,Application__c from Review__c where id = : review.Id];
            
            //ReviewStepApplication__c rsa = [Select Id, Name from ReviewStepApplication__c where ReviewStep__c=:rev.ReviewPanel__r.ReviewStep__r.Id];
            List<String> IdSet = new List<String>();
            IdSet.add(rsa.Id);
            String idStr = rev.ReviewPanel__r.ReviewStep__r.Id;
            
            ReviewStep__c nextStep = new ReviewStep__c();
            nextStep.stepnumber__c=2;
            nextStep.Description__c='Step 2';
            nextStep.ReviewGroup__c=rs.ReviewGroup__c;
            insert nextStep;        
            
             ReviewPromoteHelper rph = new ReviewPromoteHelper();
             rph.selectedRecordIds = IdSet;
             rph.urlParams.put('id', idStr);
             rph.urlParams.put('action', 'test');
             rph.ClickHandler();
             Test.stopTest();
        }
    }
 }