global with sharing class RiskItemTriggerHelper extends GNT.TriggerHelper {
  
    global override void processBeforeInsert() {
          GNT.NameTemplateTriggerHelper.beforeInsert(); 
    }
}