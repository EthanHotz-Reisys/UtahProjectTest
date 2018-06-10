<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>ChangeRequired</fullName>
        <field>ChangeRequired__c</field>
        <literalValue>1</literalValue>
        <name>ChangeRequired</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Create Budget Period Task</fullName>
        <active>true</active>
        <description>Create Budget Period Task</description>
        <formula>AND(ISPICKVAL(Status__c, &apos;Active&apos;), Program__c != null)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>ChangeRequired</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>BudgetPeriod__c.BudgetEndDate__c</offsetFromField>
            <timeLength>-7</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
</Workflow>
