global with sharing class CreatePaymentRequest extends GNT.FlexTableActionHandler{
    
    public class TestException extends Exception {}
    
    global override Map<String,Object> clickHandler(){
        Savepoint sp = Database.setSavepoint();
        List<String> errors = new List<String>();
        Map<String,Object> resultMap = new Map<String,Object>();
        try{
            //system.debug('URL :: '+ApexPages.currentPage().getUrl());
            system.debug('urlParams :: '+urlParams);
            String awardId = null;
            awardId = urlParams.get('id');
            system.debug('awardId :: '+awardId);
            if(awardId == null){
                awardId = urlParams.get('awardId');
            }
            system.debug('awardId :: '+awardId );
            List<AmendmentRequest__c> amendment = [Select id from AmendmentRequest__c where Award__c =:awardId];
            SystemContextMethodsHelper SystemContextMethodsHelper = new SystemContextMethodsHelper();
            Award__c award = SystemContextMethodsHelper.getAward(awardId);
            boolean budgeterror = false;
            String programkey = award.Grant__r.Program__r.ProgramKey__c;
            List<String> previousprograms = new List<String>();
            if(award.GrantorOrganization__c == 'USBE'){
                if (programkey != null) {
                    String delims = '_+';
                    String[] tokens = programkey.split(delims);
                    String program = tokens[0];
                    for (Integer i = 1; i < (tokens.size() - 1); i++) {
                      program += '_' + tokens[i];
                    }
                    Integer year = Integer.valueOf(tokens[tokens.size() - 1]);
                    previousprograms.add(program + '_' + String.valueOf(year - 1));
                    previousprograms.add(program + '_' + String.valueOf(year - 2));
                }
                List<Award__c> awardlist = SystemContextMethodsHelper.getAwardsFromProgramKey(previousprograms);
                List<PaymentRequest__c> pendingwaiver = [SELECT Id FROM PaymentRequest__c WHERE Award__c =: awardId AND Type__c = 'Waiver'];
                Award__c waiveraward;
                
                for (Award__c awards : awardlist) {
                    if (awards.Waived__c == false && awards.RemainingBudget__c != 0) {
                        waiveraward = awards;
                        budgeterror = true;
                    }
                }
                if (budgeterror == true) {
                    PageReference p = Page.AwardView;
                    p.getParameters().put('id', awardId);
                    String awardurl = '<a href=\'' + URL.getSalesforceBaseUrl().toExternalForm() + p.getUrl() + '\'>Test</a>';
                    errors.add('Please use up or waive remaining funds in previous related grant: ' + awardurl);
                }
                if (award.BudgetRevisionInitiatedByUSBE__c == 'Indirect Change') {
                   errors.add('Please update indirect cost in award budget');
                   
                }
                if (pendingwaiver.size() > 0) {
                    errors.add('This award has been waived');
                }
            }
            if(amendment.size()>0 && award.GrantorOrganization__c == 'UOVC'){
                errors.add('You cannot request for payment when Amendment is in progress');
            }
            if (errors.size() > 0) {
                for(String error: errors){
                    resultMap.put('Error', error);
                }
            }
            else {
                PageReference p = Page.PaymentRequestEdit;
                p.getParameters().put('awardId', awardId);
                p.getParameters().put('type', 'Reimbursement');
                p.setRedirect(true);
                String pageUrl = p.getUrl();
                resultMap.put('PageReference', new PageReference(pageUrl));
            } 
            return resultMap;
        }
        catch(Exception e){
            Database.rollback(sp);
            resultMap.put('Message', e.getMessage());
            return resultMap;
        }
    }
}