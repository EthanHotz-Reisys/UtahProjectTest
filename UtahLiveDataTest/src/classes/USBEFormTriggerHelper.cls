public with sharing class USBEFormTriggerHelper extends GNT.TriggerHelper{

     private String appName = GNT.UserPreferenceHelper.getStringValue('ActiveAppName__c');
     public override void processbeforeInsert() {
         updateMOEFields(Trigger.new);
         
     }
     
     public override void processAfterInsert() {
         Map<ID,String> formNames=new Map<ID,String>();
         for (GNT__PageTemplate__c formconfigs:[SELECT id,name from GNT__PageTemplate__c]) {
             formNames.put(formconfigs.ID,formconfigs.name);
         }
         for (USBEForm__c form : (List<USBEForm__c>)Trigger.new) {
             Id formconfigID= form.ConfigForm__c;
             String formType=formnames.get(formconfigID);
             if (formType.equalsIgnoreCase('LEAPrivateSchoolForm')) {
                 insertPrivateSchoolFormItems(Trigger.new);
                 break;
             }
         }
         
     }

     //private void updateMOEFields(List<USBEForm__c> formList){
    
     //   Map<ID,MOE__c> LeaToMoeMap= new Map<ID,MOE__c>(); 
     //   for (MOE__c MOEObject:[SELECT Id,LEA__c,MetMOE1__c,MetMOE2__c,MetMOE3__c,MetMOE4__c,
     //   PriorYearLevelOfEffort1__c,PriorYearLevelOfEffort2__c,PriorYearLevelOfEffort3__c,PriorYearLevelOfEffort4__c,
     //   RequiredLevelOfEffort1__c,RequiredLevelOfEffort2__c,RequiredLevelOfEffort3__c,RequiredLevelOfEffort4__c,
     //   Year__c FROM MOE__c]){
     //       LeaToMoeMap.put(MOEObject.LEA__c,MOEObject);
     //   }


     //   Map<ID,Application__c> UsbfToApp= new Map<ID,Application__c>();

     //   for (Application__c app:[Select id,ExternalOrganization__c from Application__c])
     //       UsbfToApp.put(app.id,app);

        
     //   Map<ID,ID> UsbfToFormName= new Map<ID,ID>();
     //   for (USBEForm__c form: formList)
     //       UsbfToFormName.put(form.id,form.ConfigForm__c);

     //   Map<ID,String> formNames=new Map<ID,String>();

     //   for (GNT__PageTemplate__c formconfigs:[SELECT id,name from GNT__PageTemplate__c])
     //   formNames.put(formconfigs.ID,formconfigs.name);
        

     //   for (USBEForm__c usbf:formList){
     //       Id formconfigID=usbf.ConfigForm__c;
     //       String formType=formnames.get(formconfigID);
     //       System.debug('Before Trigger ConfigForm__c: '+formnames.get(formconfigID));
     //       if (formType.equalsIgnoreCase('MOEForm')){
        
     //       if (UsbfToApp.containsKey(usbf.Application__c)){
     //       Application__c app1=UsbfToApp.get(usbf.Application__c);
     //       if (LeaToMoeMap.containsKey(app1.ExternalOrganization__c)){
     //       MOE__c moe=LeaToMoeMap.get(app1.ExternalOrganization__c );
     //       usbf.MOELookup__c=moe.Id;
     //       }
     //       }
     //       }
     //   }

     //}


 private void updateMOEFields(List<USBEForm__c> formList){
    
        Map<ID,MOE__c> LeaToMoeMap= new Map<ID,MOE__c>(); 
        Map<ID,ID> UsbfToFormName= new Map<ID,ID>();
        List<Id> formconfigIDs=new List<Id>();
        List<Id> AppIds=new List<Id>();
        for (USBEForm__c form: formList){
            UsbfToFormName.put(form.id,form.ConfigForm__c);
            formconfigIDs.add(form.ConfigForm__c);
            AppIds.add(form.Application__c);
        }
        List<Id> AccIds=new List<Id>();
         Map<ID,Application__c> UsbfToApp= new Map<ID,Application__c>();
        for (Application__c app:[Select id,ExternalOrganization__c from Application__c where id in :AppIds]){
        AccIds.add(app.ExternalOrganization__c);
         UsbfToApp.put(app.id,app);
        }

        for (MOE__c MOEObject:[SELECT Id,LEA__c,MetMOE1__c,MetMOE2__c,MetMOE3__c,MetMOE4__c,
        PriorYearLevelOfEffort1__c,PriorYearLevelOfEffort2__c,PriorYearLevelOfEffort3__c,PriorYearLevelOfEffort4__c,
        RequiredLevelOfEffort1__c,RequiredLevelOfEffort2__c,RequiredLevelOfEffort3__c,RequiredLevelOfEffort4__c,
        Year__c FROM MOE__c where LEA__c in :AccIds]){
            LeaToMoeMap.put(MOEObject.LEA__c,MOEObject);
        }
       
     
        Map<ID,String> formNames=new Map<ID,String>();
        for (GNT__PageTemplate__c formconfigs:[SELECT id,name from GNT__PageTemplate__c where id in :formconfigIDs])
        formNames.put(formconfigs.ID,formconfigs.name);
        

        for (USBEForm__c usbf:formList){
            Id formconfigID=usbf.ConfigForm__c;
            String formType=formnames.get(formconfigID);
            System.debug('Before Trigger ConfigForm__c: '+formnames.get(formconfigID));
            if (formType.equalsIgnoreCase('MOEForm')){
        
            if (UsbfToApp.containsKey(usbf.Application__c)){
            Application__c app1=UsbfToApp.get(usbf.Application__c);
            if (LeaToMoeMap.containsKey(app1.ExternalOrganization__c)){
            MOE__c moe=LeaToMoeMap.get(app1.ExternalOrganization__c );
            usbf.MOELookup__c=moe.Id;
            }
            }
            }
        }

     }




     public override void processbeforeUpdate() {
         Map<ID,String> formNames=new Map<ID,String>();
         for (GNT__PageTemplate__c formconfigs:[SELECT id,name from GNT__PageTemplate__c]) {
             formNames.put(formconfigs.ID,formconfigs.name);
         }
         for (USBEForm__c form : (List<USBEForm__c>)Trigger.new) {
             Id formconfigID= form.ConfigForm__c;
             String formType=formnames.get(formconfigID);
             if (formType.equalsIgnoreCase('LEAPrivateSchoolForm')) {
                 LEAPrivateSchoolFormValidation(Trigger.new);
                 break;
             }
         }
     }



    private void LEAPrivateSchoolFormValidation(List<USBEForm__c> formList){
        List<ID> formIds = new List<ID>();
        for (USBEForm__c form : formList) {
            if (form.PrivateSchoolNA__c == true) {
                form.PrivateSchoolHiddenFlag__c = 'complete';
                continue;
            }
            formIds.add(form.Id);
        }
        
        List<LEAPrivateSchoolFormItem__c> itemList = [SELECT ReceivingFundsPicklist__c, USBEForm__c from LEAPrivateSchoolFormItem__c where USBEForm__c IN :formIds];
        
        for (LEAPrivateSchoolFormItem__c item : itemList) {
            if (item.ReceivingFundsPicklist__c == null) {
                
                Trigger.new[0].addError('Participation field is required for all schools.');
                return;
            }
        }

        for (USBEForm__c form : formList) { //If form validation does not fire, form is complete
            form.PrivateSchoolHiddenFlag__c = 'complete';
        }
    }    
   
    
    private void insertPrivateSchoolFormItems(List<USBEForm__c> formList) {
        System.debug('FormList: ' + formList);
        List<ID> appIds = new List<ID>();
        List<ID> formIds = new List<ID>();
        for (USBEForm__c form : formList) {
            appIds.add(form.Application__c);
            formIds.add(form.Id);
        }
        
        List<Application__c> apps = new List<Application__c>();
        if (appIds.size() > 0) {
            apps = [SELECT Id, ExternalOrganization__c from Application__c where id IN :appIds];
        }
        
        Map<Application__c, Id> formMap = new Map<Application__c, Id>();
        for (USBEForm__c form : formList) {
            for (Application__c app : apps) {
                if (form.Application__c == app.Id) {
                    formMap.put(app, form.Id);
                    continue;
                }
            }
        }
        
        List<ID> leaIds = new List<ID>();
        
        for (Application__c app : apps) {
            leaIds.add(app.ExternalOrganization__c);
        }
        
        List<LEAPrivateSchool__c> schoolList = new List<LEAPrivateSchool__c>();
        if (leaIds.size() > 0) {
            schoolList = [SELECT LEA__c from LEAPrivateSchool__c where LEA__c IN :leaIds];
        }
        if (schoolList.size() == 0) {
            List<USBEForm__c> forms = [SELECT Id, PrivateSchoolNA__c from USBEForm__c where Id IN :formIds];
            for (USBEForm__c form : forms) {
                form.PrivateSchoolNA__c = true;
                form.PrivateSchoolHiddenFlag__c = 'complete';
            }
            update forms;
            return;
        }
        
        List<LEAPrivateSchoolFormItem__c> formItems = new List<LEAPrivateSchoolFormItem__c>();
        //Create formitems for each form
        for (LEAPrivateSchool__c school : schoolList) {
            for (Application__c app : formMap.keySet()) {
                if (school.LEA__c == app.ExternalOrganization__c) {
                    ID formId = formMap.get(app);
                    LEAPrivateSchoolFormItem__c formItem = new LEAPrivateSchoolFormItem__c(
                        LEAPrivateSchool__c = school.Id,
                        Application__c = app.Id,
                        USBEForm__c = formId
                    );
                    formItems.add(formItem);
                }
            }
        }
        
        insert formItems;
    }

}