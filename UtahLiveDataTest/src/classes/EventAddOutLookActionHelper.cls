global with sharing class EventAddOutLookActionHelper extends GNT.DynamicLayoutActionStay{
public Id eventId {get;set;}
   global override String whenClicked(){ 
        Map<String,Object> resultMap = new Map<String,Object>();
        //eventId = urlParams.get('id'); 
        Id recordId = layoutHolder.getPrimarySObject().Id;
        Id eventId = ApexPages.CurrentPage().getParameters().get('id');
        //PageReference pg = new PageReference('/servlet/servlet.OutlookEvent?rnd=1483952072307&id=00U36000006XMmXEAW&_CONFIRMATIONTOKEN=VmpFPSxNakF4Tnkwd01TMHhNbFF3T0RvMU5Eb3pNaTR6TURkYSxZWTZTRGptbFE5RTBNV0NaN212WkF4LE0yRmhPR05t&common.udd.actions.ActionsUtilORIG_URI=%2Fservlet%2Fservlet.OutlookEvent');
        PageReference pg = new PageReference('https://ggpdev5-dev-ed.my.salesforce.com/servlet/servlet.OutlookEvent?rnd=1234567890123&id=00U36000006XMmXEAW');
        pg.setRedirect(true);
        return '';   
       }
}