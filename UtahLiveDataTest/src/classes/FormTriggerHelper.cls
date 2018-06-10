public with sharing class FormTriggerHelper extends GNT.TriggerHelper{

     private String appName = GNT.UserPreferenceHelper.getStringValue('ActiveAppName__c');
     
     public override void processBeforeUpdate() {
         if(appName !='StateasGrantee'){
             updateYesNoFields(Trigger.new);
         }
     }
     
    public override void processAfterUpdate() {
        if (appName != 'StateasGrantee') { //So pretty much if appName = StateasGrantor
            copyFormFieldToApplication(Trigger.new);
            handleApplicationFieldUpdate(Trigger.new);
        }
    }

     public override void processAfterInsert() {
         handleApplicationFieldUpdate(Trigger.new);
         if(appName =='StateasGrantee'){
             buildConstructionCategories(); 
         }else{
            createFormTableItems(Trigger.new);
            
         }
     }
     
     private void updateYesNoFields(List<Form__c> formList){
        for(Form__c temp : formList){
          if(temp.PageTemplateName__c == 'Required VAWA Questions'){
            if(temp.AC2__c == null || temp.AC2__c == 'No'){
              temp.AC3__c = null;
              temp.AC4__c = null;
              temp.AC5__c = null;
              temp.AC6__c = null;
            }
            if(temp.AC7__c == null || temp.AC7__c == 'No'){
              temp.Q16VictimServices__c = null;
              temp.Q16LawEnforcement__c = null;
              temp.Q16Prosecution__c = null;
              temp.Q16Courts__c = null;
              temp.Q16Probation__c = null;
              temp.Q16HealthCare__c = null;
            }
          }
        }  
     }
     
     //On update/insert inside form trigger, update the value of the field storing the wanted value inside the corresponding application object
     private void handleApplicationFieldUpdate(List<Form__c> formList) {     
         try {
             Set<Id> appIds = new Set<Id>();
             Boolean updateTotalCrime = false; 
             Map<Id, Decimal> appCrimeVals= new Map<Id, Decimal>();
             for (Form__c temp : formList) {
                 if (temp.PageTemplateName__c == 'VAWA COVER SHEET') { //If this form is the VAWA COVER SHEET form, update the total crime field
                     if (temp.DomesticViolence__c != null && temp.CSStalking__c != null && temp.SexualAssault__c != null && temp.DatingViolence__c != null) {
                         appCrimeVals.put(temp.Application__c, (temp.DomesticViolence__c + temp.CSStalking__c + temp.SexualAssault__c + temp.DatingViolence__c));
                         updateTotalCrime = true;
                     }
                 }
             }
             if (updateTotalCrime == true) {
                 appIds = appCrimeVals.keySet();
                 Map<Id, Application__c> appUpdateMap = new Map<Id, Application__c>([SELECT Id, TotalCrimeType__c FROM Application__c WHERE Id in: appIds]);
                 for (Id appIdsIterator : appIds) {
                     appUpdateMap.get(appIdsIterator).TotalCrimeType__c = appCrimeVals.get(appIdsIterator); //Stores the TotalCrimeType__c number value from the Form__c object that is associated with the particular application Id
                 }
                 update appUpdateMap.values();
             }          
         }
         catch (Exception e) {
             System.debug('Error: ' + e);
         } 
     }  

    private void copyFormFieldToApplication(List<Form__c> formlist){
        try{
            Set<Id> appIds = new Set<Id>();
            Set<Id> formIds = new Set<Id>();
            for(Form__c forms : formlist){
                if(forms!=null && forms.Application__c !=null){
                    appIds.add(forms.Application__c);
                }
            }
            //Map<Id, Form__c> crimePercent = new Map<Id,Form__c>([Select Id,DVPercent__c,CSStalkingPercent__c,SAPercent__c,DaVPercent__c from Form__c where Id in :formIds]);
            //Map<Id,Application__c> appMap = new Map<Id,Application__c>([Select Id, DVPercent__c,CSStalkingPercent__c,SAPercent__c,DaVPercent__c from Application__c where Id in :appIds]);
            List<Application__c> apps = [Select Id,DVPercent__c,CSStalkingPercent__c,SAPercent__c,DaVPercent__c,TotalCrimeType__c from Application__c where Id in :appIds];
            for(Form__c forms : formlist){
                if(forms.PageTemplateName__c == 'VAWA COVER SHEET'){
                    for(Application__c app : apps){
                        system.debug('app id is ' +app.Id);
                        app.DVPercent__c = forms.DVPercent__c;
                        app.CSStalkingPercent__c = forms.CSStalkingPercent__c;
                        app.SAPercent__c = forms.SAPercent__c;
                        app.DaVPercent__c = forms.DaVPercent__c;
                    }
                }
            }
            update apps;
            
        }
        catch (Exception e) {
            System.debug('Error: '+e);
        }
    }
    
     private void createFormTableItems(List<Form__c> formList){
        List<Form__c> validForm = new List<Form__c>();
        for(Form__c f : formList){
          if(f.PageTemplateName__c == 'Required VAWA Questions' || f.PageTemplateName__c == 'Required VAWA Questions II'){
            validForm.add(f);
          }
        }

        if(validForm.size() == 0){
          return;
        }

        List<String> nameList = new List<String>();
        nameList.add('Administrator;FTEStaff');
        nameList.add('Attorney (does not include prosecutor);FTEStaff');
        nameList.add('Counselor;FTEStaff');
        nameList.add('Court personnel;FTEStaff');
        nameList.add('Information technology staff;FTEStaff');
        nameList.add('Investigator (prosecution based);FTEStaff');
        nameList.add('Law enforcement officer;FTEStaff');
        nameList.add('Legal advocate (does not include attorney or paralegal);FTEStaff');
        nameList.add('Paralegal;FTEStaff');
        nameList.add('Probation officer/offender monitor;FTEStaff');
        nameList.add('Program coordinator (training coordinator, volunteer coordinator, hotline coordinator, victim services coordinator);FTEStaff');
        nameList.add('Prosecutor;FTEStaff');
        nameList.add('Sexual assault nurse examiner/sexual assault forensic examiner (SAFE/SANE);FTEStaff');
        nameList.add('Support staff (administrative assistant, bookkeeper, accountant);FTEStaff');
        nameList.add('Trainer;FTEStaff');
        nameList.add('Translator/interpreter;FTEStaff');
        nameList.add('Victim advocate (non-governmental, includes domestic violence, sexual assault, and dual);FTEStaff');
        nameList.add('Victim assistant (governmental, includes victim-witness specialist/coordinator);FTEStaff');
        //----------------------------------------------
        nameList.add('Advocacy organization (NAACP,AARP);PeopleUsingFund');
        nameList.add('Batterer intervention program;PeopleUsingFund');
        nameList.add('Corrections (probation,parole, and correctional facility staff);PeopleUsingFund');
        nameList.add('Court;PeopleUsingFund');
        nameList.add('Domestic violence organization;PeopleUsingFund');
        nameList.add('Educational institutions/organizations;PeopleUsingFund');
        nameList.add('Faith-based organization;PeopleUsingFund');
        nameList.add('Governmental agency (SSA,TANF);PeopleUsingFund');
        nameList.add('Health/mental health organization;PeopleUsingFund');
        nameList.add('Law enforcement;PeopleUsingFund');
        nameList.add('Legal organization (legal services, bar association, law school);PeopleUsingFund');
        nameList.add('Prosecutor’s office;PeopleUsingFund');
        nameList.add('Sex offender management/sex;PeopleUsingFund');
        nameList.add('offender treatment provider;PeopleUsingFund');
        nameList.add('Sexual assault organization;PeopleUsingFund');
        nameList.add('Social service organization (nongovernmental);PeopleUsingFund');
        nameList.add('Tribal government/Tribal;PeopleUsingFund');
        nameList.add('government agency;PeopleUsingFund');
        nameList.add('Other (specify): ;PeopleUsingFund');
        //--------------------------------------------------
        nameList.add('Advocacy organization (NAACP, AARP);COORDINATEDCOMMUNITYRESPONSE');
        nameList.add('Batterer intervention program;COORDINATEDCOMMUNITYRESPONSE');
        nameList.add('Corrections (probation, parole, and correctional facility staff);COORDINATEDCOMMUNITYRESPONSE');
        nameList.add('Court;COORDINATEDCOMMUNITYRESPONSE');
        nameList.add('Domestic violence;COORDINATEDCOMMUNITYRESPONSE');
        nameList.add('Educational institutions/organizations;COORDINATEDCOMMUNITYRESPONSE');
        nameList.add('Faith-based organization;COORDINATEDCOMMUNITYRESPONSE');
        nameList.add('Governmental agency (SSA, TANF);COORDINATEDCOMMUNITYRESPONSE');
        nameList.add('Health/mental health organizations;COORDINATEDCOMMUNITYRESPONSE');
        nameList.add('Law enforcement;COORDINATEDCOMMUNITYRESPONSE');
        nameList.add('Legal organization (legal services, bar association, law school);COORDINATEDCOMMUNITYRESPONSE');
        nameList.add('Prosecutor’s office;COORDINATEDCOMMUNITYRESPONSE');
        nameList.add('Sex offender management/sex offender treatment provider;COORDINATEDCOMMUNITYRESPONSE');
        nameList.add('Sexual assault organization;COORDINATEDCOMMUNITYRESPONSE');
        nameList.add('Social service organization;COORDINATEDCOMMUNITYRESPONSE');
        nameList.add('Tribal government/Tribal government agency;COORDINATEDCOMMUNITYRESPONSE');
        nameList.add('Other (specify) ;COORDINATEDCOMMUNITYRESPONSE');
        //------------------------------------------------
        nameList.add('Develop a new unit;Q23FundUse');
        nameList.add('Support, expand, or coordinate an existing unit;Q23FundUse');
        nameList.add('Train a specialized unit;Q23FundUse');
        nameList.add('Other (specify): ;Q23FundUse');
        //----------------------------------------------------
        nameList.add('Sexual Assault;Q23FundVictim');
        nameList.add('Domestic violence/dating violence;Q23FundVictim');
        nameList.add('Stalking;Q23FundVictim');
        nameList.add('Other (specify): ;Q23FundVictim');
        //---------------------------------------------------------
        nameList.add('Evaluation;SystemImprove');
        nameList.add('Interpreters;SystemImprove');
        nameList.add('Language lines;SystemImprove');
        nameList.add('Meetings between tribal and non-tribal entities;SystemImprove');
        nameList.add('Safety audits;SystemImprove');
        nameList.add('Security personnel or equipment;SystemImprove');
        nameList.add('Translation of forms and documents;SystemImprove');
        nameList.add('Other: (specify) ;SystemImprove');
        //-------------------------------------------------------------
        nameList.add('Civil legal advocacy/court accompaniment;VictimServices');
        nameList.add('Civil legal assistance;VictimServices');
        nameList.add('Counseling services/support group;VictimServices');
        nameList.add('Criminal justice advocacy/court accompaniment;VictimServices');
        nameList.add('Crisis intervention;VictimServices');
        nameList.add('Forensic exam;VictimServices');
        nameList.add('Hospital/clinic/other medical response;VictimServices');
        nameList.add('Language services;VictimServices');
        nameList.add('Transportation;VictimServices');
        nameList.add('Victim/survivor advocacy ;VictimServices');
        nameList.add('Other: (specify) ;VictimServices');
        //----------------------------------------------------------------
        nameList.add('Emergency Shelter;ShelterServices');
        nameList.add('Transitional housing;ShelterServices');
        //-----------------------------------------------------------------
        nameList.add('Calls for assistance (All 911 and other calls made to law enforcement);AnticipatedFund');
        nameList.add('Incident reports (All responses to an incident as reported on an incident report);AnticipatedFund');
        nameList.add('Cases/incidents investigated (All cases in which rape kits were processed);AnticipatedFund');
        nameList.add('Arrests (All arrests made by law enforcement, except dual arrests);AnticipatedFund');
        nameList.add('Protection/ex parte/temporary restraining orders served (All instances in which these types of orders will be served on offenders);AnticipatedFund');
        nameList.add('Arrests for violation of bail bond (All instances in which arrests will be made of offenders who violate conditions set out in their bail bonds);AnticipatedFund');
        nameList.add('Enforcement of warrants (All instances in which warrants relating to these incidents were enforced);AnticipatedFund');
        nameList.add('Arrests for violation of protective order;AnticipatedFund');
        nameList.add('Protection orders issued (All orders directly issued by law enforcement in jurisdictions where law enforcement officers are so authorized);AnticipatedFund');
        nameList.add('Referrals of cases to prosecutor;AnticipatedFund');
        nameList.add('Referrals of federal firearms charges to federal prosecutor;AnticipatedFund');
        //-------------------------------------------------------------------------
        nameList.add('Misdemeanor sexual assault;AnticipatedCase');
        nameList.add('Felony sexual assault;AnticipatedCase');
        nameList.add('Homicide related to sexual assault, domestic violence/dating violence, or stalking;AnticipatedCase');
        nameList.add('Felony domestic violence/dating violence;AnticipatedCase');
        nameList.add('Stalking ordinance;AnticipatedCase');
        nameList.add('Misdemeanor stalking;AnticipatedCase');
        nameList.add('Felony stalking;AnticipatedCase');
        nameList.add('Violation of protection order;AnticipatedCase');
        nameList.add('Violation of bail;AnticipatedCase');
        nameList.add('Violation of probation/parole;AnticipatedCase');
        nameList.add('Violation of other court order;AnticipatedCase');
        //--------------------------------------------------------------------------
        nameList.add('Unduplicated count of domestic violence/dating violence offenders;TotalOffenders');
        nameList.add('Unduplicated count of sexual assault offenders;TotalOffenders');
        nameList.add('Unduplicated count of stalking offenders;TotalOffenders');
        //----------------------------------------------------------------------
        nameList.add('Face-to-face meeting with offender;AnticipatedActivities');
        nameList.add('Telephone contact with offender;AnticipatedActivities');
        nameList.add('Unscheduled surveillance of offender;AnticipatedActivities');
        nameList.add('Outreach to victims/survivors;AnticipatedActivities');
        
        List<FormTable__c> result = new List<FormTable__c>();
        for(Form__c f : validForm){
          for(String temp : nameList){
            String[] nameTable = temp.split(';');
            FormTable__c ft = new FormTable__c(Name__c = nameTable[0], TableName__c = nameTable[1], Form__c = f.Id);
            result.add(ft);
          }
        }
        insert result;
     }

      private void buildConstructionCategories(){
         
           System.debug('Entering form trigger -->');
          Map<Id,Form__c> appFormMap = new Map<Id,Form__c>();
          List<ApplicationBudgetCategory2__c> newList = new List<ApplicationBudgetCategory2__c>();

           for(Form__c form: (List<Form__c>) Trigger.New){
              if((form.PageTemplateName__c== GNT.KeyValueStoreHelper.getTextValue('Budget Information Construction Form',true)) || 
                  (form.PageTemplateName__c== GNT.KeyValueStoreHelper.getTextValue('Budget Non Construction Form',true))) {
                  appFormMap.put(form.Application__c,form);
              }
          }
          
          List<FormBudgetInformation__c> formBudgetLst = new List<FormBudgetInformation__c>();
          for(Form__c form: (List<Form__c>) Trigger.New){
            if(form.PageTemplateName__c == GNT.KeyValueStoreHelper.getTextValue('Budget Non Construction Form',true)){
              String typeOfCat = GNT.KeyValueStoreHelper.getTextValue('Forecasted Cash Needs Type',true);
              List<String> nonConstructLst = typeOfCat.split(',');
                for(String val : nonConstructLst){
                    FormBudgetInformation__c formBudget = new FormBudgetInformation__c();
                    formBudget.GrantProgramFunctionOrActivity__c = val;
                    formBudget.Form__c=form.Id;
                    formBudgetLst.add(formBudget);
                }

            }
          }

          System.debug('Form Budget Lst is -->'+formBudgetLst);
          if(formBudgetLst.size()>0){
            insert formBudgetLst;
          }
          Set<Id> appVal = appFormMap.keySet();
          System.debug('appFormMap------------------------>' + appFormMap);
          Map<Id, List<BudgetPeriod__c>> appBudPeriod = new Map<Id, List<BudgetPeriod__c>>();
          Map<Id, List<ApplicationServiceArea__c>> appServArea = new Map<Id,List<ApplicationServiceArea__c>>();
          List<BudgetPeriod__c> budPeriod = [SELECT Id, BudgetStartDate__c,Application__c FROM BudgetPeriod__c WHERE Application__c in :appVal and Status__c='Active'];          
          List<ApplicationServiceArea__c> servArea = [SELECT Id, Application__c,ServiceArea__c  FROM ApplicationServiceArea__c WHERE Application__c in :appVal ];
         
          for(BudgetPeriod__c bud : budPeriod){
              List<BudgetPeriod__c> innerList = appBudPeriod.get(bud.Application__c);
              if(innerList ==  null){
                  innerList = new List<BudgetPeriod__c>();
                  appBudPeriod.put(bud.Application__c,innerList);
              }
              innerList.add(bud);
          }

          for(ApplicationServiceArea__c serv :servArea){
            List<ApplicationServiceArea__c> innerList = appServArea.get(serv.Application__c);
            if(innerList == null){
              innerList = new List<ApplicationServiceArea__c>();
              appServArea.put(serv.Application__c,innerList);
            }
            innerList.add(serv);
          }
          
          for(Id app:appVal){
               List<BudgetPeriod__c> lst = appBudPeriod.get(app);
               Form__c form = appFormMap.get(app);
               List<ApplicationServiceArea__c> serviceLst = appServArea.get(app);
               List<ApplicationBudgetCategory2__c> appbudCats = new List<ApplicationBudgetCategory2__c>();

               if(form.PageTemplateName__c == GNT.KeyValueStoreHelper.getTextValue('Budget Information Construction Form',true)){
                 appbudCats = [Select Id,ServiceArea__c, Form__c from ApplicationBudgetCategory2__c where Application__c =:app and BudgetPeriod__c=: lst[0].Id and ServiceArea__c =:serviceLst[0].Id];
               }
               else{
                  appbudCats = [Select Id,ServiceArea__c, Form__c from ApplicationBudgetCategory2__c where Application__c =:app and BudgetPeriod__c=: lst[0].Id];
               }

               System.debug('appbudCats----------------->' + appbudCats);
               for(ApplicationBudgetCategory2__c appbudCat:appbudCats){
                   Form__c tempForm = appFormMap.get(app);
                   appbudCat.Form__c= tempForm.Id;
                   appbudCat.AppBudgetCategoryStatus__c = 'Active';

                   newList.add(appbudCat);
               }
          }

           if(newList.size()>0){
               update newList;
           }
    }
}