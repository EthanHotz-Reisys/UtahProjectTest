global without sharing class USPSAddressInformationCtrl{ 
    public USPSAddressInformationCtrl(ApexPages.StandardController controller) {

    }
 
 private static string USPS_UID = GNT.KeyValueStoreHelper.getTextValue('USPSUserId', true);
  
 private static string BuildAddressQueryURLString(USPSAddress AddressToQuery) { 
     
  // this function is coded to send only one address at a time
  // but it could be updated to support more (10 is the max ATM) by
  // iterating over addresses and incremending the address ID XML for each address 
  // until you have one large URL as your query.
   
  // However, if you do modify this for mutiple addresses then you will need to
  // re-write the XML parse to handle that as well.  
   
  String BaseURL = 'http://production.shippingapis.com/ShippingAPITest.dll?API=CityStateLookup&XML=';
  String ReturnValue = '<CityStateLookupRequest USERID="' + USPS_UID + '">';
  ReturnValue += '<ZipCode ID="0"><Zip5>' + AddressToQuery.Zip5 + '</Zip5></ZipCode>';
  ReturnValue += '</CityStateLookupRequest>';
  ReturnValue = EncodingUtil.urlEncode(ReturnValue, 'UTF-8');
   
  ReturnValue = BaseURL + ReturnValue; 

  system.debug('***return value' + ReturnValue);
   
  return ReturnValue;
   
 } // BuildAddressQueryURLString
 
 private static string GetStandardizedAddressFromUSPS(string USPSURLtoQuery) {
 
    string ReturnValue = '';
     
          HttpRequest USPSRequest = new HttpRequest();
          Http USPSHttp = new Http();
           
          USPSRequest.setMethod('GET');
           //USPSRequest.setHeader('Access-Control-Allow-Origin', 'https://govgrantsdev-developer-edition.na11.force.com');
          USPSRequest.setEndpoint(USPSURLtoQuery);
 
             HttpResponse USPSResponse = USPSHttp.send(USPSRequest);
             //USPSResponse.setHeader('Access-Control-Allow-Origin', '*');
             ReturnValue = USPSResponse.getBody();  
        
    return ReturnValue;
   
 } // GetStandardizedAddressFromUSPS
  
 private static USPSAddress ParseUSPSResponseXML(String XMLToParse) {
  USPSAddress ReturnAddress = new USPSAddress();
 
  // parse the response
  XMLStreamReader USPSXMLReader = new XMLStreamReader(XMLToParse);
   
  while (USPSXMLReader.hasNext()) {
 
          if (USPSXMLReader.getEventType() == XmlTag.START_ELEMENT) {
 
             if ('CityStateLookupResponse' == USPSXMLReader.getLocalName()) {
                             
              USPSXMLReader.next();
               
              if ('ZipCode' == USPSXMLReader.getLocalName()) {
               ReturnAddress = ParseUSPSAddressXML(USPSXMLReader);
              } // <Address ID="0"> tag
               
             } // <AddressValidateResponse> confirmation
          } // Starting tag        
    
   USPSXMLReader.next();
             
  } // loop thru UPS XML Reader
 
  if (ReturnAddress.HasData() == false) {
   // if parsing comes back totally blank then indicate an unknown / parsing error to the caller / requestor
   system.Debug('ReturnAddress.HasData() == false');
   ReturnAddress.USPS_Returned_Error = true;
   ReturnAddress.USPS_ERROR_DESC = 'Unknown Error parsing XML Response';
   ReturnAddress.USPS_ERROR_SOURCE = 'Salesforce XML Parsing';
   ReturnAddress.USPS_ERROR_CODE = '-1';
  } 
 
  return ReturnAddress;
 } // ParseAddressXML
  
 private static USPSAddress ParseUSPSAddressXML(XMLStreamReader USPSAddressXMLReader) {
  USPSAddress ReturnAddress = new USPSAddress();  
  while(USPSAddressXMLReader.hasNext()) {
         if (USPSAddressXMLReader.getEventType() == XmlTag.END_ELEMENT) {
          if ('Address' == USPSAddressXMLReader.getLocalName()) {
           // quit parsing when we hit the end of this record          
             break;
          } // check for address ending tag
         } else if ('Error' == USPSAddressXMLReader.getLocalName()) {                     
          ReturnAddress = ParseUSPSErrorXML(USPSAddressXMLReader);
          ReturnAddress.USPS_Returned_Error = true;
         } else if ('Address1' == USPSAddressXMLReader.getLocalName()) {
           
          USPSAddressXMLReader.next();
           
          if (USPSAddressXMLReader.getEventType() == XmlTag.CHARACTERS) {             
           ReturnAddress.Address1 = USPSAddressXMLReader.getText();
          } // check for data
         } else if ('Address2' == USPSAddressXMLReader.getLocalName()) {
           
          USPSAddressXMLReader.next();
           
          if (USPSAddressXMLReader.getEventType() == XmlTag.CHARACTERS) {                   
           ReturnAddress.Address2 = USPSAddressXMLReader.getText();
          } // check for data
         } else 
         if ('City' == USPSAddressXMLReader.getLocalName()) {
           
          USPSAddressXMLReader.next();
           
          if (USPSAddressXMLReader.getEventType() == XmlTag.CHARACTERS) {               
           ReturnAddress.City = USPSAddressXMLReader.getText();
          } // check for data
         } else if ('State' == USPSAddressXMLReader.getLocalName()) {
           
          USPSAddressXMLReader.next();
           
          if (USPSAddressXMLReader.getEventType() == XmlTag.CHARACTERS) {                 
           ReturnAddress.State = USPSAddressXMLReader.getText();
          } // check for data
         } else if ('Zip5' == USPSAddressXMLReader.getLocalName()) {
           
          USPSAddressXMLReader.next();
           
          if (USPSAddressXMLReader.getEventType() == XmlTag.CHARACTERS) {                
           ReturnAddress.Zip5 = USPSAddressXMLReader.getText();
          } // check for data
         } else if ('Zip4' == USPSAddressXMLReader.getLocalName()) {
           
          USPSAddressXMLReader.next();
           
          if (USPSAddressXMLReader.getEventType() == XmlTag.CHARACTERS) {                
           ReturnAddress.Zip4 = USPSAddressXMLReader.getText();
          } // check for data
                              
         } // check for end tags
          
         USPSAddressXMLReader.next();
          
      } // loop thru XML reader
   
  return ReturnAddress;  
 } // ParseUSPSAddressXML
  
 private static USPSAddress ParseUSPSErrorXML(XMLStreamReader USPSErrorXMLReader) {
 
  USPSAddress ReturnAddress = new USPSAddress();
   
  while(USPSErrorXMLReader.hasNext()) {
         if (USPSErrorXMLReader.getEventType() == XmlTag.END_ELEMENT) {
          if ('Error' == USPSErrorXMLReader.getLocalName()) {
           // quit parsing when we hit the end of this record
              break;
          }
         } else if ('Number' == USPSErrorXMLReader.getLocalName()) {
           
          USPSErrorXMLReader.next();
           
          if (USPSErrorXMLReader.getEventType() == XmlTag.CHARACTERS) {                     
           ReturnAddress.USPS_ERROR_CODE = USPSErrorXMLReader.getText();
          } // check for data
         } else if ('Source' == USPSErrorXMLReader.getLocalName()) {
           
          USPSErrorXMLReader.next();
           
          if (USPSErrorXMLReader.getEventType() == XmlTag.CHARACTERS) {                     
           ReturnAddress.USPS_ERROR_SOURCE = USPSErrorXMLReader.getText();
          } // check for data
         } else if ('Description' == USPSErrorXMLReader.getLocalName()) {
           
          USPSErrorXMLReader.next();
           
          if (USPSErrorXMLReader.getEventType() == XmlTag.CHARACTERS) {                     
           ReturnAddress.USPS_ERROR_DESC = USPSErrorXMLReader.getText();
          } // check for data
           
         } // check for ending element
          
         USPSErrorXMLReader.next();
          
      } // loop thru XML reader
   
  return ReturnAddress;  
 
   
 } // ParseUSPSErrorXML
  
 public static USPSAddress CheckAddress(USPSAddress Address2Check) {
 
  USPSAddress ResponseAddress = new USPSAddress();
   
  // build the URL for the API call  
  string USPSURL = BuildAddressQueryURLString(Address2Check);
 
  // call the API and pullback the XML as a string
  string XMLResponse = GetStandardizedAddressFromUSPS(USPSURL);   
  // send the XML reponse to the parser
  ResponseAddress = ParseUSPSResponseXML(XMLResponse);
   
   
  return ResponseAddress;
   
 } // CheckAddress
 
    @RemoteAction
    global static Map<String,Object> GetAddressRemote(String zip) {
        Map<String, Object> result = new Map<String, Object>();
        USPSAddress requestAddress = new USPSAddress();
        requestAddress.Zip5 = zip;
        USPSAddress SearchResult = CheckAddress(requestAddress);
        result.put('result', SearchResult );
        return result;
    }
} // end USPS Class