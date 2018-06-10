global with sharing class CreateAnnouncementCtrl  {

    global string administration {get; set;}
    global string administrationAbbr {get; set;}
    global List<Object> annType {get; set;}

    public String recordId {get; set;}
    public String pageTemplate {get;set;}

    global CreateAnnouncementCtrl() {
        recordId = ApexPages.CurrentPage().getParameters().get('id');
        String currentUserId=UserInfo.getUserId();
        User currentUser = [Select id,AccountNameFormulaField__c from User where id = :currentUserId];
        String accountName = currentUser.AccountNameFormulaField__c;
        if (accountName.equalsIgnoreCase('USBE') || accountName.equalsIgnoreCase('SYSTEM') ){
          pageTemplate = 'Announcement Create - Grantor';
        }
        else if(accountName.equalsIgnoreCase('UOVC')){
          pageTemplate = 'Announcement Create - Grantor UOVC';
        }


    }

    public String getKeyValue() {
        Map<String, String> keyVal = new Map<String, String>();
        keyVal.put('uesrDeptCode', [Select Id, DepartmentCode__c from User where Id = : UserInfo.getUserId()][0].DepartmentCode__c);
        return JSON.serialize(keyVal);
    }


    /*
       @RemoteAction
       global static List<Object> getFoType(){
           List<Object> result = new List<Object>();
           String ns = AppUtils.getNamespacePrefix();
           List<Schema.PicklistEntry> annTypeValues = GNT.SchemaManager.fetchDescribeFieldResult(ns + 'Announcement__c', ns + 'AnnouncementType__c').getPicklistValues();
           for(Schema.PicklistEntry pk : annTypeValues){
               Map<String,String> pkMap = new Map<String,String>();
               pkMap .put('Value',pk.getValue());
               pkMap .put('Label',pk.getLabel());
               result.add(pkMap);
           }
           return result;
       }*/
    /*
       @RemoteAction
       global static List<Object> getBudgetPeriodType(){
           List<Object> result = new List<Object>();
           String ns = AppUtils.getNamespacePrefix();
           List<Schema.PicklistEntry> budgetPeriodTypeValues = GNT.SchemaManager.fetchDescribeFieldResult(ns + 'Announcement__c', ns + 'BudgetingPeriod__c').getPicklistValues();
           for(Schema.PicklistEntry pk : budgetPeriodTypeValues){
               Map<String,String> pkMap = new Map<String,String>();
               pkMap .put('Value',pk.getValue());
               pkMap .put('Label',pk.getLabel());
               result.add(pkMap);
           }
           return result;
       }

       @RemoteAction
       global static List<Object> getBudgetCatType(){
           List<Object> result = new List<Object>();
           String ns = AppUtils.getNamespacePrefix();
           List<Schema.PicklistEntry> budgetCatTypeValues = GNT.SchemaManager.fetchDescribeFieldResult(ns + 'Announcement__c', ns + 'BudgetCategory__c').getPicklistValues();
           for(Schema.PicklistEntry pk : budgetCatTypeValues){
               Map<String,String> pkMap = new Map<String,String>();
               pkMap .put('Value',pk.getValue());
               pkMap .put('Label',pk.getLabel());
               result.add(pkMap);
           }
           return result;
       }

      @RemoteAction
      global static List<Object> getBureaus(String OrgId){
          Id userID = UserInfo.getUserId();
          List<Object> result= new List<Object>();
             List<Account> acc = [select id,name from Account where Parent.Id =:OrgId ];
              for(Account accnt : acc){
                  Map<String,String> bureaus = new Map<String,String>();
                  bureaus.put('Value',accnt.id);
                  bureaus.put('Label',accnt.Name);
                  result.add(bureaus);
             return result;
          }
          return null;
      }*/


    /* @RemoteAction
    global static List<Object> getOrganization(String programId){
       Id userID = UserInfo.getUserId();
       List<Object> result= new List<Object>();
       List<Program__c> programs = [select Account__r.Name from Program__c where Id =:programId limit 1];

       List<Account> acc = [select id,name from Account where Status__c='Active' and IsGrantingAgency__c =true and recordtypeid in
                                            (select id from REcordType where sObjectType='Account' and name ='Internal') ];
           for(Account accnt : acc){
               Map<String,String> bureaus = new Map<String,String>();
               bureaus.put('Value',accnt.id);
               bureaus.put('Label',accnt.Name);
               result.add(bureaus);
             }
             return result;
    }*/

    /*
      @RemoteAction
      global static List<Object> getPrograms(String bureauId){
          List<Object> result= new List<Object>();
          List<Program__c> programs = [select Id,Name,ProgramName__c from Program__c where Account__c =:bureauId];
          if(programs .size () > 0){
              for(Program__c program : programs){
                  Map<String,String> programMap = new Map<String,String>();
                  programMap .put('Value',program.id);
                  programMap .put('Label',program.ProgramName__c);
                  result.add(programMap );
              }
              return result;
          }
          return null;
      }

      @RemoteAction
      global static Map<String,Object> getCoreServiceArea(String programId){
          Map<String,Object> result= new  Map<String,Object>();
          List<Object> duplicateCoreServiceArea = new List<Object>();
          List<Object> uniqueCoreServiceArea = new List<Object>();
          List<ProgramServiceArea__c> programServiceAreas = [select Id,ServiceArea__c,ServiceArea__r.Name
                   from ProgramServiceArea__c where Program__c =:programId];
          Set<String> coreServiceArea = new Set<String>();
          if(programServiceAreas .size () > 0){
              for(ProgramServiceArea__c  programSA : programServiceAreas){
                  Map<String,String> programSAMapClone = new Map<String,String>();
                  if(programSA.ServiceArea__c != null){
                   System.debug('prprogramSA.ServiceArea__r.CoreServiceArea__cgramSA : ' + programSA.ServiceArea__r.CoreServiceArea__c);
                      if(!coreServiceArea.contains(programSA.ServiceArea__r.CoreServiceArea__r.Name.toLowerCase())){
                          Map<String,String> programSAMap = new Map<String,String>();
                          programSAMap .put('Value',programSA.ServiceArea__r.Name);
                          programSAMap .put('Label',programSA.ServiceArea__r.CoreServiceArea__r.Name);
                          programSAMap .put('ID',programSA.Id);
                          coreServiceArea.add(programSA.ServiceArea__r.CoreServiceArea__r.Name.toLowerCase());
                          uniqueCoreServiceArea.add(programSAMap );
                      }
                      programSAMapClone .put('Value',programSA.ServiceArea__r.Name);
                      programSAMapClone .put('Label',programSA.ServiceArea__r.CoreServiceArea__r.Name);
                      programSAMapClone .put('ID',programSA.Id);
                      duplicateCoreServiceArea.add(programSAMapClone );
                  }
              }
              result.put('Unique',uniqueCoreServiceArea);
              result.put('Duplicate',duplicateCoreServiceArea);
              system.debug('core service areas - result: '+result);
              return result;
          }
          return null;
      }

       @RemoteAction
      global static List<Object> getServiceArea(String programId,String coreServiceArea){
          List<Object> result= new  List<Object>();
          List<Object> ServiceAreas = new List<Object>();
          List<ProgramServiceArea__c> programServiceAreas = [select Id,ServiceArea__c,ServiceArea__r.Name
                   from ProgramServiceArea__c where ServiceArea__r.CoreServiceArea__r.Name  =  :coreServiceArea and program__c =:programId];
          if(programServiceAreas .size () > 0){
              for(ProgramServiceArea__c  programSA : programServiceAreas){
                      Map<String,String> serviceArea = new Map<String,String>();
                      serviceArea .put('Label',programSA.ServiceArea__r.Name);
                      serviceArea .put('Value',programSA.ServiceArea__c);
                      result.add(serviceArea );
              }
              system.debug('service areas - result: '+result);
              return result;
          }
          return null;
      }*/


//<!--global static Map<String, Object> saveAndContinue(String programId, String selectedFOType, String selectedRFA, String selectedPreApp) {-->
    @RemoteAction
    global static Map<String, Object> saveAndContinue(String programId, String selectedFOType, String selectedRFA, String selectedPreApp) {

        Map<String, Object> result = new  Map<String, Object>();
        system.debug('Inside saveAndContinue:---------------- ' );
        List<Object> ServiceAreas = new List<Object>();
        List<Object> serviceAreaIdList = new List<Object>();
        List<Program__c> programs = [select ProgramName__c,AttachmentsRequired__c,Account__c, PrimaryFundingOrganization__c, ApplicationDeadline__c, 
        AdditionalInformation__c, EligibleApplicantTypes__c, OtherEligibleApplicantTypes__c from Program__c where Id = :programId limit 1];

        if (selectedFOType == 'Sole Source/Directed') {
            selectedRFA = 'No';
        }
        List<Id> serviceAreaIdsList  = new List<Id>();
        Savepoint sp = Database.setSavepoint();
        try {
            Announcement__c ann = new Announcement__c();
            ann.Program__c = programId;
            ann.Organization__c = programs[0].Account__c;
            ann.AwardingFedAgency__c = programs[0].PrimaryFundingOrganization__c;
            ann.AnnouncementType__c = selectedFOType;
            ann.RFARequired__c = selectedRFA == 'Yes' ? true : false;
            Date todaysDate = Date.today();
            ann.FOAPublicationDate__c = todaysDate.adddays(14);
            ann.RFAReleaseDate__c = todaysDate.adddays(28);
            //ann.ApplicationDeadlineWithDateTime__c = DateTime.newInstance(todaysDate.addDays(30).year(), todaysDate.addDays(30).month(), todaysDate.addDays(30).day(), 16, 00, 00);
            ann.ApplicationDeadlineWithDateTime__c = programs[0].ApplicationDeadline__c;
            ann.AttachmentsRequired__c = programs[0].AttachmentsRequired__c;
            
            ann.AdditionalInformation__c = programs[0].AdditionalInformation__c;
            ann.EligibleApplicantTypes__c = programs[0].EligibleApplicantTypes__c;
            ann.OtherEligibleApplicantTypes__c = programs[0].OtherEligibleApplicantTypes__c;

            ann.EstimatedBudgetPeriodStartDate__c = todaysDate.adddays(56);
            ann.EstimatedBudgetPeriodEndDate__c = todaysDate.adddays(421);
            ann.EstimatedProjectPeriodStartDate__c = todaysDate.adddays(56);
            ann.EstimatedProjectPeriodEndDate__c = todaysDate.adddays(421);
            ann.AnnouncementName__c = programs[0].ProgramName__c;
            String baseUrl;
            List<GNT__GlobalConfig__c> entries = [Select GNT__CommunityURLDomain__c from GNT__GlobalConfig__c limit 1];
            if (entries.size() == 1) {
                baseUrl = entries.get(0).GNT__CommunityURLDomain__c;
            }
            // String siteUrl=GNT.KeyValueStoreHelper.getTextValue('PublicAnnouncementsSite', true);
            ann.FundingOppURL__c = baseUrl;
            //Database.SaveResult  saveResult = Database.insert(ann);
            GNT__PageDataHolder__c pageDataHolder = new GNT__PageDataHolder__c(GNT__JSONData1__c = JSON.serialize(ann));
            insert  pageDataHolder;

            Id pagedataHolderId = pageDataHolder.Id;
            result.put('URL', 'apex/AnnouncementEdit?pageDataHolder=' + pagedataHolderId);
            result.put('Error', '');
            return result;

        } catch (Exception e) {
            result.put('Error', e.getMessage());
            system.debug('Exception: ' + e);
            Database.rollback(sp);
            return result;
        }
    }

    @RemoteAction
    global static List<Object> getAllPrograms() {
        List<Object> result = new List<Object>();
        List<User> usr = [Select Id, DepartmentCode__c from User where Id = : UserInfo.getUserId()];
       /* List<Program__c> programs = [select Id, Name, ProgramName__c from Program__c where status__c = 'Active' and ProgramGroupCode__c = :usr[0].DepartmentCode__c and  recordtypeid in
                                     (select id from REcordType where sObjectType = 'Program__c' and name = 'Internal Program')]; */
         List<Program__c> programs = [select Id, Name, ProgramName__c from Program__c where status__c = 'Active' and  recordtypeid in
                                     (select id from REcordType where sObjectType = 'Program__c' and name = 'Internal Program')];               
        if (programs .size () > 0) {
            for (Program__c program : programs) {
                Map<String, String> programMap = new Map<String, String>();
                programMap .put('Value', program.id);
                programMap .put('Label', program.ProgramName__c);
                result.add(programMap );
            }
            system.debug('programs : result: ' + result);
            return result;
        }
        return null;
    }
}