/**
* IntegUtahGrantsAPITest is a Test class for the 
* IntegUtahGrantsAPI class
*
* CHANGE HISTORY
* ==================================================================================================
* Date              Name                Description
* Apr 24 2018       Brian Mason         Created
* ==================================================================================================
*/
@isTest
private class IntegUtahGrantsAPITest{
	@isTest
    private static void GrantsAPIDocStatusTests(){
        Test.startTest();
        Boolean exceptionCaught = false;
        // Test 1: pass a missing parameter in the constructor
        try{
            IntegUtahGrantsAPI.GrantsAPIDocumentStatus gads = new IntegUtahGrantsAPI.GrantsAPIDocumentStatus( '', 'XXX', '400' );
        }catch( Exception e ){
            exceptionCaught = e.getMessage().contains( 'GovGrants_DOC_ID, Grants_API_Document_Type and Grants_API_Document_Dept_CD are required values' );
        }
        system.assertEquals( true, exceptionCaught, 'Test 1: Missing parameter not caught' );
        exceptionCaught = false;
        // Test 2: pass a missing parameter in the constructor for the set
        try{
            IntegUtahGrantsAPI.GrantsAPIDocumentStatus gads = new IntegUtahGrantsAPI.GrantsAPIDocumentStatus( 'GovGrants_DOC_ID', 'GAX', '400', null );
        }catch( Exception e ){
            exceptionCaught = e.getMessage().contains( 'itemIDs are required values and cannot be null or empty' );
        }
        system.assertEquals( true, exceptionCaught, 'Test 2: Missing parameter not caught' );
        exceptionCaught = false;
        // Test 3: pass a missing parameter in the addItemID function
        try{
            IntegUtahGrantsAPI.GrantsAPIDocumentStatus gads = new IntegUtahGrantsAPI.GrantsAPIDocumentStatus( 'GovGrants_DOC_ID', 'GAX', '400', new Set<ID>() );
            gads.addItemID( null );
        }catch( Exception e ){
            exceptionCaught = e.getMessage().contains( 'itemID is a required value and cannot be null or empty' );
        }
        system.assertEquals( true, exceptionCaught, 'Test 3: Missing parameter not caught' );
        exceptionCaught = false;
        // Test 4: pass a missing parameter in the addItemIDs function
        try{
            IntegUtahGrantsAPI.GrantsAPIDocumentStatus gads = new IntegUtahGrantsAPI.GrantsAPIDocumentStatus( 'GovGrants_DOC_ID', 'GAX', '400' );
            gads.addItemIDs( null );
        }catch( Exception e ){
            exceptionCaught = e.getMessage().contains( 'itemIDs are required values and cannot be null'  );
        }
        system.assertEquals( true, exceptionCaught, 'Test 4: Missing parameter not caught' );
        exceptionCaught = false;
        // Test 5: pass a missing parameter in the removeItemID function and adding/removing from the set, finally attempt to insert
        try{
            IntegUtahGrantsAPI.GrantsAPIDocumentStatus tempGads = new IntegUtahGrantsAPI.GrantsAPIDocumentStatus( 'GovGrants_DOC_ID', 'GAX', '400' );
            tempGads.insertParent( datetime.now(), '{ "message" : "Test JSON" }' );
            delete tempGads.gads;
            IntegUtahGrantsAPI.GrantsAPIDocumentStatus gads = new IntegUtahGrantsAPI.GrantsAPIDocumentStatus( 'GovGrants_DOC_ID', 'GAX', '400' );
            gads.addItemID( tempGads.gads.ID );
            gads.removeItemID( null );
            gads.removeItemID( tempGads.gads.ID );
            gads.addItemIDs( new Set<ID>{ tempGads.gads.ID } );
            gads.removeItemIDs( new Set<ID>{ tempGads.gads.ID } );
            gads.insertParent( DateTime.now(), '' );
        }catch( Exception e ){
            exceptionCaught = e.getMessage().contains( 'Document_Transmission_Date and JSONDoc are required values and cannot be null or empty' );
        }
        system.assertEquals( true, exceptionCaught, 'Test 5: Missing parameter not caught' );
        exceptionCaught = false;
        // Test 6: pass a missing parameter in the removeItemID function and adding/removing from the set, finally attempt to insert
        try{
            IntegUtahGrantsAPI.GrantsAPIDocumentStatus tempGads = new IntegUtahGrantsAPI.GrantsAPIDocumentStatus( 'GovGrants_DOC_ID', 'GAX', '400' );
            tempGads.insertParent( datetime.now(), '{ "message" : "Test JSON" }' );
            delete tempGads.gads;
            IntegUtahGrantsAPI.GrantsAPIDocumentStatus gads = new IntegUtahGrantsAPI.GrantsAPIDocumentStatus( 'GovGrants_DOC_ID', 'GAX', '400' );
            gads.addItemID( tempGads.gads.ID );
            gads.removeItemID( null );
            gads.removeItemID( tempGads.gads.ID );
            gads.addItemIDs( new Set<ID>{ tempGads.gads.ID } );
            gads.removeItemIDs( new Set<ID>{ tempGads.gads.ID } );
            gads.insertRecords( DateTime.now(), '{ "message" : "Test JSON" }' );
        }catch( Exception e ){
            exceptionCaught = e.getMessage().contains( 'itemIDs are required values and cannot be null or empty' );
        }
        system.assertEquals( true, exceptionCaught, 'Test 6: Missing parameter not caught' );
        exceptionCaught = false;
        // Test 7: Pass an Id for an object which does not have the fields needed on it
        try{
            IntegUtahGrantsAPI.GrantsAPIDocumentStatus gads = new IntegUtahGrantsAPI.GrantsAPIDocumentStatus( 'GovGrants_DOC_ID', 'GAX', '400' );
            gads.addItemID( UserInfo.getUserId() );
        }catch( Exception e ){
            exceptionCaught = e.getMessage().contains( 'does not have grants_api_document_phase__c or grants_api_document_status__c as a field' );
        }
        system.assertEquals( true, exceptionCaught, 'Test 7: Missing parameter not caught' );
        exceptionCaught = false;
        // Test 8: Call insert records to get exception
        try{
            IntegUtahGrantsAPI.GrantsAPIDocumentStatus gads = new IntegUtahGrantsAPI.GrantsAPIDocumentStatus( 'GovGrants_DOC_ID', 'GAX', '400' );
            gads.insertRecords(  );
        }catch( Exception e ){
            exceptionCaught = e.getMessage().contains( 'Grants API Document Status record must be inserted first when using this method' );
        }
        system.assertEquals( true, exceptionCaught, 'Test 8: Missing parameter not caught' );
        exceptionCaught = false;
        // Test 9: pass parameters in the removeItemID function and adding to the set finishing with a successful insert
        try{
            IntegUtahGrantsAPI.GrantsAPIDocumentStatus tempGads = new IntegUtahGrantsAPI.GrantsAPIDocumentStatus( 'GovGrants_DOC_ID', 'GAX', '400' );
            tempGads.insertParent( datetime.now(), '{ "message" : "Test JSON" }' );
            delete tempGads.gads;
            IntegUtahGrantsAPI.GrantsAPIDocumentStatus gads = new IntegUtahGrantsAPI.GrantsAPIDocumentStatus( 'GovGrants_DOC_ID', 'GAX', '400' );
            gads.addItemID( tempGads.gads.ID );
            gads.insertRecords( DateTime.now(), '{ "message" : "Test JSON" }' );
        }catch( Exception e ){
            system.debug(e);
            exceptionCaught = true;
        }
        system.assertEquals( false, exceptionCaught, 'Test 9: Insert not successful' );
        system.assertEquals( 1, [SELECT ID FROM Attachment].size(), 'Test 9: Attchment not created' );
        delete [SELECT ID FROM Grants_API_Document_Status__c];
        delete [SELECT ID FROM Grants_API_Document_Status_Detail__c];
        delete [SELECT ID FROM Attachment];
        exceptionCaught = false;
        // Test 10: pass parameters in the removeItemID function and adding to the set finishing with a successful insert
        try{
            IntegUtahGrantsAPI.GrantsAPIDocumentStatus tempGads = new IntegUtahGrantsAPI.GrantsAPIDocumentStatus( 'GovGrants_DOC_ID', 'GAX', '400' );
            tempGads.insertParent( datetime.now(), '{ "message" : "Test JSON" }' );
            delete tempGads.gads;
            IntegUtahGrantsAPI.GrantsAPIDocumentStatus gads = new IntegUtahGrantsAPI.GrantsAPIDocumentStatus( 'GovGrants_DOC_ID', 'GAX', '400' );
            gads.addItemID( tempGads.gads.ID );
            gads.insertParent( DateTime.now(), '{ "message" : "Test JSON" }' );
            gads.insertRecords( );
        }catch( Exception e ){
            system.debug(e);
            exceptionCaught = true;
        }
        system.assertEquals( false, exceptionCaught, 'Test 10: Insert not successful' );
        system.assertEquals( 1, [SELECT ID FROM Attachment].size(), 'Test 10: Attchment not created' );
        Test.stopTest();
    }
}