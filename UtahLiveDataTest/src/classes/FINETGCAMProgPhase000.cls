public class FINETGCAMProgPhase000 {
  
  
  // PUBLIC CONSTRUCTORS
    public FINETGCAMProgPhase000(){
    
    }
    // PUBLIC METHODS
  @Future(callout=true)
  public static void gcamPhase000(Id finetProgId,Decimal oldAmount){
  ////REIM_ELG_STA__c,SUSP_STA__c,
  List<r_prog__c> finetProgramList = [SELECT id,name,AREA__c,AutoGenerate__c,BILL_AGREE_DT__c,BoardEntity__c,BuildingNumber__c,Corridor__c,County__c,DEPT_CD__c,EFBGN_DT__c,EFEND_DT__c,Entity__c,FederalAidProjectNumber__c,FINETMajorProgram__c,FINETProgramGroup__r.PGRP_CD__c,FINETProgramType__r.PTYP_CD__c,FINETProgramClass__r.PCLS_CD__c,FINETProgramCategory__r.PCAT_CD__c,FiscalApprover__c,HighwayFunctionalClass__c,IndianReservation__c,LegislativeEntity__c,MilePostEnd__c,MilePostStart__c,ParcelNumber__c,Prefix__c,ProgramApprover__c,PROG_CD__c,PROG_NM__c,Program__c,PROG_SH_NM__c,ProjectAgreementNumber__c,SecondaryRoadPlan__c,Station__c,Status__c,WorkDescription__c,FINETMajorProgram__r.DEPT_CD__r.code__c,FINETMajorProgram__r.FED_APPR_SETP__c,
                                            FINETMajorProgram__r.EffectiveFrom__c,FINETMajorProgram__r.EffectiveTo__c,FINETMajorProgram__r.MJR_PROG_CD__c,FINETMajorProgram__r.MJR_PROG_NM__c,
                                            FINETMajorProgram__r.MJR_PROG_SH_NM__c,FINETMajorProgram__r.ReclassExclusion__c,
                                            FINETMajorProgram__r.REIM_BAS_IND__c,FINETMajorProgram__r.REIM_BUD_STRU_CD__c,FINETMajorProgram__r.SPLT_IND__c,FINETMajorProgram__r.StageDefinition__c,FINETMajorProgram__r.ACT_FL__c,FINETMajorProgram__r.ALW_BUD_FL__c,
                                            FINETMajorProgram__r.StreamlinedTaskOrderBilling__c,FINETMajorProgram__r.SUSP_STA__c ,PROJ_END_DT__c,LN_TYP__c,ProgramAmount__c,FundingInferenceProfile__r.FPRFL_CD__c,OldProgramAmount__c,ACT_FL__c,ALW_BUD_FL__c,SACCT_CD__c,REIM_ELG_STA__c,SUSP_STA__c
                                            FROM r_prog__c
                                             where id =:finetProgId limit 1];
                       
  Set<Id> finetProgIds = new Set<Id>();
     for(r_prog__c fp: finetProgramList){
              finetProgIds.add(fp.Id);
            }
            
  system.debug('old amt>>>'+oldAmount); 
  system.debug('new amt>>>'+finetProgramList[0].ProgramAmount__c);                                      
  String LN_TYP; 
  Decimal LN_AM;
  String INCR_DCRS_IND;
  Integer LN_ACTN;                                    
 /* if(finetProgramList[0].OldProgramAmount__c == 0){
      LN_TYP = '1';
      LN_ACTN = 1;
      INCR_DCRS_IND = '1';
      LN_AM = finetProgramList[0].ProgramAmount__c;
      system.debug('first time>>>>'+LN_TYP+LN_ACTN+INCR_DCRS_IND+LN_AM);
  } else if(finetProgramList[0].OldProgramAmount__c < finetProgramList[0].ProgramAmount__c){
      LN_TYP = '2';
      LN_ACTN = 2;
      INCR_DCRS_IND = '1';
      LN_AM = finetProgramList[0].ProgramAmount__c - finetProgramList[0].OldProgramAmount__c;
      system.debug('increased amt>>>>'+LN_TYP+LN_ACTN+INCR_DCRS_IND+LN_AM);
  } else if(finetProgramList[0].OldProgramAmount__c > finetProgramList[0].ProgramAmount__c) {
      LN_TYP = '2';
      LN_ACTN = 2;
      INCR_DCRS_IND = '2';
      LN_AM = finetProgramList[0].OldProgramAmount__c - finetProgramList[0].ProgramAmount__c;
      system.debug('decrease amt>>>>'+LN_TYP+LN_ACTN+INCR_DCRS_IND+LN_AM);
  }  */ 
  
  if(oldAmount == 0){
      LN_TYP = '1';
      LN_ACTN = 1;
      INCR_DCRS_IND = '1';
      LN_AM = finetProgramList[0].ProgramAmount__c;
      system.debug('first time>>>>'+LN_TYP+LN_ACTN+INCR_DCRS_IND+LN_AM);
  } else if(oldAmount < finetProgramList[0].ProgramAmount__c){
      LN_TYP = '2';
      LN_ACTN = 2;
      INCR_DCRS_IND = '1';
      LN_AM = finetProgramList[0].ProgramAmount__c - oldAmount;
      system.debug('increased amt>>>>'+LN_TYP+LN_ACTN+INCR_DCRS_IND+LN_AM);
  } else if(oldAmount > finetProgramList[0].ProgramAmount__c) {
      LN_TYP = '2';
      LN_ACTN = 2;
      INCR_DCRS_IND = '2';
      LN_AM = oldAmount - finetProgramList[0].ProgramAmount__c;
      system.debug('decrease amt>>>>'+LN_TYP+LN_ACTN+INCR_DCRS_IND+LN_AM);
  }  
  
  Boolean mjrProgActiveFlag;
  Boolean mjrProgBudgetFlag; 
          
        if(finetProgramList[0].FINETMajorProgram__r.ACT_FL__c == 1.0){
        mjrProgActiveFlag = true;
        } else{
        mjrProgActiveFlag = false;
        }
        if(finetProgramList[0].FINETMajorProgram__r.ALW_BUD_FL__c == 1.0){
        mjrProgBudgetFlag = true;
        }else{
        mjrProgBudgetFlag = false;
        }
        
        Boolean ProgActiveFlag;
        Boolean ProgBudgetFlag; 
        if(finetProgramList[0].ACT_FL__c == 'True'){
        ProgActiveFlag = true;
        } else{
        ProgActiveFlag = false;
        }
        if(finetProgramList[0].ALW_BUD_FL__c == 'True'){
        ProgBudgetFlag = true;
        } else{
        ProgBudgetFlag = false;
        }
        
        String progSuspStatus;
        if(finetProgramList[0].SUSP_STA__c == 'Allowed for Reimbursement'){
        progSuspStatus = '2';
        } else{
        progSuspStatus = '1';
        } 
                                       
                                         
 IntegCGIAdv_GCAM_ProgPhse_Budgt_Document a = new IntegCGIAdv_GCAM_ProgPhse_Budgt_Document('400');
 String DOC_ID = String.valueOf(GAXPaymentCreationBatch.getRandomUnique());
 IntegCGIAdv_GCAM_ProgPhse_Budgt_Document.IntegCGIAdv_CAM_DOC_HDR_GCAM_ProgPhse_Budgt header = 
 new IntegCGIAdv_GCAM_ProgPhse_Budgt_Document.IntegCGIAdv_CAM_DOC_HDR_GCAM_ProgPhse_Budgt(DOC_ID);
 
 IntegCGIAdv_GCAM_ProgPhse_Budgt_Document.IntegCGIAdv_CAM_DOC_MJRPROG_GCAM_ProgPhse_Budgt[] mjrprograms = new IntegCGIAdv_GCAM_ProgPhse_Budgt_Document.IntegCGIAdv_CAM_DOC_MJRPROG_GCAM_ProgPhse_Budgt[]{};
 IntegCGIAdv_GCAM_ProgPhse_Budgt_Document.IntegCGIAdv_CAM_DOC_MJRPROG_GCAM_ProgPhse_Budgt mjrprogram = 
 new IntegCGIAdv_GCAM_ProgPhse_Budgt_Document.IntegCGIAdv_CAM_DOC_MJRPROG_GCAM_ProgPhse_Budgt( 
 1,
'400',
 String.valueOf(finetProgramList[0].FINETMajorProgram__r.MJR_PROG_CD__c), 
 String.valueOf(finetProgramList[0].FINETMajorProgram__r.MJR_PROG_NM__c), 
 String.valueOf(finetProgramList[0].FINETMajorProgram__r.MJR_PROG_SH_NM__c),
 mjrProgActiveFlag, 
 finetProgramList[0].FINETMajorProgram__r.EffectiveFrom__c, 
 finetProgramList[0].FINETMajorProgram__r.EffectiveTo__c,
 mjrProgBudgetFlag, 
 String.valueOf(finetProgramList[0].FINETMajorProgram__r.SUSP_STA__c), 
 String.valueOf(finetProgramList[0].FINETMajorProgram__r.REIM_BAS_IND__c),
 String.valueOf(finetProgramList[0].FINETMajorProgram__r.REIM_BUD_STRU_CD__c), 
 String.valueOf(finetProgramList[0].FINETMajorProgram__r.SPLT_IND__c), 
 String.valueOf(finetProgramList[0].FINETMajorProgram__r.FED_APPR_SETP__c),
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
      ProgActiveFlag,
      ProgBudgetFlag,
      progSuspStatus,
      finetProgramList[0].REIM_ELG_STA__c,
      finetProgramList[0].BILL_AGREE_DT__c, 
      'prog description',
      String.valueOf(finetProgramList[0].SACCT_CD__c),
      finetProgramList[0].EFBGN_DT__c,
      finetProgramList[0].EFEND_DT__c,
      String.valueOf(finetProgramList[0].FINETProgramGroup__r.PGRP_CD__c), 
      String.valueOf(finetProgramList[0].FINETProgramType__r.PTYP_CD__c), 
      String.valueOf(finetProgramList[0].FINETProgramClass__r.PCLS_CD__c), 
      String.valueOf(finetProgramList[0].FINETProgramCategory__r.PCAT_CD__c),
     // String.valueOf(finetProgramList[0].AREA__c),
      finetProgramList[0].PROJ_END_DT__c);
      programs.add( program );
      
      IntegCGIAdv_GCAM_ProgPhse_Budgt_Document.IntegCGIAdv_CAM_DOC_PHSEPROG_GCAM_ProgPhse_Budgt[] programPhases = new IntegCGIAdv_GCAM_ProgPhse_Budgt_Document.IntegCGIAdv_CAM_DOC_PHSEPROG_GCAM_ProgPhse_Budgt[]{};
      IntegCGIAdv_GCAM_ProgPhse_Budgt_Document.IntegCGIAdv_CAM_DOC_PHSEPROG_GCAM_ProgPhse_Budgt programPhase =
      new IntegCGIAdv_GCAM_ProgPhse_Budgt_Document.IntegCGIAdv_CAM_DOC_PHSEPROG_GCAM_ProgPhse_Budgt(
      1,
      1,
      1,
      LN_TYP,
      //String.valueOf(mfm.SubRecipient__r.LEA_Id__c),
      '000',
      String.valueOf(finetProgramList[0].PROG_CD__c),
      '',
     // siteLocation,
     '',
      finetProgramList[0].EFBGN_DT__c,
      finetProgramList[0].EFEND_DT__c,
      finetProgramList[0].BILL_AGREE_DT__c,
      ProgActiveFlag,
      ProgBudgetFlag,
      finetProgramList[0].REIM_ELG_STA__c,
      progSuspStatus,
     // String.valueOf(mfm.SubRecipient__r.OrganizationName__c)
     'phase000');  
      programPhases.add( programPhase );                                                                                                                                                                                                                                                                                                                                                                                           
          
      IntegCGIAdv_GCAM_ProgPhse_Budgt_Document.IntegCGIAdv_CAM_DOC_FPI_GCAM_ProgPhse_Budgt[] FPIlines = new IntegCGIAdv_GCAM_ProgPhse_Budgt_Document.IntegCGIAdv_CAM_DOC_FPI_GCAM_ProgPhse_Budgt[]{};
      IntegCGIAdv_GCAM_ProgPhse_Budgt_Document.IntegCGIAdv_CAM_DOC_FPI_GCAM_ProgPhse_Budgt FPIline =
      new IntegCGIAdv_GCAM_ProgPhse_Budgt_Document.IntegCGIAdv_CAM_DOC_FPI_GCAM_ProgPhse_Budgt( 
      1,
      LN_TYP,
      '2',
      String.valueOf(finetProgramList[0].PROG_CD__c),
      String.valueOf(finetProgramList[0].FundingInferenceProfile__r.FPRFL_CD__c),
      '1',
      //String.valueOf(mfm.SubRecipient__r.LEA_Id__c)
      '000');
      FPIlines.add( FPIline );
      
      IntegCGIAdv_GCAM_ProgPhse_Budgt_Document.IntegCGIAdv_CAM_DOC_BUDLN_GCAM_ProgPhse_Budgt[] Budgetlines = new IntegCGIAdv_GCAM_ProgPhse_Budgt_Document.IntegCGIAdv_CAM_DOC_BUDLN_GCAM_ProgPhse_Budgt[]{};
      IntegCGIAdv_GCAM_ProgPhse_Budgt_Document.IntegCGIAdv_CAM_DOC_BUDLN_GCAM_ProgPhse_Budgt Budgetline =
          new IntegCGIAdv_GCAM_ProgPhse_Budgt_Document.IntegCGIAdv_CAM_DOC_BUDLN_GCAM_ProgPhse_Budgt( 
          1,
          LN_ACTN, 
          'BGPHR', 
          '40',
          'BG22', 
          'UtahGrants',
          null, 
          null,
          LN_AM,
         String.valueOf(finetProgramList[0].PROG_CD__c),
         //String.valueOf(mfm.SubRecipient__r.LEA_Id__c),
         '000',
         String.valueOf(finetProgramList[0].FundingInferenceProfile__r.FPRFL_CD__c),
         '10', 
         '1',
         INCR_DCRS_IND, 
         '2' );
     Budgetlines.add( Budgetline );                                                                                                                                                                                                                                                                                                                                                                                        
                                                                                                                                                                                                                                                                                                                                                                     
       
       a.createAMS_DOCUMENTwithDefaults( TRUE, '400', 'null',String.valueOf(FiscalYearHelper.getFiscalYearShort(System.today())), header, mjrprograms, programs, programPhases, FPIlines, Budgetlines );
       system.debug(a.renderJSON(true));
       document doc = new document( FolderId=GetFolderHelper.getFolderId(), name = userinfo.getName() + 'Phase000GCAM' );
       doc.body =  blob.valueOf( a.renderJSON(true) );
      // webCallout(a.renderJSON(false),LN_AM);
       httpresponse r = IntegUtahGrantorAPI.postCreateProgramPhaseWithBudget(a);
       document doc1 = new document(FolderId=GetFolderHelper.getFolderId(), name = userinfo.getName() + 'Phase000GCAMResponse' );
       doc1.body =  blob.valueOf(r.getbody());
       String responseBody = r.getBody();
       
       GCAMProgramPhaseCreationBatch.IntegUtahResponse response = (GCAMProgramPhaseCreationBatch.IntegUtahResponse)JSON.deserialize(responseBody, GCAMProgramPhaseCreationBatch.IntegUtahResponse.class);
       
       IntegCGIAdv_ProgPhasBud_Transmit_Files transmittal = new IntegCGIAdv_ProgPhasBud_Transmit_Files();
       transmittal.addTranmittal(response.filename,'400',String.valueOf(FiscalYearHelper.getFiscalYearShort(System.today())),String.valueOf(FiscalYearHelper.getFiscalYearShort(System.today())),1,LN_AM,'swati.singh@reisystems.com' );
       httpresponse r1 = IntegUtahGrantorAPI.postProgramPhaseBudgetTransmittalFile(transmittal);
          document doc2 = new document( FolderId=GetFolderHelper.getFolderId(), name = userinfo.getName() + 'TempTransmittal' );
          doc2.body =  blob.valueOf(transmittal.renderJSON(true));
          document doc3 = new document( FolderId=GetFolderHelper.getFolderId(), name = userinfo.getName() + 'TempTransmittalResponse' );
          doc3.body =  blob.valueOf(r1.getbody());
          
          insert doc; 
          insert doc1;
          insert doc2;
          insert doc3;

       IntegUtahGrantsAPI.GrantsAPIDocumentStatus docStatus = new IntegUtahGrantsAPI.GrantsAPIDocumentStatus(DOC_ID,'GCAM','400',finetProgIds);
       docStatus.insertRecords(datetime.now(),a.renderJSON(true));

      
          
          } 

       @Future(callout=true)
       private static void webCallout(String jsonString, Decimal LN_AM ){
                      
            IntegCGIAdv_GCAM_ProgPhse_Budgt_Document curr;
            curr = (IntegCGIAdv_GCAM_ProgPhse_Budgt_Document) JSON.deserialize(jsonString,IntegCGIAdv_GCAM_ProgPhse_Budgt_Document.class);
            httpresponse r = IntegUtahGrantorAPI.postCreateProgramPhaseWithBudget(curr);
            document doc1 = new document( FolderId=GetFolderHelper.getFolderId(), name = userinfo.getName() + 'Phase000GCAMResponse' );
            doc1.body =  blob.valueOf(r.getbody());
            String responseBody = r.getBody();
       
       GCAMProgramPhaseCreationBatch.IntegUtahResponse response = (GCAMProgramPhaseCreationBatch.IntegUtahResponse)JSON.deserialize(responseBody, GCAMProgramPhaseCreationBatch.IntegUtahResponse.class);
       
       IntegCGIAdv_ProgPhasBud_Transmit_Files transmittal = new IntegCGIAdv_ProgPhasBud_Transmit_Files();
       transmittal.addTranmittal(response.filename,'400','18','18',1,LN_AM,'swati.singh@reisystems.com' );
       httpresponse r1 = IntegUtahGrantorAPI.postProgramPhaseBudgetTransmittalFile(transmittal);
          document doc2 = new document( FolderId=GetFolderHelper.getFolderId(), name = userinfo.getName() + 'TempTransmittal' );
          doc2.body =  blob.valueOf(transmittal.renderJSON(true));
          document doc3 = new document( FolderId=GetFolderHelper.getFolderId(), name = userinfo.getName() + 'TempTransmittalResponse' );
          doc3.body =  blob.valueOf(r1.getbody());
          
          
          insert doc1;
          insert doc2;
          insert doc3;
          
    

       
       } 
          
    }