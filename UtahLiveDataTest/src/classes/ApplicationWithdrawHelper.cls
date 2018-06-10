global without sharing class ApplicationWithdrawHelper extends GNT.DynamicLayoutActionRedirect{
    //test
    global override PageReference whenClicked(){ 
         Savepoint sp = Database.setSavePoint();
          try{
              Id recordId = layoutHolder.getPrimarySObject().Id;
           Application__c app = [Select Id, Name, Status__c, Announcement__r.ApplicationDeadlineWithDateTime__c, Announcement__c from Application__c where id = :recordId Limit 1];
           List<Announcement__c> ann = [Select NumberOfApplications__c, ApplicationDeadlineWithDateTime__c, ExtensionDays__c, TimeExtensionAllowed__c from Announcement__c where Id = :app.Announcement__c];   
            
            Boolean HideSubmit = true;
            Date d = Date.newInstance(ann[0].ApplicationDeadlineWithDateTime__c.year(), ann[0].ApplicationDeadlineWithDateTime__c.month(), ann[0].ApplicationDeadlineWithDateTime__c.day());
            User u = [Select Contact.Account.IsExtensionAllowed__c from User where Id = :UserInfo.getUserId()];
            if(u.Contact.Account.IsExtensionAllowed__c == true && ann[0].TimeExtensionAllowed__c == true){          
              if(d + Integer.valueOf(ann[0].ExtensionDays__c )> Date.today()){
                  HideSubmit = false;
              }
            }else{
              if(d > Date.today()){
                  HideSubmit = false;
              }
            }

            if(HideSubmit){
             // ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'The Application can not be withdrawn after Submission Daedline'));
              ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-52535')));
              return null;
            }

            //if(app.Announcement__r.ApplicationDeadlineWithDateTime__c<System.now()){
            //  // ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'The Application can not be withdrawn after Submission Daedline'));
            //  ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-52535')));
            //  return null;
            //}
              app.Status__c = 'Withdrawn';
              update app; 
             SystemContextMethodsHelper scm = new SystemContextMethodsHelper();
             if(ann[0].NumberOfApplications__c > 0){
                ann[0].NumberOfApplications__c = ann[0].NumberOfApplications__c - 1;
                scm.updateAnnouncements(ann);
             }
             
              // ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'The Application has been successfully withdrawn.'));
              ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, GNT.ErrorMessageHelper.fetchMessage('P02-GRNTR-16864')));  
              PageReference pf = Page.ApplicationView;
              pf.getParameters().put('id', app.Id); 
              pf.setRedirect(true);
              return pf;
          }catch(Exception ex){
            Database.rollback(sp);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, ex.getMessage())); 
            return null;
          }
    }

}