/**
*   Validate EIN and DUNS numbers against external API
*
*   CHANGE HISTORY
*   ===================================================
*    ===================================================
*   Date            Name                Description
*   06/17/2015      Shrawan Raina       Created
*   06/24/2015      Shrawan Raina       Updated method signature for external calls.
*   04/24/2017      Sirisha Duriseti    Added SAM Entity/EPLS Validation
*   07/28/2017      Sirisha Duriseti    modified D&B and Guidestar interfaces
*/

public with sharing class ExternalInterfaceCtrl {
    
    private transient InterfaceConfig__c apiConfigDUNS {get; set;}
    private transient InterfaceConfig__c apiConfigEIN {get;set;}
    private transient InterfaceConfig__c apiConfigEINDetail{get;set;}
    private transient FPDSData p {get;set;}
    List<FPDSData> listOfFPDS = new List<FPDSData>();
    private transient String guideStarResponseStr='';
    private transient String dAndBResponseStr='';
    private transient String eplsRespStr='';
    private transient String fpdsResponseStr='';
    
    public ExternalInterfaceCtrl(){
        apiConfigEIN = InterfaceConfig__c.getInstance('GuideStarQuickstartSearchAPI');      //Guidestar Quickstart API
        apiConfigEINDetail = InterfaceConfig__c.getInstance('GuideStarQuickstartDetailAPI');
        apiConfigDUNS = InterfaceConfig__c.getInstance('Dun and Bradstreet Interface');     // D & B Sandbox credentials--Need subscription to access Production API
    }
    
    private class InterfaceException extends Exception {}
    
    private class EINResponse {
        private transient String ein;
        private transient String organization_name;
        private transient String organization_id;
        private transient String address_line1;
        private transient String address_line2;
        private transient String city;
        private transient String state;
        private transient String zip;
        private transient String zip4;
        private transient String affiliation_code;
        private transient String affiliation_code_description;
        private transient String aka_organization_name;
        private transient String deductibility_code;
        private transient String deductibility_code_description;
        private transient String foundation_code;
        private transient String foundation_code_description;
        private transient String income_total;
        private transient String subsection_code;
        private transient String subsection_code_description;
        private transient String mission;
        private transient String group_exemption;
    }
    
    //GuideStar's database of Nonprofit and Charitable Organizations and Foundations. Return data is available in  JSON 
    public Map<String, List<String>> checkEIN(String einNo,Map<String, List<String>> calloutResponse) {        
            List<String> calloutReqRes = new List<String>();
        try {
            Http http = new Http();
            HttpRequest req = new HttpRequest();
            HttpResponse res = new Httpresponse();
            
            //Callout to get the Organization Id for a given EIN Number
            Blob headerValue = Blob.valueOf(apiConfigEIN.Username__c+ ':' + apiConfigEIN.Password__c);
            String authorizationHeader = 'BASIC '+EncodingUtil.base64Encode(headerValue);
     
            req.setHeader('Authorization', authorizationHeader);
            req.setHeader('Content-Type','application/json');
            req.setTimeout(50000);            
            req.setMethod('GET');
            //String ein=(einNo.length()==10 && einNo.contains('-') ? einNo : cleanEIN(einNo));
            req.setEndpoint(apiConfigEIN.Url__c + apiConfigEIN.Version__c +'?q=ein:'+einNo);   
            String startDT = String.valueOf(System.today());
            String endDT = String.valueOf(System.today());
            res = http.send(req);
            JSONParser parser;
            String organizationId = '';
            Integer status=res.getStatusCode();
            
            if(status==200){
                parser = JSON.createParser(res.getBody());
                while (parser.nextToken() != null) {
                    if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) &&
                        (parser.getText() == 'organization_id')) {
                        // Get the value.
                        parser.nextToken();
                        organizationId = parser.getText();
                        break;
                    }
                }
                
                //Using Organization Id, another callout is made to get the Organization Details
                req = new HttpRequest();
                //setting headers
                headerValue = Blob.valueOf(apiConfigEINDetail.Username__c+ ':' + apiConfigEINDetail.Password__c);
                authorizationHeader = 'BASIC '+EncodingUtil.base64Encode(headerValue);
         
                req.setheader('Authorization', authorizationHeader );
                req.setHeader('Content-Type', 'application/json');
                            
                req.setMethod('GET');
                req.setEndpoint(apiConfigEINDetail.Url__c + apiConfigEINDetail.Version__c +organizationId+'.json');   
                req.setTimeout(50000);
                res = http.send(req);
                status = res.getStatusCode();
    
            }
            if(status == 200) {
                system.debug('raw response status ok:'+res.getBody());
                EINResponse response = processEINResponse(res.getBody());
                calloutReqRes.add(req.getBody()); 
                calloutReqRes.add('GuideStar');
                calloutReqRes.add(guideStarResponseStr);
                calloutReqRes.add('Non Profit Verification');
                calloutReqRes.add('SUCCESS');
                calloutReqRes.add('');
                calloutReqRes.add(startDT);
                calloutReqRes.add(endDT);
                calloutResponse.put(einNo,calloutReqRes);                
            }
            else { 
                system.debug('status not ok:'+res.getBody());               
                calloutReqRes.add(req.getBody());
                calloutReqRes.add('GuideStar');
                calloutReqRes.add(res.getStatus());
                calloutReqRes.add('Non Profit Verification');
                calloutReqRes.add('SUCCESS');
                calloutReqRes.add('Failed:No Match found with EIN number');
                calloutReqRes.add(startDT);
                calloutReqRes.add(endDT);
                calloutResponse.put(einNo,calloutReqRes);                

            }
            return calloutResponse;
            //'401 : Unauthorized. The request requires user authentication.';
            //'403 : Forbidden. The API understood the request, but is refusing to fulfill it. Most commonly, this means that the user has exceeded their request limit or does not have permissions to access this API.'; 
            //'500 : Server Error. The API encountered an unexpected condition which prevented it from fulfilling the request.';
            //'503 : Service Unavailable. The API is unavailable to handle the request due to a temporary overloading or maintenance of the server.';

        }
        catch(System.CalloutException e) {
                calloutReqRes.add('REQUEST FAILED');
                calloutReqRes.add('GuideStar');
                calloutReqRes.add('Exception:'+e.getMessage());
                calloutReqRes.add('Non Profit Verification');
                calloutReqRes.add('FAILED'); //DUNS number match not found
                calloutReqRes.add('');
                calloutResponse.put('GuideStar-',calloutReqRes);
            System.debug('The following exception has occured: ' + e.getMessage());
            return calloutResponse;
        }
    }

    public String fetchToken() {
        String token='';
        try{
            Http http = new Http();
            HttpRequest req = new HttpRequest();
            HttpResponse res = new Httpresponse();
            //POST request to fetch the authorization token
            req.setMethod('POST');
            req.setEndpoint(apiConfigDUNS.Url__c + 'Authentication/V2.0/');
            
            //setting headers for POST
            req.setHeader('x-dnb-user', apiConfigDUNS.Username__c);
            req.setHeader('x-dnb-pwd', apiConfigDUNS.Password__c);
            req.setTimeout(50000);
            res = http.send(req);
            //access token from the POST response header
            token= res.getHeader('Authorization');
            System.debug('token--' + token);
            if(token == '' || token == null || token == 'INVALID REQUEST')
                throw new InterfaceException('Invalid Request');
            else if(token == '' || token == null || token == 'INVALID CREDENTIALS')
                throw new InterfaceException('Invalid Credentials');
        }catch(Exception e){
            System.debug('Exception in fetchToken method:'+e.getMessage());
            throw new InterfaceException(e.getMessage());
        }
        return token;
    }
    
    //Duns and Bradstreet- returns the business credit file associated with D-U-N-S Number
    //input : Authorization token and DUNS number
    //returns JSON data of the organization profile
    public Map<String, List<String>> checkDUNS(String dunsNo, String token,Map<String, List<String>> calloutResponse) {
            List<String> calloutReqRes = new List<String>();
        try {
            Http http = new Http();
            HttpRequest req = new HttpRequest();
            HttpResponse res = new Httpresponse();
        
            req.setMethod('GET');
            req.setEndPoint(apiConfigDUNS.Url__c + apiConfigDUNS.Version__c + dunsNo + apiConfigDUNS.Product_Id__c); 
            system.debug('duns and bradstreet end point:'+req.getEndpoint());
            //setting headers for GET
            req.setHeader('Authorization', token);
            req.setHeader('Content-Type', 'application/json');
            req.setTimeout(50000);
            res = http.send(req);
            
            String startDT = String.valueOf(System.today());
            String endDT = String.valueOf(System.today());
            
            Integer status = res.getStatusCode();
            String respStatus = res.getStatus();
            DAndBResponse result=processDAndBResponse(res.getBody());
            if(status == 200) {
                DAndBResponse dAndBresponse=processDAndBResponse(res.getBody());
                calloutReqRes.add(req.getBody());
                calloutReqRes.add('Dun and Bradstreet');
                calloutReqRes.add(dAndBResponseStr);
                calloutReqRes.add('DUNS Verification');
                calloutReqRes.add('SUCCESS');
                calloutReqRes.add('');
                calloutReqRes.add(startDT);
                calloutReqRes.add(endDT);                
                calloutResponse.put(dunsNo,calloutReqRes);                
                return calloutResponse;

            }
            else {
                system.debug('status not ok:'+res.getBody());
                calloutReqRes.add(req.getBody());
                calloutReqRes.add('Dun and Bradstreet');
                calloutReqRes.add(res.getStatus());
                calloutReqRes.add('DUNS Verification');
                calloutReqRes.add('SUCCESS');
                calloutReqRes.add('');
                calloutReqRes.add(startDT);
                calloutReqRes.add(endDT);                
                calloutResponse.put(dunsNo,calloutReqRes);
                return calloutResponse;

            }
            //'401 : Unauthorized. The request requires user authentication.';
            //'403 : Forbidden. The API understood the request, but is refusing to fulfill it. Most commonly, this means that the user has exceeded their request limit or does not have permissions to access this API.'; 
            //'500 : Server Error. The API encountered an unexpected condition which prevented it from fulfilling the request.';
            //'503 : Service Unavailable. The API is unavailable to handle the request due to a temporary overloading or maintenance of the server.';

        }
        catch(System.CalloutException e) {
                System.debug('The following Callout exception has occured: ' + e.getMessage());
                calloutReqRes.add('REQUEST FAILED');
                calloutReqRes.add('Dun and Bradstreet');
                calloutReqRes.add('Exception:'+e.getMessage());
                calloutReqRes.add('Dun and Bradstreet Verification');
                calloutReqRes.add('FAILED'); //DUNS number match not found
                calloutReqRes.add('');
                calloutResponse.put('Dun and Bradstreet-',calloutReqRes);
            return calloutResponse;
        } 
    }
    
    //EPLS 
    public Map<String, List<String>> checkEPLS(String samNumber,Map<String, List<String>> calloutResponse){
            List<String> calloutReqRes = new List<String>();
        try {
            Http http = new Http();
            HttpRequest req = new HttpRequest();
            HttpResponse res = new Httpresponse();
            
            req.setMethod('GET');
            req.setEndPoint('http://verifysamsexclusionlist.herokuapp.com/verify?appreference='+samNumber);
            req.setTimeout(50000);
            req.setHeader('Content-Type', 'application/json');
            res = http.send(req);
            
            String startDT = String.valueOf(System.today());
            String endDT = String.valueOf(System.today());
            Integer status = res.getStatusCode();
            String resp = res.getBody();
            String respStatus;
            JSONParser parser=null;
            SAMEPLSResponse eplsResp=null;
            parser = JSON.createParser(resp);
            while(parser.nextToken() != null) {
                if(parser.getCurrentToken() == JSONToken.FIELD_NAME) {
                    String fieldName = parser.getText();
                    System.debug('*** field Name' + fieldName);
                    parser.nextToken();
                    if(fieldName == 'status'){
                        respStatus = parser.getText();
                        break;
                    }
                }
            }
                
            if(!respStatus.equalsIgnoreCase('SAM Number doesnt exist in ExclusionList')){
                eplsResp=processSAMEPLSResponse(respStatus);
            }
            
            if(eplsResp!=null && eplsResp.isExist!=null && eplsResp.isExist) {
                
                calloutReqRes.add(req.getBody());
                calloutReqRes.add('SAM.GOV');
                calloutReqRes.add(eplsRespStr);
                calloutReqRes.add('EPLS Verification');
                calloutReqRes.add('SUCCESS');
                calloutReqRes.add('');
                calloutReqRes.add(startDT);
                calloutReqRes.add(endDT);
                calloutResponse.put(samNumber,calloutReqRes);
                return calloutResponse;
            }
            else {
                calloutReqRes.add('SAM does not exist in Exclusion List');
                calloutReqRes.add('SAM.GOV');
                calloutReqRes.add(respStatus);
                calloutReqRes.add('EPLS Verification');
                calloutReqRes.add('SUCCESS');
                calloutReqRes.add('');
                calloutReqRes.add(startDT);
                calloutReqRes.add(endDT);
                calloutResponse.put(samNumber,calloutReqRes);
                return calloutResponse;
            }
        }
        catch(System.CalloutException e) {
                calloutReqRes.add('REQUEST FAILED');
                calloutReqRes.add('SAM.GOV EPLS Verification');
                calloutReqRes.add('Exception:'+e.getMessage());
                calloutReqRes.add('EPLS Verification ');
                calloutReqRes.add('FAILURE'); //DUNS number match not found
                calloutReqRes.add('');
                calloutResponse.put('SAM.GOV EPLS-',calloutReqRes);
            System.debug('The following Callout exception has occured: ' + e.getMessage());
            return calloutResponse;
        }
    }    

    Public Map<String, List<String>> FPDSSearch(String dunsNo,Map<String, List<String>> calloutResponse){
            List<String> calloutReqRes = new List<String>();  
        try {
            Http http = new Http();
            HttpRequest req = new HttpRequest();        
            String URL = 'https://www.fpds.gov/ezsearch/FEEDS/ATOM?FEEDNAME=PUBLIC&q=';
            if(dunsNo!=null && dunsNo != ''){
                URL = URL + 'VENDOR_DUNS_NUMBER:"'+ dunsNo + EncodingUtil.urlEncode('" ', 'UTF-8');   
            }
            System.debug('URL is ' + URL);  
            req.setEndpoint(URL);
            req.setMethod('GET');
            req.setTimeout(50000);
            String startDT = String.valueOf(System.today());
            HttpResponse res = http.send(req);
            String endDT = String.valueOf(System.today());
            String xmlContent=res.getBody();
            if(res.getBody() != null || res.getBody() != '')
            {
                parse(res.getBody());
            }
            System.debug('listOfFPDS ' + listOfFPDS.size());
            
            if(listOfFPDS.size() > 0){
                FPDSData f=listOfFPDS[0];
                fpdsResponseStr+='name:'+f.name+'\n';
                fpdsResponseStr+='streetAddress:'+f.streetAddress+'\n';
                fpdsResponseStr+='city:'+f.city+'\n';
                fpdsResponseStr+='state:'+f.state+'\n';
                fpdsResponseStr+='zipCode:'+f.zipCode+'\n';
                fpdsResponseStr+='countryCode:'+f.countryCode+'\n';
                fpdsResponseStr+='principalNAICSCode'+f.principalNAICSCode+'\n';
                fpdsResponseStr+='lastModifiedDate:'+f.lastModifiedDate+'\n';
                fpdsResponseStr+='productOrServiceCode:'+f.productOrServiceCode+'\n';
                fpdsResponseStr+='annualRevenue:'+f.annualRevenue+'\n';
                
                calloutReqRes.add(req.getBody());
                calloutReqRes.add('FPDS');
                calloutReqRes.add(fpdsResponseStr);
                calloutReqRes.add('FPDS Verification');
                calloutReqRes.add('SUCCESS'); //DUNS number match found
                calloutReqRes.add('');
                calloutReqRes.add(startDT);
                calloutReqRes.add(endDT);
                calloutResponse.put('FPDS-'+dunsNo,calloutReqRes);
                return calloutResponse;            
            }
            else{
                calloutReqRes.add(req.getBody());
                calloutReqRes.add('FPDS');
                calloutReqRes.add(res.getStatus()); //res.getBody().mid(0,131070)
                calloutReqRes.add('FPDS Verification');
                calloutReqRes.add('SUCCESS'); //DUNS number match not found
                calloutReqRes.add('');
                calloutReqRes.add(startDT);
                calloutReqRes.add(endDT);
                calloutResponse.put('FPDS-'+dunsNo,calloutReqRes);
                return calloutResponse;
            }
        }
        catch(System.CalloutException e) {
                calloutReqRes.add('REQUEST FAILED');
                calloutReqRes.add('FPDS');
                calloutReqRes.add('Exception:'+e.getMessage());
                calloutReqRes.add('FPDS Verification');
                calloutReqRes.add('FAILURE'); //DUNS number match not found
                calloutReqRes.add('');
                calloutResponse.put('FPDS-',calloutReqRes);
            System.debug('The following Callout exception has occured in FPDSSearch: ' + e.getMessage());
            return calloutResponse;
        }        
        
    }        


    //Method that makes http request callout to SAM.Gov --Added by Sirisha Duriseti
    public Map<String,String> checkWithSAM(String dunsNo,String einNo){
     System.debug('einNo'+einNo);
      System.debug('dunsNo'+dunsNo);
        Map<String,String> samResponse=null;
        try{
            SAMGovEntityValidation samValidate=new SAMGovEntityValidation(); 
            if(dunsNo!=null){
                samResponse=samValidate.sendRequest(dunsNo,null,null,null,null,null); //Active registrations
                System.debug('inside dunsNo'+dunsNo);
            }else if(einNo!=null){
                samResponse=samValidate.sendRequest(null,einNo,null,null,null,null); //Active registrations
                System.debug('inside einNo'+einNo);
            }
            
        }catch(Exception e){
            samResponse.put('Exception',e.getMessage());
            System.debug('Exception'+e.getMessage());
        }
        return samResponse;
    }
    
    private String parseJSONResult(String jsonStr){
        String formattedStr='';
        JSONParser parser;
        try{
            parser = JSON.createParser(jsonStr);
            while (parser.nextToken() != null) {
                if ((parser.getCurrentToken() == JSONToken.FIELD_NAME)) {
                    formattedStr+=parser.getText()+':';
                    parser.nextToken();
                    formattedStr+= parser.getText()+'\n';
                }
            }
        }catch(Exception e){
            return e.getMessage();
        }
        return formattedStr;
    }
    
    private String parse(String toParse) {
      DOM.Document doc = new DOM.Document();      
      try {
        String result = '';
        doc.load(toParse);  
        DOM.XmlNode root = doc.getRootElement();
        DOM.XmlNode[] childNodes = doc.getRootElement().getChildElements();
        DOM.XmlNode[] entryNodes = new List<DOM.XmlNode>();
        DOM.XmlNode[] contentNodes = new List<DOM.XmlNode>();
        DOM.XmlNode[] awardNodes = new List<DOM.XmlNode>();
        DOM.XmlNode[] vendorNodes = new List<DOM.XmlNode>();
        
        //get all entry nodes
        for(DOM.XmlNode entry : childNodes) {
            if(entry.getName()=='entry')
                entryNodes.add(entry);
        }
        
        //get all content nodes
        for(DOM.XmlNode contents : entryNodes) {
            DOM.XmlNode[] contentParent = contents.getChildElements();
            for(DOM.XmlNode content : contentParent)
            {
                if(content.getName()=='content')
                    contentNodes.add(content);
            }   
        }
        
        //get all awards nodes
        for(DOM.XmlNode awards : contentNodes) {
            DOM.XmlNode[] awardParent = awards.getChildElements();
            for(DOM.XmlNode award : awardParent)
            {
                if(award.getName()=='award')
                    awardNodes.add(award);
            }   
        }
        //System.debug('##########awardNodes##########'+awardNodes);
        
        //get all vendor nodes
        for(DOM.XmlNode vendors : awardNodes) {
            if (vendors.getNodeType() == DOM.XmlNodeType.ELEMENT && vendors.getName() == 'award')
            {
                p = new FPDSData();
            }
            parsedObject(vendors);
        }   
        //System.debug('##########vendorNodes##########'+vendorNodes);
        
        return result;
        
      } catch (System.XMLException e) {  // invalid XML
        return e.getMessage();
      }
    }    

    public void parsedObject(DOM.XmlNode vendor){
        try{
        for (dom.XmlNode vendors : vendor.getchildren() ) // loop through Vendor Childs = Vendorheader, vendorLocation, vendorDUNSInformation
        {   
            for (dom.XmlNode child : vendors.getchildren() ) // loop through Vendor Childs = Vendorheader, vendorLocation, vendorDUNSInformation
            {   
                //System.debug('child is ' + child.getName());
                if (child.getname() == 'principalNAICSCode') {
                    //fpdsResponseStr+=child.getname()+':';
                    p.principalNAICSCode = child.gettext();
                }
                
                if(child.getname() == 'lastModifiedDate')
                {
                    //fpdsResponseStr+=child.getname()+':';
                    p.lastModifiedDate = child.gettext(); 
                }
                
                if(child.getname() == 'productOrServiceCode')
                {
                    //fpdsResponseStr+=child.getname()+':';
                    p.productOrServiceCode = child.gettext(); 
                }
                
                for (dom.XmlNode subchild : child.getchildren() ) 
                {   
                    for (dom.XmlNode subchildChild : subchild.getchildren() ) 
                    {
                        if (subchildChild.getname() == 'vendorName' && p!=null) {
                            //fpdsResponseStr+=subchildChild.getname()+':';
                            p.Name = subchildChild.gettext();
                        } 
                        
                        //Parse Location info 
                        if (subchildChild.getname() == 'streetAddress' && p!=null) {
                            //fpdsResponseStr+=subchildChild.getname()+':';
                            p.streetAddress = subchildChild.gettext();
                        } 
                        
                        if (subchildChild.getname() == 'city' && p!=null) {
                            //fpdsResponseStr+=subchildChild.getname()+':';
                            p.city = subchildChild.gettext();
                        }
                        
                        if (subchildChild.getname() == 'state' && p!=null) {
                            //fpdsResponseStr+=subchildChild.getname()+':';
                            p.state = subchildChild.gettext();
                        }
                        
                        if (subchildChild.getname() == 'ZIPCode' && p!=null) {
                            //fpdsResponseStr+=subchildChild.getname()+':';
                            p.zipCode = subchildChild.gettext().left(5);
                        }
                        
                        if (subchildChild.getname() == 'countryCode' && p!=null) {
                            //fpdsResponseStr+=subchildChild.getname()+':';
                            p.countryCode = subchildChild.gettext();
                        }
                        
                        //ANNUAL REVENUE 
                        if (subchildChild.getname() == 'annualRevenue' && p!=null) {
                            //fpdsResponseStr+=subchildChild.getname()+':';
                            p.annualRevenue = long.valueOf(subchildChild.gettext());
                        }
                    }
                } 
            }
        }
        
        if(p != null && p.Name != null)
        {
            listOfFPDS.add(p);
        }
        }catch(Exception e){
            System.debug('Exception in parsedObject method:'+e.getMessage());
        }

    }

    public class SAMEPLSResponse{
        public boolean isExist{get;set;}
        public String Classification{get;set;}
        public String Name{get;set;}
        public String Prefix{get;set;}
        public String FirstName{get;set;}
        public String Middle{get;set;}
        public String LastName{get;set;}
        public String Suffix{get;set;}
        public String Address1{get;set;}
        public String Address2{get;set;}
        public String Address3{get;set;}
        public String Address4{get;set;}
        public String City{get;set;}
        public String State_Province{get;set;}
        public String Country{get;set;}
        public String ZipCode{get;set;}
        public String DUNS{get;set;}
        public String ExclusionProgram{get;set;}
        public String ExcludingAgency{get;set;}
        public String CTCode{get;set;}
        public String ExclusionType{get;set;}
        public String AdditionalComments{get;set;}
        public String ActiveDate{get;set;}
        public String TerminationDate{get;set;}
        public String RecordStatus{get;set;}
        public String CrossReference{get;set;}
        public String SAMNumber{get;set;}
        public String CAGE{get;set;}
        public String NPI{get;set;}
        public String CreatedDate{get;set;}
        
    }
    public class FPDSData{
        public String name;
        public String streetAddress;
        public String city;
        public String state;
        public String zipCode;
        public String countryCode;
        public String principalNAICSCode;
        public String lastModifiedDate;
        public String productOrServiceCode;
        public Long annualRevenue;

    }
    
    
    
    
    private SAMEPLSResponse processSAMEPLSResponse(String response) {
        JSONParser parser = JSON.createParser(response);
        SAMEPLSResponse result = new SAMEPLSResponse();
        try{
        while(parser.nextToken() != null) {
            if(parser.getCurrentToken() == JSONToken.FIELD_NAME) {
                String fieldName = parser.getText();
                eplsRespStr+=fieldName+':';
                parser.nextToken();
                if(fieldName.equalsIgnoreCase('isExist')){
                    eplsRespStr+=result.isExist = Boolean.valueOf(parser.getText());
                    eplsRespStr+='\n';
                }else if(fieldName.equalsIgnoreCase('Classification')){
                    eplsRespStr+=result.Classification = parser.getText();
                    eplsRespStr+='\n';
                }else if(fieldName.equalsIgnoreCase('Name')){
                    eplsRespStr+=result.Name = parser.getText();
                     eplsRespStr+='\n';
                }else if(fieldName.equalsIgnoreCase('Prefix')){
                    eplsRespStr+=result.Prefix = parser.getText();
                    eplsRespStr+='\n';
                }else if(fieldName.equalsIgnoreCase('FirstName')){
                    eplsRespStr+=result.FirstName = parser.getText();
                     eplsRespStr+='\n';
                }else if(fieldName.equalsIgnoreCase('Middle')){
                    eplsRespStr+=result.Middle = parser.getText();
                    eplsRespStr+='\n';
                }else if(fieldName.equalsIgnoreCase('LastName')){
                    eplsRespStr+=result.LastName = parser.getText();
                    eplsRespStr+='\n';
                }else if(fieldName.equalsIgnoreCase('Suffix')){
                    eplsRespStr+=result.Suffix = parser.getText();
                    eplsRespStr+='\n';
                }
                else if(fieldName.equalsIgnoreCase('Address1')){
                    eplsRespStr+=result.Address1 = parser.getText();
                     eplsRespStr+='\n';
                }else if(fieldName.equalsIgnoreCase('Address2')){
                    eplsRespStr+=result.Address2 = parser.getText();
                     eplsRespStr+='\n';
                }else if(fieldName.equalsIgnoreCase('Address3')){
                    eplsRespStr+=result.Address3 = parser.getText();
                    eplsRespStr+='\n';
                }else if(fieldName.equalsIgnoreCase('Address4')){
                    eplsRespStr+=result.Address4 = parser.getText();
                    eplsRespStr+='\n'; 
                }else if(fieldName.equalsIgnoreCase('City')){
                    eplsRespStr+=result.City = parser.getText();
                     eplsRespStr+='\n';
                }else if(fieldName.equalsIgnoreCase('State_Province')){
                    eplsRespStr+=result.State_Province = parser.getText();
                     eplsRespStr+='\n';
                }else if(fieldName.equalsIgnoreCase('Country')){
                    eplsRespStr+=result.Country = parser.getText();
                    eplsRespStr+='\n';
                }else if(fieldName.equalsIgnoreCase('ZipCode')){
                    eplsRespStr+=result.ZipCode = parser.getText();
                     eplsRespStr+='\n';
                }else if(fieldName.equalsIgnoreCase('DUNS')){
                    eplsRespStr+=result.DUNS = parser.getText();
                    eplsRespStr+='\n';
                }else if(fieldName.equalsIgnoreCase('ExclusionProgram')){
                    eplsRespStr+=result.ExclusionProgram = parser.getText();
                     eplsRespStr+='\n';
                }else if(fieldName.equalsIgnoreCase('ExcludingAgency')){
                    eplsRespStr+=result.ExcludingAgency = parser.getText();
                    eplsRespStr+='\n';
                }else if(fieldName.equalsIgnoreCase('CTCode')){
                    eplsRespStr+=result.CTCode = parser.getText();
                    eplsRespStr+='\n';
                }else if(fieldName.equalsIgnoreCase('ExclusionType')){
                    eplsRespStr+=result.ExclusionType = parser.getText();
                    eplsRespStr+='\n';
                }else if(fieldName.equalsIgnoreCase('AdditionalComments')){
                    eplsRespStr+=result.AdditionalComments = parser.getText();
                    eplsRespStr+='\n'; 
                }else if(fieldName.equalsIgnoreCase('ActiveDate')){
                    eplsRespStr+=result.ActiveDate = parser.getText();
                    eplsRespStr+='\n';
                }else if(fieldName.equalsIgnoreCase('TerminationDate')){
                    eplsRespStr+=result.TerminationDate = parser.getText();
                    eplsRespStr+='\n'; 
                }else if(fieldName.equalsIgnoreCase('RecordStatus')){
                    eplsRespStr+=result.RecordStatus = parser.getText();
                    eplsRespStr+='\n';
                }else if(fieldName.equalsIgnoreCase('CrossReference')){
                    eplsRespStr+=result.CrossReference = parser.getText();
                    eplsRespStr+='\n';
                }else if(fieldName.equalsIgnoreCase('SAMNumber')){
                    eplsRespStr+=result.SAMNumber = parser.getText();
                    eplsRespStr+='\n';
                }else if(fieldName.equalsIgnoreCase('CAGE')){
                    eplsRespStr+=result.CAGE = parser.getText();
                    eplsRespStr+='\n';
                }else if(fieldName.equalsIgnoreCase('NPI')){
                    eplsRespStr+=result.NPI = parser.getText();
                    eplsRespStr+='\n';
                }else if(fieldName.equalsIgnoreCase('CreatedDate')){
                    eplsRespStr+=result.CreatedDate = parser.getText();
                    eplsRespStr+='\n';
                }
            }

        }
        }catch(Exception e){
            System.debug('Exception in processSAMEPLSResponse method: '+e.getMessage());
        }
        return result;      
    }
    
    
    
    
    private EINResponse processEINResponse(String response) {
        JSONParser parser = JSON.createParser(response);
        
        EINResponse result = new EINResponse();
        try{
        while(parser.nextToken() != null) {
            if(parser.getCurrentToken() == JSONToken.FIELD_NAME) {
                String fieldName = parser.getText();
                parser.nextToken();
                guideStarResponseStr+=fieldName+':';
                if(fieldName == 'ein'){
                    guideStarResponseStr+=result.ein = parser.getText();
                    guideStarResponseStr+='\n';
                }else if(fieldName == 'organization_name'){
                    guideStarResponseStr+=result.organization_name = parser.getText();
                    guideStarResponseStr+='\n';
                }else if(fieldName == 'organization_id'){
                    guideStarResponseStr+=result.organization_id = parser.getText(); 
                    guideStarResponseStr+='\n'; 
                }else if(fieldName == 'address_line1'){
                    guideStarResponseStr+=result.address_line1 = parser.getText(); 
                    guideStarResponseStr+='\n'; 
                }else if(fieldName == 'address_line2'){
                    guideStarResponseStr+=result.address_line2 = parser.getText();
                    guideStarResponseStr+='\n';
                }else if(fieldName == 'city'){
                    guideStarResponseStr+=result.city = parser.getText();
                    guideStarResponseStr+='\n';
                }else if(fieldName == 'state'){
                    guideStarResponseStr+=result.state = parser.getText();
                    guideStarResponseStr+='\n';
                }else if(fieldName == 'zip'){
                    guideStarResponseStr+=result.zip = parser.getText();
                    guideStarResponseStr+='\n';
                }else if(fieldName == 'zip4'){
                    guideStarResponseStr+=result.zip4 = parser.getText();
                    guideStarResponseStr+='\n';
                }else if(fieldName == 'affiliation_code'){
                    guideStarResponseStr+=result.affiliation_code = parser.getText();
                    guideStarResponseStr+='\n';
                }else if(fieldName == 'affiliation_code_description'){
                    guideStarResponseStr+=result.affiliation_code_description = parser.getText(); 
                    guideStarResponseStr+='\n';
                }else if(fieldName == 'aka_organization_name'){
                    guideStarResponseStr+=result.aka_organization_name = parser.getText(); 
                    guideStarResponseStr+='\n'; 
                }else if(fieldName == 'deductibility_code'){
                    guideStarResponseStr+=result.deductibility_code = parser.getText(); 
                    guideStarResponseStr+='\n'; 
                }else if(fieldName == 'deductibility_code_description'){
                    guideStarResponseStr+=result.deductibility_code_description = parser.getText();  
                    guideStarResponseStr+='\n';
                }else if(fieldName == 'foundation_code'){
                    guideStarResponseStr+=result.foundation_code = parser.getText(); 
                    guideStarResponseStr+='\n'; 
                }else if(fieldName == 'foundation_code_description'){
                    guideStarResponseStr+=result.foundation_code_description = parser.getText(); 
                    guideStarResponseStr+='\n';
                }else if(fieldName == 'group_exemption'){
                    guideStarResponseStr+=result.group_exemption = parser.getText(); 
                    guideStarResponseStr+='\n'; 
                }else if(fieldName == 'income_total'){
                    guideStarResponseStr+=result.income_total = parser.getText(); 
                    guideStarResponseStr+='\n';
                }else if(fieldName == 'subsection_code'){
                    guideStarResponseStr+=result.subsection_code = parser.getText();
                    guideStarResponseStr+='\n';  
                }else if(fieldName == 'subsection_code_description'){
                    guideStarResponseStr+=result.subsection_code_description = parser.getText(); 
                    guideStarResponseStr+='\n';
                }else if(fieldName == 'mission'){
                    guideStarResponseStr+=result.mission = parser.getText();  
                    guideStarResponseStr+='\n';
                }
            }
        }
        }catch(Exception e){
            System.debug('Exception in processEINResponse method:'+e.getMessage());
        }
        return result;      
    }
    
    
    private DAndBResponse processDAndBResponse(String response) {
        JSONParser parser = JSON.createParser(response);
        DAndBResponse result = new DAndBResponse();
        List<SalesRevenueAmount> salesList=new List<SalesRevenueAmount>();
        try{
        while(parser.nextToken() != null) {
            if(parser.getCurrentToken() == JSONToken.FIELD_NAME) {
                String fieldName = parser.getText();
                dAndBResponseStr+=fieldName+':';
                parser.nextToken();
                if(fieldName.equalsIgnoreCase('@ServiceVersionNumber')){
                    result.ServiceVersionNumber = parser.getText();
                    dAndBResponseStr+=result.ServiceVersionNumber;
                    dAndBResponseStr+='\n';
                }else if(fieldName.equalsIgnoreCase('applicationTransactionID')){
                    result.applicationTransactionID = parser.getText();
                    dAndBResponseStr+=result.applicationTransactionID;
                    dAndBResponseStr+='\n';
                }else if(fieldName.equalsIgnoreCase('serviceTransactionID')){
                    result.serviceTransactionID = parser.getText();
                    dAndBResponseStr+=result.serviceTransactionID;
                    dAndBResponseStr+='\n';
                }else if(fieldName.equalsIgnoreCase('transactionTimestamp')){
                    result.transactionTimestamp = parser.getText();
                    dAndBResponseStr+=result.transactionTimestamp;
                    dAndBResponseStr+='\n';
                }else if(fieldName.equalsIgnoreCase('severityText')){
                    result.severityText = parser.getText();
                    dAndBResponseStr+=result.severityText;
                    dAndBResponseStr+='\n';
                }else if(fieldName.equalsIgnoreCase('resultID')){
                    result.resultID = parser.getText();
                    dAndBResponseStr+=result.resultID;
                    dAndBResponseStr+='\n';
                }else if(fieldName.equalsIgnoreCase('resultText')){
                    result.resultText = parser.getText();
                    dAndBResponseStr+=result.resultText;
                    dAndBResponseStr+='\n';
                }else if(fieldName.equalsIgnoreCase('dUNSNumber')){
                    result.dUNSNumber = parser.getText();
                    dAndBResponseStr+=result.dUNSNumber;
                    dAndBResponseStr+='\n';
                }else if(fieldName.equalsIgnoreCase('countryISOAlpha2Code')){
                    result.countryISOAlpha2Code = parser.getText();
                    dAndBResponseStr+=result.countryISOAlpha2Code;
                    dAndBResponseStr+='\n';
                }else if(fieldName.equalsIgnoreCase('dNBProductID')){
                    result.dNBProductID = parser.getText();
                    dAndBResponseStr+=result.dNBProductID;
                    dAndBResponseStr+='\n';
                }else if(fieldName.equalsIgnoreCase('organizationSummaryText')){
                    result.organizationSummaryText = parser.getText();
                    dAndBResponseStr+=result.organizationSummaryText;
                    dAndBResponseStr+='\n';
                }else if(fieldName.equalsIgnoreCase('LastUpdateDate')){
                    System.debug('inside last update Date parser------------------------'+parser.getText());
                    parser.nextToken();
                    if(parser.getCurrentName().equalsIgnoreCase('$')){
                        parser.nextToken();
                        result.LastUpdateDate_value = parser.getText();
                        dAndBResponseStr+=result.LastUpdateDate_value;
                        dAndBResponseStr+='\n';
                    }
                } 
                else if(fieldName.equalsIgnoreCase('marketabilityIndicator')){
                    result.marketabilityIndicator = Boolean.valueOf(parser.getText());
                    dAndBResponseStr+=result.marketabilityIndicator;
                    dAndBResponseStr+='\n';
                }else if(fieldName.equalsIgnoreCase('transferredFromDUNSNumber')){
                    result.transferredFromDUNSNumber = parser.getText();
                    dAndBResponseStr+=result.transferredFromDUNSNumber;
                    dAndBResponseStr+='\n';
                }else if(fieldName.equalsIgnoreCase('transferredToDUNSNumber')){
                    result.transferredToDUNSNumber = parser.getText();
                    dAndBResponseStr+=result.transferredToDUNSNumber;
                    dAndBResponseStr+='\n';
                }else if(fieldName.equalsIgnoreCase('TransferDate')){
                    System.debug('inside last update Date parser------------------------'+parser.getText());
                    parser.nextToken();
                    if(parser.getCurrentName().equalsIgnoreCase('$')){
                        parser.nextToken();
                        dAndBResponseStr+=result.TransferDate_value = parser.getText();
                        dAndBResponseStr+='\n';
                    }
                }
                else if(fieldName.equalsIgnoreCase('@DNBCodeValue')){
                    dAndBResponseStr+=result.DNBCodeValue = Long.valueOf(parser.getText());
                    dAndBResponseStr+='\n';
                }
                else if(fieldName.equalsIgnoreCase('TransferReasonText')){
                    while(parser.nextToken() != null) {
                        if(parser.getCurrentName().equalsIgnoreCase('$')){
                            parser.nextToken();
                            dAndBResponseStr+=result.TransferReasonText_value = parser.getText();
                            dAndBResponseStr+='\n';
                            break;
                        }
                    }
                }
                else if(fieldName.equalsIgnoreCase('SalesRevenueAmount')){
                    SalesRevenueAmount s=new SalesRevenueAmount();
                    while(parser.nextToken() != null) {
                        if(parser.getCurrentToken() == JSONToken.FIELD_NAME && parser.getCurrentName()=='@CurrencyISOAlpha3Code') {
                            parser.nextToken();
                            s.CurrencyISOAlpha3Code = parser.getText();
                            dAndBResponseStr+=s.CurrencyISOAlpha3Code;
                            dAndBResponseStr+='\n';
                        }else if(parser.getCurrentToken() == JSONToken.FIELD_NAME && parser.getCurrentName()=='@ReliabilityText') {
                            parser.nextToken();
                            s.ReliabilityText= parser.getText();
                            dAndBResponseStr+=s.ReliabilityText;
                            dAndBResponseStr+='\n';
                        }else if(parser.getCurrentToken() == JSONToken.FIELD_NAME && parser.getCurrentName()=='@UnitOfSize') {
                            parser.nextToken();
                            s.UnitOfSize=parser.getText();
                            dAndBResponseStr+=s.UnitOfSize;
                            dAndBResponseStr+='\n';
                        }else if(parser.getCurrentToken() == JSONToken.FIELD_NAME && parser.getCurrentName()=='$') {
                            parser.nextToken();
                            s.amount=parser.getText();
                            dAndBResponseStr+=s.amount;
                            dAndBResponseStr+='\n';
                        }
                    }
                    salesList.add(s);
                    result.salesRevenueAmt=salesList;
                }
                else if(fieldName.equalsIgnoreCase('telecommunicationNumber')){
                    result.telecommunicationNumber = parser.getText();
                    dAndBResponseStr+=result.telecommunicationNumber;
                    dAndBResponseStr+='\n';
                }else if(fieldName.equalsIgnoreCase('internationalDialingCode')){
                    result.internationalDialingCode = parser.getText();
                    dAndBResponseStr+=result.internationalDialingCode;
                    dAndBResponseStr+='\n';
                }else if(fieldName.equalsIgnoreCase('unreachableIndicator')){
                    result.unreachableIndicator = Boolean.valueOf(parser.getText());
                    dAndBResponseStr+=result.unreachableIndicator;
                    dAndBResponseStr+='\n';
                }else if(fieldName.equalsIgnoreCase('primaryTownName')){
                    result.primaryTownName = parser.getText();
                    dAndBResponseStr+=result.primaryTownName; 
                    dAndBResponseStr+='\n';
                }else if(fieldName.equalsIgnoreCase('territoryAbbreviatedName')){
                    result.territoryAbbreviatedName = parser.getText();
                    dAndBResponseStr+=result.territoryAbbreviatedName;
                    dAndBResponseStr+='\n';
                }else if(fieldName.equalsIgnoreCase('postalCode')){
                    result.postalCode = parser.getText();
                    dAndBResponseStr+=result.postalCode;
                    dAndBResponseStr+='\n'; 
                }else if(fieldName.equalsIgnoreCase('countyOfficialName')){
                    result.countyOfficialName = parser.getText();
                    dAndBResponseStr+=result.countyOfficialName;
                    dAndBResponseStr+='\n';
                }else if(fieldName.equalsIgnoreCase('territoryOfficialName')){
                    result.territoryOfficialName = parser.getText();
                    dAndBResponseStr+=result.territoryOfficialName;
                    dAndBResponseStr+='\n';
                }else if(fieldName.equalsIgnoreCase('countryGroupName')){
                    result.countryGroupName = parser.getText();
                    dAndBResponseStr+=result.countryGroupName;
                    dAndBResponseStr+='\n';
                }else if(fieldName.equalsIgnoreCase('undeliverableIndicator')){
                    result.undeliverableIndicator = Boolean.valueOf(parser.getText());
                    dAndBResponseStr+=result.undeliverableIndicator;
                    dAndBResponseStr+='\n';
                }else if(fieldName.equalsIgnoreCase('registeredAddressIndicator')){
                    result.registeredAddressIndicator = Boolean.valueOf(parser.getText());
                    dAndBResponseStr+=result.registeredAddressIndicator;
                    dAndBResponseStr+='\n';
                }else if(fieldName.equalsIgnoreCase('residentialAddressIndicator')){
                    result.residentialAddressIndicator = Boolean.valueOf(parser.getText());
                    dAndBResponseStr+=result.residentialAddressIndicator;
                    dAndBResponseStr+='\n';
                }
            }
        } 
        }catch(Exception e){
            System.debug('Exception in processDAndBResponse method:'+e.getMessage());
        }    
        return result; 
    }
    
      class SalesRevenueAmount{
            String CurrencyISOAlpha3Code;
            String ReliabilityText;
            String UnitOfSize;
            String amount;
      }
      
      class DAndBResponse {
        public List<SalesRevenueAmount> salesRevenueAmt;
         // OrderProductResponse {
        public  String ServiceVersionNumber;
       //TransactionDetail {
        public  String applicationTransactionID;
        public  String serviceTransactionID;
        public  String transactionTimestamp;
        // TransactionResult {
        public  String severityText;
        public  String resultID;
        public  String resultText;
        //InquiryDetail {
        public  String dUNSNumber;
        public  String countryISOAlpha2Code;
        // Product {
        public  String dNBProductID;
        public   String languageCode;
    //SubjectHeader {
        public  String organizationSummaryText;
        //LastUpdateDate
        public   String LastUpdateDate_value;
        public  boolean marketabilityIndicator;
      // TransferDUNSNumberRegistration {
        public  String transferredFromDUNSNumber;
        public  String transferredToDUNSNumber;
        // class TransferDate {
        public  String TransferDate_value;
       //TransferReasonText {
        public  long DNBCodeValue;
        public  String TransferReasonText_value;
    // TelephoneNumber {
        public  String telecommunicationNumber;
        public  String internationalDialingCode;
        public  boolean unreachableIndicator;
    //PrimaryAddres {
        public  String primaryTownName;
        public  String territoryAbbreviatedName;
        public  String postalCode;
        public  String countyOfficialName;
        public  String territoryOfficialName;
        public  String countryGroupName;
        public  boolean undeliverableIndicator;
        public  boolean registeredAddressIndicator;
        public  boolean residentialAddressIndicator;
        //StreetAddressLine {
        public  String lineText;
    // TenureTypeText {
        public  String TenureTypeText_value;
    //StatementHeaderDetails {
        public  String financialPeriodDuration;
   //FinancialStatementToDate {
        public  String FinancialStatementToDate_value;
   //SalesRevenueAmount {
        public  String CurrencyISOAlpha3Code;
        public  String ReliabilityText;
        public  String UnitOfSize;
        public  long SalesRevenueAmount_value;
        //OrganizationName {
        public  String OrganizationName_value;
  // OrganizationDetail {
        public  boolean standaloneOrganizationIndicator;
        public  String organizationStartYear;
   //FamilyTreeMemberRoleText {
        public  String FamilyTreeMemberRoleText_value;
    //ControlOwnershipDate {
        public  String ControlOwnershipDate_value;
        // ControlOwnershipTypeText {
        public  String ControlOwnershipTypeText_value;
        // OperatingStatusText {
        public  String OperatingStatusText_value;
        //RegisteredDetail {
        public  String incorporationYear;
// OrganizationIdentificationNumberDetail {
        public  String OrganizationIdentificationNumberDetail_TypeText;
        public  String organizationIdentificationNumber;
   //IndustryCode {
        public  String IndustryCode_TypeText;
        public  long displaySequence;
        public  long salesPercentage;
       //IndustryCode {
        public  String IndustryCode_value;
        //IndustryCodeDescription {
        public  long IndustryCodeDescriptionLengthCode;
        public  String IndustryCodeDescription_value;
       // ActivitiesAndOperations {
        public  String primarySICCategoryValue;
        //LineOfBusinessDescription {
        public  String LineOfBusinessDescription_value;
    //ConsolidatedEmployeeDetails {
        public  long totalEmployeeQuantity;
    // EmployeeBasisText {
        public  String EmployeeBasisText_value;
    // ReliabilityText {
        public  String ReliabilityText_value;
  //class LinkageSummary {
        public  long globalUltimateFamilyTreeLinkageCount;
//PrincipalName
        public  String PrincipalName_type;
        public  String fullName;
    //JobTitleText
        public  String JobTitleText_value;//
         //PrincipalIdentificationNumberDetail                   
        public  String principalIdentificationNumber;
        //SocioEconomicIdentification
        public  boolean minorityOwnedIndicator;
        public  boolean smallBusinessIndicator;
        public  boolean laborSurplusAreaIndicator;
        //EthnicityTypeText
        public  String EthnicityTypeText_value;
   //InquiryReferenceDetail
        public  String[] customerReferenceText;
        public  String customerBillingEndorsementText;
        
}
public static void calculate(Integer i){

    }


}