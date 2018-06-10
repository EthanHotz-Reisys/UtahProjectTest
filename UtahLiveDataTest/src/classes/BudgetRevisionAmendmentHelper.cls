/**
* This class updates the AwardBudgetCategories through the BudgetRevision-
* AmendmentRequest
* @author - Sarat Mahavratayajula
*/
global with sharing class BudgetRevisionAmendmentHelper extends GNT.DynamicLayoutActionStay {
	private Id recordId;

	public BudgetRevisionAmendmentHelper() {
	}

	global override String whenClicked() {
		Savepoint sp = Database.setSavepoint();
		try {
			recordId = apexpages.currentpage().getparameters().get('id');
			AmendmentRequest__c amendmentRequest =
			    [select Id, Name, RecordTypeId, Award__c,
			     Award__r.Grant__r.Application__r.Announcement__c,
			     Award__r.Grant__r.Application__r.ExternalOrganization__r.Name,
			     Award__r.Grant__r.Program__c,BudgetRevisionCount__c
			     from AmendmentRequest__c
			     where Id = :recordId];

			amendmentRequest.BudgetRevisionCount__c = amendmentRequest.BudgetRevisionCount__c + 1;
			AmendmentRequestTriggerHelper.skipTrigger = false;
            update amendmentRequest;

			List<AmendmentRequestBudgetCategory__c> amendmentRequestBudgetCategories =
			    [select Id, Name, BudgetCategory__c, ServiceArea1__c,
			     GrantorAmount__c, GranteeAmount__c, Amount__c
			     from AmendmentRequestBudgetCategory__c
			     where AmendmentRequest__c = :recordId];

			List<AwardBudgetCategory__c> awardBudgetCategories = [select Id, Name, BudgetCategory__c, ServiceArea__c,
			                             GrantorAmount__c, GranteeAmount__c, Amount__c
			                             from AwardBudgetCategory__c
			                             where Award__c = :amendmentRequest.Award__c];

			List<BuildUpItem__c> buildUpItems = [select Id, Name, AwardBudgetCategory__c, AmendmentRequestBudgetCategory__c,
			                                     Title__c, Narrative__c, StartDate__c, EndDate__c, UnitPrice__c, Quantity__c,
			                                     UnitofMeasurement__c, OtherCharges__c, AllowableDirect__c, Indirect__c,
			                                     GrantorShare__c
			                                     from BuildUpItem__c
			                                     where (AwardBudgetCategory__c IN :awardBudgetCategories) or
			                                     (AmendmentRequestBudgetCategory__c IN :amendmentRequestBudgetCategories)];

			String keyValueMap = getKeyValueMap(amendmentRequest);
			GNT.SnapshotUtils.createSnapshot(amendmentRequest.Award__c,
			                                 'Awards',
			                                 keyValueMap, keyValueMap, amendmentRequest.Award__c);

			updateAwardBudgetCategories(amendmentRequestBudgetCategories,
			                            awardBudgetCategories, buildUpItems);

			//TODO: Redirect to Award View
			PageReference p = Page.AmendmentRequestView;
			p.getParameters().put('id', recordId);
			p.setRedirect(true);
			return 'Budget Revision - Award Budget Categories successful - Test';
		} catch (Exception ex) {
			Database.rollback(sp);
			ApexPages.addMessages(ex);
			return null;
		}
	}
	public string getKeyValueMap(AmendmentRequest__c amendmentRequest) {

		// Find out about these. Logic is not right in AwardViewCtrl
		/*keyValueMap.put('paymentTermConditionId',paymentTermConditionId);
		keyValueMap.put('progressTermConditionId',progressTermConditionId);
		keyValueMap.put('siteTermConditionId',siteTermConditionId);*/

		Map<String, String> keyValueMap = new Map<String, String>();
		keyValueMap.put('awardId', amendmentRequest.Award__c);
		keyValueMap.put('parentid', amendmentRequest.Award__c);
		keyValueMap.put('announcementId', amendmentRequest.Award__r.Grant__r.Application__r.Announcement__c);
		keyValueMap.put('organizationName', amendmentRequest.Award__r.Grant__r.Application__r.ExternalOrganization__r.Name);
		keyValueMap.put('programId', amendmentRequest.Award__r.Grant__r.Program__c);
		return JSON.serialize(keyValueMap);
	}

	public void updateAwardBudgetCategories(List<AmendmentRequestBudgetCategory__c> amendmentRequestBudgetCategories,
	                                        List<AwardBudgetCategory__c> awardBudgetCategories,
	                                        List<BuildUpItem__c> buildUpItems) {
		system.debug('Record Id --> ' + recordId);

		if (buildUpItems.size() < 0) {
			for (AmendmentRequestBudgetCategory__c amendmentRequestBudgetCategory : amendmentRequestBudgetCategories) {
				for (AwardBudgetCategory__c awardBudgetCategory : awardBudgetCategories) {
					if (amendmentRequestBudgetCategory.BudgetCategory__c.equals(awardBudgetCategory.BudgetCategory__c) &&
					        amendmentRequestBudgetCategory.ServiceArea1__c.equals(awardBudgetCategory.ServiceArea__c)) {
						awardBudgetCategory.GrantorAmount__c = amendmentRequestBudgetCategory.GrantorAmount__c;
						awardBudgetCategory.GranteeAmount__c = amendmentRequestBudgetCategory.GranteeAmount__c;
						awardBudgetCategory.Amount__c = amendmentRequestBudgetCategory.Amount__c;
					}
				}
			}
			update awardBudgetCategories;
			system.debug('New Award budget Categories -->' + awardBudgetCategories);
		}		

		Map<Id, List<BuildUpItem__c>> amendmentBuildUpItemsMap = new Map<Id, List<BuildUpItem__c>>();
		List<BuildUpItem__c> awardBuildUpItemsList = new List<BuildUpItem__c>();

		for (BuildUpItem__c buildUpItem : buildUpItems) {
			if (buildupItem.AwardBudgetCategory__c != null ) {
				awardBuildUpItemsList.add(buildupItem);
			}
			if (!amendmentBuildUpItemsMap.containsKey(buildUpItem.AmendmentRequestBudgetCategory__c)) {
				amendmentBuildUpItemsMap.put(buildUpItem.AmendmentRequestBudgetCategory__c, new List<BuildUpItem__c>());
			}
			amendmentBuildUpItemsMap.get(buildUpItem.AmendmentRequestBudgetCategory__c).add(buildUpItem);
		}

		if (amendmentBuildUpItemsMap.size() > 0) {
			delete awardBuildUpItemsList;

			List<BuildUpItem__c> novelAwardBuildUpItemsList = new List<BuildUpItem__c>();

			for (AmendmentRequestBudgetCategory__c amendmentRequestBudgetCategory : amendmentRequestBudgetCategories) {
				for (AwardBudgetCategory__c awardBudgetCategory : awardBudgetCategories) {
					if (amendmentRequestBudgetCategory.BudgetCategory__c.equals(awardBudgetCategory.BudgetCategory__c) &&
					        amendmentRequestBudgetCategory.ServiceArea1__c.equals(awardBudgetCategory.ServiceArea__c)) {
						system.debug('*** Map values -->' + amendmentBuildUpItemsMap.get(amendmentRequestBudgetCategory.Id));
						List<BuildUpItem__c> amendmentBuildUpItems = new List<BuildUpItem__c>();
						if (amendmentBuildUpItemsMap.containsKey(amendmentRequestBudgetCategory.Id)) {
							amendmentBuildUpItems = amendmentBuildUpItemsMap.get(amendmentRequestBudgetCategory.Id);
						}
						for (BuildUpItem__c amendmentBuildUpItem : amendmentBuildUpItems) {
							BuildUpItem__c buildupItem = new BuildUpItem__c();
							buildupItem.Title__c = amendmentBuildUpItem.Title__c;
							buildupItem.Narrative__c = amendmentBuildUpItem.Narrative__c;
							buildupItem.StartDate__c = amendmentBuildUpItem.StartDate__c;
							buildupItem.EndDate__c = amendmentBuildUpItem.EndDate__c;
							buildupItem.UnitPrice__c = amendmentBuildUpItem.UnitPrice__c;
							buildupItem.Quantity__c = amendmentBuildUpItem.Quantity__c;
							buildupItem.UnitofMeasurement__c = amendmentBuildUpItem.UnitofMeasurement__c;
							buildupItem.OtherCharges__c = amendmentBuildUpItem.OtherCharges__c;
							buildupItem.AllowableDirect__c = amendmentBuildUpItem.AllowableDirect__c;
							buildupItem.Indirect__c = amendmentBuildUpItem.Indirect__c;
							buildupItem.GrantorShare__c = amendmentBuildUpItem.GrantorShare__c;
							buildupItem.AwardBudgetCategory__c = awardBudgetCategory.Id;

							novelAwardBuildUpItemsList.add(buildupItem);
						}
					}
				}
			}
			insert novelAwardBuildUpItemsList;
			system.debug('Award Build Up Items --> ' + novelAwardBuildUpItemsList);
		}
	}
}