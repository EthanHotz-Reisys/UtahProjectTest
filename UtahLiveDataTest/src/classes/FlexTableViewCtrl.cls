/**
*  Responsible to display any flex table using the request parameters found on the URL.
*
* CHANGE HISTORY
*=========================================================================
* Dated          Name                   Description 
* 03/31/2014     Shah Kadirmohideen     Created
* 
*=========================================================================
*/
public with sharing class FlexTableViewCtrl {
    public String flexTableName {get; set;}
    public String parameterMap {get; set;}
    public String parameterMap1 {get; set;}
    public String ft1 {get;set;}
    public String ft2 {get;set;}
    public String ft3 {get;set;}


    public FlexTableViewCtrl() {
        loadInputParams();
        ft1 = ApexPages.currentPage().getParameters().get('ft1');  
        ft2 = ApexPages.currentPage().getParameters().get('ft2'); 
        ft3 = ApexPages.currentPage().getParameters().get('ft3');      
    }

    /* PRIVATE METHODS */

    private void loadInputParams() {
        Map<String, String> keyValueMap = new Map<String, String>();
        for (String key : ApexPages.currentPage().getParameters().keySet()) {
            if (key == 'flexTableName') {
                this.flexTableName = ApexPages.currentPage().getParameters().get(key);
            }
            else if(key == 'ownerId') {
                keyValueMap.put(key, UserInfo.getUserId());
            }
            //fetching the phase ID and passing it on as a phaseConfigLayoutId
  
            else {
                keyValueMap.put(key, ApexPages.currentPage().getParameters().get(key));
            }
        }
        
        this.parameterMap = JSON.serialize(keyValueMap);
        Map<String,Object> flexTableMergeFieldsMap = new Map<String,Object>();
        flexTableMergeFieldsMap = keyValueMap;    
        this.parameterMap1 =  JSON.serialize(flexTableMergeFieldsMap);
       
    }
}