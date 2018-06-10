@isTest
global class TestMockHttpResponseGenerator implements HttpCalloutMock {
    public String status;
    public String entity='';
    public TestMockHttpResponseGenerator (String scenario,String entity){
        this.entity=entity;
        status=scenario;
    }
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        // Optionally, only send a mock response for a specific endpoint
        // and method.
        String failurResp='',response='';
        System.assertEquals('GET', req.getMethod());
        HttpResponse res = new HttpResponse();
        if(entity=='SAM.Gov Entity Validation'){
            System.assertEquals('https://gw.sam.gov/SAMWS/1.0/Entity', req.getEndpoint());
            // Create a fake response
            failurResp='<env:Envelope xmlns:env="http://schemas.xmlsoap.org/soap/envelope/">'  + 
             '<env:Header/>'  + 
             '<env:Body>'  + 
             '<sam:getEntitiesResponse xmlns:sam="http://www.sam.gov">'  + 
             '<getEntities xmlns:ns2="http://www.sam.gov" xmlns:ns3="https://orcaxml.bpn.gov">'  + 
             '<transactionInformation>'  + 
             '<transactionStatus>02</transactionStatus>'  + 
             '<transactionMessage>No records found</transactionMessage>'  + 
             '<dataRetrievalTime>0.2</dataRetrievalTime>'  + 
             '<numberOfRecordsReturned>1</numberOfRecordsReturned>'  + 
             '</transactionInformation>'  + 
             '</getEntities>'  + 
             '</sam:getEntitiesResponse>'  + 
             '</env:Body>'+ 
             '</env:Envelope>' ; 
             
             response='<env:Envelope xmlns:env="http://schemas.xmlsoap.org/soap/envelope/">'  + 
             '<env:Header/>'  + 
             '<env:Body>'  + 
             '<sam:getEntitiesResponse xmlns:sam="http://www.sam.gov">'  + 
             '<getEntities xmlns:ns2="http://www.sam.gov" xmlns:ns3="https://orcaxml.bpn.gov">'  + 
             '<transactionInformation>'  + 
             '<transactionStatus>01</transactionStatus>'  + 
             '<transactionMessage/>'  + 
             '<dataRetrievalTime>0.2</dataRetrievalTime>'  + 
             '<numberOfRecordsReturned>1</numberOfRecordsReturned>'  + 
             '</transactionInformation>'  + 
             '</getEntities>'  + 
             '</sam:getEntitiesResponse>'  + 
             '</env:Body>'+ 
             '</env:Envelope>' ; 
      }
      
      if(entity=='FPDS'){
            response='  <feed xmlns="http://www.w3.org/2005/Atom"><entry>'+
    '<title><![CDATA[New DELIVERY ORDER BJ000200302CK1103BJ3007GS11K01BJD0008 awarded to REI SYSTEMS INC for the amount of $234,349]]></title>'+
    '<link rel="alternate" type="text/html" href="https://www.fpds.gov/ezsearch/search.do?s=FPDS&amp;indexName=awardfull&amp;templateName=1.4&amp;q=BJ000200302CK1103BJ3007GS11K01BJD0008+4735+"></link>'+
    '<modified>2003-06-30 11:02:10</modified>'+
    '<content xmlns:ns1="http://www.fpdsng.com/FPDS" type="application/xml">'+
      '<ns1:award xmlns:ns1="http://www.fpdsng.com/FPDS" version="1.0">'+
        '<ns1:awardID>'+
          '<ns1:awardContractID>'+            
          '<ns1:agencyID name="FEDERAL ACQUISITION SERVICE">4735</ns1:agencyID>'+
            '<ns1:PIID>BJ000200302CK1103BJ3007GS11K01BJD0008</ns1:PIID>'+
            '<ns1:modNumber>0</ns1:modNumber>'+
            '<ns1:transactionNumber>0</ns1:transactionNumber></ns1:awardContractID>'+
            '</ns1:awardContractID>'+
            '</ns1:awardID>'+
            '</ns1:award'+
            '</content>'+
           '  </entry></feed>' ;
      }  
      
      if(entity=='EPLS'){
         response='{"appreference":"S4MR3R7D6","status":"SAM Number exist in ExclusionList"}';
      }
      
      if(entity=='Dun and Bradstreet Verification'){
      	response='';
      }
 
     if(status=='success'){
        res.setBody(response);
     }else{
        res.setBody(failurResp);
     }
     res.setStatusCode(200);
     System.debug('printing the body response n testmock-----------------------'+res.getBody());
     System.debug('printing the response n testmock-----------------------'+res.getXmlStreamReader());
     return res;
    }
}