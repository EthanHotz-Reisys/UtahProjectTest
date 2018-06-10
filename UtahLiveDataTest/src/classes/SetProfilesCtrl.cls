/*
  <Purpose of this class>    
    *******************************************************************************************************************
    Audit History
    ********************************************************************************************************************
    2017-04-01  Shah Kadirmohideen  Code Reviewed
    **********************************************************************************************************************  
*/ 
global with sharing class SetProfilesCtrl {
    public String objectId {get;set;}
    public String objectType {get;set;}
    public String fieldName {get;set;}
    public String profiles {get;set;}
    
    public SetProfilesCtrl() {
        objectId = ApexPages.CurrentPage().getParameters().get('id');
        fieldName = ApexPages.CurrentPage().getParameters().get('field');
        objectType = ApexPages.CurrentPage().getParameters().get('type');
        profiles = ApexPages.CurrentPage().getParameters().get('profiles');
    }
    
    @RemoteAction
    global static List<Profile> getProfiles() {
        Organization org  = [SELECT Id , CreatedDate FROM Organization]; 
        return [SELECT Id, Name FROM Profile WHERE CreatedDate >: org.CreatedDate];
    }
    
    @RemoteAction
    global static String save(String objectType, String objectId, String fieldName, String profiles) {
        try {
            String query = 'SELECT ' + fieldName + ' FROM ' + objectType + ' WHERE id =: objectId';
            List<Sobject> sobjects = Database.query(query);
            if (sobjects.size() > 0) {
                profiles = profiles.removeStart('[').removeEnd(']').replaceAll(', ', ';');
                sobjects[0].put(fieldName, profiles);
                update sobjects[0];
                return 'Success';
            } else {
                return 'Incorrect Id';
            }
        } catch(Exception e) {
            return e.getMessage();
        }
    }
}