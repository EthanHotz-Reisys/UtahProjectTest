global with sharing class ProfileRedirectCtrl {
    private String profileId;

    public ProfileRedirectCtrl() {
        Map<String, String> UrlParameterMap = ApexPages.currentPage().getParameters();
        if (UrlParameterMap.containsKey('id')){
            profileId = UrlParameterMap.get('id');
        } else {
            profileId = 'none';
        }
    }

    public PageReference profileRedirect() {
        String namespace = AppUtils.getNamespacePrefix();
        PageReference p;
        if (profileId != 'none') {
            List<User> tmpList = [SELECT id, ContactId FROM User WHERE id = :profileId LIMIT 1];
            if (tmpList[0].ContactId != null) {
                p = new PageReference('/apex/' + namespace + 'communityUserProfileView?id=' + tmpList[0].ContactId);
            } else {
                p = new PageReference('/apex/' + namespace + 'myProfileView?id=' + profileId);
            }
        } else {
            return null;
        }
        return p;
    }
}