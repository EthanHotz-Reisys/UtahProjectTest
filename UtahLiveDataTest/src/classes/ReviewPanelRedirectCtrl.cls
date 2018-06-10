public with sharing class ReviewPanelRedirectCtrl {

    public PageReference forwardToReviewPanel() {
        
        String panelName = ApexPages.currentPage().getParameters().get('name');
	    
	    ReviewStep__c panel = [Select Id from ReviewStep__c where Name=:panelName];
	    PageReference p = new PageReference('/' + panel.Id);
	    p.setRedirect(true);
	    return p;
    }

}