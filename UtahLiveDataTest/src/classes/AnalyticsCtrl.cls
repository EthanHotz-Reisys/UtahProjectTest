/**
    **********************************************************************************************************************
    Audit History
    ********************************************************************************************************************
    2017-09-21        Shah Kadirmohideen            Code Reviewed
    **********************************************************************************************************************  
*/ 
public class AnalyticsCtrl{
        public String analyticsId { get; set; }
        public Boolean enableAnalytics { get; set; }
        public string authtoken{get;set;}
        public string refereshtoken{get;set;}
        public string bodyprint{get;set;}
        public List<String> URLStringList{get; set;}

        //Settings needed on the google cloud console.One can store this securely in custom settings or an object.
    
        //public static final string CLIENT_SECRET='JzjjexX-pkxV6uVjFP980TgL';//Fill as per your registered app settings in google console
        //public static final string CLIENT_ID='644421266142-eme20qhffvh9gttlptvfv5q7otf4datg.apps.googleusercontent.com';//Fill as per your registered app settings in google console
        //Shah CRF: Move hardcoded values (except URLs) to custom setting
        public static final string CLIENT_SECRET='t1DmkBxB_Eki9D1isk72mL0S';//Fill as per your registered app settings in google console
        public static final string CLIENT_ID='950317532649-k04pg822mospg321j3a03n7o50j5opf3.apps.googleusercontent.com';

        //public static final string REDIRECT_URL='https://ggdemo2.na31.visual.force.com/apex/GoogleAPIIntegration';
        public static final string REDIRECT_URL='https://analytics.google.com/';
        public static final string OAUTH_TOKEN_URL='https://accounts.google.com/o/oauth2/token';
        public static final string OAUTH_CODE_END_POINT_URL='https://accounts.google.com/o/oauth2/auth';
        
        public static final string GRANT_TYPE='grant_type=authorization_code';
        
        //Scope URL as per oauth 2.0 guide of the google 
        public static final string SCOPE='https://www.googleapis.com/auth/userinfo.profile https://www.googleapis.com/auth/userinfo.email https://mail.google.com/';
        public static final string STATE='/profile';
        
        //Approval Prompt Constant
        public static final string APPROVAL_PROMPT='force';
        
        public String accessToken='';
        
        public String toAddress{get;set;}
        public String subject{get;set;}
        public String body{get;set;}
        
        public AnalyticsCtrl(){
            analyticsId = GNT.KeyValueStoreHelper.getTextValue('GoogleAnalyticsId', true);
            enableAnalytics  = GNT.KeyValueStoreHelper.getBooleanValue('EnableGoogleAnalytics', true);
            System.debug('===> analyticsId '+analyticsId );
            System.debug('===> enableAnalytics  '+enableAnalytics  );
            
        }
       //returns request token
       public pagereference connect(){
           String x=OAUTH_CODE_END_POINT_URL+'?scope='+EncodingUtil.urlEncode(SCOPE, 'UTF-8')+'&state='+EncodingUtil.urlEncode(STATE,'UTF-8')+'&redirect_uri='+EncodingUtil.urlEncode(REDIRECT_URL,'UTF-8')+'&response_type=code&client_id='+CLIENT_ID+'&approval_prompt='+APPROVAL_PROMPT;
           pagereference p=new pagereference(x);
           return p;
       }
 }