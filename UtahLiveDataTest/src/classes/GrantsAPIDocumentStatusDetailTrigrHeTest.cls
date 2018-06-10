/**
* GrantsAPIDocumentStatusDetailTrigrHeTest is a Test class for the 
* GrantsAPIDocumentStatusDetailTrigrHelper class
*
* CHANGE HISTORY
* ==================================================================================================
* Date              Name                Description
* Apr 19 2018       Brian Mason         Created
* ==================================================================================================
*/
@isTest
private class GrantsAPIDocumentStatusDetailTrigrHeTest {
    @IsTest
    private static void ParentWithDuplicateChildren(){
        Test.startTest();
        // Test 1: duplicate data in same set of data being inserted
        Boolean exceptionCaught = false;
        try{
            Grants_API_Document_Status__c gads = new Grants_API_Document_Status__c( GovGrants_DOC_ID__c = 'a', Document_Transmission_Date__c = datetime.now(),
                                                                                   	Grants_API_Document_Type__c = 'GAX', Grants_API_Document_Dept_CD__c = '400',
                                                                                  	Document_Transmission_Date_in_MS__c = datetime.now().getTime() );
            insert gads;
            resetTriggerMembers();
            List<Grants_API_Document_Status_Detail__c> gadsds = 
                new List<Grants_API_Document_Status_Detail__c>{new Grants_API_Document_Status_Detail__c(Grants_API_Document_Status__c = gads.id,
                                                                                                        Grants_API_Document_Item_ID__c = gads.id),
															   new Grants_API_Document_Status_Detail__c(Grants_API_Document_Status__c = gads.id,
                                                                                                        Grants_API_Document_Item_ID__c = gads.id)};
			insert gadsds;
        }catch( Exception e ){
            if( e.getMessage().contains( 'Duplicate ID in document.' ) ){ exceptionCaught = true; }
        }
        system.assertEquals( true, exceptionCaught, 'Test 1: Duplicate ID not caught' );
        // Test 2: Duplicate data is inserted after existing data is in Object
        exceptionCaught = false;
        resetTriggerMembers();
        try{
            Grants_API_Document_Status__c gads = new Grants_API_Document_Status__c( GovGrants_DOC_ID__c = 'b', Document_Transmission_Date__c = datetime.now().addDays(1),
                                                                                   	Grants_API_Document_Type__c = 'GAX', Grants_API_Document_Dept_CD__c = '400',
                                                                                  	Document_Transmission_Date_in_MS__c = datetime.now().getTime() );
            insert gads;
            resetTriggerMembers();
            List<Grants_API_Document_Status_Detail__c> gadsds = 
                new List<Grants_API_Document_Status_Detail__c>{new Grants_API_Document_Status_Detail__c(Grants_API_Document_Status__c = gads.id,
                                                                                                        Grants_API_Document_Item_ID__c = Userinfo.getUserId(),
                                                                                                        Active__c = true ),
															   new Grants_API_Document_Status_Detail__c(Grants_API_Document_Status__c = gads.id,
                                                                                                        Grants_API_Document_Item_ID__c = gads.id,
                                                                                                        Active__c = true)};
			insert gadsds;
            resetTriggerMembers();
            insert new Grants_API_Document_Status_Detail__c(Grants_API_Document_Status__c = gads.id, Grants_API_Document_Item_ID__c = gads.id, Active__c = true);
        }catch( Exception e ){
            if( e.getMessage().contains( 'Duplicate ID in document.' ) ){ exceptionCaught = true; }
        }
        system.assertEquals( true, exceptionCaught, 'Test 2: Duplicate ID not caught' );
        // Test 3: Duplicate data is caused by update to field
        exceptionCaught = false;
        resetTriggerMembers();
        try{
            Grants_API_Document_Status__c gads = new Grants_API_Document_Status__c( GovGrants_DOC_ID__c = 'c', Document_Transmission_Date__c = datetime.now().addDays(2),
                                                                                   	Grants_API_Document_Type__c = 'GAX', Grants_API_Document_Dept_CD__c = '400',
                                                                                  	Document_Transmission_Date_in_MS__c = datetime.now().getTime() );
            insert gads;
            resetTriggerMembers();
            Grants_API_Document_Status_Detail__c gadsd = new Grants_API_Document_Status_Detail__c(Grants_API_Document_Status__c = gads.id, Grants_API_Document_Item_ID__c = gads.id);
            List<Grants_API_Document_Status_Detail__c> gadsds = 
                new List<Grants_API_Document_Status_Detail__c>{
                    new Grants_API_Document_Status_Detail__c(Grants_API_Document_Status__c = gads.id, Grants_API_Document_Item_ID__c = Userinfo.getUserId() ),
                    gadsd
                };
			insert gadsds;
            resetTriggerMembers();
            gadsd.Grants_API_Document_Item_ID__c = Userinfo.getUserId();
            update gadsd;
        }catch( Exception e ){
            if( e.getMessage().contains( 'Duplicate ID in document.' ) ){ exceptionCaught = true; }
        }
        system.assertEquals( true, exceptionCaught, 'Test 3: Duplicate ID not caught' );
        // Test 4: Duplicate data is caused by undelete of record
        exceptionCaught = false;
        resetTriggerMembers();
        try{
            Grants_API_Document_Status__c gads = new Grants_API_Document_Status__c( GovGrants_DOC_ID__c = 'd', Document_Transmission_Date__c = datetime.now().addDays(3),
                                                                                   	Grants_API_Document_Type__c = 'GAX', Grants_API_Document_Dept_CD__c = '400',
                                                                                  	Document_Transmission_Date_in_MS__c = datetime.now().getTime() );
            insert gads;
            resetTriggerMembers();
            Grants_API_Document_Status_Detail__c gadsd1 = new Grants_API_Document_Status_Detail__c(Grants_API_Document_Status__c = gads.id, Grants_API_Document_Item_ID__c = gads.id);
            Grants_API_Document_Status_Detail__c gadsd2 = new Grants_API_Document_Status_Detail__c(Grants_API_Document_Status__c = gads.id, Grants_API_Document_Item_ID__c = gads.id);
			insert gadsd1;
            resetTriggerMembers();
            delete gadsd1;
            resetTriggerMembers();
            insert gadsd2;
            resetTriggerMembers();
            undelete gadsd1;
        }catch( Exception e ){
            if( e.getMessage().contains( 'Duplicate ID in document.' ) ){ exceptionCaught = true; }
        }
        system.assertEquals( true, exceptionCaught, 'Test 4: Duplicate ID not caught' );
        // Test 5: Duplicate data is caused by undelete of record
        exceptionCaught = false;
        resetTriggerMembers();
        try{
            Grants_API_Document_Status__c gads = new Grants_API_Document_Status__c( GovGrants_DOC_ID__c = 'e', Document_Transmission_Date__c = datetime.now().addDays(4),
                                                                                   	Grants_API_Document_Type__c = 'GAX', Grants_API_Document_Dept_CD__c = '400',
                                                                                  	Document_Transmission_Date_in_MS__c = datetime.now().getTime() );
            insert gads;
            Grants_API_Document_Status_Detail__c gadsd1 = new Grants_API_Document_Status_Detail__c(Grants_API_Document_Status__c = gads.id, Grants_API_Document_Item_ID__c = gads.id);
			insert gadsd1;
            resetTriggerMembers();
            Grants_API_Document_Status_Detail__c gadsd2 = new Grants_API_Document_Status_Detail__c(Grants_API_Document_Status__c = gads.id, Grants_API_Document_Item_ID__c = gadsd1.id);
            delete gadsd1;
            resetTriggerMembers();
            insert gadsd2;
            resetTriggerMembers();
            undelete gadsd1;
        }catch( Exception e ){
            if( e.getMessage().contains( 'Duplicate ID in document.' ) ){ exceptionCaught = true; }
        }
        system.assertEquals( false, exceptionCaught, 'Test 5: Duplicate ID caught' );
        Test.stopTest();
    }
	@isTest
    private static void OneParentWithChildren(){
        Test.startTest();
        Grants_API_Document_Status__c gads = new Grants_API_Document_Status__c( GovGrants_DOC_ID__c = 'a', Document_Transmission_Date__c = datetime.now(),
                                                                               	Grants_API_Document_Type__c = 'GAX', Grants_API_Document_Dept_CD__c = '400',
                                                                               	Document_Transmission_Date_in_MS__c = datetime.now().getTime() );
        insert gads;
        List<Grants_API_Document_Status_Detail__c> gadsds = new List<Grants_API_Document_Status_Detail__c>{new Grants_API_Document_Status_Detail__c(Grants_API_Document_Status__c = gads.id, Grants_API_Document_Item_ID__c = Userinfo.getUserId() ),
            																							   new Grants_API_Document_Status_Detail__c(Grants_API_Document_Status__c = gads.id, Grants_API_Document_Item_ID__c = gads.id )};
        insert gadsds;
        Test.stopTest();
    }
    @isTest
    private static void TwoParentsWithChildren(){
        Test.startTest();
        Grants_API_Document_Status__c gads1 = new Grants_API_Document_Status__c( GovGrants_DOC_ID__c = 'a', Document_Transmission_Date__c = datetime.now(),
                                                                                 Grants_API_Document_Type__c = 'GAX', Grants_API_Document_Dept_CD__c = '400',
                                                                                  	Document_Transmission_Date_in_MS__c = datetime.now().getTime() );
        Grants_API_Document_Status__c gads2 = new Grants_API_Document_Status__c( GovGrants_DOC_ID__c = 'b', Document_Transmission_Date__c = datetime.now().addDays(1),
                                                                                 Grants_API_Document_Type__c = 'GAX', Grants_API_Document_Dept_CD__c = '400',
                                                                                  	Document_Transmission_Date_in_MS__c = datetime.now().addDays(1).getTime() );
        insert new List<Grants_API_Document_Status__c>{gads1,gads2};
        List<Grants_API_Document_Status_Detail__c> gadsds = new List<Grants_API_Document_Status_Detail__c>{new Grants_API_Document_Status_Detail__c(Grants_API_Document_Status__c = gads1.id, Grants_API_Document_Item_ID__c = Userinfo.getUserId() ),
            																							   new Grants_API_Document_Status_Detail__c(Grants_API_Document_Status__c = gads1.id, Grants_API_Document_Item_ID__c = gads1.id ),
            																							   new Grants_API_Document_Status_Detail__c(Grants_API_Document_Status__c = gads2.id, Grants_API_Document_Item_ID__c = Userinfo.getUserId() ),
            																							   new Grants_API_Document_Status_Detail__c(Grants_API_Document_Status__c = gads2.id, Grants_API_Document_Item_ID__c = gads2.id )};
        insert gadsds;
        Test.stopTest();
        system.assertEquals(1, [SELECT ID
                                  FROM Grants_API_Document_Status_Detail__c
                                 WHERE Grants_API_Document_Status__c = :gads1.ID
                                   AND Active__c = true].size(), 'Test Failed: Record not marked inactive as expected.');
        system.assertEquals(2, [SELECT ID
                                  FROM Grants_API_Document_Status_Detail__c
                                 WHERE Grants_API_Document_Status__c = :gads2.ID
                                   AND Active__c = true].size(), 'Test Failed: Record not marked active as expected.');
    }
    private static void resetTriggerMembers(){
        GrantsAPIDocumentStatusDetailTrigrHelper.triggerProcessed = null;
        GrantsAPIDocumentStatusDetailTrigrHelper.errorsFound = null;
    }
}