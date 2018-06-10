global with sharing class CloneApplicationHelper extends GNT.DynamicLayoutActionRedirect{
    Application__c currentRecord;
    public CloneApplicationHelper(ApexPages.StandardController controller) {
     currentRecord = (Application__c)controller.getRecord();
    }
    public CloneApplicationHelper(GNT.DynamicLayoutHolder layoutHolder) {
        this.layoutHolder = layoutHolder;
    }
    public CloneApplicationHelper( ) {
        }
    global override PageReference whenClicked(){
        Application__c newRecord;
        Savepoint sp = Database.setSavepoint();
        Integer appCount,maxAppCount;
        Boolean HideSubmit = true;
        Id recordId = layoutHolder.getPrimarySObject().Id;
        String newId = '';
    	Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
    	String uniqueIdAPIName = 'InternalUniqueID__c';
    	String SobjectApiName = 'Application__c';
        Map<String, Schema.SObjectField> fieldMap = schemaMap.get(SobjectApiName).getDescribe().fields.getMap();
        String commaSeparatedFields = '';
        for(String fieldName : fieldMap.keyset()){
            if(!fieldName.equalsIgnorecase(uniqueIdAPIName)){
                if(commaSeparatedFields == null || commaSeparatedFields == ''){
                    commaSeparatedFields = fieldName;
                }else{
                    commaSeparatedFields = commaSeparatedFields + ', ' + fieldName;
                }
            }
        }
        String query = 'select Announcement__r.MaxApplicationsAllowed__c, Announcement__r.Name, ' + commaSeparatedFields + ' from ' + SobjectApiName + ' where Id = \'' + recordId + '\'';
        
        currentRecord = Database.query(query);
        List<Application__c> appList = [Select Id, Name from Application__c where Announcement__c=:currentRecord.Announcement__c and ExternalOrganization__c =:currentRecord.ExternalOrganization__c];
        if(appList!=null &&  appList.size()>0){
            appCount = appList.size();
       } else{
            appCount = 0;
        }
        if(currentRecord.Announcement__r.MaxApplicationsAllowed__c!=null&&currentRecord.Announcement__r.MaxApplicationsAllowed__c>0){
            maxAppCount=(Integer)currentRecord.Announcement__r.MaxApplicationsAllowed__c;
        }
        else{
            maxAppCount=1;
        }
        Announcement__c announcementObj = [Select ApplicationDeadlineWithDateTime__c, ExtensionDays__c, TimeExtensionAllowed__c from Announcement__c where Id = :currentRecord.Announcement__c limit 1];
        Date d = Date.newInstance(announcementObj.ApplicationDeadlineWithDateTime__c.year(), announcementObj.ApplicationDeadlineWithDateTime__c.month(), announcementObj.ApplicationDeadlineWithDateTime__c.day());
        User u = [Select Contact.Account.IsExtensionAllowed__c from User where Id = :UserInfo.getUserId()];
        if(u.Contact.Account.IsExtensionAllowed__c == true && announcementObj.TimeExtensionAllowed__c == true){          
          if(d + Integer.valueOf(announcementObj.ExtensionDays__c )> Date.today()){
              HideSubmit = false;
          }
        }else{
          if(d > Date.today()){
              HideSubmit = false;
          }
        }
        if(HideSubmit){
            // ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Cannot clone application after application deadline'));
          ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, GNT.ErrorMessageHelper.fetchMessage('P32-RPT-15414')));
          return null;
        }
        if(maxAppCount<=appCount){
            // ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Application can not be cloned as you have reached the maximum limit for allowed applications for '+currentRecord.Announcement__r.Name));
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-17603')+' ' +currentRecord.Announcement__r.Name));
            return null;                 
        }
        ApplicationCloneHelper cloneHelper = new ApplicationCloneHelper();
		newId = cloneHelper.cloneApplication(recordId, null);
       return new PageReference('/'+newId);
    }
       
}