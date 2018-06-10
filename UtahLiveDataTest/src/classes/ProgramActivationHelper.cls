global with sharing class ProgramActivationHelper extends GNT.DynamicLayoutActionRedirect { 
    global override PageReference whenClicked(){
        Savepoint sp = Database.setSavepoint();
        List<String> errors = new List<String>();  
        Decimal sumofFundingAccounts = 0, sumofFutureFunding = 0;
        try{
            Id recordId = apexpages.currentpage().getparameters().get('id');
            List<ProgramFundingAccount__c> programFAList = [Select Id, Name from ProgramFundingAccount__c where Program__c=: recordId];
            List<ProgramContacts__c> programContactList = [Select Id, Name from ProgramContacts__c where Program__c=: recordId];
            Program__c program = [Select Id,Name,Status__c,IsProjectServiceAreaneeded__c,FundedAmount__c,ExpectedFunding__c,Publisheddate__c, FunderType__c, ProgramPathway__c, DistrictCode__c, USBEIndirectCostRate__c, FederalAwardDate__c, FederalAwardingAgency__c from Program__c where Id =:recordId ];
            List<ProgramServiceArea__c>  programSAList = [Select Id,Name from ProgramServiceArea__c where Program__c =:recordId ];
           
            if(programFAList.isEmpty()){
            //errors.add('Please associate atleast one Funding Account');
            //errors.add(GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTE-16024'));
            }

            if(programContactList.isEmpty()){
            //errors.add('Please add atleast one Program Contact');
            errors.add(GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTE-75625'));     
            }

            if(program.IsProjectServiceAreaneeded__c=='Yes' && programSAList.isEmpty()){
             //errors.add('Please associate atleast one Program Service Area'); 
             errors.add(GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTE-88589'));    
            }
            
            if(errors.size() > 0){
                for(String error: errors){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, error));
                }
            }else{
                program.Status__c='Active';
                program.Publisheddate__c=System.today();
                update program;
                if(program.ProgramPathway__c == 'Application 1/12th' || program.ProgramPathway__c == 'Fed-Formula' || program.ProgramPathway__c == 'Fed-Competitive' || program.ProgramPathway__c == 'State-Competitive' || program.ProgramPathway__c == 'Lump-Sum-App'){
                    sendProgramAwardLetterAndCreateNewAward(program);
                }
                //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'The Program has been activated successfully.'));
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, GNT.ErrorMessageHelper.fetchMessage('M01-GRNTR-83576')));
                PageReference p = Page.ProgramView;
                p.getParameters().put('Id', program.Id);
                p.setRedirect(true);
                return p;
            }  
        }catch(Exception e){
            Database.rollback(sp);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            return null;
        }
        return null;
    }

    private void sendProgramAwardLetterAndCreateNewAward(Program__c program){
        List<AwardFINETCode__c> afcList = [SELECT Id, Name FROM AwardFINETCode__c WHERE Award__r.Grant__r.Program__c = :program.Id AND Award__r.Status__c = 'Activated'];
        List<Award__c> awardList = [SELECT Id, Name FROM Award__c WHERE Grant__r.Program__c = :program.Id AND Status__c = 'Activated'];
        Boolean isFedralKeyChange = (program.DistrictCode__c + program.USBEIndirectCostRate__c + program.FederalAwardDate__c + program.FederalAwardingAgency__c) == program.FederalOldKey__c ? false : true;
        Boolean isStateKeyChange = (program.DistrictCode__c + program.USBEIndirectCostRate__c) == program.StateOldKey__c ? false : true;
        if((program.FunderType__c == 'Federal' && isFedralKeyChange) || (program.FunderType__c == 'State' && isStateKeyChange)){
            program.FederalOldKey__c = program.DistrictCode__c + program.USBEIndirectCostRate__c + program.FederalAwardDate__c + program.FederalAwardingAgency__c;
            program.StateOldKey__c = program.DistrictCode__c + program.USBEIndirectCostRate__c;
            update program;
            ActiveUSBEAwardHelper.sendAwardLetter((new Map<Id, AwardFINETCode__c>(afcList)).keySet());
            CloneAwardHelper.deepCloneAwardList((new Map<Id, Award__c>(awardList)).keySet(), 'Activated');
        }
    }
}