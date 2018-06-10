public with sharing class LoginHighlightsCtrl {
    public List<GNT__Highlight__c> extendedHighlightsList {get;set;}
    public List<GNT__Highlight__c> minHighlightsList {get;set;}
    public Integer minItemsCount {get;set;}
    public Integer actualItemCount {get;set;}
    
    public LoginHighlightsCtrl(){
        minHighlightsList = new List<GNT__Highlight__c>();
        extendedHighlightsList = new List<GNT__Highlight__c>();
        actualItemCount = 0;
        minItemsCount = 0;
        initialize();
    }
    
    /*
        Method Queries the Highlights Custom Object to fetch the latest Highlights ordered by Start Date
    */
    public void initialize(){
        //Number of Announcment Items to display when VIEW ALL is clicked
        Integer maxItemsCount = GNT.KeyValueStoreHelper.getIntegerValue('HighlightsExpandedItemsCount', true);
        //Number of Announcement Items to display by default
        minItemsCount = GNT.KeyValueStoreHelper.getIntegerValue('HighlightsVisibleItemsCount', true);
        //Number of characters allowed to display for each Highlight Item
        Integer highlightCharacterCount = GNT.KeyValueStoreHelper.getIntegerValue('HighlightsCharacterCount', true); 
        Integer i = 0;
        
        List<GNT__Highlight__c> highlightsList = new List<GNT__Highlight__c>();
        if(UserInfo.getUserType() == 'Guest' || Test.isRunningTest()){
            if(Network.getNetworkId() == null){ // Internal Site user
                highlightsList = [Select GNT__Summary__c, GNT__StartDate__c from GNT__Highlight__c where GNT__StartDate__c <= :Date.today()
                            and GNT__EndDate__c >= :Date.today() and RecordType.Name = 'Internal' order by GNT__StartDate__c DESC LIMIT :maxItemsCount];
            }else{  // External Community user
                highlightsList = [Select GNT__Summary__c, GNT__StartDate__c from GNT__Highlight__c where GNT__StartDate__c <= :Date.today()
                            and GNT__EndDate__c >= :Date.today() and RecordType.Name = 'External' order by GNT__StartDate__c DESC LIMIT :maxItemsCount];
            }
        }
                                    
        actualItemCount = highlightsList.size();
        
        for(GNT__Highlight__c highlightsInstance : highlightsList){
         GNT__Highlight__c updatedHighlight = new GNT__Highlight__c();
            
            if(highlightsList.get(i).GNT__Summary__c.length() > highlightCharacterCount){
                updatedHighlight.GNT__Summary__c = highlightsList.get(i).GNT__Summary__c.substring(0 , highlightCharacterCount) + '...';
            }
            else{
                updatedHighlight.GNT__Summary__c = highlightsList.get(i).GNT__Summary__c;
            }
            
            updatedHighlight.GNT__StartDate__c = highlightsList.get(i).GNT__StartDate__c;
            
            if(i < minItemsCount){
                minHighlightsList.add(updatedHighlight);
            }
            else{
                extendedHighlightsList.add(updatedHighlight);
            }
            i++;
        }
    }
}