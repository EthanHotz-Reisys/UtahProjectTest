global with sharing class UsefulLinksCtrl {
    global List<UsefulLinkWrapper> extendedLinksList {get;set;}
    global List<UsefulLinkWrapper> minLinksList {get;set;}
    global Integer minItemsCount {get;set;}
    global Integer actualItemCount {get;set;}
    
    global UsefulLinksCtrl (){
        minLinksList = new List<UsefulLinkWrapper>();
        extendedLinksList = new List<UsefulLinkWrapper>();
        actualItemCount = 0;
        minItemsCount = 0;
        initialize(); 
    }
    
    /*
        Method Queries the UsefulLinks__c Custom setting
    */
    global void initialize(){ 
        //Number of links Item to display when VIEW ALL is clicked
        Integer maxItemsCount = GNT.KeyValueStoreHelper.getIntegerValue('UsefulLinksExpandedItemsCount', true);
        //Number of Announcement Items to display by default
        minItemsCount = GNT.KeyValueStoreHelper.getIntegerValue('UsefulLinksVisibleItemsCount', true);
        //Number of characters allowed to display for each Highlight Item
        Integer highlightCharacterCount = GNT.KeyValueStoreHelper.getIntegerValue('UsefulLinksCharacterCount', true); 
        Integer i = 0;        
        List<GNT__UsefulLinkConfig__c> linkList = new List<GNT__UsefulLinkConfig__c>();        
         
        if(String.valueOf(ApexPages.CurrentPage()).contains('Applicant')){
            linkList = [Select GNT__URL__c, GNT__Label__c, GNT__OpenInNewWindow__c, GNT__Location__c  
                from GNT__UsefulLinkConfig__c Where GNT__Active__c = true AND GNT__Location__c = 'ApplicantLogin' 
                    Order by GNT__Sequence__c LIMIT :maxItemsCount]; 
                    
        }else if(String.valueOf(ApexPages.CurrentPage()).contains('Reviewer')){
            linkList = [Select GNT__URL__c, GNT__Label__c, GNT__OpenInNewWindow__c, GNT__Location__c 
                from GNT__UsefulLinkConfig__c Where GNT__Active__c = true AND GNT__Location__c = 'ReviewerLogin' 
                    Order by GNT__Sequence__c LIMIT :maxItemsCount]; 
        }

        actualItemCount = linkList.size();
        
        for(GNT__UsefulLinkConfig__c link : linkList){            
            GNT__UsefulLinkConfig__c usefulLink = new GNT__UsefulLinkConfig__c();
            
            if(link.GNT__Label__c.length() > highlightCharacterCount){
                usefulLink.GNT__Label__c = link.GNT__Label__c.substring(0 , highlightCharacterCount) + '...';
            }
            else{
                usefulLink.GNT__Label__c = link.GNT__Label__c;
            } 
            
            if(i < minItemsCount){
                minLinksList.add(new UsefulLinkWrapper(usefulLink.GNT__Label__c, link.GNT__URL__c, link.GNT__OpenInNewWindow__c));
            }
            else{
                extendedLinksList.add(new UsefulLinkWrapper(usefulLink.GNT__Label__c, link.GNT__URL__c, link.GNT__OpenInNewWindow__c));
            }
            i++;
        }
    } 
    
    global class UsefulLinkWrapper{
        global string label{get;set;}
        global string url{get;set;}
        global boolean openInNewWindow {get;set;}
        global UsefulLinkWrapper(String label, String url, boolean openInNewWindow){
            this.label = label;
            this.url = url;
            this.openInNewWindow = openInNewWindow;
        }
    }
}