public class CommunityManageExternalUserCtrl{
    
    //Properties
    public PageReference savePage {get;set;}
    public PageReference cancelPage {get;set;}
    public Id contactId {
        get{
            String userId = ApexPages.currentPage().getParameters().get('userId');          
            contactId = GNT__UserPreferences__c.getValues(UserInfo.getUserId()).GNT__ContactId__c;
            return contactId;
        }
        set;}
    public CommunityManageExternalUserCtrl(ApexPages.StandardController stdController){
        savePage = Page.CommunityRegisteredExtUsersList;
        cancelPage = Page.CommunityRegisteredExtUsersList;
    }
}