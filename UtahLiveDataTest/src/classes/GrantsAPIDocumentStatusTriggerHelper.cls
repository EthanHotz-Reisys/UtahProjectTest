/**
* GrantsAPIDocumentStatusTriggerHelper is a Trigger helper for the 
* trigger on "Grants API Document Status" object
*
* CHANGE HISTORY
* ==================================================================================================
* Date              Name                Description
* Apr 23 2018       Brian Mason         Created
* May 16 2018		Brian Mason			Disabled triggers as the field being checked is now marked unique, required
* ==================================================================================================
*/
public without sharing class GrantsAPIDocumentStatusTriggerHelper {
	// PUBLIC METHODS
/*
    public static void preventDuplicateTransmittionDates( List<Grants_API_Document_Status__c> newList, Map<ID, Grants_API_Document_Status__c> newMap ) {
        if( newList != null && !newList.isEmpty() ){
            Map<Long, Map<ID, Grants_API_Document_Status__c>> mapTransDTtoRecs = new Map<Long, Map<ID, Grants_API_Document_Status__c>>();
            for( Grants_API_Document_Status__c gads : newList ){
                Long transDateInMS = Long.valueOf( String.valueOf( gads.Document_Transmission_Date_in_MS__c ) );
                if( !mapTransDTtoRecs.containsKey( transDateInMS ) ){
                    mapTransDTtoRecs.put( transDateInMS, new Map<ID, Grants_API_Document_Status__c>() );
                }
                mapTransDTtoRecs.get( transDateInMS ).put( gads.ID, gads );
            }
            for( Grants_API_Document_Status__c gads : [SELECT ID, Document_Transmission_Date_in_MS__c
                                                       	 FROM Grants_API_Document_Status__c
                                                       	WHERE Document_Transmission_Date__c
                                                       	   IN :mapTransDTtoRecs.keySet()] ){
                mapTransDTtoRecs.get( gads.Document_Transmission_Date_in_MS__c ).put( gads.ID, gads );
            }
            for( Long transmissionDate : mapTransDTtoRecs.keySet() ){
                if( mapTransDTtoRecs.get( transmissionDate ).size() > 1 ){
                    for( ID gadsID : mapTransDTtoRecs.get( transmissionDate ).keySet() ){
                        if( newMap.containsKey( gadsID ) ){ newMap.get( gadsID ).addError( 'Duplicate Transmission dates are not allowed' ); }
                    }
                }
            }
        }
    }
*/
}