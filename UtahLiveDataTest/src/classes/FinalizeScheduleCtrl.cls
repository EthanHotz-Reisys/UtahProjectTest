global with sharing class FinalizeScheduleCtrl extends GNT.DynamicLayoutActionRedirect{

    
    global override PageReference whenClicked(){
        Savepoint sp = Database.setSavepoint();
        Id recordId = layoutHolder.getPrimarySObject().Id;        
        SiteVisitSchedule__c siteSchedule = (SiteVisitSchedule__c)layoutHolder.recordMap.get(AppUtils.getNamespacePrefix() + 'SiteVisitSchedule__c');
        try{
            siteSchedule.status__c = 'Finalized';
            update siteSchedule;
            List <SiteVisit__c> siteVisits = [SELECT Id,Name, IsSiteVisitFinalized__c,SiteVisitor__r.email,SiteVisitor__r.name,grant__r.Name,SiteVisitor__c,
                                                   grant__r.GranteePOC__r.email,grant__r.AssignedTo__r.email,grant__r.ProjectDirector__r.email,VisitDateandTime__c
                                                       FROM SiteVisit__c];            
        
        }catch(Exception e){
            Database.rollback(sp);
            //errorMsg = e.getMessage();
            return null;
        }
        
        PageReference  p = Page.SiteVisitScheduleView;
        p.getParameters().put('id',recordId);
        p.setRedirect(true);
        return p;
     }
      
      /* Pranjali : The below method is not used in this class hence commenting it */
      /*
      private void sendEmailNUpdateSiteVisit(List<SiteVisit__c> siteVisits){
          //Create a master list to hold the emails we'll send
          List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
          List<SiteVisit__c> siteVisitList  =  new List<SiteVisit__c>();
          List<GNT.TaskCreationHandler.TaskBulkClass> taskBulkList =  new List<GNT.TaskCreationHandler.TaskBulkClass> ();
          for(SiteVisit__c siteVisit : siteVisits){
             if(!siteVisit.IsSiteVisitFinalized__c){
                  Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                  List<String> sendTo = new List<String>();
                  if(siteVisit.SiteVisitor__r.email != null)
                      sendTo.add(siteVisit.SiteVisitor__r.email);
                  List<String>sendCC = new List<String>();
                  if(siteVisit.grant__r.GranteePOC__r.email != null)
                      sendCC.add(siteVisit.grant__r.GranteePOC__r.email);
                  if(siteVisit.grant__r.AssignedTo__r.email != null)
                      sendCC.add(siteVisit.grant__r.AssignedTo__r.email);
                  if(siteVisit.grant__r.ProjectDirector__r.email != null)
                      sendCC.add(siteVisit.grant__r.ProjectDirector__r.email);
                  mail.setToAddresses(sendTo); 
                  mail.setCCAddresses(sendCC);     
                  mail.setSubject('Site Visit finalized for Grant '+siteVisit.grant__r.Name);
                  mail.setHTMLBody('Hello '+ siteVisit.SiteVisitor__r.name +', <br/> Site visit scheduled at '+ siteVisit.VisitDateandTime__c + '<br/> Thank You');
                  mails.add(mail);
                  
                  // Check isSiteVisitFinalized to true
                  siteVisit.IsSiteVisitFinalized__c = true;
                  siteVisitList.add(siteVisit);
                  
                  GNT.TaskCreationHandler.TaskBulkClass taskBulkInstance = new GNT.TaskCreationHandler.TaskBulkClass();
                  taskBulkInstance.ownerUserId = siteVisit.SiteVisitor__c;
                  taskBulkInstance.recordId = siteVisit.Id;
                  taskBulkInstance.action = 'Submit Site Visit Report';
                  taskBulkInstance.recordName = siteVisit.Name;
                  taskBulkList.add(taskBulkInstance);              
              }  
          }
          // Send email
           if(mails != null && mails.size() > 0){
               Messaging.sendEmail(mails);
           }
          //update SiteVisit
          if(siteVisitList != null && siteVisitList.size() > 0){
              if(Schema.sObjectType.SiteVisit__c.isUpdateable()){
                 update siteVisitList;
              }
          }

          //Create Tasks
          GNT.TaskCreationHandler.createBulkTasks(taskBulkList, true);
      }    */
}