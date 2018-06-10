public with sharing class TermConditionViewRedirectCtrl {
	public TermConditionViewRedirectCtrl() {
		
	}

	public PageReference redirect() {
		Id termConditionId = ApexPages.CurrentPage().getParameters().get('termConditionId');
		PageReference pr = new PageReference('/apex/'+AppUtils.getNamespacePrefix()+'TermConditionView?id='+termConditionId);
		return pr;
	}
}