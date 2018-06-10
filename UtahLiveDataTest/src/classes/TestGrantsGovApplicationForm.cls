/**
* @author: Sarat Mahavratayajula - 2016-08-02
*/
@isTest
private class TestGrantsGovApplicationForm {
/*    public static void setup(){
        // Skip unwanted triggers
        AnnouncementTriggerHelper.skipTrigger = true;
        ApplicationtriggerHelper.skiptrigger = true;
    }
    
    
    @isTest static void test1() {
        setup();
        Announcement__c ann = TestHelper.getAnnouncement(true);
        Application__c application = TestHelper.getApplication(ann.Id, true);
        Form__c form1 = new Form__c();
        form1.Title__c = 'Test title';
        form1.ApplicantsOrganization__c = 'Some test organization';
        form1.Date__c = system.today() + 100;
        form1.Application__c = application.Id;      
        insert form1;

        String formName = 'TestForm1';
        String xmlDoc = '<?xml version="1.0"?><ResultSet xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="urn:yahoo:maps" xsi:schemaLocation="urn:yahoo:maps http://api.local.yahoo.com/MapsService/V1/GeocodeResponse.xsd"><Result precision="address"><Latitude>37.416397</Latitude><Longitude>-122.025055</Longitude><Address>701 1st Ave</Address><City>Sunnyvale</City><State>CA</State><Zip>94089-1019</Zip><Country>US</Country></Result></ResultSet>';
        
        Dom.Document doc = new Dom.Document();
        doc.load(xmlDoc);
        Dom.XMLNode root = doc.getRootElement();

        IntegrationFormConfig__c integrationFormConfig = new IntegrationFormConfig__c();
        integrationFormConfig.Name = formName;
        integrationFormConfig.IsActive__c = true;
        /*integrationFormConfig.FormConfig__c   = '{ "name": "GG_V1_1_Assurances_for_Non-Construction_Programs(SF-424B)", ' +
                                                '"structure": ' + 
                                                '{ "objectName": "Form__c",' +  
                                                '"namespaces":[ ' + 
                                                '{"name" : "SF424B", "value":"http://apply.grants.gov/forms/SF424B-V1.1"},' +
                                                '{"name" : "glob", "value":"http://apply.grants.gov/system/Global-V1.0"} ],' +
                                                '"root":' +
                                                '{ "name":"Assurances", "namespacePrefix":"SF424B", "regNamespaces":["SF424B", "glob"],' +
                                                '"attributes": ['+
                                                '{ "name": "coreSchemaVersion", "value": "1.1", "type":"fixed", "namespacePrefix":"glob" },'+ 
                                                '{ "name": "programType", "value": "Non-Construction", "type":"fixed",' +
                                                '"namespacePrefix":"SF424B" } ] }, "children": ['+
                                                '{ "name": "FormVersionIdentifier", "namespacePrefix":"glob",' +
                                                '"dataconfig": { "dataType": "fixed", "value": "4040-0007"} },' +
                                                '{ "name": "AuthorizedRepresentative", "namespacePrefix":"SF424B", "children": [' +
                                                '{ "name": "RepresentativeName", "namespacePrefix":"SF424B",' +
                                                '"dataconfig": { "field": "Signature__c"} },' +
                                                '{ "name": "RepresentativeTitle", "namespacePrefix":"SF424B",' +
                                                '"dataconfig": { "field": "Title__c"} } ] },' +
                                                '{ "name": "ApplicantOrganizationName", "namespacePrefix":"SF424B",' +
                                                '"dataconfig": { "field": "ApplicantsOrganization__c"} },'+
                                                '{ "name": "SubmittedDate", "namespacePrefix":"SF424B",' +
                                                '"dataconfig": { "field": "Date__c", "dataType": "date"} } ] } }';*/
    
        
     /**   insert integrationFormConfig;

        List<GrantsGovApplicationForm.FormNameSpace> formNameSpaces = new List<GrantsGovApplicationForm.FormNameSpace>();

        GrantsGovApplicationForm.FormNameSpace formNameSpace1 = new GrantsGovApplicationForm.FormNameSpace();
        formNameSpace1.name = 'Some name';
        formNameSpace1.value = 'Some Value';

        GrantsGovApplicationForm.FormNameSpace formNameSpace2 = new GrantsGovApplicationForm.FormNameSpace();
        formNameSpace2.name = 'Some name';
        formNameSpace2.value = 'Some Value';

        formNameSpaces.add(formNameSpace1);
        formNameSpaces.add(formNameSpace2);

        List<GrantsGovApplicationForm.FormField> formFields = new List<GrantsGovApplicationForm.FormField>();

        GrantsGovApplicationForm.FormField formFld1 = new GrantsGovApplicationForm.FormField();
        formFld1.Name = 'Some Name';
        formFld1.namespacePrefix = 'Some namespacePrefix';

        GrantsGovApplicationForm.FormField formFld2 = new GrantsGovApplicationForm.FormField();
        formFld2.Name = 'Some Name';
        formFld2.namespacePrefix = 'Some namespacePrefix';

        formFields.add(formFld1);
        formFields.add(formFld2);

        GrantsGovApplicationForm.FormRoot formRoot = new GrantsGovApplicationForm.FormRoot();
        formRoot.name = 'Some Name';
        formRoot.namespacePrefix = 'Some Name Prefix';

        GrantsGovApplicationForm.Structure strut = new GrantsGovApplicationForm.Structure();
        strut.objectName = 'Some Name';
        strut.namespaces = formNameSpaces;
        strut.children = formFields;
        strut.root = formRoot;

        GrantsGovApplicationForm.FormConfig formConfig1 = new GrantsGovApplicationForm.FormConfig();
        formConfig1.Name = 'Some Name';
        formConfig1.structure = strut;
        
        Test.startTest();
            GrantsGovApplicationForm grantsGovApplForm = new GrantsGovApplicationForm(application.Id,form1.Id,formName);
            grantsGovApplForm.formConfig = formConfig1;
            grantsGovApplForm.buildForm(root,doc);
        Test.stopTest();
    }*/
    
    /*@isTest static void test2() {

        // Skip unwanted triggers
        AnnouncementTriggerHelper.skipTrigger = true;
        ApplicationtriggerHelper.skiptrigger = true;

        Announcement__c ann = TestHelper.getAnnouncement(true);
        Application__c application = TestHelper.getApplication(ann.Id, true);

        String formName = 'TestForm1';
        
        Test.startTest();
            GrantsGovApplicationForm grantsGovApplForm = new GrantsGovApplicationForm(application.Id,application.Id,formName);
        Test.stopTest();
    }*/
    
    
}