public with sharing class GrantsGovApplication {

  private String applicationId;
  
    private String headerNs = 'http://apply.grants.gov/system/Header-V1.0';
    private String headerNsPrefix = 'header';
    private String globalNs = 'http://apply.grants.gov/system/Global-V1.0';
    private String globalNsPrefix = 'glob';
  private String metaNs = 'http://apply.grants.gov/system/MetaGrantApplication';
  private String metaNsPrefix = 'grant';
  private List<String> applicationAttachments = new List<String>();

  public GrantsGovApplication(String appId){
    applicationId = appId;
  }

  public Dom.Document getApplicationDocument(){
    Dom.Document doc = new Dom.Document();

    Dom.Xmlnode rootNode = doc.createRootElement('GrantApplication', metaNs, metaNsPrefix);
    rootNode.setNamespace('xsi', 'http://www.w3.org/2001/XMLSchema-instance');
    rootNode.setNamespace('grant', metaNs);
    rootNode.setAttributeNS('schemaLocation', (metaNs), 'http://www.w3.org/2001/XMLSchema-instance', null);

    addApplicationHeader(rootNode, doc);
    addApplicationForms(rootNode, doc);
    
    //system.debug('>>>>>>>>>>>.doc.toXmlString()>>>>>>>>>>>>>>>' + doc.toXmlString());
    
    return doc;
  }
  
  public List<String> getApplicationAttachments(){
    return applicationAttachments;
  }
  
  private void addApplicationHeader(Dom.Xmlnode rootNode, Dom.Document doc){

    String oppId;
    List<Application__c> apps = [select Announcement__r.AnnouncementNumber__c  from Application__c where Id = :applicationId];
    if(apps != null && apps.size() >0){
        oppId = apps.get(0).Announcement__r.AnnouncementNumber__c;
    }
    System.debug('oppId-- ' + oppId);
    Dom.Xmlnode headerNode = rootNode.addChildElement('GrantSubmissionHeader', headerNs, headerNsPrefix);
    headerNode.setNamespace(globalNsPrefix, globalNs);
    headerNode.setAttributeNS('schemaVersion', '1.0', globalNs, null);
    Dom.Xmlnode globHashNode = headerNode.addChildElement('HashValue', globalNs, globalNsPrefix);
    globHashNode.setAttributeNS('hashAlgorithm', 'SHA-1', globalNs, null);
    
    List<Application__c> applications = [SELECT Announcement__r.AnnouncementNumber__c, CFDANumber__c FROM Application__c Where Id = :applicationId];

    if(!applications.isEmpty() && applications.size() > 0){
      Application__c application = applications.get(0);
      String cfda = null;
      if(String.isNotBlank(application.CFDANumber__c)){
        cfda = application.CFDANumber__c;
        Integer index = cfda.indexof(';');
        if( index > -1){
          cfda = cfda.substring(0, index);
        }
        headerNode.addChildElement('CFDANumber', headerNs, headerNsPrefix).addTextNode(cfda);
      }
      
      String oppNumber = application.Announcement__r != null ? application.Announcement__r.AnnouncementNumber__c : null;
      if(String.isNotBlank(oppNumber)){
        headerNode.addChildElement('OpportunityID', headerNs, headerNsPrefix).addTextNode(oppNumber);
      }
    }


  }
  
  private void addApplicationForms(Dom.Xmlnode rootNode, Dom.Document doc){
    List<Form__c> forms = [SELECT Id,  TemplateName__c, 
            PageTemplateConfig__r.Id, PageTemplateConfig__r.Name
            FROM Form__c where Application__c = :applicationId];
    
    if(forms == null || forms.isEmpty()){
      return;
    }
    
    Dom.Xmlnode formsNode = rootNode.addChildElement('Forms', metaNs, metaNsPrefix);    
   /*     for(Form__c form: forms){
            String formName = form.PageTemplateConfig__r.Name; 
            if(formName != null){
                system.debug('>>>>>>>>>>>>'+formName);
                GrantsGovApplicationForm appForm = new GrantsGovApplicationForm(applicationId, form.Id, formName);
                try{
                  appForm.buildForm(formsNode, doc);
                }catch(Exception e){
                  String msg = formName +'::' +e.getMessage() +'::'+e.getStackTraceString();
                  system.debug('Form Exception>>>>>>>>>>>>'+msg);
                  throw new IntegrationException(msg);
                }
                List<String> formAttachments = appForm.getFormAttachments();
                if(formAttachments != null && !formAttachments.isEmpty()){
                  applicationAttachments.addAll(formAttachments);
                  system.debug('applicationAttachments:>>>>>>>>>>>>'+applicationAttachments);
                }
                System.debug('appForm-- ' + appForm);
            }
        }*/
  }
  
  private class IntegrationException extends Exception{}
  
}