//public with sharing class ExternalRegistrationNDACtrl{
public class ExternalRegistrationNDACtrl{
    public ID recordId{get;set;}
    private ID contactId;
    private String securityToken;
    private String recordType;
    public PageReference deleteURL;
    public String pageTemplateName{get;set;}
    private PageReference cancelPage;
    private PageReference savePage;
   
  public ExternalRegistrationNDACtrl(ApexPages.StandardController stdController){
    //pageTemplateName = 'External Reviewer Edit';
    pageTEmplateName = 'ExternalRegistrationNDA';
    System.debug('ApexPages.CurrentPage().Conroller ' + ApexPages.CurrentPage().getParameters().get('id'));
  }

  public PageReference createUserReg(){
    securityToken= ApexPages.CurrentPage().getParameters().get('SecurityToken');
    recordType= ApexPages.CurrentPage().getParameters().get('RecordType');
    System.debug('securityToken: ' + securityToken + ', recordType: ' + recordType);
    System.debug('ApexPages.CurrentPage(). ' + ApexPages.CurrentPage().getParameters().get('id'));

    if(ApexPages.CurrentPage().getParameters().get('id') != null && ApexPages.CurrentPage().getParameters().get('id') != '' ) {
        this.recordId = ApexPages.CurrentPage().getParameters().get('id');
        return null;
    } else {
         if (!String.isEmpty(securityToken)){
              handleSecurityToken();
            }
            else {
              handleWithoutToken();
            }
            ApexPages.CurrentPage().setRedirect(true);
            return ApexPages.CurrentPage();
    }
   

    
  }

  /* PRIVATE METHODS */

  private void handleSecurityToken() {
    List<Contact> contactList = [SELECT Id, UserRegistration__c,email,FirstName,LastName,Phone,AccountID FROM Contact WHERE SecurityToken__c =: SecurityToken limit 1];
    List<Account> accountList = [SELECT Id, name FROM Account where ID =:contactList[0].AccountID];
    if (contactList.size() == 0) {
      //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Invalid token found in the URL'));
      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, GNT.ErrorMessageHelper.fetchMessage('P01-GRNTR-43951')));
      return;
    }

    Contact cont = contactList.get(0);
    if (cont.UserRegistration__c == null) {
      createRegistration(cont);
    }
    else {
      this.recordId = cont.UserRegistration__c;
      ApexPages.CurrentPage().getParameters().put('id', recordId );
    }
  }

  private void handleWithoutToken() {
    createRegistration(null);
  }

  private void createRegistration(Contact cont) {
    UserRegistration__c userReg = new UserRegistration__c();
    userReg.RecordTypeId = [Select Id from RecordType where DeveloperName = :recordType  and
                                SObjectType = 'UserRegistration__c'].id;
    userReg.NDALookup__c = getAgreementId('NDA');
    userReg.COILookup__c = getAgreementId('COI');
    if (cont != null) {
      userReg.Contact__c = cont.Id ;
      //swati
     userReg.Account__c = cont.AccountID;
     userReg.PrimaryRepEmail__c = cont.email;
     userReg.PrimaryRepFirstName__c = cont.FirstName;
     userReg.PrimaryRepLastName__c = cont.LastName;
     userReg.PrimaryRepPhone__c = cont.Phone;
      
    }
    insert userReg;
    System.debug('newly created user registration: ' + userReg);
    this.recordId = userReg.Id;
    ApexPages.CurrentPage().getParameters().put('id', recordId );
    System.debug('Id val: ' +  ApexPages.CurrentPage().getParameters().get('id'));

    if (cont != null) {
      cont.UserRegistration__c = userReg.id;
      update cont;
      // swati
      Account account = [SELECT Id, name,UserRegistration__c FROM Account where ID =:cont.AccountID];
      if(account !=null){
      account.UserRegistration__c = userReg.id;
      update account;
      }
      
      System.debug('contact updated: ' + cont);
    }
  }

  private Id getAgreementId(String agreementType) {
    List<MasterAgreement__c> masterAgreeList = ([SELECT Id FROM MasterAgreement__c WHERE 
                               DocumentType__c=:recordType and RecordType.DeveloperName=:agreementType limit 1]);
    if (masterAgreeList.size() == 1) {
      return masterAgreeList.get(0).Id;
    }
    return null;
  }


}