global class ApprovalRecallSchedular implements Schedulable {
    Integer intervalMinutes;
    public ApprovalRecallSchedular(Integer intervalMinutes) {
        this.intervalMinutes = intervalMinutes;
    }
   global void execute(SchedulableContext sc) {
      DateTime now  = DateTime.now();
        DateTime nextRunTime = now.addMinutes(2);
        String cronString = '' + nextRunTime.second() + ' ' + nextRunTime.minute() + ' ' + 
            nextRunTime.hour() + ' ' + nextRunTime.day() + ' ' + 
            nextRunTime.month() + ' ? ' + nextRunTime.year(); 
        System.schedule(ApprovalRecallSchedular.class.getName() + '-' + now.format(), cronString, new ApprovalRecallSchedular(intervalMinutes));
        // Abort the current job
        Id jobId = sc.getTriggerId();
        System.abortJob(jobId);
      
      GNT.ApprovalRecallBatch b = new GNT.ApprovalRecallBatch(); 
      database.executebatch(b, 1);
   }

       global static void scheduleMe() {
        GNT.ApprovalRecallBatch batch = new GNT.ApprovalRecallBatch();
        
        String cronExpression = GNT.BatchApexJobScheduler.prepareJobsSchTime(System.now(), 2); 
        String jobName = GNT.BatchApexJobScheduler.getUniqueJobName('ApprovalRecallBatch');  

        if (!Test.isRunningTest()) {
            System.schedule(jobName, cronExpression, new GNT.BatchApexJobScheduler(batch, 1));
        }
    }
}