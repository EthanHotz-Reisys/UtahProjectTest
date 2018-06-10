global class SelectPackageCtrl1 {
    /**
    * Pankaj - This method will use to get all package types
    */
    @RemoteAction
    global static List<Map<String, String>> getPackageTypes(String recordId) {
        String recordTypeName=GNT.UserPreferenceHelper.getStringValue('ActiveAppName__c');
        List<GNT__PackageTypeConfig__c> grantpackageTypeList= new List<GNT__PackageTypeConfig__c>();
        List<Map<String, String>> returnList = new List<Map<String, String>>();
        returnList.add( new Map<String, String>{'id'=>'-- Select --', 'name'=>'-- Select --'} );
        List<GNT__PackageTypeConfig__c> packageTypeList = [select name,GNT__CustomAppConfig__c,GNT__LayoutForm__c from GNT__PackageTypeConfig__c where GNT__CustomAppConfig__r.Name
                                                        =: GNT.UserPreferenceHelper.getStringValue('ActiveAppName__c')];
        if(recordTypeName=='StateAsGrantor'){
            grantpackageTypeList = [select name,GNT__CustomAppConfig__c,GNT__LayoutForm__c from GNT__PackageTypeConfig__c where GNT__CustomAppConfig__r.Name
                                                        =:recordTypeName and name NOT IN('Application','Pre-Application','App-Review')];
        }
        if(recordTypeName=='StateAsGrantee'){
            grantpackageTypeList = [select name,GNT__CustomAppConfig__c,GNT__LayoutForm__c from GNT__PackageTypeConfig__c where GNT__CustomAppConfig__r.Name
                                                        =:recordTypeName and name NOT IN('Application','Pre-Application','App-Review','Site Visit')]; 
        }
        List<GNT__PackageTypeConfig__c> annpackageTypeList = [select name,GNT__CustomAppConfig__c,GNT__LayoutForm__c from GNT__PackageTypeConfig__c where GNT__CustomAppConfig__r.Name
                                                        =: GNT.UserPreferenceHelper.getStringValue('ActiveAppName__c') and name NOT IN('Payment Request','Award','Amendment Request')];
        List<BusinessPackage__c> businessPackages;
        String recordIdType =  ((Id)recordId).getSobjectType().getDescribe().getName();
        if(recordIdType.contains('Program__c')){
            businessPackages = [select id,name,PackageType__c from BusinessPackage__c where Program__c=:recordId];
        } else if(recordIdType.contains('Grant__c')){
            businessPackages = [select id,name,PackageType__c from BusinessPackage__c where Grant__c=:recordId ];
        }  else{
            businessPackages = [select id,name,PackageType__c from BusinessPackage__c where FundingOpportunity__c=:recordId];
        }
        Set<String> exstingPackageTypes = new Set<String>();
        for(BusinessPackage__c businesspackage : businessPackages){
            exstingPackageTypes.add( businesspackage.PackageType__c );
        }
        if(recordIdType.contains('Grant__c')){
            for(GNT__PackageTypeConfig__c packageTypeConfig : grantpackageTypeList){
            if(!exstingPackageTypes.contains(packageTypeConfig.name)){
                returnList.add( new Map<String, String>{'id'=>packageTypeConfig.name, 'name'=>packageTypeConfig.name} );
            }
          }
            
        }else if(recordIdType.contains('Announcement__c')){
            for(GNT__PackageTypeConfig__c packageTypeConfig : annpackageTypeList){
            if(!exstingPackageTypes.contains(packageTypeConfig.name)){
                returnList.add( new Map<String, String>{'id'=>packageTypeConfig.name, 'name'=>packageTypeConfig.name} );
            }
         }
        }
       else{
        for(GNT__PackageTypeConfig__c packageTypeConfig : packageTypeList){
            if(!exstingPackageTypes.contains(packageTypeConfig.name)){
                returnList.add( new Map<String, String>{'id'=>packageTypeConfig.name, 'name'=>packageTypeConfig.name} );
            }
         }
       }
        return returnList;
    }
    /**
    * Pankaj - This method will use to get all packages for given submission type
    */
    @RemoteAction
    global static Map<String, Object> getPackageNames(String businessFormId, String recordId, String submissionType) {
        
        // get All packages List
        String recordIdType =  ((Id)recordId).getSobjectType().getDescribe().getName();
        Map<String, Object> returnMap = new Map<String, Object>();
        // In case of new get all submission types else get only record submission Type.
        if(businessFormId == null || businessFormId == ''){
            /*List<String> packageTypeList= getPackageType(recordId, recordIdType);
            if(packageTypeList.size() > 0 ) {
                submissionType = submissionType!= null && submissionType != '' ? submissionType : packageTypeList.get(0);
                List<Map<String, String>> packageMapLst = new List<Map<String, String>>();
                for(String pkgType : packageTypeList){
                    packageMapLst.add(new Map<String, String>{'id'=>pkgType, 'name'=>pkgType});
                }
                returnMap.put('packageTypeList', packageMapLst);
            }*/
        }
        if(businessFormId != null && businessFormId != ''){
            BusinessPackage__c businessPackage = [select id,name,PackageConfig__c,IsMandatory__c,HideForExternalUser__c,PackageConfig__r.Name,PackageConfig__r.GNT__Description__c,PackageConfig__r.GNT__Source__c,
                                                PackageConfig__r.RecordType.name,PackageType__c from BusinessPackage__c where Id=:businessFormId];
            submissionType = businessPackage.PackageType__c;
            returnMap.put('packageId', businessPackage.PackageConfig__c);
            returnMap.put('packageName', businessPackage.PackageConfig__r.Name);
            returnMap.put('source', businessPackage.PackageConfig__r.GNT__Source__c);
            returnMap.put('packageDescription', businessPackage.PackageConfig__r.GNT__Description__c);
            returnMap.put('recordType', businessPackage.PackageConfig__r.RecordType.name);
            returnMap.put('isMandatory', businessPackage.IsMandatory__c);
            returnMap.put('hideForExternalUser', businessPackage.HideForExternalUser__c);
            //Special case so hardcoded - check if package is cloned from program to annoucement and it is custom then you can not remove mandatory attritbute from forms
            Boolean isPackageCloned = false;
            if( recordIdType ==  AppUtils.getNameSpacePrefix()+'Announcement__c') {
                Announcement__c ann = [select program__c from Announcement__c where id=:recordId];
                List<BusinessPackage__c> pgmBusinessPackage = [select id,name,PackageConfig__c from BusinessPackage__c where Program__c = :ann.program__c and PackageType__c=:submissionType];
                if(pgmBusinessPackage.size() > 0){
                    isPackageCloned = (pgmBusinessPackage[0].PackageConfig__c == businessPackage.PackageConfig__c)? true : false;
                }
            }
            returnMap.put('disableMandAction', isPackageCloned);
            returnMap.put('PackageForms', getFormList1( businessPackage.PackageConfig__c, null, isPackageCloned ) );
        }
        // show sourcce to grantee. On grator side it will be set value to State(It will be part of trigger).
        if( GNT.UserPreferenceHelper.getStringValue('ActiveAppName__c') == 'StateAsGrantee') {
            returnMap.put('showSource', true);
            List<Map<String, String>> sourceValues = new List<Map<String, String>>();
            sourceValues.add(new Map<String, String>{'id'=>'','name'=>'-- Select --'});
            sourceValues.add(new Map<String, String>{'id'=>'Federal','name'=>'Federal'});
            sourceValues.add(new Map<String, String>{'id'=>'NGO','name'=>'NGO'});
            returnMap.put('sourceValues', sourceValues);
        } else {
            returnMap.put('showSource', false);
        }
        
        //get packageName list. Default should be All.
        List<Map<String, String>> packaNameList = new List<Map<String, String>>();
        packaNameList.add(new Map<String, String>{'id'=>'All', 'name'=>'All Forms'});
        List<GNT__Package__c> pkgList = [Select Id,Name,GNT__Description__c from GNT__Package__c 
                                where GNT__SubmissionType__c =:submissionType 
                                and RecordType.Name='Standard' and GNT__CustomAppConfig__r.Name=: GNT.UserPreferenceHelper.getStringValue('ActiveAppName__c') and
                                 GNT__Status__c = 'Active'];
        for(GNT__Package__c pkg : pkgList) {
            packaNameList.add(new Map<String, String>{'id'=>pkg.Id, 'name'=>pkg.Name});
        }
        //returnMap.put('showRequiredCheckBox', ( recordIdType ==  AppUtils.getNameSpacePrefix()+'Announcement__c') ? false :true);
        returnMap.put('showRequiredCheckBox', false);
        returnMap.put('packageList', packaNameList);
        returnMap.put('submissionType', submissionType);
        return returnMap;
    }
    /**
    * Pankaj :- Method use to get all forms associated with packageId. If packageId is All then return all forms for given submission type.
    */
    
    @RemoteAction
    global static List<Map<String, Object>> getFormList1(String packageId, String submissionType, Boolean isPackageCloned) {
        List<Map<String, Object>> returnList = new List<Map<String, Object>>();
        if(packageId != 'All') {
            List<GNT__PackageFormConfig__c> lstPackageForms = [Select Id,Name,GNT__FormConfig__r.Name,GNT__FormConfig__r.GNT__OMBNumber__c,GNT__FormConfig__r.GNT__Version__c,GNT__isMandatory__c 
                                                            from GNT__PackageFormConfig__c where GNT__PackageConfig__c =: packageId order by GNT__Order__c];
            for(GNT__PackageFormConfig__c pkgForm : lstPackageForms){
                System.debug('isPackageCloned===='+isPackageCloned);
                System.debug('pkgForm.isMandatory__c===='+pkgForm.GNT__isMandatory__c);
                returnList.add(new Map<String, Object>{'id'=>pkgForm.GNT__FormConfig__r.Id,'selected'=>pkgForm.GNT__isMandatory__c,'disableMandatory'=>pkgForm.GNT__isMandatory__c && isPackageCloned,
                                                         'name'=>pkgForm.GNT__FormConfig__r.Name + 
                                                        (pkgForm.GNT__FormConfig__r.GNT__OMBNumber__c != null ? ', '+pkgForm.GNT__FormConfig__r.GNT__OMBNumber__c : '') +
                                                        (pkgForm.GNT__FormConfig__r.GNT__Version__c != null ? ', v'+pkgForm.GNT__FormConfig__r.GNT__Version__c : '')});
            }
        } else {
            System.debug(submissionType+'---');
            List<GNT__PageTemplate__c> pageFormsList = [select Id,Name,GNT__OMBNumber__c,GNT__Version__c from GNT__PageTemplate__c where GNT__PackageType__c =:submissionType and 
                                                        GNT__CustomAppConfig__r.Name=:GNT.UserPreferenceHelper.getStringValue('ActiveAppName__c') and GNT__Status__c = 'Active' and
                                                        RecordType.Name='Business Form'];
            System.debug('pageFormsList--->'+pageFormsList);                                                        
            for(GNT__PageTemplate__c pageForm : pageFormsList){
                returnList.add(new Map<String, Object>{'id'=>pageForm.Id, 'name'=>pageForm.Name + 
                                                        (pageForm.GNT__OMBNumber__c != null ? ', '+pageForm.GNT__OMBNumber__c : '') +
                                                        (pageForm.GNT__Version__c != null ? ', v'+pageForm.GNT__Version__c : '')});
            }
            System.debug('returnList--->'+returnList);
        }
         return returnList; 
    }    
    @RemoteAction
    global static PageReference upsertAndSelectPackage(Boolean selectExistingPackage, String parentId, Map<String, Object> paramMap) {
        SavePoint sp;
        try{
        sp = sp = Database.setSavepoint();
        System.debug('parentId=====' + parentId);
        System.debug('paramMap=====' + paramMap);
        String objectAPIName = ( (Id)parentId).getSobjectType().getDescribe().getName();
        String pkgId = null;
        String requiredFieldAPIName = null;
        String businessFormId  = (String)paramMap.get('businessFormid');
        System.debug('businessFormId--->'+businessFormId);
        String submissionType = (String)paramMap.get('pkgType');
        System.debug('submissionType--->?'+submissionType);
        Boolean requiredPackage = (Boolean)paramMap.get('requiredPackage');
        system.debug('requiredPackage'+requiredPackage );
        Boolean hideForExternalUser = (Boolean)paramMap.get('hideForExternalUser');
        system.debug('hideForExternalUser '+hideForExternalUser );
         system.debug('selectExistingPackage '+selectExistingPackage);
        IF( !selectExistingPackage ){
            pkgId = (String)paramMap.get('packageId');
            System.debug('pkgId=====' + pkgId);
            String packageName = (String)paramMap.get('packageName');
            System.debug('packageName=====' + packageName);
            String packageDescription = (String)paramMap.get('packageDescription');
            System.debug('packageDescription=====' + packageDescription);
            String formIdStr = (String)paramMap.get('formids');
            String packageRecordType = (String)paramMap.get('recordType');
            System.debug('formIdStr=====' + formIdStr);
            List<Object> formObjList = (List<Object>)JSON.deserializeUntyped(formIdStr);
            String referenceObjectAPIName = '';
            System.debug('appBNae=ne--->'+GNT.UserPreferenceHelper.getStringValue('ActiveAppName__c'));
            System.debug('submissionType--->>>'+submissionType);

            System.debug('UserPreferenceHelper--->>>'+GNT.UserPreferenceHelper.getStringValue('ActiveAppName__c'));
            GNT__PackageTypeConfig__c pkgTypeConfig = [select id,GNT__LayoutForm__c from GNT__PackageTypeConfig__c where Name =:submissionType
                                                    and GNT__CustomAppConfig__r.Name =:GNT.UserPreferenceHelper.getStringValue('ActiveAppName__c')];
            GNT__CustomApp__c customApp = [select name from GNT__CustomApp__c where Name=:GNT.UserPreferenceHelper.getStringValue('ActiveAppName__c') and GNT__Active__c=true];
            
            //In case of Editing standard Package, clone package and make it custom.
            System.debug('packageRecordType======' + packageRecordType);
            Id recordTypeId = Schema.SObjectType.GNT__Package__c.getRecordTypeInfosByName().get('Custom').getRecordTypeId();
            //Id recordTypeId = GNT.AppUtils.GetRecordTypeIdsByDeveloperName(GNT__Package__c.SObjectType).get('Custom');
            //if Editing standard package then create new custom package
            if(packageRecordType == 'Standard'){
                pkgId = null;
                if( businessFormId != '' && businessFormId != null ){
                    delete [select id from BusinessPackage__c where id=:businessFormId];
                }
                businessFormId = null;
            }
            System.debug('pkgId======' + pkgId);
            GNT__Package__c pack = new GNT__Package__c(Id=( pkgId != '' ? pkgId : null) , Name=packageName, GNT__PageTemplateConfig__c =pkgTypeConfig.GNT__LayoutForm__c, GNT__CustomAppConfig__c = customApp.Id,
                                              GNT__Status__c = 'Active', GNT__SubmissionType__c= submissionType, GNT__Description__c=packageDescription);
            if( pack.id == null ) {
                pack.recordTypeId = recordTypeId;
            }
            if(GNT.UserPreferenceHelper.getStringValue('ActiveAppName__c') == 'StateAsGrantee') {
                pack.GNT__Source__c = (String)paramMap.get('source');
            }
            upsert pack;
            pkgId = pack.Id;
            // delete existing package forms.
            if( pkgId != null ) {
                delete [select id,name from GNT__PackageFormConfig__c where GNT__PackageConfig__c=:pkgId];
                system.debug('Deleted Successfully');
            }
            List<GNT__PackageFormConfig__c> packFormConfigList = new List<GNT__PackageFormConfig__c>();            
            Integer i= 1;
            System.debug('After delete--->'+packFormConfigList);
            System.debug('formObjList--->'+formObjList);            
            for(Object form : formObjList) {
                System.debug('form=======' + form);
                Map<String, Object> formObj = (Map<String, Object>)form;
                System.debug('formObj=======' + formObj);
                packFormConfigList.add( new GNT__PackageFormConfig__c(GNT__FormConfig__c = String.valueOf( formObj.get('id') ), GNT__PackageConfig__c = pack.Id, 
                                                        GNT__isMandatory__c = ( (formObj.get('selected') != null && formObj.get('selected') != '' ) ? (Boolean)formObj.get('selected') : false),
                                                         GNT__Order__c = i++) );
            }
            insert packFormConfigList;
        } else {
             System.debug('pkgId11111=====' + pkgId);
            System.debug('paramMap=====' + paramMap);

             if(paramMap.get('packageId')==null){
                throw new CustomExceptions.InputDataException('Please select package');
             
             }
             System.debug('pkgId1111156=====' + pkgId);
                pkgId = String.valueOf( paramMap.get('packageId') );
                System.debug('pkgId=====' + pkgId);
            //fieldAPIName = String.valueOf( paramMap.get('fieldName') );
        }                                       
        // update package reference field on sobject
        System.debug('hideForExternalUser: ' + hideForExternalUser);
        System.debug('pkgId========' + pkgId);
        if( businessFormId != '' && businessFormId != null ){
            delete [select id from BusinessPackage__c where id=:businessFormId];
            businessFormId = null;
        }
        BusinessPackage__c businessPkg = new BusinessPackage__c(Id=( businessFormId == '' ? null : businessFormId), IsMandatory__c=requiredPackage==null?false:requiredPackage, HideForExternalUser__c=hideForExternalUser==null?false:hideForExternalUser,
            PackageConfig__c=pkgId, PackageType__c=submissionType,
            FundingOpportunity__c= (objectAPIName.contains('Announcement__c')  ? parentId : null), Program__c= (objectAPIName.contains('Program__c')  ? parentId : null),
            Grant__c=  (objectAPIName.contains('Grant__c')  ? parentId : null));
            upsert businessPkg;
        PageReference p = new PageReference('/'+parentId);
        return p;
        }catch(Exception e){
            Database.rollback(sp);
            throw e;
        }
        return null;
    }
    public string getKeyValueMap(){
        Map<String,String> keyValueMap = new Map<String,String>();
        keyValueMap.put('objName','');        
        keyValueMap.put('activeAppID',[Select Id from GNT__CustomApp__c where Name =: GNT.UserPreferenceHelper.getStringValue('ActiveAppName__c')].Id); 
        return JSON.serialize(keyValueMap);
        // get the users current active Application       
    }    
}