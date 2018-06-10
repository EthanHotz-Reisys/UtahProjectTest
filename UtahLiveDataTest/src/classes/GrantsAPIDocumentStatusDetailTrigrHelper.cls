/**
* GrantsAPIDocumentStatusDetailTrigrHelper is a Trigger helper for the 
* trigger on "Grants API Document Status Detail" object
*
* CHANGE HISTORY
* ==================================================================================================
* Date              Name                Description
* Apr 19 2018       Brian Mason         Created
* ==================================================================================================
*/
public without sharing class GrantsAPIDocumentStatusDetailTrigrHelper{
    // PUBLIC MEMBERS
    @testvisible public static Boolean triggerProcessed {get;private set;}
    @testvisible public static Boolean errorsFound {get;private set;}
    // PUBLIC METHODS
    // Method used to prevent duplicate Grants_API_Document_Item_ID__c values under one parent
    public static Map<ID,List<Grants_API_Document_Status_Detail__c>> preventDuplicateIDWithinParent( List<Grants_API_Document_Status_Detail__c> newList,
                                                                                                     Map<ID, Grants_API_Document_Status_Detail__c> newMap ){
		// First: check the incoming data
		Map<ID,List<Grants_API_Document_Status_Detail__c>> mapIDtoGADSD = checkForDuplicatesInParent( newList, newMap );
        // Second: check if there are any duplicate children already in the database for this parent
		return checkForDuplicatesInParent( [SELECT ID, Grants_API_Document_Item_ID__c,
                                            	   Grants_API_Document_Status__c, Grants_API_Document_Final__c,
                                            	   Document_Transmission_Date_in_MS__c, Active__c
                                              FROM Grants_API_Document_Status_Detail__c
                                             WHERE Grants_API_Document_Item_ID__c in :mapIDtoGADSD.keySet()
                                               AND Grants_API_Document_Final__c = FALSE
                                          ORDER BY Document_Transmission_Date_in_MS__c DESC], newMap );
    }
    // Method used to check for active records in a different document.
	// A record can only be "Active" in one document at a time.
	// The most recent document will always be where the "Active" record is kept.
    public static void checkForActiveRecordInDiffDocument(  Map<ID,List<Grants_API_Document_Status_Detail__c>> mapIDtoGADSD ){	
		// First: Create a map to store records to update	
        Map<ID, Grants_API_Document_Status_Detail__c> recordsToUpdate = new Map<ID, Grants_API_Document_Status_Detail__c>();
        // Second: Extract the records to update from the incoming data
        recordsToUpdate.putAll( findRecordsToUpdate( mapIDtoGADSD ) );
        if( !recordsToUpdate.isEmpty() ){
            update recordsToUpdate.values();
        }
        triggerProcessed = true;
    }
    // PRIVATE METHODS
    private static Map<ID,List<Grants_API_Document_Status_Detail__c>> checkForDuplicatesInParent( List<Grants_API_Document_Status_Detail__c> newList,
                                                                                                  Map<ID, Grants_API_Document_Status_Detail__c> newMap ){
        Map<ID,List<Grants_API_Document_Status_Detail__c>> mapIDtoGADSD = new Map<ID,List<Grants_API_Document_Status_Detail__c>>();
        // Loop over the incoming list
        for( Grants_API_Document_Status_Detail__c gadsd : newList ){
            // Check if the map already contains this ID. 
            if( !mapIDtoGADSD.containsKey( gadsd.Grants_API_Document_Item_ID__c ) ){
                mapIDtoGADSD.put( gadsd.Grants_API_Document_Item_ID__c, new List<Grants_API_Document_Status_Detail__c>() );
            }
            mapIDtoGADSD.get( gadsd.Grants_API_Document_Item_ID__c ).add( gadsd );
            for( Grants_API_Document_Status_Detail__c gadsdFromInternalList : mapIDtoGADSD.get( gadsd.Grants_API_Document_Item_ID__c ) ){
                // If the parent is the same throw an exception that 
                // a parent cannot have two children with the same ID
                if( gadsdFromInternalList.Grants_API_Document_Status__c == gadsd.Grants_API_Document_Status__c &&
                    gadsdFromInternalList.ID != gadsd.ID ){
                       if( newmap.containskey( gadsdFromInternalList.ID ) ){ 
                           newMap.get( gadsdFromInternalList.ID ).addError('Duplicate ID in document.');
                           errorsFound = true;
                       }else if( newmap.containskey( gadsd.ID ) ){ 
                           newMap.get( gadsd.ID ).addError('Duplicate ID in document.'); }
                           errorsFound = true;
                }
            }
        }
        return mapIDtoGADSD;
    }
    private static Map<ID, Grants_API_Document_Status_Detail__c> findRecordsToUpdate( Map<ID,List<Grants_API_Document_Status_Detail__c>> mapIDtoGADSD ){
        // List to store records which need to be updated
        Map<ID, Grants_API_Document_Status_Detail__c> recordsToUpdate = new Map<ID, Grants_API_Document_Status_Detail__c>();
        // Loop over map that was just created
        for( ID itemID : mapIDtoGADSD.keySet() ){
            Integer listSize = mapIDtoGADSD.get( itemID ).size();
            if( listSize <= 1 ){ continue; }
            // Loop over the List within each value of the map
            for( Integer i = 0; i < listSize; i++ ){
                if( listSize == 2 && i == 1 ){ break; }
                Integer nextArrPos = i + 1 == listSize ? 0 : i + 1;
                Grants_API_Document_Status_Detail__c currGADSD = mapIDtoGADSD.get( itemID )[i];
                Grants_API_Document_Status_Detail__c nextGADSD = mapIDtoGADSD.get( itemID )[nextArrPos];
                Grants_API_Document_Status_Detail__c activeGADSD = 
                    mapIDtoGADSD.get( itemID )[currGADSD.Document_Transmission_Date_in_MS__c > nextGADSD.Document_Transmission_Date_in_MS__c ? i : nextArrPos];
                Grants_API_Document_Status_Detail__c inactiveGADSD = 
                    mapIDtoGADSD.get( itemID )[currGADSD.Document_Transmission_Date_in_MS__c > nextGADSD.Document_Transmission_Date_in_MS__c ? nextArrPos : i];
                if( activeGADSD.Active__c != true ){ recordsToUpdate.put( activeGADSD.ID, setRecordToUpdate ( activeGADSD, true ) ); }
                if(	inactiveGADSD.Active__c != false ){ recordsToUpdate.put( inactiveGADSD.ID, setRecordToUpdate ( inactiveGADSD, false ) ); }
            }
        }
        return recordsToUpdate;
    }
    private static Grants_API_Document_Status_Detail__c setRecordToUpdate( Grants_API_Document_Status_Detail__c recToUpdate, Boolean value ){
        recToUpdate.Active__c = value;
        return recToUpdate;
    }
}