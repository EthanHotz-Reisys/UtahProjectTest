global with sharing class ResetUserThemeActionHelper extends GNT.FlexTableActionHandler{
Id recordId ;
String action;
    
 global override Map<String,Object> clickHandler(){ 
        GNT__UserPreferences__c pref = GNT__UserPreferences__c.getInstance(UserInfo.getUserId());
        pref.GNT__ThemeDocumentID__c = '';
        update pref;
        Map<String,Object> resultMap = new Map<String,Object>();
        resultMap.put('PageReference','/apex/MyProfileView?id='+UserInfo.getUserId());
        return resultMap;
     }
      

    
     


}