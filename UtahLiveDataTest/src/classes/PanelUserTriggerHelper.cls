/*
    This class handles the auto population of ReviewStepUser__c when a panel user record is inserted.
    ***********************************************************
    Audit History
    ***********************************************************
    11/10/2014      Nakul         Created
    ***********************************************************
*/
public with sharing class PanelUserTriggerHelper extends GNT.TriggerHelper {
  public static boolean skipAll = false;
  public override void processAfterInsert() {
    shareAccesstoReviewGroup();
    if (skipAll == false) {
      populateReviewStepUser(trigger.newMap.keySet());
      updatePanelNameCountOnRSU(trigger.newMap.keySet());
      shareToSMEUsers(Trigger.New);
    }
  }
  public override void processBeforeInsert() {
    if (skipAll == false) {
      isUserPresentInPanel(Trigger.New);
    }
  }

  public override void processBeforeDelete() {

    if (skipAll == false) {
      validateDelete();
      removeAccesstoReviewGroup();
    }
    //deleteAssociatedAssignedReviews();
  }

  public override void processAfterDelete() {
    //deleteAssociatedAssignedReviews();
  }

  // this method is used to populate the RSU records when the currosponding Panel User records are inserted.
  // A user can be part of multiple panel under the same Review Step, however Review Step user should not hold duplicate entries for a user under the same Review Step.
  @future
  private static void updatePanelNameCountOnRSU(Set<Id> panelUserIds) {
    Map<Id, Set<String>> userIdToPanelIdMap = new  Map<Id, Set<String>>();
    Map<Id, Id> userIdToStepIdMap = new  Map<Id, Id>();

    List<PanelUser__c> panelUsersList = [Select Id, Reviewer__c,
                                         ReviewPanel__r.ReviewStep__c, ReviewPanel__r.Name, ReviewPanel__r.PanelName__c From PanelUser__c
                                         Where Id IN :panelUserIds];

    for (PanelUser__c panelUser : panelUsersList) {
      Set<String> panels = userIdToPanelIdMap.get(panelUser.Reviewer__c);
      if (panels == null) {
        panels = new Set<String>();
      }
      panels.add(panelUser.ReviewPanel__r.PanelName__c + '');
      userIdToPanelIdMap.put(panelUser.Reviewer__c, panels);
      userIdToStepIdMap.put(panelUser.Reviewer__c, paneluser.ReviewPanel__r.ReviewStep__c);
    }


    List<ReviewStepUser__c> reviewStepUsersList = [SELECT Id, Name, PanelNames__c, PanelCount__c, ReviewStep__c, Reviewer__c FROM ReviewStepUser__c WHERE Reviewer__c IN :userIdToPanelIdMap.keyset()];
    if (reviewStepUsersList != null) {
      for (ReviewStepUser__c reviewStepUser : reviewStepUsersList) {
        Decimal panelCount = (reviewStepUser.PanelCount__c == null) ? 0 : reviewStepUser.PanelCount__c;
        String panelNames = (reviewStepUser.PanelNames__c == null) ? '' : reviewStepUser.PanelNames__c + ',';
        for (Id reviewer : userIdToPanelIdMap.keyset()) {
          Id reviewStep = userIdToStepIdMap.get(reviewer);
          if (reviewStepUser.Reviewer__c == reviewer && reviewStepUser.ReviewStep__c == reviewStep ) {
            Set<String> panels = userIdToPanelIdMap.get(reviewer);
            for (String panel : panels) {
              panelNames = panelNames + panel + ',';
              panelCount++;
            }
            reviewStepUser.PanelCount__c = panelCount;
          }
        }
        panelNames = panelNames.removeEnd(',');
        reviewStepUser.PanelNames__c = panelNames;
      }

    }

    update reviewStepUsersList;


  }
  private void populateReviewStepUser(Set<Id> panelUserIds) {
    Map<Id, Set<Id>> revStepToRevMap = new Map<Id, Set<Id>>();
    Map<Id, Set<Id>> revieweStepToReviewerMap = new Map<Id, Set<Id>>();
    Map<Id, Set<Id>> insertRSUMap = new Map<Id, Set<Id>>();
    Map<Id, Set<String>> userIdToPanelIdMap = new  Map<Id, Set<String>>();
    Set<Id> userIds = new Set<Id>();
    List<ReviewStepUser__c> insertReviewStepUserList = new List<ReviewStepUser__c>();
    // Query to get relation ship field values
    List<PanelUser__c> panelUsersList = [Select Id, Reviewer__c,
                                         ReviewPanel__r.ReviewStep__c, ReviewPanel__r.Name, ReviewPanel__r.PanelName__c From PanelUser__c
                                         Where Id IN :panelUserIds];

    // for a map of Review step --> Set of Reviewer user ids (using Panel User records)
    for (PanelUser__c panelUser : panelUsersList) {
      Set<Id> userList = revStepToRevMap.get(panelUser.ReviewPanel__r.ReviewStep__c);
      if (userList == null) {
        userList = new set<Id>();
      }
      userList.add(panelUser.Reviewer__c);
      userIds.add(panelUser.Reviewer__c);
      revStepToRevMap.put(panelUser.ReviewPanel__r.ReviewStep__c, userList);
    }

    // fetch all the review step user associated with the review steps (review steps - those are linked to the panel user records currently getting inserted)
    List<ReviewStepUser__c> stepUserList = [Select id, ReviewStep__c, Reviewer__c
                                            From ReviewStepUser__c where
                                            ReviewStep__c IN : revStepToRevMap.keySet() AND Reviewer__c IN :userIds];
    // for a map of Review step --> Set of Reviewer user ids (Using Reviewer Step User records)
    for (ReviewStepUser__c revUser : stepUserList) {
      Set<Id> userList = revieweStepToReviewerMap.get(revUser.ReviewStep__c);
      if (userList == null) {
        userList = new Set<Id>();
      }
      userList.add(revUser.Reviewer__c);
      revieweStepToReviewerMap.put(revUser.ReviewStep__c, userList);
    }
    // check the eligible records for insert (skip the ones which are already present in the RSU)
    for (Id stepId : revStepToRevMap.keySet()) {
      Set<Id> userIdSet = revStepToRevMap.get(stepId);
      for (Id userId : userIdSet) {
        // check if the user is already present in the RSU object under the same Review Step.
        Boolean userExistsInRevStep = isUserPresentInStep(revieweStepToReviewerMap, stepId, userId);
        if (!userExistsInRevStep) {
          Set<Id> revUser = insertRSUMap.get(stepId);
          if (revUser == null) {
            revUser = new Set<Id>();
          }
          revUser.add(userId);
          insertRSUMap.put(stepId, revUser);
        }
      }
    }

    // generate list of records to be inserted
    for (Id stepId : insertRSUMap.keySet()) {
      Set<Id> userId = insertRSUMap.get(stepId);
      for (Id user : userId) {
        ReviewStepUser__c rsUser = new ReviewStepUser__c();
        rsUser.ReviewStep__c = stepId;
        rsUser.Reviewer__c = user;
        Set<String>panelNameSet = new Set<String>();
        insertReviewStepUserList.add(rsUser);
      }
    }

    // insert RSU
    if (insertReviewStepUserList.size() > 0) {
      insert insertReviewStepUserList;
    }

  }

  // This method check if the user is already present in the RSU object for the given Review Step record
  private Boolean isUserPresentInStep(Map<Id, Set<Id>> stepToUser, Id revStep, Id userId) {

    for (Id step : stepToUser.keySet()) {
      if (revStep == step) {
        Set<Id> userSet = stepToUser.get(step);
        if (userSet.contains(userId)) {
          return true;
        }
      }
    }
    return false;
  }

  private void validateDelete() {
    Set<Id> pUserId = new Set<Id>();
    Set<Id> eligiblepUserId = new Set<Id>();

    Map<Id, Review__c> panelUserReviews = new Map<Id, Review__c>([
          SELECT id, PanelUser__c, Status__c FROM Review__c
          WHERE PanelUser__c in :trigger.oldMap.keySet()
          AND Status__c IN ('Sent For Review', 'Review Completed', 'Review In Progress')]);

    for (Review__c rev : panelUserReviews.values()) {
      pUserId.add(rev.PanelUser__c);
    }

    for (PanelUser__c panelUser : (List<PanelUser__c>)trigger.oldMap.values()) {
      if (!pUserId.contains(panelUser.Id)) {
        eligiblepUserId.add(panelUser.Id);
      } else {
        //panelUser.addError('The selected Reviewer cannot be Removed since the Review might be in progress.');
        panelUser.addError(GNT.ErrorMessageHelper.fetchMessage('M01-GRNTR-19999'));
      }
    }
    if (eligiblepUserId.size() > 0) {
      deleteAssociatedAssignedReviews(eligiblepUserId);
    }
  }

  private void deleteAssociatedAssignedReviews(Set<Id> pUsersId) {

    List<Review__c> reviews = [select id, PanelUser__c, Status__c from Review__c where PanelUser__c in : pUsersId AND Status__c = 'Assigned'];
    if (reviews.size() > 0) {
      delete reviews;
    }
  }


  // Share with SME Users - RSA, Application for updates during Review Process
  private void shareToSMEUsers(List<PanelUser__c> panelUsersList) {
    List<Id> reviewPanelId = new List<Id>();
    List<Id> reviewerId = new List<Id>();
    for (PanelUser__c panelUser : panelUsersList) {
      reviewPanelId.add(panelUser.ReviewPanel__c);
      reviewerId.add(paneluser.Reviewer__c);
    }

    List<ReviewPanel__c> reviewPanelList = [Select Id, Name, ReviewStep__c from ReviewPanel__c where id IN :reviewPanelId];
    Map<Id, ReviewPanel__c> revStepMap = new Map<Id, ReviewPanel__c>([Select Id, Name, ReviewStep__c from ReviewPanel__c where id IN :reviewPanelList]);
    List<ReviewPanel__c> revPanelList = [Select Id, Name, ReviewStep__c from ReviewPanel__c where id IN :reviewPanelList];
    Set<Id> rsaIDSet = new Set<Id>();
    for (ReviewPanel__c revPan : revPanelList) {
      rsaIDSet.add(revPan.ReviewStep__c);
    }

    List<ReviewStepApplication__c> revStepAppList = [Select Id, Name, Application__c from ReviewStepApplication__c where ReviewStep__c IN :rsaIDSet];
    List<Id> appList = new List<Id>();
    for (ReviewStepApplication__c reviewApp : revStepAppList) {
      appList.add(reviewApp.Application__c);
    }

    List<Application__Share> applicationShares = new List<Application__Share>();
    for (Id idVal : appList) {
      for (PanelUser__c panUser : panelUsersList ) {
        Application__Share revApp = new Application__Share();
        revApp.ParentId = idVal;
        revApp.AccessLevel = 'edit';
        revApp.UserOrGroupId = panUser.Reviewer__c;
        revApp.Rowcause = Schema.Application__Share.RowCause.SharetoReviewStepReviewers__c;
        applicationShares.add(revApp);
      }
    }
    // Insert all of the newly created Share records and capture save result
    //  insert reviewStepApplicationShares;


    System.debug('**applicationShares**' + applicationShares);
    SystemContextMethodsHelper contextHelper = new SystemContextMethodsHelper();
    contextHelper.upsertApplicationShare(applicationShares);
  }

  private void isUserPresentInPanel(List<PanelUser__c> newPanelUserList) {

    Set<Id> panelReview = new Set<Id>();
    for (PanelUser__c panelUser :  newPanelUserList) {
      panelReview.add(panelUser.ReviewPanel__c);
    }

    List<PanelUser__c> userList = [Select Id, Name, Reviewer__c,ReviewPanel__c from PanelUser__c where ReviewPanel__c IN: panelReview];


    Map<Id, List<PanelUser__c>> userMap = new Map<Id, List<PanelUser__c>>();
    for (PanelUser__c user : userList) {
      List<PanelUser__c> tmp = userMap.get(user.ReviewPanel__c);
      if (tmp == null) {
        tmp = new List<PanelUser__c>();
        userMap.put(user.ReviewPanel__c, tmp);
      }
      tmp.add(user);
    }

    for (PanelUser__c user : newPanelUserList) {
      List<PanelUser__c> users = userMap.get(user.ReviewPanel__c);
      if (users != null) {
        for (PanelUser__c userIterator : users) {
          if (userIterator.Reviewer__c == user.Reviewer__c) {
            user.addError('The reviewer already exists please add another user!!');
          }
        }
      }
    }


  }

  private void shareAccesstoReviewGroup() {
    List<ReviewGroup__Share> rgShares = new List<ReviewGroup__Share>();
    Set<Id> rgOwnerId = new Set<Id>();

    System.debug('Inside shareAccesstoReviewGroup**' + Trigger.NewMap.keySet());
    List<PanelUser__c> puList = [Select Id, Name, Reviewer__c, ReviewPanel__r.ReviewStep__r.ReviewGroup__c, ReviewPanel__r.ReviewStep__r.ReviewGroup__r.OwnerId  from PanelUser__c where id in :Trigger.NewMap.keySet()];

    for (PanelUser__c panUser : puList ) {
      rgOwnerId.add(panUser.ReviewPanel__r.ReviewStep__r.ReviewGroup__r.OwnerId);
    }

    for (PanelUser__c panUser : puList ) {
      if (!rgOwnerId.contains(panUser.Reviewer__c)) { // to check that owner of group is not added in Share object to avoid issues
        ReviewGroup__Share revGp = new ReviewGroup__Share();
        revGp.ParentId = panUser.ReviewPanel__r.ReviewStep__r.ReviewGroup__c;
        revGp.AccessLevel = 'Edit';
        revGp.UserOrGroupId = panUser.Reviewer__c;
        revGp.RowCause = Schema.ReviewGroup__Share.RowCause.SharetoReviewers__c;
        rgShares.add(revGp);
      }
    }
    SystemContextMethodsHelper.updateReviewGroupShares(rgShares);
  }

  private void removeAccesstoReviewGroup() {
    System.debug('Inside removeAccesstoReviewGroup**' + Trigger.OldMap.keySet());
    Set<Id> revGroupIds = new Set<Id>();
    Set<Id> reviewerIds = new Set<Id>();
    List<PanelUser__c> puList = [Select Id, Name, Reviewer__c, ReviewPanel__r.ReviewStep__r.ReviewGroup__c from PanelUser__c where id in :Trigger.OldMap.keySet()];
    for (PanelUser__c panUser : puList ) {
      reviewerIds.add(panUser.Reviewer__c);
      revGroupIds.add(panUser.ReviewPanel__r.ReviewStep__r.ReviewGroup__c);
    }
    System.debug(' revGroupIds**' + revGroupIds);
    System.debug(' reviewerIds**' + reviewerIds);
    List<ReviewGroup__Share> rgShares = [Select Id from ReviewGroup__Share where ParentId in :revGroupIds and UserOrGroupId in :reviewerIds and AccessLevel = 'Edit'];
    System.debug(' rgShares**' + rgShares);
    SystemContextMethodsHelper contextHelper = new SystemContextMethodsHelper();
    contextHelper.deleteSobjectList(rgShares);
  }
}