global with sharing class MSPAwardTriggerHelper extends GNT.TriggerHelper{
	public override void processAfterInsert(){
		updateOtherAwardsStatus((List<Award__c>)Trigger.new);
	}

	public override void processAfterUpdate(){
		updateOtherAwardsStatus((List<Award__c>)Trigger.new);
		updateAwardFinetCodeStatus((List<Award__c>)Trigger.new);
	}

    private void updateOtherAwardsStatus(List<Award__c> awards){
        List<Award__c> activeAwardList = new List<Award__c>();
        List<Id> grantIdList = new List<Id>();
        for(Award__c award : awards){
            if(award.Status__c == 'Activated'){
                activeAwardList.add(award);
                grantIdList.add(award.Grant__c);
            }
        }

        List<Award__c> amendedAwardList = new List<Award__c>([SELECT Id, Status__c FROM Award__c WHERE Grant__c IN :grantIdList AND Id NOT IN :activeAwardList AND Status__c = 'Activated']);
        for(Award__c awd : amendedAwardList){
            awd.Status__c = 'Amended';
        }

        update amendedAwardList;
    }   
    private void updateAwardFinetCodeStatus(List<Award__c> awards){
        List<AwardFINETCode__c> afcs = [SELECT Id, Award__r.Status__c, AwardStatus__c FROM AwardFINETCode__c WHERE Award__c IN :awards];
        for(AwardFINETCode__c afc : afcs){
            afc.AwardStatus__c = afc.Award__r.Status__c;
        }
        update afcs;
    }
}