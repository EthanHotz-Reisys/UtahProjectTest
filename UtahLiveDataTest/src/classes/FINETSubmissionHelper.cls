global with sharing class FINETSubmissionHelper extends GNT.DynamicLayoutActionRedirect { 

    global override PageReference whenClicked(){
    Savepoint sp = Database.setSavepoint();
    List<String> errors = new List<String>();  
    try{
      Id recordId = apexpages.currentpage().getparameters().get('id');
      List<PaymentRequest__c> paymentList = [SELECT Id, Status__c,MSPPaymentSchedule__r.FiscalYear__c,MSPPaymentSchedule__r.ScheduleDate__c,PaymentAmount__c,Grant__r.InternalOrganization__c FROM PaymentRequest__c WHERE id =:recordId limit 1];
      
      if(paymentList.size() !=0 && paymentList.size() >0)
      {
      Set<String> PaymentSet = new Set<String>();
       for(PaymentRequest__c paymentReq: paymentList){
       PaymentSet.add(paymentReq.Id);
      } 
      List<PaymentFINETCode__c> paymentFINETList = [SELECT id,Amount__c,AwardFINETCode__r.ProgramCode__r.PROG_CD__c,AwardFINETCode__r.ProgramCode__r.PROG_NM__c,AwardFINETCode__r.ObjectCode__r.OBJ_CD__c,paymentRequest__r.Grant__r.Program__r.Account__r.Code__c,paymentRequest__r.Grant__r.Program__r.UnitLookup__r.UNIT_CD__c,paymentRequest__r.Grant__r.Program__r.FundLookup__r.FUND_CD__c,paymentRequest__r.Grant__r.Program__r.AppropriationLookup__r.APPR_CD__c,
      OneTwelveCatchUpAmount__c,OneTwelvePaymentAmount__c,PaymentRequest__c,
      RemainingAmount__c,RequestedAmount__c,SpentAmount__c,
      paymentRequest__r.Grant__r.InternalOrganization__r.LEA_Id__c,
      paymentRequest__r.Grant__r.ExternalOrganization__r.Code__c,paymentRequest__r.Grant__r.ExternalOrganization__r.UnitCode__c
      FROM PaymentFINETCode__c where paymentRequest__c IN :PaymentSet];
      
     Set<Id> paymentFinetIds = new Set<Id>();
     for(PaymentFINETCode__c fp: paymentFINETList){
              paymentFinetIds.add(fp.Id);
            }
   
      List<FINETVendorLink__c> vendorLink = [select InternalAccount__r.Name,VendorPaymentType__c,FINETVCUST__r.vend_cust_cd__c,FINETVCUSTADD__r.AD_ID__c  from FINETVendorLink__c where Account__c =:paymentList[0].Grant__r.InternalOrganization__c AND InternalAccount__r.Name = 'USBE' limit 1];
      
      if(vendorLink[0].VendorPaymentType__c == 'GAX'){
      IntegCGIAdv_GAX_Document a = new IntegCGIAdv_GAX_Document(String.valueOf(paymentFINETList[0].paymentRequest__r.Grant__r.ExternalOrganization__r.Code__c));
      Date todaysDate = Date.today();
      String DOC_ID = String.valueOf(GAXPaymentCreationBatch.getRandomUnique());
      IntegCGIAdv_GAX_Document.IntegCGIAdv_ABS_DOC_HDR_GAX header = new IntegCGIAdv_GAX_Document.IntegCGIAdv_ABS_DOC_HDR_GAX( 
      todaysDate,
      '11', 
      FiscalYearHelper.getFiscalYear(System.today()), 
      DOC_ID );
       IntegCGIAdv_GAX_Document.IntegCGIAdv_ABS_DOC_VEND_GAX vendor = new IntegCGIAdv_GAX_Document.IntegCGIAdv_ABS_DOC_VEND_GAX( 
       1,
       String.valueOf(vendorLink[0].FINETVCUST__r.vend_cust_cd__c),
       String.valueOf(vendorLink[0].FINETVCUSTADD__r.AD_ID__c),
       PaymentScheduleHelper.getPaymentDate());
       
        IntegCGIAdv_GAX_Document.IntegCGIAdv_ABS_DOC_ACTG_GAX[] accountingLines = new IntegCGIAdv_GAX_Document.IntegCGIAdv_ABS_DOC_ACTG_GAX[]{};
        integer i = 1;
        Decimal totalAmount = 0.00;
        string vendInvNo;
        for(PaymentFINETCode__c paymentFINET :paymentFINETList ){
       
              vendInvNo = GAXPaymentCreationBatch.getRandomUnique();
              accountingLines.add( new IntegCGIAdv_GAX_Document.IntegCGIAdv_ABS_DOC_ACTG_GAX( 
              1,
              i,
              paymentFINET.AwardFINETCode__r.ProgramCode__r.PROG_NM__c,
              paymentFINET.RequestedAmount__c,
              String.valueOf(vendInvNo),
              i,
              todaysDate,
              String.valueOf(paymentFINET.paymentRequest__r.Grant__r.Program__r.FundLookup__r.FUND_CD__c),
              String.valueOf(paymentFINET.paymentRequest__r.Grant__r.Program__r.Account__r.Code__c),
              String.valueOf(paymentFINET.paymentRequest__r.Grant__r.Program__r.UnitLookup__r.UNIT_CD__c),
              String.valueOf(paymentFINET.paymentRequest__r.Grant__r.Program__r.AppropriationLookup__r.APPR_CD__c),
              String.valueOf(paymentFINET.AwardFINETCode__r.ObjectCode__r.OBJ_CD__c),
              String.valueOf(paymentFINET.AwardFINETCode__r.ProgramCode__r.PROG_CD__c),
              String.valueOf(paymentFINET.paymentRequest__r.Grant__r.InternalOrganization__r.LEA_Id__c) ) );
              i = i+1;   
              totalAmount = totalAmount+(paymentFINET.RequestedAmount__c);
        }
       a.createAMS_DOCUMENTwithDefaults( TRUE,String.valueOf(paymentFINETList[0].paymentRequest__r.Grant__r.ExternalOrganization__r.Code__c),String.valueOf(paymentFINETList[0].paymentRequest__r.Grant__r.ExternalOrganization__r.UnitCode__c),String.valueOf(FiscalYearHelper.getFiscalYearShort(System.today())), header, vendor, accountingLines );
        
       system.debug(a.renderJSON(true));
        
        document doc = new document( FolderId=GetFolderHelper.getFolderId(), name = userinfo.getName() + 'SingleGAX' );
        doc.body =  blob.valueOf( a.renderJSON(true) );
       // webCalloutGAX(a.renderJSON(false),String.valueOf(paymentFINETList[0].paymentRequest__r.Grant__r.ExternalOrganization__r.Code__c),totalAmount);
        insert doc;
        IntegUtahGrantsAPI.GrantsAPIDocumentStatus docStatus = new IntegUtahGrantsAPI.GrantsAPIDocumentStatus(DOC_ID,'GAX',String.valueOf(paymentFINETList[0].paymentRequest__r.Grant__r.ExternalOrganization__r.Code__c),paymentFinetIds);
        docStatus.insertRecords(datetime.now(),a.renderJSON(true));
   
    } else if(vendorLink[0].VendorPaymentType__c == 'IET'){
         Date todaysDate = Date.today();
         String DOC_ID = String.valueOf(GAXPaymentCreationBatch.getRandomUnique());
         IntegCGIAdv_IET_Document a = new IntegCGIAdv_IET_Document(String.valueOf(paymentFINETList[0].paymentRequest__r.Grant__r.ExternalOrganization__r.Code__c));
         IntegCGIAdv_IET_Document.IntegCGIAdv_IET_DOC_HDR_IET header = new IntegCGIAdv_IET_Document.IntegCGIAdv_IET_DOC_HDR_IET( 
         todaysDate,
         '11',
         Integer.valueOf(FiscalYearHelper.getFiscalYear(System.today())),
         DOC_ID,
         IETTarget__c.getInstance().AD_ID__c, 
         IETTarget__c.getInstance().INIT_CD__c,
         IETTarget__c.getInstance().VEND_CUST_CD__c);
         IntegCGIAdv_IET_Document.IntegCGIAdv_IET_DOC_ACTG_IET[] accountingLines = new IntegCGIAdv_IET_Document.IntegCGIAdv_IET_DOC_ACTG_IET[]{};
         integer i = 1;
         Decimal totalAmount = 0.00;
         for(PaymentFINETCode__c paymentFINET :paymentFINETList ){
            accountingLines.add( new IntegCGIAdv_IET_Document.IntegCGIAdv_IET_DOC_ACTG_IET( 
            1, 
            i, 
            'Account line description', 
            paymentFINET.RequestedAmount__c,
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
            totalAmount = totalAmount+(paymentFINET.RequestedAmount__c);
  
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
        
         document doc4 = new document( FolderId=GetFolderHelper.getFolderId(), name = userinfo.getName() + 'SingleIET' );
         doc4.body =  blob.valueOf( a.renderJSON(true) );
        // webCalloutIET(a.renderJSON(false),String.valueOf(paymentFINETList[0].paymentRequest__r.Grant__r.ExternalOrganization__r.Code__c),totalAmount); 
         insert doc4;
         IntegUtahGrantsAPI.GrantsAPIDocumentStatus docStatus = new IntegUtahGrantsAPI.GrantsAPIDocumentStatus(DOC_ID,'IET',String.valueOf(paymentFINETList[0].paymentRequest__r.Grant__r.ExternalOrganization__r.Code__c),paymentFinetIds);
         docStatus.insertRecords(datetime.now(),a.renderJSON(true));
 
           
         }
   
 

         
       }
       return null;
     }
       catch(Exception e){
            Database.rollback(sp);
            System.debug('***exception caught' + e.getCause());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            return null;
        }
    }
    
       private static void webCalloutGAX(String jsonString,String deptCode,Decimal amount){
       IntegCGIAdv_GAX_Document curr;
       curr = (IntegCGIAdv_GAX_Document) JSON.deserialize(jsonString,IntegCGIAdv_GAX_Document.class);
            
          httpresponse r = IntegUtahGrantorAPI.postGAXPaymentDetails(curr);
          system.debug('response from server'+ r);
          document doc1 = new document( FolderId=GetFolderHelper.getFolderId(), name = userinfo.getName() + 'SingleGAXResponse' );
          doc1.body =  blob.valueOf(r.getbody());
          String responseBody = r.getBody();
          
     
          FINETSubmissionHelper.IntegUtahResponse response = (FINETSubmissionHelper.IntegUtahResponse)JSON.deserialize(responseBody, FINETSubmissionHelper.IntegUtahResponse.class);
          IntegCGIAdv_GAX_Transmittal_Files transmittal = new IntegCGIAdv_GAX_Transmittal_Files();
          transmittal.addTranmittal(response.filename,deptCode,String.valueOf(FiscalYearHelper.getFiscalYearShort(System.today())),String.valueOf(FiscalYearHelper.getFiscalYearShort(System.today())),1,amount,'swati.singh@reisystems.com' );
          httpresponse r1 = IntegUtahGrantorAPI.postGAXTransmittalFile(transmittal);
          document doc2 = new document( FolderId=GetFolderHelper.getFolderId(), name = userinfo.getName() + 'SingleGAXTransmittal' );
          doc2.body =  blob.valueOf(transmittal.renderJSON(true));
          document doc3 = new document( FolderId=GetFolderHelper.getFolderId(), name = userinfo.getName() + 'SingleGAXTransmittalResponse' );
          doc3.body =  blob.valueOf(r1.getbody());
          insert doc2;
          
      }
      
       private static void webCalloutIET(String jsonString,String deptCode,Decimal amount){
       IntegCGIAdv_IET_Document curr;
       curr = (IntegCGIAdv_IET_Document) JSON.deserialize(jsonString,IntegCGIAdv_IET_Document.class);
      
         httpresponse r = IntegUtahGrantorAPI.postIETPaymentDetails(curr);
         document doc5 = new document( FolderId=GetFolderHelper.getFolderId(), name = userinfo.getName() + 'SingleIETResponse' );
         doc5.body =  blob.valueOf(r.getbody());
         system.debug('IETresponse>>>'+r.getBody());
         String responseBody = r.getBody();
         
         FINETSubmissionHelper.IntegUtahResponse response = (FINETSubmissionHelper.IntegUtahResponse)JSON.deserialize(responseBody, FINETSubmissionHelper.IntegUtahResponse.class);
          IntegCGIAdv_IET_Transmittal_Files transmittal = new IntegCGIAdv_IET_Transmittal_Files();
          transmittal.addTranmittal(response.filename,deptCode,String.valueOf(FiscalYearHelper.getFiscalYearShort(System.today())),String.valueOf(FiscalYearHelper.getFiscalYearShort(System.today())),1,amount,'swati.singh@reisystems.com' );
          httpresponse r1 = IntegUtahGrantorAPI.postIETTransmittalFile(transmittal);
          document doc6 = new document( FolderId=GetFolderHelper.getFolderId(), name = userinfo.getName() + 'SingleIETTransmittal' );
          doc6.body =  blob.valueOf(transmittal.renderJSON(true));
          document doc7 = new document( FolderId=GetFolderHelper.getFolderId(), name = userinfo.getName() + 'SingleIETTransmittalResponse' );
          doc7.body =  blob.valueOf(r1.getbody()); 
          insert doc6;
          
        }
   

    
       /* Public class */
        public class IntegUtahResponse {
        public string message {get;set;}
        public string status {get;set;}
        public string filename {get;set;}
       
        
        }
   
    
}