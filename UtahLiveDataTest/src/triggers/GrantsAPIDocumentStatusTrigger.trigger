/**
* GrantsAPIDocumentStatusTrigger is a Trigger on the "Grants API Document Status" object
*
* CHANGE HISTORY
* ==================================================================================================
* Date              Name                Description
* Apr 23 2018       Brian Mason         Created
* May 16 2018		Brian Mason			Disabled triggers as the field being checked is now marked unique, required
* ==================================================================================================
*/
trigger GrantsAPIDocumentStatusTrigger on Grants_API_Document_Status__c ( before insert, before update, before delete, after insert, after update, after delete, after undelete ) {
/*
	if( Trigger.isBefore ){
        if( Trigger.isInsert ){
            // Call class logic here!
        } 
        if( Trigger.isUpdate ){
            // Call class logic here!
        }
        if( Trigger.isDelete ){ 
            // Call class logic here!
        }
    }
    
    if( Trigger.IsAfter ){
        if( Trigger.isInsert ){
            GrantsAPIDocumentStatusTriggerHelper.preventDuplicateTransmittionDates( Trigger.new, Trigger.newMap );
        }
        if( Trigger.isUpdate ){
            GrantsAPIDocumentStatusTriggerHelper.preventDuplicateTransmittionDates( Trigger.new, Trigger.newMap );
        }
        if( Trigger.isDelete ){
            // Call class logic here!
        }

		if( Trigger.isUndelete ){
            GrantsAPIDocumentStatusTriggerHelper.preventDuplicateTransmittionDates( Trigger.new, Trigger.newMap );
        }
    }
*/
}