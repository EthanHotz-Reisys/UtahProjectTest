global with sharing class HeatMapCtrl {
    global HeatMapCtrl() {
        
    }

    @RemoteAction
    global static List<Application__c> processApplications(String code, String value) {
        system.debug('code: '+code);
        List<Application__c> apps = [SELECT Id,Name,Title__c,SiteState__c,ExternalOrganization__c, ExternalOrganization__r.Name, Announcement__c, Announcement__r.Name FROM Application__c where SiteState__c = : code];
        return apps;
    }
}