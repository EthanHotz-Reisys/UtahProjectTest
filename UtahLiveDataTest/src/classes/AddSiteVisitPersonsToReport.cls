global with sharing class AddSiteVisitPersonsToReport extends GNT.FlexTableActionHandler {
    
    global override Map<String,Object> clickHandler(){
        Map<String,Object> resultMap = new Map<String,Object>();
        String ns = AppUtils.getNamespacePrefix(); 
        Id siteVisitId  = urlParams.get('id');
        String tabName = urlParams.get('tabName');
        String userType = urlParams.get('userType');        
        system.debug('--Inside AddSiteVisitPersonsToReport--selectedRecordIds--'+selectedRecordIds);
        //ReviewPanel__c reviewPanel = [SELECT Id, Name,ReviewStep__c FROM ReviewPanel__c WHERE Id=:panelId];
        List<SiteVisitPerson__c> siteVisitUserList = new List<SiteVisitPerson__c>();
        if(userType != null && userType != 'Contact') {
            Map<Id,User> users = new Map<Id,User>([select id, FirstName,LastName,Email,Phone,Title From User where id in : selectedRecordIds]);
            for(String selectedId:selectedRecordIds){
                SiteVisitPerson__c siteVisitUser = new SiteVisitPerson__c();
                siteVisitUser.User__c = selectedId;
                siteVisitUser.SiteVisit__c = siteVisitId;
                siteVisitUser.UserType__c = userType;
                siteVisitUser.FirstName__c = users.get(selectedId).FirstName;
                siteVisitUser.LastName__c = users.get(selectedId).LastName;
                siteVisitUser.Title__c = users.get(selectedId).Title;
                siteVisitUser.Telephone__c = users.get(selectedId).Phone;
                siteVisitUser.Email__c = users.get(selectedId).Email;
                siteVisitUserList.add(siteVisitUser);
            }      
        }
        else if(userType != null && userType == 'Contact') {
            Map<Id,Contact> contacts = new Map<Id,Contact>([select id, FirstName,LastName,Email,Phone,Title From Contact where id in : selectedRecordIds]);
            for(String selectedId:selectedRecordIds){
                SiteVisitPerson__c siteVisitUser = new SiteVisitPerson__c();
                siteVisitUser.Contact__c = selectedId;
                siteVisitUser.SiteVisit__c = siteVisitId;
                siteVisitUser.UserType__c = userType;
                siteVisitUser.FirstName__c = contacts.get(selectedId).FirstName;
                siteVisitUser.LastName__c = contacts.get(selectedId).LastName;
                siteVisitUser.Title__c = contacts.get(selectedId).Title;
                siteVisitUser.Telephone__c = contacts.get(selectedId).Phone;
                siteVisitUser.Email__c = contacts.get(selectedId).Email;
                siteVisitUserList.add(siteVisitUser);
            }
        }
        
        system.debug('--Inside AddSiteVisitPersonsToReport--siteVisitUserList--'+siteVisitUserList);
        if(Schema.sObjectType.SiteVisitPerson__c.isCreateable()){
            insert siteVisitUserList;
        }
  
        String PageReferenceURL = '/apex/'+ns+'SiteVisitPersonAdd?id=' + siteVisitId;
      //  if(!String.isEmpty(tabName)){
        //  PageReferenceURL+='&tabName='+tabName;
        //}
       // resultMap.put('PageReference',PageReferenceURL);   
         //resultMap.put('Message','User has been added successfully');
         resultMap.put('Message',GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-02121'));
                                               
        return resultMap;
    }    
}