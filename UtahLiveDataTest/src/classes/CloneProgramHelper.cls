global without sharing class CloneProgramHelper extends GNT.DynamicLayoutActionRedirect{
    public Id recordId;
    public Program__c currentRecord;
    public Program__c newRecord;
    public Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
    public String uniqueIdAPIName = 'InternalUniqueID__c';
    Decimal clonedCounter = 0;
    
    private void toggleTrigger(Boolean status){
        ProgramTriggerHelperUSBE.skipTrigger = status;
        ProgramTriggerHelperUOVC.skipTrigger = status;
        TermConditionTriggerHelper.skipTrigger = status;
        BusinessPackageTriggerHelper.skipTrigger = status;
        RolesAndRespTriggerHelperUSBE.skipTrigger = status;
        ReviewStepTemplateTriggerHelper.skipTrigger = status;
    }
    
    private String dynamicQuery(String SobjectApiName, String recordIds, String fieldID, String prefix){
        String uniqueIdAPIName = prefix + 'internaluniqueid__c';
        Map<String, Schema.SObjectField> fieldMap = schemaMap.get(SobjectApiName).getDescribe().fields.getMap();
        List<String> fieldNames = new List<String>(fieldMap.keyset());
        String tmp = String.join(fieldNames, ', ');
        String commaSeparatedFields = tmp.replace(uniqueIdAPIName + ', ', '');
        String query = 'select ' + commaSeparatedFields + ' from ' + SobjectApiName + ' where ' + fieldId + ' in: ' + recordIds;
        System.debug(query);
        return query;
    }
    
    private String dynamicQuery(String SobjectApiName, String recordIds, String fieldID){
        return dynamicQuery(SobjectApiName, recordIds, fieldID, '');
    }
    
    global override PageReference whenClicked() {
        toggleTrigger(true);
        Savepoint sp = Database.setSavepoint();
        Boolean HideSubmit = true;
        recordId = layoutHolder.getPrimarySObject().Id;
        try{
            String SobjectApiName = 'Program__c';
            Map<String, Schema.SObjectField> fieldMap = schemaMap.get(SobjectApiName).getDescribe().fields.getMap();
            String commaSeparatedFields = '';
            for(String fieldName : fieldMap.keyset()){
                if(!fieldName.equalsIgnorecase(uniqueIdAPIName) && !fieldName.equalsIgnorecase('ProgramKey__c') && !fieldName.equalsIgnorecase('Name')){
                    if(commaSeparatedFields == null || commaSeparatedFields == ''){
                        commaSeparatedFields = fieldName;
                    }else{
                        commaSeparatedFields = commaSeparatedFields + ', ' + fieldName;
                    }
                }
            }
            String query = 'select Account__r.Name, ' + commaSeparatedFields + ' from ' + SobjectApiName + ' where Id = \'' + recordId + '\'';
            currentRecord = Database.query(query);
            
            if (currentRecord.ClonedCounter__c == null) {
                currentRecord.ClonedCounter__c = 0;
            }
            clonedCounter = currentRecord.ClonedCounter__c;
            currentRecord.Cloned__c = true;
            newRecord = currentRecord.clone();
            newRecord.ClonedFrom__c = currentRecord.Name;
            newRecord.ClonedCounter__c = 0;
            if (clonedCounter == 0) {
                newRecord.ProgramName__c = currentRecord.ProgramName__c + ' (Copy)';
            } else {
                newRecord.ProgramName__c = currentRecord.ProgramName__c + ' (Copy ' + clonedCounter + ')';
            }
            newRecord.Status__c = 'Created';
            currentRecord.ClonedCounter__c += 1;
            update currentRecord;
            insert newRecord;
            
            SobjectApiName = 'ProgramContacts__c';
            fieldMap = schemaMap.get(SobjectApiName).getDescribe().fields.getMap();
            commaSeparatedFields = '';
            for(String fieldName : fieldMap.keyset()){
                if(!fieldName.equalsIgnorecase(uniqueIdAPIName)){
                    if(commaSeparatedFields == null || commaSeparatedFields == ''){
                        commaSeparatedFields = fieldName;
                    }else{
                        commaSeparatedFields = commaSeparatedFields + ', ' + fieldName;
                    }
                }
            }
            query = 'select ' + commaSeparatedFields + ' from ' + SobjectApiName + ' where Program__c = \'' + recordId + '\'';
            List<ProgramContacts__c> currentContacts = Database.query(query);
            List<ProgramContacts__c> contactslist = new List<ProgramContacts__c>();
            for(ProgramContacts__c contact : currentContacts){
                ProgramContacts__c newcontact = contact.clone();
                newcontact.Program__c = newRecord.id;
                contactslist.add(newcontact);
            }
            insert contactslist;
            
            SobjectApiName = 'ProgramFundingAccount__c';
            fieldMap = schemaMap.get(SobjectApiName).getDescribe().fields.getMap();
            commaSeparatedFields = '';
            for(String fieldName : fieldMap.keyset()){
                if(!fieldName.equalsIgnorecase(uniqueIdAPIName)){
                    if(commaSeparatedFields == null || commaSeparatedFields == ''){
                        commaSeparatedFields = fieldName;
                    }else{
                        commaSeparatedFields = commaSeparatedFields + ', ' + fieldName;
                    }
                }
            }
            query = 'select ' + commaSeparatedFields + ' from ' + SobjectApiName + ' where Program__c = \'' + recordId + '\'';
            List<ProgramFundingAccount__c> currentfundings = Database.query(query);
            List<ProgramFundingAccount__c> fundinglist = new List<ProgramFundingAccount__c>();
            for(ProgramFundingAccount__c funding : currentfundings){
                ProgramFundingAccount__c newfunding = funding.clone();
                newfunding.Program__c = newRecord.id;
                fundinglist.add(newfunding);
            }
            insert fundinglist;
            
            SobjectApiName = 'BudgetPeriod__c';
            fieldMap = schemaMap.get(SobjectApiName).getDescribe().fields.getMap();
            commaSeparatedFields = '';
            for(String fieldName : fieldMap.keyset()){
                if(!fieldName.equalsIgnorecase(uniqueIdAPIName)){
                    if(commaSeparatedFields == null || commaSeparatedFields == ''){
                        commaSeparatedFields = fieldName;
                    }else{
                        commaSeparatedFields = commaSeparatedFields + ', ' + fieldName;
                    }
                }
            }
            query = 'select ' + commaSeparatedFields + ' from ' + SobjectApiName + ' where Program__c = \'' + recordId + '\'';
            List<BudgetPeriod__c> currentbudgetperiodlist = Database.query(query);
            List<BudgetPeriod__c> budgetPeriodList = new List<BudgetPeriod__c>();
            for(BudgetPeriod__c budgetPeriod : currentbudgetperiodlist){
                BudgetPeriod__c newBudgetPeriod = budgetPeriod.clone();
                newBudgetPeriod.Program__c = newRecord.id;
                budgetPeriodList.add(newBudgetPeriod);
            }
            insert budgetPeriodList;
            
            SobjectApiName = 'ProjectCostByFundingSource__c';
            fieldMap = schemaMap.get(SobjectApiName).getDescribe().fields.getMap();
            commaSeparatedFields = '';
            for(String fieldName : fieldMap.keyset()){
                if(!fieldName.equalsIgnorecase(uniqueIdAPIName)){
                    if(commaSeparatedFields == null || commaSeparatedFields == ''){
                        commaSeparatedFields = fieldName;
                    }else{
                        commaSeparatedFields = commaSeparatedFields + ', ' + fieldName;
                    }
                }
            }
            query = 'select ' + commaSeparatedFields + ' from ' + SobjectApiName + ' where Program__c = \'' + recordId + '\'';
            List<ProjectCostByFundingSource__c> currentCosts = Database.query(query);
            List<ProjectCostByFundingSource__c> costlist = new List<ProjectCostByFundingSource__c>();
            for(ProjectCostByFundingSource__c cost : currentCosts){
                ProjectCostByFundingSource__c newcost = cost.clone();
                newcost.Program__c = newRecord.id;
                costlist.add(newcost);
            }
            insert costlist;
            
            SobjectApiName = 'ProgramBudgetCategory__c';
            fieldMap = schemaMap.get(SobjectApiName).getDescribe().fields.getMap();
            commaSeparatedFields = '';
            for(String fieldName : fieldMap.keyset()){
                if(!fieldName.equalsIgnorecase(uniqueIdAPIName)){
                    if(commaSeparatedFields == null || commaSeparatedFields == ''){
                        commaSeparatedFields = fieldName;
                    }else{
                        commaSeparatedFields = commaSeparatedFields + ', ' + fieldName;
                    }
                }
            }
            query = 'select ' + commaSeparatedFields + ' from ' + SobjectApiName + ' where Program__c = \'' + recordId + '\'';
            List<ProgramBudgetCategory__c> currentbudgetcategorylist = Database.query(query);
            List<ProgramBudgetCategory__c> budgetcategorylist = new List<ProgramBudgetCategory__c>();
            for(ProgramBudgetCategory__c budgetcategory : currentbudgetcategorylist){
                ProgramBudgetCategory__c newbudgetcategory = budgetcategory.clone();
                newbudgetcategory.Program__c = newRecord.id;
                budgetcategorylist.add(newbudgetcategory);
            }
            insert budgetcategorylist;
            
            SobjectApiName = 'TermCondition__c';
            fieldMap = schemaMap.get(SobjectApiName).getDescribe().fields.getMap();
            commaSeparatedFields = '';
            for(String fieldName : fieldMap.keyset()){
                if(!fieldName.equalsIgnorecase(uniqueIdAPIName)){
                    if(commaSeparatedFields == null || commaSeparatedFields == ''){
                        commaSeparatedFields = fieldName;
                    }else{
                        commaSeparatedFields = commaSeparatedFields + ', ' + fieldName;
                    }
                }
            }
            query = 'select ' + commaSeparatedFields + ' from ' + SobjectApiName + ' where Program__c = \'' + recordId + '\'';
            List<TermCondition__c> currenttermconditions = Database.query(query);
            List<TermCondition__c> termconditionlist = new List<TermCondition__c>();
            for(TermCondition__c termcondition : currenttermconditions){
                TermCondition__c newtermcondition = termcondition.clone();
                newtermcondition.Program__c = newRecord.id;
                termconditionlist.add(newtermcondition);
            }
            insert termconditionlist;
            
            SobjectApiName = 'JXPrograms__c';
            fieldMap = schemaMap.get(SobjectApiName).getDescribe().fields.getMap();
            commaSeparatedFields = '';
            for(String fieldName : fieldMap.keyset()){
                if(!fieldName.equalsIgnorecase(uniqueIdAPIName)){
                    if(commaSeparatedFields == null || commaSeparatedFields == ''){
                        commaSeparatedFields = fieldName;
                    }else{
                        commaSeparatedFields = commaSeparatedFields + ', ' + fieldName;
                    }
                }
            }
            query = 'select ' + commaSeparatedFields + ' from ' + SobjectApiName + ' where StateProgram__c = \'' + recordId + '\'';
            List<JXPrograms__c> currentjxprograms = Database.query(query);
            List<JXPrograms__c> jxprogramlist = new List<JXPrograms__c>();
            for(JXPrograms__c jxprogram : currentjxprograms){
                JXPrograms__c newjxprogram = jxprogram.clone();
                newjxprogram.StateProgram__c = newRecord.id;
                jxprogramlist.add(newjxprogram);
            }
            insert jxprogramlist;
            
            SobjectApiName = 'ProgramServiceArea__c';
            fieldMap = schemaMap.get(SobjectApiName).getDescribe().fields.getMap();
            commaSeparatedFields = '';
            for(String fieldName : fieldMap.keyset()){
                if(!fieldName.equalsIgnorecase(uniqueIdAPIName)){
                    if(commaSeparatedFields == null || commaSeparatedFields == ''){
                        commaSeparatedFields = fieldName;
                    }else{
                        commaSeparatedFields = commaSeparatedFields + ', ' + fieldName;
                    }
                }
            }
            query = 'select ' + commaSeparatedFields + ' from ' + SobjectApiName + ' where Program__c = \'' + recordId + '\'';
            List<ProgramServiceArea__c> currentservices = Database.query(query);
            List<ProgramServiceArea__c> servicelist = new List<ProgramServiceArea__c>();
            for(ProgramServiceArea__c service : currentservices){
                ProgramServiceArea__c newservice = service.clone();
                newservice.Program__c = newRecord.id;
                servicelist.add(newservice);
            }
            insert servicelist;
            
            SobjectApiName = 'BusinessPackage__c';
            fieldMap = schemaMap.get(SobjectApiName).getDescribe().fields.getMap();
            commaSeparatedFields = '';
            for(String fieldName : fieldMap.keyset()){
                if(!fieldName.equalsIgnorecase(uniqueIdAPIName)){
                    if(commaSeparatedFields == null || commaSeparatedFields == ''){
                        commaSeparatedFields = fieldName;
                    }else{
                        commaSeparatedFields = commaSeparatedFields + ', ' + fieldName;
                    }
                }
            }
            query = 'select ' + commaSeparatedFields + ' from ' + SobjectApiName + ' where Program__c = \'' + recordId + '\'';
            List<BusinessPackage__c> currentbusinesspackages = Database.query(query);
            List<BusinessPackage__c> businesspackagelist = new List<BusinessPackage__c>();
            for(BusinessPackage__c businesspackage : currentbusinesspackages){
                BusinessPackage__c newbusinesspackage = businesspackage.clone();
                newbusinesspackage.Program__c = newRecord.id;
                businesspackagelist.add(newbusinesspackage);
            }
            insert businesspackagelist;
            
            SobjectApiName = 'RolesAndResponsibilities__c';
            fieldMap = schemaMap.get(SobjectApiName).getDescribe().fields.getMap();
            commaSeparatedFields = '';
            for(String fieldName : fieldMap.keyset()){
                if(!fieldName.equalsIgnorecase(uniqueIdAPIName)){
                    if(commaSeparatedFields == null || commaSeparatedFields == ''){
                        commaSeparatedFields = fieldName;
                    }else{
                        commaSeparatedFields = commaSeparatedFields + ', ' + fieldName;
                    }
                }
            }
            query = 'select ' + commaSeparatedFields + ' from ' + SobjectApiName + ' where Announcement__c = null AND Application__c = null AND Grant__c = null AND Award__c = null AND Program__c = \'' + recordId + '\'';
            List<RolesAndResponsibilities__c> currentroles = Database.query(query);
            List<RolesAndResponsibilities__c> rolesandresplist = new List<RolesAndResponsibilities__c>();
            for(RolesAndResponsibilities__c rolesandresp : currentroles){
                RolesAndResponsibilities__c newroles = rolesandresp.clone();
                newroles.Program__c = newRecord.id;
                rolesandresplist.add(newroles);
            }
            
            SobjectApiName = 'Attachment';
            fieldMap = schemaMap.get(SobjectApiName).getDescribe().fields.getMap();
            commaSeparatedFields = '';
            for(String fieldName : fieldMap.keyset()){
                if(!fieldName.equalsIgnorecase(uniqueIdAPIName)){
                    if(commaSeparatedFields == null || commaSeparatedFields == ''){
                        commaSeparatedFields = fieldName;
                    }else{
                        commaSeparatedFields = commaSeparatedFields + ', ' + fieldName;
                    }
                }
            }
            query = 'select ' + commaSeparatedFields + ' from ' + SobjectApiName + ' where ParentId = \'' + recordId + '\'';
            List<Attachment> currentattachments = Database.query(query);
            List<Attachment> attachmentlist = new List<Attachment>();
            for(Attachment attachment : currentattachments){
                Attachment newattachment = attachment.clone();
                newattachment.ParentId = newRecord.id;
                attachmentlist.add(newattachment);
            }
            insert attachmentlist;
            
            SobjectApiName = 'GNT__AttachmentExtension__c';
            fieldMap = schemaMap.get(SobjectApiName).getDescribe().fields.getMap();
            commaSeparatedFields = '';
            for(String fieldName : fieldMap.keyset()){
                if(!fieldName.equalsIgnorecase('GNT__InternalUniqueID__c')){
                    if(commaSeparatedFields == null || commaSeparatedFields == ''){
                        commaSeparatedFields = fieldName;
                    }else{
                        commaSeparatedFields = commaSeparatedFields + ', ' + fieldName;
                    }
                }
            }
            query = 'select ' + commaSeparatedFields + ' from ' + SobjectApiName + ' where GNT__Classification__c != \'History\' AND GNT__ParentId__c = \'' + recordId + '\'';
            List<GNT__AttachmentExtension__c> currentattachmentextensions = Database.query(query);
            List<GNT__AttachmentExtension__c> attachmentextensionlist = new List<GNT__AttachmentExtension__c>();
            
            Map<Id,GNT__AttachmentExtension__c> attachmentmap = new Map<Id,GNT__AttachmentExtension__c>();
            for(GNT__AttachmentExtension__c attachmentextension : currentattachmentextensions){
                attachmentmap.put(attachmentextension.GNT__Attachment__c,attachmentextension);
            }
            
            Map<Id,Attachment> atttoattmap = new Map<Id,Attachment>();
            for (Attachment currentattachment : currentattachments){
                for (Attachment attachment : attachmentlist){
                    if (attachment.Body == currentattachment.Body){
                        atttoattmap.put(currentattachment.Id,attachment);
                    }
                }
            }
            for (Attachment currentattachment : currentattachments){
                Attachment newattachment = atttoattmap.get(currentattachment.Id);
                GNT__AttachmentExtension__c attachmentextension = attachmentmap.get(currentattachment.Id);
                if (attachmentextension != null){
                    GNT__AttachmentExtension__c newattachmentextension = attachmentextension.clone();
                    newattachmentextension.GNT__Attachment__c = newattachment.Id;
                    newattachmentextension.GNT__ParentId__c = newattachment.ParentId;
                    newattachmentextension.GNT__InternalUniqueID__c = null;
                    attachmentextensionlist.add(newattachmentextension);
                }
            }
            
            SobjectApiName = 'ReviewStepTemplate__c';
            fieldMap = schemaMap.get(SobjectApiName).getDescribe().fields.getMap();
            commaSeparatedFields = '';
            for(String fieldName : fieldMap.keyset()){
                if(!fieldName.equalsIgnorecase(uniqueIdAPIName)){
                    if(commaSeparatedFields == null || commaSeparatedFields == ''){
                        commaSeparatedFields = fieldName;
                    }else{
                        commaSeparatedFields = commaSeparatedFields + ', ' + fieldName;
                    }
                }
            }
            query = 'select ' + commaSeparatedFields + ' from ' + SobjectApiName + ' where Program__c = \'' + recordId + '\'';
            List<ReviewStepTemplate__c> currentreviewStepTemplates = Database.query(query);
            List<ReviewStepTemplate__c> reviewStepTemplateList = new List<ReviewStepTemplate__c>();
            for(ReviewStepTemplate__c reviewStepTemplate : currentreviewStepTemplates){
                ReviewStepTemplate__c  newReviewStepTemplate = reviewStepTemplate.clone();
                newReviewStepTemplate.Program__c = newRecord.Id;
                reviewStepTemplateList.add(newReviewStepTemplate);
            }
            insert reviewStepTemplateList;
            
            Set<Id> reviewstepIds = new Set<Id>();
            for (ReviewStepTemplate__c reviewstep : currentreviewStepTemplates){
                reviewstepIds.add(reviewstep.Id);
            }
            
            if (reviewstepIds.size() > 0){
                Map<Id,ReviewStepTemplate__c> reviewtoreviewmap = new Map<Id,ReviewStepTemplate__c>();
                Map<Id,List<ReviewPanelTemplate__c>> reviewmap = new Map<Id,List<ReviewPanelTemplate__c>>();
                for (ReviewStepTemplate__c currentreview : currentreviewStepTemplates){
                    for (ReviewStepTemplate__c review : reviewStepTemplateList){
                        if (currentreview.Name == review.Name){
                            reviewtoreviewmap.put(review.Id,currentreview);
                        }
                    }
                }
                
                SobjectApiName = 'ReviewPanelTemplate__c';
                fieldMap = schemaMap.get(SobjectApiName).getDescribe().fields.getMap();
                commaSeparatedFields = '';
                for(String fieldName : fieldMap.keyset()){
                    if(!fieldName.equalsIgnorecase(uniqueIdAPIName)){
                        if(commaSeparatedFields == null || commaSeparatedFields == ''){
                            commaSeparatedFields = fieldName;
                        }else{
                            commaSeparatedFields = commaSeparatedFields + ', ' + fieldName;
                        }
                    }
                }
                String idstring = '';
                for(Id record : reviewstepIds){
                    if (idstring == ''){
                        idstring = 'ReviewStepTemplate__c = \'' + record + '\'';
                    }else{
                        idstring = idstring + ' OR ReviewStepTemplate__c = \'' + record + '\'';
                    }
                }
                query = 'select ReviewStepTemplate__r.Program__r.GrantsManager__c, ReviewStepTemplate__r.Name, ' + commaSeparatedFields + ' from ' + SobjectApiName + ' where ' + idstring;
                List<ReviewPanelTemplate__c> currentreviewpanel = Database.query(query);
                
                for (ReviewPanelTemplate__c review : currentreviewpanel){
                    List<ReviewPanelTemplate__c> tmp = reviewmap.get(review.ReviewStepTemplate__c);
                    if(tmp == null){
                        tmp = new List<ReviewPanelTemplate__c>();
                    }
                    tmp.add(review);
                    reviewmap.put(review.ReviewStepTemplate__c,tmp);
                }
                List<ReviewPanelTemplate__c> reviewpanellist = new List<ReviewPanelTemplate__c>();
                for (ReviewStepTemplate__c reviewstep : reviewStepTemplateList){
                    ReviewStepTemplate__c currentreviewstep = reviewtoreviewmap.get(reviewstep.Id);
                    if (currentreviewstep != null){
                        List<ReviewPanelTemplate__c> reviewpanels = reviewmap.get(currentreviewstep.Id);
                        if (reviewpanels != null){
                            for (ReviewPanelTemplate__c reviewpanel : reviewpanels){
                                ReviewPanelTemplate__c newreviewpanel = reviewpanel.clone();
                                newreviewpanel.ReviewStepTemplate__c = reviewstep.Id;
                                reviewpanellist.add(newreviewpanel);
                            }
                        }
                    }
                }
                insert reviewpanellist;
                
                List<PanelUserTemplate__c> newReviewers = new List<PanelUserTemplate__c>();
                for (ReviewPanelTemplate__c reviewpanel : reviewpanellist){
                    if (reviewpanel.ReviewStepTemplate__r.Name == 'Pre-Screen Review'){
                        PanelUserTemplate__c newReviewer = new PanelUserTemplate__c();
                        newReviewer.Reviewer__c = reviewpanel.ReviewStepTemplate__r.Program__r.GrantsManager__c;
                        newReviewer.ReviewPanelTemplate__c = reviewpanel.Id;
                        newReviewers.add(newReviewer);
                    }
                }
                insert newReviewers;
            }
            
            if (currentRecord.Account__r.Name == 'USBE' && currentRecord.ProgramPathway__c.contains('Competitive')) {
                cloneAnnouncement(recordId, newRecord.Id, clonedCounter);
            }
            
            insert rolesandresplist;
            insert attachmentextensionlist;
        }
        catch(Exception e){
            Database.rollback(sp);
            ApexPages.addMessages(e);
            toggleTrigger(false);
            return null;
        }
        toggleTrigger(false);
        return new PageReference('/'+newRecord.id);
    }
    
    global void cloneAnnouncement(Id recordId, Id newRecord, Decimal clonedCounter) {
        AnnouncementTriggerHelper.skipTrigger = true;
        USBEAnnouncementTriggerHelper.skipTrigger = true;
        Set<Id> listIds = new Set<Id>();
        List<Announcement__c> newAnnList = new List<Announcement__c>();
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        String SobjectApiName = 'Announcement__c';
        Map<String, Schema.SObjectField> fieldMap = schemaMap.get(SobjectApiName).getDescribe().fields.getMap();
        String commaSeparatedFields = '';
        for(String fieldName : fieldMap.keyset()){
            if(!fieldName.equalsIgnorecase(uniqueIdAPIName)){
                if(commaSeparatedFields == null || commaSeparatedFields == ''){
                    commaSeparatedFields = fieldName;
                }else{
                    commaSeparatedFields = commaSeparatedFields + ', ' + fieldName;
                }
            }
        }
        String query = 'select ' + commaSeparatedFields + ' from ' + SobjectApiName + ' where Program__c = \'' + recordId + '\'';
        List<Announcement__c> currentAnnList = Database.query(query);
        
        if (currentAnnList.size() > 0){
            for (Announcement__c currentAnn : currentAnnList) {
                listIds.add(currentAnn.id);
            }
            
            SobjectApiName = 'Attachment';
            fieldMap = schemaMap.get(SobjectApiName).getDescribe().fields.getMap();
            commaSeparatedFields = '';
            for(String fieldName : fieldMap.keyset()){
                if(!fieldName.equalsIgnorecase(uniqueIdAPIName)){
                    if(commaSeparatedFields == null || commaSeparatedFields == ''){
                        commaSeparatedFields = fieldName;
                    }else{
                        commaSeparatedFields = commaSeparatedFields + ', ' + fieldName;
                    }
                }
            }
            String idstring = '';
            for(Id record : listIds){
                if (idstring == ''){
                    idstring = 'ParentId = \'' + record + '\'';
                }else{
                    idstring = idstring + ' OR ParentId = \'' + record + '\'';
                }
            }
            query = 'select ' + commaSeparatedFields + ' from ' + SobjectApiName + ' where ' + idstring;
            List<Attachment> currentattachmentlist = Database.query(query);
            
            SobjectApiName = 'GNT__AttachmentExtension__c';
            fieldMap = schemaMap.get(SobjectApiName).getDescribe().fields.getMap();
            commaSeparatedFields = '';
            for(String fieldName : fieldMap.keyset()){
                if(!fieldName.equalsIgnorecase('GNT__InternalUniqueID__c')){
                    if(commaSeparatedFields == null || commaSeparatedFields == ''){
                        commaSeparatedFields = fieldName;
                    }else{
                        commaSeparatedFields = commaSeparatedFields + ', ' + fieldName;
                    }
                }
            }
            idstring = '';
            for(Id record : listIds){
                if (idstring == ''){
                    idstring = 'GNT__ParentId__c = \'' + record + '\'';
                }else{
                    idstring = idstring + ' OR GNT__ParentId__c = \'' + record + '\'';
                }
            }
            query = 'select ' + commaSeparatedFields + ' from ' + SobjectApiName + ' where GNT__Classification__c != \'History\' AND (' + idstring + ')';
            List<GNT__AttachmentExtension__c> currentattachmentextensionlist = Database.query(query);
            
            SobjectApiName = 'RolesAndResponsibilities__c';
            fieldMap = schemaMap.get(SobjectApiName).getDescribe().fields.getMap();
            commaSeparatedFields = '';
            for(String fieldName : fieldMap.keyset()){
                if(!fieldName.equalsIgnorecase(uniqueIdAPIName)){
                    if(commaSeparatedFields == null || commaSeparatedFields == ''){
                        commaSeparatedFields = fieldName;
                    }else{
                        commaSeparatedFields = commaSeparatedFields + ', ' + fieldName;
                    }
                }
            }
            idstring = '';
            for(Id record : listIds){
                if (idstring == ''){
                    idstring = 'Announcement__c = \'' + record + '\'';
                }else{
                    idstring = idstring + ' OR Announcement__c = \'' + record + '\'';
                }
            }
            query = 'select ' + commaSeparatedFields + ' from ' + SobjectApiName + ' where isActiveUser__c = true AND Program__c = null AND Application__c = null AND Grant__c = null AND Award__c = null AND (' + idstring + ')';
            List<RolesAndResponsibilities__c> currentrolelist = Database.query(query);
            
            SobjectApiName = 'TermCondition__c';
            fieldMap = schemaMap.get(SobjectApiName).getDescribe().fields.getMap();
            commaSeparatedFields = '';
            for(String fieldName : fieldMap.keyset()){
                if(!fieldName.equalsIgnorecase(uniqueIdAPIName)){
                    if(commaSeparatedFields == null || commaSeparatedFields == ''){
                        commaSeparatedFields = fieldName;
                    }else{
                        commaSeparatedFields = commaSeparatedFields + ', ' + fieldName;
                    }
                }
            }
            idstring = '';
            for(Id record : listIds){
                if (idstring == ''){
                    idstring = 'Announcement__c = \'' + record + '\'';
                }else{
                    idstring = idstring + ' OR Announcement__c = \'' + record + '\'';
                }
            }
            query = 'select ' + commaSeparatedFields + ' from ' + SobjectApiName + ' where ' + idstring;
            List<TermCondition__c> currenttermconditionlist = Database.query(query);
            
            SobjectApiName = 'BudgetPeriod__c';
            fieldMap = schemaMap.get(SobjectApiName).getDescribe().fields.getMap();
            commaSeparatedFields = '';
            for(String fieldName : fieldMap.keyset()){
                if(!fieldName.equalsIgnorecase(uniqueIdAPIName)){
                    if(commaSeparatedFields == null || commaSeparatedFields == ''){
                        commaSeparatedFields = fieldName;
                    }else{
                        commaSeparatedFields = commaSeparatedFields + ', ' + fieldName;
                    }
                }
            }
            idstring = '';
            for(Id record : listIds){
                if (idstring == ''){
                    idstring = 'FundingOpportunity__c = \'' + record + '\'';
                }else{
                    idstring = idstring + ' OR FundingOpportunity__c = \'' + record + '\'';
                }
            }
            query = 'select ' + commaSeparatedFields + ' from ' + SobjectApiName + ' where ' + idstring;
            List<BudgetPeriod__c> currentbudgetperiodlist = Database.query(query);
            
            SobjectApiName = 'FundingOpportunityBudgetCategory__c';
            fieldMap = schemaMap.get(SobjectApiName).getDescribe().fields.getMap();
            commaSeparatedFields = '';
            for(String fieldName : fieldMap.keyset()){
                if(!fieldName.equalsIgnorecase(uniqueIdAPIName)){
                    if(commaSeparatedFields == null || commaSeparatedFields == ''){
                        commaSeparatedFields = fieldName;
                    }else{
                        commaSeparatedFields = commaSeparatedFields + ', ' + fieldName;
                    }
                }
            }
            idstring = '';
            for(Id record : listIds){
                if (idstring == ''){
                    idstring = 'FundingOpportunity__c = \'' + record + '\'';
                }else{
                    idstring = idstring + ' OR FundingOpportunity__c = \'' + record + '\'';
                }
            }
            query = 'select ' + commaSeparatedFields + ' from ' + SobjectApiName + ' where ' + idstring;
            List<FundingOpportunityBudgetCategory__c> currentbudgetcategorylist = Database.query(query);
            
            SobjectApiName = 'ReviewStepTemplate__c';
            fieldMap = schemaMap.get(SobjectApiName).getDescribe().fields.getMap();
            commaSeparatedFields = '';
            for(String fieldName : fieldMap.keyset()){
                if(!fieldName.equalsIgnorecase(uniqueIdAPIName)){
                    if(commaSeparatedFields == null || commaSeparatedFields == ''){
                        commaSeparatedFields = fieldName;
                    }else{
                        commaSeparatedFields = commaSeparatedFields + ', ' + fieldName;
                    }
                }
            }
            idstring = '';
            for(Id record : listIds){
                if (idstring == ''){
                    idstring = 'Announcement__c = \'' + record + '\'';
                }else{
                    idstring = idstring + ' OR Announcement__c = \'' + record + '\'';
                }
            }
            query = 'select ' + commaSeparatedFields + ' from ' + SobjectApiName + ' where ' + idstring;
            List<ReviewStepTemplate__c> currentreviewStepTemplates = Database.query(query);
            
            Set<Id> reviewstepIds = new Set<Id>();
            for (ReviewStepTemplate__c reviewstep : currentreviewStepTemplates){
                reviewstepIds.add(reviewstep.Id);
            }
            SobjectApiName = 'ReviewPanelTemplate__c';
            fieldMap = schemaMap.get(SobjectApiName).getDescribe().fields.getMap();
            commaSeparatedFields = '';
            for(String fieldName : fieldMap.keyset()){
                if(!fieldName.equalsIgnorecase(uniqueIdAPIName)){
                    if(commaSeparatedFields == null || commaSeparatedFields == ''){
                        commaSeparatedFields = fieldName;
                    }else{
                        commaSeparatedFields = commaSeparatedFields + ', ' + fieldName;
                    }
                }
            }
            idstring = '';
            for(Id record : reviewstepIds){
                if (idstring == ''){
                    idstring = 'ReviewStepTemplate__c = \'' + record + '\'';
                }else{
                    idstring = idstring + ' OR ReviewStepTemplate__c = \'' + record + '\'';
                }
            }
            query = 'select ReviewStepTemplate__r.Program__r.GrantsManager__c, ReviewStepTemplate__r.Name, ' + commaSeparatedFields + ' from ' + SobjectApiName + ' where ' + idstring;
            List<ReviewPanelTemplate__c> currentreviewpanel = Database.query(query);
            
            for (Announcement__c currentAnn : currentAnnList) {
                Announcement__c newAnn = currentAnn.clone();
                newAnn.Program__c = newRecord;
                newAnn.ClonedFrom__c = currentAnn.Name;
                newAnn.Status__c = 'Created';
                newAnn.FOAStatus__c = 'Created';
                newAnn.FOAPublicationDate__c = null;
                newAnn.ApplicationDeadlineWithDateTime__c = null;
                newAnn.EstimatedProjectPeriodStartDate__c = null;
                newAnn.EstimatedProjectPeriodEndDate__c = null;
                newAnn.FOAReviews__c = 0;
                if (clonedCounter == 0) {
                    newAnn.AnnouncementName__c = currentAnn.AnnouncementName__c + ' (Copy)';
                } else {
                    newAnn.AnnouncementName__c = currentAnn.AnnouncementName__c + ' (Copy ' + clonedCounter + ')';
                }
                newAnnList.add(newAnn);
            }
            insert newAnnList;
            
            Map<String,Announcement__c> announcementmap = new Map<String,Announcement__c>();
            for (Announcement__c newAnn : newAnnList){
                announcementmap.put(newAnn.ClonedFrom__c,newAnn);
            }
            
            Map<Id,List<Attachment>> attachmentmap = new Map<Id,List<Attachment>>();
            for (Attachment currentattachment : currentattachmentlist){
                List<Attachment> tmp = attachmentmap.get(currentattachment.ParentId);
                if (tmp == null){
                    tmp = new List<Attachment>();
                    attachmentmap.put(currentattachment.ParentId,tmp);
                }
                tmp.add(currentattachment);
            }
            
            Map<Id,List<RolesAndResponsibilities__c>> rolemap = new Map<Id,List<RolesAndResponsibilities__c>>();
            for (RolesAndResponsibilities__c currentrole : currentrolelist){
                List<RolesAndResponsibilities__c> tmp = rolemap.get(currentrole.Announcement__c);
                if (tmp == null){
                    tmp = new List<RolesAndResponsibilities__c>();
                    rolemap.put(currentrole.Announcement__c,tmp);
                }
                tmp.add(currentrole);
            }
            
            Map<Id,List<TermCondition__c>> termconditionmap = new Map<Id,List<TermCondition__c>>();
            for (TermCondition__c currenttermcondition : currenttermconditionlist){
                List<TermCondition__c> tmp = termconditionmap.get(currenttermcondition.Announcement__c);
                if (tmp == null){
                    tmp = new List<TermCondition__c>();
                    termconditionmap.put(currenttermcondition.Announcement__c,tmp);
                }
                tmp.add(currenttermcondition);
            }
            
            Map<Id,List<BudgetPeriod__c>> budgetperiodmap = new Map<Id,List<BudgetPeriod__c>>();
            for (BudgetPeriod__c currentbudgetperiod : currentbudgetperiodlist){
                List<BudgetPeriod__c> tmp = budgetperiodmap.get(currentbudgetperiod.FundingOpportunity__c);
                if (tmp == null){
                    tmp = new List<BudgetPeriod__c>();
                    budgetperiodmap.put(currentbudgetperiod.FundingOpportunity__c,tmp);
                }
                tmp.add(currentbudgetperiod);
            }
            
            Map<Id,List<FundingOpportunityBudgetCategory__c>> budgetcategorymap = new Map<Id,List<FundingOpportunityBudgetCategory__c>>();
            for (FundingOpportunityBudgetCategory__c currentbudgetcategory : currentbudgetcategorylist){
                List<FundingOpportunityBudgetCategory__c> tmp = budgetcategorymap.get(currentbudgetcategory.FundingOpportunity__c);
                if (tmp == null){
                    tmp = new List<FundingOpportunityBudgetCategory__c>();
                    budgetcategorymap.put(currentbudgetcategory.FundingOpportunity__c,tmp);
                }
                tmp.add(currentbudgetcategory);
            }
            
            Map<Id,GNT__AttachmentExtension__c> attachmentextensionmap = new Map<Id,GNT__AttachmentExtension__c>();
            for(GNT__AttachmentExtension__c attachmentextension : currentattachmentextensionlist){
                attachmentextensionmap.put(attachmentextension.GNT__Attachment__c,attachmentextension);
            }
            
            Map<Id,List<ReviewStepTemplate__c>> reviewstepmap = new Map<Id,List<ReviewStepTemplate__c>>();
            for (ReviewStepTemplate__c currentreview : currentreviewStepTemplates){
                List<ReviewStepTemplate__c> tmp = reviewstepmap.get(currentreview.Announcement__c);
                if (tmp == null){
                    tmp = new List<ReviewStepTemplate__c>();
                    reviewstepmap.put(currentreview.Announcement__c,tmp);
                }
                tmp.add(currentreview);
            }
            
            List<Attachment> attachmentlist = new List<Attachment>();
            List<RolesAndResponsibilities__c> rolesandresplist = new List<RolesAndResponsibilities__c>();
            List<TermCondition__c> termconditionlist = new List<TermCondition__c>();
            List<BudgetPeriod__c> budgetperiodList = new List<BudgetPeriod__c>();
            List<ReviewStepTemplate__c> reviewStepTemplateList = new List<ReviewStepTemplate__c>();
            for (Announcement__c currentAnn : currentAnnList) {
                Announcement__c newAnn = announcementmap.get(currentAnn.Name);
                List<Attachment> currentattachments = attachmentmap.get(currentAnn.Id);
                List<RolesAndResponsibilities__c> currentroles = rolemap.get(currentAnn.Id);
                List<TermCondition__c> termconditions = termconditionmap.get(currentAnn.Id);
                List<ReviewStepTemplate__c> reviewsteps = reviewstepmap.get(currentAnn.Id);
                List<BudgetPeriod__c> budgetperiods = budgetperiodmap.get(currentAnn.Id);
                
                if (currentattachments != null){
                    for(Attachment attachment : currentattachments){
                        if (attachment.ParentId == currentAnn.id) {
                            Attachment newatt = attachment.clone();
                            newatt.ParentId = newAnn.id;
                            attachmentlist.add(newatt);
                        }
                    }
                }
                if (currentroles != null){
                    for(RolesAndResponsibilities__c role : currentroles){
                        if (role.Announcement__c == currentAnn.id) {
                            RolesAndResponsibilities__c newrole = role.clone();
                            newrole.Announcement__c = newAnn.id;
                            rolesandresplist.add(newrole);
                        }
                    }
                }
                if (termconditions != null){
                    for(TermCondition__c termcondition : termconditions){
                        TermCondition__c newtermcondition = termcondition.clone();
                        newtermcondition.Announcement__c = newAnn.Id;
                        termconditionlist.add(newtermcondition);
                    }
                }
                if (budgetperiods != null){
                    for(BudgetPeriod__c budgetperiod : budgetperiods){
                        BudgetPeriod__c  newbudgetperiod = budgetperiod.clone();
                        newbudgetperiod.FundingOpportunity__c = newAnn.Id;
                        budgetperiodList.add(newbudgetperiod);
                    }
                }
                if (currentreviewStepTemplates != null){
                    for(ReviewStepTemplate__c reviewStepTemplate : reviewsteps){
                        ReviewStepTemplate__c  newReviewStepTemplate = reviewStepTemplate.clone();
                        newReviewStepTemplate.Announcement__c = newAnn.Id;
                        reviewStepTemplateList.add(newReviewStepTemplate);
                    }
                }
            }
            insert attachmentlist;
            insert rolesandresplist;
            insert termconditionlist;
            insert budgetperiodList;
            insert reviewStepTemplateList;
            
            Map<Id,Attachment> atttoattmap = new Map<Id,Attachment>();
            for (Attachment currentattachment : currentattachmentlist){
                for (Attachment attachment : attachmentlist){
                    if (attachment.Body == currentattachment.Body){
                        atttoattmap.put(currentattachment.Id,attachment);
                    }
                }
            }
            Map<Id,BudgetPeriod__c> bptobpmap = new Map<Id,BudgetPeriod__c>();
            for (BudgetPeriod__c currentbp : currentbudgetperiodlist){
                for (BudgetPeriod__c bp : budgetperiodList){
                    if (bp.BudgetPeriod__c == currentbp.BudgetPeriod__c){
                        bptobpmap.put(currentbp.Id,bp);
                    }
                }
            }
            Map<Id,ReviewStepTemplate__c> reviewtoreviewmap = new Map<Id,ReviewStepTemplate__c>();
            for (ReviewStepTemplate__c currentreview : currentreviewStepTemplates){
                for (ReviewStepTemplate__c review : reviewStepTemplateList){
                    if (currentreview.Name == review.Name){
                        reviewtoreviewmap.put(review.Id,currentreview);
                    }
                }
            }
            
            Map<Id,List<ReviewPanelTemplate__c>> reviewmap = new Map<Id,List<ReviewPanelTemplate__c>>();
            for (ReviewPanelTemplate__c review : currentreviewpanel){
                List<ReviewPanelTemplate__c> tmp = reviewmap.get(review.ReviewStepTemplate__c);
                if(tmp == null){
                    tmp = new List<ReviewPanelTemplate__c>();
                }
                tmp.add(review);
                reviewmap.put(review.ReviewStepTemplate__c,tmp);
            }
            
            List<GNT__AttachmentExtension__c> attachmentextensionlist = new List<GNT__AttachmentExtension__c>();
            List<ReviewPanelTemplate__c> reviewpanellist = new List<ReviewPanelTemplate__c>();
            List<FundingOpportunityBudgetCategory__c> budgetcategorylist = new List<FundingOpportunityBudgetCategory__c>();
            for (Announcement__c currentAnn : currentAnnList) {
                Announcement__c newAnn = announcementmap.get(currentAnn.Name);
                List<ReviewStepTemplate__c> reviewsteps = reviewstepmap.get(currentAnn.Id);
                List<Attachment> currentattachments = attachmentmap.get(currentAnn.Id);
                List<FundingOpportunityBudgetCategory__c> currentbudgetcategories = budgetcategorymap.get(currentAnn.Id);
                
                if (currentattachments != null){
                    for (Attachment currentattachment : currentattachments){
                        Attachment newattachment = atttoattmap.get(currentattachment.Id);
                        GNT__AttachmentExtension__c attachmentextension = attachmentextensionmap.get(currentattachment.Id);
                        if (attachmentextension != null){
                            GNT__AttachmentExtension__c newattachmentextension = attachmentextension.clone();
                            newattachmentextension.GNT__Attachment__c = newattachment.Id;
                            newattachmentextension.GNT__ParentId__c = newattachment.ParentId;
                            newattachmentextension.GNT__InternalUniqueID__c = null;
                            attachmentextensionlist.add(newattachmentextension);
                        }
                    }
                }
                if (reviewsteps != null){
                    for (ReviewStepTemplate__c reviewstep : reviewsteps){
                        ReviewStepTemplate__c currentreviewstep = reviewtoreviewmap.get(reviewstep.Id);
                        if (currentreviewstep != null){
                            List<ReviewPanelTemplate__c> reviewpanels = reviewmap.get(currentreviewstep.Id);
                            if (reviewpanels != null){
                                for (ReviewPanelTemplate__c reviewpanel : reviewpanels){
                                    ReviewPanelTemplate__c newreviewpanel = reviewpanel.clone();
                                    newreviewpanel.ReviewStepTemplate__c = reviewstep.Id;
                                    reviewpanellist.add(newreviewpanel);
                                }
                            }
                        }
                    }
                }
                if(currentbudgetcategories != null){
                    for (FundingOpportunityBudgetCategory__c currentbudgetcategory : currentbudgetcategories){
                        BudgetPeriod__c bp = bptobpmap.get(currentbudgetcategory.BudgetPeriod__c);
                        FundingOpportunityBudgetCategory__c newbudgetcategory = currentbudgetcategory.clone();
                        newbudgetcategory.BudgetPeriod__c = bp.Id;
                        newbudgetcategory.FundingOpportunity__c = newAnn.Id;
                        budgetcategorylist.add(newbudgetcategory);
                    }
                }
            }
            insert attachmentextensionlist;
            insert reviewpanellist;
            insert budgetcategorylist;
            
            List<PanelUserTemplate__c> newReviewers = new List<PanelUserTemplate__c>();
            for (ReviewPanelTemplate__c reviewpanel : reviewpanellist){
                if (reviewpanel.ReviewStepTemplate__r.Name == 'Pre-Screen Review'){
                    PanelUserTemplate__c newReviewer = new PanelUserTemplate__c();
                    newReviewer.Reviewer__c = reviewpanel.ReviewStepTemplate__r.Program__r.GrantsManager__c;
                    newReviewer.ReviewPanelTemplate__c = reviewpanel.Id;
                    newReviewers.add(newReviewer);
                }
            }
            insert newReviewers;
        }
    }
}