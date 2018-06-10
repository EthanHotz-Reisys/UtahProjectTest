global class GAXPaymentCreationBatch implements Database.Batchable<sObject>,Database.AllowsCallouts, Database.Stateful {

  public String query;
  public List<String> errors;
  public MSPPaymentSchedule__c mps;
  
 
  
  global GAXPaymentCreationBatch(MSPPaymentSchedule__c mps) {
    this.mps = mps;
    errors = new List<String>();
  }
  
  global Database.QueryLocator start(Database.BatchableContext BC) {
    try{
            
       //query = 'select LEA_Id__c,ParentID,EINText__c,DUNS__c,Name,ApplicantType__c,BillingCity,BillingState,CreatedDate from account where recordType.name =\'Recipient\'AND LEA_Id__c IN(\'010\')';
         query = 'select LEA_Id__c,ParentID,EINText__c,DUNS__c,Name,ApplicantType__c,BillingCity,BillingState,CreatedDate from account where recordType.name =\'Recipient\'AND LEA_Id__c != null';

     return Database.getQueryLocator(query);
    }catch(Exception e){
      errors.add(e.getMessage());
      return null;
    }
  }

     global void execute(Database.BatchableContext BC, List<Account> scope) {
     if(scope == null){
      return;
    }

    try{
       Set<String> keySet = new Set<String>();
       Set<String> accountIdSet= new Set<String>();
       for(Account acc : scope){
       keySet.add(acc.LEA_Id__c);
       accountIdSet.add(acc.Id);
      } 
    
      List<PaymentRequest__c> paymentList = [SELECT Id, Status__c,MSPPaymentSchedule__r.FiscalYear__c,MSPPaymentSchedule__r.ScheduleDate__c,PaymentAmount__c,Grant__r.InternalOrganization__c FROM PaymentRequest__c WHERE  Grant__r.InternalOrganization__r.LEA_Id__c IN :keySet AND MSPPaymentSchedule__c = : mps.Id]; /*MSPPaymentSchedule__c = : mps.Id AND*/
      System.debug('paymentList>>>>'+paymentList);
      if(paymentList.size() !=0 && paymentList.size() >0)
      {
      Set<String> PaymentSet = new Set<String>();
       for(PaymentRequest__c paymentReq: paymentList){
       PaymentSet.add(paymentReq.Id);
      } 
      List<PaymentFINETCode__c> paymentFINETList = [SELECT id,Amount__c,AwardFINETCode__r.ProgramCode__r.PROG_CD__c,AwardFINETCode__r.ProgramCode__r.PROG_NM__c,AwardFINETCode__r.ObjectCode__r.OBJ_CD__c,paymentRequest__r.Grant__r.Program__r.Account__r.Code__c,paymentRequest__r.Grant__r.Program__r.UnitLookup__r.UNIT_CD__c,paymentRequest__r.Grant__r.Program__r.FundLookup__r.FUND_CD__c,paymentRequest__r.Grant__r.Program__r.AppropriationLookup__r.APPR_CD__c,OneTwelveCatchUpAmount__c,OneTwelvePaymentAmount__c,PaymentRequest__c,RemainingAmount__c,RequestedAmount__c,SpentAmount__c,paymentRequest__r.Grant__r.InternalOrganization__r.LEA_Id__c,paymentRequest__r.Grant__r.ExternalOrganization__r.Code__c,paymentRequest__r.Grant__r.ExternalOrganization__r.UnitCode__c FROM PaymentFINETCode__c where paymentRequest__c IN :PaymentSet];
      System.debug('paymentFINETList>>>>'+paymentFINETList);
      
     Set<Id> paymentFinetIds = new Set<Id>();
     for(PaymentFINETCode__c fp: paymentFINETList){
              paymentFinetIds.add(fp.Id);
            }
 
      List<FINETVendorLink__c> vendorLink = [select InternalAccount__r.Name,VendorPaymentType__c,FINETVCUST__r.vend_cust_cd__c,FINETVCUSTADD__r.AD_ID__c  from FINETVendorLink__c where Account__c IN :accountIdSet AND InternalAccount__r.Name = 'USBE' limit 1];
      System.debug('vendorLink>>>>'+vendorLink);
      
      if(vendorLink[0].VendorPaymentType__c == 'GAX'){
      IntegCGIAdv_GAX_Document a = new IntegCGIAdv_GAX_Document(String.valueOf(paymentFINETList[0].paymentRequest__r.Grant__r.ExternalOrganization__r.Code__c));
      Date todaysDate = Date.today();
      String DOC_ID = String.valueOf(getRandomUnique());
      IntegCGIAdv_GAX_Document.IntegCGIAdv_ABS_DOC_HDR_GAX header = new IntegCGIAdv_GAX_Document.IntegCGIAdv_ABS_DOC_HDR_GAX( 
      todaysDate,
      '11', 
      FiscalYearHelper.getFiscalYear(System.today()), 
      DOC_ID );
       // IntegCGIAdv_GAX_Document.IntegCGIAdv_ABS_DOC_VEND_GAX vendor = new IntegCGIAdv_GAX_Document.IntegCGIAdv_ABS_DOC_VEND_GAX( 1, '76453J', '00', date.newInstance(2018, 10, 26));
       IntegCGIAdv_GAX_Document.IntegCGIAdv_ABS_DOC_VEND_GAX vendor = new IntegCGIAdv_GAX_Document.IntegCGIAdv_ABS_DOC_VEND_GAX( 
       1,
       String.valueOf(vendorLink[0].FINETVCUST__r.vend_cust_cd__c),
       String.valueOf(vendorLink[0].FINETVCUSTADD__r.AD_ID__c),
       PaymentScheduleHelper.getPaymentDate());
       //paymentList[0].MSPPaymentSchedule__r.ScheduleDate__c
        IntegCGIAdv_GAX_Document.IntegCGIAdv_ABS_DOC_ACTG_GAX[] accountingLines = new IntegCGIAdv_GAX_Document.IntegCGIAdv_ABS_DOC_ACTG_GAX[]{};
        integer i = 1;
        Decimal totalAmount = 0.00;
        string vendInvNo;
        for(PaymentFINETCode__c paymentFINET :paymentFINETList ){
       
              vendInvNo = getRandomUnique();
              accountingLines.add( new IntegCGIAdv_GAX_Document.IntegCGIAdv_ABS_DOC_ACTG_GAX( 
              1,
              i,
              paymentFINET.AwardFINETCode__r.ProgramCode__r.PROG_NM__c,
              paymentFINET.OneTwelvePaymentAmount__c,
              String.valueOf(vendInvNo),
              i,
              todaysDate,
              String.valueOf(paymentFINET.paymentRequest__r.Grant__r.Program__r.FundLookup__r.FUND_CD__c),
              String.valueOf(paymentFINET.paymentRequest__r.Grant__r.Program__r.Account__r.Code__c),
              String.valueOf(paymentFINET.paymentRequest__r.Grant__r.Program__r.UnitLookup__r.UNIT_CD__c),
              String.valueOf(paymentFINET.paymentRequest__r.Grant__r.Program__r.AppropriationLookup__r.APPR_CD__c),
              String.valueOf(paymentFINET.AwardFINETCode__r.ObjectCode__r.OBJ_CD__c),
              //'7511',
              String.valueOf(paymentFINET.AwardFINETCode__r.ProgramCode__r.PROG_CD__c),
              String.valueOf(paymentFINET.paymentRequest__r.Grant__r.InternalOrganization__r.LEA_Id__c) ) );
              i = i+1;   
              totalAmount = totalAmount+(paymentFINET.OneTwelvePaymentAmount__c);
        }
       a.createAMS_DOCUMENTwithDefaults( TRUE,String.valueOf(paymentFINETList[0].paymentRequest__r.Grant__r.ExternalOrganization__r.Code__c),String.valueOf(paymentFINETList[0].paymentRequest__r.Grant__r.ExternalOrganization__r.UnitCode__c),String.valueOf(FiscalYearHelper.getFiscalYearShort(System.today())), header, vendor, accountingLines );
        
       system.debug(a.renderJSON(true));
        
        document doc = new document( FolderId=GetFolderHelper.getFolderId(), name = userinfo.getName() + 'GAX' );
        doc.body =  blob.valueOf( a.renderJSON(true) );
        
          httpresponse r = IntegUtahGrantorAPI.postGAXPaymentDetails(a);
          system.debug('response from server'+ r);
          document doc1 = new document( FolderId=GetFolderHelper.getFolderId(), name = userinfo.getName() + 'GAXResponse' );
     
          doc1.body =  blob.valueOf(r.getbody());
          String responseBody = r.getBody();
          
     
          GAXPaymentCreationBatch.IntegUtahResponse response = (GAXPaymentCreationBatch.IntegUtahResponse)JSON.deserialize(responseBody, GAXPaymentCreationBatch.IntegUtahResponse.class);
          IntegCGIAdv_GAX_Transmittal_Files transmittal = new IntegCGIAdv_GAX_Transmittal_Files();
          transmittal.addTranmittal(response.filename,String.valueOf(paymentFINETList[0].paymentRequest__r.Grant__r.ExternalOrganization__r.Code__c),String.valueOf(FiscalYearHelper.getFiscalYearShort(System.today())),String.valueOf(FiscalYearHelper.getFiscalYearShort(System.today())),1,totalAmount,'swati.singh@reisystems.com' );
          httpresponse r1 = IntegUtahGrantorAPI.postGAXTransmittalFile(transmittal);
          document doc2 = new document( FolderId=GetFolderHelper.getFolderId(), name = userinfo.getName() + 'GAXTransmittal' );
          doc2.body =  blob.valueOf(transmittal.renderJSON(true));
          document doc3 = new document( FolderId=GetFolderHelper.getFolderId(), name = userinfo.getName() + 'GAXTransmittalResponse' );
          doc3.body =  blob.valueOf(r1.getbody());
          
         // insert doc;
         // insert doc1;
          insert doc2;
         // insert doc3; 
        IntegUtahGrantsAPI.GrantsAPIDocumentStatus docStatus = new IntegUtahGrantsAPI.GrantsAPIDocumentStatus(DOC_ID,'GAX',String.valueOf(paymentFINETList[0].paymentRequest__r.Grant__r.ExternalOrganization__r.Code__c),paymentFinetIds);
        docStatus.insertRecords(datetime.now(),a.renderJSON(true));
 
         } 
         else if(vendorLink[0].VendorPaymentType__c == 'IET'){
         Date todaysDate = Date.today();
         String DOC_ID = String.valueOf(getRandomUnique());
         IntegCGIAdv_IET_Document a = new IntegCGIAdv_IET_Document(String.valueOf(paymentFINETList[0].paymentRequest__r.Grant__r.ExternalOrganization__r.Code__c));
         IntegCGIAdv_IET_Document.IntegCGIAdv_IET_DOC_HDR_IET header = new IntegCGIAdv_IET_Document.IntegCGIAdv_IET_DOC_HDR_IET( 
         todaysDate,
         '11',
         Integer.valueOf(FiscalYearHelper.getFiscalYear(System.today())),
         DOC_ID,
         IETTarget__c.getInstance().AD_ID__c, 
         IETTarget__c.getInstance().INIT_CD__c,
         IETTarget__c.getInstance().VEND_CUST_CD__c);
       //  IntegCGIAdv_IET_Document.IntegCGIAdv_IET_DOC_VEND_IET vendor = new IntegCGIAdv_IET_Document.IntegCGIAdv_IET_DOC_VEND_IET( 1,String.valueOf(vendorLink[0].FINETVCUST__r.vend_cust_cd__c),String.valueOf(vendorLink[0].FINETVCUSTADD__r.AD_ID__c), 'IN04', '7000', '050', '7560', 'null', 'null', 'null', 'null', '4052', 'null', 'null', 'null',totalAmount);
         IntegCGIAdv_IET_Document.IntegCGIAdv_IET_DOC_ACTG_IET[] accountingLines = new IntegCGIAdv_IET_Document.IntegCGIAdv_IET_DOC_ACTG_IET[]{};
         integer i = 1;
         Decimal totalAmount = 0.00;
         for(PaymentFINETCode__c paymentFINET :paymentFINETList ){
            accountingLines.add( new IntegCGIAdv_IET_Document.IntegCGIAdv_IET_DOC_ACTG_IET( 
            1, 
            i, 
            'Account line description', 
            paymentFINET.OneTwelvePaymentAmount__c,
            String.valueOf(paymentFINET.paymentRequest__r.Grant__r.Program__r.FundLookup__r.FUND_CD__c),
            String.valueOf(paymentFINET.paymentRequest__r.Grant__r.Program__r.Account__r.Code__c),
            String.valueOf(paymentFINET.paymentRequest__r.Grant__r.Program__r.UnitLookup__r.UNIT_CD__c),
            String.valueOf(paymentFINET.paymentRequest__r.Grant__r.Program__r.AppropriationLookup__r.APPR_CD__c),
            'null', 
            String.valueOf(paymentFINET.AwardFINETCode__r.ObjectCode__r.OBJ_CD__c),
            'null', 
            'null', 
            String.valueOf(paymentFINET.AwardFINETCode__r.ProgramCode__r.PROG_CD__c),
            String.valueOf(paymentFINET.paymentRequest__r.Grant__r.InternalOrganization__r.LEA_Id__c),
            'null' ) );
            i = i+1;   
            totalAmount = totalAmount+(paymentFINET.OneTwelvePaymentAmount__c);
  
        }
        IntegCGIAdv_IET_Document.IntegCGIAdv_IET_DOC_VEND_IET vendor = new IntegCGIAdv_IET_Document.IntegCGIAdv_IET_DOC_VEND_IET( 
        1,
        String.valueOf(vendorLink[0].FINETVCUST__r.vend_cust_cd__c),
        String.valueOf(vendorLink[0].FINETVCUSTADD__r.AD_ID__c), 
        'IN04', 
        '7000', 
        '050', 
        '7560', 
        'null', 
        'null', 
        'null', 
        'null', 
        '4052', 
        'null', 
        'null', 
        'null',
        totalAmount);
 
         a.createAMS_DOCUMENTwithDefaults( TRUE,String.valueOf(paymentFINETList[0].paymentRequest__r.Grant__r.ExternalOrganization__r.Code__c),String.valueOf(paymentFINETList[0].paymentRequest__r.Grant__r.ExternalOrganization__r.UnitCode__c),String.valueOf(FiscalYearHelper.getFiscalYearShort(System.today())), header, vendor, accountingLines );
         system.debug(a.renderJSON(true));
        
         document doc4 = new document( FolderId=GetFolderHelper.getFolderId(), name = userinfo.getName() + 'IET' );
         doc4.body =  blob.valueOf( a.renderJSON(true) );
         httpresponse r = IntegUtahGrantorAPI.postIETPaymentDetails(a);
         document doc5 = new document( FolderId=GetFolderHelper.getFolderId(), name = userinfo.getName() + 'IETResponse' );
         doc5.body =  blob.valueOf(r.getbody());
         system.debug('IETresponse>>>'+r.getBody());
         String responseBody = r.getBody();
         
         GAXPaymentCreationBatch.IntegUtahResponse response = (GAXPaymentCreationBatch.IntegUtahResponse)JSON.deserialize(responseBody, GAXPaymentCreationBatch.IntegUtahResponse.class);
          IntegCGIAdv_IET_Transmittal_Files transmittal = new IntegCGIAdv_IET_Transmittal_Files();
          transmittal.addTranmittal(response.filename,String.valueOf(paymentFINETList[0].paymentRequest__r.Grant__r.ExternalOrganization__r.Code__c),String.valueOf(FiscalYearHelper.getFiscalYearShort(System.today())),String.valueOf(FiscalYearHelper.getFiscalYearShort(System.today())),1,totalAmount,'swati.singh@reisystems.com' );
          httpresponse r1 = IntegUtahGrantorAPI.postIETTransmittalFile(transmittal);
          document doc6 = new document( FolderId=GetFolderHelper.getFolderId(), name = userinfo.getName() + 'IETTransmittal' );
          doc6.body =  blob.valueOf(transmittal.renderJSON(true));
          document doc7 = new document( FolderId=GetFolderHelper.getFolderId(), name = userinfo.getName() + 'IETTransmittalResponse' );
          doc7.body =  blob.valueOf(r1.getbody()); 
          insert doc4;
          insert doc5;
          insert doc6;
          insert doc7;
        IntegUtahGrantsAPI.GrantsAPIDocumentStatus docStatus = new IntegUtahGrantsAPI.GrantsAPIDocumentStatus(DOC_ID,'IET',String.valueOf(paymentFINETList[0].paymentRequest__r.Grant__r.ExternalOrganization__r.Code__c),paymentFinetIds);
        docStatus.insertRecords(datetime.now(),a.renderJSON(true));
 
         }
          }
  
      } catch(Exception e){
      errors.add(e.getMessage());
     // Database.rollback(sp);
    }
   
  }
  
  global void finish(Database.BatchableContext BC) {
    
  }
     /* Public class */
        public class IntegUtahResponse {
        public string message {get;set;}
        public string status {get;set;}
        public string filename {get;set;}
       
        
        }
        
    public static string getRandomUnique(){
        Integer counter = 10;
        String hashString = counter + String.valueOf(Datetime.now().formatGMT('yyyy-MM-dd HH:mm:ss.SSS'));
        Blob hash = Crypto.generateDigest('MD5', Blob.valueOf(hashString));
        String hexDigest = EncodingUtil.convertToHex(hash);
        //system.debug('##########' + hexDigest );
        Integer size = hexDigest.length();
         if(hexDigest.length()>30){
             size = 30;
         }   
        return  hexDigest.substring(0, size).toUpperCase();      
    }  


   


  
}