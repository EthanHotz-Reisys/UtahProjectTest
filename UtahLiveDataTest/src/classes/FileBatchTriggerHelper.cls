public class FileBatchTriggerHelper extends GNT.TriggerHelper {

    public static boolean skipTrigger = false;
    private Id RECORD_TYPE_MSP = Schema.SObjectType.FileBatch__c.getRecordTypeInfosByName().get(UTConstants.FILE_BATCH_MSP).getRecordTypeId();
    private Id RECORD_TYPE_FED_FORMULA = Schema.SObjectType.FileBatch__c.getRecordTypeInfosByName().get(UTConstants.FILE_BATCH_FED_FORMULA).getRecordTypeId();
    private Id RECORD_TYPE_STATE_FORMULA = Schema.SObjectType.FileBatch__c.getRecordTypeInfosByName().get(UTConstants.FILE_BATCH_STATE_FORMULA).getRecordTypeId();
    private Id RECORD_TYPE_APP12_FORMULA = Schema.SObjectType.FileBatch__c.getRecordTypeInfosByName().get(UTConstants.FILE_BATCH_APP12).getRecordTypeId();
    private Id RECORD_TYPE_LSA_FORMULA = Schema.SObjectType.FileBatch__c.getRecordTypeInfosByName().get(UTConstants.FILE_BATCH_LSA).getRecordTypeId();
    private Id RECORD_TYPE_LSNA_FORMULA = Schema.SObjectType.FileBatch__c.getRecordTypeInfosByName().get(UTConstants.FILE_BATCH_LSNA).getRecordTypeId();

    public override void processBeforeInsert() {
        giveFileBatchKeyValue((List<FileBatch__c>)Trigger.new);
        validAmendment((List<FileBatch__c>)Trigger.new);
        validCreate((List<FileBatch__c>)Trigger.new);
        validateCreator((List<FileBatch__c>)Trigger.new);
        GNT.NameTemplateTriggerHelper.beforeInsert();
    }

    public override void processBeforeUpdate() {
        List<FileBatch__c> updatedBatches = (List<FileBatch__c>)Trigger.new;
        List<FileBatch__c> processedBatches = getBatches(updatedBatches, 'Uploaded', 'Processed');
        FileBatchValidator validator;
        System.debug('process validation before update >>> ' + (List<FileBatch__c>)Trigger.new + (List<FileBatch__c>)Trigger.old);

        if (processedBatches.size() > 0) {
            Map<Id, List<FileBatch__c>> categories = getBatchesByCategory(processedBatches);
            validator = getValidator(categories);
            FileBatchValidationResult  validationResult = validator.validate();
            if (validationResult.Status == false) {
                String errorMessage = String.join(validationResult.ErrorMessages, '***');
                for (FileBatch__c fb : processedBatches) {
                    fb.Status__c = 'Error';
                    fb.ErrorLog__c  = errorMessage;
                }
            }
        }
    }

    //This methods handles single instance of Filebatch.
    public override void processAfterUpdate() {
        List<FileBatch__c> updatedBatches = (List<FileBatch__c>)Trigger.new;
        List<FileBatch__c> processedBatches = getBatches(updatedBatches, 'Uploaded', 'Processed');
        System.debug('process validation after update >>> ');

        if (processedBatches.size() > 0) {
            createApprovalTask(processedBatches);
        }
    }

    Map<Id, List<FileBatch__c>> getBatchesByCategory(List<FileBatch__c> batches) {
        Map<Id, List<FileBatch__c>> results = new Map<Id, List<FileBatch__c>>();
        for (FileBatch__c fb : batches) {
            List<FileBatch__c> tempBatches = results.get(fb.RecordTypeId);
            if (tempBatches == null) {
                tempBatches = new List<FileBatch__c>();
                results.put(fb.RecordTypeId, tempBatches);
            }
            tempBatches.add(fb);

        }
        return results;
    }


    private FileBatchValidator getValidator(Map<Id, List<FileBatch__c>> batches) {
        FileBatchValidator validator;
        for (Id recordType : batches.keySet()) {
            List<FileBatch__C> fileBatches = batches.get(recordType);
            if (recordType == RECORD_TYPE_MSP || recordType == RECORD_TYPE_LSNA_FORMULA) {
                validator = new FileBatchValidatorMSP(fileBatches);
            } else if (recordType == RECORD_TYPE_FED_FORMULA || recordType == RECORD_TYPE_STATE_FORMULA
                       || recordType == RECORD_TYPE_APP12_FORMULA || recordType == RECORD_TYPE_LSA_FORMULA
                      ) {
                validator = new FileBatchValidatorFedFormula(fileBatches);
            }
        }
        return validator;
    }


    private void giveFileBatchKeyValue(List<FileBatch__c> batchList) {
        for (FileBatch__c fb : batchList) {
            fb.FileBatchKey__c = fb.RecordTypeId + fb.FiscalYear__c;
        }
    }

    private void validAmendment(List<FileBatch__c> batchList) {
        List<FileBatch__c> amendBatches = new List<FileBatch__c>();
        for (FileBatch__c fb : batchList) {
            if (fb.ActionType__c == 'Amend') {
                amendBatches.add(fb);
            }
        }

        Set<String> fileBatchKeys = new Set<String>();
        for (FileBatch__c fb : amendBatches) {
            if (!fileBatchKeys.contains(fb.FileBatchKey__c)) {
                fileBatchKeys.add(fb.FileBatchKey__c);
            }
        }

        AggregateResult[] fbCounts = [SELECT COUNT(Id) fbCount FROM FileBatch__c WHERE Status__c = 'Active' AND FileBatchKey__c IN :fileBatchKeys GROUP BY FileBatchKey__c];
        if (fbCounts.size() != fileBatchKeys.size()) {
            for (FileBatch__c fb : amendBatches) {
                fb.addError('At Least One Create Batch Should be Active Before Amend for This Fiscal Year');
            }
        }
    }

    private void validCreate(List<FileBatch__c> batchList) {
        List<FileBatch__c> createBatches = new List<FileBatch__c>();
        for (FileBatch__c fb : batchList) {
            if (fb.ActionType__c == 'Create') {
                createBatches.add(fb);
            }
        }
        Set<String> fileBatchKeys = new Set<String>();
        for (FileBatch__c fb : createBatches) {
            if (!fileBatchKeys.contains(fb.FileBatchKey__c)) {
                fileBatchKeys.add(fb.FileBatchKey__c);
            }
        }
        AggregateResult[] fbCounts = [SELECT COUNT(Id) fbCount FROM FileBatch__c WHERE Status__c IN ('Active', 'Sent for Activation') AND FileBatchKey__c IN :fileBatchKeys GROUP BY FileBatchKey__c];
        if (fbCounts.size() > 0) {
            for (FileBatch__c fb : createBatches) {
                fb.addError('A batch is already approved or active for this fiscal year, cannot create another create batch');
            }
        }
    }

    private List<FileBatch__c> getBatches(List<FileBatch__c> batchList, string oldStatus, string newStatus) {
        List<FileBatch__c> validBatches = new List<FileBatch__c>();
        Map<Id, FileBatch__c> batchOldMap = (Map<Id, FileBatch__c>)Trigger.oldMap;

        for (FileBatch__c fb : batchList) {

            if (fb.Status__c == newStatus  && batchOldMap.get(fb.Id).Status__c == oldStatus) {
                validBatches.add(fb);
            }
        }
        return validBatches;
    }
    private void createApprovalTask(List<FileBatch__c> validBatch) {

        /*List<FileBatch__c> validBatch = new List<FileBatch__c>();
        Map<Id, FileBatch__c> batchOldMap = (Map<Id, FileBatch__c>)Trigger.oldMap;

        for (FileBatch__c fb : batchList) {
            if (fb.Status__c == 'Processed' && batchOldMap.get(fb.Id).Status__c == 'Uploaded') {
                validBatch.add(fb);
            }
        }

        if (validBatch.size() == 0) {
            return;
        }
        */

        List<Task> batchApprovalTasks = new List<Task>();

        for (FileBatch__c fb : validBatch) {
            if (fb.RecordTypeId == Schema.SObjectType.FileBatch__c.getRecordTypeInfosByName().get(UTConstants.FILE_BATCH_MSP).getRecordTypeId()) {
                List<Task> batchApprovalTask = GNT.TaskCreationHandler.createTasks(fb.FirstApprover__c,
                                               fb.Id, 'MSP Batch Approval',
                                               fb.FiscalYear__c + ' ' + fb.ActionType__c, null, false, null,
                                               'Approval', fb.FiscalYear__c + ' ' + fb.ActionType__c, false
                                                                                  );

                if (batchApprovalTask != null && batchApprovalTask.size() > 0) {
                    batchApprovalTasks.add(batchApprovalTask[0]);
                }
            } else if (fb.RecordTypeId == Schema.SObjectType.FileBatch__c.getRecordTypeInfosByName().get(UTConstants.FILE_BATCH_FED_FORMULA).getRecordTypeId()) {
                List<Task> batchApprovalTask = GNT.TaskCreationHandler.createTasks(fb.FirstApprover__c,
                                               fb.Id, 'Fed Formula Batch',
                                               fb.FiscalYear__c + ' ' + fb.ActionType__c, null, false, null,
                                               'Approval', 'Review and Approve' + fb.FiscalYear__c + ', ' + fb.ActionType__c, false
                                                                                  );

                if (batchApprovalTask != null && batchApprovalTask.size() > 0) {
                    batchApprovalTasks.add(batchApprovalTask[0]);
                }
            }
        }

        insert batchApprovalTasks;
    }


    private void validateCreator(List<FileBatch__c> batchList) {
        //uncomment below comments for activating first approver and second approver validation
        /*
        for (FileBatch__c fb : batchList) {
             if ((fb.FirstApprover__c != null && fb.SecondApprover__c != null) && (fb.FirstApprover__c == fb.SecondApprover__c)) {
                 fb.addError('The First Approver and Second Approver cannot be the same person');
             }
        }*/
        /************** not useful  ***********/
        /*
        List<FileBatch__c> mspBatch = new List<FileBatch__c>();
        for(FileBatch__c fb : batchList){
            if(fb.RecordTypeId == Schema.SObjectType.FileBatch__c.getRecordTypeInfosByName().get(UTConstants.FILE_BATCH_MSP).getRecordTypeId()){
                mspBatch.add(fb);
            }
        }
        */
        //Group mspGroup = [SELECT Id, Name FROM Group WHERE Type = 'Regular' AND Name = 'USBEFINOPS'];
        //List<GroupMember> mspGroupMembers = [SELECT Id, UserOrGroupId FROM GroupMember WHERE GroupId = :mspGroup.Id];
        List<User> mspGroupMembers = [SELECT Id FROM User WHERE ProfileName__c = 'EXE' or ProfileName__c = 'System Administrator'];
        Set<String> mspGroupMemberIds = new Set<String>();
        for (User gm : mspGroupMembers) {
            //mspGroupMemberIds.add(gm.UserOrGroupId);
            mspGroupMemberIds.add(gm.Id);
        }
        if (!mspGroupMemberIds.contains(UserInfo.getUserId())) {
            for (FileBatch__c fb : batchList) {
                fb.addError('You cannot create batch');
            }
        }
    }

    private class FileBatchValidationResult {
        public Boolean Status {get; set;}
        public List<String> ErrorMessages {get; set;}
        FileBatchValidationResult() {
            Status = true;
            ErrorMessages = new List<String>();
        }
    }

    private virtual class FileBatchValidator {
        protected List<FileBatch__c> fileBatches;
        public FileBatchValidator(List<FileBatch__c> batches) {
            fileBatches = batches;
        }

        public virtual FileBatchValidationResult validate() {
            return new FileBatchValidationResult ();
        }

    }

    private class FileBatchValidatorMSP extends FileBatchValidator {
        public FileBatchValidatorMSP(List<FileBatch__c> batches) {
            super(batches);
        }

        public override  FileBatchValidationResult validate() {
            FileBatchValidationResult result = super.validate();
            if (result.Status == true) {
                List<MSPFinancialStage__c> details = getDetails(fileBatches[0].Id);
                processProgramCodes(details, result );
                processObjectCodes(details, result);
                processAmounts(details, result);
                validateStagingData(details, result);
                validateLeaId(details, result);
                //validateProgramKeys(details, result, fileBatches[0]);
            }
            return result;
        }

        private void  validateLeaId(List<MSPFinancialStage__c> mfss, FileBatchValidationResult validationResult) {
            for (MSPFinancialStage__c mfs : mfss) {
                if (mfs.SubRecipient__c == null) {
                    validationResult.Status = false;
                    validationResult.ErrorMessages.add('Empty LEA');
                    break;
                }
            }
        }

        private void  validateProgramKeys(List<MSPFinancialStage__c> mfss, FileBatchValidationResult validationResult, FileBatch__c fb) {
            for (MSPFinancialStage__c mfs : mfss) {
                string key = mfs.Program__r.ProgramKey__c;
                if (key.length() < 4 || (key.length() > 4 && key.substring(key.length() - 4) != fb.FiscalYear__c)) {
                    validationResult.Status = false;
                    validationResult.ErrorMessages.add('Missing fiscal year in Program Key for year '+ fb.FiscalYear__c +', :' + key );
                }
            }
        }

        private void validateStagingData(List<MSPFinancialStage__c> mfss, FileBatchValidationResult validationResult) {
            Set<String> keySets = new Set<String>();
            List<String> result = new List<String>();
            for (MSPFinancialStage__c mfs : mfss) {
                if (!keySets.contains(mfs.UniqueKeyFormula__c)) {
                    keySets.add(mfs.UniqueKeyFormula__c);
                } else {
                    validationResult.Status = false;
                    if (!result.contains(mfs.SubRecipient__r.LEA_Id__c + ' : ' + mfs.Program__r.ProgramKey__c)) result.add(mfs.SubRecipient__r.LEA_Id__c + ' : ' + mfs.Program__r.ProgramKey__c);
                }
            }
            if (result.size() > 0) validationResult.ErrorMessages.add('Duplicate FINET linking in Excel:  ' + String.join(result , ', '));
        }

        private void processProgramCodes( List<MSPFinancialStage__c> details, FileBatchValidationResult validationResult) {

            Set<string> programCodes = new Set<string>();
            for (MSPFinancialStage__c stage : details) {
                programCodes.add(stage.ProgramCode__c);
            }
            List<r_prog__c  > programs = [SELECT PROG_CD__c FROM r_prog__c  where PROG_CD__c  in : programCodes];
            Set<string> programCodesDB = new Set<string>();
            for (r_prog__c  program : programs ) {
                programCodesDB.add(program.PROG_CD__c );
            }
            programCodes.removeAll(programCodesDB);
            if (programCodes != null && programCodes.size() > 0) {
                List<string> temp = new List<string>(programCodes);
                validationResult.ErrorMessages.add('Invalid Program Codes : ' + String.join(temp , ', '));
                validationResult.Status = false;
            }

        }

        private void processObjectCodes( List<MSPFinancialStage__c> details, FileBatchValidationResult validationResult) {

            Set<string> objectCodes = new Set<string>();
            for (MSPFinancialStage__c stage : details) {
                objectCodes.add(stage.ObjectCode__c);
            }
            List<r_obj__c> objectCodeInstances = [SELECT OBJ_CD__c FROM r_obj__c where OBJ_CD__c in : objectCodes];
            Set<string> objectCodesDB = new Set<string>();
            for (r_obj__c  instance : objectCodeInstances ) {
                objectCodesDB.add(instance.OBJ_CD__c );
            }
            objectCodes.removeAll(objectCodesDB);
            if (objectCodes != null && objectCodes.size() > 0) {
                List<string> temp = new List<string>(objectCodes);
                validationResult.ErrorMessages.add('Invalid Object Codes : ' + String.join(temp , ', '));
                validationResult.Status = false;
            }

        }

        private void processAmounts(List<MSPFinancialStage__c> details, FileBatchValidationResult validationResult) {
            for (MSPFinancialStage__c stage : details) {
                if (stage.AwardAmountFormula__c == null || stage.AwardAmountFormula__c < 0) {
                    validationResult.ErrorMessages.add('Invalid Award Amount for Program Code: ' + stage.Program__r.ProgramCode__c + ', Lea Code: ' + stage.SubRecipient__r.LEA_Id__c);
                    validationResult.Status = false;
                }
            }
        }

        private List<MSPFinancialStage__c> getDetails(Id fileBatchId) {
            List<MSPFinancialStage__c> results = [SELECT AwardAmountFormula__c, AwardAmount__c, FileBatch__c, Id, LEAComment__c, ObjectCode__c, ProgramCode__c, Program__c, SubRecipient__c, UniqueKeyFormula__c, Program__r.ProgramCode__c, SubRecipient__r.LEA_Id__c, Program__r.ProgramKey__c  FROM MSPFinancialStage__c Where FileBatch__c = :fileBatchId ];
            return results;
        }
    }

    private class FileBatchValidatorFedFormula extends FileBatchValidator {

        public FileBatchValidatorFedFormula (List<FileBatch__c> batches) {
            super(batches);
        }

        public override  FileBatchValidationResult validate() {
            FileBatchValidationResult result = super.validate();
            if (result.Status == true) {
                List<FEDBudgetStage__c> details = getDetails(fileBatches[0].Id);
                processProgramCodes(details, result );
                processObjectCodes(details, result);
                processKeyContacts(details, result);
                processAmounts(details, result);
                processDates(details, result);
                //validateProgramKeys(details, result, fileBatches[0]);
            }
            return result;
        }

        private void processProgramCodes( List<FEDBudgetStage__c> details, FileBatchValidationResult validationResult) {

            Set<string> programCodes = new Set<string>();
            for (FEDBudgetStage__c stage : details) {
                programCodes.add(stage.ProgramCode__c);
            }
            List<r_prog__c  > programs = [SELECT PROG_CD__c FROM r_prog__c  where PROG_CD__c  in : programCodes];
            Set<string> programCodesDB = new Set<string>();
            for (r_prog__c  program : programs ) {
                programCodesDB.add(program.PROG_CD__c );
            }
            programCodes.removeAll(programCodesDB);
            if (programCodes != null && programCodes.size() > 0) {
                List<string> temp = new List<string>(programCodes);
                validationResult.ErrorMessages.add('Invalid Program Codes : ' + String.join(temp , ', '));
                validationResult.Status = false;
            }

        }

        private void  validateProgramKeys(List<FEDBudgetStage__c> details, FileBatchValidationResult validationResult, FileBatch__c fb) {
            for (FEDBudgetStage__c item : details) {
                string key = item.Program__r.ProgramKey__c;
                if (key.length() < 4 || (key.length() > 4 && key.substring(key.length() - 4) != fb.FiscalYear__c)) {
                    validationResult.Status = false;
                    validationResult.ErrorMessages.add('Missing fiscal year in Program Key for year '+ fb.FiscalYear__c +', :' + key );
                }
            }
        }

        private void processObjectCodes( List<FEDBudgetStage__c> details, FileBatchValidationResult validationResult) {

            Set<string> objectCodes = new Set<string>();
            for (FEDBudgetStage__c stage : details) {
                objectCodes.add(stage.ObjectCode__c);
            }
            List<r_obj__c> objectCodeInstances = [SELECT OBJ_CD__c FROM r_obj__c where OBJ_CD__c in : objectCodes];
            Set<string> objectCodesDB = new Set<string>();
            for (r_obj__c  instance : objectCodeInstances ) {
                objectCodesDB.add(instance.OBJ_CD__c );
            }
            objectCodes.removeAll(objectCodesDB);
            if (objectCodes != null && objectCodes.size() > 0) {
                List<string> temp = new List<string>(objectCodes);
                validationResult.ErrorMessages.add('Invalid Object Codes : ' + String.join(temp , ', '));
                validationResult.Status = false;
            }

        }

        private void processAmounts(List<FEDBudgetStage__c> details, FileBatchValidationResult validationResult) {
            for (FEDBudgetStage__c stage : details) {
                if (stage.BudgetAmountFormula__c == null || stage.BudgetAmountFormula__c < 0) {
                    validationResult.ErrorMessages.add('Invalid Budget Amount for Program Code: ' + stage.Program__r.ProgramCode__c + ', Lea Code: ' + stage.SubRecipient__r.LEA_Id__c);
                    validationResult.Status = false;
                }
            }
        }

        private void processKeyContacts(List<FEDBudgetStage__c> details, FileBatchValidationResult validationResult) {
            System.debug('keycontacts >>> ' + details);
            for (FEDBudgetStage__c stage : details) {
                if (stage.KeyContactId__c == null) {
                    validationResult.ErrorMessages.add('Key Contact is not available for Program Code: ' + stage.Program__r.ProgramCode__c + ', Lea Code: ' + stage.SubRecipient__r.LEA_Id__c);
                    validationResult.Status = false;
                }
            }
        }

        private void processDates(List<FEDBudgetStage__c> details, FileBatchValidationResult validationResult) {

            Map<string, ProgramWrapper> programs = new Map<string, ProgramWrapper>();
            for (FEDBudgetStage__c stage : details) {
                string programCode = stage.Program__r.ProgramCode__c;
                if (!programs.containsKey(programCode)) {
                    ProgramWrapper wrapper = new ProgramWrapper();
                    wrapper.ProgramTitle = stage.Program__r.ProgramCode__c;
                    wrapper.ApplicationDeadline = stage.Program__r.ApplicationDeadline__c;
                    wrapper.ProjectStartDate = stage.Program__r.StartDate__c;
                    wrapper.ProjectEndDate = stage.Program__r.EndDate__C;
                    programs.put(programCode,  wrapper);
                }
            }
            for (String programCode : programs.keySet()) {
                ProgramWrapper program = programs.get(programCode);
                DateTime today = DateTime.now();
                if (program.ApplicationDeadline ==  null || program.ApplicationDeadline < today) {
                    validationResult.ErrorMessages.add('Invalid either Application dead line or Application deadline date should not be a past date for ' + programCode);
                    validationResult.Status = false;
                }

                if (program.ProjectStartDate ==  null || program.ProjectEndDate ==  null || program.ProjectStartDate > program.ProjectEndDate || program.ProjectStartDate < today) {
                    validationResult.ErrorMessages.add('Invalid Project Start Date and End Date or Project Start Date should not be Past or Project Period End Date should be greater than Project Period Start Date for ' + programCode);
                    validationResult.Status = false;
                }
            }
        }

        private List<FEDBudgetStage__c> getDetails(Id fileBatchId) {
            List<FEDBudgetStage__c> results = [SELECT BudgetAmountFormula__c, BudgetAmount__c, FileBatch__c, Id, KeyContactId__c, LEAComment__c, ObjectCode__c, ProgramCode__c, Program__c, SubRecipient__c, UniqueKeyFormula__c, Program__r.ProgramKey__c, Program__r.ProgramCode__c, SubRecipient__r.LEA_Id__c, Program__r.StartDate__c, Program__r.EndDate__C, Program__r.ApplicationDeadline__c FROM FEDBudgetStage__c Where FileBatch__c = :fileBatchId ];
            return results;
        }

    }


    private class ProgramWrapper {
        public DateTime ApplicationDeadline {get; set;}
        public Date ProjectStartDate {get; set;}
        public Date ProjectEndDate {get; set;}
        public string ProgramTitle {get; set;}
    }


}