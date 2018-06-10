global with sharing class GCAMProgramPhaseCreationHelper extends GNT.DynamicLayoutActionRedirect { 

    global override PageReference whenClicked(){
    Savepoint sp = Database.setSavepoint();
    List<String> errors = new List<String>();  
    try{
      Id recordId = apexpages.currentpage().getparameters().get('id');
     
      Award__c aw  = [select Id,name,Grant__c,Grant__r.ExternalOrganization__r.code__c,Grant__r.InternalOrganization__r.LEA_ID__c,Grant__r.InternalOrganization__r.SITE_LOC_CD__c,Grant__r.InternalOrganization__r.name from Award__c where Id =:recordId limit 1];
      List<AwardFINETCode__c> awFinetList =[select Id,name,Amount__c,ProgramCode__c,ProgramCode__r.PROG_CD__c,ProgramCode__r.PROG_NM__c,ProgramCode__r.PROG_SH_NM__c,ProgramCode__r.ACT_FL__c ,ProgramCode__r.ALW_BUD_FL__c ,ProgramCode__r.SACCT_CD__c,ProgramCode__r.SUSP_STA__c,ProgramCode__r.REIM_ELG_STA__c,ProgramCode__r.BILL_AGREE_DT__c,ProgramCode__r.EFBGN_DT__c,ProgramCode__r.EFEND_DT__c,ProgramCode__r.FINETProgramGroup__r.PGRP_CD__c,ProgramCode__r.FINETProgramType__r.PTYP_CD__c,ProgramCode__r.FINETProgramClass__r.PCLS_CD__c,ProgramCode__r.FINETProgramCategory__r.PCAT_CD__c,ProgramCode__r.AREA__c,ProgramCode__r.FundingInferenceProfile__r.FPRFL_CD__c,ProgramCode__r.PROJ_END_DT__c,
      ProgramCode__r.FINETMajorProgram__r.MJR_PROG_CD__c,ProgramCode__r.FINETMajorProgram__r.MJR_PROG_NM__c,ProgramCode__r.FINETMajorProgram__r.MJR_PROG_SH_NM__c,ProgramCode__r.FINETMajorProgram__r.ACT_FL__c,ProgramCode__r.FINETMajorProgram__r.ALW_BUD_FL__c,ProgramCode__r.FINETMajorProgram__r.EffectiveFrom__c,ProgramCode__r.FINETMajorProgram__r.EffectiveTo__c,ProgramCode__r.FINETMajorProgram__r.SUSP_STA__c,ProgramCode__r.FINETMajorProgram__r.REIM_BAS_IND__c,ProgramCode__r.FINETMajorProgram__r.REIM_BUD_STRU_CD__c,ProgramCode__r.FINETMajorProgram__r.SPLT_IND__c,ProgramCode__r.FINETMajorProgram__r.FED_APPR_SETP__c 
      from AwardFINETCode__c where Award__c =:recordId];
      ////
      Set<Id> awardFinetIds= new Set<Id>();
      Set<Id> finetProgIds= new Set<Id>();
      for(AwardFINETCode__c afcIds: awFinetList){
              awardFinetIds.add(afcIds.Id);
              finetProgIds.add(afcIds.ProgramCode__c);
            }
            
      for(AwardFINETCode__c awf: awFinetList){
      
        Boolean mjrProgActiveFlag;
        Boolean mjrProgBudgetFlag; 
          
        if(awf.ProgramCode__r.FINETMajorProgram__r.ACT_FL__c == 1.0){
        mjrProgActiveFlag = true;
        } else{
        mjrProgActiveFlag = false;
        }
        if(awf.ProgramCode__r.FINETMajorProgram__r.ALW_BUD_FL__c == 1.0){
        mjrProgBudgetFlag = true;
        }else{
        mjrProgBudgetFlag = false;
        }
        
        Boolean ProgActiveFlag;
        Boolean ProgBudgetFlag; 
        if(awf.ProgramCode__r.ACT_FL__c == 'True'){
        ProgActiveFlag = true;
        } else{
        ProgActiveFlag = false;
        }
        if(awf.ProgramCode__r.ALW_BUD_FL__c == 'True'){
        ProgBudgetFlag = true;
        } else{
        ProgBudgetFlag = false;
        }
        
        String progSuspStatus;
        if(awf.ProgramCode__r.SUSP_STA__c == 'Allowed for Reimbursement'){
        progSuspStatus = '2';
        } else{
        progSuspStatus = '1';
        } 
        
      IntegCGIAdv_GCAM_ProgPhse_Budgt_Document a = new IntegCGIAdv_GCAM_ProgPhse_Budgt_Document(String.valueOf(aw.Grant__r.ExternalOrganization__r.code__c));
      String DOC_ID = String.valueOf(GAXPaymentCreationBatch.getRandomUnique());
      IntegCGIAdv_GCAM_ProgPhse_Budgt_Document.IntegCGIAdv_CAM_DOC_HDR_GCAM_ProgPhse_Budgt header = 
      new IntegCGIAdv_GCAM_ProgPhse_Budgt_Document.IntegCGIAdv_CAM_DOC_HDR_GCAM_ProgPhse_Budgt(DOC_ID);
                
      IntegCGIAdv_GCAM_ProgPhse_Budgt_Document.IntegCGIAdv_CAM_DOC_MJRPROG_GCAM_ProgPhse_Budgt[] mjrprograms = new IntegCGIAdv_GCAM_ProgPhse_Budgt_Document.IntegCGIAdv_CAM_DOC_MJRPROG_GCAM_ProgPhse_Budgt[]{};
      IntegCGIAdv_GCAM_ProgPhse_Budgt_Document.IntegCGIAdv_CAM_DOC_MJRPROG_GCAM_ProgPhse_Budgt mjrprogram = 
      new IntegCGIAdv_GCAM_ProgPhse_Budgt_Document.IntegCGIAdv_CAM_DOC_MJRPROG_GCAM_ProgPhse_Budgt( 
      1,
      String.valueOf(aw.Grant__r.ExternalOrganization__r.code__c),
      String.valueOf(awf.ProgramCode__r.FINETMajorProgram__r.MJR_PROG_CD__c),
      String.valueOf(awf.ProgramCode__r.FINETMajorProgram__r.MJR_PROG_NM__c),
      String.valueOf(awf.ProgramCode__r.FINETMajorProgram__r.MJR_PROG_SH_NM__c),
      mjrProgActiveFlag, 
      awf.ProgramCode__r.FINETMajorProgram__r.EffectiveFrom__c, 
      awf.ProgramCode__r.FINETMajorProgram__r.EffectiveTo__c,
      mjrProgBudgetFlag, 
      String.valueOf(Integer.valueOf(awf.ProgramCode__r.FINETMajorProgram__r.SUSP_STA__c)), 
      String.valueOf(Integer.valueOf(awf.ProgramCode__r.FINETMajorProgram__r.REIM_BAS_IND__c)),
      String.valueOf(Integer.valueOf(awf.ProgramCode__r.FINETMajorProgram__r.REIM_BUD_STRU_CD__c)), 
      String.valueOf(Integer.valueOf(awf.ProgramCode__r.FINETMajorProgram__r.SPLT_IND__c)), 
      String.valueOf(Integer.valueOf(awf.ProgramCode__r.FINETMajorProgram__r.FED_APPR_SETP__c)),
      String.valueOf(awf.ProgramCode__r.FINETMajorProgram__r.MJR_PROG_NM__c));
      mjrprograms.add(mjrprogram); 
      
      /*yet to be implemented for single GCAMS */
      Boolean amendment  = false;
      String LN_TYP;
      if(amendment == true){
      LN_TYP = '2';
      } else {
      LN_TYP = '1';
      }
      /***************************************/
      
      IntegCGIAdv_GCAM_ProgPhse_Budgt_Document.IntegCGIAdv_CAM_DOC_PROG_GCAM_ProgPhse_Budgt[] programs = new IntegCGIAdv_GCAM_ProgPhse_Budgt_Document.IntegCGIAdv_CAM_DOC_PROG_GCAM_ProgPhse_Budgt[]{};
      IntegCGIAdv_GCAM_ProgPhse_Budgt_Document.IntegCGIAdv_CAM_DOC_PROG_GCAM_ProgPhse_Budgt program =
      new IntegCGIAdv_GCAM_ProgPhse_Budgt_Document.IntegCGIAdv_CAM_DOC_PROG_GCAM_ProgPhse_Budgt(
      1,
      1,
      '2',
      String.valueOf(awf.ProgramCode__r.PROG_CD__c),
      String.valueOf(awf.ProgramCode__r.PROG_NM__c),
      String.valueOf(awf.ProgramCode__r.PROG_SH_NM__c),
      ProgActiveFlag,
      ProgBudgetFlag,
      progSuspStatus,
      awf.ProgramCode__r.REIM_ELG_STA__c,
      awf.ProgramCode__r.BILL_AGREE_DT__c, 
      'prog description',
      String.valueOf(awf.ProgramCode__r.SACCT_CD__c),
      awf.ProgramCode__r.EFBGN_DT__c,
      awf.ProgramCode__r.EFEND_DT__c,
      String.valueOf(awf.ProgramCode__r.FINETProgramGroup__r.PGRP_CD__c), 
      String.valueOf(awf.ProgramCode__r.FINETProgramType__r.PTYP_CD__c), 
      String.valueOf(awf.ProgramCode__r.FINETProgramClass__r.PCLS_CD__c), 
      String.valueOf(awf.ProgramCode__r.FINETProgramCategory__r.PCAT_CD__c),
      //String.valueOf(awf.ProgramCode__r.AREA__c),
      awf.ProgramCode__r.PROJ_END_DT__c);
      programs.add( program );
      
      IntegCGIAdv_GCAM_ProgPhse_Budgt_Document.IntegCGIAdv_CAM_DOC_PHSEPROG_GCAM_ProgPhse_Budgt[] programPhases = new IntegCGIAdv_GCAM_ProgPhse_Budgt_Document.IntegCGIAdv_CAM_DOC_PHSEPROG_GCAM_ProgPhse_Budgt[]{};
      IntegCGIAdv_GCAM_ProgPhse_Budgt_Document.IntegCGIAdv_CAM_DOC_PHSEPROG_GCAM_ProgPhse_Budgt programPhase =
      new IntegCGIAdv_GCAM_ProgPhse_Budgt_Document.IntegCGIAdv_CAM_DOC_PHSEPROG_GCAM_ProgPhse_Budgt(
       1,
       1,
       1,
       LN_TYP,
       String.valueOf(aw.Grant__r.InternalOrganization__r.LEA_ID__c),
       String.valueOf(awf.ProgramCode__r.PROG_CD__c),
       //String.valueOf(awf.ProgramCode__r.SACCT_CD__c),
       '',
       String.valueOf(aw.Grant__r.InternalOrganization__r.SITE_LOC_CD__c),
       awf.ProgramCode__r.EFBGN_DT__c,
       awf.ProgramCode__r.EFEND_DT__c,
       awf.ProgramCode__r.BILL_AGREE_DT__c,
       ProgActiveFlag,
       ProgBudgetFlag,
       awf.ProgramCode__r.REIM_ELG_STA__c,
       progSuspStatus,
       String.valueOf(aw.Grant__r.InternalOrganization__r.name));                                                                                                                                                                                                                                                                                  
       programPhases.add( programPhase );                                                                                                                                                                                                                                                                                                                                                                                                    
                                                                                                                                                                                                                                                                                                                                                                                                   
                                                                                                                                                                                                                                                                                                                                                                                                   
                                                                                                                                                                                                                                                                                                                                                                                                   
      IntegCGIAdv_GCAM_ProgPhse_Budgt_Document.IntegCGIAdv_CAM_DOC_FPI_GCAM_ProgPhse_Budgt[] FPIlines = new IntegCGIAdv_GCAM_ProgPhse_Budgt_Document.IntegCGIAdv_CAM_DOC_FPI_GCAM_ProgPhse_Budgt[]{};
      IntegCGIAdv_GCAM_ProgPhse_Budgt_Document.IntegCGIAdv_CAM_DOC_FPI_GCAM_ProgPhse_Budgt FPIline =
      new IntegCGIAdv_GCAM_ProgPhse_Budgt_Document.IntegCGIAdv_CAM_DOC_FPI_GCAM_ProgPhse_Budgt( 
       1,
       LN_TYP,
       '2',
       String.valueOf(awf.ProgramCode__r.PROG_CD__c),
       String.valueOf(awf.ProgramCode__r.FundingInferenceProfile__r.FPRFL_CD__c), 
       '1',
       String.valueOf(aw.Grant__r.InternalOrganization__r.LEA_ID__c));
       FPIlines.add( FPIline );

      IntegCGIAdv_GCAM_ProgPhse_Budgt_Document.IntegCGIAdv_CAM_DOC_BUDLN_GCAM_ProgPhse_Budgt[] Budgetlines = new IntegCGIAdv_GCAM_ProgPhse_Budgt_Document.IntegCGIAdv_CAM_DOC_BUDLN_GCAM_ProgPhse_Budgt[]{};
      
      if(awf.Amount__c < 0){
      IntegCGIAdv_GCAM_ProgPhse_Budgt_Document.IntegCGIAdv_CAM_DOC_BUDLN_GCAM_ProgPhse_Budgt Budgetline =
      new IntegCGIAdv_GCAM_ProgPhse_Budgt_Document.IntegCGIAdv_CAM_DOC_BUDLN_GCAM_ProgPhse_Budgt( 
      1,
      integer.ValueOf(LN_TYP), 
      'BGPHR', 
      '40',
      'BG22', 
      'UtahGrants',
      null, 
      null,
      (awf.Amount__c *-1),
      String.valueOf(awf.ProgramCode__r.PROG_CD__c),
      String.valueOf(aw.Grant__r.InternalOrganization__r.LEA_ID__c),
      String.valueOf(awf.ProgramCode__r.FundingInferenceProfile__r.FPRFL_CD__c),
      '10', 
      '1',
      '2', 
      '2' );
       Budgetlines.add( Budgetline );   
      } 
      if(awf.Amount__c  >= 0){ 
       IntegCGIAdv_GCAM_ProgPhse_Budgt_Document.IntegCGIAdv_CAM_DOC_BUDLN_GCAM_ProgPhse_Budgt Budgetline =
       new IntegCGIAdv_GCAM_ProgPhse_Budgt_Document.IntegCGIAdv_CAM_DOC_BUDLN_GCAM_ProgPhse_Budgt( 
       1,
       integer.ValueOf(LN_TYP), 
       'BGPHR', 
       '40',
       'BG22', 
       'UtahGrants',
       null, 
       null,
       (awf.Amount__c),
       String.valueOf(awf.ProgramCode__r.PROG_CD__c),
       String.valueOf(aw.Grant__r.InternalOrganization__r.LEA_ID__c),
       String.valueOf(awf.ProgramCode__r.FundingInferenceProfile__r.FPRFL_CD__c),
       '10', 
       '1',
       '1', 
       '2' );
       Budgetlines.add( Budgetline );                                                                                                                                                                                                                                                                                                                                                                                        
                                                                                                                                                                                                                                                                                                                                                                        
       }        
                                                                                                                                                                                                                                                                                                                                                                                                
                                                                                                                                                                                                                                                                                                                                                                                                
                                                                                                                                                                                                                                                                                                                                                                                                
      a.createAMS_DOCUMENTwithDefaults( TRUE,String.valueOf(aw.Grant__r.ExternalOrganization__r.code__c), 'null',String.valueOf(FiscalYearHelper.getFiscalYearShort(System.today())), header, mjrprograms, programs, programPhases, FPIlines, Budgetlines );
      system.debug(a.renderJSON(true));

      document doc = new document( FolderId= GetFolderHelper.getFolderId(), name = userinfo.getName() + 'SingleGCAM' );
      doc.body =  blob.valueOf( a.renderJSON(true) );
      webCallout(a.renderJSON(false),String.valueOf(aw.Grant__r.ExternalOrganization__r.code__c),awf.Amount__c);
      
      
 /* Phase 000 decrease GCAM */
     
     IntegCGIAdv_GCAM_ProgPhse_Budgt_Document a1 = new IntegCGIAdv_GCAM_ProgPhse_Budgt_Document('400');
     String DOC_ID2 = String.valueOf(GAXPaymentCreationBatch.getRandomUnique());
     IntegCGIAdv_GCAM_ProgPhse_Budgt_Document.IntegCGIAdv_CAM_DOC_HDR_GCAM_ProgPhse_Budgt header1 = 
     new IntegCGIAdv_GCAM_ProgPhse_Budgt_Document.IntegCGIAdv_CAM_DOC_HDR_GCAM_ProgPhse_Budgt(DOC_ID2);
     
     IntegCGIAdv_GCAM_ProgPhse_Budgt_Document.IntegCGIAdv_CAM_DOC_MJRPROG_GCAM_ProgPhse_Budgt[] mjrprograms1 = new IntegCGIAdv_GCAM_ProgPhse_Budgt_Document.IntegCGIAdv_CAM_DOC_MJRPROG_GCAM_ProgPhse_Budgt[]{};
     IntegCGIAdv_GCAM_ProgPhse_Budgt_Document.IntegCGIAdv_CAM_DOC_MJRPROG_GCAM_ProgPhse_Budgt mjrprogram1 = 
     new IntegCGIAdv_GCAM_ProgPhse_Budgt_Document.IntegCGIAdv_CAM_DOC_MJRPROG_GCAM_ProgPhse_Budgt( 
     1,
     String.valueOf(aw.Grant__r.ExternalOrganization__r.code__c),
     String.valueOf(awf.ProgramCode__r.FINETMajorProgram__r.MJR_PROG_CD__c), 
     String.valueOf(awf.ProgramCode__r.FINETMajorProgram__r.MJR_PROG_NM__c), 
     String.valueOf(awf.ProgramCode__r.FINETMajorProgram__r.MJR_PROG_SH_NM__c),
     mjrProgActiveFlag, 
     awf.ProgramCode__r.FINETMajorProgram__r.EffectiveFrom__c, 
     awf.ProgramCode__r.FINETMajorProgram__r.EffectiveTo__c,
     mjrProgBudgetFlag,  
     String.valueOf(Integer.valueOf(awf.ProgramCode__r.FINETMajorProgram__r.SUSP_STA__c)), 
     String.valueOf(Integer.valueOf(awf.ProgramCode__r.FINETMajorProgram__r.REIM_BAS_IND__c)),
     String.valueOf(Integer.valueOf(awf.ProgramCode__r.FINETMajorProgram__r.REIM_BUD_STRU_CD__c)), 
     String.valueOf(Integer.valueOf(awf.ProgramCode__r.FINETMajorProgram__r.SPLT_IND__c)), 
     String.valueOf(Integer.valueOf(awf.ProgramCode__r.FINETMajorProgram__r.FED_APPR_SETP__c)),
     String.valueOf(awf.ProgramCode__r.FINETMajorProgram__r.MJR_PROG_NM__c));
          
     mjrprograms1.add(mjrprogram1);

    
      IntegCGIAdv_GCAM_ProgPhse_Budgt_Document.IntegCGIAdv_CAM_DOC_PROG_GCAM_ProgPhse_Budgt[] programs1 = new IntegCGIAdv_GCAM_ProgPhse_Budgt_Document.IntegCGIAdv_CAM_DOC_PROG_GCAM_ProgPhse_Budgt[]{};
      IntegCGIAdv_GCAM_ProgPhse_Budgt_Document.IntegCGIAdv_CAM_DOC_PROG_GCAM_ProgPhse_Budgt program1 =
      new IntegCGIAdv_GCAM_ProgPhse_Budgt_Document.IntegCGIAdv_CAM_DOC_PROG_GCAM_ProgPhse_Budgt(
      1,
      1,
      '2',
      String.valueOf(awf.ProgramCode__r.PROG_CD__c),
      String.valueOf(awf.ProgramCode__r.PROG_NM__c),
      String.valueOf(awf.ProgramCode__r.PROG_SH_NM__c),
      ProgActiveFlag,
      ProgBudgetFlag,
      progSuspStatus,
      awf.ProgramCode__r.REIM_ELG_STA__c,
      awf.ProgramCode__r.BILL_AGREE_DT__c, 
      'prog description',
      String.valueOf(awf.ProgramCode__r.SACCT_CD__c),
      awf.ProgramCode__r.EFBGN_DT__c,
      awf.ProgramCode__r.EFEND_DT__c,
      String.valueOf(awf.ProgramCode__r.FINETProgramGroup__r.PGRP_CD__c), 
      String.valueOf(awf.ProgramCode__r.FINETProgramType__r.PTYP_CD__c), 
      String.valueOf(awf.ProgramCode__r.FINETProgramClass__r.PCLS_CD__c), 
      String.valueOf(awf.ProgramCode__r.FINETProgramCategory__r.PCAT_CD__c),
      //String.valueOf(awf.ProgramCode__r.AREA__c),
      awf.ProgramCode__r.PROJ_END_DT__c);
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
      String.valueOf(awf.ProgramCode__r.PROG_CD__c),
      '',
      //SiteLocation,
      '',
      awf.ProgramCode__r.EFBGN_DT__c,
      awf.ProgramCode__r.EFEND_DT__c,
      awf.ProgramCode__r.BILL_AGREE_DT__c,
      ProgActiveFlag,
      ProgBudgetFlag,
      awf.ProgramCode__r.REIM_ELG_STA__c,
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
      String.valueOf(awf.ProgramCode__r.PROG_CD__c),
      String.valueOf(awf.ProgramCode__r.FundingInferenceProfile__r.FPRFL_CD__c), 
      '1',
      //String.valueOf(mfm.SubRecipient__r.LEA_Id__c)
      '000');
      FPIlines1.add(FPIline1);
      
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
          awf.Amount__c,
         String.valueOf(awf.ProgramCode__r.PROG_CD__c),
         //String.valueOf(mfm.SubRecipient__r.LEA_Id__c),
         '000',
         String.valueOf(awf.ProgramCode__r.FundingInferenceProfile__r.FPRFL_CD__c),
         '10', 
         '1',
         '2', 
         '2' );
     Budgetlines1.add( Budgetline1);                                                                                                                                                                                                                                                                                                                                                                                        
                                                                                                                                                                                                                                                                                                                                                                     
       
       a1.createAMS_DOCUMENTwithDefaults( TRUE,String.valueOf(aw.Grant__r.ExternalOrganization__r.code__c), 'null',String.valueOf(FiscalYearHelper.getFiscalYearShort(System.today())), header1, mjrprograms1, programs1, programPhases1, FPIlines1, Budgetlines1);
       system.debug(a1.renderJSON(true));
       document phaseGCAM = new document( FolderId=GetFolderHelper.getFolderId(), name = userinfo.getName() + 'Phase000GCAMNow' );
       phaseGCAM.body =  blob.valueOf( a1.renderJSON(true) );
       
       webCallout(a1.renderJSON(false),String.valueOf(aw.Grant__r.ExternalOrganization__r.code__c),awf.Amount__c);
       
     /*  httpresponse r3 = IntegUtahGrantorAPI.postCreateProgramPhaseWithBudget(a1);
       document phaseRes = new document( FolderId=GetFolderHelper.getFolderId(), name = userinfo.getName() + 'Phase000GCAMResponse' );
       phaseRes.body =  blob.valueOf(r3.getbody());
       String responseBody3 = r3.getBody();
       
       GCAMProgramPhaseCreationBatch.IntegUtahResponse response3 = (GCAMProgramPhaseCreationBatch.IntegUtahResponse)JSON.deserialize(responseBody3, GCAMProgramPhaseCreationBatch.IntegUtahResponse.class);
       
       IntegCGIAdv_ProgPhasBud_Transmit_Files transmittal1 = new IntegCGIAdv_ProgPhasBud_Transmit_Files();
       transmittal1.addTranmittal(response3.filename,String.valueOf(aw.Grant__r.ExternalOrganization__r.code__c),String.valueOf(FiscalYearHelper.getFiscalYearShort(System.today())),String.valueOf(FiscalYearHelper.getFiscalYearShort(System.today())),1,awf.Amount__c,'swati.singh@reisystems.com' );
       httpresponse r4 = IntegUtahGrantorAPI.postProgramPhaseBudgetTransmittalFile(transmittal1);
          document phaseTrans = new document( FolderId=GetFolderHelper.getFolderId(), name = userinfo.getName() + 'Phase000TransmittalNow' );
          phaseTrans.body =  blob.valueOf(transmittal1.renderJSON(true));
          document phaseTransRes = new document( FolderId=GetFolderHelper.getFolderId(), name = userinfo.getName() + 'Phase000TransmittalResponse' );
          phaseTransRes.body =  blob.valueOf(r4.getbody()); 
          
          
          insert phaseTrans; */
          insert doc; 
          insert phaseGCAM; 
     /***************************/
     IntegUtahGrantsAPI.GrantsAPIDocumentStatus docStatus = new IntegUtahGrantsAPI.GrantsAPIDocumentStatus(DOC_ID,'GCAM','400',awardFinetIds);
     docStatus.insertRecords(datetime.now(),a.renderJSON(true));
     IntegUtahGrantsAPI.GrantsAPIDocumentStatus docStatus1 = new IntegUtahGrantsAPI.GrantsAPIDocumentStatus(DOC_ID2,'GCAM','400',finetProgIds);
     docStatus1.insertRecords(datetime.now(),a1.renderJSON(true));
      
     }
   return null;

    } catch(Exception e){
            Database.rollback(sp);
            System.debug('***exception caught' + e.getCause());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            return null;
        }
    
    }
    
       @Future(callout=true)
       private static void webCallout(String jsonString,String deptCode,Decimal amount){
           IntegCGIAdv_GCAM_ProgPhse_Budgt_Document curr;
           curr = (IntegCGIAdv_GCAM_ProgPhse_Budgt_Document) JSON.deserialize(jsonString,IntegCGIAdv_GCAM_ProgPhse_Budgt_Document.class);
            
           httpresponse r = IntegUtahGrantorAPI.postCreateProgramPhaseWithBudget(curr);
           system.debug('response from server'+ r); 
           system.debug(r.getbody());
           //transmittal
           String responseBody = r.getBody();
           FINETGCAMProgSubmissionHelper.IntegUtahResponse response = (FINETGCAMProgSubmissionHelper.IntegUtahResponse)JSON.deserialize(responseBody, FINETGCAMProgSubmissionHelper.IntegUtahResponse.class);
           IntegCGIAdv_Program_Transmittal_Files transmittal = new IntegCGIAdv_Program_Transmittal_Files();
           transmittal.addTranmittal(response.filename,deptCode,String.valueOf(FiscalYearHelper.getFiscalYearShort(System.today())),String.valueOf(FiscalYearHelper.getFiscalYearShort(System.today())),1,amount,'swati.singh@reisystems.com' );
           httpresponse r1 = IntegUtahGrantorAPI.postProgramTransmittalFile(transmittal);
           document doc1 = new document( FolderId= GetFolderHelper.getFolderId(), name = userinfo.getName() + 'SingleGCAMTransmittal' );
              doc1.body =  blob.valueOf(transmittal.renderJSON(true));
              /*document doc2 = new document( FolderId= GetFolderHelper.getFolderId(), name = userinfo.getName() + 'TempTransmittalResponse' );
              doc2.body =  blob.valueOf(r1.getbody()); */
              insert doc1;
              
         
        }  
        
        /* Public class */
        public class IntegUtahResponse {
        public string message {get;set;}
        public string status {get;set;}
        public string filename {get;set;}
       }
    
    
}