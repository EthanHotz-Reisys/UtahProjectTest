public with sharing class ProgramViewCtrl {
    
    //Properties
    public ID recordId{get;set;}
    public List<Program__c> ProgramList{get;set;}
    public String pageTemplateName {get;set;}
    public Boolean hideSideBar {get;set;}
    private id coreservicearea;
    public boolean isGuest {get; set;}
    public ProgramViewCtrl(ApexPages.StandardController stdController){ 
        recordId = ApexPages.CurrentPage().getParameters().get('id');  
        System.debug('recordId'+recordId);  
        String appName = GNT.UserPreferenceHelper.getStringValue('ActiveAppName__c');
        ProgramList = [select id,name,KeyPerformanceIndicator__c,recordtype.name,Account__c, Account__r.Name  from Program__c WHERE id=:recordId];
        System.debug('programlist'+ProgramList.size());
        If(ProgramList[0].KeyPerformanceIndicator__c!=null){
        coreservicearea = ProgramList[0].KeyPerformanceIndicator__c;
        }
        User u = [SELECT id,Name,IsExternalUser__c, UserType FROM User WHERE Id=:UserInfo.getUserId()];
        isGuest = u.UserType == 'Guest';
        hideSideBar = (u.UserType == 'Guest') ? true : false;
        //pageTemplateName = 'Grantee State Program';
        String recType = ProgramList[0].recordtype.name;
        if(ProgramList[0].Account__r.Name == 'USBE'){
            pageTemplateName = 'USBE Program';
        }else{
            if(recType == 'Internal Program'){
                pageTemplateName = 'Grantee State Program';
            }
            if(recType == 'NGO Program'){
                pageTemplateName = 'NGO Program';
            }
            if(recType == 'External Program'){
                pageTemplateName = 'Federal Program';
            }
            if(isGuest == true){
               pageTemplateName = 'ProgramExternalGrantor';
            }
        }
        //hideSideBar = UserInfo.getUserType() == 'Guest' ? true : false; 
    }
    
    public string getKeyValueMap(){
        List<Program__c> ProgramList = [select id,name,recordtype.name,Account__c, ReviewProcess__c  from Program__c WHERE id=:ApexPages.currentPage().getParameters().get('id')]; 
        Map<String,String> keyValueMap = new Map<String,String>();
        keyValueMap.put('programid',ApexPages.currentPage().getParameters().get('id'));
        System.debug(' The KEY VALUE ID is ' +ApexPages.currentPage().getParameters().get('id') ); 
        Id recTypeIdApp = Schema.SObjectType.ReviewStepTemplate__c.getRecordTypeInfosByName().get('Application').getRecordTypeId();
        keyValueMap.put('recTypeAppId',(String)recTypeIdApp);
        keyValueMap.put('UserId',UserInfo.getUserId());    
        keyValueMap.put('accountId',(Id)ProgramList[0].Account__c);  
        Id recTypeIdPreapp = Schema.SObjectType.ReviewStepTemplate__c.getRecordTypeInfosByName().get('Pre-Application').getRecordTypeId();
        keyValueMap.put('recTypePreAppId',(String)recTypeIdPreapp );      
        return JSON.serialize(keyValueMap);
    } 
    public string getChartParameters(){
        Map<String,String> keyValueMap = new Map<String,String>();
        keyValueMap.put('programid',ApexPages.currentPage().getParameters().get('id'));
        keyValueMap.put('coreservicearea',coreservicearea);
        return JSON.serialize(keyValueMap);
    }
    
    public void updateStatus(){
        EventHandlerCtrl ctrl = new EventHandlerCtrl();
        ctrl.updateStatus();
    }
}