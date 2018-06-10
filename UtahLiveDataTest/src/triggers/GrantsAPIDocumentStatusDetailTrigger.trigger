/**
* GrantsAPIDocumentStatusDetailTrigger is a Trigger on the "Grants API Document Status Detail" object
*
* CHANGE HISTORY
* ==================================================================================================
* Date              Name                Description
* Apr 19 2018       Brian Mason         Created
* ==================================================================================================
*/
trigger GrantsAPIDocumentStatusDetailTrigger on Grants_API_Document_Status_Detail__c ( before insert, before update, before delete, after insert, after update, after delete, after undelete ) {
    /*if( Trigger.isBefore ){
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
    */
    if( Trigger.IsAfter ){
        if( Trigger.isInsert ){
            Map<ID,List<Grants_API_Document_Status_Detail__c>> mapItemIDtoGADSD = 
                GrantsAPIDocumentStatusDetailTrigrHelper.preventDuplicateIDWithinParent( Trigger.new, Trigger.newMap );
            if( GrantsAPIDocumentStatusDetailTrigrHelper.triggerProcessed != true && GrantsAPIDocumentStatusDetailTrigrHelper.errorsFound != true ){
                GrantsAPIDocumentStatusDetailTrigrHelper.checkForActiveRecordInDiffDocument( mapItemIDtoGADSD ); }
        } 
        if( Trigger.isUpdate ){
            Map<ID,List<Grants_API_Document_Status_Detail__c>> mapItemIDtoGADSD = 
                GrantsAPIDocumentStatusDetailTrigrHelper.preventDuplicateIDWithinParent( Trigger.new, Trigger.newMap );
            if( GrantsAPIDocumentStatusDetailTrigrHelper.triggerProcessed != true && GrantsAPIDocumentStatusDetailTrigrHelper.errorsFound != true ){
                GrantsAPIDocumentStatusDetailTrigrHelper.checkForActiveRecordInDiffDocument( mapItemIDtoGADSD ); }
        }
        if( Trigger.isDelete ){
            Map<ID,List<Grants_API_Document_Status_Detail__c>> mapItemIDtoGADSD = 
                GrantsAPIDocumentStatusDetailTrigrHelper.preventDuplicateIDWithinParent( Trigger.old, Trigger.oldMap );
            if( GrantsAPIDocumentStatusDetailTrigrHelper.triggerProcessed != true && GrantsAPIDocumentStatusDetailTrigrHelper.errorsFound != true ){
                GrantsAPIDocumentStatusDetailTrigrHelper.checkForActiveRecordInDiffDocument( mapItemIDtoGADSD ); }
        }
		if( Trigger.isUndelete ){
            Map<ID,List<Grants_API_Document_Status_Detail__c>> mapItemIDtoGADSD = 
                GrantsAPIDocumentStatusDetailTrigrHelper.preventDuplicateIDWithinParent( Trigger.new, Trigger.newMap );
            if( GrantsAPIDocumentStatusDetailTrigrHelper.triggerProcessed != true && GrantsAPIDocumentStatusDetailTrigrHelper.errorsFound != true ){
                GrantsAPIDocumentStatusDetailTrigrHelper.checkForActiveRecordInDiffDocument( mapItemIDtoGADSD ); }
        }
    }
}