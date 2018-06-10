global class GCAMProgramPhaseCreationBatch implements Database.Batchable<sObject>, Database.Stateful,Database.AllowsCallouts {
  public String query;
  public List<String> errors;
  public FileBatch__c fb;
  public Grants_API_Document_Status__c gads;
  public IntegUtahGrantsAPI.GrantsAPIDocumentStatus docStatus;
  public integer counter = 0;
  public List<String> finetProgCodes;
  public List<String> finetCodeSet;
  public List<IntegUtahGrantsAPI.GrantsAPIDocumentStatus> docStatusList;

global GCAMProgramPhaseCreationBatch(FileBatch__c fb){
  this.fb = fb;
 
}

global GCAMProgramPhaseCreationBatch(FileBatch__c fb,List<String> finetProgCodes){
  this.fb = fb;
  this.finetProgCodes = finetProgCodes;
  finetCodeSet = new List<String>();
  docStatusList = new List<IntegUtahGrantsAPI.GrantsAPIDocumentStatus>();
}

  global Database.QueryLocator start(Database.BatchableContext BC){
    try{
        errors = new List<String>();
        String allstring = String.join(finetProgCodes,'\',\'');
        allstring = '(\'' + allstring + '\')';
       
      //Shivankar: Important Note. 
     //Add to query below: ACT_FL__c,,ALW_BUD_FL__c
     //Removed it from query while changing the type of ACT_FL__c,ALW_BUD_FL__c, to picklist. ////ReimbEligible__c,ReimbStatus__c,
     
      query = 'SELECT id,FINETMajorProgram__c,FINETMajorProgram__r.MJR_PROG_CD__c,AllocatedAmount__c,AREA__c,AutoGenerate__c,AwardedAmount__c,BILL_AGREE_DT__c,BoardEntity__c,BuildingNumber__c,Corridor__c,County__c,DEPT_CD__c,EFBGN_DT__c,EFEND_DT__c,Entity__c,FederalAidProjectNumber__c,FINETProgramCategory__c,FINETProgramClass__c,FINETProgramGroup__c,FINETProgramType__c,HighwayFunctionalClass__c,Name,Program__c,PROG_CD__c,PROG_NM__c,PROG_SH_NM__c,ProjectAgreementNumber__c,REIM_ELG_STA__c,SUSP_STA__c,RemainingAmount__c,SecondaryRoadPlan__c,StateOldKey__c,Station__c,Status__c,SACCT_CD__c,WorkDescription__c,FINETMajorProgram__r.SUSP_STA__c FROM r_prog__c where status__c IN(\'Active\') AND PROG_CD__c IN ' + allstring + ' ORDER BY PROG_CD__c ASC';
     // query = 'SELECT id,FINETMajorProgram__c,FINETMajorProgram__r.MJR_PROG_CD__c,AllocatedAmount__c,AREA__c,AutoGenerate__c,AwardedAmount__c,BILL_AGREE_DT__c,BoardEntity__c,BuildingNumber__c,Corridor__c,County__c,DEPT_CD__c,EFBGN_DT__c,EFEND_DT__c,Entity__c,FederalAidProjectNumber__c,FINETProgramCategory__c,FINETProgramClass__c,FINETProgramGroup__c,FINETProgramType__c,HighwayFunctionalClass__c,Name,Program__c,PROG_CD__c,PROG_NM__c,PROG_SH_NM__c,ProjectAgreementNumber__c,REIM_ELG_STA__c,SUSP_STA__c,RemainingAmount__c,SecondaryRoadPlan__c,StateOldKey__c,Station__c,Status__c,SACCT_CD__c,WorkDescription__c,FINETMajorProgram__r.SUSP_STA__c FROM r_prog__c where status__c IN(\'Active\') AND PROG_CD__c IN(\'31ABC\')';
      return Database.getQueryLocator(query);
    }catch(Exception e){
      errors.add(e.getMessage());
      return null;
    }
  }

  global void execute(Database.BatchableContext BC, List<r_prog__c> scope){
   // Savepoint sp = Database.setSavepoint();

    if(scope == null){
      return;
    }

    try{
     
      Set<String> keySet = new Set<String>();
      for(r_prog__c finetProg : scope){
        keySet.add(finetProg.PROG_CD__c);
      } 
      
      system.debug('keySet >>>'+keySet);
     // List<MSPFinancialStage__c> mfmList = [SELECT Id, program__r.account__r.code__c,SubRecipient__r.LEA_Id__c,SubRecipient__r.OrganizationName__c,SubRecipient__r.SITE_LOC_CD__c,Program__r.ProgramKey__c, AwardAmount__c,DeltaAmount__c, DisplayOrder__c, ObjectCode__c, Program__c, ProgramCode__c, SubRecipient__c, UniqueKeyFormula__c, AwardAmountFormula__c, ProgramComment__c, LEAComment__c FROM MSPFinancialStage__c WHERE ProgramCode__c IN :keySet and FileBatch__c = :fb.Id];
     AggregateResult[] mfmList =[SELECT SUM(AwardAmountFormula__c),SUM(DeltaAmount__c),SUM(OldAwardedAmount__c),ObjectCode__c, ProgramCode__c, SubRecipient__r.LEA_ID__c lea,SubRecipient__r.SITE_LOC_CD__c site,SubRecipient__r.name name FROM MSPFinancialStage__c WHERE ProgramCode__c IN :keySet and FileBatch__c = :fb.Id GROUP BY ProgramCode__c,ObjectCode__c,SubRecipient__r.LEA_ID__c,SubRecipient__r.SITE_LOC_CD__c ,SubRecipient__r.name Having SUM(DeltaAmount__c) !=0];
 
      system.debug('mfmList >>>'+mfmList);
      if(mfmList.size() !=0 && mfmList.size() >0)
      {
      Set<String> programCodeSet = new Set<String>();
      for(AggregateResult mfm : mfmList){
        programCodeSet.add(String.valueOf(mfm.get('ProgramCode__c')));
      }
      system.debug('programCodeSet >>>'+programCodeSet);
      
      //Shivankar: Important Note. 
     //Add this to query below: ACT_FL__c,ALW_BUD_FL__c,
     //Removed from query while changing the type of ACT_FL__c,ALW_BUD_FL__c, to picklist. ////ReimbEligible__c,ReimbStatus__c,
     
      List<r_prog__c> finetProgramList =[SELECT AllocatedAmount__c,AREA__c,AutoGenerate__c,AwardedAmount__c,BILL_AGREE_DT__c,BoardEntity__c,BuildingNumber__c,Corridor__c,County__c,DEPT_CD__c,EFBGN_DT__c,EFEND_DT__c,Entity__c,FederalAidProjectNumber__c,FINETMajorProgram__c,FINETMajorProgram__r.MJR_PROG_CD__c,FINETMajorProgram__r.MJR_PROG_NM__c,FINETMajorProgram__r.MJR_PROG_SH_NM__c,FINETProgramCategory__c,FINETProgramClass__c,FINETProgramGroup__c,FINETProgramType__c,HighwayFunctionalClass__c,Id,
      Name,Program__c,PROG_CD__c,PROG_NM__c,PROG_SH_NM__c,ProjectAgreementNumber__c,RemainingAmount__c,PROJ_END_DT__c,SACCT_CD__c,REIM_ELG_STA__c,SUSP_STA__c,
      SecondaryRoadPlan__c,StateOldKey__c,Station__c,Status__c,WorkDescription__c,FINETMajorProgram__r.SUSP_STA__c,FINETMajorProgram__r.REIM_BAS_IND__c,FINETMajorProgram__r.REIM_BUD_STRU_CD__c,FINETMajorProgram__r.SPLT_IND__c,FINETMajorProgram__r.FED_APPR_SETP__c,FINETMajorProgram__r.EffectiveFrom__c,FINETMajorProgram__r.EffectiveTo__c,FINETMajorProgram__r.ACT_FL__c,FINETMajorProgram__r.ALW_BUD_FL__c,
      FINETProgramCategory__r.PCAT_CD__c,FINETProgramClass__r.PCLS_CD__c,FINETProgramGroup__r.PGRP_CD__c,FINETProgramType__r.PTYP_CD__c,FundingInferenceProfile__r.FPRFL_CD__c,ACT_FL__c,ALW_BUD_FL__c,DEPT_CD__r.code__c
      FROM r_prog__c where PROG_CD__c IN :programCodeSet limit 1];
     
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
                    
        
      Map<String,r_prog__c> finetProgramMap = new Map<String,r_prog__c>();
        
      for(r_prog__c finetProgram :finetProgramList){
        finetProgramMap.put(finetProgram.PROG_CD__c,finetProgram);
      }
      
      IntegCGIAdv_GCAM_ProgPhse_Budgt_Document a = new IntegCGIAdv_GCAM_ProgPhse_Budgt_Document(String.valueOf(finetProgramList[0].DEPT_CD__r.code__c));
      String DOC_ID = String.valueOf(GAXPaymentCreationBatch.getRandomUnique());
      IntegCGIAdv_GCAM_ProgPhse_Budgt_Document.IntegCGIAdv_CAM_DOC_HDR_GCAM_ProgPhse_Budgt header = 
      new IntegCGIAdv_GCAM_ProgPhse_Budgt_Document.IntegCGIAdv_CAM_DOC_HDR_GCAM_ProgPhse_Budgt(DOC_ID);
                
      IntegCGIAdv_GCAM_ProgPhse_Budgt_Document.IntegCGIAdv_CAM_DOC_MJRPROG_GCAM_ProgPhse_Budgt[] mjrprograms = new IntegCGIAdv_GCAM_ProgPhse_Budgt_Document.IntegCGIAdv_CAM_DOC_MJRPROG_GCAM_ProgPhse_Budgt[]{};
      IntegCGIAdv_GCAM_ProgPhse_Budgt_Document.IntegCGIAdv_CAM_DOC_MJRPROG_GCAM_ProgPhse_Budgt mjrprogram = 
      new IntegCGIAdv_GCAM_ProgPhse_Budgt_Document.IntegCGIAdv_CAM_DOC_MJRPROG_GCAM_ProgPhse_Budgt( 
      1,
      String.valueOf(finetProgramList[0].DEPT_CD__r.code__c),
      String.valueOf(finetProgramList[0].FINETMajorProgram__r.MJR_PROG_CD__c),
      String.valueOf(finetProgramList[0].FINETMajorProgram__r.MJR_PROG_NM__c),
      String.valueOf(finetProgramList[0].FINETMajorProgram__r.MJR_PROG_SH_NM__c),
      mjrProgActiveFlag, 
      finetProgramList[0].FINETMajorProgram__r.EffectiveFrom__c, 
      finetProgramList[0].FINETMajorProgram__r.EffectiveTo__c,
      mjrProgBudgetFlag, 
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
      String.valueOf(mfmList[0].get('ProgramCode__c')),
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
      //String.valueOf(finetProgramList[0].AREA__c),
      finetProgramList[0].PROJ_END_DT__c);
      programs.add( program );
      
      IntegCGIAdv_GCAM_ProgPhse_Budgt_Document.IntegCGIAdv_CAM_DOC_PHSEPROG_GCAM_ProgPhse_Budgt[] programPhases = new IntegCGIAdv_GCAM_ProgPhse_Budgt_Document.IntegCGIAdv_CAM_DOC_PHSEPROG_GCAM_ProgPhse_Budgt[]{};
      IntegCGIAdv_GCAM_ProgPhse_Budgt_Document.IntegCGIAdv_CAM_DOC_FPI_GCAM_ProgPhse_Budgt[] FPIlines = new IntegCGIAdv_GCAM_ProgPhse_Budgt_Document.IntegCGIAdv_CAM_DOC_FPI_GCAM_ProgPhse_Budgt[]{};
      IntegCGIAdv_GCAM_ProgPhse_Budgt_Document.IntegCGIAdv_CAM_DOC_BUDLN_GCAM_ProgPhse_Budgt[] Budgetlines = new IntegCGIAdv_GCAM_ProgPhse_Budgt_Document.IntegCGIAdv_CAM_DOC_BUDLN_GCAM_ProgPhse_Budgt[]{};
      
      integer i = 1;
      Decimal totalAmount = 0.00;
      Decimal totalAmountGCAM = 0.00;
      for(AggregateResult mfm :mfmList){
      /* Amendment line type logic */
      Decimal oldAmount = (Decimal)mfm.get('expr2');
      Decimal CurrentAmount = (Decimal)mfm.get('expr0');
      String LN_TYP;
      if(oldAmount == 0.0){
      LN_TYP = '1';
      } else {
      LN_TYP = '2';
      }
      /*****************************/
      
      
      r_prog__c finetPorgram = finetProgramMap.get(String.valueOf(mfm.get('ProgramCode__c')));
   
       IntegCGIAdv_GCAM_ProgPhse_Budgt_Document.IntegCGIAdv_CAM_DOC_PHSEPROG_GCAM_ProgPhse_Budgt programPhase =
       new IntegCGIAdv_GCAM_ProgPhse_Budgt_Document.IntegCGIAdv_CAM_DOC_PHSEPROG_GCAM_ProgPhse_Budgt(
       1,
       1,
       i,
       LN_TYP,
       String.valueOf(mfm.get('lea')),
       String.valueOf(mfm.get('ProgramCode__c')),
       //String.valueOf(finetPorgram.SACCT_CD__c),
       '',
       String.valueOf(mfm.get('site')),
       finetPorgram.EFBGN_DT__c,
       finetPorgram.EFEND_DT__c,
       finetPorgram.BILL_AGREE_DT__c,
       ProgActiveFlag,
       ProgBudgetFlag,
       finetPorgram.REIM_ELG_STA__c,
       progSuspStatus,
       String.valueOf(mfm.get('name')));                                                                                                                                                                                                                                                                                  
       programPhases.add( programPhase );                                                                                                                                                                                                                                                                                                                                                                                           
                                                                                                                                                                                                                                                                                                                                                                                                   
       IntegCGIAdv_GCAM_ProgPhse_Budgt_Document.IntegCGIAdv_CAM_DOC_FPI_GCAM_ProgPhse_Budgt FPIline =
       new IntegCGIAdv_GCAM_ProgPhse_Budgt_Document.IntegCGIAdv_CAM_DOC_FPI_GCAM_ProgPhse_Budgt( 
       i,
       LN_TYP,
       '2',
       String.valueOf(mfm.get('ProgramCode__c')),
       String.valueOf(finetPorgram.FundingInferenceProfile__r.FPRFL_CD__c), 
       '1',
       String.valueOf(mfm.get('lea')));
       FPIlines.add( FPIline );
      
      if((Decimal)(mfm.get('expr1')) < 0){
      IntegCGIAdv_GCAM_ProgPhse_Budgt_Document.IntegCGIAdv_CAM_DOC_BUDLN_GCAM_ProgPhse_Budgt Budgetline =
      new IntegCGIAdv_GCAM_ProgPhse_Budgt_Document.IntegCGIAdv_CAM_DOC_BUDLN_GCAM_ProgPhse_Budgt( 
      i,
      integer.ValueOf(LN_TYP), 
      'BGPHR', 
      '40',
      'BG22', 
      'UtahGrants',
      null, 
      null,
      ((Decimal)(mfm.get('expr1'))*-1),
      String.valueOf(mfm.get('ProgramCode__c')),
      String.valueOf(mfm.get('lea')),
      String.valueOf(finetPorgram.FundingInferenceProfile__r.FPRFL_CD__c),
      '10', 
      '1',
      '2', 
      '2' );
       Budgetlines.add( Budgetline );   
      } 
      if((Decimal)(mfm.get('expr1')) >= 0){ 
       IntegCGIAdv_GCAM_ProgPhse_Budgt_Document.IntegCGIAdv_CAM_DOC_BUDLN_GCAM_ProgPhse_Budgt Budgetline =
       new IntegCGIAdv_GCAM_ProgPhse_Budgt_Document.IntegCGIAdv_CAM_DOC_BUDLN_GCAM_ProgPhse_Budgt( 
       i,
       integer.ValueOf(LN_TYP), 
       'BGPHR', 
       '40',
       'BG22', 
       'UtahGrants',
       null, 
       null,
       ((Decimal)(mfm.get('expr1'))),
       String.valueOf(mfm.get('ProgramCode__c')),
       String.valueOf(mfm.get('lea')),
       String.valueOf(finetPorgram.FundingInferenceProfile__r.FPRFL_CD__c),
       '10', 
       '1',
       '1', 
       '2' );
       Budgetlines.add( Budgetline );                                                                                                                                                                                                                                                                                                                                                                                        
                                                                                                                                                                                                                                                                                                                                                                        
       }                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              
       i = i+1;
       Decimal amount;
       if((Decimal)(mfm.get('expr1'))<0){
       amount = (Decimal)(mfm.get('expr1')) *-1;
       } else{
       amount = (Decimal)(mfm.get('expr1'));
       }
         totalAmount = totalAmount+(Decimal)(mfm.get('expr1'));
         totalAmountGCAM = totalAmountGCAM+amount;                                                             
      }
      system.debug('totalAmount>>>final'+ totalAmount); 
      Decimal transmittalAmount;
      if(totalAmount < 0){
          transmittalAmount = totalAmount*-1;
      } else{
          transmittalAmount = totalAmount;
      }
      a.createAMS_DOCUMENTwithDefaults( TRUE,String.valueOf(finetProgramList[0].DEPT_CD__r.code__c), 'null',String.valueOf(FiscalYearHelper.getFiscalYearShort(System.today())), header, mjrprograms, programs, programPhases, FPIlines, Budgetlines );
      system.debug(a.renderJSON(true));
     

    
      document doc = new document( FolderId=GetFolderHelper.getFolderId(), name = userinfo.getName() + 'GCAMnow' );
     
      doc.body =  blob.valueOf( a.renderJSON(true) );
      
        httpresponse r = IntegUtahGrantorAPI.postCreateProgramPhaseWithBudget(a);
        document doc4 = new document( FolderId=GetFolderHelper.getFolderId(), name = userinfo.getName() + 'GCAMResponse' );
     
        doc4.body =  blob.valueOf(r.getbody());
      
        system.debug('response from server'+ r); 
        system.debug(r.getbody()); 
        String responseBody = r.getBody();
        system.debug('response >>>'+responseBody);
        
     // webCallout(a.renderJSON(false));
     
       GCAMProgramPhaseCreationBatch.IntegUtahResponse response = (GCAMProgramPhaseCreationBatch.IntegUtahResponse)JSON.deserialize(responseBody, GCAMProgramPhaseCreationBatch.IntegUtahResponse.class);
       system.debug('GCAMProgramPhaseCreationBatch.IntegUtahResponse' + response);
       IntegCGIAdv_ProgPhasBud_Transmit_Files transmittal = new IntegCGIAdv_ProgPhasBud_Transmit_Files();
       transmittal.addTranmittal(response.filename,String.valueOf(finetProgramList[0].DEPT_CD__r.code__c),String.valueOf(FiscalYearHelper.getFiscalYearShort(System.today())),String.valueOf(FiscalYearHelper.getFiscalYearShort(System.today())),1,totalAmountGCAM,'swati.singh@reisystems.com' );
       httpresponse r1 = IntegUtahGrantorAPI.postProgramPhaseBudgetTransmittalFile(transmittal);
          document doc1 = new document( FolderId=GetFolderHelper.getFolderId(), name = userinfo.getName() + 'GCAMTransmittalNow' );
          doc1.body =  blob.valueOf(transmittal.renderJSON(true));
          document doc2 = new document( FolderId=GetFolderHelper.getFolderId(), name = userinfo.getName() + 'GCAMTransmittalResponse' );
          doc2.body =  blob.valueOf(r1.getbody());
          system.debug('response2 from server'+ r1); 
          system.debug('body'+ r1.getbody()); 
         
          
  /* Phase 000 decrease */
    Set<Id> finetProgIds = new Set<Id>();
     for(r_prog__c fp: finetProgramList){
              finetProgIds.add(fp.Id);
            }
            
 IntegCGIAdv_GCAM_ProgPhse_Budgt_Document a1 = new IntegCGIAdv_GCAM_ProgPhse_Budgt_Document('400');
 String DOC_ID2 = String.valueOf(GAXPaymentCreationBatch.getRandomUnique());
 IntegCGIAdv_GCAM_ProgPhse_Budgt_Document.IntegCGIAdv_CAM_DOC_HDR_GCAM_ProgPhse_Budgt header1 = 
 new IntegCGIAdv_GCAM_ProgPhse_Budgt_Document.IntegCGIAdv_CAM_DOC_HDR_GCAM_ProgPhse_Budgt(DOC_ID2);
 
 IntegCGIAdv_GCAM_ProgPhse_Budgt_Document.IntegCGIAdv_CAM_DOC_MJRPROG_GCAM_ProgPhse_Budgt[] mjrprograms1 = new IntegCGIAdv_GCAM_ProgPhse_Budgt_Document.IntegCGIAdv_CAM_DOC_MJRPROG_GCAM_ProgPhse_Budgt[]{};
 IntegCGIAdv_GCAM_ProgPhse_Budgt_Document.IntegCGIAdv_CAM_DOC_MJRPROG_GCAM_ProgPhse_Budgt mjrprogram1 = 
 new IntegCGIAdv_GCAM_ProgPhse_Budgt_Document.IntegCGIAdv_CAM_DOC_MJRPROG_GCAM_ProgPhse_Budgt( 
 1,
 String.valueOf(finetProgramList[0].DEPT_CD__r.code__c),
 String.valueOf(finetProgramList[0].FINETMajorProgram__r.MJR_PROG_CD__c), 
 String.valueOf(finetProgramList[0].FINETMajorProgram__r.MJR_PROG_NM__c), 
 String.valueOf(finetProgramList[0].FINETMajorProgram__r.MJR_PROG_SH_NM__c),
 mjrProgActiveFlag, 
 finetProgramList[0].FINETMajorProgram__r.EffectiveFrom__c, 
 finetProgramList[0].FINETMajorProgram__r.EffectiveTo__c,
 mjrProgBudgetFlag,  
 String.valueOf(Integer.valueOf(finetProgramList[0].FINETMajorProgram__r.SUSP_STA__c)), 
 String.valueOf(Integer.valueOf(finetProgramList[0].FINETMajorProgram__r.REIM_BAS_IND__c)),
 String.valueOf(Integer.valueOf(finetProgramList[0].FINETMajorProgram__r.REIM_BUD_STRU_CD__c)), 
 String.valueOf(Integer.valueOf(finetProgramList[0].FINETMajorProgram__r.SPLT_IND__c)), 
 String.valueOf(Integer.valueOf(finetProgramList[0].FINETMajorProgram__r.FED_APPR_SETP__c)),
 String.valueOf(finetProgramList[0].FINETMajorProgram__r.MJR_PROG_NM__c));
      
 mjrprograms1.add(mjrprogram1);

    
      IntegCGIAdv_GCAM_ProgPhse_Budgt_Document.IntegCGIAdv_CAM_DOC_PROG_GCAM_ProgPhse_Budgt[] programs1 = new IntegCGIAdv_GCAM_ProgPhse_Budgt_Document.IntegCGIAdv_CAM_DOC_PROG_GCAM_ProgPhse_Budgt[]{};
      IntegCGIAdv_GCAM_ProgPhse_Budgt_Document.IntegCGIAdv_CAM_DOC_PROG_GCAM_ProgPhse_Budgt program1 =
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
      //String.valueOf(finetProgramList[0].AREA__c),
      finetProgramList[0].PROJ_END_DT__c);
      programs1.add(program1);
      
      IntegCGIAdv_GCAM_ProgPhse_Budgt_Document.IntegCGIAdv_CAM_DOC_PHSEPROG_GCAM_ProgPhse_Budgt[] programPhases1 = new IntegCGIAdv_GCAM_ProgPhse_Budgt_Document.IntegCGIAdv_CAM_DOC_PHSEPROG_GCAM_ProgPhse_Budgt[]{};
      IntegCGIAdv_GCAM_ProgPhse_Budgt_Document.IntegCGIAdv_CAM_DOC_PHSEPROG_GCAM_ProgPhse_Budgt programPhase1 =
      new IntegCGIAdv_GCAM_ProgPhse_Budgt_Document.IntegCGIAdv_CAM_DOC_PHSEPROG_GCAM_ProgPhse_Budgt(
      1,
      1,
      1,
      '2',
      //String.valueOf(mfm.SubRecipient__r.LEA_Id__c),
      '000',
      String.valueOf(finetProgramList[0].PROG_CD__c),
      '',
      //sitelocation
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
      programPhases1.add( programPhase1);                                                                                                                                                                                                                                                                                                                                                                                           
          
      IntegCGIAdv_GCAM_ProgPhse_Budgt_Document.IntegCGIAdv_CAM_DOC_FPI_GCAM_ProgPhse_Budgt[] FPIlines1 = new IntegCGIAdv_GCAM_ProgPhse_Budgt_Document.IntegCGIAdv_CAM_DOC_FPI_GCAM_ProgPhse_Budgt[]{};
      IntegCGIAdv_GCAM_ProgPhse_Budgt_Document.IntegCGIAdv_CAM_DOC_FPI_GCAM_ProgPhse_Budgt FPIline1 =
      new IntegCGIAdv_GCAM_ProgPhse_Budgt_Document.IntegCGIAdv_CAM_DOC_FPI_GCAM_ProgPhse_Budgt( 
      1,
      '2',
      '2',
      String.valueOf(finetProgramList[0].PROG_CD__c),
      String.valueOf(finetProgramList[0].FundingInferenceProfile__r.FPRFL_CD__c),
      '1',
      //String.valueOf(mfm.SubRecipient__r.LEA_Id__c)
      '000');
      FPIlines1.add(FPIline1);
      
      String phase000LineType;
      Decimal phase000Amount;
      if(totalAmount < 0){
          phase000Amount = totalAmount*-1;
          phase000LineType = '1';
      } else{
          phase000Amount = totalAmount;
          phase000LineType = '2';
      }
      IntegCGIAdv_GCAM_ProgPhse_Budgt_Document.IntegCGIAdv_CAM_DOC_BUDLN_GCAM_ProgPhse_Budgt[] Budgetlines1 = new IntegCGIAdv_GCAM_ProgPhse_Budgt_Document.IntegCGIAdv_CAM_DOC_BUDLN_GCAM_ProgPhse_Budgt[]{};
      IntegCGIAdv_GCAM_ProgPhse_Budgt_Document.IntegCGIAdv_CAM_DOC_BUDLN_GCAM_ProgPhse_Budgt Budgetline1 =
          new IntegCGIAdv_GCAM_ProgPhse_Budgt_Document.IntegCGIAdv_CAM_DOC_BUDLN_GCAM_ProgPhse_Budgt( 
          1,
          2, 
          'BGPHR', 
          '40',
          'BG22', 
          'UtahGrants',
          null, 
          null,
          phase000Amount,
         String.valueOf(finetProgramList[0].PROG_CD__c),
         //String.valueOf(mfm.SubRecipient__r.LEA_Id__c),
         '000',
         String.valueOf(finetProgramList[0].FundingInferenceProfile__r.FPRFL_CD__c),
         '10', 
         '1',
         phase000LineType, 
         '2' );
     Budgetlines1.add( Budgetline1);                                                                                                                                                                                                                                                                                                                                                                                        
                                                                                                                                                                                                                                                                                                                                                                     
       
       a1.createAMS_DOCUMENTwithDefaults( TRUE,String.valueOf(finetProgramList[0].DEPT_CD__r.code__c), 'null',String.valueOf(FiscalYearHelper.getFiscalYearShort(System.today())), header1, mjrprograms1, programs1, programPhases1, FPIlines1, Budgetlines1);
       system.debug(a1.renderJSON(true));
       document phaseGCAM = new document( FolderId=GetFolderHelper.getFolderId(), name = userinfo.getName() + 'Phase000GCAMNow' );
       phaseGCAM.body =  blob.valueOf( a1.renderJSON(true) );
       httpresponse r3 = IntegUtahGrantorAPI.postCreateProgramPhaseWithBudget(a1);
       document phaseRes = new document( FolderId=GetFolderHelper.getFolderId(), name = userinfo.getName() + 'Phase000GCAMResponse' );
       phaseRes.body =  blob.valueOf(r3.getbody());
       String responseBody3 = r3.getBody();
       
       GCAMProgramPhaseCreationBatch.IntegUtahResponse response3 = (GCAMProgramPhaseCreationBatch.IntegUtahResponse)JSON.deserialize(responseBody3, GCAMProgramPhaseCreationBatch.IntegUtahResponse.class);
       
       IntegCGIAdv_ProgPhasBud_Transmit_Files transmittal1 = new IntegCGIAdv_ProgPhasBud_Transmit_Files();
       transmittal1.addTranmittal(response3.filename,String.valueOf(finetProgramList[0].DEPT_CD__r.code__c),String.valueOf(FiscalYearHelper.getFiscalYearShort(System.today())),String.valueOf(FiscalYearHelper.getFiscalYearShort(System.today())),1,transmittalAmount,'swati.singh@reisystems.com' );
       httpresponse r4 = IntegUtahGrantorAPI.postProgramPhaseBudgetTransmittalFile(transmittal1);
          document phaseTrans = new document( FolderId=GetFolderHelper.getFolderId(), name = userinfo.getName() + 'Phase000TransmittalNow' );
          phaseTrans.body =  blob.valueOf(transmittal1.renderJSON(true));
          document phaseTransRes = new document( FolderId=GetFolderHelper.getFolderId(), name = userinfo.getName() + 'Phase000TransmittalResponse' );
          phaseTransRes.body =  blob.valueOf(r4.getbody()); 
          
          insert doc; 
          insert doc1;
          insert phaseGCAM; 
          insert phaseTrans;
          
  /* Doc status */
     docStatus = new IntegUtahGrantsAPI.GrantsAPIDocumentStatus(DOC_ID,'GCAM',String.valueOf(finetProgramList[0].DEPT_CD__r.code__c));
     gads = docStatus.insertParent(datetime.now().addSeconds(counter),a.renderJSON(true));
     counter++;
     System.debug(gads.Id);
     docStatusList.add(docStatus);
     finetCodeSet.add(String.valueOf(finetProgramList[0].PROG_CD__c));
     
  /*************/
   
       IntegUtahGrantsAPI.GrantsAPIDocumentStatus docStatus1 = new IntegUtahGrantsAPI.GrantsAPIDocumentStatus(DOC_ID2,'GCAM','400',finetProgIds);
       docStatus1.insertRecords(datetime.now().addSeconds(counter),a1.renderJSON(true));
          counter++;
  /**********************/
          
          }
        
   }catch(Exception e){
      errors.add(e.getMessage());
     // Database.rollback(sp);
    }
  }

                                                                                  
                     
 

                                                                                                                                                                                                                                                                                                                                                                                               
                                                                                                                                                                                                                                                                                                                                                                                                
                                                                                                                                                                                                                                                                                                                                                                                                
  
  global void finish(Database.BatchableContext BC){
         if(errors.size() == 0){
             if(docStatusList.size() == finetCodeSet.size()){
                // Database.executeBatch(new MSPGrantAndAwardCreateAndAmendBatch(fb,docStatus), 200);
                   Database.executeBatch(new MSPGrantAndAwardCreateAndAmendBatch(fb,finetCodeSet,0,docStatusList), 200);
             } 
          
        
        }else{
            for(String err : errors){
                fb.ErrorLog__c =  fb.ErrorLog__c + ';' + err;
            }
            fb.Status__c = 'Error';         
        
            update fb;  
        }

  }

  public class MyException extends Exception{}
      
      /* @Future(callout=true)
       private static void webCallout(String jsonString){
             httpresponse r = IntegUtahGrantorAPI.postCreateProgramPhaseWithBudget(jsonString);
             system.debug('response from server'+ r); 
             system.debug(r.getbody());
         
        } */
        
        /* Public class */
        public class IntegUtahResponse {
        public string message {get;set;}
        public string status {get;set;}
        public string filename {get;set;}
       
        
        }
       
}