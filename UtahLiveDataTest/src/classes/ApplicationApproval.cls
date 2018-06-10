global class ApplicationApproval extends GNT.ApprovalDecisionActionHandler {
    Map<String,Object> resultMap = new Map<String,Object>();
    PageReference pageRef = null;
    global override String execute(){
            system.debug('Connecting...!');
            if(selectedAction == 'Approve'){
            
            Id appId = selectedRecordId;
            system.debug('id is' +appId);
            Application__c app = [Select Id, Name,Approver__c, IndirectCostPicklist__c,
            Announcement__r.OrganizationName__c,Announcement__r.Program__r.AttachmentsRequired__c,
            TotalFederalMatch__c, Announcement__r.GranteeMatch__c,Announcement__r.MatchRequired__c,
            TotalCashMatch__c,TotalInKindMatch__c,TotalGrantCost__c ,PrimaryApplicant__r.Id,Status__c,
            Announcement__r.DaysLeft__c,Announcement__r.Name ,ExternalOrganization__c,
            ExternalOrganization__r.ApplicantType__c, Announcement__c,FormsValidated__c,
            Announcement__r.MaxApplicationsAllowed__c,Announcement__r.ApplicationsReviewStatus__c,
            NumberOfReviews__c,InitialRequestedAmount__c,RequestedAmount__c,AwardCeiling__c, AwardFloor__c,
             ProgramBudgetTypeUSBE__c, GrantorOrganizationName__c  from Application__c where id = :appId Limit 1];

             System.debug('Application ID'+app.id);

             app.Status__c = 'Submitted to Grantor';
              app.SubmittedOn__c=System.Now();
              app.InitialRequestedAmount__c=app.RequestedAmount__c;
              app.SubmittedBy__c=UserInfo.getUserId();
              update app;
              List<Task> taskList = [Select Id, Status, WhatId from Task where 
                                       WhatId = :app.Id AND OwnerId=:app.PrimaryApplicant__r.Id AND Status='In Progress'];
               if(taskList != null && taskList.size()>0){

                  for(Task task: taskList){
                     task.Status='Completed';
                  }                   
                  update taskList;
               }
               /*
              if(app.Announcement__r.ApplicationsReviewStatus__c!='Not Started' && app.Announcement__r.ApplicationsReviewStatus__c!='Ready for Review'){
                SystemContextMethodsHelper helper = new SystemContextMethodsHelper();
                helper.insertSingleApplicationToReview(app);
              }
              */
              ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Approval Process Action class works.')); 
              

                return ('Submitting to Grantor.');
            }
            return ('Not submitted to Grantor.');
          }
}