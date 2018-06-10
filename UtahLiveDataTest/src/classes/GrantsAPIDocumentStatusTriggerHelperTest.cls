/**
* GrantsAPIDocumentStatusTriggerHelperTest is a Test class for the 
* GrantsAPIDocumentStatusTriggerHelperTest class
*
* CHANGE HISTORY
* ==================================================================================================
* Date              Name                Description
* Apr 23 2018       Brian Mason         Created
* ==================================================================================================
*/
@isTest
private class GrantsAPIDocumentStatusTriggerHelperTest {
/*
	@isTest
    private static void duplicateTransmissionDates(){
        Test.startTest();
        // Test 1: Duplicate transmission data in same set of data being inserted
        Boolean exceptionCaught = false;
        try{
            Grants_API_Document_Status__c gads1 = new Grants_API_Document_Status__c( GovGrants_DOC_ID__c = 'a', Document_Transmission_Date__c = datetime.now(),
                                                                                   	 Grants_API_Document_Type__c = 'GAX', Grants_API_Document_Dept_CD__c = '400' );
            Grants_API_Document_Status__c gads2 = new Grants_API_Document_Status__c( GovGrants_DOC_ID__c = 'b', Document_Transmission_Date__c = gads1.Document_Transmission_Date__c,
                                                                                   	 Grants_API_Document_Type__c = 'GAX', Grants_API_Document_Dept_CD__c = '400' );
            insert new List<Grants_API_Document_Status__c>{ gads1, gads2 };
        }catch( DMLException e){
            if( e.getMessage().contains( 'Duplicate Transmission dates are not allowed' ) ){ exceptionCaught = true; }
        }
        system.assertEquals( true, exceptionCaught, 'Test 1: Duplicate Transmission dates not caught' );
        // Test 2: Duplicate transmission data is inserted after existing data is in Object
        exceptionCaught = false;
        try{
            Grants_API_Document_Status__c gads1 = new Grants_API_Document_Status__c( GovGrants_DOC_ID__c = 'a', Document_Transmission_Date__c = datetime.now(),
                                                                                   	 Grants_API_Document_Type__c = 'GAX', Grants_API_Document_Dept_CD__c = '400' );
            insert gads1;
            Grants_API_Document_Status__c gads2 = new Grants_API_Document_Status__c( GovGrants_DOC_ID__c = 'b', Document_Transmission_Date__c = gads1.Document_Transmission_Date__c,
                                                                                   	 Grants_API_Document_Type__c = 'GAX', Grants_API_Document_Dept_CD__c = '400' );
            insert gads2;
        }catch( DMLException e){
            if( e.getMessage().contains( 'Duplicate Transmission dates are not allowed' ) ){ exceptionCaught = true; }
            delete [SELECT ID FROM Grants_API_Document_Status__c];
        }
        system.assertEquals( true, exceptionCaught, 'Test 2: Duplicate Transmission dates not caught' );
        // Test 3: Duplicate transmission data is caused by update to field
        exceptionCaught = false;
        try{
            Grants_API_Document_Status__c gads1 = new Grants_API_Document_Status__c( GovGrants_DOC_ID__c = 'a', Document_Transmission_Date__c = datetime.now(),
                                                                                   	 Grants_API_Document_Type__c = 'GAX', Grants_API_Document_Dept_CD__c = '400' );
            insert gads1;
            Grants_API_Document_Status__c gads2 = new Grants_API_Document_Status__c( GovGrants_DOC_ID__c = 'b', Document_Transmission_Date__c = datetime.now().addDays(1),
                                                                                   	 Grants_API_Document_Type__c = 'GAX', Grants_API_Document_Dept_CD__c = '400' );
            insert gads2;
            gads2.Document_Transmission_Date__c = gads1.Document_Transmission_Date__c;
            update gads2;
        }catch( DMLException e){
            if( e.getMessage().contains( 'Duplicate Transmission dates are not allowed' ) ){ exceptionCaught = true; }
            delete [SELECT ID FROM Grants_API_Document_Status__c];
        }
        system.assertEquals( true, exceptionCaught, 'Test 3: Duplicate Transmission dates not caught' );
        // Test 4: Duplicate transmission data is caused by undelete of record
        exceptionCaught = false;
        try{
            Grants_API_Document_Status__c gads1 = new Grants_API_Document_Status__c( GovGrants_DOC_ID__c = 'a', Document_Transmission_Date__c = datetime.now(),
                                                                                   	 Grants_API_Document_Type__c = 'GAX', Grants_API_Document_Dept_CD__c = '400' );
            insert gads1;
            Grants_API_Document_Status__c gads2 = new Grants_API_Document_Status__c( GovGrants_DOC_ID__c = 'b', Document_Transmission_Date__c = gads1.Document_Transmission_Date__c,
                                                                                   	 Grants_API_Document_Type__c = 'GAX', Grants_API_Document_Dept_CD__c = '400' );
            delete gads1;
            insert gads2;
            undelete gads1;
        }catch( DMLException e){
            if( e.getMessage().contains( 'Duplicate Transmission dates are not allowed' ) ){ exceptionCaught = true; }
        }
        system.assertEquals( true, exceptionCaught, 'Test 4: Duplicate Transmission dates not caught' );
        Test.stopTest();
    }
*/
}