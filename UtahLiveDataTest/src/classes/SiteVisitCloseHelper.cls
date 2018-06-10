global with sharing class SiteVisitCloseHelper extends GNT.DynamicLayoutActionRedirect {
    global override PageReference whenClicked() {
        String recordId = ApexPages.CurrentPage().getParameters().get('id');

        SiteVisit__c sv = [SELECT Id, Status__c, GrantAdministrator__c FROM SiteVisit__c WHERE Id=:recordId];

        sv.Status__c = 'Closed';
        update sv;

        List<Task> tasks = [SELECT WhatId,Status FROM Task where WhatId=:sv.Id and OwnerId =:sv.GrantAdministrator__c and Status = 'In Progress'];
        if (tasks != null && tasks.size() > 0) {
            for (Task t : tasks) {
                t.Status = 'Completed';
            }
            update tasks;
        }

        ApexPages.Message msg = new Apexpages.Message(ApexPages.Severity.INFO,'Site Visit successfully closed' );
        ApexPages.addmessage(msg);
        PageReference p = Page.SiteVisitView;
        p.getParameters().put('Id', sv.Id);
        p.setRedirect(true);
        return p;
    }
}