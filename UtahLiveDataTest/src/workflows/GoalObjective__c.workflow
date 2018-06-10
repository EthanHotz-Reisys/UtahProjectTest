<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <rules>
        <fullName>ReminderEmailforQ2</fullName>
        <active>false</active>
        <criteriaItems>
            <field>GoalObjective__c.IsParent__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>This rule is to send an reminder email for end of every quarter</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <offsetFromField>GoalObjective__c.Q2DueDate__c</offsetFromField>
            <timeLength>-24</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>ReminderEmailforQ3</fullName>
        <active>false</active>
        <description>This rule is to send an reminder email for end of every quarter</description>
        <formula>AND(IsParent__c = false, !ISBLANK(Q3DueDate__c))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <offsetFromField>GoalObjective__c.Q3DueDate__c</offsetFromField>
            <timeLength>-24</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>ReminderEmailforQ4</fullName>
        <active>false</active>
        <description>This rule is to send an reminder email for end of every quarter</description>
        <formula>AND(IsParent__c = false, !ISBLANK(Q4DueDate__c))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <offsetFromField>GoalObjective__c.Q4DueDate__c</offsetFromField>
            <timeLength>-24</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
</Workflow>
