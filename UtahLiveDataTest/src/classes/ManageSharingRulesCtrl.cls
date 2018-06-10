public with sharing class ManageSharingRulesCtrl {
    public Boolean isBizShareConfigured{
        get{       
            List<GNT__BusinessShareConfig__c> bizShareConfigList = GNT__BusinessShareConfig__c.getAll().values();
            return bizShareConfigList.size() > 0 ?  true : false;
        }set;
    }
    public PageReference recalculateShare(){
        Id batchInstanceId = Database.executeBatch(new ShareRecalculatorBatch(null,null,true,0));
        return null;
    }
    public Boolean isRecalculationInProgress{
        get{       
            ApexClass shareRecalculatorClass = [SELECT Id FROM ApexClass WHERE Name = 'ShareRecalculatorBatch'];
            List<AsyncApexJob> jobs = [SELECT Id FROM AsyncApexJob WHERE ApexClassId =:shareRecalculatorClass.Id 
                                        AND Status IN('Queued','Processing','Preparing','Holding') ];
            return jobs.size() > 0 ?  true : false;
        }set;
    }
}