public with sharing class POC_FinancialCtrl {
    
	public String recordId{get;set;}
	public String packageId{get;set;}
	public PageReference deleteURL{get;set;}
	public String stageJSON{get;set;}
    public String fbStatus{get;set;}
    public String mainJSON{get;set;}

    public POC_FinancialCtrl(ApexPages.StandardController stdController) {
        recordId = ApexPages.CurrentPage().getParameters().get('id');
        packageId = null;
        deleteURL = null;
        POC_FinancialBatch__c fb = [SELECT Id, Status__c, FiscalYear__c FROM POC_FinancialBatch__c WHERE Id = :recordId];
        fbStatus = fb.Status__c;
        List<POC_FinancialMain__c> fms = [SELECT Program__r.ProgramName__c, SubRecipient__r.Name, AwardAmount__c, UniqueKeyFormula__c FROM POC_FinancialMain__c WHERE FiscalYear__c =:fb.FiscalYear__c ORDER BY SubRecipient__r.LEA_Id__c, Program__r.Name];
        List<POC_Financial__c> fs = [SELECT Program__r.ProgramName__c, SubRecipient__r.Name, AwardAmount__c, UniqueKeyFormula__c FROM POC_Financial__c WHERE POC_FinancialBatch__c =:recordId ORDER BY SubRecipient__r.LEA_Id__c, Program__r.Name];
        
        //mainJSON = JSON.serialize(fms);
        //if(fbStatus == 'Approved'){    
        //    stageJSON = JSON.serialize(fms);
        //}else{
        //    stageJSON = JSON.serialize(fs);
        //}

        List<AwardWrapper> stageWrapper = new List<AwardWrapper>();
        for(POC_Financial__c f : fs){
            AwardWrapper temp = new AwardWrapper();
            temp.programName = f.Program__r.ProgramName__c;
            temp.subRecipientName = f.SubRecipient__r.Name;
            temp.awardAmount = f.AwardAmount__c;
            temp.uniqueKeyFormula = f.UniqueKeyFormula__c;
            stageWrapper.add(temp);
        }
        List<AwardWrapper> mainWrapper = new List<AwardWrapper>();
        for(POC_FinancialMain__c fm : fms){
            AwardWrapper temp = new AwardWrapper();
            temp.programName = fm.Program__r.ProgramName__c;
            temp.subRecipientName = fm.SubRecipient__r.Name;
            temp.awardAmount = fm.AwardAmount__c;
            temp.uniqueKeyFormula = fm.UniqueKeyFormula__c;
            mainWrapper.add(temp);
        }
        mainJSON = JSON.serialize(mainWrapper);
        if(fbStatus == 'Approved'){    
            stageJSON = JSON.serialize(mainWrapper);
        }else{
            stageJSON = JSON.serialize(stageWrapper);
        }

    } 

    public String getKeyValueMap(){
        Map<String,String> keyValueMap = new Map<String,String>();
        keyValueMap.put('batchId', recordId);
        return JSON.serialize(keyValueMap);
    }
    
    public String getListParameters(){
	    Map<String,Set<String>> listParams = new Map<String,Set<String>>();
	    return JSON.serialize(listParams);
    }

    public PageReference approve(){
    	POC_FinancialBatch__c pf = [SELECT FiscalYear__c, Type__c, Status__c FROM POC_FinancialBatch__c WHERE Id = :recordId];
        Savepoint sp = Database.setSavepoint();
		try{
            if(pf.Type__c == 'Create'){
                List<POC_FinancialBatch__c> fbsSameYear = [SELECT Status__c FROM POC_FinancialBatch__c WHERE FiscalYear__c = :pf.FiscalYear__c AND Id != :pf.Id];
                Boolean flag = false;
                
                for(POC_FinancialBatch__c fb : fbsSameYear ){
                    if(fb.Status__c == 'Approved'){
                        flag = true;
                    }
                }

                if(flag){
                     ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'One create batch already approved for this year'));
                     return null;
                }else{
                    List<POC_Financial__c> fs = [SELECT Id, Program__c, SubRecipient__c, AwardAmount__c, POC_FinancialBatch__r.FiscalYear__c, POC_FinancialBatch__r.EffectiveMonth__c FROM POC_Financial__c WHERE POC_FinancialBatch__c = :recordId];
                    List<POC_FinancialMain__c> fms = new List<POC_FinancialMain__c>();
                    for(POC_Financial__c f : fs){
                        POC_FinancialMain__c temp = new POC_FinancialMain__c(
                            Program__c = f.Program__c,
                            SubRecipient__c = f.SubRecipient__c,
                            AwardAmount__c = f.AwardAmount__c,
                            FiscalYear__c = f.POC_FinancialBatch__r.FiscalYear__c,
                            EffectiveMonth__c = f.POC_FinancialBatch__r.EffectiveMonth__c
                        );
                        fms.add(temp);
                    }
                    if(fms.size() > 0){
                        insert fms;
                    }
                    pf.Status__c = 'Approved';
                }
            }else if(pf.Type__c == 'Amend'){
                List<POC_Financial__c> fs = [SELECT Id, Program__c, SubRecipient__c, AwardAmount__c, POC_FinancialBatch__c, UniqueKeyFormula__c FROM POC_Financial__c WHERE POC_FinancialBatch__c = :recordId];
                Map<String, POC_Financial__c> stageMap = new Map<String, POC_Financial__c>();
                for(POC_Financial__c f : fs){
                    stageMap.put(f.UniqueKeyFormula__c, f);
                }
                List<POC_FinancialMain__c> fms = [SELECT Id, AwardAmount__c, UniqueKeyFormula__c FROM POC_FinancialMain__c WHERE UniqueKeyFormula__c IN :stageMap.keySet()];
                List<POC_FinancialMain__c> updatefms = new List<POC_FinancialMain__c>();
                for(POC_FinancialMain__c fm : fms){
                    POC_Financial__c f = stageMap.get(fm.UniqueKeyFormula__c);
                    if(fm.AwardAmount__c != f.AwardAmount__c){
                        fm.AwardAmount__c = f.AwardAmount__c;
                        updatefms.add(fm);
                    }
                }

                if(updatefms.size() > 0){
                    update updatefms;
                }
                pf.Status__c = 'Approved';
            }
            update pf;
    		PageReference pageref = Page.PhaseView;
            pageref.getParameters().put('t','GrantorPlanning');
            pageref.setRedirect(true);
            return pageref;
        }catch(Exception e){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,e.getMessage()));
            Database.rollback(sp);
            return null;
        }
    }
    public PageReference reject(){
    	POC_FinancialBatch__c pf = [SELECT Status__c FROM POC_FinancialBatch__c WHERE Id = :recordId];
		pf.Status__c = 'Rejected';
		update pf;
		PageReference pageref = Page.PhaseView;
        pageref.getParameters().put('t','GrantorPlanning');
        pageref.setRedirect(true);
        return pageref;
	}

    public PageReference cancel(){
        PageReference pageref = Page.PhaseView;
        pageref.getParameters().put('t','GrantorPlanning');
        pageref.setRedirect(true);
        return pageref;
    }

    class AwardWrapper{
        public String programName{get;set;}
        public String subRecipientName{get;set;}
        public String awardAmount{get;set;}
        public String uniqueKeyFormula{get;set;}
    }

}