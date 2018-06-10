public with sharing class MapQuestAddressInformationCtrl{ 

    public MapQuestAddressInformationCtrl(ApexPages.StandardController controller) {}
  
    private static string MAP_QUEST_APP_KEY = 'Fmjtd%7Cluur20u725%2Caa%3Do5-9ayl9r';
    private static string BuildAddressQueryURLString(MapQuestAddress addressWrap) {  
        String BaseURL = 'http://open.mapquestapi.com/geocoding/v1/address?key='+MAP_QUEST_APP_KEY;
        String ReturnValue = '&street='+addressWrap.Street+'&city='+addressWrap.City+'&state='+addressWrap.State+'&postalCode=';          
        ReturnValue = ReturnValue.replaceAll(' ', '%20');
        ReturnValue = BaseURL + ReturnValue; 

        return ReturnValue;
    }
 
    private static string RequestAddress(string URLString) {
        string ReturnValue = '';
        HttpRequest MapQuestRequest = new HttpRequest();
        Http httpObject = new Http();
        MapQuestRequest.setMethod('GET');
        MapQuestRequest.setEndpoint(URLString); 
        HttpResponse responseObject = httpObject.send(MapQuestRequest);
        ReturnValue = responseObject.getBody();  
   
        return ReturnValue;
    }
  
    public static Map<String, Object> CheckAddress(MapQuestAddress Address2Check) {
        
        // build the URL for the API call  
        string URLString = BuildAddressQueryURLString(Address2Check);
        // call the API and pullback the XML as a string
        string JSONResponse = RequestAddress(URLString);   
        // send the XML reponse to the parser
        Map<String, Object>  ResponseLatLang = ParseJSONResponse(JSONResponse);
   
        return ResponseLatLang ;
    }
    
    private static Map<String, Object> ParseJSONResponse(String JSONResponse){
        JSONParser parser = JSON.createParser(JSONResponse);
        Map<String, Object> latLangMap = new Map<String, Object>();
        while (parser.nextToken() != null) {
            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) &&  (parser.getText() == 'latLng')) {
                parser.nextToken();
                if(parser.nextToken() != null && (parser.getCurrentToken() == JSONToken.FIELD_NAME) &&  (parser.getText() == 'lng')){   
                    parser.nextToken();                    
                    latLangMap.put('lng', parser.getDoubleValue());
                }
                if(parser.nextToken() != null && (parser.getCurrentToken() == JSONToken.FIELD_NAME) &&  (parser.getText() == 'lat')){   
                    parser.nextToken();                    
                    latLangMap.put('lat', parser.getDoubleValue());
                }
            }
        }
        return latLangMap;
    }
 
    public class MapQuestAddress{        
        String Street {get; set;}
        String City {get; set;}
        String State {get; set;}
        
        public MapQuestAddress(){            
            Street = '';
            City = '';
            State = '';
        }
    }

    public static Map<String,Object> GetLatLangAddressRemote(String street, String city, String state) {
        Map<String, Object> result = new Map<String, Object>();
        MapQuestAddress requestAddress = new MapQuestAddress();        
        if(street == null || street == 'null'){
            street = '';
        }
        requestAddress.Street = street;
        requestAddress.City = city;
        requestAddress.State = state;
        return CheckAddress(requestAddress);
                
    }
}