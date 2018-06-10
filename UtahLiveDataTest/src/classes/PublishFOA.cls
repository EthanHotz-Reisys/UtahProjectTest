global with sharing class PublishFOA extends GNT.DynamicLayoutActionRedirect {

    global override PageReference whenClicked() {

        Id recordId = apexpages.currentpage().getparameters().get('id');
        List<String> errors = new List<String>();
        try {
            Savepoint sp = Database.setSavepoint();
            Announcement__c ann = [Select Id, Name, OrganizationName__c, FundingOppURL__c, AnnouncementType__c, FOAPublicationDate__c, PreApplicationNeeded__c, FOAStatus__c, RFAStatus__c, Status__c from Announcement__c where id = : recordId Limit 1];
            List<RolesAndResponsibilities__c> rrList = new List<RolesAndResponsibilities__c>();
            if (ann.OrganizationName__c == 'UOVC') {
                rrList = [Select Id, Name__c from RolesAndResponsibilities__c where Announcement__c = :ann.Id and (BusinessRole__c LIKE '%Approver%' OR BusinessRole__c IN ('Owner')) and Name__c = :UserInfo.getUserId()];
            }


            else if (ann.OrganizationName__c == 'USBE') {
                Id user = UserInfo.getUserId();
                User u = [Select id, ProfileName__c from User where id = : user];
                rrList = [Select Id, Name__c from RolesAndResponsibilities__c where Announcement__c = :ann.Id and (BusinessRole__c = 'Grants Manager'  OR BusinessRole__c IN ('Owner')) AND Name__c != null and Name__c = :UserInfo.getUserId() and Name__r.ProfileName__c='GMO'];
            }

            Date foaPublishDate = Date.valueOf(ann.FOAPublicationDate__c);
            boolean checkRequiredDoc = checkFOAPresent(recordId);

            if (rrList != null && rrList.size() == 0) {
                errors.add('You do not have sufficient access to Publish the Announcement');
                //errors.add(GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-89651'));
            }
            if (ann.FundingOppURL__c == null) {
                // errors.add('Please Enter External Announcement URL before publishing FOA');
                // errors.add(GNT.ErrorMessageHelper.fetchMessage('P51-GRNTR-40263'));
            }

            // Check App-Review Packages
            List<BusinessPackage__c> pkgList = [Select Id, PackageType__c from BusinessPackage__c where FundingOpportunity__c = :recordId and PackageType__c = 'Pre-Application'];

            if ( (ann.PreApplicationNeeded__c == 'Required' ||  ann.PreApplicationNeeded__c == 'Recommended') && (pkgList == null || pkgList.size() == 0)) {
                //errors.add('Please associate a Package with PreApplication Package Type for the Announcement.');
                errors.add(GNT.ErrorMessageHelper.fetchMessage('P51-GRNTR-65384'));
            }

            if (System.today() < foaPublishDate) {
                errors.add(GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-41945') + ' ' + foaPublishDate.format());
            }
            if (errors.size() > 0) {
                for (String error : errors) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, error));
                }
            } else {
                ann.FOAStatus__c = 'Published';
                ann.Status__c = 'Published';
                ann.RFAStatus__c = 'Created';
                if (ann.RFAStatus__c == 'Published') {
                    ann.Status__c = 'Active';
                } else {
                    ann.Status__c = 'Published';
                }
                update ann ;

                // Send email notiications to all users
                notifyUsers(ann);

                //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Announcement published successfully.'));
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, GNT.ErrorMessageHelper.fetchMessage('P51-GRNTR-93993')));
                PageReference  pageref = Page.AnnouncementView;
                pageref.getParameters().put('Id', recordId);
                pageref.setRedirect(true);
                return pageref;
            }

        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        }
        return null;
    }

    private boolean checkFOAPresent(Id parentId) {
        List<GNT__AttachmentExtension__c> attachmentExt = [select GNT__Classification__c from GNT__AttachmentExtension__c where GNT__ParentId__c  like :parentId];
        Set<String> classifications = new Set<String>();
        for (GNT__AttachmentExtension__c attachmetExtn : attachmentExt) {
            classifications.add(attachmetExtn.GNT__Classification__c.toLowerCase().trim());
        }
        if (!classifications.contains('foa')) {
            return false;
        }
        return true;
    }

    private Boolean notifyUsers(Announcement__c announcement) {
        String[] toAddresses = new String[] {};
        List<Contact> contactList = new List<Contact>();
        if (announcement.AnnouncementType__c == 'Competitive') {
            // For Competitive Announcements
            contactList = [select Id, name, Email from Contact where Account.RecordType.DeveloperName = 'Recipient' and KeyContact__c = true and UserRole__c = 'Primary' and ReviewerStatus__c = 'Active'];
        } else if (announcement.AnnouncementType__c == 'Sole Source/Directed') {
            // For Sole Source/Directed Annoucements
            List<SoleSourceAwardRecipient__c> ssAwardRecipientList = [Select Id, Account__c from SoleSourceAwardRecipient__c where FundingOpportunity__c = : announcement.id];
            Set<Id> recipientIdSet = new Set<Id>();
            for (SoleSourceAwardRecipient__c ss : ssAwardRecipientList) {
                recipientIdSet.add(ss.Account__c);
            }
            contactList = [select Id, name, Email from Contact where Account.RecordType.DeveloperName = 'Recipient' and KeyContact__c = true and UserRole__c = 'Primary' and ReviewerStatus__c = 'Active' and Account.Id in :recipientIdSet ];
        } else {
            return false;
        }

        for (Contact ct : contactList) {
            toAddresses.add(ct.email);
        }
        EmailTemplate templateId = [Select id from EmailTemplate where developername = 'AnnouncementPublished'];
        Contact cont = [select id, Email from Contact where email <> null limit 1];
        Map<Id, String[]> recIdToAddressMap = new Map<Id, String[]> ();
        recIdToAddressMap.put(announcement.Id, toAddresses);
        try {
            // AppUtils.sendEmailUsingTemplate(templateId.Id, recIdToAddressMap, cont.Id, false);
        } catch (Exception exc) {
            system.debug(exc);
            //throw new CustomExceptions.RequiredException('An Error occured in notifying the Applicants');
            throw new CustomExceptions.RequiredException(GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-38725'));
        }
        return false;
    }
}