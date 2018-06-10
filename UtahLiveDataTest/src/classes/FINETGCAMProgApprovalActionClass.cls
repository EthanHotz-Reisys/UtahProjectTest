global class FINETGCAMProgApprovalActionClass extends GNT.ApprovalDecisionActionHandler {
    Map<String,Object> resultMap = new Map<String,Object>();
    PageReference pageRef = null;
    global override String execute(){
            system.debug('Connecting...!');
            if(selectedAction == 'Approve'){
                Savepoint sp = Database.setSavepoint();
    List<String> errors = new List<String>();  
    try{
     Id recordId = selectedRecordId;

     //Shivankar: Important Note. 
     //Add these to query below: ACT_FL__c,FINETMajorProgram__r.ACT_FL__c,ALW_BUD_FL__c,FINETMajorProgram__r.ALW_BUD_FL__c
     //Removed them from query while changing the type of ACT_FL__c,ALW_BUD_FL__c to picklist. ////REIM_ELG_STA__c,SUSP_STA__c,
      List<r_prog__c> finetProgram= [SELECT id,name,AREA__c,AutoGenerate__c,BILL_AGREE_DT__c,BoardEntity__c,BuildingNumber__c,Corridor__c,County__c,DEPT_CD__c,EFBGN_DT__c,EFEND_DT__c,Entity__c,FederalAidProjectNumber__c,FINETMajorProgram__c,FINETProgramGroup__r.PGRP_CD__c,FINETProgramType__r.PTYP_CD__c,FINETProgramClass__r.PCLS_CD__c,FINETProgramCategory__r.PCAT_CD__c,FiscalApprover__c,HighwayFunctionalClass__c,IndianReservation__c,LegislativeEntity__c,MilePostEnd__c,MilePostStart__c,ParcelNumber__c,Prefix__c,ProgramApprover__c,PROG_CD__c,PROG_NM__c,Program__c,PROG_SH_NM__c,ProjectAgreementNumber__c,SecondaryRoadPlan__c,Station__c,Status__c,WorkDescription__c,FINETMajorProgram__r.DEPT_CD__r.code__c,FINETMajorProgram__r.FED_APPR_SETP__c,
                                            FINETMajorProgram__r.EffectiveFrom__c,FINETMajorProgram__r.EffectiveTo__c,FINETMajorProgram__r.MJR_PROG_CD__c,FINETMajorProgram__r.MJR_PROG_NM__c,
                                            FINETMajorProgram__r.MJR_PROG_SH_NM__c,FINETMajorProgram__r.ReclassExclusion__c,
                                            FINETMajorProgram__r.REIM_BAS_IND__c,FINETMajorProgram__r.REIM_BUD_STRU_CD__c,FINETMajorProgram__r.SPLT_IND__c,FINETMajorProgram__r.StageDefinition__c,
                                            FINETMajorProgram__r.StreamlinedTaskOrderBilling__c,FINETMajorProgram__r.SUSP_STA__c ,PROJ_END_DT__c,LN_TYP__c,DEPT_CD__r.code__c,ACT_FL__c,FINETMajorProgram__r.ACT_FL__c,ALW_BUD_FL__c,FINETMajorProgram__r.ALW_BUD_FL__c,SACCT_CD__c,REIM_ELG_STA__c,SUSP_STA__c
                                            FROM r_prog__c
                                           where id =:recordId limit 1];
                                           
    Set<Id> finetProgIds = new Set<Id>();
     for(r_prog__c fp: finetProgram){
              finetProgIds.add(fp.Id);
            }
   
                                            
Boolean mjrProgActiveFlag;
Boolean mjrProgBudgetFlag; 
  
if(finetProgram[0].FINETMajorProgram__r.ACT_FL__c == 1.0){
mjrProgActiveFlag = true;
} else{
mjrProgActiveFlag = false;
}
if(finetProgram[0].FINETMajorProgram__r.ALW_BUD_FL__c == 1.0){
mjrProgBudgetFlag = true;
}else{
mjrProgBudgetFlag = false;
}

Boolean ProgActiveFlag;
Boolean ProgBudgetFlag; 
if(finetProgram[0].ACT_FL__c == 'True'){
ProgActiveFlag = true;
} else{
ProgActiveFlag = false;
}
if(finetProgram[0].ALW_BUD_FL__c == 'True'){
ProgBudgetFlag = true;
} else{
ProgBudgetFlag = false;
}

String progSuspStatus;
if(finetProgram[0].SUSP_STA__c == 'Allowed for Reimbursement'){
progSuspStatus = '2';
} else{
progSuspStatus = '1';
} 
String DOC_ID = String.valueOf(GAXPaymentCreationBatch.getRandomUnique());

IntegCGIAdv_GCAM_Program_Document a = new IntegCGIAdv_GCAM_Program_Document(String.valueOf(finetProgram[0].DEPT_CD__r.code__c));
IntegCGIAdv_GCAM_Program_Document.IntegCGIAdv_CAM_DOC_HDR_GCAM_Program header = new IntegCGIAdv_GCAM_Program_Document.IntegCGIAdv_CAM_DOC_HDR_GCAM_Program(DOC_ID);
IntegCGIAdv_GCAM_Program_Document.IntegCGIAdv_CAM_DOC_MJRPROG_GCAM_Program[] mjrprograms = new IntegCGIAdv_GCAM_Program_Document.IntegCGIAdv_CAM_DOC_MJRPROG_GCAM_Program[]{};
IntegCGIAdv_GCAM_Program_Document.IntegCGIAdv_CAM_DOC_MJRPROG_GCAM_Program mjrprogram = new IntegCGIAdv_GCAM_Program_Document.IntegCGIAdv_CAM_DOC_MJRPROG_GCAM_Program( 
1,
String.valueOf(finetProgram[0].FINETMajorProgram__r.DEPT_CD__r.code__c),
String.valueOf(finetProgram[0].FINETMajorProgram__r.MJR_PROG_CD__c),
String.valueOf(finetProgram[0].FINETMajorProgram__r.MJR_PROG_NM__c),
String.valueOf(finetProgram[0].FINETMajorProgram__r.MJR_PROG_SH_NM__c),
mjrProgActiveFlag,
finetProgram[0].FINETMajorProgram__r.EffectiveFrom__c,
finetProgram[0].FINETMajorProgram__r.EffectiveTo__c,
mjrProgBudgetFlag,
String.valueOf(Integer.valueOf(finetProgram[0].FINETMajorProgram__r.SUSP_STA__c)),
String.valueOf(Integer.valueOf(finetProgram[0].FINETMajorProgram__r.REIM_BAS_IND__c)),
String.valueOf(Integer.valueOf(finetProgram[0].FINETMajorProgram__r.REIM_BUD_STRU_CD__c)),
String.valueOf(Integer.valueOf(finetProgram[0].FINETMajorProgram__r.SPLT_IND__c)),
String.valueOf(Integer.valueOf(finetProgram[0].FINETMajorProgram__r.FED_APPR_SETP__c)),
'null');
mjrprograms.add(mjrprogram); 

IntegCGIAdv_GCAM_Program_Document.IntegCGIAdv_CAM_DOC_PROG_GCAM_Program[] programs = new IntegCGIAdv_GCAM_Program_Document.IntegCGIAdv_CAM_DOC_PROG_GCAM_Program[]{};
IntegCGIAdv_GCAM_Program_Document.IntegCGIAdv_CAM_DOC_PROG_GCAM_Program program = new IntegCGIAdv_GCAM_Program_Document.IntegCGIAdv_CAM_DOC_PROG_GCAM_Program( 
1,
1,
finetProgram[0].LN_TYP__c,
finetProgram[0].PROG_CD__c,
finetProgram[0].PROG_NM__c,
finetProgram[0].PROG_SH_NM__c,
ProgActiveFlag,
ProgBudgetFlag,
progSuspStatus,
finetProgram[0].REIM_ELG_STA__c,
finetProgram[0].BILL_AGREE_DT__c,
finetProgram[0].WorkDescription__c,
finetProgram[0].SACCT_CD__c,
finetProgram[0].EFBGN_DT__c,
finetProgram[0].EFEND_DT__c,
finetProgram[0].FINETProgramGroup__r.PGRP_CD__c,
finetProgram[0].FINETProgramType__r.PTYP_CD__c,
finetProgram[0].FINETProgramClass__r.PCLS_CD__c,
finetProgram[0].FINETProgramCategory__r.PCAT_CD__c,
finetProgram[0].PROJ_END_DT__c);
programs.add( program ); 
system.debug('program>>>'+program);                                                                      
a.createAMS_DOCUMENTwithDefaults( TRUE,String.valueOf(finetProgram[0].DEPT_CD__r.code__c), 'null',String.valueOf(FiscalYearHelper.getFiscalYearShort(System.today())), header, mjrprograms, programs );
system.debug(a.renderJSON(true));


document doc = new document( FolderId=GetFolderHelper.getFolderId(), name = userinfo.getName() + 'Temp' );
doc.body =  blob.valueOf( a.renderJSON(true) );

webCallout(a.renderJSON(false),String.valueOf(finetProgram[0].DEPT_CD__r.code__c));
insert doc;
finetProgram[0].Grants_API_Document_Phase__c ='Sent to FINET';
update finetProgram;
IntegUtahGrantsAPI.GrantsAPIDocumentStatus docStatus = new IntegUtahGrantsAPI.GrantsAPIDocumentStatus(DOC_ID,'GCAM',String.valueOf(finetProgram[0].DEPT_CD__r.code__c),finetProgIds);
docStatus.insertRecords(datetime.now(),a.renderJSON(true));

       // return null; 
        return ('Approving and sending to FINET. ');
       } catch(Exception e){
            Database.rollback(sp);
            System.debug('***exception caught' + e.getCause());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            return null;
        }            
               
            }
            return ('Rejected.');
          }
          
     @Future(callout=true)
       private static void webCallout(String jsonString, String deptCode ){
            // httpresponse r = IntegUtahGrantsAPI.postCreateProgram(jsonString);
            IntegCGIAdv_GCAM_Program_Document curr;
            curr = (IntegCGIAdv_GCAM_Program_Document) JSON.deserialize(jsonString,IntegCGIAdv_GCAM_Program_Document.class);

            httpresponse r = IntegUtahGrantorAPI.postCreateProgram(curr);
             system.debug('response from server'+ r); 
             system.debug(r.getbody());
             document doc3 = new document( FolderId= GetFolderHelper.getFolderId(), name = userinfo.getName() + 'Response' );
             doc3.body =  blob.valueOf(r.getbody());
             //transmittal
       String responseBody = r.getBody();
       FINETGCAMProgSubmissionHelper.IntegUtahResponse response = (FINETGCAMProgSubmissionHelper.IntegUtahResponse)JSON.deserialize(responseBody, FINETGCAMProgSubmissionHelper.IntegUtahResponse.class);
       IntegCGIAdv_Program_Transmittal_Files transmittal = new IntegCGIAdv_Program_Transmittal_Files();
       transmittal.addTranmittal(response.filename,deptCode,String.valueOf(FiscalYearHelper.getFiscalYearShort(System.today())),String.valueOf(FiscalYearHelper.getFiscalYearShort(System.today())),1,00.00,'swati.singh@reisystems.com' );
       httpresponse r1 = IntegUtahGrantorAPI.postProgramTransmittalFile(transmittal);
       document doc1 = new document( FolderId= GetFolderHelper.getFolderId(), name = userinfo.getName() + 'TempTransmittal' );
          doc1.body =  blob.valueOf(transmittal.renderJSON(true));
          document doc2 = new document( FolderId= GetFolderHelper.getFolderId(), name = userinfo.getName() + 'TempTransmittalResponse' );
          doc2.body =  blob.valueOf(r1.getbody());
          insert doc1;
          insert doc2;
          insert doc3;
        }   
    
    /* Phase 000 GCAM */
  @Future(callout=true)
  public static void gcamPhase000(Id finetProgId){
  ////REIM_ELG_STA__c,SUSP_STA__c,
  List<r_prog__c> finetProgramList = [SELECT id,name,AREA__c,AutoGenerate__c,BILL_AGREE_DT__c,BoardEntity__c,BuildingNumber__c,Corridor__c,County__c,DEPT_CD__c,EFBGN_DT__c,EFEND_DT__c,Entity__c,FederalAidProjectNumber__c,FINETMajorProgram__c,FINETProgramGroup__r.PGRP_CD__c,FINETProgramType__r.PTYP_CD__c,FINETProgramClass__r.PCLS_CD__c,FINETProgramCategory__r.PCAT_CD__c,FiscalApprover__c,HighwayFunctionalClass__c,IndianReservation__c,LegislativeEntity__c,MilePostEnd__c,MilePostStart__c,ParcelNumber__c,Prefix__c,ProgramApprover__c,PROG_CD__c,PROG_NM__c,Program__c,PROG_SH_NM__c,ProjectAgreementNumber__c,SACCT_CD__c,SecondaryRoadPlan__c,Station__c,Status__c,WorkDescription__c,FINETMajorProgram__r.DEPT_CD__r.code__c,FINETMajorProgram__r.FED_APPR_SETP__c,
                                            FINETMajorProgram__r.EffectiveFrom__c,FINETMajorProgram__r.EffectiveTo__c,FINETMajorProgram__r.MJR_PROG_CD__c,FINETMajorProgram__r.MJR_PROG_NM__c,
                                            FINETMajorProgram__r.MJR_PROG_SH_NM__c,FINETMajorProgram__r.ReclassExclusion__c,
                                            FINETMajorProgram__r.REIM_BAS_IND__c,FINETMajorProgram__r.REIM_BUD_STRU_CD__c,FINETMajorProgram__r.SPLT_IND__c,FINETMajorProgram__r.StageDefinition__c,
                                            FINETMajorProgram__r.StreamlinedTaskOrderBilling__c,FINETMajorProgram__r.SUSP_STA__c ,PROJ_END_DT__c,LN_TYP__c,ProgramAmount__c,FundingInferenceProfile__r.FPRFL_CD__c,REIM_ELG_STA__c,SUSP_STA__c
                                            FROM r_prog__c
                                            where id =:finetProgId limit 1];
                                            
 IntegCGIAdv_GCAM_ProgPhse_Budgt_Document a = new IntegCGIAdv_GCAM_ProgPhse_Budgt_Document('400');
 
 IntegCGIAdv_GCAM_ProgPhse_Budgt_Document.IntegCGIAdv_CAM_DOC_HDR_GCAM_ProgPhse_Budgt header = 
 new IntegCGIAdv_GCAM_ProgPhse_Budgt_Document.IntegCGIAdv_CAM_DOC_HDR_GCAM_ProgPhse_Budgt( '(GovGrants Unique Record ID,GovGrants User ID)' );
 
 IntegCGIAdv_GCAM_ProgPhse_Budgt_Document.IntegCGIAdv_CAM_DOC_MJRPROG_GCAM_ProgPhse_Budgt[] mjrprograms = new IntegCGIAdv_GCAM_ProgPhse_Budgt_Document.IntegCGIAdv_CAM_DOC_MJRPROG_GCAM_ProgPhse_Budgt[]{};
 IntegCGIAdv_GCAM_ProgPhse_Budgt_Document.IntegCGIAdv_CAM_DOC_MJRPROG_GCAM_ProgPhse_Budgt mjrprogram = 
 new IntegCGIAdv_GCAM_ProgPhse_Budgt_Document.IntegCGIAdv_CAM_DOC_MJRPROG_GCAM_ProgPhse_Budgt( 
 1,
'400',
 String.valueOf(finetProgramList[0].FINETMajorProgram__r.MJR_PROG_CD__c), 
 String.valueOf(finetProgramList[0].FINETMajorProgram__r.MJR_PROG_NM__c), 
 String.valueOf(finetProgramList[0].FINETMajorProgram__r.MJR_PROG_SH_NM__c),
 true, 
 null, 
 null,
 true, 
 String.valueOf(Integer.valueOf(finetProgramList[0].FINETMajorProgram__r.SUSP_STA__c)), 
 String.valueOf(Integer.valueOf(finetProgramList[0].FINETMajorProgram__r.REIM_BAS_IND__c)),
 String.valueOf(Integer.valueOf(finetProgramList[0].FINETMajorProgram__r.REIM_BUD_STRU_CD__c)), 
 String.valueOf(Integer.valueOf(finetProgramList[0].FINETMajorProgram__r.SPLT_IND__c)), 
 String.valueOf(Integer.valueOf(finetProgramList[0].FINETMajorProgram__r.FED_APPR_SETP__c)),
 String.valueOf(finetProgramList[0].FINETMajorProgram__r.MJR_PROG_NM__c));
      
 mjrprograms.add(mjrprogram);

    
      IntegCGIAdv_GCAM_ProgPhse_Budgt_Document.IntegCGIAdv_CAM_DOC_PROG_GCAM_ProgPhse_Budgt[] programs = new IntegCGIAdv_GCAM_ProgPhse_Budgt_Document.IntegCGIAdv_CAM_DOC_PROG_GCAM_ProgPhse_Budgt[]{};
      IntegCGIAdv_GCAM_ProgPhse_Budgt_Document.IntegCGIAdv_CAM_DOC_PROG_GCAM_ProgPhse_Budgt program =
      new IntegCGIAdv_GCAM_ProgPhse_Budgt_Document.IntegCGIAdv_CAM_DOC_PROG_GCAM_ProgPhse_Budgt(
      1,
      1,
      '2',
      String.valueOf(finetProgramList[0].PROG_CD__c),
      String.valueOf(finetProgramList[0].PROG_NM__c),
      String.valueOf(finetProgramList[0].PROG_SH_NM__c),
      true,
      true,
      String.ValueOf(Integer.valueOf(finetProgramList[0].FINETMajorProgram__r.SUSP_STA__c)),
      true,
      finetProgramList[0].BILL_AGREE_DT__c, 
      'V002A160045',
      String.valueOf(finetProgramList[0].SACCT_CD__c),
      finetProgramList[0].EFBGN_DT__c,
      finetProgramList[0].EFEND_DT__c,
      String.valueOf(finetProgramList[0].FINETProgramGroup__r.PGRP_CD__c), 
      String.valueOf(finetProgramList[0].FINETProgramType__r.PTYP_CD__c), 
      String.valueOf(finetProgramList[0].FINETProgramClass__r.PCLS_CD__c), 
      String.valueOf(finetProgramList[0].FINETProgramCategory__r.PCAT_CD__c),
      date.newInstance(2018, 10, 15));
      programs.add( program );
      
      IntegCGIAdv_GCAM_ProgPhse_Budgt_Document.IntegCGIAdv_CAM_DOC_PHSEPROG_GCAM_ProgPhse_Budgt[] programPhases = new IntegCGIAdv_GCAM_ProgPhse_Budgt_Document.IntegCGIAdv_CAM_DOC_PHSEPROG_GCAM_ProgPhse_Budgt[]{};
      IntegCGIAdv_GCAM_ProgPhse_Budgt_Document.IntegCGIAdv_CAM_DOC_PHSEPROG_GCAM_ProgPhse_Budgt programPhase =
      new IntegCGIAdv_GCAM_ProgPhse_Budgt_Document.IntegCGIAdv_CAM_DOC_PHSEPROG_GCAM_ProgPhse_Budgt(
      1,
      1,
      1,
      finetProgramList[0].LN_TYP__c,
      //String.valueOf(mfm.SubRecipient__r.LEA_Id__c),
      '000',
      String.valueOf(finetProgramList[0].PROG_CD__c),
      '',
      '',
      finetProgramList[0].EFBGN_DT__c,
      finetProgramList[0].EFEND_DT__c,
      finetProgramList[0].BILL_AGREE_DT__c,
      true,
      true,
      true,
      '2',
     // String.valueOf(mfm.SubRecipient__r.OrganizationName__c)
     'phase000');  
      programPhases.add( programPhase );                                                                                                                                                                                                                                                                                                                                                                                           
          
      IntegCGIAdv_GCAM_ProgPhse_Budgt_Document.IntegCGIAdv_CAM_DOC_FPI_GCAM_ProgPhse_Budgt[] FPIlines = new IntegCGIAdv_GCAM_ProgPhse_Budgt_Document.IntegCGIAdv_CAM_DOC_FPI_GCAM_ProgPhse_Budgt[]{};
      IntegCGIAdv_GCAM_ProgPhse_Budgt_Document.IntegCGIAdv_CAM_DOC_FPI_GCAM_ProgPhse_Budgt FPIline =
      new IntegCGIAdv_GCAM_ProgPhse_Budgt_Document.IntegCGIAdv_CAM_DOC_FPI_GCAM_ProgPhse_Budgt( 
      1,
      finetProgramList[0].LN_TYP__c,
      '2',
      String.valueOf(finetProgramList[0].PROG_CD__c),
      String.valueOf(finetProgramList[0].FundingInferenceProfile__r.FPRFL_CD__c),
      '1',
      //String.valueOf(mfm.SubRecipient__r.LEA_Id__c)
      '000');
      FPIlines.add( FPIline );
      
      IntegCGIAdv_GCAM_ProgPhse_Budgt_Document.IntegCGIAdv_CAM_DOC_BUDLN_GCAM_ProgPhse_Budgt[] Budgetlines = new IntegCGIAdv_GCAM_ProgPhse_Budgt_Document.IntegCGIAdv_CAM_DOC_BUDLN_GCAM_ProgPhse_Budgt[]{};
      
      if(finetProgramList[0].ProgramAmount__c < 0){
          IntegCGIAdv_GCAM_ProgPhse_Budgt_Document.IntegCGIAdv_CAM_DOC_BUDLN_GCAM_ProgPhse_Budgt Budgetline =
          new IntegCGIAdv_GCAM_ProgPhse_Budgt_Document.IntegCGIAdv_CAM_DOC_BUDLN_GCAM_ProgPhse_Budgt( 
          1,
          1,
          'BGPHR',
          '2',
          'BG22',
          'UtahGrants',
          null, 
          null,
         (finetProgramList[0].ProgramAmount__c*-1),
          String.valueOf(finetProgramList[0].PROG_CD__c),
         // String.valueOf(mfm.SubRecipient__r.LEA_Id__c),
         '000',
          'USBEST',
          '10', 
          '1',
          '2', 
          '2' );
      Budgetlines.add( Budgetline );   
      } 
      
      if(finetProgramList[0].ProgramAmount__c >= 0){ 
          IntegCGIAdv_GCAM_ProgPhse_Budgt_Document.IntegCGIAdv_CAM_DOC_BUDLN_GCAM_ProgPhse_Budgt Budgetline =
          new IntegCGIAdv_GCAM_ProgPhse_Budgt_Document.IntegCGIAdv_CAM_DOC_BUDLN_GCAM_ProgPhse_Budgt( 
          1,
          1, 
          'BGPHR', 
          '2',
          'BG22', 
          'UtahGrants',
          null, 
          null,
         finetProgramList[0].ProgramAmount__c,
         String.valueOf(finetProgramList[0].PROG_CD__c),
         //String.valueOf(mfm.SubRecipient__r.LEA_Id__c),
         '000',
         String.valueOf(finetProgramList[0].FundingInferenceProfile__r.FPRFL_CD__c),
         '10', 
         '1',
         '1', 
         '2' );
     Budgetlines.add( Budgetline );                                                                                                                                                                                                                                                                                                                                                                                        
                                                                                                                                                                                                                                                                                                                                                                     
       }
       a.createAMS_DOCUMENTwithDefaults( TRUE, '400', 'null', '18', header, mjrprograms, programs, programPhases, FPIlines, Budgetlines );
       system.debug(a.renderJSON(true));
       document doc = new document( FolderId=GetFolderHelper.getFolderId(), name = userinfo.getName() + 'Phase000GCAM' );
       doc.body =  blob.valueOf( a.renderJSON(true) );
       httpresponse r = IntegUtahGrantorAPI.postCreateProgramPhaseWithBudget(a);
       document doc1 = new document( FolderId=GetFolderHelper.getFolderId(), name = userinfo.getName() + 'Phase000GCAMResponse' );
       doc1.body =  blob.valueOf(r.getbody());
       String responseBody = r.getBody();
       
       GCAMProgramPhaseCreationBatch.IntegUtahResponse response = (GCAMProgramPhaseCreationBatch.IntegUtahResponse)JSON.deserialize(responseBody, GCAMProgramPhaseCreationBatch.IntegUtahResponse.class);
       
       IntegCGIAdv_ProgPhasBud_Transmit_Files transmittal = new IntegCGIAdv_ProgPhasBud_Transmit_Files();
       transmittal.addTranmittal(response.filename,'400','18','18',1,finetProgramList[0].ProgramAmount__c,'swati.singh@reisystems.com' );
       httpresponse r1 = IntegUtahGrantorAPI.postProgramPhaseBudgetTransmittalFile(transmittal);
          document doc2 = new document( FolderId=GetFolderHelper.getFolderId(), name = userinfo.getName() + 'TempTransmittal' );
          doc2.body =  blob.valueOf(transmittal.renderJSON(true));
          document doc3 = new document( FolderId=GetFolderHelper.getFolderId(), name = userinfo.getName() + 'TempTransmittalResponse' );
          doc3.body =  blob.valueOf(r1.getbody());
          
          insert doc; 
          insert doc1;
          insert doc2;
          insert doc3;
          }
       
    
    /* Public class */
        public class IntegUtahResponse {
        public string message {get;set;}
        public string status {get;set;}
        public string filename {get;set;}
       
        
        }
}