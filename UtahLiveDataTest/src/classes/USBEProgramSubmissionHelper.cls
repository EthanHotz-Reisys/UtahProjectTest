//

global with sharing class USBEProgramSubmissionHelper extends GNT.DynamicLayoutActionRedirect {

  global override PageReference whenClicked() {
    Savepoint sp = Database.setSavepoint();
    List<String> errors = new List<String>();

    try {
      Id recordId = apexpages.currentpage().getparameters().get('id');
      List<RolesAndResponsibilities__c> lstRolesResposiblities = [Select Id, BusinessRole__c, Name__c from RolesAndResponsibilities__c where Program__c = :recordId AND Name__c != null];
      /*
      Map<String, Boolean> mapForRoles = new Map<String, Boolean>{'Key POC' => false,
                                                                  'Program Approver' => false,
                                                                  'Fiscal Approver' => false,
                                                                  'Executive Approver' => false};
      Map<String,String> errorMessage= new Map<String,String>{'Key POC' => GNT.ErrorMessageHelper.fetchMessage('M01-GRNTR-54930'),
                                                              'Program Approver' => GNT.ErrorMessageHelper.fetchMessage('M01-GRNTR-99971'),
                                                              'Executive Approver' => 'A Executive Approver (under Roles & Responsibilities section of Roles Tab) is a required field for a program',
                                                              'Fiscal Approver'=> 'A Fiscal Approver (under Roles & Responsibilities section of Roles Tab) is a required field for a program'};
      */
      Map<String, Boolean> mapForRoles = new Map<String, Boolean> {'Owner' => false,
          'Grants Manager' => false,
          'Executive Approver' => false
                                                                  };
      Map<String, String> errorMessage = new Map<String, String> {'Owner' => 'An Owner (under Roles & Responsibilities section of Roles Tab) is a required field for a program',
          'Grants Manager' => 'A Grants Manager (under Roles & Responsibilities section of Roles Tab) is a required field for a program',
          'Executive Approver' => 'An Executive Approver (under Roles & Responsibilities section of Roles Tab) is a required field for a program '
                                                                 };
      Program__c program = [Select Id, Name, RecordType.Name, AttachmentsRequired__c, FunderType__c, StartDate__c, EndDate__c, IsProjectServiceAreaneeded__c, ProgramName__c, Account__r.Name, ProgramBudgetTypeUSBE__c, IsNoReviewStepProgram__c, Objectives__c, ProgrammaticContact__c, UnitLookup__c, FundLookup__c, AppropriationLookup__c, ApplicationDeadline__c, ReviewProcess__c, ProgramPathway__c, FiscalYear__c from Program__c where Id = :recordId ];
      List<ProgramServiceArea__c> programService = [Select Id from ProgramServiceArea__c where Program__c = :recordId];
      //List<JXPrograms__c> FederalPrograms = [Select Id from JXPrograms__c where StateProgram__c =:recordId];
      List<BudgetPeriod__c> budPeriod = [Select Id, BudgetStartDate__c, BudgetEndDate__c, Status__c, Program__c from BudgetPeriod__c where Program__c = : recordId order by BudgetStartDate__c asc];
      List<ProgramBudgetCategory__c> programBudgetCategory = [Select Name from ProgramBudgetCategory__c where Program__c = :recordId];
      List<ProgramFundingAccount__c> programFundingAccount = [Select Name from ProgramFundingAccount__c where Program__c = :recordId];
      List<ProgramContacts__c> programContactList = [Select Id, Name from ProgramContacts__c where Program__c = : recordId];
      Integer count = 0;

      //Leons refactored R&R check**********

      for (RolesAndResponsibilities__c role : lstRolesResposiblities) { //assigning true or false to the present R&R
        if (role.BusinessRole__c != null) {
          mapForRoles.put(role.BusinessRole__c, true);
        }
      }


      for (String key : mapForRoles.keySet()) { // adding error messages
        if (!mapForRoles.get(key)) {
          errors.add(errorMessage.get(key));
        }
      }

      if (program.Account__r.Name != null && program.Account__r.Name == 'USBE') {
        List<String> errorsUSBE = new List<String>();    // beginning the USBE page layout field validations
        errorsUSBE = checkUSBEFieldValidations(program, errors);
        errors.addAll(errorsUSBE);
      }

      //Leons refactored R&R check*********

      if (budPeriod.size() > 0) {
        for (BudgetPeriod__c bud : budPeriod) {
          if (bud.Status__c == 'Active') {
            count++;
          }
        }
      }

      //Check to make sure 'Other' is a type of attachment; and adding it, if it is not there.
      String listOfAttachments = program.AttachmentsRequired__c;
      if (listOfAttachments != null) {
        if (!listOfAttachments.containsIgnoreCase('other'))
          //errors.add ('Must have attachment type ' +'other');
          program.AttachmentsRequired__c += ';Other';
        update program;
      } else {
        program.AttachmentsRequired__c = 'Other';
        update program;
      }


      //Checking for financial and programmatic contacts.
      // Check Review Process
      List<ReviewStepTemplate__c> reviewStepList = [Select Id, IsStepMandatory__c from ReviewStepTemplate__c where Program__c = :recordId and IsStepMandatory__c = 'Mandatory'];

      // Check App-Review Packages
      //List<BusinessPackage__c> pkgList = [Select Id,PackageType__c from BusinessPackage__c where Program__c =:recordId and PackageType__c='Application'];
      if (program.ProgramPathway__c != 'MSP' && program.ProgramPathway__c != 'Lump-Sum-No-App') {
        AggregateResult[] aggs = [SELECT PackageType__c packageType FROM BusinessPackage__c WHERE Program__c = :recordId GROUP BY PackageType__c];
        Set<String> packageTypeSet = new Set<String>();
        for (AggregateResult agg : aggs) {
          packageTypeSet.add(String.valueOf(agg.get('packageType')));
        }

        /*if(!packageTypeSet.contains('Risk Assessment')){
          errors.add ('Please associate a Package with Risk Assessment under attachments.');
        }

        if(!packageTypeSet.contains('Progress Report')){
          errors.add ('Please associate a Package with Progress Report under attachments.');
        }

        if(!packageTypeSet.contains('Site Visit')){
          errors.add ('Please associate a Package with Site Visit under attachments.');
        }

        if(!packageTypeSet.contains('Closeout')){
          errors.add ('Please associate a Package with Closeout under attachments.');
        }
        */
      }
      if (programBudgetCategory == null || programBudgetCategory.size() == 0) {
        //errors.add ('Program must have at least one budget category');
        errors.add (GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-31605'));
      }
      //Shivankar: Commented this validation out based on BA's request.
      //  if(programFundingAccount == null || programFundingAccount.size() == 0){
      //    //errors.add ('Program must have at least one funding account associated');
      //  errors.add (GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTE-16024'));
      //}
      System.debug('The start and end DATES =======>' + program.StartDate__c + program.EndDate__c + budPeriod);
      if (!AppUtils.validateBudgetPeriods(program.StartDate__c, program.EndDate__c, budPeriod)) {
        errors.add ('The program start and end dates should be the same as the budget period start and end dates.');
      }

      /*if(keypocExists == false){
          //errors.add ('A Key POC (under Roles & Responsibilities section of Review Tab) is a required field for a program');
          errors.add (GNT.ErrorMessageHelper.fetchMessage('M01-GRNTR-54930'));
      }
      if(approverExists == false){
          //errors.add( ' An Approver (under Roles & Responsibilities section of Review Tab) is a required field for a program');
          errors.add(GNT.ErrorMessageHelper.fetchMessage('M01-GRNTR-99971'));
      }
      if(fiscalAppoverExists == false){
          errors.add('A Fiscal Approver (under Roles & Responsibilities section of Roles Tab) is a required field for a program');
      }
      if(executiveApproverExists == false){
        errors.add('A Executive Approver (under Roles & Responsibilities section of Roles Tab) is a required field for a program');
      }*/

      if (programContactList.isEmpty()) {
        //errors.add('Please add atleast one Program Contact');
        errors.add(GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTE-75625'));
      }

      if ((reviewStepList == null || reviewStepList.size() == 0) && program.RecordType.Name == 'Internal Program' && program.IsNoReviewStepProgram__c == false) {
        //errors.add(' Atleast one Mandatory Review Step required for the Program.');
        errors.add(GNT.ErrorMessageHelper.fetchMessage('M01-GRNTR-69825'));
      }

      //if(pkgList == null || pkgList.size()==0){
      //errors.add(' Please associate a Package with Application Package Type with the Program.');
      //errors.add(GNT.ErrorMessageHelper.fetchMessage('M01-GRNTR-52018'));
      //}

      if ((program.IsProjectServiceAreaneeded__c == 'Yes') && (programService == null || programService.size() == 0)) {
        //errors.add('Please associate atleast one Service Area with the Program.');
        errors.add(GNT.ErrorMessageHelper.fetchMessage('M01-GRNTR-83669'));
      }
      if ((program.IsProjectServiceAreaneeded__c == 'No') && (programService.size() > 0)) {
        //errors.add('Please do not associate Service Area, if Project Service Area is not needed');
        errors.add(GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-39325'));
        //errors.add(GNT.ErrorMessageHelper.fetchMessage('M01-GRNTR-83669'));
      }

      //if((program.FunderType__c == 'Federal') && (FederalPrograms == null || FederalPrograms.size()==0)){
      //    //errors.add('Please associate atleast one Federal Program with the Program.');
      //    errors.add(GNT.ErrorMessageHelper.fetchMessage('M01-GRNTR-65888'));
      //}

      /* if (program.Account__r.Name == 'USBE' && program.ProgramBudgetTypeUSBE__c == null) {
           errors.add('USBE programs must specify their program type');
       } */
      System.debug('JONATHANS MESSAGE ======>' + mapForRoles.get('Executive Approver'));
      if (count == 0) {
        errors.add(GNT.ErrorMessageHelper.fetchMessage('P17-GRNTE-39059'));
      }
      if (count > 1) {
        errors.add(GNT.ErrorMessageHelper.fetchMessage('P17-GRNTE-52534'));
      }
      if (errors.size() > 0) {
        for (String error : errors) {
          ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, error));
        }
      }

      //else if(mapForRoles.get('Key POC') && mapForRoles.get('Program Approver') == true){
      else if (mapForRoles.get('Executive Approver') == true) {
        ProgramTriggerHelperUSBE.skipTrigger = true;
        System.debug('***entered here *** ');
        GNT.TaskCreationHandler.createApprovalProcessTasks(program.Id, 'Approve Program', program.Name, null, System.TODAY() + 7, program.ProgramName__c, true);
        //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'The Program has been submitted successfully.'));
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, GNT.ErrorMessageHelper.fetchMessage('M01-GRNTR-12057')));
        PageReference p = Page.ProgramView;
        p.getParameters().put('Id', program.Id);
        p.setRedirect(true);
        return p;
      }
      return null;
    } catch (Exception e) {
      Database.rollback(sp);
      System.debug('***exception caught' + e.getCause());
      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
      return null;
    }
  }

  private List<String> checkUSBEFieldValidations(Program__c program, List<String> errorsUSBE) { // check the field validations only for the USBE program

    List<BusinessPackage__c> pkgList = [Select Id, PackageType__c from BusinessPackage__c where Program__c = :program.Id and PackageType__c = 'App-Review'];
    Datetime applicationDeadline = program.ApplicationDeadline__c;
    Date startDate = program.StartDate__c;
    Date endDate = program.EndDate__c;

   // if (program.FiscalYear__c == null) { // checking for field validations on the USBE program
   //   errorsUSBE.add('Please add a fiscal year to the program before submitting');
   // }

    if (program.ProgrammaticContact__c == null) { // checking for field validations on the USBE program
      errorsUSBE.add('Please associate a programmatic contact with the program before submitting');
    }

    if (program.UnitLookup__c == null) {
      errorsUSBE.add('Please associate a unit lookup value with the program before submitting');
    }

    if (program.FundLookup__c == null) {
      errorsUSBE.add('Please associate a fund lookup value with the program before submitting');
    }

    if (program.AppropriationLookup__c == null) {
      errorsUSBE.add('Please associate a appropriation lookup value with the program before submitting');
    }

    if (( (program.ProgramPathway__c == 'Fed-Formula') || (program.ProgramPathway__c == 'Application 1/12th') || (program.ProgramPathway__c == 'Lump-Sum-App') ) && program.Objectives__c == null) {
      errorsUSBE.add('Please fill out the description field with the program before submitting');
    }

    if (!(applicationDeadline > startDate) && !(applicationDeadline < endDate)) { //check if the application deadline date is between start date and end date
      errorsUSBE.add('Please select an application deadline date between ' + startDate + ' and ' + endDate);
    }

    if (program.ReviewProcess__c == 'null') {
      errorsUSBE.add(' Please associate a value in the review step field before submitting this program.');
    }

    if ((program.ReviewProcess__c == 'One step review') && (pkgList == null || pkgList.size() == 0)) { //attach the one step review package;
      errorsUSBE.add(' Please associate a One Step Review Package on the Attachements tab before submitting this program.');
    }

    if ((program.ReviewProcess__c == 'Three step review') && (pkgList == null || pkgList.size() == 0)) { // attach the three step review package
      errorsUSBE.add('  Please associate a Three Step Review Package on the Attachements tab before submitting this program.');
    }

    return errorsUSBE;
  }




}