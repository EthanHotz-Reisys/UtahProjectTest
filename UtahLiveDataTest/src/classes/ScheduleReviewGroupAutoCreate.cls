/****************************************************************************************************
This class schedules the creation of two records in Review Group when the announcement is 
past the close date.
****************************************************************************************************
Audit History
****************************************************************************************************
4-30-2014       Hafsa Syed      Created
05-07-2014      Prem Pal        Updated
*****************************************************************************************************
*/


global class ScheduleReviewGroupAutoCreate implements Schedulable { 

    global void execute(SchedulableContext sc) {
       //1. Create review groups for announcement that have crossed deadline
        ReviewTasksHandler rtHandler = new ReviewTasksHandler();
        rtHandler.insertReviewTasks(); 
        //2. Process all terms and conditions and create tasks for external users
    //    TermConditionTasksBatchProcessHandler tcTasksHandler  = new TermConditionTasksBatchProcessHandler();
     //   ID termsCondTaskBatchJobId = database.executebatch(tcTasksHandler);                
    }

    global static void scheduleJob(){
        String cronExp = '0 0 2 * * ?'; /* This expression is used to run the scheduled job everyday at 2 AM */
        System.schedule('ReviewGroupAutoCreateJob', cronExp, new ScheduleReviewGroupAutoCreate());  
    }
}