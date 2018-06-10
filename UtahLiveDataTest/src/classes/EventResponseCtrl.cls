public class EventResponseCtrl {
    public String eventId{get;set;}
    public String usrId{get;set;}
    public String status{get;set;}
    public String inputValue { get; set;} 
    public Site site {get;set;}
    public String siteFullUrl {set; get;}
    
    public EventResponseCtrl() {
        site = [Select name,SubDomain,UrlPathPrefix from Site where Name = 'Recipient_Portal'];
        String urlCode = String.valueof(URL.getSalesforceBaseUrl().toExternalForm());
        Organization org = [SELECT InstanceName, IsSandbox, OrganizationType FROM Organization];
        siteFullUrl = 'https://' + site.Subdomain + '.';
        siteFullUrl += (org.IsSandbox || org.OrganizationType == 'Developer Edition' ? (org.InstanceName.toLowerCase() + '.') : '') + 'force.com';
        //siteFullUrl += '/' + site.UrlPathPrefix;
        System.debug('===> '+siteFullUrl );
        eventId = ApexPages.CurrentPage().getParameters().get('eventId');
    }
       
    public void eventResponse(){
        String eventId,usrId,status;
        eventId = ApexPages.CurrentPage().getParameters().get('eventId');
        usrId = ApexPages.CurrentPage().getParameters().get('usrId');
        status = ApexPages.CurrentPage().getParameters().get('status');
        System.debug('===> eventId  '+eventId);
        System.debug('===> usrId '+usrId);
        //EventRelation eve = [Select EventId, RelationId, Status from EventRelation where EventId =: eventId and RelationId =: usrId];
        EventRelation__c eve = [Select EventId__c, RelationId__c, Status__c from EventRelation__c where EventId__c =: eventId and RelationId__c =: usrId];
        System.debug('===> eve  '+ eve);
        if(eve.Status__c == 'Accepted' && status == 'Accepted')
            // ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.info,'You have already accepted the request'));
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.info,GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-59008')));
        else if(eve.Status__c == 'Declined' && status == 'Declined')    
            // ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.info,'You have already declined the request'));
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.info,GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-77851')));
        else{   
            if(eve.Status__c != 'Accepted' && status == 'Accepted'){
                // ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.info,'Your request has been accepted'));
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.info,GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-90278')));
                eve.Status__c = 'Accepted';
                update eve;
            }
            else if(eve.Status__c != 'Declined' && status == 'Declined'){    
                // ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.info,'Your request has been declined'));
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.info,GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-91368')));
                eve.Status__c = 'Declined';
                update eve;
                
            }
        }
        System.debug('===> eventId / usrId / status '+ eventId + '/' + usrId + '/' + status);
    }
    private String dummy='';

    public String getDummy(){
         GNT__GlobalConfig__c gblConfig = [SELECT  GNT__InternalURLDomain__c FROM  GNT__GlobalConfig__c where Id = 'a0U36000004Cami' limit 1];
         System.debug('===> gblConfig  '+gblConfig );
         dummy = gblConfig.GNT__InternalURLDomain__c ;
        return dummy;
    }
 
}