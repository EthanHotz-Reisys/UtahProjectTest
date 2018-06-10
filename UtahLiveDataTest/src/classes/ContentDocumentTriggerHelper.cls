/*
    This is a helper class for the ContentDocument Trigger 
    
    *******************************************************************************************************************
    Audit History
    ********************************************************************************************************************
    2015-02-23  William Moore      Created 
    
    **********************************************************************************************************************  
*/ 
public with sharing class ContentDocumentTriggerHelper extends GNT.TriggerHelper{
    
    // This is used to delete the network sharing link that is initially created when a file is posted externally
    // This is done because we are filtering based on accounts instead and a community file would be shared among all organizations
    public override void processAfterInsert() {
        Network n = [SELECT id FROM Network LIMIT 1];
        List<ContentDocumentLink> cdls;
        for(Sobject cd: Trigger.new) {
            cdls = [SELECT id FROM ContentDocumentLink WHERE LinkedEntityId =: n.id AND ContentDocumentId =: cd.id];
            if (cdls.size() > 0) {
                ContentDocumentLink newcdl = new ContentDocumentLink();
                newcdl.LinkedEntityId = ConnectApi.Organization.getSettings().orgId;
                newcdl.ContentDocumentId = cd.id;
                newcdl.ShareType = 'V';
                insert newcdl;
                delete cdls;
            }
        } 
    }
}