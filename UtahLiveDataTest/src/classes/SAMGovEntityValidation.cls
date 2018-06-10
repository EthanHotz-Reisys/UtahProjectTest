/**
* Apex class that validates user with sam.gov by webservice callout
* 
* CHANGE HISTORY
* =============================================================================
* Date          Name               Description
* 03/18/2017    Sirisha Duriseti   Sam.gov user validation
* =============================================================================
*/
public class SAMGovEntityValidation
{
    public String userName='';
    public String password='';
    public String soapNS='';
    public String xsi='';
    public String endPoint='';
    
    public SAMGovEntityValidation(){
        SamGovEntityCredentials__c samGov = SamGovEntityCredentials__c.getValues('samGovCreds');
        userName=samGov.username__c;
        password=samGov.password__c;
        soapNS = samGov.soapNS__c;
        xsi = samGov.xsi__c;
        endPoint=samGov.endpoint__c;
        System.debug('samGov'+samGov);
    }
    private DOM.Document prepareRequest(String dunsNumber,String TIN, String startDt, String endDt,String CAGECode,String registrationStatus){
        
        //System.debug('in prepared request method----------------------------------');
        //'2013-11-25-00:00:00'
        DOM.Document doc = new DOM.Document();
        dom.XmlNode envelope
            = doc.createRootElement('Envelope', soapNS, 'soapenv');
        envelope.setNamespace('sam', xsi);
        dom.XmlNode header
            = envelope.addChildElement('Header', soapNS, null);
        dom.XmlNode body
            = envelope.addChildElement('Body', soapNS, null);
    
       body.addChildElement('getEntities', xsi, 'sam').
       addChildElement('authenticationKey', null, null).
       addChildElement('userID', null, null).
       addTextNode(userName);
       body.getChildElement('getEntities',xsi).getChildElement('authenticationKey', null).addChildElement('password',null,null).addTextNode(password);
       
       if(dunsNumber!=null){
            if(body.getChildElement('getEntities',xsi).getChildElement('entitySearchCriteria', null)!=null){
                body.getChildElement('getEntities',xsi).getChildElement('entitySearchCriteria',null).addChildElement('DUNSNumber',null,null).addTextNode(dunsNumber);
            }else{
                body.getChildElement('getEntities',xsi).addChildElement('entitySearchCriteria',null,null).addChildElement('DUNSNumber',null,null).addTextNode(dunsNumber);
            }
       }
       if(TIN!=null){
            if(TIN.containsAny('-')){
                TIN=TIN.remove('-');
            }
            //System.debug('TIN in sam e validation--------------'+TIN);
            if(body.getChildElement('getEntities',xsi).getChildElement('entitySearchCriteria', null)!=null){
                body.getChildElement('getEntities',xsi).getChildElement('entitySearchCriteria',null).addChildElement('taxpayerIdentificationNumber',null,null).addTextNode(TIN);
            }else{
                body.getChildElement('getEntities',xsi).addChildElement('entitySearchCriteria',null,null).addChildElement('taxpayerIdentificationNumber',null,null).addTextNode(TIN);
            }
       }
       /*if(startDt!=null && endDt!=null){
            if(body.getChildElement('getEntities',xsi).getChildElement('entitySearchCriteria', null)!=null){
                body.getChildElement('getEntities',xsi).getChildElement('entitySearchCriteria',null).addChildElement('startDt',null,null).addTextNode(startDt);
                body.getChildElement('getEntities',xsi).getChildElement('entitySearchCriteria',null).addChildElement('endDt',null,null).addTextNode(endDt);
            }else{
                body.getChildElement('getEntities',xsi).addChildElement('entitySearchCriteria',null,null).addChildElement('startDt',null,null).addTextNode(startDt);
                body.getChildElement('getEntities',xsi).addChildElement('entitySearchCriteria',null,null).addChildElement('endDt',null,null).addTextNode(endDt);
            }
            
       }
       if(CAGECode!=null){
            if(body.getChildElement('getEntities',xsi).getChildElement('entitySearchCriteria', null)!=null){
                body.getChildElement('getEntities',xsi).getChildElement('entitySearchCriteria',null).addChildElement('CAGECode',null,null).addTextNode(CAGECode);
            }else{
                body.getChildElement('getEntities',xsi).addChildElement('entitySearchCriteria',null,null).addChildElement('CAGECode',null,null).addTextNode(CAGECode);
            }
       }*/
       if(registrationStatus!=null){
            if(body.getChildElement('getEntities',xsi).getChildElement('entitySearchCriteria', null)!=null){
                body.getChildElement('getEntities',xsi).getChildElement('entitySearchCriteria',null).addChildElement('registrationStatus',null,null).addTextNode(registrationStatus);
            }else{
                body.getChildElement('getEntities',xsi).addChildElement('entitySearchCriteria',null,null).addChildElement('registrationStatus',null,null).addTextNode(registrationStatus);
            }
       }
       body.getChildElement('getEntities',xsi).addChildElement('requestedData',null,null).addChildElement('coreData',null,null).addTextNode('Y');
                   
        return doc;
    }
    
    public Map<String,String> sendRequest(String dunsNumber,String TIN, String startDt, String endDt,String CAGECode,String registrationStatus)
    {
        
        Map<String,String> responseMap=new Map<String,String>();
        try{
            String response='';
            System.debug('in send request method----------------------------------'+dunsNumber+'\n'+TIN);
            DOM.Document doc=prepareRequest(dunsNumber,TIN,startDt,endDt,CAGECode,registrationStatus);
            System.debug('SAM entity validation doc--------------'+doc);
            // Send the request
            HttpRequest req = new HttpRequest();
            req.setMethod('GET');
            req.setEndpoint(endPoint);
            req.setBodyDocument(doc);
            
            Http http = new Http();
            //System.debug('in before request method----------------------------------'+req);
            HttpResponse res=null;
            res = http.send(req);     
            
            XmlStreamReader reader;
            if(res!=null){
            reader=res.getXmlStreamReader();
            //System.debug('res in actual class --------------------'+reader );
            boolean isSafeToGetNextXmlElement = true;
            String transactionStatus='';
            String transactionMsg='';
            JSONGenerator gen = JSON.createGenerator(true);
            gen.writeStartObject();
            String fin='';
            String localName='';
            while (reader.hasNext()) {
              if (reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName()!=null){
                fin+=reader.getLocalName()+':';
                localName=reader.getLocalName();
              } 
              
              if (reader.getEventType() == XmlTag.CHARACTERS) {
                fin += reader.getText()+';';
                if(localName!=null && reader.getText()!=null){
                    gen.writeStringField(localName, reader.getText());
                }
              }
              reader.next();
            }
            gen.writeEndObject();
            Map<String, Object> m =(Map<String, Object>)JSON.deserializeUntyped(gen.getAsString());
            for(String s:m.keySet()){
                responseMap.put(s,String.valueOf(m.get(s)));
            }
            //responseMap.put('responseBody',res.toString());
            }
            //System.debug('responseMap------------------------'+responseMap);
        }catch(System.CalloutException e){
            responseMap.put('REQUEST FAILED',e.getMessage());
            System.debug('Exception in sendRequest method:'+e.getMessage());
        }
        return responseMap;
       
        
    }
    
}