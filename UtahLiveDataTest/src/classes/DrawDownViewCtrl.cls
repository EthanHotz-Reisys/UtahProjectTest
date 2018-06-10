/**
* This class is used for drawdown view 
* @author: Sarat Maahavratayajula
*/
public with sharing class DrawDownViewCtrl {

    public ID recordId {get;set;}
    public PageReference savePage {get;set;}
    public PageReference cancelPage {get;set;}
    public  string pageTemplateName {get;set;}
    public List <GNT.DynamicLayoutDefaultValueHelper> listDefaultValues {get;set;}
    public Drawdown__c draw {get;set;}
    public String packageId {get;set;}

    public DrawDownViewCtrl(ApexPages.StandardController standardController) {
        recordId = ApexPages.CurrentPage().getParameters().get('id');
        String appName = GNT.UserPreferenceHelper.getStringValue('ActiveAppName__c');
         
        draw= [select id,Name,Grant__c from Drawdown__c where id=:recordId];     
        System.debug('draw:'+draw);  
        //Grant__c grantObj= [SELECT Id, (select PackageConfig__r.Name from Business_Packages__r where PackageType__c='Payment Request' AND PackageConfig__r.GNT__PrimarySobjectName__c='Drawdown__c') FROM Grant__c WHERE id=:draw.Grant__c LIMIT 1];   
         
        //System.debug('GrantObject ---->'+grantObj);
        //packageId = grantObj.Business_Packages__r[0].PackageConfig__c; 
        //System.debug('Package Id --->'+packageId);
        pageTemplateName = 'Draw Down';
         
    }
    public string getKeyValueMap(){
        Map<String,String> keyValueMap = new Map<String,String>();
        keyValueMap.put('drawId',ApexPages.currentPage().getParameters().get('id'));
        return JSON.serialize(keyValueMap);
    }
}