/**
  Shah code reviewed on 4/1/2017
*/
global with sharing class SelectApplicationCtrl extends GNT.FlexTableActionHandler{

   global string administration {get;set;}
   global string administrationAbbr {get;set;}
   global List<Object> annType {get;set;}
   global List<Object> budgetPeriodType {get;set;}
   global List<Object> budgetCatType {get;set;}
   
   global SelectApplicationCtrl(){
      
   }
   
   global override Map<String,Object> clickHandler(){
        Map<String,Object> resultMap = new Map<String,Object>();
        List<UserRole> userRole = [select Name from UserRole where id=:UserInfo.getUserRoleId()];
        if(userRole.size () > 0 ){
            if(!String.isEmpty(userRole[0].Name)){
               // if(!userRole[0].Name.contains('Project Officer') &&
               //         !userRole[0].Name.contains('Program Manager')){
                //    resultMap.put('Error', Label.GNT.InsufficientPrivelages);
               //     return resultMap;
              //  }else{
                    String sfdcBaseURL = System.URL.getSalesforceBaseUrl().toExternalForm();
                    System.debug('Base URL: ' + sfdcBaseURL );  
                    sfdcBaseURL = sfdcBaseURL.replace('ggsInt.', 'c.');  //Shah CRF: namespace should not be hardcoded
                    System.debug('Base URL: after ---' + sfdcBaseURL );  
                    resultMap.put('PageReference', sfdcBaseURL +'/apex/DOH_CreateAnnouncement?t=Planning');  //Shah CRF: Are we still using DOH page? If yes, VF page name should be changed
                    return resultMap;
               // }
                
            }
        }  
        return null;
   }
    
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
    }

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
    //       }
          
           return result;
       }        
       return null;
   }
 
    
     @RemoteAction 
   global static List<Object> getOrganization(String programId){ 
       Id userID = UserInfo.getUserId(); 
       List<Object> result= new List<Object>();   
       List<Program__c> programs = [select Account__r.Name from Program__c where Id =:programId limit 1];
      
       //Shah CRF: The following SOQL could return more rows. What is the purpose of this SOQL? Also record type query could use relationship field.
       List<Account> acc = [select id,name from Account where Status__c='Active' and IsGrantingAgency__c =true and recordtypeid in
                                            (select id from REcordType where sObjectType='Account' and name ='Internal') ];
           for(Account accnt : acc){
               Map<String,String> bureaus = new Map<String,String>();
               bureaus.put('Value',accnt.id);
               bureaus.put('Label',accnt.Name);
               result.add(bureaus);
             }

             return result;

     /*  System.debug('programs : '+programs );
       if(programs .size () > 0){
           for(Program__c program : programs){
               Map<String,String> programMap = new Map<String,String>();
               programMap .put('Value',program.Account__c);
               programMap .put('Label',program.Account__r.Name);
               result.add(programMap );
           }
          system.debug('programs : result: '+result);
           return result;
       }      */  
       //return null;
   }
    
   
  /* @RemoteAction
   global static List<Object> getPrograms(String bureauId){
       System.debug('bureauId: '+bureauId);
       List<Object> result= new List<Object>();   
       List<Program__c> programs = [select Id,Name,ProgramName__c from Program__c where Account__c =:bureauId];
       System.debug('programs : '+programs );
       if(programs .size () > 0){
           for(Program__c program : programs){
               Map<String,String> programMap = new Map<String,String>();
               programMap .put('Value',program.id);
               programMap .put('Label',program.ProgramName__c);
               result.add(programMap );
           }
          system.debug('programs : result: '+result);
           return result;
       }        
       return null;
   } */
   
   @RemoteAction 
   global static Map<String,Object> getCoreServiceArea(String programId){
     System.debug('programId: '+programId);
       Map<String,Object> result= new  Map<String,Object>();
       List<Object> duplicateCoreServiceArea = new List<Object>();
       List<Object> uniqueCoreServiceArea = new List<Object>();
       //Weike add ServiceArea__r.CoreServiceArea__c, ServiceArea__r.CoreServiceArea__r.Name      
       List<ProgramServiceArea__c> programServiceAreas = [select Id,ServiceArea__c,ServiceArea__r.Name, ServiceArea__r.CoreServiceArea__c, ServiceArea__r.CoreServiceArea__r.Name
                from ProgramServiceArea__c where Program__c =:programId];  
       Set<String> coreServiceArea = new Set<String>();
       System.debug('programServiceAreas : '+programServiceAreas );
       if(programServiceAreas .size () > 0){
           for(ProgramServiceArea__c  programSA : programServiceAreas){
            System.debug('programSA : '+programSA );
               Map<String,String> programSAMapClone = new Map<String,String>();
                System.debug('prprogramSA.ServiceArea__r.CoreServiceArea__cgramSA00 : ');
              
               if(programSA.ServiceArea__c != null){ 
                System.debug('prprogramSA.ServiceArea__r.CoreServiceArea__cgramSA : ' + programSA.ServiceArea__r.CoreServiceArea__c);
                   if(!coreServiceArea.contains(programSA.ServiceArea__r.CoreServiceArea__r.Name.toLowerCase())){
                     System.debug('prprogramSA.ServiceArea__r.CoreServiceArea__cgramSA22 : ' + programSA.ServiceArea__r.CoreServiceArea__c);
              
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
       /*List<Object> coreServiceAreasList = (List<Object>)JSON.deserializeUntyped(coreServiceAreas);    
       List<String> coreServiceAreasListString  = new List<String>();
       for(Object coreSA : coreServiceAreasList){
        coreServiceAreasListString.add(String.valueOf(coreSA));       
       }
       system.debug('coreServiceAreasList==='+coreServiceAreasList);*/
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
   }
   
    @RemoteAction 
    global static Map<String,Object> saveAndContinue(String recordId,Id annId){
        Savepoint sp = Database.setSavepoint();
        String newId = '';
    	Map<String,Object> result = new  Map<String,Object>();
    	try{
    		ApplicationCloneHelper cloneHelper = new ApplicationCloneHelper();
    		newId = cloneHelper.cloneApplication(recordId, annId);
    	}catch(Exception e){
    		result.put('Error',e.getMessage());
            Database.rollback(sp);
            return result;
        }
    	
        result.put('URL','/apex/'+AppUtils.getNamespacePrefix()+'ApplicationView?Id='+newId);
        result.put('Error','');
        return result;
   }    
    
      @RemoteAction
   global static List<Object> getAllPrograms(){
       List<Object> result= new List<Object>();          
       List<User> usr = [Select Id,OrganizationAccountName__c from User where Id =: UserInfo.getUserId()];         
      /* List<Application__c> applications= [select Id,Name,ExternalOrganization__r.name from application__c where status__c IN('Submitted to Grantor','Review Initiated') and ExternalOrganization__r.name =:usr[0].OrganizationAccountName__c and recordtypeid in
                                            (select id from RecordType where sObjectType='Application__c' and name ='Grantor')];  */
      List<Application__c> applications= [select Id,Name,ExternalOrganization__r.name,Title__c from application__c where ExternalApplicantStatus__c IN('Submitted to Grantor') and ExternalOrganization__r.name =:usr[0].OrganizationAccountName__c and recordtypeid in
                                            (select id from RecordType where sObjectType='Application__c' and name ='Grantor')];                                       
       System.debug('applications: '+applications);
       if(applications.size () > 0){
           for(Application__c application : applications){
               Map<String,String> applicationMap = new Map<String,String>();
               applicationMap.put('Value',application.id);
               applicationMap.put('Label',application.Name + ' - ' + application.Title__c);
               result.add(applicationMap);
           }
          system.debug('program>>>>'+result);
           return result;
       }        
       return null;
   }
    
}