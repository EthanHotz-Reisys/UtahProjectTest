@isTest
public class Integ_DocumentStatusMock implements HttpCalloutMock {

    protected Integer code;
    protected String body;
    protected boolean calloutException;

    public Integ_DocumentStatusMock(Integer statusCode, boolean calloutException, String type) {
        this.code = statusCode;
        
        if (type == 'GCAM') {
            this.body = '[{"DOC_DEPT_CD":"400","DOC_PHASE_NM":"Draft","DOC_ID":"180000000000137","DOC_STA_CD":3,"DOC_VERS_NO":1,"DOC_STA_NM":"Rejected","DOC_CD":"GCAM","DOC_DSCR":"(GovGrants Unique Record ID,F5414B3E9025B33A81594D023AB784)","DOC_PHASE_CD":1}]';
        } else if (type == 'GAX') {
            this.body = '[{"DOC_DEPT_CD":"400","DOC_PHASE_NM":"Draft","DOC_ID":"180000000000137","DOC_STA_CD":3,"DOC_VERS_NO":1,"DOC_STA_NM":"Rejected","DOC_CD":"GAX","DOC_DSCR":"(GovGrants Unique Record ID,F5414B3E9025B33A81594D023AB784)","DOC_PHASE_CD":1}]';
        } else { //Assume IET
            this.body = '[{"DOC_DEPT_CD":"400","DOC_PHASE_NM":"Draft","DOC_ID":"180000000000137","DOC_STA_CD":3,"DOC_VERS_NO":1,"DOC_STA_NM":"Rejected","DOC_CD":"IET","DOC_DSCR":"(GovGrants Unique Record ID,F5414B3E9025B33A81594D023AB784)","DOC_PHASE_CD":1}]';
        }
        this.calloutException = calloutException;
    }

    public HTTPResponse respond(HTTPRequest req) {
        if (calloutException) {
            CalloutException e = new CalloutException();
            e.setMessage('Timeout message');
            throw e;
        } else {
            HttpResponse res = new HttpResponse();
            res.setBody(this.body);
            res.setStatusCode(this.code);
            return res;
        }
        
    }

}