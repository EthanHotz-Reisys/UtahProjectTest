global with sharing class DashboardApplicationMapHelper implements GNT.MapInterface{
    public List<GNT.MapPin> getPins(Map<String, String> urlParams){
        List<Application__c> applicationList = [Select Id,ExternalOrganization__r.BillingCountry,ExternalOrganization__r.BillingState,
                                                    ExternalOrganization__r.BillingCity,ExternalOrganization__r.BillingStreet   
                                                        From Application__c 
                                                            Where Announcement__r.FiscalYear__c = :GNT.AppUtils.getCurrentFiscalYear() LIMIT :GNT.AppUtils.SOQL_LIMIT];
        
        List<GNT.MapPin> pinsList = new List<GNT.MapPin>();
        for(Application__c a:applicationList){
            GNT.MapPin pin = new GNT.MapPin();
            pinsList.add(pin);  
        }
        return pinsList;        
    }    
}