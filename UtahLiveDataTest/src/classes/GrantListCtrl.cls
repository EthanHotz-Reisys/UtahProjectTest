public with sharing class GrantListCtrl {
    public String currentAccount{get;set;}  
    public Boolean isExtUSBE {get;set;} 
    Integer currentFiscalYear;
    
    public GrantListCtrl() {
        Integer currentYear = System.today().year();
        Date fiscalYearStartDate = Date.newInstance(currentYear, 7, 1);
        if(System.today() >= fiscalYearStartDate){
            currentFiscalYear = currentYear + 1;
        }else{
            currentFiscalYear = currentYear;
        }
        String currentUserId = UserInfo.getUserId();
        User currentUser = [SELECT Id, AccountNameFormulaField__c, Contact.Account.HideIfLEA__c FROM User WHERE Id = :currentUserId];
        currentAccount = currentUser.AccountNameFormulaField__c;
        isExtUSBE = currentUser.Contact.Account.HideIfLEA__c;
        System.debug('DeviTest currentAcc********************************: ' + currentAccount);
        System.debug('DeviTest isExtUSBE ********************************: ' + isExtUSBE);
    }

    public string getKeyValueMap(){
        Map<String,String> keyValueMap = new Map<String,String>();
        keyValueMap.put('currentFiscalYear', String.valueOf(currentFiscalYear));
        keyValueMap.put('lastFiscalYear', String.valueOf(currentFiscalYear - 1));
        keyValueMap.put('beforeLastFiscalYear', String.valueOf(currentFiscalYear - 2));
        return JSON.serialize(keyValueMap);
    }
}