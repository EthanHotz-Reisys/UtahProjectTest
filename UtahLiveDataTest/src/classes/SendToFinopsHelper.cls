global with sharing class SendToFinopsHelper extends GNT.DynamicLayoutActionRedirect{
    String appName = GNT.UserPreferenceHelper.getStringValue('ActiveAppName__c');
    global override PageReference whenClicked(){
        Savepoint sp = Database.setSavePoint();
        List<String> errors = new List<String>();
        try{
            Id recordId = apexpages.currentpage().getparameters().get('id');
            boolean POexists = false;
            boolean FOexists = false;
            boolean COMPexists = false;
            boolean GrantAdminexists = false;
            //For USBE approval process
            Boolean Owner = false;
            Boolean PAexists = false;
            Boolean FAexists = false;
            Boolean LAexists = false;
            Boolean EAexists = false;

            Integer count = 0;

            system.debug(LoggingLevel.ERROR + 'Control is here - 1');
            Award__c award = [SELECT Id, Name, SubmittedOn__c,awardissuedate__c, GrantAwardName__c,AwardApprover1__c, AwardedAmount__c, PriorAwardedAmount__c, NumberofFiscalContacts__c,
                TotalObligateAmount__c, Grant__c, Grant__r.Program__c, Grant__r.Program__r.ProgramPathway__c, Grant__r.ProjectPeriodStartDate__c, Grant__r.ProjectPeriodEndDate__c, Grant__r.SpendType__c, Grant__r.TypeOfBudgetCategories__c, GranteePOC__c,
                TotalGrantAwardAmount__c, NumberofProgramContacts__c, NumberofOtherContacts__c, AreTCspartofNGAAttachments__c, ExecutiveApprover__c,
                BudgetPeriod__c, IndirectCostRateDecision__c, ProjectAmountofBudgetCategories__c, AwardedAmountthisAction__c, GrantorOrganization__c,
                Grant__r.InternalOrganization__r.status__c, AwardAmountThisAction__c, ObligatedAwardAmount__c, Grant__r.TotalOriginalGrantAmount__c, FOUser__c
                FROM Award__c
                WHERE Id =: recordId LIMIT 1
            ];
            //List < RolesAndResponsibilities__c > lstRolesResposiblities = [Select Id, BusinessRole__c from RolesAndResponsibilities__c where Award__c =: recordId];
            List < Attachment > attachment = [SELECT id FROM Attachment WHERE ParentId =: recordId];
            List < TermCondition__c > term = [SELECT id, Award__c, RecordType.DeveloperName FROM TermCondition__c WHERE RecordType.DeveloperName = 'Term'
                and Award__c =: recordId
            ];
            List < TermCondition__c > reportingrequirement = [SELECT id, Award__c, RecordType.DeveloperName FROM TermCondition__c WHERE RecordType.DeveloperName = 'ReportingRequirement'
                and Award__c =: recordId
            ];
            List < FundingSource__c > fundingsource = [Select id, name, Grant__c from FundingSource__c where Grant__c =: award.Grant__c];
            List < TermCondition__c > paymentrequest = [SELECT id, Award__c, RecordType.DeveloperName FROM TermCondition__c WHERE RecordType.DeveloperName = 'PaymentRequest'
                and Award__c =: recordId
            ];
            List < AwardFundingAccount__c > awdfundingaccount = [select id, Award__c from AwardFundingAccount__c where Award__c =: recordId];
            List < BusinessPackage__c > progressreportpkglist = [Select Id, PackageType__c from BusinessPackage__c where Grant__c =: award.Grant__c and PackageType__c = 'Progress Report'];
            List < BusinessPackage__c > sitevisitpkglist = [Select Id, PackageType__c from BusinessPackage__c where Grant__c =: award.Grant__c and PackageType__c = 'Site Visit'];
            List < BusinessPackage__c > riskassessmentpkgList = [Select Id, PackageType__c from BusinessPackage__c where Grant__c =: award.Grant__c and PackageType__c = 'Risk Assessment'];
            List < BusinessPackage__c > closeoutpkgList = [Select Id, PackageType__c from BusinessPackage__c where Grant__c =: award.Grant__c and PackageType__c = 'Closeout'];
            List < BusinessPackage__c > PaymentreqpkgList = [Select Id, PackageType__c from BusinessPackage__c where Grant__c =: award.Grant__c and PackageType__c = 'Payment Request'];
            List < SpendPlan__c > spendplanList = [Select Id, SpendType__c from SpendPlan__c where Grant__c =: award.Grant__c];
            List < BudgetPeriod__c > budgetPrd = [Select Id, Grant__c, BudgetStartDate__c, BudgetEndDate__c, Status__c from BudgetPeriod__c where Grant__c =: award.Grant__c];
            AggregateResult[] aggResults = [select sum(GrantorAmount__c) grantorAmount
                from AwardBudgetCategory__c
                where Award__c =: recordId
            ];

            Decimal grantorTotal = 0.0;

            for (AggregateResult agg: aggResults) {
                grantorTotal = (Decimal)(agg.get('grantorAmount'));
            }

            String budCat;
            String indirectValue;

            boolean keyPOC = testKeyPOC(recordId, appName);
            if (!keyPOC && appName == 'StateAsGrantor') {
                //errors.add('Please add KeyPOC as an Award Contact before Award Submission.');
                //errors.add(GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-80276'));
            }
            if (!AppUtils.validateBudgetPeriods(award.Grant__r.ProjectPeriodStartDate__c, award.Grant__r.ProjectPeriodEndDate__c, budgetPrd)) {
                errors.add(GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-79576'));
            }

            if (award.Grant__r.TypeOfBudgetCategories__c == 'Construction & Non Construction') {
                budCat = 'Indirect Cost Construction';
            } else {
                budCat = 'Indirect Cost' + ' ' + award.Grant__r.TypeOfBudgetCategories__c;
            }
            indirectValue = GNT.KeyValueStoreHelper.getTextValue(budCat, true);
            List < AwardBudgetCategory__c > awdbclist = [select id, Award__c, BudgetCategoryName__c, Amount1__c from AwardBudgetCategory__c where Award__c =: recordId and BudgetCategoryName__c =: indirectValue];
            system.debug(LoggingLevel.ERROR + 'Control is here - 2');



            Boolean isUploadProgramUSBE = false;
            Set<String> businessRolesToCheck;
            if (award.Grant__r.Program__r.ProgramPathway__c.equals('MSP') || award.Grant__r.Program__r.ProgramPathway__c.equals('Lump-Sum-No-App')) {
                businessRolesToCheck = new Set<String>{'Owner','Executive Approver','Grants Manager','Payment Approver 1','Payment Approver 2'};
            }
            else {
                businessRolesToCheck = new Set<String>{'Owner','Executive Approver','Grants Manager','Payment Approver 1','Payment Approver 2','Payment Approver 3','Payment Approver 4'};
            }
            List<RolesAndResponsibilities__c> rolesAndRespList = [SELECT Id, BusinessRole__c, Program__c FROM RolesAndResponsibilities__c WHERE Program__c =: award.Grant__r.Program__c AND Name__c != null];
            Set<String> businessRolesInRoles = new Set<String>();
            for (RolesAndResponsibilities__c rolesAndRespIterator : rolesAndRespList) {
                if (businessRolesToCheck.contains(rolesAndRespIterator.BusinessRole__c)) {
                    businessRolesToCheck.remove(rolesAndRespIterator.BusinessRole__c);
                }
            }
            if (businessRolesToCheck.size() > 0) {
                errors.add('In order to proceed, the roles table in the Program must contain the following roles: ' + businessRolesToCheck);
            }
            else {
                POexists = true;
                FOexists = true;
                GrantAdminexists = true;
                COMPexists = true;
                LAexists = true;
                Owner = true;
            }
            /*
            for (RolesAndResponsibilities__c role: lstRolesResposiblities) {
                if (role.BusinessRole__c.equals('Program Approver')) {
                    POexists = true;
                }
                if (role.BusinessRole__c.equals('Fiscal Approver')) {
                    FOexists = true;
                }
                if (role.BusinessRole__c.equals('Grants Administrator')) {
                    GrantAdminexists = true;
                }
                if (role.BusinessRole__c.equals('Executive Approver')) {
                    COMPexists = true;
                }
                if ('Legal Approver'.equals(role.BusinessRole__c)) {
                    LAexists = true;
                }
                if ('Owner'.equals(role.BusinessRole__c)) {
                    Owner = true;
                }
            }
            */
            if (budgetPrd.size() > 0) {
                for (BudgetPeriod__c bud: budgetPrd) {
                    if (bud.Status__c == 'Active') {
                        count++;
                    }
                }
            }

            if (POexists == false) {
                errors.add(GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTE-54484'));
            }
            /*
            if ((sitevisitpkglist == null || sitevisitpkglist.size() == 0) && (award.Grant__r.SpendType__c == 'Sub Awards' || (award.Grant__r.SpendType__c == 'Contracts' && award.Grant__r.ReportingPackagesRequired__c == true)) && appName != 'StateAsGrantee') {
                //errors.add('Please associate a Package with Site Visit in grant under attachments.');
                errors.add(GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-66537'));
            }

            if ((closeoutpkgList == null || closeoutpkgList.size() == 0) && (award.Grant__r.SpendType__c == 'Sub Awards' || (award.Grant__r.SpendType__c == 'Contracts' && award.Grant__r.ReportingPackagesRequired__c == true))) {
                //errors.add('Please associate a Package with Closeout in grant under attachments.');
                errors.add(GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-91328'));
            }
            if ((riskassessmentpkgList == null || riskassessmentpkgList.size() == 0) && (award.Grant__r.SpendType__c == 'Sub Awards' || (award.Grant__r.SpendType__c == 'Contracts' && award.Grant__r.ReportingPackagesRequired__c == true))) {
                // errors.add('Please associate a Package with Risk Assessment in grant under attachments.');
                errors.add(GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-68362'));
            }
            if ((progressreportpkglist == null || progressreportpkglist.size() == 0) && (award.Grant__r.SpendType__c == 'Sub Awards' || (award.Grant__r.SpendType__c == 'Contracts' && award.Grant__r.ReportingPackagesRequired__c == true))) {
                //errors.add('Please associate a Package with Progress Report in grant under attachments.');
                errors.add(GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-15578'));
            }
            */
            /*if ((PaymentreqpkgList == null || PaymentreqpkgList.size() == 0) && appName == 'StateAsGrantor' && (award.Grant__r.SpendType__c == 'Sub Awards' || (award.Grant__r.SpendType__c == 'Contracts' && award.Grant__r.ReportingPackagesRequired__c == true))) {
            // errors.add('Please associate a Package with Payment Request in grant under attachments.');
            errors.add(GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-57309'));
            }*/
            if ((spendplanList == null || spendplanList.size() == 0) && appName == 'StateAsGrantee') {
                // errors.add('Please add atleast on spend plan at Federal Grant');
                errors.add(GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-90584'));
            }
            /*
            if (FOexists == false) {
                //errors.add('Fiscal Approver is Required in Roles and Responsibilities');
                errors.add(GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTE-43307'));
            }
            */
            if (COMPexists == false && appName == 'StateAsGrantee') {
                //errors.add('Comptroller Approver is Required in Roles and Responsibilities');
                errors.add(GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTE-27360'));
            }
            if (GrantAdminexists == false) {
                //errors.add('Grant Approver is Required in Roles and Responsibilities');
                errors.add(GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTE-21930'));
            }
            /*
            if (award.GrantorOrganization__c == 'USBE' && LAexists == false) {
                errors.add('Legal Approver is Required in Roles and Responsibilities');
            }
            */
            if (award.GrantorOrganization__c == 'USBE' && Owner == false) {
                errors.add('Owner is Required in Roles and Responsibilities');
            }
            if (award.ObligatedAwardAmount__c == 0) {
                errors.add('Obligated Award Amount should not be 0');
            }
            /*
            if (award.Grant__r.TotalOriginalGrantAmount__c == 0) {
                errors.add('Total Orginal Grant Amount in Grant should not be 0 under Financials tab in grant view');
            }
            */
            /*
            if (award.NumberofFiscalContacts__c == 0) {
                //errors.add ('Please add atleast one Fiscal Contact to Submit for Approval');
                errors.add(GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTE-38594'));
            }
            */
            /*if (award.NumberofProgramContacts__c == 0) {
            //errors.add('Please add atleast one Program Contact to Submit for Approval');
            errors.add(GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTE-20402'));
            }*/
            // if (award.NumberofOtherContacts__c == 0) {
            //     //errors.add ('Please add atleast one Federal/Sponsor Contact to Submit for Approval');
            //     errors.add(GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTE-01159'));
            // }

            if (appName == 'StateAsGrantee' && Math.ceil(award.ProjectAmountofBudgetCategories__c) != award.AwardedAmount__c) {
                //errors.add ('Sum of Catagories in Award Budget categories should be equal to awarded amount');
                errors.add(GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-46617'));
                system.debug('***Project amount of budget cat : ' + award.ProjectAmountofBudgetCategories__c);
                system.debug('***Total amount awarded  : ' + award.AwardedAmount__c);
                //errors.add(GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTE-20862'));
            }
            if (appName == 'StateAsGrantor' && award.AwardAmountThisAction__c != grantorTotal) {
                //TODO: Add the message in error message config
                //errors.add('Sum of grantor budget Catagories in Award Budget categories should be equal to awarded amount this action');
            }
            System.debug('--------------------------1');
            if (award.IndirectCostRateDecision__c == 'Explicit' && awdbclist[0].Amount1__c <= 0) {
                //errors.add ('Please enter Amount on indirect Cost line item in Budget Categories if Indirect cost decision rate is Explicit');
                errors.add(GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-47507'));
            }
            if (award.IndirectCostRateDecision__c == 'Implicit' && awdbclist[0].Amount1__c > 0) {
                // errors.add ('Please do not enter Amount on "Indirect Cost Rate" line item in Budget Categories,if "Indirect Cost Rate Decision" is Implicit');
                errors.add(GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-25307'));
            }
            System.debug('--------------------------2');
            /*if (award.TotalObligateAmount__c <= 0 || award.AwardedAmountthisAction__c < 0) {
            //errors.add ('Total Obligated Amount & Award Amount this action cannot be less than 0');
            errors.add(GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-56885'));

            }*/
            System.debug('--------------------------3');
            //if ((reportingrequirement.size() < 1) && (award.Grant__r.SpendType__c == 'Sub Awards' || award.Grant__r.SpendType__c == 'Contracts')) {
            //    //errors.add ('Please add atleast one Reporting Requirement to Submit for Approval');
            //    errors.add(GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTE-93031'));
            //}
            System.debug('--------------------------4');
            /*if ((paymentrequest.size() < 1 && appName == 'StateAsGrantor') && (award.Grant__r.SpendType__c == 'Sub Awards' || award.Grant__r.SpendType__c == 'Contracts')) {
            //errors.add ('Please add atleast one Payment Request Schedule to Submit for Approval');
            errors.add(GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTE-91717'));
            }*/
            /*if (awdfundingaccount.size() < 1 && appName == 'StateAsGrantor') {
            //errors.add ('Please add atleast one Funding Account to Submit for Approval');
            errors.add(GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTE-80329'));
            }*/
            /*if (award.AreTCspartofNGAAttachments__c == true && attachment.size() < 2) {
                //errors.add ('Please add  two attachments to Submit for Approval');
                errors.add(GNT.ErrorMessageHelper.fetchMessage('P13-GRNTE-51657'));
            }*/
           /* if (award.AreTCspartofNGAAttachments__c == false && attachment.size() < 1) {
                //errors.add ('Please add atleast one attachment to Submit for Approval');
                errors.add(GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTE-54874'));
            } */
            // if (award.AreTCspartofNGAAttachments__c == false && term.size() < 1) {
            //     //errors.add ('Please add atleast one Term and Condition to Submit for Approval');
            //     errors.add(GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTE-29503'));
            // }
            if (award.AwardIssueDate__c == null) {
                //errors.add ('The award cannot be submiited as for this Grantee Organization debarment process has been initiated');
                errors.add('Please enter Award Issue date. ');
            }
            if (award.Grant__r.InternalOrganization__r.status__c == 'Debarred') {
                //errors.add ('The award cannot be submiited as for this Grantee Organization debarment process has been initiated');
                errors.add(GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-37493'));
            }
            if (count == 0) {
                errors.add(GNT.ErrorMessageHelper.fetchMessage('P13-GRNTE-32469'));
            }
            if (count > 1) {
                errors.add(GNT.ErrorMessageHelper.fetchMessage('P13-GRNTE-67817'));
            }

            if (errors.size() > 0) {
                for (String error: errors) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, error));
                }
            } else {
                award.Status__c = 'Submitted for Approval';
                update award;
                List<Task> finetLinkingTask = GNT.TaskCreationHandler.createTasks(award.AwardApprover1__c,
                    award.Id,'FINET Linking',
                    award.Name + ' FINET Linking', null, false, null,
                    'Review', award.Name + ' FINET Linking', true
                );
                PageReference pf = Page.AwardView;
                pf.setRedirect(true);
                pf.getParameters().put('id', award.Id);
                return pf;
            }
            return null;
        }catch(Exception e){
            Database.rollback(sp);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, e.getMessage()));
            return null;
        }
    }

    public boolean testKeyPOC(Id recordId, String appName) {
        boolean keyPOC = false;
        if (appName == 'StateAsGrantor') {
            List < GrantContact__c > grantContacts = [SELECT Id, Role__c
                FROM GrantContact__c
                where Award__c =: recordId
            ];
            if (grantContacts.size() > 0) {
                for (GrantContact__c grantContact: grantContacts) {
                    if (grantContact.Role__c.equals('KeyPOC')) {
                        keyPOC = true;
                    }
                }
            }
        }
        return keyPOC;
    }

}