public with sharing class AccountRedirectCtrl {
    public AccountRedirectCtrl (ApexPages.StandardController controller) {
    }

    // Code we will invoke on page load.
    public PageReference forwardToPage() {
        String ns = AppUtils.getNamespacePrefix(); 
        Id accId = System.currentPageReference().getParameters().get('id');
          
        String redirectToTheme = ApexPages.currentPage().getParameters().get('retParams');
        if(!String.isEmpty(redirectToTheme) && redirectToTheme.contains('themeselect')){
            return new PageReference('/apex/'+ns+'ThemeSelection?aid='+accId );
        }else{
            return new PageReference('/apex/'+ns+'OrganizationView?id='+accId );
        }
        return null;
    }
}