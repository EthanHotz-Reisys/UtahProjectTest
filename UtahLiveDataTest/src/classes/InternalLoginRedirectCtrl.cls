public with sharing class InternalLoginRedirectCtrl {

    public PageReference forwardToPage() {
     AppUtils.createUserPreference();
        String ns = AppUtils.getNamespacePrefix(); 
        Id annId = System.currentPageReference().getParameters().get('applyId');  
        system.debug('announcement id is'+annId);
        if(annId != '' && annId !=null){
            return new PageReference('/apex/'+ns+'AnnouncementView?id='+annId);
        }else{            
            PageReference page = AppUtils.getHomepage();
            return page;     //TODO: instead of hardcoding, conditionally redirect to the correct home page
        }
        return null;
    }
}