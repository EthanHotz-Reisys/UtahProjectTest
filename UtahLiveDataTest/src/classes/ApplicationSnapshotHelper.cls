global without sharing class ApplicationSnapshotHelper {
    private Map<String, Schema.SObjectType> schemaMap;

    private void toggleTrigger(Boolean status) {
        ApplicationTriggerHelper.skipTrigger = status;
        ApplicationTriggerHelperUSBE.skipTrigger = status;
        ApplicationTriggerHelperUOVC.skipTrigger = status;
        RolesandResponsibilitiesTriggerHelper.skipTrigger = status;
        ApplicationBudgetCategoryTriggerHelper.skipTrigger = status;
        GoalObjectiveTriggerHelper.skipTrigger = status;
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

    global boolean createSnapshot(List<Id> recordIds) {
        Savepoint sp = Database.setSavepoint();
        try {
            toggleTrigger(true);
            schemaMap = Schema.getGlobalDescribe();
            String query = dynamicQuery('Application__c', 'recordIds', 'ID');
            List<Application__c> currentRecords = Database.query(query);
            List<Application__c> newRecords = new List<Application__c>();

            for (Application__c currentRecord : currentRecords) {
                if (currentRecord.Version__c == null) {
                    currentRecord.Version__c = 0;
                }
                currentRecord.Version__c += 1;
                Application__c newRecord = currentRecord.clone();
                newRecord.Snapshot__c = currentRecord.Id;
                newRecord.Status__c = 'Snapshot';
                newRecords.add(newRecord);
            }
            update currentRecords;
            insert newRecords;
            
            query = dynamicQuery('Form__c', 'recordIds', 'Application__c');
            List<Form__c> formlist = Database.query(query);
            query = dynamicQuery('GoalObjective__c', 'recordIds', 'Application__c');
            List<GoalObjective__c> goallist = Database.query(query);
            query = dynamicQuery('BudgetPeriod__c', 'recordIds', 'Application__c');
            List<BudgetPeriod__c> bplist = Database.query(query);
            query = dynamicQuery('ApplicationBudgetCategory2__c', 'recordIds', 'Application__c');
            List<ApplicationBudgetCategory2__c> abclist = Database.query(query);
            query = dynamicQuery('USBEForm__c', 'recordIds', 'Application__c');
            List<USBEForm__c> usbeformlist = Database.query(query);
            query = dynamicQuery('RolesAndResponsibilities__c', 'recordIds', 'Application__c');
            List<RolesAndResponsibilities__c> rolesandresplist = Database.query(query);
            query = dynamicQuery('Attachment', 'recordIds', 'ParentId');
            List<Attachment> attachmentlist = Database.query(query);
            query = dynamicQuery('GNT__AttachmentExtension__c', 'recordIds', 'GNT__ParentId__c', 'GNT__');
            List<GNT__AttachmentExtension__c> attachmentextensionlist = Database.query(query);

            List<Id> formidlist = new List<Id>();
            List<Id> usbeformidlist = new List<Id>();
            for (Form__c form : formlist) {
                formidlist.add(form.id);
            }
            for (USBEForm__c usbeform : usbeformlist) {
                usbeformidlist.add(usbeform.id);
            }

            List<FormTable__c> formtablelist = new List<FormTable__c>();
            List<Attachment> formattachmentlist = new List<Attachment>();
            List<GNT__AttachmentExtension__c> formattachmentextensionlist = new List<GNT__AttachmentExtension__c>();
            if (formlist.size() > 0) {
                formtablelist = Database.query(dynamicQuery('FormTable__c', 'formidlist', 'Form__c'));
                formattachmentlist = Database.query(dynamicQuery('Attachment', 'formidlist', 'ParentId'));
                formattachmentextensionlist = Database.query(dynamicQuery('GNT__AttachmentExtension__c', 'formidlist', 'GNT__ParentId__c', 'GNT__'));
            }

            List<LEAPrivateSchoolFormItem__c> leaprivateschoolformlist = new List<LEAPrivateSchoolFormItem__c>();
            if (usbeformlist.size() > 0) {
                leaprivateschoolformlist = Database.query(dynamicQuery('LEAPrivateSchoolFormItem__c', 'usbeformidlist', 'USBEForm__c'));
            }

            Map<Id, Application__c> appmap = new Map<Id, Application__c>();
            Map<Id, List<Form__c>> formmap = new Map<Id, List<Form__c>>();
            Map<Id, List<GoalObjective__c>> goalmap = new Map<Id, List<GoalObjective__c>>();
            Map<Id, List<BudgetPeriod__c>> bpmap = new Map<Id, List<BudgetPeriod__c>>();
            Map<Id, List<RolesAndResponsibilities__c>> rrmap = new Map<Id, List<RolesAndResponsibilities__c>>();
            Map<Id, List<Attachment>> attachmentmap = new Map<Id, List<Attachment>>();
            Map<Id, List<Attachment>> formattachmentmap = new Map<Id, List<Attachment>>();
            Map<Id, GNT__AttachmentExtension__c> attachmentextensionmap = new Map<Id, GNT__AttachmentExtension__c>();
            Map<Id, GNT__AttachmentExtension__c> formattachmentextensionmap = new Map<Id, GNT__AttachmentExtension__c>();
            Map<Id, List<ApplicationBudgetCategory2__c>> abcmap = new Map<Id, List<ApplicationBudgetCategory2__c>>();
            Map<Id, List<FormTable__c>> formtablemap = new Map<Id, List<FormTable__c>>();
            Map<Id, List<USBEForm__c>> usbeformmap = new Map<Id, List<USBEForm__c>>();
            Map<Id, List<LEAPrivateSchoolFormItem__c>> leaprivateschoolformmap = new Map<Id, List<LEAPrivateSchoolFormItem__c>>();

            for (Application__c newRecord : newRecords) {
                appmap.put(newRecord.Snapshot__c, newRecord);
            }

            for (Form__c form : formlist) {
                List<Form__c> tmp = formmap.get(form.Application__c);
                if (tmp == null) {
                    tmp = new List<Form__c>();
                    formmap.put(form.Application__c, tmp);
                }
                tmp.add(form);
            }

            for (GoalObjective__c goal : goallist) {
                List<GoalObjective__c> tmp = goalmap.get(goal.Application__c);
                if (tmp == null) {
                    tmp = new List<GoalObjective__c>();
                    goalmap.put(goal.Application__c, tmp);
                }
                tmp.add(goal);
            }

            for (BudgetPeriod__c bp : bplist) {
                List<BudgetPeriod__c> tmp = bpmap.get(bp.Application__c);
                if (tmp == null) {
                    tmp = new List<BudgetPeriod__c>();
                    bpmap.put(bp.Application__c, tmp);
                }
                tmp.add(bp);
            }

            for (RolesAndResponsibilities__c rr : rolesandresplist) {
                List<RolesAndResponsibilities__c> tmp = rrmap.get(rr.Application__c);
                if (tmp == null) {
                    tmp = new List<RolesAndResponsibilities__c>();
                    rrmap.put(rr.Application__c, tmp);
                }
                tmp.add(rr);
            }

            for (Attachment attachment : attachmentlist) {
                List<Attachment> tmp = attachmentmap.get(attachment.ParentId);
                if (tmp == null) {
                    tmp = new List<Attachment>();
                    attachmentmap.put(attachment.ParentId, tmp);
                }
                tmp.add(attachment);
            }

            for (Attachment formattachment : formattachmentlist) {
                List<Attachment> tmp = attachmentmap.get(formattachment.ParentId);
                if (tmp == null) {
                    tmp = new List<Attachment>();
                    formattachmentmap.put(formattachment.ParentId, tmp);
                }
                tmp.add(formattachment);
            }

            for (GNT__AttachmentExtension__c attachmentextension : attachmentextensionlist) {
                attachmentextensionmap.put(attachmentextension.GNT__Attachment__c, attachmentextension);
            }

            for (GNT__AttachmentExtension__c formattachmentextension : formattachmentextensionlist) {
                formattachmentextensionmap.put(formattachmentextension.GNT__Attachment__c, formattachmentextension);
            }

            for (ApplicationBudgetCategory2__c abc : abclist) {
                List<ApplicationBudgetCategory2__c> tmp = abcmap.get(abc.BudgetPeriod__c);
                if (tmp == null) {
                    tmp = new List<ApplicationBudgetCategory2__c>();
                    abcmap.put(abc.BudgetPeriod__c, tmp);
                }
                tmp.add(abc);
            }

            for (FormTable__c formtable : formtablelist) {
                List<FormTable__c> tmp = formtablemap.get(formtable.Form__c);
                if (tmp == null) {
                    tmp = new List<FormTable__c>();
                    formtablemap.put(formtable.Form__c, tmp);
                }
                tmp.add(formtable);
            }

            for (USBEForm__c usbeform : usbeformlist) {
                List<USBEForm__c> tmp = usbeformmap.get(usbeform.Application__c);
                if (tmp == null) {
                    tmp = new List<USBEForm__c>();
                    usbeformmap.put(usbeform.Application__c, tmp);
                }
                tmp.add(usbeform);
            }

            for (LEAPrivateSchoolFormItem__c leaprivateschoolform : leaprivateschoolformlist) {
                List<LEAPrivateSchoolFormItem__c> tmp = leaprivateschoolformmap.get(leaprivateschoolform.USBEForm__c);
                if (tmp == null) {
                    tmp = new List<LEAPrivateSchoolFormItem__c>();
                    leaprivateschoolformmap.put(leaprivateschoolform.USBEForm__c, tmp);
                }
                tmp.add(leaprivateschoolform);
            }

            List<Form__c> newformlist = new List<Form__c>();
            List<GoalObjective__c> newgoallist = new List<GoalObjective__c>();
            List<GoalObjective__c> newobjectivelist = new List<GoalObjective__c>();
            List<BudgetPeriod__c> newbplist = new List<BudgetPeriod__c>();
            List<RolesAndResponsibilities__c> newrolesandresplist = new List<RolesAndResponsibilities__c>();
            List<Attachment> newattachmentlist = new List<Attachment>();
            List<Attachment> newformattachmentlist = new List<Attachment>();
            List<GNT__AttachmentExtension__c> newattachmentextensionlist = new List<GNT__AttachmentExtension__c>();
            List<GNT__AttachmentExtension__c> newformattachmentextensionlist = new List<GNT__AttachmentExtension__c>();
            List<ApplicationBudgetCategory2__c> newabclist = new List<ApplicationBudgetCategory2__c>();
            List<FormTable__c> newformtablelist = new List<FormTable__c>();
            List<USBEForm__c> newusbeformlist = new List<USBEForm__c>();
            List<LEAPrivateSchoolFormItem__c> newleaprivateschoolformlist = new List<LEAPrivateSchoolFormItem__c>();
            for (Application__c currentRecord : currentRecords) {
                Application__c newRecord = appmap.get(currentRecord.Id);
                List<Form__c> forms = formmap.get(currentRecord.Id);
                List<BudgetPeriod__c> bps = bpmap.get(currentRecord.Id);
                List<RolesAndResponsibilities__c> rolesandresps = rrmap.get(currentRecord.Id);
                List<Attachment> attachments = attachmentmap.get(currentRecord.Id);
                List<USBEForm__c> usbeforms = usbeformmap.get(currentRecord.Id);

                if (forms != null) {
                    for (Form__c form : forms) {
                        Form__c newform = form.clone();
                        newform.Application__c = newRecord.Id;
                        newformlist.add(newform);
                    }
                }

                if (bps != null) {
                    for (BudgetPeriod__c bp : bps) {
                        BudgetPeriod__c newbp = bp.clone();
                        newbp.Application__c = newRecord.Id;
                        newbplist.add(newbp);
                    }
                }

                if (rolesandresps != null) {
                    for (RolesAndResponsibilities__c rolesandresp : rolesandresps) {
                        RolesAndResponsibilities__c newrolesandresp = rolesandresp.clone();
                        newrolesandresp.Application__c = newRecord.id;
                        newrolesandresplist.add(newrolesandresp);
                    }
                }

                if (attachments != null) {
                    for (Attachment attachment : attachments) {
                        Attachment newatt = attachment.clone();
                        newatt.ParentId = newRecord.id;
                        newattachmentlist.add(newatt);
                    }
                }

                if (usbeforms != null) {
                    for (USBEForm__c usbeform : usbeforms) {
                        USBEForm__c newusbeform = usbeform.clone();
                        newusbeform.Application__c = newRecord.Id;
                        newusbeformlist.add(newusbeform);
                    }
                }
            }
            insert newformlist;
            insert newbplist;
            insert newrolesandresplist;
            insert newattachmentlist;
            insert newusbeformlist;

            Map<Id, Form__c> formtoformmap = new Map<Id, Form__c>();
            for (Form__c form : formlist) {
                for (Form__c newform : newformlist) {
                    if (form.PageTemplateConfig__c == newform.PageTemplateConfig__c) {
                        formtoformmap.put(form.Id, newform);
                    }
                }
            }

            Map<Id, BudgetPeriod__c> bptobpmap = new Map<Id, BudgetPeriod__c>();
            for (BudgetPeriod__c bp : bplist) {
                for (BudgetPeriod__c newbp : newbplist) {
                    if (bp.BudgetPeriod__c == newbp.BudgetPeriod__c) {
                        bptobpmap.put(bp.Id, newbp);
                    }
                }
            }

            Map<Id, USBEForm__c> usbeformtousbeformmap = new Map<Id, USBEForm__c>();
            for (USBEForm__c usbeform : usbeformlist) {
                for (USBEForm__c newusbeform : newusbeformlist) {
                    if (usbeform.ConfigForm__c == newusbeform.ConfigForm__c) {
                        usbeformtousbeformmap.put(usbeform.Id, newusbeform);
                    }
                }
            }

            Map<Id, Attachment> atttoattmap = new Map<Id, Attachment>();
            for (Attachment attachment : attachmentlist) {
                for (Attachment newattachment : newattachmentlist) {
                    if (attachment.Body == newattachment.Body) {
                        atttoattmap.put(attachment.Id, newattachment);
                    }
                }
            }

            for (Application__c currentRecord : currentRecords) {
                List<Form__c> forms = formmap.get(currentRecord.Id);
                List<Attachment> attachments = attachmentmap.get(currentRecord.Id);
                List<BudgetPeriod__c> bps = bpmap.get(currentRecord.Id);
                List<USBEForm__c> usbeforms = usbeformmap.get(currentRecord.Id);

                if (forms != null) {
                    for (Form__c form : forms) {
                        Form__c newform = formtoformmap.get(form.Id);
                        List<GoalObjective__c> goals = goalmap.get(form.Application__c);
                        List<Attachment> formattachments = formattachmentmap.get(form.Id);
                        List<FormTable__c> formtables = formtablemap.get(form.Id);

                        if (goals != null) {
                            for (GoalObjective__c goal : goals) {
                                if (goal.IsParent__c == true && goal.Form__c == form.Id) {
                                    GoalObjective__c newgoal = goal.clone();
                                    newgoal.Application__c = newform.Application__c;
                                    newgoal.Form__c = newform.Id;
                                    newgoallist.add(newgoal);
                                }
                            }
                        }

                        if (formattachments != null) {
                            for (Attachment formattachment : formattachments) {
                                Attachment newformatt = formattachment.clone();
                                newformatt.ParentId = newform.id;
                                newformattachmentlist.add(newformatt);
                            }
                        }

                        if (formtables != null) {
                            for (FormTable__c formtable : formtables) {
                                FormTable__c newformtable = formtable.clone();
                                newformtable.Form__c = newform.id;
                                newformtablelist.add(newformtable);
                            }
                        }
                    }
                }

                if (attachments != null) {
                    for (Attachment attachment : attachments) {
                        Attachment newattachment = atttoattmap.get(attachment.Id);
                        GNT__AttachmentExtension__c attachmentextension = attachmentextensionmap.get(attachment.Id);
                        GNT__AttachmentExtension__c newattachmentextension = attachmentextension.clone();
                        newattachmentextension.GNT__Attachment__c = newattachment.Id;
                        newattachmentextension.GNT__ParentId__c = newattachment.ParentId;
                        newattachmentextension.GNT__InternalUniqueID__c = null;
                        newattachmentextensionlist.add(newattachmentextension);
                    }
                }

                if (bps != null) {
                    for (BudgetPeriod__c bp : bps) {
                        BudgetPeriod__c newbp = bptobpmap.get(bp.Id);
                        List<ApplicationBudgetCategory2__c> abcs = abcmap.get(bp.Id);
                        for (ApplicationBudgetCategory2__c abc : abcs) {
                            ApplicationBudgetCategory2__c newabc = abc.clone();
                            newabc.Application__c = newbp.Application__c;
                            newabc.BudgetPeriod__c = newbp.Id;
                            newabclist.add(newabc);
                        }
                    }
                }

                if (usbeforms != null) {
                    for (USBEForm__c usbeform : usbeforms) {
                        USBEForm__c newusbeform = usbeformtousbeformmap.get(usbeform.Id);
                        List<LEAPrivateSchoolFormItem__c> leaprivateschoolforms = leaprivateschoolformmap.get(usbeform.Id);
                        if (leaprivateschoolforms != null) {
                            for (LEAPrivateSchoolFormItem__c leaprivateschoolform : leaprivateschoolforms) {
                                LEAPrivateSchoolFormItem__c newleaprivateschoolform = leaprivateschoolform.clone();
                                newleaprivateschoolform.Application__c = newusbeform.Application__c;
                                newleaprivateschoolform.USBEForm__c = newusbeform.id;
                                newleaprivateschoolformlist.add(newleaprivateschoolform);
                            }
                        }
                    }
                }
            }
            insert newgoallist;
            insert newabclist;
            insert newformattachmentlist;
            insert newformtablelist;
            insert newleaprivateschoolformlist;
            insert newattachmentextensionlist;

            Map<Id, GoalObjective__c> goalgoalmap = new Map<Id, GoalObjective__c>();
            for (GoalObjective__c goal : goallist) {
                for (GoalObjective__c newgoal : newgoallist) {
                    if (goal.CombineTextQuestions__c == newgoal.CombineTextQuestions__c) {
                        goalgoalmap.put(goal.Id, newgoal);
                    }
                }
            }

            Map<Id, Attachment> formatttoformattmap = new Map<Id, Attachment>();
            for (Attachment formattachment : formattachmentlist) {
                for (Attachment newformattachment : newformattachmentlist) {
                    if (formattachment.Body == newformattachment.Body) {
                        formatttoformattmap.put(formattachment.Id, newformattachment);
                    }
                }
            }

            for (Application__c currentRecord : currentRecords) {
                List<Form__c> forms = formmap.get(currentRecord.Id);

                if (forms != null) {
                    for (Form__c form : forms) {
                        Form__c newform = formtoformmap.get(form.Id);
                        List<Attachment> formattachments = formattachmentmap.get(form.Id);
                        List<GoalObjective__c> goals = goalmap.get(form.Application__c);

                        if (goals != null) {
                            for (GoalObjective__c parentgoal : goals) {
                                if (parentgoal.IsParent__c == true) {
                                    GoalObjective__c newparentgoal = goalgoalmap.get(parentgoal.Id);
                                    for (GoalObjective__c goal : goals) {
                                        if (goal.ParentGoal__c == parentgoal.Id && goal.Form__c == form.Id) {
                                            GoalObjective__c newgoal = goal.clone();
                                            newgoal.Application__c = newform.Application__c;
                                            newgoal.Form__c = newform.Id;
                                            newgoal.ParentGoal__c = newparentgoal.Id;
                                            newobjectivelist.add(newgoal);
                                        }
                                    }
                                }
                            }
                        }

                        if (formattachments != null) {
                            for (Attachment formattachment : formattachments) {
                                Attachment newformattachment = formatttoformattmap.get(formattachment.Id);
                                GNT__AttachmentExtension__c formattachmentextension = formattachmentextensionmap.get(formattachment.Id);
                                GNT__AttachmentExtension__c newformattachmentextension = formattachmentextension.clone();
                                newformattachmentextension.GNT__Attachment__c = newformattachment.Id;
                                newformattachmentextension.GNT__ParentId__c = newformattachment.ParentId;
                                newformattachmentextension.GNT__InternalUniqueID__c = null;
                                newformattachmentextensionlist.add(newformattachmentextension);
                            }
                        }
                    }
                }
            }
            insert newobjectivelist;
            insert newformattachmentextensionlist;
        } catch (Exception e) {
            Database.rollback(sp);
            ApexPages.addMessages(e);
            toggleTrigger(false);

            return false;
        }
        toggleTrigger(false);
        return true;
    }
}