global class DeleteScheduledApexJobsHelper extends GNT.FlexTableActionHandler {
       global override Map<String,Object> clickHandler(){
        Map<String,Object> returnMap = new Map<String,Object>();
        deleteScheduledJobs();
        
        returnMap.put('Message','Jobs were deleted');
        return returnMap;
       }
       
       public static void deleteScheduledJobs() {
        List<CronTrigger> apexJobs = [SELECT Id FROM CronTrigger where EndTime=null and CronJobDetail.JobType='7' limit 150];
        for (CronTrigger job : apexJobs) {
            System.abortJob(job.Id);
        }
    }
    
}