public with sharing class FEDBatchViewCtrl {
    public FEDBatchViewCtrl() {
        
    }

    public PageReference test(){
        PageReference p = Page.AWSSuccess;
        p.setRedirect(true);
        return p;
    }

}