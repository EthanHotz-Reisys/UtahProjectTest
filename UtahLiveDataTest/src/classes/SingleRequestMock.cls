@isTest
global class SingleRequestMock implements HttpCalloutMock {

    String entity='',status='success';
    String response='',failurResp='FAILED';
    
    global SingleRequestMock (String entity,String status){
        this.entity=entity;
        this.status=status;
    }
    
         // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
         HttpResponse res=new HttpResponse();
         system.debug('entity-in http response----------------------'+entity);
         if(entity=='auth'){
             res.setHeader('Authorization', 'asdlkfjalsdjflaksdjfajsdf');
             response='asdflaksjdfljasldfjlasdfj';
         }else {
             response='{"":{"TransactionDetail":{"ApplicationTransactionID":null,"TransactionTimestamp":null},"TransactionResult":{"SeverityText":"Error","ResultID":"PD005","ResultText":"Requested Product not available."}}}';
         }
         if(status=='success'){
            res.setBody(response);
            res.setStatusCode(200);
         }else{
            res.setBody(failurResp);
            res.setStatusCode(404);
         }
         
         res.setStatus(status);

         System.debug('printing the body response n testmock-----------------------'+res.getBody());
         System.debug('printing the response n testmock-----------------------'+res.getXmlStreamReader());
         return res;
    }
    
}