/**
    Allows admin to setup various scheduled jobs from single click.
*/
public with sharing class JobSetupCtrl {
    public Integer currentlyRunningJobs {get; set;}
    public Integer expectedJobs {get; set;}

    private static final Integer MAX_JOBS = 5000;

    public JobSetupCtrl() {
        init();
    }

    //Selects all apex scheduled jobs (not scheduled reports or dashboards) and deletes them
    //from the scheduled jobs page so that any deployments can be made.
    public PageReference deleteScheduledJobs() {
        List<CronTrigger> apexJobs = [SELECT Id FROM CronTrigger where EndTime=null and CronJobDetail.JobType='7' limit 150];
        for (CronTrigger job : apexJobs) {
            System.abortJob(job.Id);
        }
        init();
        setSuccessMessage('Total ' + apexJobs.size() + ' apex jobs were deleted from Scheduled Jobs page');
        return null;
    }

    //Schedules all apex jobs. If there were already scheduled, it deletes them first and then reschedule them.
    public PageReference scheduleApexJobs() {
        deleteScheduledJobs();
        if (!Test.isRunningTest()) {
            //VendisysUtil.scheduleAllJobs();     
        }
        init();
        List<CronTrigger> apexJobs = [SELECT Id FROM CronTrigger where EndTime=null and CronJobDetail.JobType='7' limit 150];
        setSuccessMessage('Total ' + apexJobs.size() + ' apex jobs were scheduled. To view the list of jobs, visit the ' +
                '<a href="/08e?setupid=ScheduledJobs">Scheduled Jobs</a> page.');
        return null;
    }
    

    /* PRIVATE METHODS */
    
    private void setSuccessMessage(String msg) {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, msg));
    }

    private void init() {
        this.currentlyRunningJobs = [SELECT count() FROM CronTrigger where EndTime=null and CronJobDetail.JobType='7' limit :MAX_JOBS];
        this.expectedJobs = 0;
    }
}