/*
    All trigger logic on Progress Reports Object
   
    **********************************************************  
*/  
global with sharing class ProgressReportsTriggerHelper extends GNT.TriggerHelper {
    global static boolean skipTrigger = false;
    public override void processBeforeInsert(){   
     if(skipTrigger == false) {
      GNT.NameTemplateTriggerHelper.beforeInsert(); 
     }
    }
    public override void processAfterInsert() {
     if(skipTrigger == false) {
     copyRolesAndResponsibilities();
     String appName = GNT.UserPreferenceHelper.getStringValue('ActiveAppName__c');     
     createProgressReportShares(Trigger.New);
     if(appName == 'StateasGrantee' || appName == 'StateasGrantor'){     
        createFederalCostCategories(Trigger.New);
        }
     }
    }

    public override void processAfterUpdate() {
     if(skipTrigger == false) {
     String appName = GNT.UserPreferenceHelper.getStringValue('ActiveAppName__c');
           if(appName == 'StateasGrantee'){
            updateSubmissionHistory();        
        }
        approvalSendBack(Trigger.New, Trigger.Old);
     }
    }
    
    private void updateSubmissionHistory()
    {    
      List<SubmissionTracking__c> subTrckList= new List<SubmissionTracking__c>();
           
        Id poc;
        Id progRptFiscalApprover,progRptPgmApprover;

        for(ProgressReports__c rpt : (List<ProgressReports__c>)Trigger.new){
                if(rpt.status__c=='Submitted to Grantor')
                { 
                SubmissionTracking__c subTrck = new SubmissionTracking__c();
                subTrck.SubmissionId__c = rpt.Id;
                subTrck.TrackingType__c = 'Info';
                subTrck.Comments__c = 'Progress Report Submitted : '+ rpt.Name;
                subTrck.Status__c = 'Submitted to Grantor';
                subTrck.TrackingNumber__c = rpt.Name;
                subTrckList.add(subTrck);
                }
        }      
     if(subTrckList!=null && subTrckList.size()>0)
      insert subTrckList;
    }

     private void approvalSendBack(List<ProgressReports__c> progressRep, List<ProgressReports__c> progressRepOld){
        List<Id> listids = new List<Id>();
        for (ProgressReports__c progrep : progressRep) {
            for (ProgressReports__c progrepold : progressRepOld) {
                if (progrep.Id == progrepold.Id && progrep.Status__c == 'Change Requested' && progrep.Status__c != progrepold.Status__c) {
                    listids.add(progrep.Id);
                }
            }
        }
        if (listids.size() > 0) {
            approvalSendBackHelper(listids);
        }
     }

     @future
    private static void approvalSendBackHelper(List<Id> listids){
        List<ProgressReports__c> progrepList = [SELECT Id,AssignedTo__c,Name,Title__c FROM ProgressReports__c WHERE Id IN: listids];
        for (ProgressReports__c progreps : progrepList) {
            GNT.TaskCreationHandler.createTasks(progreps.AssignedTo__c, progreps.Id, 'Redo Progress Report', progreps.Name, null, false, System.TODAY() + 7, 'Redo Progress Report', progreps.Title__c, true);
        }
    }



    // To Copy Roles and Responsibility from Award when new Progress Report is Created
  private void copyRolesAndResponsibilities()
  {

    List<String> awdID = new List<String>();
    List<RolesAndResponsibilities__c> rolesList = new List<RolesAndResponsibilities__c>();
    String appName = GNT.UserPreferenceHelper.getStringValue('ActiveAppName__c');
    String developerName;
    
    if(appName == 'StateasGrantee'){
        developerName = 'ProgressReport';
    }
    else{
        developerName = 'GrantorProgressReport';
    }

   for(ProgressReports__c prRpt : (List<ProgressReports__c>)Trigger.new){
            if(prRpt.Award__c != null){
                awdID.add(prRpt.Award__c);  
            }
        System.debug('Award--------------------------------->' + prRpt.Award__c);                     
        } 

        String query =  'Select Id,Name__c,UserType__c,BusinessRole__c,Award__c,Notify__c,Responsibility__c,ProgressReport__c from RolesAndResponsibilities__c where Award__c in '+GNT.AppUtils.soqlList(awdID);
        List<RolesAndResponsibilities__c> lstRoles = Database.query(query);
        List<RecordType> recType = [select Id, Name,DeveloperName FROM RecordType where SobjectType=:AppUtils.getNamespacePrefix()+'RolesAndResponsibilities__c' and DeveloperName=:developerName Limit 1];
        String recId = recType[0].Id;
          for(ProgressReports__c prRpt : (List<ProgressReports__c>)Trigger.new){
             for(RolesAndResponsibilities__c roleandresp : (List<RolesAndResponsibilities__c>)lstRoles){
                RolesAndResponsibilities__c rolesprogRpt = new RolesAndResponsibilities__c();
                rolesprogRpt.Name__c=roleandresp.Name__c;
                //rolesprogRpt.Role__c=roleandresp.Role__c;
                rolesprogRpt.BusinessRole__c=roleandresp.BusinessRole__c;
                rolesprogRpt.ProgressReport__c=prRpt.Id;
                rolesprogRpt.Notify__c=roleandresp.Notify__c;
                rolesprogRpt.RecordTypeId=recId;
                rolesprogRpt.Responsibility__c=roleandresp.Responsibility__c;
                rolesprogRpt.UserType__c=roleandresp.UserType__c;
                 rolesList.add(rolesprogRpt);   
               }
              }      
                if(rolesList!=null && rolesList.size()>0)
                {
                  insert rolesList;
                }
  }

   private void createProgressReportShares(List<ProgressReports__c> reports) {
        List<String> reportIds = new List<String>();
        Map<String, Map<String, ProgressReports__Share>> shareMap = new Map<String, Map<String, ProgressReports__Share>>();
        for(ProgressReports__c report: reports) {
            reportIds.add(report.id);
            if(!shareMap.containsKey(report.id)) {
                shareMap.put(report.id, new Map<String, ProgressReports__Share>());
            }
        }
        List<ProgressReports__Share> currentShares = [SELECT ParentId, AccessLevel, UserOrGroupId FROM ProgressReports__Share WHERE ParentId IN: reportIds];
        System.debug(currentShares);
        for(ProgressReports__Share ps: currentShares) {
            shareMap.get(ps.ParentId).put(ps.userOrGroupId, ps);
        }
        ProgressReports__Share share;
        List<ProgressReports__Share> shares = new List<ProgressReports__Share>();
        List<ProgressReports__c> reportslist = [select id,Award__r.FoUser__c,ProjectOfficer__c,AssignedTo__c,ProgramApprover__c,GrantAdministrator__c 
                                                  from ProgressReports__c where id IN:reportIds ];
      
        for(ProgressReports__c report: reportslist) {
            if(report.Award__r.FoUser__c != null) {
                if(shareMap.get(report.id).containsKey(report.Award__r.FoUser__c)) {
                    if(shareMap.get(report.id).get(report.Award__r.FoUser__c).AccessLevel == 'Read') {
                        shareMap.get(report.id).get(report.Award__r.FoUser__c).AccessLevel = 'Edit';
                        shares.add(shareMap.get(report.id).get(report.Award__r.FoUser__c));
                    }
                } else {
                    share = new ProgressReports__Share(parentId = report.id, AccessLevel = 'Edit', UserOrGroupId = report.Award__r.FoUser__c, RowCause = Schema.ProgressReports__Share.RowCause.SharetoFO__c);
                    shares.add(share);
                    shareMap.get(report.id).put(report.Award__r.FoUser__c, share);
                }
               
            }
            if(report.ProgramApprover__c != null) {
                if(shareMap.get(report.id).containsKey(report.ProgramApprover__c)) {
                    if(shareMap.get(report.id).get(report.ProgramApprover__c).AccessLevel == 'Read') {
                        shareMap.get(report.id).get(report.ProgramApprover__c).AccessLevel = 'Edit';
                        shares.add(shareMap.get(report.id).get(report.ProgramApprover__c));
                    }
                } else {
                    share = new ProgressReports__Share(parentId = report.id, AccessLevel = 'Edit', UserOrGroupId = report.ProgramApprover__c, RowCause = Schema.ProgressReports__Share.RowCause.SharetoProgramApprover__c);
                    shares.add(share);
                    shareMap.get(report.id).put(report.ProgramApprover__c, share);
                }
            }

            if(report.GrantAdministrator__c != null) {
                if(shareMap.get(report.id).containsKey(report.GrantAdministrator__c)) {
                    if(shareMap.get(report.id).get(report.GrantAdministrator__c).AccessLevel == 'Read') {
                        shareMap.get(report.id).get(report.GrantAdministrator__c).AccessLevel = 'Edit';
                        shares.add(shareMap.get(report.id).get(report.GrantAdministrator__c));
                    }
                } else {
                    share = new ProgressReports__Share(parentId = report.id, AccessLevel = 'Edit', UserOrGroupId = report.GrantAdministrator__c, RowCause = Schema.ProgressReports__Share.RowCause.SharetoProgramApprover__c);
                    shares.add(share);
                    shareMap.get(report.id).put(report.GrantAdministrator__c, share);
                }
            }

            if(report.AssignedTo__c != null) {
                if(shareMap.get(report.id).containsKey(report.AssignedTo__c)) {
                    //Updates the existing records to Edit if they are currently set to read
                    if(shareMap.get(report.id).get(report.AssignedTo__c).AccessLevel == 'Read') {
                        shareMap.get(report.id).get(report.AssignedTo__c).AccessLevel = 'Edit';
                        shares.add(shareMap.get(report.id).get(report.AssignedTo__c));
                    }
                } else {
                    share = new ProgressReports__Share(parentId = report.id, AccessLevel = 'Edit', UserOrGroupId = report.AssignedTo__c, RowCause = Schema.ProgressReports__Share.RowCause.SharetoExternalPOC__c);
                    shares.add(share);
                    shareMap.get(report.id).put(report.AssignedTo__c, share);
                }
            }

        //update paymentMap.values();
        System.debug('Shares: ' + shares);
     }
     if(shares.size() > 0) {
            System.debug('Upsert');
            SystemContextMethodsHelper SystemContextMethodsHelper = new SystemContextMethodsHelper();
            SystemContextMethodsHelper.upsertProgressReportShare(shares);
        }
   }


  /*Creating Progress Report Break downs for grid Construction*/
  private void createFederalCostCategories(List<ProgressReports__c> reports) {
          
        List<ProgressReportCostBreakdown__c> fcbs = new List<ProgressReportCostBreakdown__c>();
        List<ReportBudgetCategory__c> bcs = [SELECT Id,RowNumber__c FROM ReportBudgetCategory__c where sObject__c='Federal Cash'];
        ProgressReportCostBreakdown__c fcb;  
        for(ProgressReports__c rpt: reports) {      
            for(ReportBudgetCategory__c bc: bcs) {
                fcb = new ProgressReportCostBreakdown__c();
                fcb.ProgressReport__c = rpt.Id;
                fcb.ReportBudgetCategory__c = bc.Id;
                fcb.RowNumber__c=bc.RowNumber__c;
                fcbs.add(fcb);
                }
            }
        insert fcbs;   

  List<ProgressReportCostBreakdown__c> fcbs1 = new List<ProgressReportCostBreakdown__c>();
        List<ReportBudgetCategory__c> bcs1 = [SELECT Id,RowNumber__c FROM ReportBudgetCategory__c where sObject__c='Federal Expenditures'];
        ProgressReportCostBreakdown__c fcb1; 
         for(ProgressReports__c rpt: reports) {          
            for(ReportBudgetCategory__c bc: bcs1) {
                fcb1 = new ProgressReportCostBreakdown__c();
                fcb1.ProgressReport__c = rpt.Id;
                fcb1.ReportBudgetCategory__c = bc.Id;
                fcb1.RowNumber__c=bc.RowNumber__c;
                fcbs1.add(fcb1);
                }
            }
        insert fcbs1;   

  List<ProgressReportCostBreakdown__c> fcbs2 = new List<ProgressReportCostBreakdown__c>();
        List<ReportBudgetCategory__c> bcs2 = [SELECT Id,RowNumber__c FROM ReportBudgetCategory__c where sObject__c='Recipient Share'];
        ProgressReportCostBreakdown__c fcb2; 
          for(ProgressReports__c rpt: reports) {         
            for(ReportBudgetCategory__c bc: bcs2) {
                fcb2 = new ProgressReportCostBreakdown__c();
                fcb2.ProgressReport__c = rpt.Id;
                fcb2.ReportBudgetCategory__c = bc.Id;
                fcb2.RowNumber__c=bc.RowNumber__c;
                fcbs2.add(fcb2);
                }
            }
            
        insert fcbs2;   

  List<ProgressReportCostBreakdown__c> fcbs3 = new List<ProgressReportCostBreakdown__c>();
        List<ReportBudgetCategory__c> bcs3 = [SELECT Id,RowNumber__c FROM ReportBudgetCategory__c where sObject__c='Program Income'];
        ProgressReportCostBreakdown__c fcb3;     
          for(ProgressReports__c rpt: reports) {     
            for(ReportBudgetCategory__c bc: bcs3) {
                fcb3 = new ProgressReportCostBreakdown__c();
                fcb3.ProgressReport__c = rpt.Id;
                fcb3.ReportBudgetCategory__c = bc.Id;
                fcb3.RowNumber__c=bc.RowNumber__c;
                fcbs3.add(fcb3);
                }
            }
        insert fcbs3;         
            
        
        List<ProgressReportDetail__c> fcbs4 = new List<ProgressReportDetail__c>();
        List<ReportBudgetCategory__c> bcs4 = [SELECT Id FROM ReportBudgetCategory__c where sObject__c='ProgressReportDetail__c'];
        ProgressReportDetail__c fcb4;        
        for(ProgressReports__c rpt: reports) {
            for(ReportBudgetCategory__c bc: bcs4) {
                fcb4 = new ProgressReportDetail__c();
                fcb4.ProgressReport__c = rpt.Id;
                fcb4.ReportBudgetCategory__c = bc.Id;
                fcbs4.add(fcb4);
            }
        }
       insert fcbs4; 
    }    
 }