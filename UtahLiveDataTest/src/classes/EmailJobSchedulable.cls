global class EmailJobSchedulable implements Schedulable {
     global void execute(SchedulableContext ctx) {
        System.abortJob(ctx.getTriggerId());
        scheduleMe();
   } 
    
    global static void scheduleMe()
    {
        DateTime now  = DateTime.now();
        Integer intervalMinutes = 1;
        DateTime nextRunTime = now.addMinutes(intervalMinutes);
        String cronString = '' + nextRunTime.second() + ' ' + nextRunTime.minute() + ' ' + 
            nextRunTime.hour() + ' ' + nextRunTime.day() + ' ' + 
            nextRunTime.month() + ' ? ' + nextRunTime.year();
         String jobName = Test.isRunningTest() ? 'TestEmailJobScheduler' : 'EmailJobScheduler';
        //System.schedule(jobName, cronString, this);   
        System.schedule(jobName, cronString,new EmailJobSchedulable());
        GNT.EmailSenderJob emailSend = new  GNT.EmailSenderJob();
        database.executebatch(emailSend,10);  
    }
}