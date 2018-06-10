/*
* Mock response for class ExternalInterfaceCtrl.
* @author: Sarat Mahavratayajula. 2016-08-01
* This class retruns the mock response to ExternalInterfaceCtrl when 
* http remote call is invoked.
*/
@isTest
global class MockExternalInterfaceCtrlResponse implements HttpCalloutMock {
    
    public static String indicator;
    public static String indicatorHeader;
    public static String indicatorStatus;
    
    global HttpResponse respond(HttpRequest request) {
        String userName = 'myname';
        String password = 'mypwd';
        Blob headerValue = Blob.valueOf(username + ':' + password);
        String authorizationHeader = 'BASIC ' + EncodingUtil.base64Encode(headerValue);
        system.debug('*** my header' + authorizationHeader);
        HttpResponse res = new HttpResponse();
            if (indicatorHeader.equals('json')) {
                res.setHeader('Content-Type', 'application/json');
            }
            if (indicatorHeader.equals('urlencoded')) {
                res.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            }
            
           
            if(indicatorStatus.contains('SAM Number exist in ExclusionList')) { 
                system.debug('in sam.gov epls resp------');
                res.setBody('{"appreference":"S4MR4BL9Y","status":"{\"country\":\"XUN\",\"lastName\":\"\",\"zipCode\":\"\",\"city\":\"\",\"NPI\":\"\",\"prefix\":\"\",\"crossReference\":\"(also INVERSIONES TURISTICAS JOYA GRANDE, S.A. DE C.V.)\",\"exclusionType\":\"Prohibition/Restriction\",\"suffix\":\"\",\"terminationDate\":\"Indefinite\",\"activeDate\":\"\",\"address4\":\"\",\"isExist\":true,\"CAGE\":\"\",\"middle\":\"\",\"address3\":\"\",\"address2\":\"\",\"exclusionProgram\":\"Reciprocal\",\"address1\":\"\",\"excludingAgency\":\"TREAS-OFAC\",\"CTCode\":\"03-SDNTK-01\",\"classification\":\"Special Entity Designation\",\"state_Province\":\"\",\"SAMNumber\":\"S4MR4BL9Y\",\"firstName\":\"\",\"additionalComments\":\"PII data has been masked from view\",\"createdDate\":\"Thu Sep 07 07:32:54 UTC 2017\",\"recordStatus\":\"\",\"DUNS\":\"\",\"name\":\"Special Entity Designation\"}"}'); 
            }
            
            if(indicatorStatus.contains('XML')) { 
                res.setBody('<books><entry>My Book</entry><entry>Your Book</entry></books>');
            }   
            res.setStatus('Pass'); 
            res.setHeader('Authorization',authorizationHeader);
            if(indicator.equals('200')){
                system.debug('*** I am here 1');
                res.setStatusCode(200);
            }
            if(indicator.equals('500')){
                system.debug('*** I am here 2');
                res.setStatusCode(500);
            }
            if(indicatorStatus.contains('SAMEntity')) {
                res.setStatusCode(200);
                res.setBody('<entity>Valid</entity>');
                system.debug('in sam.gov entity resp------');
            }
            
            return res;
    }
}