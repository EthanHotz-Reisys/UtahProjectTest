global with sharing class ApplicationReviewHandler extends GNT.FlexTableActionHandler {

 public ApplicationReviewHandler() {}


 global override Map < String, Object > clickHandler() {
  Map < String, Object > resultMap = new Map < String, Object > ();
  
  Savepoint sp = Database.setSavepoint();

  try {
   if (selectedRecordIds == null || selectedRecordIds.isEmpty()) {
    //resultMap.put('Message','Please select the Announcements to Initiate Review Process');
    resultMap.put('Message', GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-63597'));
    resultMap.put('Type', 'danger');
    return resultMap;
   } else if (selectedRecordIds.size() > 1) {
    //resultMap.put('Message','Please select only 1 Record');
    resultMap.put('Message', GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-59783'));
    resultMap.put('Type', 'danger');
    return resultMap;
   } else {
    Id announcementId = selectedRecordIds[0];
    Boolean revPanelFlag = false;
    Boolean revPanelDateFlag = false;
    List < Announcement__c > annList = [Select Id, Name, AnnouncementLink__c, ApplicationsReviewStatus__c, NumberOfApplications__c, ApplicationDeadlineWithDateTime__c, Program__r.ReviewProcess__c from Announcement__c where Id = : announcementId];
    Announcement__c ann = annList[0];
    if (ann.ApplicationsReviewStatus__c == 'In Progress') {
     //resultMap.put('Message','The applications for selected Announcement are already under Review');
     resultMap.put('Message', GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-50353'));
     resultMap.put('Type', 'danger');
     return resultMap;
    }
    if (ann.NumberOfApplications__c < 1 && ann.Program__r.ReviewProcess__c != 'One step review') {
     //resultMap.put('Message','No applications has been submitted for selected Announcement');
     resultMap.put('Message',GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-97891'));
     resultMap.put('Type', 'danger');
     //resultMap.put('Type', 'success');
     return resultMap;
    }
    List < ReviewStepTemplate__c > rstList = [SELECT Id, Name, StepNumber__c, NumberOfReviewPanels__c, MultiplePanelsRequired__c, ApplicationAssignment__c, RequiredStep__c FROM ReviewStepTemplate__c WHERE Announcement__c = : announcementId order by StepNumber__c asc];
    System.debug('--rstList--' + rstList);
    if (rstList != null || rstList.size() > 0) {
     ReviewStepTemplate__c firstRST = rstList[0];
     List < ReviewPanelTemplate__c > rptList = [SELECT Id, Name, ReviewersCount__c, EndDate__c FROM ReviewPanelTemplate__c WHERE ReviewStepTemplate__c = : firstRST.Id];
     if (rptList.size() < 1) {
      //resultMap.put('Message','Review Panels are not present in First Review Step, please add panel, update Review Due Date and add Reviewers before continuing');
      resultMap.put('Message', GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-21865'));
      resultMap.put('Type', 'danger');
      return resultMap;
     }
     for (ReviewPanelTemplate__c revPanel: rptList) {
      system.debug('--revPanel--' + revPanel);
      if (revPanel.ReviewersCount__c < 1) {
       revPanelFlag = true;
       break;
      }
      if (revPanel.EndDate__c == null || revPanel.EndDate__c < System.Today()) {
       revPanelDateFlag = true;
       break;
      }
     }
     if (revPanelFlag) {
      //resultMap.put('Message',firstRST.Name+' does not have Reviewers in all the associated Panels. Please add Reviewer in Announcement');
      resultMap.put('Message', firstRST.Name + ' ' + GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-28229'));
      resultMap.put('Type', 'danger');
      return resultMap;
     }
     If(revPanelDateFlag) {
      //resultMap.put('Message',firstRST.Name+' does not have Valid Review Due Date in all the associated Panels.');
      resultMap.put('Message', firstRST.Name + ' ' + GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-59170'));
      resultMap.put('Type', 'danger');
      return resultMap;
     }
     if (ann.ApplicationDeadlineWithDateTime__c > System.now() && ann.Program__r.ReviewProcess__c != 'One step review') {
      //resultMap.put('Message','Application Review can not be started before Application Deadline');
      resultMap.put('Message', GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-84986'));
      resultMap.put('Type', 'danger');
      return resultMap;
     }


     // Find the announcement Id.
     // Check the first step in RSATemplate object and see its application assignment
     // If auto -> call InitiateApplicationReviewHandler class
     //otherwise call ReviewTasksHandler and let user do it manually

     ReviewStepTemplate__c rst = rstList[0];
     system.debug('--rst--' + rst);
     String appAssignment;
     if (rst != null && rst.ApplicationAssignment__c != null) {
      appAssignment = rst.ApplicationAssignment__c;
     } else {
      appAssignment = 'Auto-Assign to All';
     }
     system.debug('**appAssignment --' + appAssignment);
     //  appAssignment='Auto-Assign to All';      
     if (appAssignment == 'Auto-Assign to All') {
      ReviewTasksHandler rth = new ReviewTasksHandler(announcementId);
      rth.insertReviewTasks();
      //ReviewGroup__c rg = [Select Id, Name, Announcement__c from ReviewGroup__c where Announcement__c = : announcementId limit 1];
      //system.debug('**rg --' + rg);
      system.debug('**announcementId--' + announcementId);
      ReviewStep__c revStep = [Select Id from ReviewStep__c where ReviewGroup__r.Announcement__c = : announcementId and stepNumber__c = 1 limit 1];
      system.debug('--revStep --' + revStep);
      ApplicationReviewHelper arh = new ApplicationReviewHelper();
      arh.createReviewTasks(revStep.Id);
     } else if (appAssignment == 'Equal Distribution') {
      ReviewTasksHandler rth = new ReviewTasksHandler(announcementId);
      rth.insertReviewTasks();
      ReviewStep__c revStep = [Select Id from ReviewStep__c where ReviewGroup__r.Announcement__c = : announcementId and stepNumber__c = 1 limit 1];
      System.debug('--revStep --' + revStep);
      ApplicationReviewHelper arh = new ApplicationReviewHelper();
      arh.createReviewTasks(revStep.Id);
     } else if (appAssignment == 'Manual Assignment') { // Do not create reviews, just start the review and let PM take it forward
      ReviewTasksHandler rth = new ReviewTasksHandler(selectedRecordIds);
      rth.insertReviewTasks();
     }
    } else {
     //resultMap.put('Message','Application Review can not be started for the selected announcement');
     resultMap.put('Message', GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-31863'));
     resultMap.put('Type', 'danger');
     return resultMap;
    }
   }
  } catch (Exception e) {
   Database.rollback(sp);
   system.debug(e.getMessage());
   resultMap.put('Message', 'Error message: ' + e.getMessage());
   resultMap.put('Type', 'danger');
   return resultMap;
  }
  //resultMap.put('Message','Review process has been initiated');
  resultMap.put('Message', GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-50344'));
  resultMap.put('Type', 'success');
  return resultMap;
 }
}