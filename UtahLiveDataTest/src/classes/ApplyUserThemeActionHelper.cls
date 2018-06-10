global with sharing class ApplyUserThemeActionHelper extends GNT.FlexTableActionHandler{
Id recordId ;
String action;
	
 global override Map<String,Object> clickHandler(){	
 		system.debug('selectedRecordId:====>'+selectedRecordId+'selectedRecordIds:=====>'+selectedRecordIds);
		GNT__ThemeConfig__c theme = [Select Name from GNT__ThemeConfig__c where id IN:selectedRecordIds];
		GNT__UserPreferences__c pref = GNT__UserPreferences__c.getInstance(UserInfo.getUserId());
		pref.GNT__ThemeDocumentID__c = theme.Name;
		update pref;
		Map<String,Object> resultMap = new Map<String,Object>();
		resultMap.put('PageReference','/apex/MyProfileView?id='+UserInfo.getUserId());
		return resultMap;
	 }
	  

	
	 


}