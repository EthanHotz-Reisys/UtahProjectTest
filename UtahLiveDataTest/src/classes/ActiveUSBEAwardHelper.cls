global with sharing class ActiveUSBEAwardHelper extends GNT.DynamicLayoutActionRedirect{
    global override PageReference whenClicked(){
        Savepoint sp = Database.setSavePoint();
        try{
            String recordId = ApexPages.CurrentPage().getParameters().get('id');
            Award__c award = [SELECT Id, Name, Grant__c, Status__c, Grant__r.Program__r.AwardLetterRequired__c, Grant__r.Program__r.FunderType__c, Grant__r.InternalOrganization__c FROM Award__c WHERE Id = :recordId];
            List<Award__c> oldActiveAward = new List<Award__c>([SELECT Id, Name FROM Award__c WHERE Grant__c = :award.Grant__c AND Status__c = 'Activated']);
            award.Status__c = 'Activated';
            update award;

            List<AwardFINETCode__c> oldAfcList = new List<AwardFINETCode__c>();
            if(oldActiveAward.size() != 0){
                oldAfcList = [SELECT Id, AwardFINETCodeKeyFormula__c FROM AwardFINETCode__c WHERE Award__c = :oldActiveAward[0].Id];
            }
            List<AwardFINETCode__c> newAfcList = [SELECT Id, AwardFINETCodeKeyFormula__c FROM AwardFINETCode__c WHERE Award__c = :award.Id];
            
            List<AwardFINETCode__c> awardLetterList = new List<AwardFINETCode__c>();

            Set<String> oldAfcKeySet = new Set<String>();
            for(AwardFINETCode__c oldAfc : oldAfcList){
                oldAfcKeySet.add(oldAfc.AwardFINETCodeKeyFormula__c);
            }

            for(AwardFINETCode__c newAfc : newAfcList){
                if(!oldAfcKeySet.contains(newAfc.AwardFINETCodeKeyFormula__c)){
                    awardLetterList.add(newAfc);
                }
            }

            sendAwardLetter((new Map<Id, AwardFINETCode__c>(awardLetterList)).keySet());
            PageReference pf = Page.AwardView;
            pf.setRedirect(true);
            pf.getParameters().put('id', award.Id);
            return pf;
        }catch(Exception e){
            Database.rollback(sp);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, e.getMessage()));
            return null;
        }
    }

    @future(Callout = true)
    global static void sendAwardLetter(Set<Id> awardFinetCodeIdList){
        List<AwardFINETCode__c> awardCodeList = [SELECT Id, Name, Award__c, Award__r.Name, Award__r.Status__c, Award__r.Grant__r.Program__r.AwardLetterRequired__c, Award__r.Grant__r.Program__r.FunderType__c, Award__r.Grant__r.InternalOrganization__c FROM AwardFINETCode__c WHERE Id IN :awardFinetCodeIdList];
        List<Attachment> attList = new List<Attachment>();
        for(AwardFINETCode__c awardCode : awardCodeList){
            if(awardCode.Award__r.Grant__r.Program__r.AwardLetterRequired__c == 'Yes'){
                PageReference pdf = null;
                if(awardCode.Award__r.Grant__r.Program__r.FunderType__c == 'Federal'){
                    pdf = new PageReference('/apex/GNT__DynamicLayoutExport?packageId=&id=' + awardCode.Id + '&viewTemplateName=USBE Award Letter Federal Form&flexTableParam={\"programId\":\"' + awardCode.Id + '\",\"awardId\":\"' + awardCode.Id + '\"}');
                }else if(awardCode.Award__r.Grant__r.Program__r.FunderType__c == 'State'){
                    pdf = new PageReference('/apex/GNT__DynamicLayoutExport?packageId=&id=' + awardCode.Id + '&viewTemplateName=USBE Award Letter State Form&flexTableParam={\"programId\":\"' + awardCode.Id + '\",\"awardId\":\"' + awardCode.Id + '\"}');
                }

                if(pdf != null){ 
                    Blob body = pdf.getContent();
                    Attachment att = new Attachment(
                        Body = body,
                        Name = awardCode.Award__r.Name + '_Award Letter.pdf',
                        ParentId = awardCode.Id,
                        ContentType = 'application/pdf'
                    );
                    attList.add(att);
                }
            }
        }

        if(attList.size() == 0) return;
        insert attList;

        /*
        List<Id> leaIds = new List<Id>();
        for(AwardFINETCode__c awardCode : awardCodeList){
            leaIds.add(awardCode.Award__r.Grant__r.InternalOrganization__c);
        }

        List<User> leaUsers = [SELECT Id, AccountId FROM User WHERE AccountId IN :leaIds AND IsActive = true];
        Map<String, List<User>> userMap = new Map<String, List<User>>();
        for(User u : leaUsers){
            if(userMap.get(u.AccountId) == null){
                List<User> ul = new List<User>();
                ul.add(u);
                userMap.put(u.AccountId, ul);
            }else{
                userMap.get(u.AccountId).add(u);
            }
        }
        */

        Map<Id, AwardFINETCode__c> awardCodeMap = new Map<Id, AwardFINETCode__c>([SELECT Id, Award__c, Award__r.Grant__r.GranteePOC__c, Award__r.Approver__c, Award__r.Application__r.OwnerId FROM AwardFINETCode__c WHERE Id IN :awardCodeList]);
        List<GNT.EmailFeeder> emails = new List<GNT.EmailFeeder>();
        for(Attachment att : attList){
          AwardFINETCode__c awardCode = awardCodeMap.get(att.ParentId);
          GNT.EmailFeeder email0 = new GNT.EmailFeeder().contextRecordId(awardCode.Award__c).template('Award_Activated').attachment(att.Id).TargetObjectId(awardCode.Award__r.Grant__r.GranteePOC__c);
          emails.add(email0);
          GNT.EmailFeeder email1 = new GNT.EmailFeeder().contextRecordId(awardCode.Award__c).template('Award_Activated').attachment(att.Id).TargetObjectId(awardCode.Award__r.Approver__c);
          emails.add(email1);
          GNT.EmailFeeder email2 = new GNT.EmailFeeder().contextRecordId(awardCode.Award__c).template('Award_Activated').attachment(att.Id).TargetObjectId(awardCode.Award__r.Application__r.OwnerId);
          emails.add(email2);
        }
        GNT.EmailFeeder.SendEmails(emails);
    }
}