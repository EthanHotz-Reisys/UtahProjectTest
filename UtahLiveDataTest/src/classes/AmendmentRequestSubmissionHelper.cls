/*
* This action submission helper class validates the required fields supplied by the user
* before submitting AmendmentRequest
*
* @author: Sarat Mahavratayajula
*/
global with sharing class AmendmentRequestSubmissionHelper extends GNT.DynamicLayoutActionRedirect {
    private String appName = GNT.UserPreferenceHelper.getStringValue('ActiveAppName__c');
    List<String> errors = new List<String>();

    global override PageReference whenClicked() {

        system.debug('***App Name : ' + appName);
        Savepoint sp = Database.setSavepoint();
        AmendmentRequest__c amendmentRequest;
        Grant__c grantForAmendmentRequest;
        List<AmendmentRequestPriorApproval__c> amendmentRequestPriorApprovals;
        try {
            Id recordId = ApexPages.currentpage().getParameters().get('id');

            Map<Id, String> recordTypeMap = new Map<Id, String>();

            List<RecordType> amendmentRecordTypes = [select Id, Name, DeveloperName
                                                    FROM RecordType
                                                    where SobjectType = :AppUtils.getNamespacePrefix() + 'AmendmentRequest__c'];

            for (RecordType recordType : amendmentRecordTypes) {
                recordTypeMap.put(recordType.Id, recordType.DeveloperName);
            }

            List<RolesAndResponsibilities__c> amendRlsAndResps = [select Id, BusinessRole__c
                                                                    from RolesAndResponsibilities__c
                                                                    where AmendmentRequest__c = :recordId];

            boolean programApproverExists = false;
            boolean fiscalApproverExists = false;

            if (amendRlsAndResps.size() == 0) {
                //errors.add('Please add atleast one Roles and Responsibilities before submission');
                errors.add(GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-40826'));
            }

            for (RolesAndResponsibilities__c role : amendRlsAndResps) {

                if (role.BusinessRole__c.equals('Program Approver')) {
                    programApproverExists = true;
                }

                if (role.BusinessRole__c.equals('Fiscal Approver')) {
                    fiscalApproverExists = true;
                }
            }

            //if (!programApproverExists) errors.add('Please add Program Approver');
            if (!programApproverExists) errors.add(GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-46802'));

            //if (!fiscalApproverExists) errors.add('Please add Fiscal Approver');
            if (!fiscalApproverExists) errors.add(GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-12195'));

            //if (appName == 'StateasGrantee' || appName == 'Recipient') {
            amendmentRequest = [select Id, Name,Award__c, AwardName__c, RecordType__c,NewGranteePOC__c,TotalFederalAmountDifference__c,TotalMatchAmountDifference__c, Purpose__c, Impact__c, AmendmentContact__c,
                                NoCostExtension__c, BudgetPeriodExtension__c, KeyContactChange__c, OtherChange__c,
                                NewBudgetPeriodEndDate__c, ContactChangeDescription__c, Award__r.Grant__c,
                                OtherChangeDescription__c, BudgetPeriodChange__c, Justification__c, KeyPOC__c,
                                NewKeyPOC__c, NewKeyPersonnel__c, RecordTypeId
                                from AmendmentRequest__c
                                where Id = :recordId];
            amendmentRequestPriorApprovals = [select Justification__c, AmendmentType__c
                                              from AmendmentRequestPriorApproval__c
                                              where AmendmentRequest__c = :recordId];
            

            //Id grantId = amendmentRequest.Award__r.Grant__c;

            

            //}

            //List<Attachment> attachments = [SELECT Id
            //                                FROM Attachment
            //                                WHERE ParentId = :recordId];

            //if (attachments.size() == 0) {
            //    // errors.add('Please add atleast one Attachment');
            //    errors.add(GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTE-54874'));
            //}

            if (appName == 'StateasGrantee' && amendmentRequest.AmendmentContact__c == null) {
                // errors.add('Please add Amendment Contact before submission of the amendment request');
                errors.add(GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-77866'));
            }

            if (recordTypeMap.get(amendmentRequest.RecordTypeId).equals('BudgetRevision')) {
                verifyAmendmentBudgetCategoriesTotal(amendmentRequest);
            }


            if (amendmentRequest.RecordType__c == 'Prior Approval') {
                for (AmendmentRequestPriorApproval__c amendmentRequestPriorApproval : amendmentRequestPriorApprovals) {

                    if (amendmentRequestPriorApproval.Justification__c == '' ||
                            amendmentRequestPriorApproval.Justification__c == null) {
                        //errors.add('Please add Justification before submission of the amendment request');
                        errors.add(GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-72299'));
                    }
                }

                if (amendmentRequest.Purpose__c == null) {
                    //errors.add('Please add Purpose before submission of the amendment request');
                    errors.add(GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-11075'));
                }

                if (amendmentRequest.Impact__c == null) {
                    //errors.add('Please add Impact before submission of the amendment request');
                    errors.add(GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-04841'));
                }

                if (amendmentRequestPriorApprovals.size() == 0) {
                    //errors.add('Please add missing Prior Approval Type before submission');
                    errors.add(GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTE-14373'));
                }
            }

            if (amendmentRequest.RecordType__c == 'Formal Amendments') {

                grantForAmendmentRequest = [select ProjectPeriodEndDate__c
                                        from Grant__c
                                        where Id = :amendmentRequest.Award__r.Grant__c];

                Date grantProjectEndDate = grantForAmendmentRequest.ProjectPeriodEndDate__c;

                boolean testValue = (amendmentRequest.NewBudgetPeriodEndDate__c > grantProjectEndDate);

                //if (amendmentRequest.NewBudgetPeriodEndDate__c != null &&
                //        amendmentRequest.NewBudgetPeriodEndDate__c > grantProjectEndDate) {
                //    //errors.add('You are attempting to change the budget period end date. Please see your' +
                //    //   ' System Administrator to change the Project End Date in the Grant before you can continue');
                //    errors.add(GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-49126'));
                //}

                if (!amendmentRequest.NoCostExtension__c && !amendmentRequest.BudgetPeriodExtension__c
                        && !amendmentRequest.KeyContactChange__c && !amendmentRequest.OtherChange__c && !amendmentRequest.BudgetPeriodChange__c) {
                    //errors.add('Please check atleast one : No Cost extension, BudgetPeriodExtension,' +
                    //          'Key contact change or Other change');
                    errors.add(GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-16578'));
                }

                //if((amendmentRequest.BudgetPeriodExtension__c || amendmentRequest.BudgetPeriodChange__c) && (amendmentRequest.TotalMatchAmountDifference__c ==0 && amendmentRequest.TotalFederalAmountDifference__c == 0)){
                //    errors.add('Please add the new budget.');
                //}

                //if (amendmentRequest.NoCostExtension__c && amendmentRequest.NewBudgetPeriodEndDate__c == null ||
                //        amendmentRequest.NewBudgetPeriodEndDate__c <> null && (!amendmentRequest.NoCostExtension__c &&
                //                !amendmentRequest.BudgetPeriodChange__c)) {
                //    //errors.add('Please Verify No Cost Extension budget period details');
                //    errors.add(GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-26902'));
                //}

                if (amendmentRequest.OtherChange__c && amendmentRequest.OtherChangeDescription__c == null ||
                        amendmentRequest.OtherChangeDescription__c <> null && !amendmentRequest.OtherChange__c) {
                    //errors.add('Please verify Other information. ');
                    errors.add(GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-43934'));

                }

                if ((amendmentRequest.NoCostExtension__c || amendmentRequest.BudgetPeriodExtension__c ||
                        amendmentRequest.BudgetPeriodChange__c) && (amendmentRequest.Justification__c == null)) {
                    //errors.add('Please add Justification for Budget and/or Cost changes');
                    errors.add(GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-44443'));
                }

                if (appName == 'StateasGrantor') {
                    if (amendmentRequest.KeyContactChange__c && amendmentRequest.NewGranteePOC__c == null) {
                        errors.add('Please add New Key POC');
                        //errors.add(GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTE-54874'));
                    }
                }
                if(amendmentRequest.BudgetPeriodExtension__c && amendmentRequest.NewBudgetPeriodEndDate__c !=null){
                    errors.add('Please choose Cost and Budget Period Change if you are changing Budget Period dates.');
                }

                if (appName == 'StateasGrantee') {
                    if (amendmentRequest.KeyContactChange__c && amendmentRequest.NewKeyPersonnel__c == null) {
                        //errors.add('Please add New Key POC');
                        errors.add(GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-32923'));
                    }
                }
            }

            if (errors.size() > 0) {
                for (String error : errors) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, error));
                }
            }

            else if (programApproverExists && fiscalApproverExists) {
                //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,
                //                                          'The Amendment request has been submitted successfully.'));
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-36393')));
                system.debug('*** sarat testing' + amendmentRequest.Id + ' --- ' + amendmentRequest.Name
                             + ' --- ' + amendmentRequest.AwardName__c);
                // To Recall the payment approval process in action and removing their pending tasks. ----- YST
                SystemContextMethodsHelper contexthelper = new SystemContextMethodsHelper();
                contexthelper.rejectProcess(amendmentRequest.Award__c);




                //--------------YST
                if (appName.contains('StateasGrantee')) {
                    system.debug('Grantee task creation');
                    GNT.TaskCreationHandler.createApprovalProcessTasks
                    (amendmentRequest.Id, 'Review Amendment Request', amendmentRequest.Name, null,
                     System.TODAY() + 7, amendmentRequest.AwardName__c, true);
                    system.debug('***Task successfully sent ***');
                } else {
                    system.debug('Grantor task creation');
                    GNT.TaskCreationHandler.createApprovalProcessTasks
                    (amendmentRequest.Id, 'Approval Amendment Request', amendmentRequest.Name, null,
                     System.TODAY() + 7, amendmentRequest.AwardName__c, true);
                    system.debug('***Task successfully sent ***');
                }



                PageReference p = Page.amendmentrequestview;
                p.getParameters().put('Id', amendmentRequest.Id);
                p.setRedirect(true);
                return p;

            }
            return null;
        } catch (Exception e) {
            Database.rollback(sp);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            return null;
        }
    }
    public void verifyAmendmentBudgetCategoriesTotal(AmendmentRequest__c amendmentRequest) {
        Decimal totalAwardedAmount = 0.0;
        Decimal totalGrantorAmount = 0.0;
        List<AmendmentRequestBudgetCategory__c> amdRequestBudgetCategories =
                                                            [select Id, Name, CurrentAmount__c, GrantorAmount__c
                                                             from AmendmentRequestBudgetCategory__c
                                                             where AmendmentRequest__c = :amendmentRequest.Id];

        for(AmendmentRequestBudgetCategory__c amdRequestBudgetCategory: amdRequestBudgetCategories) {
            totalAwardedAmount = totalAwardedAmount + (amdRequestBudgetCategory.CurrentAmount__c == null ? 0.0 : amdRequestBudgetCategory.CurrentAmount__c);
            totalGrantorAmount = totalGrantorAmount + (amdRequestBudgetCategory.GrantorAmount__c == null ? 0.0 : amdRequestBudgetCategory.GrantorAmount__c);
        }

        if (totalAwardedAmount != totalGrantorAmount) {
             errors.add('Total awarded amount and Total Grantor amount must match');
        }
    }
}