global with sharing class FINETProgramActiveHelper extends GNT.DynamicLayoutActionRedirect{
	global override PageReference whenClicked(){
		Savepoint sp = Database.setSavePoint();
		try{
			String recordId = ApexPages.CurrentPage().getParameters().get('id');
			r_prog__c finetProgram = [SELECT Id, Status__c, PROG_NM__c, FINETMajorProgram__c, AREA__c, FederalOldKey__c, StateOldKey__c FROM r_prog__c WHERE Id = :recordId];
			finetProgram.Status__c = 'Active';
			
			List<AwardFINETCode__c> afcList = new List<AwardFINETCode__c>([SELECT Id, Award__c, Award__r.Grant__r.Program__r.FunderType__c FROM AwardFINETCode__c WHERE ProgramCode__c = :finetProgram.Id AND Award__r.Status__c = 'Activated']);
			List<Id> awardIdList = new List<Id>();
			List<AwardFINETCode__c> federalAfcList = new List<AwardFINETCode__c>();
			List<AwardFINETCode__c> stateAfcList = new List<AwardFINETCode__c>();
			for(AwardFINETCode__c afc : afcList){
				awardIdList.add(afc.Award__c);
				if(afc.Award__r.Grant__r.Program__r.FunderType__c == 'Federal'){
					federalAfcList.add(afc);
				}else if(afc.Award__r.Grant__r.Program__r.FunderType__c == 'State'){
					stateAfcList.add(afc);
				}
			}

			List<Award__c> awardList = new List<Award__c>([SELECT Id, Name, Status__c, Grant__r.Program__r.AwardLetterRequired__c, Grant__r.Program__r.FunderType__c, Grant__r.InternalOrganization__c FROM Award__c WHERE Id IN :awardIdList AND Status__c = 'Activated']);
			List<Award__c> federalAwardList = new List<Award__c>();
			List<Award__c> stateAwardList = new List<Award__c>();
			for(Award__c award : awardList){
				if(award.Grant__r.Program__r.FunderType__c == 'Federal'){
					federalAwardList.add(award);
				}else if(award.Grant__r.Program__r.FunderType__c == 'State'){
					stateAwardList.add(award);
				}
			}

			Boolean isFedralKeyChange = (finetProgram.PROG_NM__c + finetProgram.AREA__c + finetProgram.FINETMajorProgram__c) == finetProgram.FederalOldKey__c ? false : true;
			Boolean isStateKeyChange = (finetProgram.PROG_NM__c + finetProgram.FINETMajorProgram__c) == finetProgram.StateOldKey__c ? false : true;

			if(isFedralKeyChange || isStateKeyChange){
				finetProgram.FederalOldKey__c = finetProgram.PROG_NM__c + finetProgram.AREA__c + finetProgram.FINETMajorProgram__c;
				finetProgram.StateOldKey__c = finetProgram.PROG_NM__c + finetProgram.FINETMajorProgram__c;
				update finetProgram;
				if(isFedralKeyChange){
					ActiveUSBEAwardHelper.sendAwardLetter((new Map<Id, AwardFINETCode__c>(federalAfcList)).keySet());
					CloneAwardHelper.deepCloneAwardList((new Map<Id, Award__c>(federalAwardList)).keySet(), 'Activated');
				}

				if(isStateKeyChange){
					ActiveUSBEAwardHelper.sendAwardLetter((new Map<Id, AwardFINETCode__c>(stateAfcList)).keySet());
					CloneAwardHelper.deepCloneAwardList((new Map<Id, Award__c>(stateAwardList)).keySet(), 'Activated');					
				}
			}

			/*
			if((finetProgram.PROG_NM__c + finetProgram.AREA__c + finetProgram.FINETMajorProgram__c) != finetProgram.FederalOldKey__c) {
				finetProgram.FederalOldKey__c = finetProgram.PROG_NM__c + finetProgram.AREA__c + finetProgram.FINETMajorProgram__c;
				finetProgram.IsAwardLetterSent__c = true;
				update finetProgram;
				ActiveUSBEAwardHelper.sendAwardLetter((new Map<Id, AwardFINETCode__c>(federalAfcList)).keySet());
				CloneAwardHelper.deepCloneAwardList((new Map<Id, Award__c>(federalAwardList)).keySet(), 'Active');
			}

			if((finetProgram.PROG_NM__c + finetProgram.FINETMajorProgram__c) != finetProgram.StateOldKey__c){
				finetProgram.StateOldKey__c = finetProgram.PROG_NM__c + finetProgram.FINETMajorProgram__c; 
				finetProgram.IsAwardLetterSent__c = true;
				update finetProgram;
				ActiveUSBEAwardHelper.sendAwardLetter((new Map<Id, AwardFINETCode__c>(stateAfcList)).keySet());
				CloneAwardHelper.deepCloneAwardList((new Map<Id, Award__c>(stateAwardList)).keySet(), 'Active');
			}
			*/

			PageReference pf = Page.FINETProgramView;
			pf.setRedirect(true);
			pf.getParameters().put('id', recordId);
			return pf;
		}catch(Exception e){
			Database.rollback(sp);
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, e.getMessage()));
			return null;
		}
	}
}