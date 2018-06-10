global with sharing class ApplicationMapHelper implements GNT.MapInterface{
    public List<GNT.MapPin> getPins(Map<String, String> urlParams){
        Id applicationId = urlParams.get('id');  
        List<Application__c> applicationList = [Select Id,ExternalOrganization__r.ShippingLongitude,ExternalOrganization__r.ShippingLatitude 
                                                        From Application__c 
                                                            Where Id = :applicationId LIMIT :GNT.AppUtils.SOQL_LIMIT];
        
        List<GNT.MapPin> pinsList = new List<GNT.MapPin>();
        for(Application__c a:applicationList){
         GNT.MapPin pin = new GNT.MapPin();
            pin.longitude = a.ExternalOrganization__r.ShippingLongitude;    
            pin.latitude = a.ExternalOrganization__r.ShippingLatitude;      
            pinsList.add(pin);  
        }          
        return pinsList;        
    }    
}