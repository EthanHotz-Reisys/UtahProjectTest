global class  FedFormulaValidateBatch implements Database.Batchable<sObject>, Database.Stateful {
	private List<String> errors = new List<string>();
	private FileBatch__C fb;

	List<Announcement__c> batchAnnouncements = new List<Announcement__c>();
	List<Application__c> batchApplications = new List<Application__c>();
	List<FedBudgetMain__C> batchMainItems = new List<FedBudgetMain__C>();

	public FedFormulaValidateBatch(FileBatch__C fb) {
		this.fb = fb;
	}

	global List<FileBatch__C> start(Database.BatchableContext BC) {
		return new List<FileBatch__c> {fb};
	}

	global void execute(Database.BatchableContext BC, List<FileBatch__C> scope) {
		Savepoint sp = Database.setSavepoint();
		try {
			setSkipTrigger(false);
			process();
		} catch (Exception e) {
			errors.add(e.getMessage() + e.getStackTraceString());
			System.debug(e.getMessage());
			Database.rollback(sp);
		}
		setSkipTrigger(false);
	}
	private void setSkipTrigger(Boolean status) {
		RolesandResponsibilitiesTriggerHelper.skipTrigger = status;
		USBEAnnouncementTriggerHelper.skipTrigger = status;
		AnnouncementTriggerHelper.skipTrigger = status;
	}
	global void finish(Database.BatchableContext BC) {
		if (errors.size() == 0) {
			try {
				fb.Status__c = 'Active';
				update fb;
				if (fb.ActionType__c == 'Amend') {
					List<FileBatch__c> otherfbs = [SELECT Id, Status__c FROM FileBatch__c WHERE Id != :fb.Id AND Status__c = 'Active'  AND FiscalYear__c = :fb.FiscalYear__c];
					for (FileBatch__c otherfb : otherfbs) {
						otherfb.Status__c = 'Replaced';
					}
					update otherfbs;
				}
				if (this.batchApplications.size() > 0) {
					Database.executeBatch(new FedFormulaAnnouncementBatch(fb, this.batchMainItems, this.batchAnnouncements, this.batchApplications), 2000);
				}
			} catch (Exception e) {
				//errors.add(e.getMessage() + e.getStackTraceString());
			}
		}

		if (errors.size() > 0) {
			for (String error : errors) {
				fb.ErrorLog__c =  fb.ErrorLog__c + ';' + error;
			}
			fb.Status__c = 'Error';
			update fb;
		}
		setSkipTrigger(false);
	}


	void process() {
		Id fileBatchId = fb.Id;
		string fiscalYear = fb.FiscalYear__c;
		string APPID_SET = 'noAwardAppIdSet';
		string AWARDID_SET = 'awardAppIdSet';
		List<FEDBudgetStage__c> stageItems = [SELECT Program__C, BudgetAmountFormula__c, Program__r.Id, FileBatch__R.FiscalYear__C, Ownerid, ObjectCode__C, ProgramCode__C,  Program__r.ProgramName__c, SubRecipient__r.Name, LEAComment__c, SubRecipient__C, SubRecipient__r.LEA_Id__c, BudgetAmount__c, KeyContactId__C , UniqueKeyFormula__c FROM FEDBudgetStage__c where FileBatch__C = :fileBatchId];
		List<FEDBudgetMain__c> mainItems = [SELECT Program__r.Id, Program__r.ProgramName__c, Ownerid, ObjectCode__C, ProgramCode__C, SubRecipient__r.Name, SubRecipient__C, LEAComment__c, SubRecipient__r.LEA_Id__c, BudgetAmount__c, UniqueKeyFormula__c FROM FEDBudgetMain__c where fiscalyear__C = :fiscalYear];
		Map<string, FEDBudgetMain__c> mapMainItems = getMapMainItems(mainItems);
		List<Application__C> dbApplications = [select Id, Announcement__C,  Announcement__R.Program__C, Ownerid, ExternalOrganization__c, BudgetAllocation__c from Application__c  where fiscalyear__C = :fiscalYear and Status__c != 'Snapshot'];
		List<Announcement__C> dbAnnouncements = [select EstimatedProjectPeriodStartDate__c, EstimatedProjectPeriodEndDate__c,  ApplicationDeadlineWithDateTime__c, AnnouncementName__c, Program__c, Id from Announcement__c   where fiscalyear__C = :fiscalYear and Status__c != 'Snapshot'];
		Map<string, decimal> stageProgramLeaMap =   getStagingApplicationsMap(stageItems);
		Map<string, decimal> stageProgramMap =   getStagingProgramMap(stageItems);
		Map<string, Application__C> dbProgramLeaMap = new Map<string, Application__C>();
		Map<Id, Announcement__C> dbProgramMap = new Map<Id, Announcement__C>();
		List<FedBudgetStage__C> newAnnouncementApplications = new List<FedBudgetStage__C>();
		List<FedBudgetStage__C> newApplications = new List<FedBudgetStage__C>();
		List<FedBudgetStage__C> existingApplications = new List<FedBudgetStage__C>();
		List<FedBudgetStage__C> ignoreItems = new List<FedBudgetStage__C>();
		Map<Id, decimal> preApplicationIdDifferences = new Map<Id, decimal>();
		Map<Id, Id> keyContacts = getKeyContacts(stageItems);
		List<FedBudgetMain__C> newMainItems = new List<FedBudgetMain__C>();
		List<FedBudgetMain__C> updatedMainItems = new List<FedBudgetMain__C>();

		for (Announcement__C announcement : dbAnnouncements) {
			dbProgramMap.put(announcement.Program__C, announcement);
		}
		for (Application__C application : dbApplications) {
			dbProgramLeaMap.put(application.Announcement__R.Program__C + '_' + application.ExternalOrganization__c , application);
		}


		for (FedBudgetStage__C stage : stageItems) {
			if (!dbProgramMap.containsKey(stage.Program__C) && stage.BudgetAmountFormula__c != null && stage.BudgetAmountFormula__c != 0) {
				newAnnouncementApplications.add(stage);
				newMainItems.add(createMain(stage));
			} else if (!dbProgramLeaMap.containsKey(stage.Program__C + '_' + stage.SubRecipient__C) && stage.BudgetAmountFormula__c != null && stage.BudgetAmountFormula__c != 0) {
				newApplications.add(stage);
				newMainItems.add(createMain(stage));
			} else if (dbProgramLeaMap.containsKey(stage.Program__C + '_' + stage.SubRecipient__C) && dbProgramLeaMap.get(stage.Program__C + '_' + stage.SubRecipient__C).BudgetAllocation__c != stage.BudgetAmountFormula__c) {
				existingApplications.add(stage);
				string key = stage.Program__c + '' + stage.SubRecipient__c + '' + stage.ProgramCode__c + '' + stage.ObjectCode__c + '' + stage.FileBatch__R.FiscalYear__C;
				FedBudgetMain__C mainItem = mapMainItems.get(key);
				if (mainItem != null) {
					mainItem.BudgetAmount__c = stage.BudgetAmount__c;
					updatedMainItems.add(mainItem);
				}
			} else if (dbProgramLeaMap.containsKey(stage.Program__C + '_' + stage.SubRecipient__C) && dbProgramLeaMap.get(stage.Program__C + '_' + stage.SubRecipient__C).BudgetAllocation__c == stage.BudgetAmountFormula__c) {
				ignoreItems.add(stage);
			} else {
				system.debug('Error Processing in Batch file');
				//errors.add('Error Processing in Batch file');
			}
		}

		Map<string, decimal> newProgramLeaMap = getStagingApplicationsMap(newAnnouncementApplications);
		Map<string, decimal> newProgramMap =   getStagingProgramMap(newAnnouncementApplications);
		Map<string, decimal> onlyProgramLeaMap = getStagingApplicationsMap(newApplications);
		Map<string, decimal> existingProgramLeaMap = getStagingApplicationsMap(existingApplications);
		for (string key : existingProgramLeaMap.keySet()) {
			Application__C application = dbProgramLeaMap.get(key);
			if (application != null) {
				preApplicationIdDifferences.put(application.Id, existingProgramLeaMap.get(key));
			}
		}

		System.debug('stage items:' + stageItems);
		System.debug('main items : ' + mainItems);
		System.debug('db announcements ' + dbAnnouncements);
		System.debug('db applications ' + dbApplications);
		System.debug('db program map ' + dbProgramMap);
		System.debug('db program lea map' + dbProgramLeaMap);
		System.debug('stage program lea map ' + stageProgramLeaMap);
		System.debug('stage program map' + stageProgramMap);
		System.debug('new program lea map ' + newProgramLeaMap);
		System.debug('new program map' + newProgramMap);
		System.debug('only application program lea map' +onlyProgramLeaMap);
		System.debug('existing program lea map' + existingProgramLeaMap);
		System.debug('ignored items' + ignoreItems);

		if (preApplicationIdDifferences.size() > 0) {
			Map<String, Set<Id>> temp = USBEAmendApplicationInReviewHelper.resolveApplicationIds(preApplicationIdDifferences.keySet());
			//For Awarded applications
			if (temp.containsKey(AWARDID_SET) == true) {
				Set<Id> awardApplicationIds = temp.get(AWARDID_SET);
				Map<Id, Decimal> awardApplications = new Map<Id, Decimal>();
				for (Id applicationId : awardApplicationIds) {
					awardApplications.put(applicationId, preApplicationIdDifferences.get(applicationId));
				}
				if (awardApplications.size() > 0) {
					USBEAmendApplicationInReviewHelper.updateAwardAllocatedAmounts(awardApplications);
				}
			}
			//For Applications which are in draft, review and fdm
			if (temp.containsKey(APPID_SET) == true && temp.get(APPID_SET).size() > 0) {
				Set<Id> applicationIdDifferences = temp.get(APPID_SET);
				//call process method to update application status
				USBEAmendApplicationInReviewHelper.process(applicationIdDifferences);
				//call JL method to create snapshots
				ApplicationSnapshotHelper snapShotHelper = new ApplicationSnapshotHelper();
				system.debug('snapshot ids ' + applicationIdDifferences);
				snapShotHelper.createSnapshot(new List<Id>(applicationIdDifferences));
				updateNonAwardApplications(preApplicationIdDifferences, applicationIdDifferences);
			}
			if (updatedMainItems != null && updatedMainItems.size() > 0) {
				update updatedMainItems;
			}
		}

		if (newMainItems.size() > 0) {
			//uncomment following lines
			this.batchMainItems = newMainItems;
			createAnnouncementsApplications(fb, newProgramMap, newProgramLeaMap, onlyProgramLeaMap, keyContacts, dbProgramMap);

		}

	}


	void createAnnouncementsApplications(FileBatch__C fb, Map<string, decimal> announcements,
	                                     Map<string, decimal> applications, Map<string, decimal> onlyApplications, Map<Id, Id>
	                                     keyContacts, Map<Id, Announcement__c> existingProgramAnnouncements) {

		Map<Id, Program__C> programs = getPrograms(announcements.keySet());
		List<Announcement__c> lstAnnouncements = new List<Announcement__c>();
		Map<Id, Announcement__c> programAnnouncements = new Map<Id, Announcement__c>();
		System.debug('MANUALDEBUG >>> mapped applications >>>' + applications.size() + ',:' + applications);

		for (String programId : announcements.keySet()) {
			Program__c program = programs.get(programId);
			Decimal budgetAmount = announcements.get(programId).setScale(2);
			Announcement__c announcement = new Announcement__c();
			announcement.Program__c = programId;
			announcement.AnnouncementName__c =  program.ProgramName__c + ' - ' + string.valueOf(fb.FiscalYear__c) ;
			announcement.AnnouncementType__c = 'Formula Grants';
			announcement.AnnouncementDescription__c = program.Objectives__c;
			announcement.FiscalYear__c = fb.FiscalYear__c;
			announcement.FOAStatus__c = 'Draft';
			announcement.Status__c = 'Create';
			announcement.AwardCeiling__c = announcements.get(programId);
			announcement.AwardFloor__c = 0;//budgetAmount;
			announcement.SetAsideAmount__c = budgetAmount;
			announcement.ObligatedAmount__c = budgetAmount;
			announcement.Organization__c = program.Account__C;
			announcement.FOAPublicationDate__c =  date.valueOf(DateTime.now().addDays(1)); //Foa Release date
			announcement.ApplicationDeadlineWithDateTime__c = program.ApplicationDeadline__c;// date.valueOf('2018-06-26'); //application deadline with date time.
			announcement.EstimatedProjectPeriodStartDate__c = program.StartDate__c ;
			announcement.EstimatedProjectPeriodEndDate__c = program.EndDate__C;// date.valueOf('2019-09-28');
			lstAnnouncements.add(announcement);
			programAnnouncements.put(programId, announcement);
		}

		List<Group> queueList = new List<Group>([SELECT Id, Name FROM Group WHERE Type = 'Queue']);
		Map<String, Group> queueAccountIdMap = new Map<String, Group>();
		for (Group g : queueList) {
			queueAccountIdMap.put(g.Name, g);
		}

		List<Application__c> lstNewAnnouncementApplications = getApplications(fb, programAnnouncements, applications, keyContacts, queueAccountIdMap);
		List<Application__c> lstNewApplications = getApplications(fb, existingProgramAnnouncements, onlyApplications, keyContacts, queueAccountIdMap);

		List<Application__C> results = new List<Application__C>();
		results.addall(lstNewAnnouncementApplications);
		results.addall(lstNewApplications);

		system.debug('new announcements' + programAnnouncements);
		system.debug('new announcement applications ' + lstNewAnnouncementApplications);
		system.debug('new applications ' + lstNewApplications);
		system.debug('merged applications ' + results);

		//uncomment following lines
		this.batchApplications = results;
		this.batchAnnouncements = lstAnnouncements;


	}


	List<Application__C> getApplications(FileBatch__C fb, Map<Id, Announcement__c> existingProgramAnnouncements, Map<string, decimal> applications, Map<Id, Id>
	                                     keyContacts, Map<String, Group> queueAccountIdMap ) {
		Id recordTypeId = Schema.SObjectType.Application__c.getRecordTypeInfosByName().get('Grantor').getRecordTypeId();
		List<Application__c> lstApplications = new List<Application__c>();
		for (string programAccountKey : applications.keySet()) {
			List<string> tempPairs = programAccountKey.split('_');
			Id programId = tempPairs[0];
			Id subRecipientId = tempPairs[1];
			Id keyContactId = keyContacts.get(subRecipientId);

			Announcement__c announcement;
			if (existingProgramAnnouncements.containsKey(programId)) {
				announcement = existingProgramAnnouncements.get(programId);
			}

			decimal awardAmount = applications.get(programAccountKey);
			if (awardAmount != 0) {
				Application__c tempApplication = new Application__c();
				lstApplications.add(tempApplication);
				if (announcement != null && announcement.Id != null) {
					tempApplication.Announcement__c = announcement.Id;
				}
				tempApplication.FederalProgram__c = announcement.Program__c;
				tempApplication.ExternalOrganization__c = subRecipientId;
				tempApplication.AwardCeiling__c = awardAmount.setScale(2);
				tempApplication.AwardFloor__c = awardAmount.setScale(2);
				tempApplication.BudgetAllocation__c = awardAmount.setScale(2);
				tempApplication.ProjectPeriodStartDate__c = announcement.EstimatedProjectPeriodStartDate__c;
				tempApplication.ProjectPeriodEndDate__c = announcement.EstimatedProjectPeriodEndDate__c;
				tempApplication.ApplicationDeadlineWithDateTime__c = announcement.ApplicationDeadlineWithDateTime__c;

				tempApplication.OwnerId = queueAccountIdMap.get('SubQueue' + subRecipientId).Id;
				tempApplication.RecordTypeId = recordTypeId;
				tempApplication.Title__C = announcement.AnnouncementName__c;
				tempApplication.FiscalYear__c = fb.FiscalYear__C;
				tempApplication.ProjectDirector__c = string.valueOf(keyContactId);
				tempApplication.ChangeOwnerAndCloseTask__c = 'No';
			}

		}
		return lstApplications;
	}


	Map<string, decimal> getStagingApplicationsMap(List<FedBudgetStage__C> items) {
		Map<string, decimal> result = new Map<string, decimal>();
		for (FedBudgetStage__C item : items) {
			string key = item.Program__c + '_' + item.SubRecipient__c;
			decimal budgetAmount = 0;
			if (result.containsKey(key)) {
				budgetAmount = result.get(key);
			}
			budgetAmount = budgetAmount + decimal.valueOf(item.BudgetAmount__c);
			result.put(key, budgetAmount);
		}
		return result;
	}



	FEDBudgetMain__c createMain(FedBudgetStage__C stage) {
		FEDBudgetMain__c main = new FEDBudgetMain__c();
		main.BudgetAmount__c = stage.BudgetAmount__c;
		main.LEAComment__c = stage.LEAComment__c;
		main.ObjectCode__c = stage.ObjectCode__c;
		main.OwnerId = stage.OwnerId;
		main.ProgramCode__c = stage.ProgramCode__c;
		main.Program__c = stage.Program__c;
		main.SubRecipient__c = stage.SubRecipient__c;
		main.FiscalYear__c = stage.FileBatch__R.FiscalYear__C;
		return main;
	}

	Map<string, decimal>  getStagingProgramMap(List<FEDBudgetStage__c> items) {
		Map<string, decimal> result = new Map<string, decimal>();
		for (FedBudgetStage__C item : items) {
			string key = item.Program__c;

			decimal budgetAmount = 0;
			if (result.containsKey(key)) {
				budgetAmount = result.get(key);
			}
			budgetAmount = budgetAmount + decimal.valueOf(item.BudgetAmount__c);
			result.put(key, budgetAmount);
		}
		return result;
	}

	Map<Id, Program__C> getPrograms(Set<string> programIds) {
		List<Program__C> programs = [SELECT Id, Account__C, ProgramName__c, StartDate__c, EndDate__C, ApplicationDeadline__c, Objectives__c  FROM Program__C WHERE id in : programIds];
		Map<Id, Program__C> historyMap = new Map<Id, Program__C>();
		for (Program__C p : programs) {
			historyMap.put(p.Id, p);
		}
		return historyMap;
	}

	void updateNonAwardApplications(Map<Id, decimal> preApplications, Set<Id> applicationsIds) {
		List<Application__c> dbApplications = [Select Id, AwardCeiling__c, AwardFloor__c, BudgetAllocation__c from Application__C where id in:applicationsIds];
		List<Application__C> results = new List<Application__C>();
		for (Application__c application : dbApplications) {
			//Doublecheck the applications passed and if the allocations actually changed
			if (application.BudgetAllocation__c != preApplications.get(application.Id)) {
				decimal amount = preApplications.get(application.Id);
				application.BudgetAllocation__c = amount;
				application.AwardCeiling__c = amount;
				application.AwardFloor__c = amount;
				application.Status__c = 'Created';
				results.add(application);
			}
		}
		system.debug('non award applications>>>' + results);
		if (results.size() > 0) {
			update results;
		}
	}

	Map<Id, Id> getKeyContacts(List<FEDBudgetStage__c> stageItems ) {
		Map<Id, Id> keyContacts = new Map<Id, Id>();
		for (FEDBudgetStage__c budget : stageItems ) {
			keyContacts.put(budget.SubRecipient__c, budget.KeyContactId__C);
		}
		return keyContacts;
	}

	Map<string, FedBudgetMain__C> getMapMainItems(List<FedBudgetMain__C> mainItems ) {
		Map<string, FedBudgetMain__C> results = new Map<string, FedBudgetMain__C>();
		if (mainItems == null || mainItems.size() == 0) {
			return results;
		}
		for (FedBudgetMain__C budget : mainItems ) {
			results.put(budget.UniqueKeyFormula__c, budget);
		}
		return results;
	}

	class BatchWrapper {
		public BatchWrapper(FEDBudgetMain__c  main, FEDBudgetStage__c stage) {
			this.stage = stage;
			this.main = main;
		}
		public FEDBudgetStage__c stage {get; set;}
		public FEDBudgetMain__c main {get; set;}
	}
}