public class OpportunitiesExpandedRequestCallout {

    public static String app='';
    public static String soapEnv='';
    public static String gran='';
    public static String endpoint='';
    public static String soapAction='';
    public static String header='';
    public static String oppPackageID='';
    

   public static void webserviceCalloutParameters(){
               
        GrantsGovNamespaces__c grantsNS = GrantsGovNamespaces__c.getValues('GrantsNS');
        app=grantsNS.app__c;
        gran=grantsNS.gran__c;
        soapEnv= grantsNS.soapenv__c;
        endpoint=grantsNS.endpoint__c;
        soapAction=grantsNS.soapAction__c;
        header=grantsNS.header__c;
   }

    public static String  prepareSoapRequestBody(String oppNumber){         
        
        
        Xmlstreamwriter xmlW = new Xmlstreamwriter();
        xmlW.writeStartDocument('utf-8','1.0');
            xmlW.writeStartElement('soapenv','Envelope', soapEnv);
                xmlW.writeAttribute('xmlns','null','soapenv',soapEnv);
                xmlW.writeAttribute('xmlns','null','app',app);
                xmlW.writeAttribute('xmlns','null','gran',gran);
                xmlW.writeStartElement('soapenv','Header',soapEnv);
                xmlW.writeEndElement();
                xmlW.writeStartElement('soapenv','Body',soapEnv);
                    xmlW.writeStartElement('app','GetOpportunitiesExpandedRequest',soapEnv);
                            xmlW.writeStartElement('gran','FundingOpportunityNumber',soapEnv);                       
                            xmlW.writeCharacters(oppNumber);
                        xmlW.writeEndElement(); //close FundingOpportunityNumber
                    xmlW.writeEndElement(); //Close GetOpportunitiesExpandedRequest
                xmlW.writeEndElement(); //Close Body
            xmlW.writeEndElement(); //Close Envelope
        xmlW.writeEndDocument(); //Close XML document
    
        String xmlStringxmlRes = xmlW.getXmlString();
        System.debug('The XML :'+xmlW.getXmlString());     
        xmlW.close();
    
        return xmlStringxmlRes;
    }
        
    public static List<FormElement> opportunitiesExpandedCallout(String oppNumber){
    
          try{
          webserviceCalloutParameters();
          String body=prepareSoapRequestBody(oppNumber);
          
          //String body='<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:app="http://apply.grants.gov/services/ApplicantWebServices-V2.0" xmlns:gran="http://apply.grants.gov/system/GrantsCommonElements-V1.0"><soapenv:Header/><soapenv:Body><app:GetOpportunitiesExpandedRequest><gran:FundingOpportunityNumber>GGTEST1</gran:FundingOpportunityNumber></app:GetOpportunitiesExpandedRequest></soapenv:Body></soapenv:Envelope>';
          String endPoint=endPoint; 
            
          HttpRequest req = new HttpRequest();
          req.setMethod('POST');
          req.setHeader('SOAPAction',soapAction);
          req.setHeader('Content-Type','text/xml;charset=UTF-8');
          req.setHeader('Accept', 'gzip,deflate');
          req.setHeader('Content-Length', '7531');
          req.setHeader('Host',header);
          req.setHeader('Connection','Keep-Alive');
          req.setEndpoint(endPoint);
          req.setBody(body);
          req.setClientCertificateName('grantsgovcert');

          Http http = new Http();
          //System.debug('in before request method----------------------------------'+req);
          HttpResponse res=null;
          res = http.send(req); 
          System.debug('Opp schema retrieval WS----------------------------------'+res.getBody()); 
          
          OpportunityExpandedResult  oppExpObj=parseResponse(res.getBody());
          
          System.debug('oppExpObj----------------'+oppExpObj);
          
          String schemaOutput='';
          List<FormElement> elementsList=null;
          
          /*ggsTempPack1__Package__c test=new ggsTempPack1__Package__c();
          test.Name='test Pkg';
          insert test;*/
          
          //System.debug('test----------------------'+test);
          
          if(oppExpObj!=null && oppExpObj.SchemaURL!=null){
              System.debug('inside oppExpObj--------------------'+oppExpObj.SchemaURL);
              oppPackageID=oppExpObj.PackageID;
             
              Pagereference pg=new Pagereference(oppExpObj.SchemaURL);   //'https://trainingapply.grants.gov/apply/opportunities/schemas/applicant/oppGGTEST1-cfda00.000.xsd');
              pg.setRedirect(false);
              System.debug('pg--------------------'+pg);
              System.debug('pg--------------------'+pg.getHeaders());
              schemaOutput=pg.getContent().toString();
              System.debug('schema url content--------------------'+schemaOutput);
              
              elementsList=parseSchemaMethod(schemaOutput,'Forms');
              
              for (FormElement e: elementsList){
               
                    System.debug('Element values----------------'+e);
                            
                
              } 
              return elementsList;
          }
          }catch(Exception e){
              System.debug('Exception'+e.getMessage());
              return null;
          }
          
          return null;
          
    }
    
    
    public static OpportunityExpandedResult  parseResponse(String res){
    
        try{
            Map<String,String> responseMap=new Map<String,String>();
            XmlStreamReader reader = new XmlStreamReader(res);
            System.debug('Reader in parseResponse method --------------------'+reader );
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
           
            System.debug('gen.getAsString()-------------------'+gen.getAsString());
            OpportunityExpandedResult oppExpObj =(OpportunityExpandedResult)JSON.deserialize(gen.getAsString(),OpportunityExpandedResult.class);
            System.debug('oppExpObj -----------------'+oppExpObj );
            return oppExpObj ;
            }catch(Exception e){
                System.debug('Exception occured'+e.getMessage());
                return null;
            }
    
    }
    
    public class OpportunityExpandedResult{
    
        String WorkContext{get;set;}
        String FundingOpportunityNumber{get;set;}
        String CFDANumber{get;set;}
        String OpeningDate{get;set;}
        String ClosingDate{get;set;}
        //String FundingOpportunityTitle{get;set;}
        String OfferingAgency{get;set;}
        //List<String> AgencyContactInfo{get;set;}
        String CFDADescription{get;set;}
        String SchemaURL{get;set;}
        String InstructionsURL{get;set;}
        String IsMultiProject{get;set;}
        String PackageID{get;set;}

    
    }
    
    
    public static List<FormElement> parseSchemaMethod(String str,String nodeVal){
        Map<String,String> responseMap=new Map<String,String>();
   
        XmlStreamReader reader = new XmlStreamReader(str);
        boolean isSafeToGetNextXmlElement=true;
        List<FormElement> elementsList= new List<FormElement>();
        
        boolean formsNode=false;
        while(isSafeToGetNextXmlElement) { 
                if (reader.getEventType() == XmlTag.START_ELEMENT ) {
                    System.debug('Attribute value at 0-------------------------------'+reader.getAttributeValueAt(0));
                                       
                    String refValue=reader.getAttributeValueAt(0);
                    if(refValue!=null && refValue =='Forms'){
                        if (reader.hasNext()) {
                            reader.next();
                        }   
                        reader = reader;
                        formsNode=true;
                        break;
                    }
                      
                }
                
                if (reader.hasNext()) {
                    reader.next();
                } else {
                    isSafeToGetNextXmlElement = false;
                    break;
                }
       }
        
        
        while(formsNode){
        
               if (reader.getEventType() == XmlTag.START_ELEMENT ) {
                    String refValue=reader.getAttributeValueAt(0);
                    if(refValue!=null ){
                        FormElement element= new FormElement();
                        element.name=refValue;
                        element.oppPackageID=oppPackageID;
                        element.minOccurs=reader.getAttributeValueAt(1);
                        element.maxOccurs=reader.getAttributeValueAt(2);
                        elementsList.add(element);
                       
                    }
                      
                }
                
                if (reader.hasNext()) {
                    reader.next();
                } else {
                    formsNode=false;
                    break;
                }
        
        }
        
       return elementsList; 
       
        
  }    
  
   
       
}