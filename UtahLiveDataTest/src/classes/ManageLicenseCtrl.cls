public class ManageLicenseCtrl {
    public List<UserInfo> userInfoList{get;set;}
    public ManageLicenseCtrl() {
        userInfoList = getPassiveUserList(true);
    }


    public static List<UserInfo> getPassiveUserList(Boolean isInternal) {
        List<UserInfo> usersInfoToReturn = new List<UserInfo>();
        List<User> passiveUsers = [select Id, Name from user where GNT__GGUserType__c = 'Passive'];
        for(List<User> users : getSplittedList(passiveUsers)) {
            usersInfoToReturn.addAll(getExceededuers(users));
        }
        return usersInfoToReturn;
    }
    
    public static List<UserInfo> getExceededuers(List<User> users) {
        List<UserInfo> usersInfoToReturn = new List<UserInfo>();
        Map<String, user> userIds = new Map<String, user>();
        for(User u : users) {
            userIds.put(u.Id, u);
        }
        List<AggregateResult> usersLoggedInCount = [Select count(Id), UserId from LoginHistory where LoginTime = LAST_MONTH and userid in:userIds.keySet() and LoginType = 'Application' group by userid];
        for(AggregateResult aggRes : usersLoggedInCount) {
            Integer logCount = (Integer)aggRes.get('expr0');
            String userId = (String)aggRes.get('UserId');
            GNT__GlobalConfig__c gc = GNT__GlobalConfig__c.getInstance(userId);
            if(gc != null && gc.GNT__AllowedLoginAttempts__c != null && gc.GNT__AllowedLoginAttempts__c < logCount) {
                UserInfo uinfo = new UserInfo();
                uinfo.user = userIds.get(userId);
                uinfo.noOfLoginAttemplted = logCount;
                uinfo.allowedLogins = Integer.valueOf(gc.GNT__AllowedLoginAttempts__c);
                usersInfoToReturn.add(uinfo);
            }
            
        }
        return usersInfoToReturn;
    }
    
    private static List<List<User>> getSplittedList(List<User> users) {
        List<List<User>> userListToReturn = new List<List<User>>();
        for(Integer i = 0 ; i < (users.size() / 200)+1 ; i++){
            List<User> lstTemp = new List<User>();
            for(Integer j=(i*200);(j<(i*200)+200) && j<users.size() ; j++){
                lstTemp.add(users.get(j));
            }
            userListToReturn.add(lstTemp);
        }
        return userListToReturn;
    }
    
    public class UserInfo{
        public User user{get;set;}
        public Integer noOfLoginAttemplted{get;set;}
        public Integer allowedLogins{get;set;}
    }

}