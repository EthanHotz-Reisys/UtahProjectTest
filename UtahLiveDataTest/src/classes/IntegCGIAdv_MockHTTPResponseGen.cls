@isTest
public class IntegCGIAdv_MockHTTPResponseGen implements HttpCalloutMock{
    public String exceptionMessage{get;set;}
    private Boolean isException{get;set;}
    private Exception exceptionToCast{get;set;}
    private String scenario;
    public IntegCGIAdv_MockHTTPResponseGen(){ throwNullPointerException( 'Values must be provided for: scenario or exception' ); }
    public IntegCGIAdv_MockHTTPResponseGen( String scenario ){
        this.scenario = scenario;
        this.isException = false;
    }
    public IntegCGIAdv_MockHTTPResponseGen( String exceptionMessage, boolean isException ){
        this.exceptionMessage = exceptionMessage;
        this.isException = isException;
    }
    // Implement this interface method
    public HTTPResponse respond( HTTPRequest req ) {
        System.debug('HTTP response: ' + req.getEndpoint());
        System.debug(req.getEndpoint().contains('unit/query' ));
        //System.debug(req.getEndpoint().split('?')[0].
        if( isException != null && isException ){ 
            if (exceptionMessage.contains('callout')) {
                CalloutException npe = new CalloutException();
                npe.setMessage( this.exceptionMessage );
                throw npe;
            } else {
                throwNullPointerException(exceptionMessage);
            }
        }
        HttpResponse res = new HttpResponse();
        if( scenario != null && scenario.length() > 0 ){
            if( scenario.toUpperCase() == 'A' ){
                if( req.getEndpoint().contains('appr/query' )){
                    res.setBody('[{"APPR_CD":"QLE","APPR_NM":"UCAT Performance Funding","FY":2018},{"APPR_CD":"QKD","APPR_NM":"SLCC Technical College","FY":200}]');
                    res.setStatusCode(200);
                }else if( req.getEndpoint().contains( 'fund/query' )){
                    res.setBody('[{"FUND_NM":"(DHS) Account for People with Disabilities","FUND_CD":"1114","FY":2018},{"FUND_NM":"(FIN) Federal Commodities","FUND_CD":"1323","FY":201}]');
                    res.setStatusCode(200);
                }else if( req.getEndpoint().contains('funding-inference-profile/query' )){
                    res.setBody('[{"FPRFL_CD":"UTGRNT","DEPT_CD":"400","MJR_PROG_CD":"UTGRNT","FPRFL_NM":"Utah Grants"},{"FPRFL_CD":"FP1","DEPT_CD":"600","MJR_PROG_CD":"MJPP","FPRFL_NM":"FP1"}]');
                    res.setStatusCode(200);
                }else if( req.getEndpoint().contains('major-program/query' )){
                    res.setBody('[{ "REIM_BAS_IND": 1,"ALW_BUD_FL": 1,"ACT_FL": 1, "DEPT_CD": "400", "MJR_PROG_CD": "0100", "MJR_PROG_NM": "USBE","REIM_BUD_STRU_CD": null,"SUSP_STA": 1,"FED_APPR_SETP": 1, "SPLT_IND": 3,"MJR_PROG_SH_NM": "USBE", "EFBGN_DT": null,"EFEND_DT": null, "TBL_LAST_DT": "2017-08-04T20:12:55.000Z"},{ "REIM_BAS_IND": 1,"ALW_BUD_FL": 1,"ACT_FL": 1, "DEPT_CD": "999", "MJR_PROG_CD": "0100", "MJR_PROG_NM": "USBE","REIM_BUD_STRU_CD": null,"SUSP_STA": 1,"FED_APPR_SETP": 1, "SPLT_IND": 3,"MJR_PROG_SH_NM": "USBE", "EFBGN_DT": null,"EFEND_DT": null, "TBL_LAST_DT": "2017-08-04T20:12:55.000Z"}]');
                    res.setStatusCode(200);
                }else if( req.getEndpoint().contains( 'obj/query')){
                    res.setBody('[{"OBJ_SH_NM":"Otr Cn/Serc","OBJ_CD":"6154","FY":2018},{"OBJ_SH_NM":"Pr/Tch Serv","OBJ_CD":"6155","FY":201}]');
                    res.setStatusCode(200);
                }else if( req.getEndpoint().contains( 'program/query' )){
                    res.setBody('[{"DEPT_CD": "400","PROG_CD": "17DEC", "MJR_PROG_CD": "0100", "PROG_NM": "Administration FFY2017","ACT_FL": 1,"PROG_SH_NM": "17DEC", "ALW_BUD_FL": 1, "REIM_ELG_STA": 1, "PCLS_CD": "FED",  "PCAT_CD": "PROG", "PGRP_CD": "BD","PTYP_CD": "MD", "SUSP_STA": 2,"PROG_DSRC": null, "SITE_LOC_CD": null, "EFBGN_DT": "2016-07-01T06:00:00.000Z", "EFEND_DT": null,  "TBL_LAST_DT": "2018-01-09T23:07:28.000Z"},{"DEPT_CD": "999","PROG_CD": "17DEC", "MJR_PROG_CD": "0100", "PROG_NM": "Administration FFY2017","ACT_FL": 1,"PROG_SH_NM": "17DEC", "ALW_BUD_FL": 1, "REIM_ELG_STA": 1, "PCLS_CD": "FED",  "PCAT_CD": "PROG", "PGRP_CD": "BD","PTYP_CD": "MD", "SUSP_STA": 2,"PROG_DSRC": null, "SITE_LOC_CD": null, "EFBGN_DT": "2016-07-01T06:00:00.000Z", "EFEND_DT": null,  "TBL_LAST_DT": "2018-01-09T23:07:28.000Z"}]');
                    res.setStatusCode(200);
                }else if( req.getEndpoint().contains('program/category/query' )){
                    res.setBody('[{"PCAT_CD":"PROG","PCAT_SH_NM":"Ops","PCAT_NM":"Operations"}, {"PCAT_CD":null,"PCAT_SH_NM":"Ops","PCAT_NM":"Operations"}]');
                    res.setStatusCode(200);
                }else if( req.getEndpoint().contains( 'program/class/query' )){
                    res.setBody('[{"PCLS_SH_NM":"FED","PCLS_CD":"FED","PCLS_NM":"Federal"},{"PCLS_SH_NM":"STATE","PCLS_CD":null,"PCLS_NM":"State"}]');
                    res.setStatusCode(200);
                }else if( req.getEndpoint().contains( 'program/group/query')){
                    res.setBody('[{"DEPT_CD":"400","PGRP_SH_NM":"Blind","PGRP_NM":"Blind","PGRP_CD":"BD"},{"DEPT_CD":"999","PGRP_SH_NM":"Deaf","PGRP_NM":"Deaf","PGRP_CD":"DF"}]');
                    res.setStatusCode(200);
                }else if( req.getEndpoint().contains( 'program/type/query' )){
                    res.setBody('[{"PTYP_NM":"Medicaid","PTYP_SH_NM":"Medicaid","PTYP_CD":"MD","DEPT_CD":"400"},{"PTYP_NM":"Medicaid","PTYP_SH_NM":"Medicaid","PTYP_CD":"MD","DEPT_CD":"999"}]');
                    res.setStatusCode(200);
                }else if( req.getEndpoint().contains('subrecipient/query' )){
                    res.setBody('[{"LGL_NM":"CAMP HOBE INC","DUNS_NO":"010600561","TIN":"571149391","VEND_CUST_CD":"100218A"},{"LGL_NM":"CAMP HOBE INC","DUNS_NO":"010600561","TIN":"571149391","VEND_CUST_CD":null}]');
                    res.setStatusCode(200);
                }else if( req.getEndpoint().contains( 'subrecipient/address/query' )){
                    res.setBody('[{"AD_TYP":"PA","STR_1_NM":"1170 State Office Blvd","PRIN_CNTAC":"CB TRAVEL CORP","STR_2_NM":null,"CTRY":"US","AD_ID":"00","VOICE_PH_NO":"801-327-7747","VEND_CUST_CD":"100218A","CITY_NM":"SALT LAKE CITY","ZIP":"84114-1205","ST":"UT"}, {"AD_TYP":null,"STR_1_NM":null,"PRIN_CNTAC":null,"STR_2_NM":null,"CTRY":null,"AD_ID":null,"VOICE_PH_NO":null,"VEND_CUST_CD":null,"CITY_NM":null,"ZIP":null,"ST":null}]');
                    res.setStatusCode(200);
                }else if( req.getEndpoint().contains('unit/query' )){
                    System.debug('Unit endpoint set');
                    res.setBody('[{"DEPT_CD":"400","UNIT_NM":"Blind Schools","UNIT_CD":"5200","FY":2018}, {"DEPT_CD":"999","UNIT_NM":"Blind Schools","UNIT_CD":"5200","FY":2018}]');
                    res.setStatusCode(200);
                }else if( req.getEndpoint().contains('award/payment-request/gax' ) && req.getMethod().toUpperCase() == 'POST' ){
                    res.setBody('{"message":"File was uploaded successfully","status":"success","filename":"400GAX_201701010732_GGrants.xml"}');
                    res.setStatusCode(200);
                }else if( req.getEndpoint().contains('award/payment-request/gax' ) && req.getMethod().toUpperCase() == 'DELETE' ){
                    res.setBody('[{"FILENAME":"400GAX_20171025_1715_GGrants.xml","MESSAGE":"File was successfully deleted.","STATUS":"success","ISDELETED":true}]');
                    res.setStatusCode(200);
                }else if( req.getEndpoint().contains('award/payment-request/gax/transmittal' ) && req.getMethod().toUpperCase() == 'POST' ){
                    res.setBody('{"transmittals":[{"filename":"100GAX20180116155406_DCCMS.xml","dept":"100","documentcode":"GGAX","firstdocid":"18","lastdocid":"18","numofdocs":240,"totalamt":-316204.91,"returnemail":"mickeymouse@utah.gov"}]}');
                    res.setStatusCode(200);
                }else if( req.getEndpoint().contains('award/payment-request/iet' ) && req.getMethod().toUpperCase() == 'POST' ){
                    res.setBody('{"message":"File was uploaded successfully","status":"success","filename":"400IET_201701010732_GGrants.xml"}');
                    res.setStatusCode(200);
                }else if( req.getEndpoint().contains('award/payment-request/iet' ) && req.getMethod().toUpperCase() == 'DELETE' ){
                    res.setBody('[{"FILENAME":"400IET_20171025_1715_GGrants.xml","MESSAGE":"File was successfully deleted.","STATUS":"success","ISDELETED":true}]');
                    res.setStatusCode(200);
                }else if( req.getEndpoint().contains('award/payment-request/iet/transmittal' ) && req.getMethod().toUpperCase() == 'POST' ){
                    res.setBody('{"transmittals":[{"filename":"100IET20180116155406_DCCMS.xml","dept":"100","documentcode":"GIET","firstdocid":"18","lastdocid":"18","numofdocs":240,"totalamt":-316204.91,"returnemail":"mickeymouse@utah.gov"}]}');
                    res.setStatusCode(200);
                }else if( req.getEndpoint().contains('program/phase-budget') && req.getMethod().toUpperCase() == 'POST' ){
                    res.setBody('{"message":"File was uploaded successfully","status":"success","filename":"400GCAM_201701010732_GGrants.xml"}');
                    res.setStatusCode(200);
                }else if( req.getEndpoint().contains('program/phase-budget') && req.getMethod().toUpperCase() == 'PUT' ){
                    res.setBody('{"message":"File was uploaded successfully","status":"success","filename":"400GCAM_201701010732_GGrants.xml"}');
                    res.setStatusCode(200);
                }else if( req.getEndpoint().contains('program/phase-budget' ) && req.getMethod().toUpperCase() == 'DELETE' ){
                    res.setBody('[{"FILENAME":"400GCAM_20171025_1715_GGrants.xml","MESSAGE":"File was successfully deleted.","STATUS":"success","ISDELETED":true}]');
                    res.setStatusCode(200);
                }else if( req.getEndpoint().contains('program/phase-budget/transmittal' ) && req.getMethod().toUpperCase() == 'POST' ){
                    res.setBody('{"transmittals":[{"filename":"100GCAM20180116155406_DCCMS.xml","dept":"100","documentcode":"GCAM","firstdocid":"18","lastdocid":"18","numofdocs":240,"totalamt":-316204.91,"returnemail":"mickeymouse@utah.gov"}]}');
                    res.setStatusCode(200);
                }else if( req.getEndpoint().contains('program' ) && req.getMethod().toUpperCase() == 'POST' ){
                    res.setBody('{"message":"File was uploaded successfully","status":"success","filename":"400GCAM_201701010732_GGrants.xml"}');
                    res.setStatusCode(200);
                }else if( req.getEndpoint().contains('program' ) && req.getMethod().toUpperCase() == 'DELETE' ){
                    res.setBody('[{"FILENAME":"400GCAM_20171025_1715_GGrants.xml","MESSAGE":"File was successfully deleted.","STATUS":"success","ISDELETED":true}]');
                    res.setStatusCode(200);
                }else if( req.getEndpoint().contains('program/transmittal' ) && req.getMethod().toUpperCase() == 'POST' ){
                    res.setBody('{"transmittals":[{"filename":"100GCAM20180116155406_DCCMS.xml","dept":"100","documentcode":"GCAM","firstdocid":"18","lastdocid":"18","numofdocs":240,"totalamt":-316204.91,"returnemail":"mickeymouse@utah.gov"}]}');
                    res.setStatusCode(200);
                } else {
                    res.setBody('[{"message":"Error: unknown endpoint"}]');
                    res.setStatusCode(500);
                }
            }else if( scenario.toUpperCase() == 'N' ){
                res.setStatusCode(404);
                res.setBody('{ "message": "No records found." }');
            }else if( scenario.toUpperCase() == 'TM' ){
                res.setStatusCode(404);
                res.setBody('{ "message": "Count of records returned is greater than max supplied." }');
            }else if( scenario.toUpperCase() == '500' ){
                res.setStatusCode(500);
            }
        }
        return res;
    }
    private void throwNullPointerException( String message ){
        NullPointerException npe = new NullPointerException();
        npe.setMessage( message );
        throw npe;
    }
}