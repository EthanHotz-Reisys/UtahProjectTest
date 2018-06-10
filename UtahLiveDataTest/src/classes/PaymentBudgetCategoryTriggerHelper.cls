/*
    This class has methods to execute methods related to Payment Budget Category Trigger
    **********************************************************
    Audit History
    **********************************************************
    2016-04-05  Ramu Loke       Created
    
    **********************************************************  
*/
global with sharing class PaymentBudgetCategoryTriggerHelper extends GNT.TriggerHelper{
    global static boolean skipTrigger = false;
    
    public override void processbeforeInsert() {
      // udpatePaymentYTDSpent();
    } 
    public override void processBeforeUpdate() {
        if (!skipTrigger) {
          // udpatePaymentYTDSpent();
           PopulateFundingAccount(Trigger.new);
           CheckBudgetValidations();
           updateBudget(Trigger.new);
        }
    } 
    public override void processAfterInsert(){
    }
    public override void processAfterUpdate() {
        if (!skipTrigger) {
           updateIndirect(Trigger.new);
           updatePaidAmount(Trigger.new);
        }
    }
    public override void processAfterDelete() {
        
    }
   
   /* to update YTD spent on payment rquest */ 
   private void udpatePaymentYTDSpent(){
        for(PaymentBudgetCategory__c pbc : (List<PaymentBudgetCategory__c >)trigger.new){
            if(pbc.PaymentStatus__c == 'Created' || pbc.PaymentStatus__c == 'Submitted for Approval'){
                pbc.YTDReimbursementPaid__c = pbc.AwardYTDReimbursementPaid__c;
            }
           /* if(pbc.DisallowanceReasons__c == '--None--'){
                pbc.DisallowanceReasons__c = '';
            } */
        }
    }
    
    
    private void CheckBudgetValidations(){
        List<ID> awardids = new List<ID>();
        List<AwardPaymentBudgetCategory__c> awdlivecatlist = new List<AwardPaymentBudgetCategory__c>();
        for(PaymentBudgetCategory__c paymentbudcat : (List<PaymentBudgetCategory__c>) Trigger.New){
              awardids.add((ID)paymentbudcat.AwardId__c);
            }
        awdlivecatlist = [select id,Name,Award__c,AwardedAmount__c,BudgetCategory__c,GrantProjectArea__c,YTDAdvanceApplied__c,
                               YTDAdvanceAvailable__c,YTDAdvancePaid__c,YTDReimbursementAvailable__c,YTDReimbursementPaid__c
                                                              from AwardPaymentBudgetCategory__c where Award__c IN :awardids];
        List<PaymentRequest__c> paymentreqlist = [select id,Name,Award__c,Type__c from PaymentRequest__c where Type__c = 'Advance' and Award__c IN :awardids];
        if(!awdlivecatlist.isEmpty()){
           for(PaymentBudgetCategory__c paymentbudcat : (List<PaymentBudgetCategory__c>) Trigger.New){
              for(AwardPaymentBudgetCategory__c awdbudcat : awdlivecatlist){
                 if((paymentbudcat.PaymentType__c == 'Reimbursement') && (paymentbudcat.GrantProjectArea__c == awdbudcat.GrantProjectArea__c) && (paymentbudcat.BudgetCategory__c == awdbudcat.BudgetCategory__c) 
                                                                                         && (paymentbudcat.AdvanceApplied__c > awdbudcat.YTDAdvanceAvailable__c)){
                        paymentbudcat.adderror('Advance Applied for Payment Request cannot be greater than YTD Advance Available in Payment Summary: ' + paymentbudcat.ServiceArea__c +': ' +paymentbudcat.BudgetCategoryName__c);
                    
                 }
                 ////
                 if((paymentbudcat.PaymentType__c == 'Reimbursement') && (paymentbudcat.GrantProjectArea__c == awdbudcat.GrantProjectArea__c) && (paymentbudcat.BudgetCategory__c == awdbudcat.BudgetCategory__c) 
                                                                                         && (paymentbudcat.AdvanceApplied__c > paymentbudcat.RequestedExpense__c)){
                        paymentbudcat.adderror('Advance Applied cannot be greater than Reimbursement Requested Amount: ' + paymentbudcat.ServiceArea__c +': ' +paymentbudcat.BudgetCategoryName__c);
                    
                 }
                 if((paymentbudcat.PaymentType__c == 'Reimbursement') && (paymentbudcat.GrantProjectArea__c == awdbudcat.GrantProjectArea__c) && (paymentbudcat.BudgetCategory__c == awdbudcat.BudgetCategory__c) 
                                                                                         && (paymentbudcat.DisallowedAmount__c> paymentbudcat.RequestedExpense__c)){
                        paymentbudcat.adderror('Disallowed Amount cannot be greater than Reimbursement Requested Amount: ' + paymentbudcat.ServiceArea__c +': ' +paymentbudcat.BudgetCategoryName__c);
                    
                 }
                 ////
                 if((paymentbudcat.PaymentType__c == 'Reimbursement') && (paymentbudcat.GrantProjectArea__c == awdbudcat.GrantProjectArea__c) && (paymentbudcat.BudgetCategory__c == awdbudcat.BudgetCategory__c) 
                                                                                         && (paymentbudcat.RequestedExpense__c > awdbudcat.YTDReimbursementAvailable__c)){
                        paymentbudcat.adderror('Reimbursement Requested Amount for Payment Request cannot be greater than Remaining Amount: ' + paymentbudcat.ServiceArea__c +':' +paymentbudcat.BudgetCategoryName__c);
                  }
                 
                }
              }
            }
            else{
                  for(PaymentBudgetCategory__c paymentbudcat : (List<PaymentBudgetCategory__c>) Trigger.New){
                    if(paymentreqlist.isEmpty() && paymentbudcat.AdvanceApplied__c > 0){
                        //paymentbudcat.adderror('Advance Applied Cannot be entered if you do not have any Advance Request for the Award');
                        paymentbudcat.addError(GNT.ErrorMessageHelper.fetchMessage('M01-GRNTR-38272'));
                 }
               }
            }
         }
         
     // Method to populate FundingAccount__c from AwardFundingAccount__c.
     
    private void PopulateFundingAccount(List<PaymentBudgetCategory__c> listpaybc){
        Set<Id> AwardfundingAccountIds = new Set<Id>();
        Map<Id,AwardfundingAccount__c> fundingaccntmap=  new Map<Id,AwardfundingAccount__c>();
        for (PaymentBudgetCategory__c paybc : listpaybc) {  
         if (paybc.AwardFundingAccount__c != null) {
            AwardfundingAccountIds.add(paybc.AwardFundingAccount__c);
           }
         }
         list<AwardFundingAccount__c> awdfalist = [select Id,FundingAccount__c from AwardfundingAccount__c where id IN:AwardfundingAccountIds];
         for(AwardfundingAccount__c awardfundingaccount:awdfalist){
            fundingaccntmap.put(awardfundingaccount.id,awardfundingaccount);
         }
         for (PaymentBudgetCategory__c paybc : listpaybc) {  
          if (paybc.AwardFundingAccount__c != null) {
             AwardFundingAccount__c awdfunaccnt = fundingaccntmap.get(paybc.AwardFundingAccount__c);
             paybc.FundingAccount__c = awdfunaccnt.FundingAccount__c;
           }
         }
         
    }
      
    //Method to update Budget Values in PaymentBudgetCategory__c
    private void updateBudget(List<PaymentBudgetCategory__c> listpaybc){
    	Set<Id> paymentIds = new Set<Id>();
    	for (PaymentBudgetCategory__c paybc : listpaybc) {
    		paymentIds.add(paybc.PaymentRequest__c);
    	}
    	List<PaymentRequest__c> payreqlist = [SELECT Id,OrganizationName__c FROM PaymentRequest__c WHERE Id IN: paymentIds];
    	Map<Id,List<PaymentBudgetCategory__c>> bcmap = new Map<Id,List<PaymentBudgetCategory__c>>();
    	for(PaymentBudgetCategory__c bc : listpaybc){
    		List<PaymentBudgetCategory__c >tmp = bcmap.get(bc.PaymentRequest__c);
    		if (tmp == null){
    			tmp = new List<PaymentBudgetCategory__c>();
    		}
    		tmp.add(bc);
    		bcmap.put(bc.PaymentRequest__c,tmp);
    	}
    	
    	for(PaymentRequest__c payreq : payreqlist){
    		List<PaymentBudgetCategory__c> bcs = bcmap.get(payreq.Id);
    		if (payreq.OrganizationName__c == 'UOVC'){
		        for (PaymentBudgetCategory__c paybc : bcs) {
		            paybc.RequestedExpense__c = paybc.Q1__c + paybc.Q2__c + paybc.Q3__c + paybc.Q4__c;
		        }
    		}
    	}
    }
    
    //Method to update Indirect Budget Values
    private void updateIndirect(List<PaymentBudgetCategory__c> listpaybc){
        Set<Id> payIds = new Set<Id>();
        for (PaymentBudgetCategory__c paybc : listpaybc){
        	payIds.add(paybc.PaymentRequest__c);
        }
        List<PaymentRequest__c> paymentreq = [SELECT Id, Grant__r.Application__r.IndirectCostPercentage__c, OrganizationName__c, USBELEACostRate__c, USBELEACostRate__r.RestrictedIndirectRate__c,
                                           USBELEACostRate__r.UnrestrictedIndirectRate__c,Award__r.ProgramBudgetTypeUSBE__c,Grant__r.Program__r.USBEIndirectCostRate__c FROM PaymentRequest__c WHERE Id IN: payIds];
        List<PaymentBudgetCategory__c> indirectbcList = [SELECT Id,PaymentRequest__c,Q1__c,Q2__c,Q3__c,Q4__c,RequestedExpense__c,AdminRequestedExpenditure__c FROM PaymentBudgetCategory__c
                                                         WHERE PaymentRequest__c IN: payIds AND RowNumber__c != '570' AND RowNumber__c != '580' AND RowNumber__c != '599' AND RowNumber__c != '204' AND RowNumber__c != '213'];
        Decimal indirectPercent = 0;
        
        Map<Id,List<PaymentBudgetCategory__c>> bcmap = new Map<Id,List<PaymentBudgetCategory__c>>();
        for (PaymentBudgetCategory__c paybc : indirectbclist){
        	List<PaymentBudgetCategory__c> tmp = bcmap.get(paybc.PaymentRequest__c);
        	if (tmp == null){
        		tmp = new List<PaymentBudgetCategory__c>();
        	}
        	tmp.add(paybc);
        	bcmap.put(paybc.PaymentRequest__c,tmp);
        }
        
        for (PaymentRequest__c payreq : paymentreq){
        	List<PaymentBudgetCategory__c> indirectList = bcmap.get(payreq.Id);
	        if (payreq.OrganizationName__c == 'USBE' && payreq.USBELEACostRate__c != null){
	            if (payreq.Grant__r.Program__r.USBEIndirectCostRate__c == 'Restricted') {
	                indirectPercent = payreq.USBELEACostRate__r.RestrictedIndirectRate__c / 100;
	            } else if (payreq.Grant__r.Program__r.USBEIndirectCostRate__c == 'Unrestricted'){
	                indirectPercent = payreq.USBELEACostRate__r.UnrestrictedIndirectRate__c / 100;
	            }
		        if (indirectPercent != 0){
			        Decimal indirectCurrent = 0;
			        for (PaymentBudgetCategory__c paybc : indirectList){
			        	indirectCurrent += paybc.RequestedExpense__c;
			        }
			        payreq.Indirect__c = (indirectCurrent * indirectPercent).setScale(2);
			        if (payreq.Award__r.ProgramBudgetTypeUSBE__c == 'CTE'){
				        Decimal adminCurrent = 0;
				        for (PaymentBudgetCategory__c paybc : indirectList){
				        	adminCurrent += paybc.AdminRequestedExpenditure__c;
				        }
				        payreq.AdminIndirect__c = (adminCurrent * indirectPercent).setScale(2);
			        }
		        }
	        } else if (payreq.OrganizationName__c == 'UOVC'){
	        	indirectPercent = payreq.Grant__r.Application__r.IndirectCostPercentage__c / 100;
	        	if (indirectPercent != 0){
			        Decimal indirectQ1 = 0;
			        Decimal indirectQ2 = 0;
			        Decimal indirectQ3 = 0;
			        Decimal indirectQ4 = 0;
			        for (PaymentBudgetCategory__c paybc : indirectList){
			            indirectQ1 += paybc.Q1__c;
			            indirectQ2 += paybc.Q2__c;
			            indirectQ3 += paybc.Q3__c;
			            indirectQ4 += paybc.Q4__c;
			        }
			        payreq.IndirectQ1__c = (indirectQ1 * indirectPercent).setScale(2);
			        payreq.IndirectQ2__c = (indirectQ2 * indirectPercent).setScale(2);
			        payreq.IndirectQ3__c = (indirectQ3 * indirectPercent).setScale(2);
			        payreq.IndirectQ4__c = (indirectQ4 * indirectPercent).setScale(2);
	        	}
	        }
        }
        update paymentreq;
    }
         
    // Method to update Paid Amount in Funding Account based on Request Amount added to Payment Budget Category.
      private void updatePaidAmount(List<PaymentBudgetCategory__c> listpaybc){
        Set<Id> fundingAccountIds = new Set<Id>();
        Map<id,double> fundingaccountMap = new Map<id,double> ();
        List<FundingAccount__c> funaccntstoupdate = new List<FundingAccount__c> ();
        for (PaymentBudgetCategory__c paybc : listpaybc) {  
         if (paybc.FundingAccount__c != null) {
            fundingAccountIds.add(paybc.FundingAccount__c);
           }
         }
        
         if(!fundingAccountIds.isEmpty()){
            for (AggregateResult ar : [select FundingAccount__c,sum(RequestedExpense__c) total
                                 from PaymentBudgetCategory__c where FundingAccount__c IN :fundingAccountIds 
                                 group by FundingAccount__c]){
            fundingaccountMap.put((Id)ar.get('FundingAccount__c'),(Double)ar.get('total'));
            }
        
            for(FundingAccount__c faccnt : [Select Id,Paid__c from FundingAccount__c where Id IN :fundingAccountIds]){
               Double Requestexpensesum = fundingaccountMap.get(faccnt.Id);
               faccnt.Paid__c = Requestexpensesum;
               funaccntstoupdate.add(faccnt);
            }
            update funaccntstoupdate;
            }
       }         
    }