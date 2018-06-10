global with sharing class NewPerformanceResultHandler extends GNT.FlexTableActionHandler {
    
    global override Map<String,Object> clickHandler(){
        SavePoint sp = Database.setSavepoint();
        Map<String,Object> resultMap = new Map<String,Object> ();
        String progressReportResultId = urlParams.get('id');
        String type = urlParams.get('type');
        Id userId = Userinfo.getProfileId();

        String profileName = [select Name from Profile where id =: userId limit 1][0].Name;
        if(true) {

        }
            
        return resultMap;
        
    }
}