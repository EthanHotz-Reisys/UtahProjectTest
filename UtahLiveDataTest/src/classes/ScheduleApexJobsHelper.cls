global with sharing class ScheduleApexJobsHelper  extends GNT.FlexTableActionHandler {
       global override Map<String,Object> clickHandler(){
        Map<String,Object> returnMap = new Map<String,Object>();
        deleteScheduledJobs();
        if (Test.isRunningTest() == false) {
            new GNT.BatchJobKicker(true).scheduleApexJobsFromObject(); 
        }
        List<CronTrigger> apexJobs = [SELECT Id FROM CronTrigger where EndTime=null and CronJobDetail.JobType='7' limit 100];
        returnMap.put('Message','Apex jobs were scheduled. To view the list of jobs, visit the ' +
                '<a href="/08e?setupid=ScheduledJobs">Scheduled Jobs</a> page.');
        return returnMap;
       }
       
       public static void deleteScheduledJobs() {
        List<CronTrigger> apexJobs = [SELECT Id FROM CronTrigger where EndTime=null and CronJobDetail.JobType='7' limit 150];
        for (CronTrigger job : apexJobs) {
            System.abortJob(job.Id);
        }
    }
    
}