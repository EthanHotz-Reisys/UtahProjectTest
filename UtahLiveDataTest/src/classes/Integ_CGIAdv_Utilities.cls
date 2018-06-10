/**
* Integ_CGIAdv_Utilities is a utility class used in the IntegCGIAdv classes
*
* CHANGE HISTORY
* ==================================================================================================
* Date              Name                Description
* Mar 01 2018       Brian Mason         Created
* ==================================================================================================
*/
public class Integ_CGIAdv_Utilities {
    //PUBLIC PROPERTIES
    public static Integer batchRetrievalHours {
        get {
            return getBatchRetrievalHours();
        }
        private set;
    }

    public static Integer batchSize = 9995;
    public static String grantorDevURL {
        get {
            checkUrlInstance();
            return finetUrls.GrantorDevURL__c;
        }
        private set;
    }
    public static String granteeDevURL {
        get {
            checkUrlInstance();
            return finetUrls.GranteeDevURL__c;
        }
        private set;
    }
    public static String grantorProdURL {
        get {
            checkUrlInstance();
            return finetUrls.GrantorProdURL__c;
        }
        private set;
    }
    public static String granteeProdURL {
        get {
            checkUrlInstance();
            return finetUrls.GranteeProdURL__c;
        }
        private set;
    }
    
    // PUBLIC STATIC METHODS
    
    public static String valueIfBlank( String specifiedValue, String defaultValue ){
        return String.isNotBlank( specifiedValue ) ? specifiedValue : defaultValue;
    }
    public static String DefaultTimeZone(){ return 'US/Mountain'; }
    public static Set<String> dedupeSet( Set<String> setToDedupe ){
        Set<String> setToReturn = new Set<String>();
        for( String str : new List<String>( setToDedupe ) ){
            if( str != null ){ setToReturn.add( str.toUpperCase() ); }
        }
        return setToReturn;
    }

    public static PersistentBatchObject getDefaultBatchObject() {
        DateTime defaultStart = DateTime.now().addHours(batchRetrievalHours);
        return new PersistentBatchObject(
            DateTime.newInstanceGMT(defaultStart.date(), defaultStart.time()), 
            DateTime.newInstanceGMT(DateTime.now().date(), DateTime.now().time()), 
            DateTime.newInstanceGMT(DateTime.now().date(), DateTime.now().time()), 
            null);
    }

    public static String formatDateToString( Date newDate ){
        return datetime.newInstance( newDate.year(), newDate.month(), newDate.day() ).format( 'yyyy-MM-dd' );
    }
    
    public static DateTime formatDateTime(DateTime DT) {
        return DateTime.valueOf(DT.format('yyyy-MM-dd HH:mm:ss.SSS', Integ_CGIAdv_Utilities.DefaultTimeZone() ));
    }

    public static String getExtId_Unit(string unit_cd, string dept_cd, string fy) {
        return unit_cd + dept_cd + fy;
    }

    public static String getExtId_Program(string prog_cd, string dept_cd) {
        return prog_cd + dept_cd;
    }

    public static String getExtId_Fund(string fund_cd, string fy) {
        return fund_cd + fy;
    }

    public static String getExtId_Appropriation(string appr_cd, string fy) {
        return appr_cd + fy;
    }

    public static String getExtId_Object(string obj_cd, string fy) {
        return obj_cd + fy;
    }

    public static String getExtId_MajorProgram(string mjr_prog_cd, string dept_cd) {
        return mjr_prog_cd + dept_cd;
    }

    public static String getExtId_ProgramGroup(string pgrp_cd, string dept_cd ) {
        return pgrp_cd + dept_cd;
    }

    public static String getExtId_ProgramType(string ptyp_cd, string dept_cd ) {
        return ptyp_cd + dept_cd;
    }

    public static String getExtId_ProgramClass(string pcls_cd) {
        return pcls_cd;
    }

    public static String getExtId_ProgramCategory(string pcat_cd) {
        return pcat_cd;
    }

    public static String getExtId_VendorAddress(string vend_cust_cd, string ad_typ, string ad_id) {
        return vend_cust_cd + ad_typ + ad_id;
    }
    
    public static String getExtId_FundingInference(string fprfl_cd, string dept_cd, string mjr_prog_cd) {
        return fprfl_cd + dept_cd + mjr_prog_cd;
    }

    public static void sendErrorEmails(List<string> errorList) {
        string csvString = '';
        List<Id> allIds = new List<Id>();
        List<Id> idList = new List<Id>();
        Boolean finetUserFlag = false;
        for (User u : [SELECT Id, Receive_FINET_Errors__c FROM User WHERE IsActive = true AND Profile.Name LIKE 'System Administrator']) {
            allIds.add(u.Id);
            if (u.Receive_FINET_Errors__c == true) {
                idList.add(u.Id);
                finetUserFlag = true;
            }
        }
        for (string err : errorList) {
            csvString += err + '\n';
        }
        if (csvString != '') {
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.setSubject('Error log from FINET data transfer');
            string emailBody = '';
            if (finetUserFlag == false) {
                emailBody = 'Because no FINET admins have been defined, all administrators are receiving this email.\n';
            }
            emailBody += 'The error log is attached.\n';
            message.setPlainTextBody(emailBody);
            message.setToAddresses(finetUserFlag == false ? allIds : idList);
             
            Messaging.EmailFileAttachment csv = new Messaging.EmailFileAttachment();
            Blob csvBlob = Blob.valueOf(csvString);
            csv.setFileName('FINETDataTransferErrorLog_'+DateTime.now()+'.csv');
            csv.setBody(csvBlob); 
            message.setFileAttachments(new Messaging.EmailFileAttachment[]{csv});
            Messaging.SendEmailResult[] results = Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{message});
        }
    }

    public static void sendErrorEmails(String error) {
        List<string> tempList = new List<string>();
        tempList.add(error);
        sendErrorEmails(tempList); 
    }

    public static Set<Integer> getFiscalYears() {
        Set<Integer> fiscalYears = new Set<Integer>();
        List<FiscalYear__c> yearList = [SELECT FiscalYearNumber__c from FiscalYear__c where FiscalYearNumber__c != null];
        if (yearList == null) { throw new BatchLogicException('Fiscal Year error - ensure FiscalYearNumber__c field is populated'); }
        for (FiscalYear__c year : yearList) {
            fiscalYears.add(Integer.valueOf(year.FiscalYearNumber__c));
        }
        return fiscalYears;
    }

    public static Set<String> getDepartmentCodes() {
        Set<String> departmentCodes = new Set<String>();
        List<Account> deptList = [SELECT Code__c FROM Account WHERE Code__c != null];
        for (Account acc : deptList) {
            departmentCodes.add(acc.Code__c);
        }
        return departmentCodes;
    }

    //PRIVATE METHODS/VARIABLES
    private static FINET_Batch_Settings__c batchSettings;
    private static integer getBatchRetrievalHours() {
        if (batchSettings == null) { batchSettings = FINET_Batch_Settings__c.getInstance(); }
        if (batchSettings.Batch_Retrieval_Hours__c == null) {
            throw new NullReferenceException('FINET Batch Settings custom setting not populated');
        }
        Decimal hours = (batchSettings.Batch_Retrieval_Hours__c < 0) ? batchSettings.Batch_Retrieval_Hours__c : -(batchSettings.Batch_Retrieval_Hours__c);
        return Integer.valueOf(hours);
    }

    private static FINET_URLs__c finetUrls;
    private static void checkUrlInstance() {
        if (finetUrls == null) { finetUrls = FINET_URLs__c.getInstance();}
        if (finetUrls.GranteeDevURL__c == null || finetUrls.GrantorDevURL__c == null || 
        finetUrls.GrantorProdURL__c == null || finetUrls.GranteeProdURL__c == null) { throw new Integ_CGIAdv_Utilities.NullReferenceException('FINET URL custom setting not found');}
    }
    
    //EXCEPTIONS
    public class FINETAPIException extends Exception {}
    public class ReadOnlyModeException extends Exception {}
    public class NullReferenceException extends Exception {}
    public class BatchLogicException extends Exception {}
}