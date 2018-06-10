/**
    **********************************************************
    Audit History
    **********************************************************  
   
    01/04/2016    swati singh      Edited
    **********************************************************  
*/
public without sharing class ApplicantRegistrationPage2Ctrl{

    //Properties
    private List<Account> lstAccounts;
    private  List<UserRegistration__c> userRegistrations;
    public String EINNumber{get;private set;}
    
    public PageReference savePage {get;set;}
    public PageReference cancelPage {get;set;}
    public UserRegistration__c userReg{get;set;}
    public Boolean showCaptcha{get;set;}
    public Boolean isRegistrationSuccessful{get;set;}
    public Boolean isAdminRequired {get;set;}
    public Boolean startPanel{get;set;}
    public String EINValue{get;set;}
    public string orgName{get;set;}
    public string orgCity{get;set;}
    public string orgState{get;set;}
    public string orgCountry{get;set;}
    public Boolean confirmationPanel{get;set;}
    public Boolean showContactInfoPanel{get;set;}
    public UserRegistration__c accountMissingRequiredFields{get;set;}
    public Boolean redirectToEditOrganization{get;set;}
    public set<String> missingFields;
    public map<string,Object> apiNameToValuesMap;
    public Boolean orgMissingRequiredFields{get;set;}
    public String externalLoginPageUrl{get;set;}
    public Boolean directToCreateUserInfo{get;set;}
    public Boolean OrgInProgressAfterSearchResult{get;set;}
    public String namespace{get;set;}
    public String approverForAppliant{get;set;}
    
    public Boolean showCountryValidationPanel{get; set;}
    
    public Boolean showOrgCreatePanel{get;set;}
    public Boolean showorgInfoPanel{get; set;}
    public Boolean OrgNotExistPanel{get;set;}
    public String adminName{get;set;}
    public String adminEmail{get;set;}  
    public boolean isAdminNotApproved{get;set;} 
    public String cancelPageName{get;set;}
    public List<SelectOption> applicantTypes;
    public List<SelectOption> validCountries;
    public string loginValidationtype;
    public string organizationName{get;set;}
    public string countrySelected{get;set;}
    public String registrationSuccessMsg {get; set;}
    private UserRegistration__c orgSelected{get;set;}
    public GNT.PageLayoutConfigHelper.AlternativeRendering altRen {get; set;}
    public Map<String,GNT.PageLayoutConfigHelper.AlternativeRendering> fieldAPINameToAltRen {get;set;}
    public Id selectedOrgId{get;set;}
    public String createOrgAddInfoBlockHeader {get; set;} 
    public String createOrgBasicInfoBlockHeader {get; set;}
    public String createOrgOuterBlockHeader {get; set;}
    public String createUserAddInfoBlockHeader {get; set;}
    public String createUserBasicInfoBlockHeader {get; set;}
    public String createUserOuterBlockHeader {get; set;}
    public String newUserCountryBlockHeader {get; set;}
    public String newUserEINBlockHeader {get; set;}
    public String newUserDUNSBlockHeader{get;set;}
    public String orgSelectionConfirmMsg {get; set;}
    public Boolean showCreateUserAddInfoBlock {get; set;}
    public String countryLabel {get; set;}
    public String isReviewer {get;set;}
    public String type{get;set;}
    public boolean doNotAllowToRegister {get;set;}
    public String dunsNumber {get;set;}
    public List<CommunityRegistrationConfigDetailWrapper> CommunityRegistrationConfigDetailWrapperList{get;set;}
    public CommunityRegistrationConfig__c communityRegistrationConfig{get;set;}
    public String CommunityRegistrationHeaderText{get;set;}
    public Integer SelectionLimitForAreaOfExpertise{get;set;}
    public Boolean IsUserRegistrationaDOHSpecific{get;set;}
    public string dummy{get;set;}

    public Boolean testRendered{get;set;}
    public Id recordId{get;set;}
    public String pageTemplateName{get;set;}
    public String keyPOCfName{get;set;}
    public String keyPOClName{get;set;}
    public String sw{get;set;}
   




    @TestVisible private boolean isCaptchaVerified;   
    private boolean existingOrgSelected;
    private boolean noOrgExist;
    private String securityToken;
   // private UserInvitation__c invitation;
    private Contact reviewerContact; //Added 09032015 - Shrawan

    //Captcha Changes
    private static String baseUrl = 'https://www.google.com/recaptcha/api/verify'; 

    // The keys you get by signing up for reCAPTCHA for your domain
    private static String privateKey = GNT.KeyValueStoreHelper.getTextValue('CaptchaPrivateKey',true);
    public String publicKey { 
        get { return GNT.KeyValueStoreHelper.getTextValue('CaptchaPublicKey',true); }
    } 
    
    public String challenge { 
        get {
            return ApexPages.currentPage().getParameters().get('recaptcha_challenge_field');
        }
    }
    public String response  { 
        get {
            return ApexPages.currentPage().getParameters().get('recaptcha_response_field');
        }
    }
    
    public String orgSearchIdentifier{get;private set;}
    
    public string getLoginValidationtype(){
        String validationType = GNT.KeyValueStoreHelper.getTextValue('ExternalLoginValidationType',true);
        return validationType;
        
    }
    public PageReference redirectPage(){
        String isReviewer = ApexPages.currentPage().getParameters().get('isReviewer');
        Boolean isNewUserRegWindowOpen = GNT.AppUtils.getIsNewUserRegWindowOpen();   
        if(isReviewer != 'true' && isNewUserRegWindowOpen!=null && !isNewUserRegWindowOpen){
            PageReference pg = Page.NoRegistration;
            return pg;
        }
        return null;
    }
    public ApplicantRegistrationPage2Ctrl(ApexPages.StandardController stdController){      
        recordId= ApexPages.CurrentPage().getParameters().get('ID');
        List<UserRegistration__c> ur = [SELECT Id, recordtype.name FROM UserRegistration__c WHERE id =:recordId LIMIT 1];
        sw = ur[0].recordtype.name;
        securityToken = ApexPages.currentPage().getParameters().get('t');
        orgResultWrapper = new List<OrganizationResultWrapper> ();
        externalLoginPageUrl = GNT.KeyValueStoreHelper.getTextValue('ExternalLoginPage',true); 
        startPanel = true;        
        isAdminNotApproved = false;
        orgMissingRequiredFields = false;
        confirmationPanel = false;
        isAdminRequired = false;
        isRegistrationSuccessful = false;
        showCaptcha = true;
        redirectToEditOrganization = false;
        existingOrgSelected = false;
        noOrgExist = false;
        doNotAllowToRegister=false;
        userReg = (UserRegistration__c)stdController.getRecord();       
        userReg.PhysicalCountry__c = 'USA';
        userReg.Countries__c = 'USA';
        userReg.Country__c = 'USA';
        userReg.IsAutoCreteatedRecord__c = false;
        directToCreateUserInfo = false;
        namespace = AppUtils.getNameSpacePrefix()+'';
        IsUserRegistrationaDOHSpecific = GNT.KeyValueStoreHelper.getBooleanValue('IsUserRegistrationaDOHSpecific',true);
        fetchKeyValueStore();
        isReviewer = ApexPages.currentPage().getParameters().get('isReviewer');
        
        //  11/12/2015-Shrawan moved code befoe if condition - Begin
        securityToken = ApexPages.currentPage().getParameters().get('t');
        if(!String.isEmpty(securityToken)){
           
        }                 
        // End
        if(isReviewer == 'true'){
           
        }
        else {
            fetchCommunityRegistrationConfigRecords(sw);
            PageReference pg = Page.CommunitiesLanding;
            cancelPageName = pg.getURL();
            cancelPageName = cancelPageName.substring(6);
            userReg.RecordTypeId = Schema.SObjectType.UserRegistration__c.getRecordTypeInfosByName().get('Applicant').getRecordTypeId();
        }      
        System.debug('userReg:<<<' + userReg);
    }
       

    
    /*Get Applicant Types*/
    public List<SelectOption> getApplicantTypes(){
        applicantTypes = new List<SelectOption>();
        List<GNT__Picklist__c> picklists = GNT__Picklist__c.getAll().values();
        for(GNT__Picklist__c pickList : picklists){
            applicantTypes.add(new SelectOption(pickList.GNT__DisplayValue__c,pickList.GNT__DisplayValue__c));
        }
        return applicantTypes;  
    }
    
    /* create oganization button  */
    
     public PageReference CreateOrganization() {
      
       PageReference pg = Page.ApplicantRegistrationEdit;
        for(CommunityRegistrationConfigDetailWrapper a : CommunityRegistrationConfigDetailWrapperList){
                if(!String.isEmpty(a.inputFieldAPIName) && a.value != null){
                    if(a.inputField == 'EIN'){
                      pg.getParameters().put('EIN',String.valueOf(a.value));
                    }else if(a.inputField == 'DUNS'){
                         pg.getParameters().put('DUNS',String.valueOf(a.value));
                    }                
                }            
            } 
       
      pg.setRedirect(true);
       return pg ;
       
    }
    
    /*get country picklist*/
    public List<SelectOption> getValidCountries(){
        validCountries  = new List<SelectOption>();       
        validCountries.add(new SelectOption('', 'All Countries'));
        List<String> picklists = GNT.AppUtils.getCountryPickListValues();
        if(picklists!=null){
         for(String pickList : picklists){
            validCountries.add(new SelectOption(pickList,pickList));
            }     
        }
       
        return validCountries;  
    } 
    
    public List<OrganizationResultWrapper> orgResultWrapper {get;set;}
    public class OrganizationResultWrapper{
        public UserRegistration__c orgObj{get;set;}
        public boolean selected{get;set;}
        
        public OrganizationResultWrapper(UserRegistration__c orgObj){
            this.orgObj = orgObj;
            this.selected = false;
        }
    }
    
    public void applySelectedFlags(){
        selectedOrgId = ApexPages.CurrentPage().getParameters().get('selectedOrgId');
        if(selectedOrgId == null){
            selectedOrgId = orgSelected.Id;
        }
        for(OrganizationResultWrapper wrap : orgResultWrapper){
            if(wrap.orgObj.id == selectedOrgId || wrap.orgObj.id == orgSelected.Id ){
                orgSelected = wrap.orgObj;
            }
        }
    }

    public boolean getAdminApprovalRequired(){
        boolean isApprovalRequired = GNT.KeyValueStoreHelper.getBooleanValue('IsExternalUserRegApprovalRequired', true);
        return isApprovalRequired;
    }
    
    /*
        This method used to check for the available Domain in Organizations. 
        The matching domain Orgs are displayed on community portal
    */
    public void checkOrganizations(){
        OrgNotExistPanel = false;
        String dynamicFilter;
        String namespace = AppUtils.getNameSpacePrefix();
        String limitClause = '';
        String fldString = '';
        
        try{
            orgSearchIdentifier = GNT.KeyValueStoreHelper.getTextValue('ExternalLoginValidationType',true);
            
            // form a where clause based on the entry validation
            if(orgSearchIdentifier.equalsIgnoreCase('EIN')){
                EINNumber = EINValue;
                userReg.EINText__c = EINNumber;
                dynamicFilter = ' EINText__c= \''+EINNumber + '\'';
                limitClause = ' Limit 1';
            }else if(orgSearchIdentifier.equalsIgnoreCase('Country')){
                if (String.isEmpty(organizationName)) {
                    ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.ERROR,GNT.ErrorMessageHelper.fetchMessage('P02-GRNTR-91067'));
                    ApexPages.addMessage(errorMsg);
                    return;                    
                }
                if (organizationName.length() < 3) {
                    ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.ERROR,GNT.ErrorMessageHelper.fetchMessage('P02-GRNTR-19261'));
                    ApexPages.addMessage(errorMsg);
                    return;                    
                }
                userReg.Countries__c  = countrySelected;
                userReg.OrganizationName__c  = organizationName;                   
                if (!String.isEmpty(countrySelected)) {
                    dynamicFilter = ' OrganizationCountry__c =\''+countrySelected+'\' AND OrganizationName__c like \'%'+organizationName+'%\'';
                }
                else {
                    dynamicFilter = ' OrganizationName__c like \'%'+organizationName+'%\'';
                }
            }else if(orgSearchIdentifier.equalsIgnoreCase('DUNS')){    
                if(dunsNumber.length() == 9){                                                             
                    userReg.DUNS__c = dunsNumber;
                    dynamicFilter = ' DUNS__c = '+dunsNumber;
                    limitClause = ' Limit 1';
                }else{                  
                }
            }
            
            // field set used to show fields on the org search result page
            String orgResulFldSetName = namespace + 'Org_Search_Result';
            List<Schema.FieldSetMember> fieldsetMembers = Schema.SObjectType.UserRegistration__c.fieldSets.getMap().get(orgResulFldSetName).getFields();
            // code block to form fields list from the field set
            for(Schema.FieldSetMember fldMember : fieldsetMembers){
                String tempFld = fldMember.getfieldPath() + ',';    //removeStartIgnoreCase
                tempFld = tempFld.removeStartIgnoreCase(namespace).trim();
                fldString += tempFld;
            }
            // list of other fields
            fldString += 'OrganizationName__c,OrganizationCountry__c,EINText__c,DUNS__c,Website__c,OrganizationType__c,OrganizationCityAddress__c,OrganizationStreetAddress__c,OrganizationState__c,OrganizationZipCode__c';
            // logic to filter duplicate fields from field set and above fields
            List<String> fldList = fldString.split(',');
            Set<String> fldSet = new Set<String>();
            fldSet.addAll(fldList);
            
            fldString = '';
            // comma separated list of field
            for(String fld : fldSet){
                fldString += fld + ',';
            }
            fldString = fldString.removeEnd(',');
            // dynamic query on user registration to search on matching records
            String qry = 'select ' + fldString + ' from UserRegistration__c where '+ dynamicFilter +' ' +limitClause;
            List<UserRegistration__c> userRegistrationsTemp = Database.query(qry);
            Map<String, UserRegistration__c> resultMap = new Map<String, UserRegistration__c>();
            for(UserRegistration__c urObj : userRegistrationsTemp){
                resultMap.put(urObj.OrganizationName__c, urObj);
            }
            userRegistrations = resultMap.values();
            orgResultWrapper = new List<OrganizationResultWrapper> ();
            // form a wrapper class of the org search result
            if(userRegistrations != null && userRegistrations.size() > 0){
                for(UserRegistration__c uObj : userRegistrations){
                    orgResultWrapper.add(new OrganizationResultWrapper(uObj));
                }
                confirmationPanel = true;
                startPanel = false;
            }
            else{
                OrgNotExistPanel = true;
            }
        }catch(Exception e){
            if(e.getMessage().contains('Invalid integer:')){
                ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.ERROR,GNT.ErrorMessageHelper.fetchMessage('P02-GRNTR-14027'));
                ApexPages.addMessage(errorMsg);
            }else{
                ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage());
                ApexPages.addMessage(errorMsg);
            }
        }
    }
    
    
    
    public void saveUserRegistrationEntry(){
        checkCaptcha();
        setDefaultValues();

        try{
            showContactInfoPanel = false;
            if(this.isCaptchaVerified == true || Test.isRunningTest()){
                isReviewer = ApexPages.currentPage().getParameters().get('isReviewer'); 
                type = ApexPages.currentPage().getParameters().get('type');               
                if(!String.isEmpty(isReviewer)){
                    if(isReviewer.equalsIgnoreCase('true')){
                        userReg.isApplicant__c = false;
                        userReg.isReviewer__c = true;
                    }
                }else{
                    userReg.isApplicant__c = true;
                    isReviewer='false';
                }
           
                userReg.Status__c = 'In Progress';
                Map<String, Object> result = MapQuestAddressInformationCtrl.GetLatLangAddressRemote(userReg.OrganizationStreetAddress__c, userReg.OrganizationCityAddress__c, userReg.OrganizationState__c);

                if(result.size() > 0){
                    userReg.Location__Latitude__s = (Decimal)(result.get('lat'));
                    userReg.Location__Longitude__s = (Decimal)(result.get('lng'));
                }
                if(Schema.sObjectType.UserRegistration__c.isCreateable()){
                    insert userReg;
                }
             
                Id reviewerRecordTypeId = Schema.SObjectType.UserRegistration__c.getRecordTypeInfosByName().get('Reviewer').getRecordTypeId();
                List<UserRegistration__c> userRegList;
                List<Account> acc;
                if(userReg.RecordTypeId == reviewerRecordTypeId){
                    userRegList = [SELECT Id FROM UserRegistration__c WHERE Email__c =: userReg.Email__c AND (Status__c != 'Rejected' OR (userrole__c = 'Project Associate' and Status__c = 'Rejected'))];
                }
                else{                    
                    orgSearchIdentifier = GNT.KeyValueStoreHelper.getTextValue('ExternalLoginValidationType', true);
                    if(orgSearchIdentifier.equalsIgnoreCase('EIN')){
                       userRegList = [SELECT Id FROM UserRegistration__c WHERE (EINText__c = :userReg.EINText__c ) AND (Status__c != 'Rejected' OR (userrole__c = 'Project Associate' and Status__c = 'Rejected'))];  
                       acc = [SELECT Id, Name, ApplicantType__c, Website, EINText__c, DUNS__c FROM Account Where RecordType.DeveloperName = 'External' AND ( Name =:userReg.organizationName__c) LIMIT 1];
                    }
                    else if(orgSearchIdentifier.equalsIgnoreCase('Country')){
                        userRegList = [SELECT Id from UserRegistration__c WHERE ( organizationName__c =:userReg.organizationName__c) AND (Status__c != 'Rejected' OR (userrole__c = 'Project Associate' and Status__c = 'Rejected'))];
                        acc = [SELECT Id, Name, ApplicantType__c, Website, EINText__c, DUNS__c FROM Account WHERE RecordType.DeveloperName = 'External' AND ( Name =:userReg.organizationName__c) LIMIT 1];
                    }
                }              
                if(acc != null && acc.size()== 0 && userReg.UserRole__c != 'Project Associate'){             
                    if(userRegList.size() == 1){
                        isAdminRequired = false;
                        isRegistrationSuccessful = true;
                    }else{
                        isRegistrationSuccessful = true;
                    }
                }else{
                    isRegistrationSuccessful = true;
                }
                showCaptcha = false;
          }else{
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,GNT.ErrorMessageHelper.fetchMessage('P02-GRNTR-07272')));
                isRegistrationSuccessful = false;
                showCaptcha = true;
                showContactInfoPanel = true;
            }
        
        }catch(Exception e){
            system.debug(e.getMessage());
            ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage());
            ApexPages.addMessage(errorMsg);
        }
        
    }
    
    public void showContactInfo(){
       // GNT.BusinessRuleResult result = GNT.BusinessRuleConfigHelper.execute('ValidateCommunityRegOrgData', userReg);
       /* Commenting the code as we are moving the Business Rule Config from Custom setting to Custom object */
        if(!orgMissingRequiredFields){
          /*  GNT.BusinessRuleResult result = GNT.BusinessRuleConfigHelper.execute('ValidationBasedOnEINAndDUNS', userReg);
            if (result != null && result.hasErrors()) {
                result.addErrorsToPage();
                return;
            }*/
        }
        if(orgMissingRequiredFields){
            for(String apiName : missingFields){
                accountMissingRequiredFields.put(apiName,userReg.get(apiName));
            }
        }        
        showContactInfoPanel = true;
        confirmationPanel = false;
        showOrgCreatePanel = false;
        showCaptcha = true;
        isRegistrationSuccessful = false;
        //showCaptchaInfo();        
    }
    
    private void orgDetailsMapping(){
        
            if(orgSelected != null){
               UserRegistration__c dummyUserReg = [SELECT OrganizationName__c,EINText__c,DUNS__c,Website__c,Ward__c,
                                                    PrimaryPOCSuffix__c,PrimaryPOCPrefix__c,OrgnizationPhoneNumber__c,
                                                    PrimaryPOCLastName__c,PrimaryPOCFirstName__c,PrimaryPOCEmail__c,OrganizationTypeSInglePicklist__c FROM UserRegistration__c 
                                           WHERE ID = :orgSelected.Id];
                userReg.OrganizationName__c = dummyUserReg.OrganizationName__c;
                userReg.EINText__c = dummyUserReg.EINText__c;
                userReg.DUNS__c = dummyUserReg.DUNS__c;
                /*In case org is found*/ 
               // markUserAsPrimaryOrSecondaryApplicant();                
            }        
    }
    
    public void showOrgCreateInfo(){
        try {

       
           testRendered = true;
           startPanel = false;
            showOrgCreatePanel = true;
            showContactInfoPanel = false;
            confirmationPanel = false;
            OrgNotExistPanel = false;
            existingOrgSelected = false;
            noOrgExist = true;
            for(CommunityRegistrationConfigDetailWrapper a : CommunityRegistrationConfigDetailWrapperList){
                if(!String.isEmpty(a.inputFieldAPIName) && a.value != null){
                    if(a.inputField == 'EIN'){
                        //userReg.put(a.inputFieldAPIName,Double.valueOf(a.value).longValue());
                        //Commented as EIN is now text - Manasi
                        userReg.put(a.inputFieldAPIName,a.value);
                    }else if(a.inputField == 'DUNS'){
                        userReg.put(a.inputFieldAPIName,String.valueOf(a.value));
                    }                
                }            
            }
            /*In case org is not found and 'Create Organization' is clicked*/
           // markUserAsPrimaryOrSecondaryApplicant();        
        } catch(Exception e) {
            testRendered = true;   
        }
    }
    
    public void checkIfAccountIsMissingRequiredFields(){
        List<String> organizationFields = new List<String>();
        OrgNotExistPanel = false;
        startPanel = false;
        showCaptcha = true;
        Boolean isEmptyFlag = false;
        missingFields = new Set<String>();
        apiNameToValuesMap = new Map<String,object>();               
        if(String.isEmpty(selectedOrgId)){
            return;         
        }
        orgDetailsMapping();
        Integer limitOfUsers = GNT.KeyValueStoreHelper.getIntegervalue('AllowedExternalUsersPerOrganisation',true);         
        if(limitOfUsers != null){
            List<user> userList = [SELECT Id,OrganizationAccountName__c,IsActive FROM User WHERE Contact.Account.EINText__c = :userReg.EINText__c AND Contact.Account.DUNS__c = :userReg.DUNS__c AND IsActive = TRUE];          
            if(userList != null){
                if(userList.size()>=limitOfUsers){
                    doNotAllowToRegister =true;
                    confirmationPanel = false;
                    showOrgCreatePanel = false;
                    existingOrgSelected = true; 
                    showContactInfoPanel = false;    
                    // ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'User Limit Exceeded');
                    ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.ERROR,GNT.ErrorMessageHelper.fetchMessage('P02-GRNTR-85893'));
                    ApexPages.addMessage(errorMsg);                                     
                    return;
                }
            }
        }        
            
            String query = 'SELECT ';                           
            List<Schema.FieldSetMember> extUserRegOrgInformation =  SObjectType.UserRegistration__c.FieldSets.ExtUserReg_Org_Information.getFields();
            List<Schema.FieldSetMember> extUserRegOrgAddressInformation =  SObjectType.UserRegistration__c.FieldSets.ExtUserReg_Org_Address_Information.getFields();
            List<Schema.FieldSetMember> extUserRegOrgPrimaryPOC =  SObjectType.UserRegistration__c.FieldSets.Primary_Point_of_Contact_Info.getFields();
                                    
            
            for(Schema.FieldSetMember f : extUserRegOrgInformation) {                                       
                    query += f.getFieldPath() + ', ';  
                    organizationFields.add(f.getFieldPath());                      
            }
            
            for(Schema.FieldSetMember f : extUserRegOrgAddressInformation ) {                                       
                    query += f.getFieldPath() + ', ';        
                    organizationFields.add(f.getFieldPath());                
            }
            
            for(Schema.FieldSetMember f : extUserRegOrgPrimaryPOC ) {                                       
                    query += f.getFieldPath() + ', ';        
                    organizationFields.add(f.getFieldPath());                
            }
            query += 'Id FROM UserRegistration__c WHERE ID = \''+ selectedOrgId +'\''  ;
            accountMissingRequiredFields = Database.Query(query);
            //update accountMissingRequiredFields;
            
            for(Schema.FieldSetMember f : extUserRegOrgInformation) {
                if(f.getRequired()){
                    if(accountMissingRequiredFields != null){
                        if(accountMissingRequiredFields.get(f.getFieldPath()) == null){
                            isEmptyFlag = true; 
                            missingFields.add(f.getFieldPath());    
                        }else{
                            apiNameToValuesMap.put(f.getFieldPath(),accountMissingRequiredFields.get(f.getFieldPath()));                            
                        }
                    } 
                }               
            }
            
            for(Schema.FieldSetMember f : extUserRegOrgAddressInformation ) {
                if(f.getRequired()){
                    if(accountMissingRequiredFields != null){
                        if(accountMissingRequiredFields.get(f.getFieldPath()) == null){
                            isEmptyFlag = true; 
                            missingFields.add(f.getFieldPath());    
                        }else{
                            apiNameToValuesMap.put(f.getFieldPath(),accountMissingRequiredFields.get(f.getFieldPath()));                            
                        }
                    } 
                }               
            }
            
            for(Schema.FieldSetMember f : extUserRegOrgPrimaryPOC ) {
                if(f.getRequired()){
                    if(accountMissingRequiredFields != null){
                        if(accountMissingRequiredFields.get(f.getFieldPath()) == null){
                            isEmptyFlag = true; 
                            missingFields.add(f.getFieldPath());    
                        }else{
                            apiNameToValuesMap.put(f.getFieldPath(),accountMissingRequiredFields.get(f.getFieldPath()));                            
                        }
                    } 
                }               
            }
                
            for(String apiName : apiNameToValuesMap.keyset() ){
                if(apiNameToValuesMap.get(apiName) != null){
                    userReg.put(apiName,apiNameToValuesMap.get(apiName));
                }               
            }
            
            if(isEmptyFlag){    
                orgMissingRequiredFields = true;            
                confirmationPanel = false;
                showContactInfoPanel = false;
                showorgInfoPanel=false;
                doNotAllowToRegister = false;   
                showOrgCreatePanel = true;
                showCreateUserAddInfoBlock = false;
                showOrgCreateInfo();
            }else{
                orgMissingRequiredFields = false;            
                confirmationPanel = false;
                showContactInfoPanel = true;
                showorgInfoPanel=false;
                doNotAllowToRegister = false;   
                showOrgCreatePanel = false;
                showCreateUserAddInfoBlock = true;
                directToCreateUserInfo = true;  
                for(String field : organizationFields){
                    userReg.put(field,accountMissingRequiredFields.get(field));
                }               
                                  
            }                   
    }
    
    //Called when an existing org is selected
    public void showContactInfoWithOrgSelected(){
        if (String.isEmpty(selectedOrgId)) {
            ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.ERROR,GNT.ErrorMessageHelper.fetchMessage('P02-GRNTR-85893'));
            return;
        }
        //checkIfAccountIsMissingRequiredFields();
        orgDetailsMapping();         
        if(!String.isEmpty(organizationName)){
            Integer limitOfUsers = GNT.KeyValueStoreHelper.getIntegervalue('AllowedExternalUsersPerOrganisation',true);         
            if(limitOfUsers != null){
                List<user> userList = [SELECT Id,OrganizationAccountName__c,IsActive FROM User WHERE OrganizationAccountName__c = :userReg.OrganizationName__c AND IsActive = :true];               
                if(userList != null){
                    if(userList.size()>=limitOfUsers){
                        doNotAllowToRegister =true;
                        confirmationPanel = false;
                        showOrgCreatePanel = false;
                        existingOrgSelected = true; 
                        showContactInfoPanel = false;    
                        // ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'User Limit Exceeded');
                        ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.ERROR,GNT.ErrorMessageHelper.fetchMessage('P02-GRNTR-85893'));
                        ApexPages.addMessage(errorMsg);                                     
                        return;
                    }
                }
            }
        }
        userReg.NewOrganization__c = false;
        showContactInfoPanel = true;
        confirmationPanel = false;
        showOrgCreatePanel = false;
        existingOrgSelected = true;
    }

    //Called when 'Create New Organization' button is clicked
    public void showOrgCreateInfoResetEIN(){
        userReg.EINText__c = null;
        userReg.NewOrganization__c = true;
        EINNumber = '';
        startPanel = false;
        showOrgCreatePanel = true;
        showContactInfoPanel = false;
        confirmationPanel = false;
        OrgNotExistPanel = false;
    }
    
    public void backFromConfirmOrganization(){
        confirmationPanel = false; 
        loginValidationtype = getLoginValidationtype();
        startPanel = true;    
    }
    
    public void backFromCreateOrganization(){
        showOrgCreatePanel = false;
        //showContactInfoPanel = false;
        if(noOrgExist){
            startPanel = true;
        }else{
            confirmationPanel = true;
        }
    }
    
    public void backFromCreateUser(){
        showContactInfoPanel = false;
        if(existingOrgSelected){
            confirmationPanel = true;
        }else{
            showOrgCreatePanel = true;
        }
    }   
    
    public void showCaptchaInfo(){
        // Commenting the code as we are moving the Business Rule Config from Custom Setting to Custom Object
        /*BusinessRuleResult result = GNT.BusinessRuleConfigHelper.execute('ValidateCommunityRegUserData', userReg);
        if (result != null && result.hasErrors()) {
            result.addErrorsToPage();
            return;
        }*/


        showContactInfoPanel = true;
        showCaptcha = true;
    }

    private void setDefaultValues() {
        if (String.isEmpty(userReg.City__c)) {
            userReg.City__c = 'NA';
        }
        if (String.isEmpty(userReg.Country__c)) {
            userReg.Country__c = 'NA';
        }
        if (String.isEmpty(userReg.Street__c)) {
            userReg.Street__c = 'NA';
        }
        if (String.isEmpty(userReg.State__c)) {
            userReg.State__c = 'NA';
        }
        if (String.isEmpty(userReg.ZipCode__c)) {
            userReg.ZipCode__c = 'NA';
        }
        if (String.isEmpty(userReg.PhysicalCity__c)) {
            userReg.PhysicalCity__c = 'NA';
        }
        if (String.isEmpty(userReg.PhysicalCountry__c)) {
            userReg.PhysicalCountry__c = 'NA';
        }
        if (String.isEmpty(userReg.PhysicalStreet__c)) {
            userReg.PhysicalStreet__c = 'NA';
        }
        if (String.isEmpty(userReg.PhysicalState__c)) {
            userReg.PhysicalState__c = 'NA';
        }
        if (String.isEmpty(userReg.PhysicalZipCode__c)) {
            userReg.PhysicalZipCode__c = 'NA';
        }

        if (String.isEmpty(userReg.PhoneNumber__c)) {
            userReg.PhoneNumber__c = 'NA';
        }
        if (String.isEmpty(userReg.Fax__c)) {
            userReg.Fax__c = 'NA';
        }
        if (String.isEmpty(userReg.OrganizationCityAddress__c)) {
            userReg.OrganizationCityAddress__c = 'NA';
        }
        if (String.isEmpty(userReg.OrganizationState__c)) {
            userReg.OrganizationState__c = 'NA';
        }
       // userReg.Name = userReg.FirstName__c + ' ' + userReg.LastName__c;
    }
    private void checkCaptcha(){
    
        // On first page load, form is empty, so no request to make yet
        if ( challenge == null || response == null ) { 
            this.isCaptchaVerified = false;
        }
                    
        HttpResponse r = makeRequest(baseUrl,
            'privatekey=' + privateKey + 
            '&remoteip='  + remoteHost + 
            '&challenge=' + challenge +
            '&response='  + response
        );
        
        if ( r!= null ) {
            this.isCaptchaVerified = (r.getBody().startsWithIgnoreCase('true'));
        }
    }
     private static HttpResponse makeRequest(string url, string body)  {
        HttpResponse response = null;
        HttpRequest req = new HttpRequest();   
        req.setEndpoint(url);
        req.setMethod('POST');
        req.setBody (body);
        try {
            Http http = new Http();
            response = http.send(req);
        } 
        catch(System.Exception e) {
            System.debug('ERROR: ' + e);
        }
        return response;
    }   
        
    private String remoteHost { 
        get { 
            String ret = '127.0.0.1';
            // also could use x-original-remote-host 
            Map<String, String> hdrs = ApexPages.currentPage().getHeaders();
            if (hdrs.get('x-original-remote-addr')!= null)
                ret =  hdrs.get('x-original-remote-addr');
            else if (hdrs.get('X-Salesforce-SIP')!= null)
                ret =  hdrs.get('X-Salesforce-SIP');
            return ret;
        }
    }

    private void fetchKeyValueStore() {
        registrationSuccessMsg = Label.UserRegistrationSuccessMsg;
        createOrgAddInfoBlockHeader = Label.CreateOrgAddInfoBlockHeader;
        createOrgBasicInfoBlockHeader = Label.CreateOrgBasicInfoBlockHeader;
        createOrgOuterBlockHeader = Label.CreateOrgOuterBlockHeader;
        createUserAddInfoBlockHeader = Label.CreateUserAddInfoBlockHeader;
        createUserBasicInfoBlockHeader = Label.CreateUserBasicInfoBlockHeader;
        createUserOuterBlockHeader = Label.CreateUserOuterBlockHeader;
        newUserCountryBlockHeader = Label.NewUserCountryBlockHeader;
        newUserEINBlockHeader = Label.NewUserEINBlockHeader;
        newUserDUNSBlockHeader = Label.NewUserDUNSBlockHeader;
        orgSelectionConfirmMsg = Label.OrgSelectionConfirmMsg;
        showCreateUserAddInfoBlock = GNT.KeyValueStoreHelper.getBooleanValue('ShowCreateUserAddInfoBlock', true);
        countryLabel = Label.CountryLabel;
    }

    /*
        This method takes to landingpage
    */
    public PageReference cancelPage() {
        PageReference pg = Page.CommunitiesLanding;
        return pg;
    }
    
    public void copyAddress(){
        userReg.PhysicalStreet__c = userReg.Street__c;
        userReg.PhysicalCity__c = userReg.City__c;
        userReg.PhysicalState__c = userReg.State__c;
        userReg.PhysicalCountry__c = userReg.Country__c;
        userReg.PhysicalZipCode__c = userReg.ZipCode__c;
    }
 
    public void showSearchOrgnizations(){
            startPanel = true;
            OrgInProgressAfterSearchResult = false; 
            resetSearchCriteria();          
    }
    
    public void resetSearchCriteria(){
        for(CommunityRegistrationConfigDetailWrapper a : communityRegistrationConfigDetailWrapperList){
            a.value = null;
        }
    }
        
     public PageReference fetchOrgnizations(){         
        try{
            Id recordId = apexpages.currentpage().getparameters().get('id');
          
            String dynamicQueryFilter = '';
            String accdynamicQueryFilter = '';
            String fldString = '';
            String namespace = AppUtils.getNameSpacePrefix();
            String orgResulFldSetName = namespace + 'Org_Search_Result';
            Boolean argNull = true;
            List<UserRegistration__c> userRegistrationList;
            List<Account> accRegistrationList;
            confirmationPanel = false;
            OrgNotExistPanel = false;
            OrgInProgressAfterSearchResult = false;
            List<Schema.FieldSetMember> fieldsetMembers = Schema.SObjectType.UserRegistration__c.fieldSets.getMap().get(orgResulFldSetName).getFields();
            // code block to form fields list from the field set
            for(Schema.FieldSetMember fldMember : fieldsetMembers){
                String tempFld = fldMember.getfieldPath() + ',';    //removeStartIgnoreCase
                tempFld = tempFld.removeStartIgnoreCase(namespace).trim();
                fldString += tempFld;
            }
            List<String> fldList = fldString.split(',');
            Set<String> fldSet = new Set<String>();
            fldSet.addAll(fldList);
            
            fldString = '';
            // comma separated list of field
            for(String fld : fldSet){
                fldString += fld + ',';
            }
            fldString = fldString.removeEnd(',');
            
            /*swati - removed name field*/
            String query='SELECT ID,Status__c,UserRole__c, '+fldString +' FROM UserRegistration__c '; /*Name,*/
            String accquery='SELECT ID,Name FROM Account';
           
            for( CommunityRegistrationConfigDetailWrapper wrapper : CommunityRegistrationConfigDetailWrapperList){
                if(wrapper.inputField.equalsIgnoreCase('Country')){
                    if(countrySelected != null && countrySelected.length() > 0){
                        wrapper.value = countrySelected;    
                        
                    }                                    
                }     
                                                  
                if(wrapper.isVisible){                                                  
                    if(wrapper.value != null && wrapper.value != '' ){
                        argNull = false;
                        if(wrapper.inputField.equalsIgnoreCase('EIN')){                              
                            dynamicQueryFilter = dynamicQueryFilter + 'EINText__c = \''+ wrapper.value + '\' AND ';  
                            accdynamicQueryFilter = accdynamicQueryFilter + 'EINText__c = \''+ wrapper.value + '\' AND ';                         
                        }else if(wrapper.inputField.equalsIgnoreCase('DUNS')){
                            dynamicQueryFilter = dynamicQueryFilter  + 'DUNS__c LIKE \'%'+ String.valueof(wrapper.value) +'%\'' + ' AND ';
                            accdynamicQueryFilter = accdynamicQueryFilter  + 'DUNS__c LIKE \'%'+ String.valueof(wrapper.value) +'%\'' + ' AND ';
                        }else if(wrapper.inputField.equalsIgnoreCase('Organization Name')){
                            dynamicQueryFilter = dynamicQueryFilter + 'OrganizationName__c LIKE \'%'+ String.valueof(wrapper.value).replace('\'', '\\\'') +'%\'' + ' AND ';
                            accdynamicQueryFilter = accdynamicQueryFilter + 'Name LIKE \'%'+ String.valueof(wrapper.value).replace('\'', '\\\'') +'%\'' + ' AND ';
                        }else if(wrapper.inputField.equalsIgnoreCase('Country')){
                                dynamicQueryFilter = dynamicQueryFilter + 'OrganizationCountry__c = \''+ countrySelected +'\'' + ' AND ';
                        }                        
                    }
                }                   
            }
            
            dynamicQueryFilter = dynamicQueryFilter.removeEndIgnoreCase('AND ');  
            accdynamicQueryFilter = accdynamicQueryFilter.removeEndIgnoreCase('AND ');   
            //query = query +  dynamicQueryFilter;
           
            if(argNull == false){               
               // query = query + ' WHERE Status__c IN (\'In Progress\',\'Submitted for Approval\') AND  ';
                query = query + ' WHERE Status__c IN (\'Verified\',\'Submitted for Approval\',\'Approved\') AND  '; 
                query = query +  dynamicQueryFilter;
                userRegistrationList = Database.query(query);
                accquery = accquery + ' WHERE ';
                accquery = accquery +  accdynamicQueryFilter; 
                 System.debug('accquery<<<<<' + accquery);
                accRegistrationList = Database.query(accquery);
               
            }
            query = query + ' ORDER BY Status__c ASC LIMIT 1';
            userRegistrationList = Database.query(query);
            accquery = accquery + ' ORDER BY Name ASC LIMIT 1';
            accRegistrationList = Database.query(accquery);
            orgResultWrapper = new List<OrganizationResultWrapper> ();
            System.debug('I am here' + accRegistrationList);
            List<Contact> contactList;
            if((userRegistrationList!=null && userRegistrationList.size() > 0)||(accRegistrationList!=null && accRegistrationList.size() > 0)){
                if(accRegistrationList!=null && accRegistrationList.size() > 0){
                      contactList = [SELECT id , firstname , lastname , accountID FROM contact WHERE KeyContact__c = true AND accountID =:accRegistrationList[0].ID LIMIT 1 ];
                      keyPOCfName = contactList[0].firstname;
                      keyPOClName =  contactList[0].lastname;
                    
                }

             
               testRendered = true;
              
               return null;
          
            }else{
               // OrgNotExistPanel = true;
               // confirmationPanel = false;
                //CreateOrganization();
                UserRegistration__c objUserReg = [SELECT Id,EINText__c,StateDropdownList__c,OrganizationCityAddress__c,OrganizationZipCode__c,DUNS__c,OrganizationName__c,name FROM UserRegistration__c WHERE id =: recordId];
                List<USDemographicInfo__c> usDemos=[SELECT PrimaryCity__c,StateCode__c,Name FROM USDemographicInfo__c];
             
                 PageReference pg = Page.ApplicantRegistrationEdit;
                pg.getParameters().put('id', recordId );
               // pg.getParameters().put('tempLayout','1');
                for(CommunityRegistrationConfigDetailWrapper a : CommunityRegistrationConfigDetailWrapperList){
                if(!String.isEmpty(a.inputFieldAPIName) && a.value != null){
                    if(a.inputField == 'EIN'){
                      //pg.getParameters().put('EIN',String.valueOf(a.value));
                      objUserReg.EINText__c = String.valueOf(a.value);
                      
                       
                    }else if(a.inputField == 'DUNS'){
                        // pg.getParameters().put('DUNS',String.valueOf(a.value));
                         objUserReg.DUNS__c = String.valueOf(a.value);
                    } 
                    else if(a.inputField == 'Organization Name'){
                        // pg.getParameters().put('OrganizationName',String.valueOf(a.value));
                         objUserReg.OrganizationName__c = String.valueOf(a.value);
                      
                    }
                    else if(a.inputField =='ZipCode'){
                        String zipCode=String.valueOf(a.value);
                        objUserReg.OrganizationZipCode__c = zipCode;
                        //List<USDemographicInfo__c> usDemos=[SELECT PrimaryCity__c,StateCode__c,Name FROM USDemographicInfo__c where name=:zipCode];
                        /*objUserReg.StateDropdownList__c=usDemos[0].StateCode__c;
                        objUserReg.OrganizationCityAddress__c=usDemos[0].PrimaryCity__c;*/
                        for(USDemographicInfo__c usDemo:usDemos){
                            if(usDemo.Name==zipCode){
                                objUserReg.StateDropdownList__c=usDemo.StateCode__c;
                                objUserReg.OrganizationCityAddress__c=usDemo.PrimaryCity__c; 
                            }
                        } 
                    }                
                } 
                update objUserReg;      
            } 
       
      pg.setRedirect(true);
       return pg ;
            }            
        }
        catch(exception e){
              ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage());
              ApexPages.addMessage(errorMsg);
              pagereference pg = apexpages.Currentpage();
              return pg;
        }                      
     }
     /////added for ind applicant//////////////
     public PageReference fetchOrgnizationsInd(){         
        try{
           Id recordId = apexpages.currentpage().getparameters().get('id');
            System.debug('recordId <<<<<' + recordId );
            String dynamicQueryFilter = '';
            String accdynamicQueryFilter = '';
            String fldString = '';
            String namespace = AppUtils.getNameSpacePrefix();
            String orgResulFldSetName = namespace + 'Org_Search_Result';
            Boolean argNull = true;
            List<UserRegistration__c> userRegistrationList;
            List<Contact> accRegistrationList;
            confirmationPanel = false;
            OrgNotExistPanel = false;
            OrgInProgressAfterSearchResult = false;
            List<Schema.FieldSetMember> fieldsetMembers = Schema.SObjectType.UserRegistration__c.fieldSets.getMap().get(orgResulFldSetName).getFields();
            // code block to form fields list from the field set
            for(Schema.FieldSetMember fldMember : fieldsetMembers){
                String tempFld = fldMember.getfieldPath() + ',';    //removeStartIgnoreCase
                tempFld = tempFld.removeStartIgnoreCase(namespace).trim();
                fldString += tempFld;
            }
            List<String> fldList = fldString.split(',');
            Set<String> fldSet = new Set<String>();
            fldSet.addAll(fldList);
            
            fldString = '';
            // comma separated list of field
            for(String fld : fldSet){
                fldString += fld + ',';
            }
            fldString = fldString.removeEnd(',');
            
            /*swati - removed name field*/
            String query='SELECT ID,Status__c,UserRole__c, '+fldString +' FROM UserRegistration__c '; /*Name,*/
            String accquery='SELECT ID,Name FROM Contact';
           
            for( CommunityRegistrationConfigDetailWrapper wrapper : CommunityRegistrationConfigDetailWrapperList){
                if(wrapper.inputField.equalsIgnoreCase('Country')){
                    if(countrySelected != null && countrySelected.length() > 0){
                        wrapper.value = countrySelected;    
                        
                    }                                    
                }     
                                                  
                if(wrapper.isVisible){                                                  
                    if(wrapper.value != null && wrapper.value != '' ){
                        argNull = false;
                        if(wrapper.inputField.equalsIgnoreCase('Unique ID')){                              
                            // dynamicQueryFilter = dynamicQueryFilter + 'UniqueID__c = \''+ wrapper.value + '\' AND ';  
                            accdynamicQueryFilter = accdynamicQueryFilter + 'UniqueID__c = \''+ wrapper.value + '\' AND ';                         
                        }else if(wrapper.inputField.equalsIgnoreCase('Unique ID Type')){
                            dynamicQueryFilter = dynamicQueryFilter  + 'DUNS__c LIKE \'%'+ String.valueof(wrapper.value) +'%\'' + ' AND ';
                            accdynamicQueryFilter = accdynamicQueryFilter  + 'UniqueIdType__c LIKE \'%'+ String.valueof(wrapper.value) +'%\'' + ' AND ';
                        }else if(wrapper.inputField.equalsIgnoreCase('Organization Name')){
                            dynamicQueryFilter = dynamicQueryFilter + 'OrganizationName__c LIKE \'%'+ String.valueof(wrapper.value) +'%\'' + ' AND ';
                        }/*else if(wrapper.inputField.equalsIgnoreCase('Zip Code')){
                                dynamicQueryFilter = dynamicQueryFilter + 'OrganizationZipCode2__c LIKE = \'%'+String.valueof(wrapper.value) +'%\'' + ' AND ';
                        }*/else if(wrapper.inputField.equalsIgnoreCase('Country')){
                                dynamicQueryFilter = dynamicQueryFilter + 'OrganizationCountry__c = \''+ countrySelected +'\'' + ' AND ';
                        }                        
                    }
                }                   
            }
            
            dynamicQueryFilter = dynamicQueryFilter.removeEndIgnoreCase('AND ');  
            accdynamicQueryFilter = accdynamicQueryFilter.removeEndIgnoreCase('AND ');
            System.debug('I am here' + accdynamicQueryFilter );   
            //query = query +  dynamicQueryFilter;
           
            if(argNull == false){               
               // query = query + ' WHERE Status__c IN (\'In Progress\',\'Submitted for Approval\') AND  ';
                query = query + ' WHERE Status__c IN (\'Verified\',\'Submitted for Approval\',\'Approved\') AND  '; 
                query = query +  dynamicQueryFilter;
                userRegistrationList = Database.query(query);
                accquery = accquery + ' WHERE ';
                accquery = accquery +  accdynamicQueryFilter; 
                 System.debug('accquery<<<<<' + accquery);
                accRegistrationList = Database.query(accquery);
               
            }
            query = query + ' ORDER BY Status__c ASC LIMIT 1';
            userRegistrationList = Database.query(query);
            accquery = accquery + ' ORDER BY Name ASC LIMIT 1';
            accRegistrationList = Database.query(accquery);
            orgResultWrapper = new List<OrganizationResultWrapper> ();
            System.debug('I am here' + accRegistrationList);
            if((userRegistrationList!=null && userRegistrationList.size() > 0)||(accRegistrationList!=null && accRegistrationList.size() > 0)){
               testRendered = true;
               return null;
               
            }else{
               // OrgNotExistPanel = true;
               // confirmationPanel = false;
                //CreateOrganization();
                UserRegistration__c objUserReg = [SELECT Id,EINText__c,DUNS__c,OrganizationName__c,name,UniqueID__c,UniqueIdType__c  FROM UserRegistration__c WHERE id =: recordId];
                 PageReference pg = Page.ExtRegIndApplicantProfile;
                 pg.getParameters().put('id', recordId );
                for(CommunityRegistrationConfigDetailWrapper a : CommunityRegistrationConfigDetailWrapperList){
                if(!String.isEmpty(a.inputFieldAPIName) && a.value != null){
                    if(a.inputField == 'EIN'){
                      pg.getParameters().put('EIN',String.valueOf(a.value));
                      
                       
                    }else if(a.inputField == 'DUNS'){
                         pg.getParameters().put('DUNS',String.valueOf(a.value));
                      
                    } 
                    else if(a.inputField == 'Organization Name'){
                         pg.getParameters().put('OrganizationName',String.valueOf(a.value));
                      
                    }  else if(a.inputField == 'Unique ID'){
                        pg.getParameters().put('UniqueID',String.valueOf(a.value));
                        objUserReg.UniqueID__c = String.valueOf(a.value);
                    } else if(a.inputField == 'Unique ID Type'){
                        pg.getParameters().put('UniqueType',String.valueOf(a.value));
                        objUserReg.UniqueIdType__c = String.valueOf(a.value);
                    }
                               
                }  
               update objUserReg;          
            } 
       
      pg.setRedirect(true);
       return pg ;
            }            
        }
        catch(exception e){
              ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage());
              ApexPages.addMessage(errorMsg);
              pagereference pg = apexpages.Currentpage();
              return pg;
        }                      
     }
     
     ///////////////////// 
     
    /* private void copyFromAccount(UserRegistration__c searchedUserReg){

        List<Account> existingAccount = [SELECT Id,Name FROM Account WHERE EINText__c = :searchedUserReg.EINText__c AND DUNS__c = :searchedUserReg.DUNS__c LIMIT 1];
        if(existingAccount.size() > 0){
            GNT.AppUtils.copyRecord('Account',AppUtils.getNameSpacePrefix()+'UserRegistration__c',existingAccount[0].Id,userReg);
        }    
     } 
     
     public void setUserRegRecordFromCommunityRegConfig(){
        CommunityRegistrationConfig__c communityRegistrationConfig = [SELECT Id,Name,UserRegistration__r.EINText__c,UserRegistration__r.DUNS__c FROM CommunityRegistrationConfig__c WHERE UserType__c = 'Reviewer' LIMIT 1 ];
        Account externalReviewerAccount;
        if(communityRegistrationConfig != null){
            externalReviewerAccount = [SELECT Id,Name,EINText__c,DUNS__c FROM Account WHERE 
                                            EINText__c = :communityRegistrationConfig.UserRegistration__r.EINText__c AND DUNS__c = :communityRegistrationConfig.UserRegistration__r.DUNS__c];
        }
        if(externalReviewerAccount != null){
            GNT.AppUtils.copyRecord('Account',AppUtils.getNameSpacePrefix()+'UserRegistration__c',externalReviewerAccount.Id,userReg);
        } 
     }
     
    // Added for new User Registration process for Reviewers
    public void setUserRegRecordFromExistingContact(String token){
        if(token != null && token != '' && reviewerContact != null){
            GNT.AppUtils.copyRecord('Contact', AppUtils.getNameSpacePrefix()+'UserRegistration__c', reviewerContact.Id, userReg);
        } 
    } */
     
    public void fetchCommunityRegistrationConfigRecords(string recordTypeName){
        communityRegistrationConfig = [SELECT Id,Name,HeaderText__c FROM CommunityRegistrationConfig__c WHERE UserType__c =:recordTypeName LIMIT 1 ];
        if(communityRegistrationConfig !=null ){
            CommunityRegistrationHeaderText = communityRegistrationConfig.HeaderText__c;
        }                        
        List<CommunityRegistrationConfigDetail__c> communityRegistrationConfigList = [SELECT Id,Name,IsVisible__c,IsRequired__c,ErrorMessage__c,
                                                                                    HelpText__c,HelpTextPost__c,InputField__c,InputFieldAPIName__c,UserType__c,Sequence__c,FieldLabelOverride__c 
                                                                                    FROM CommunityRegistrationConfigDetail__c WHERE CommunityRegistrationConfig__c = :communityRegistrationConfig.Id];                
        CommunityRegistrationConfigDetailWrapperList = new List<CommunityRegistrationConfigDetailWrapper>();
        if(communityRegistrationConfigList != null){
            for(CommunityRegistrationConfigDetail__c communityRegistrationConfigDetail : communityRegistrationConfigList){          
                CommunityRegistrationConfigDetailWrapper communityRegistrationWrapper =new CommunityRegistrationConfigDetailWrapper(communityRegistrationConfigDetail);                     
                CommunityRegistrationConfigDetailWrapperList.add(communityRegistrationWrapper);
            }
        }
                        
        CommunityRegistrationConfigDetailWrapperList.sort();        
    }

    /*public class UsernameAvailabilityWrapper {
        public String msg {get; set;}
        public Boolean error {get; set;}
        public Boolean available {get; set;}

        public UsernameAvailabilityWrapper() {
            this.error = false;
            this.available = false;
        }
    } */
    
    public class CommunityRegistrationConfigDetailWrapper implements Comparable {
        public CommunityRegistrationConfigDetail__c communityRegistrationConfigDetail {get;set;}
        public String inputField {get;set;}       
        public Object value {get;set;}
        public Boolean isVisible{get;set;}
        public Boolean isRequired{get;set;}
        public String fieldLabelOverride{get;set;}
        public String helpText{get;set;}
        public String helpTextPost{get;set;}        
        public Integer sequence; 
        public String errorMessage{get;set;} 
        public String inputFieldAPIName{get;set;}  
        public String  inputFieldType{get;set;}    

        public CommunityRegistrationConfigDetailWrapper(CommunityRegistrationConfigDetail__c communityRegistrationConfigDetail){
            this.communityRegistrationConfigDetail = communityRegistrationConfigDetail;
            this.inputField = communityRegistrationConfigDetail.InputField__c;   
            this.sequence =  Integer.valueof(communityRegistrationConfigDetail.Sequence__c);
            this.isVisible = communityRegistrationConfigDetail.IsVisible__c;
            this.isRequired = communityRegistrationConfigDetail.IsRequired__c;
            this.fieldLabelOverride = communityRegistrationConfigDetail.FieldLabelOverride__c;
            this.helpText = communityRegistrationConfigDetail.HelpText__c;
            this.helpTextPost = communityRegistrationConfigDetail.HelpTextPost__c;
            this.errorMessage = communityRegistrationConfigDetail.ErrorMessage__c; 
            this.inputFieldAPIName = communityRegistrationConfigDetail.inputFieldAPIName__c;            
        }
        

        public Integer compareTo(Object objToCompare){
            Boolean sequence = ((CommunityRegistrationConfigDetailWrapper)objToCompare).communityRegistrationConfigDetail.Sequence__c > communityRegistrationConfigDetail.Sequence__c;
            if(sequence){
                return -1;
            }
            return 1;            
        }
    }
    
}