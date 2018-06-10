global class BatchController {

    public String flexGridName {get; set;}
    public String recordId {get; set;}
    public String packageId {get; set;}
    public String currentAccount {get; set;}
    public String tab_MSP {get{return UTConstants.FILE_BATCH_MSP;}}
    public String tab_FedFormula {get{return UTConstants.FILE_BATCH_FED_FORMULA;}}
    public String tab_StateFormula {get{return UTConstants.FILE_BATCH_STATE_FORMULA;}}
    public String tab_APP12 {get{return UTConstants.FILE_BATCH_APP12;}}
    public String tab_LSA {get{return UTConstants.FILE_BATCH_LSA;}}
    public String tab_LSNA {get{return UTConstants.FILE_BATCH_LSNA;}}
    public String tab_FedCompete {get{return UTConstants.FILE_BATCH_FED_COMPETE;}}
    public String tab_StateCompete {get{return UTConstants.FILE_BATCH_STATE_COMPETE;}}

    public BatchController(ApexPages.StandardController stdController) {
        flexGridName = 'POC_FinancialBatchGrid';
        String currentUserId = UserInfo.getUserId();
        User currentUser = [SELECT Id, AccountNameFormulaField__c FROM User WHERE Id = :currentUserId];
        currentAccount = currentUser.AccountNameFormulaField__c;
    }

    public BatchController() {
        flexGridName = 'POC_FinancialBatchGrid';
        String currentUserId = UserInfo.getUserId();
        User currentUser = [SELECT Id, AccountNameFormulaField__c FROM User WHERE Id = :currentUserId];
        currentAccount = currentUser.AccountNameFormulaField__c;
    }

    public String getKeyValueMap() {
        Map<String, String> keyValueMap = new Map<String, String>();
        keyValueMap.put('account', currentAccount);
        keyValueMap.put('batchTypeLongName', 'abc');
        return JSON.serialize(keyValueMap);
    }

    public String getKeyValueMap_MSP() {
        return getKeySettings(tab_MSP);
    }

    public String getKeyValueMap_FedFormula() {
        return getKeySettings(tab_FedFormula);
    }

    public String getKeyValueMap_StateFormula() {
        return getKeySettings(tab_StateFormula);
    }

    public String getKeyValueMap_LSNA() {
        return getKeySettings(tab_LSNA);
    }

    public String getKeyValueMap_LSA() {
        return getKeySettings(tab_LSA);
    }

    public String getKeyValueMap_APP12() {
        return getKeySettings(tab_APP12);
    }

    public String getKeyValueMap_FedCompete() {
        return getKeySettings(tab_FedCompete);
    }

    public String getKeyValueMap_StateCompete() {
        return getKeySettings(tab_StateCompete);
    }



    private String getKeySettings(String value) {
        Map<String, String> keyValueMap = new Map<String, String>();
        keyValueMap.put('batchType', value);
        keyValueMap.put('batchTypeLongName', UTConstants.FILE_BATCH_FULL_NAMES.get(value));
        system.debug(keyValueMap);
        return JSON.serialize(keyValueMap);
    }

    @RemoteAction
    global static List<Program__c> getData(String programPathWay) {
        List<Program__c> fb = [SELECT Name, Phone__c, ProgramCode__c FROM Program__c WHERE ProgramPathway__c = :programPathWay];

        return fb;
    }

    public PageReference redirectToParentPage() {
        PageReference redirectPage = new PageReference('https://www.cicis.com/media/1176/pizza_trad_pepperonibeef.png');
        redirectPage.setRedirect(true);
        return redirectPage;
    }

}