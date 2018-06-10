public with sharing class GovGrantsLauncherCtrl {
    public PageReference targetPage() {
       System.debug(LoggingLevel.ERROR,'inside GovGrantsLauncherCtrl');      
       AppUtils.createUserPreference();
       PageReference page = AppUtils.getHomePage();
       return page ;    
    }
    
    
}