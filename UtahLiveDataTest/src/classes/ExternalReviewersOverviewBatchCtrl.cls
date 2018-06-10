global class ExternalReviewersOverviewBatchCtrl implements Database.Batchable<sObject>, Database.Stateful  {
    
    private String query;
    private Set <User> externalReviewersList;
    private String subject;
    private String body='';
    private String htmlBodyForActiveReviewers='';
    private String htmlBodyForInactiveReviewers='';
    private List<String> emailAddress;
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        if(query == null){
            query = 'SELECT Id,Name,IsActive,FirstName,Email,LastName,IsReviewer__c,IsApplicant__c,LastLoginDate,LastModifiedDate FROM User WHERE IsReviewer__c = True '+
            'AND LastModifiedDate = TODAY ORDER BY LastModifiedDate DESC';
        }
        return Database.getQueryLocator(query);
    }
    
    global void execute (Database.BatchableContext BC, List<sObject> scope){
        try{
            externalReviewersList = new set<User>();
            externalReviewersList.addAll((List <User>)scope);
            system.debug('externalReviewersList------->>>'+externalReviewersList);
            set <User> activeReviewersList = new set <User>();
            set <User> inactiveReviewersList = new set <User>();
            emailAddress = New List<String>();
            if(externalReviewersList.size() > 0){
                for(User u :externalReviewersList){
                    if(u.IsActive){
                        activeReviewersList.add(u);
                    }else{
                        inactiveReviewersList.add(u);
                    }
                }
                subject = 'List of Active And Inactive Reviewers';
                body = 'Hi ' + UserInfo.getFirstName() + ' following table contains list of Activated and Deactivated External Reviewers within 24 hrs<br/>';
                htmlBodyForActiveReviewers += '<table border="1" style="width:50%">';
                htmlBodyForActiveReviewers += '<tr>';
                htmlBodyForActiveReviewers += '<td>';
                htmlBodyForActiveReviewers += 'First Name';
                htmlBodyForActiveReviewers += '</td>';
                htmlBodyForActiveReviewers += '<td>';
                htmlBodyForActiveReviewers += 'Last Name';
                htmlBodyForActiveReviewers += '</td>';
                htmlBodyForActiveReviewers += '<td>';
                htmlBodyForActiveReviewers += 'Email';
                htmlBodyForActiveReviewers += '</td>';
                htmlBodyForActiveReviewers += '</tr>';
                if(activeReviewersList.size() > 0){
                        for(User u : activeReviewersList){
                            htmlBodyForActiveReviewers += '<tr>';
                            htmlBodyForActiveReviewers += '<td>';
                            htmlBodyForActiveReviewers += u.FirstName;
                            htmlBodyForActiveReviewers += '</td>';
                            htmlBodyForActiveReviewers += '<td>';
                            htmlBodyForActiveReviewers += u.LastName;
                            htmlBodyForActiveReviewers += '</td>';
                            htmlBodyForActiveReviewers += '<td>';
                            htmlBodyForActiveReviewers += u.Email;
                            htmlBodyForActiveReviewers += '</td>';                      
                            htmlBodyForActiveReviewers += '</tr>';
                        }
                        
                        htmlBodyForActiveReviewers += '</table>';       
                        htmlBodyForActiveReviewers += '<br/><br/>';             
                }
                
                
                htmlBodyForInactiveReviewers += '<table border="1" style="width:50%">';
                htmlBodyForInactiveReviewers += '<tr>';
                htmlBodyForInactiveReviewers += '<td>';
                htmlBodyForInactiveReviewers += 'First Name';
                htmlBodyForInactiveReviewers += '</td>';
                htmlBodyForInactiveReviewers += '<td>';
                htmlBodyForInactiveReviewers += 'Last Name';
                htmlBodyForInactiveReviewers += '</td>';
                htmlBodyForInactiveReviewers += '<td>';
                htmlBodyForInactiveReviewers += 'Email';
                htmlBodyForInactiveReviewers += '</td>';
                htmlBodyForInactiveReviewers += '</tr>';
                if(activeReviewersList.size() > 0){
                        for(User u : activeReviewersList){
                            htmlBodyForInactiveReviewers += '<tr>';
                            htmlBodyForInactiveReviewers += '<td>';
                            htmlBodyForInactiveReviewers += u.FirstName;
                            htmlBodyForInactiveReviewers += '</td>';
                            htmlBodyForInactiveReviewers += '<td>';
                            htmlBodyForInactiveReviewers += u.LastName;
                            htmlBodyForInactiveReviewers += '</td>';
                            htmlBodyForInactiveReviewers += '<td>';
                            htmlBodyForInactiveReviewers += u.Email;
                            htmlBodyForInactiveReviewers += '</td>';                        
                            htmlBodyForInactiveReviewers += '</tr>';
                        }
                        
                        htmlBodyForInactiveReviewers += '</table>';     
                        htmlBodyForInactiveReviewers += '<br/><br/>';               
                }           
                body = body + htmlBodyForActiveReviewers  + htmlBodyForInactiveReviewers;   
                emailAddress.add('tanmay.deshpande@reisystems.in');
                system.debug('body-------->>>>'+body);
                //AppUtils.sendEmail(emailAddress,subject,'',body);
                //scheduleMe();                                                                                                     
            }                                   
        }catch(Exception e){
            body='Following is the error --->>>>'+e.getMessage();
        }           
    }
    
     global void finish(Database.BatchableContext BC){
        try{
            
        }catch(Exception e){
            
        }
     }
     
     global static void scheduleMe() {
        ExternalReviewersOverviewBatchCtrl batch = new ExternalReviewersOverviewBatchCtrl();
        //String cronExpression = GNT.BatchApexJobScheduler.prepareJobsSchTime(System.now(),2);
        String jobName = GNT.BatchApexJobScheduler.getUniqueJobName('ExternalReviewersOverviewBatchCtrl');
        if (!Test.isRunningTest()) {
            System.schedule(jobName,'0 20 00 * * ?', new GNT.BatchApexJobScheduler(batch, 1));
        }
    }

}