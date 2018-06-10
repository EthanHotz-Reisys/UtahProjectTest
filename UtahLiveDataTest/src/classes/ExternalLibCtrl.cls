/**
    **********************************************************************************************************************
    Audit History
    ********************************************************************************************************************
    2017-09-21        Shah Kadirmohideen            Code Reviewed
    **********************************************************************************************************************  
*/ 
global with sharing class ExternalLibCtrl {
     public String govGrantsColorContrastName {
        get;
        set;
    }
    public String themeDocURL {
        get;
        set;
    }

    /*parameters for google analytics*/
    public String analyticsId {
        get;
        set;
    }
    public Boolean enableAnalytics {
        get;
        set;
    }
    public String govGrantPleaseWaitIconURL {
        get;
        set;
    }

    public ExternalLibCtrl() {
        Boolean isEnable508 = false;
        String govGrantsColorContrast;

        applyGoogleAnalytics(); // google analytics changes                                    

        if (UserInfo.getUserType() == 'Guest') {
            isEnable508 = true;
        } else {
            user u = [SELECT GNT__Enable508Compliance__c,IsPortalEnabled, ContactId FROM User WHERE Id =: UserInfo.getUserId()];
            if (u.IsPortalEnabled) {
                Contact c = [SELECT GNT__Enable508Compliance__c FROM Contact WHERE Id =: u.ContactId];
                isEnable508 = c.GNT__Enable508Compliance__c;

            } else if (u.GNT__Enable508Compliance__c) {
                isEnable508 = true;
            }
        }

        govGrantsColorContrast = applyColorTheme(isEnable508); //Master CSS(Color) file        

        Set < String > docNames = new Set < String > ();
        docNames.add(govGrantsColorContrast);
        //String themeDoc = 'GovGrantsTheme'; //Master CSS(structural) file
        String themeDoc = 'GovGrantsThemeNew'; //Master CSS(structural) file
        docNames.add(themeDoc);

        String govGrantPleaseWaitIcon = GNT.KeyValueStoreHelper.getTextValue('govGrantPleaseWaitIcon', true);
        docNames.add(govGrantPleaseWaitIcon); //please Wait Icon
       
        //Code review Prem: Why are we using Name here and why not Developer Name?
        List < document > documentList = [select Name,DeveloperName from document where DeveloperName in: docNames];
        if (documentList.size() > 0) {
            for (Document doc: documentList) {
                if (themeDoc != null && doc.DeveloperName == themeDoc) {
                    themeDocURL = '/servlet/servlet.FileDownload?file=' + doc.id;
                }
                if (govGrantsColorContrast != null && doc.DeveloperName == govGrantsColorContrast) {
                    govGrantsColorContrastName = '/servlet/servlet.FileDownload?file=' + doc.id;
                }
                if (govGrantPleaseWaitIcon != null && doc.DeveloperName == govGrantPleaseWaitIcon) {
                    govGrantPleaseWaitIconURL = '/servlet/servlet.FileDownload?file=' + doc.id;
                    
                }
            }
        }
    }
    private void applyGoogleAnalytics() {
        /*variable initializatin*/
        analyticsId = GNT.KeyValueStoreHelper.getTextValue('GoogleAnalyticsId', true);
        enableAnalytics = GNT.KeyValueStoreHelper.getBooleanValue('EnableGoogleAnalytics', true);
        

    }
    public string applyColorTheme(Boolean isEnable508) {
        string colorContrastTheme;
        if (isEnable508 == true) {
            colorContrastTheme = GNT.KeyValueStoreHelper.getTextValue('govGrantsColorContrast_508', true);
        } else {
            colorContrastTheme = GNT.KeyValueStoreHelper.getTextValue('govGrantsColorContrast', true);
            GNT__UserPreferences__c pref = GNT__UserPreferences__c.getInstance();
            
            if(pref.GNT__ThemeDocumentID__c != null) {
              colorContrastTheme = pref.GNT__ThemeDocumentID__c;
            } else {
              if (pref.GNT__ActiveAppName__c.containsIgnoreCase('Grantor')) {
                  colorContrastTheme = colorContrastTheme + '_Grantor';
              } else if (pref.GNT__ActiveAppName__c.containsIgnoreCase('Grantee')) {
                  colorContrastTheme = colorContrastTheme + '_Grantee';
              } else if (pref.GNT__ActiveAppName__c.equalsIgnoreCase('Recipient')) {
                  colorContrastTheme = colorContrastTheme + '_Recipient';
              } else if (pref.GNT__ActiveAppName__c.equalsIgnoreCase('Admin')) {
                  colorContrastTheme = colorContrastTheme + '_Admin';
              }
            }
        }
        return colorContrastTheme;
    } 
}