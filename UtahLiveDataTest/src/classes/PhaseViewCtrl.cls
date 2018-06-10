public with sharing class PhaseViewCtrl extends GNT.ParentController {
    public transient String currentTabName {get; set;}
    public transient GNT__PhaseConfig__c phaseConfig {get; set;}
    public transient String flexTableName {get; set;}
    public transient String previousTabName {get; set;}
    public PageReference bodyPageIncludeTop {get; set;}
    public PageReference bodyPageIncludeBottom {get; set;}
    Id orgId;
    public PhaseViewCtrl() {
        GNT.AppUtils.setTabCookie();  
        previousTabName = GNT.AppUtils.getSelectedTabName();
        //User userObj = [Select Contact.AccountId From User where Id =:UserInfo.getUserId()];
        //orgId = [Select id from Account where Id =: userObj.Contact.AccountId].Id;
        loadPhaseConfig();
    }

    public Boolean getDisplayFlexTable() {
        
        if(phaseConfig!=null){
            return phaseConfig.GNT__BodyTable__c != null && !getDisplaySearchResult();
        }else{
            return true;
        }
    }

    /* PRIVATE METHODS */
    //Loads the current phase configuration
    private void loadPhaseConfig() {
        currentTabName = ApexPages.currentPage().getCookies().get('govgrants_tabname').getValue();
        System.debug('Current page cookies --->>>'+ApexPages.currentPage().getCookies().get('govgrants_tabname'));
        System.debug('The currentTabName is '+currentTabName);         
        if(!String.isEmpty(currentTabName)){
            this.phaseConfig = [Select Id, Name, GNT__TabName__c, GNT__BodyTable__c, GNT__BodyTable__r.Name, GNT__BodyBottomPageURL__c,
                                GNT__BodyPageIncludeURL__c,GNT__FlexTableParameters__c
                                from GNT__PhaseConfig__c where Name=:currentTabName];
        }
                    
        //Set body page include         
        if(this.phaseConfig != null){
            this.flexTableName = phaseConfig.GNT__BodyTable__r.Name; 
            this.bodyPageIncludeTop = Page.BlankPage; 
            this.bodyPageIncludeBottom = Page.BlankPage;
            
            if (String.isEmpty(phaseConfig.GNT__BodyPageIncludeURL__c) || getDisplaySearchResult()) {
                this.bodyPageIncludeTop = Page.BlankPage;  
            }       
            else {
                this.bodyPageIncludeTop = new PageReference(phaseConfig.GNT__BodyPageIncludeURL__c);            
            }
            
            if (String.isEmpty(phaseConfig.GNT__BodyBottomPageURL__c) || getDisplaySearchResult()) {
                this.bodyPageIncludeBottom = Page.BlankPage;  
            }       
            else {
                this.bodyPageIncludeBottom = new PageReference(phaseConfig.GNT__BodyBottomPageURL__c);            
            }    
        }
    }
    
    public String getKeyValueMap(){
        Map<String,String> keyValueMap = new Map<String,String>();
        if(this.phaseConfig.GNT__FlexTableParameters__c != null){
            string[] params = this.phaseConfig.GNT__FlexTableParameters__c.split(',');
            for(string s : params){
                string[] keyValue = s.split('=');
                keyValueMap.put(keyValue[0], keyValue[1]);
            }
        }
       // keyValueMap.put('orgId', orgId);
        return JSON.serialize(keyValueMap);        
    }
    public String getKeyValueMap1(){
        Map<String,String> keyValueMap = new Map<String,String>();
        if(this.phaseConfig.GNT__FlexTableParameters__c != null){
            string[] params = this.phaseConfig.GNT__FlexTableParameters__c.split(',');
            for(string s : params){
                string[] keyValue = s.split('=');
                keyValueMap.put(keyValue[0], keyValue[1]);
            }
        }  
         keyValueMap.put('orgId', '00D36000000JiirEAC'); 
        //keyValueMap.put('orgId', '00136000004zyd9AAA');     
        Map<String,Object> flexTableMergeFieldsMap = new Map<String,Object>();
        flexTableMergeFieldsMap = keyValueMap;        
        return JSON.serialize(flexTableMergeFieldsMap); 
    }
}