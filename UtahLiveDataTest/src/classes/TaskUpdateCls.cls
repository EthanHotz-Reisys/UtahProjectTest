global class TaskUpdateCls extends GNT.FlexTableActionHandler {

    global override Map<String,Object> clickHandler(){
     	Map<String,Object> resultMap = new Map<String,Object>();
        try{
        	String ns = AppUtils.getNamespacePrefix(); 
            Id selectedRecordId = selectedRecordIds[0];
            List<Task> t = [select status from Task where id =: selectedRecordId and status = 'Not Started'];
            if(t!=null && t.size() > 0){
                t[0].status = 'In Progress';
                update t;
            }
            String PageReferenceURL = '/apex/'+ns+'TaskReviewRedirect?id='+selectedRecordId;
            resultMap.put('PageReference',PageReferenceURL);
	    	return resultMap;
        }catch(Exception e){
            return null;
        }
        
    
    }


}