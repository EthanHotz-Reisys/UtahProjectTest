/*
    Controller Class for WhatFixHelper
    ***********************************************************
    Audit History
    ***********************************************************
    06/20/2016      Dhruva Eppalapally       Created
    *********************************************************** 
*/
public class WhatFixHelperCtrl {
    
    public Boolean getEnableWhatFix() {
        Boolean storeValue = GNT.KeyValueStoreHelper.getBooleanValue('EnableWhatFix', true);
        
        return storeValue == true;
    }
    
    // WhatFix ent_id indicates which WhatFix account we use
    public String getWhatFixEntId() {
        String storeValue = GNT.KeyValueStoreHelper.getTextValue('WhatFixEntId', true);
        
        return storeValue == null ? 'd210c700-3713-11e6-969a-448a5b5dd5b8' : storeValue;
    }
    
    public String getOrgName() {
        Organization myOrg = [SELECT Name FROM Organization LIMIT 1];
        return myOrg == null ? '' : myOrg.Name;
    }
    
    public String getPackageName() {
        return AppUtils.getNameSpacePrefix();
    }
    
    public String getProfileName() {
        return [SELECT Profile.Name FROM User WHERE Id = :UserInfo.getUserId()].Profile.Name;
    }
    
}