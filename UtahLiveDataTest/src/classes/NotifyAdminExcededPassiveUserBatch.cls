global with sharing class NotifyAdminExcededPassiveUserBatch  extends GNT.BatchApexHandler {
    global override String getQuery() {
    	return 'select ide from User where GNT__GGUserTpe = \'Passive\'';
    }
    
    global override void execute(List<SObject> scope1){
	     try{
	     	
	     }catch(Exception ex) {
	     	
	     }
     }
     
}