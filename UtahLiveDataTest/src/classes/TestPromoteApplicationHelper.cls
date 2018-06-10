@isTest
private class TestPromoteApplicationHelper{
    @IsTest(SeeAllData=false)
    private static void testPromoteApplicationHelper(){
        User u = TestHelper.getAdminUser(false); 
        System.runAs(u){
            AppUtils.skipStepReviewTrigger = true;
            ProgramTriggerHelper.skipTrigger=false;
            AnnouncementTriggerHelper.skipTrigger=true;
            ApplicationTriggerHelper.skipTrigger=true;
            ReviewStepTriggerHelper.skipTrigger=true; 
            TestHelper.CreateCustomSettings(true);
            GNT__ErrorMessageConfig__c err = new GNT__ErrorMessageConfig__c();
            err.GNT__Message__c='text';
            err.GNT__ErrorCode__c='M01-GRNTR-78792';
            err.GNT__Message_Type__c='Success Message';
            insert err;
            
            GNT__ErrorMessageConfig__c err1 = new GNT__ErrorMessageConfig__c();
            err1.GNT__Message__c='text';
            err1.GNT__ErrorCode__c='M01-GRNTR-53478';
            err1.GNT__Message_Type__c='Success Message';
            insert err1;            
            Announcement__c  ann = TestHelper.getGrantorAnnouncementAll(true);
           
            Test.startTest();
            Review__c review = TestHelper.getGrantorReview(ann,true);  
            ReviewStep__c rs =[Select Id, Name, StepNumber__c,Description__c,ReviewGroup__c from ReviewStep__c where ReviewGroup__r.Announcement__c=:ann.Id Limit 1];
            rs.status__c='In Progress';
            update rs;
            Review__c rev = [Select Id, Name, ReviewPanel__r.ReviewStep__r.Id,Application__c from Review__c where id = : review.Id];
            
            ReviewStepApplication__c rsa = [Select Id, Name from ReviewStepApplication__c where ReviewStep__c=:rev.ReviewPanel__r.ReviewStep__r.Id Limit 1];
            rsa.Decision__c='Approved';
            update rsa;
             
            ReviewStep__c nextStep = new ReviewStep__c();
            nextStep.stepnumber__c=2;
            nextStep.Description__c='Step 2';
            nextStep.ReviewGroup__c=rs.ReviewGroup__c;
            insert nextStep;   
                 
            Test.setCurrentPageReference(new PageReference('Page.ReviewStepView'));
            PromoteApplicationHelper rph = new PromoteApplicationHelper();
            ApexPages.currentPage().getParameters().put('id', rs.Id);
            rph.whenClicked();
            Test.stopTest();
        }
    }
 }