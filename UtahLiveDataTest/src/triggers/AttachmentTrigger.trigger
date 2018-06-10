trigger AttachmentTrigger on Attachment (after insert, after update) {

    if(trigger.isAfter && trigger.isInsert){
        Attachment att = trigger.new[0];
        String parentObjectName = att.parentId.getSObjectType().getDescribe().getName();
        system.debug('parentObjectName--------->>>'+parentObjectName);
        system.debug('att.Id--------->>>'+att.Id);
        if(parentObjectName.equalsIgnoreCase('account')){
            /*AttachmentExtension__c attachExt = new AttachmentExtension__c();
            attachExt = [SELECT Id,Name,ParentId__c,Classification__c FROM AttachmentExtension__c 
                            WHERE AttachmentId__c LIKE :att.Id AND Classification__c LIKE '%DUNS Certification%'];
            system.debug('attachExt--------->>>'+attachExt);*/
            //if(attachExt != null){
                List<Task> t = [SELECT Id,Status FROM Task WHERE WhatId = :att.parentId AND     GNT__TaskAction__c LIKE '%DUNS Certification%'];
                system.debug('t--------->>>'+t);
                if(t.size() > 0){
                    t[0].status = 'Completed';
                update t[0];
                }
            //}                                         
        }
    }
}