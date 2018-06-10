global with sharing class ViewPaymentTermConditionHandler extends GNT.FlexTableActionHandler {
	public ViewPaymentTermConditionHandler() {
		
	}
	global override Map<String,Object> clickHandler() {
        Map<String,Object> resultMap = new Map<String,Object>();
        String ns = AppUtils.getNamespacePrefix(); 
        Id grantId = urlParams.get('grantId');
        Id gId = urlParams.get('id');
       	String grntId ='';
        List<TermCondition__c> tcs = new List<TermCondition__c>();
        if(gId != null) {
        	 tcs = [SELECT Grant__c,Id FROM TermCondition__c WHERE Id =: gId];
        	 grntId = tcs[0].Grant__c;
        }
        
        if(grantId != null) {
        	String PageReferenceURL = '/apex/'+ns+'GrantView?id='+grantId;
        	resultMap.put('PageReference',PageReferenceURL);
        }
        else {
        	String PageReferenceURL = '/apex/'+ns+'GrantView?id='+grntId;
        	resultMap.put('PageReference',PageReferenceURL);
        }
		return resultMap;
    }
}