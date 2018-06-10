public class CommunityUserDeactivateCtrl {

    public PageReference cancelPage(){
        PageReference cancelPage1 = Page.CommunityRegisteredExtUsersList;
        return cancelPage1;
    }

    public PageReference deactivateUser() {
        try{
            User extUser = [Select Id,IsActive From User Where Id = : ApexPages.currentPage().getParameters().get('userId') Limit 1];
            if(extUser != null){
                if(!(extUser.Id == UserInfo.getUserId())){
                    extUser.IsActive = false;
                    if(Schema.sObjectType.User.isUpdateable()){
                        update extUser;
                    }
                }
            }
        }catch(Exception e){
            ApexPages.AddMessages(e);
        }
        return Page.CommunityRegisteredExtUsersList;
    }
    
}