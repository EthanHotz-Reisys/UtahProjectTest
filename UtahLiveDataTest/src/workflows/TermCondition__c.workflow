<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>ActiveStatus</fullName>
        <field>Status__c</field>
        <literalValue>Active</literalValue>
        <name>Set Active status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>InactiveStatus</fullName>
        <field>Status__c</field>
        <literalValue>Inactive</literalValue>
        <name>Set Inactive status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Update Term and Condition status based on EffectiveFrom and Inactiveon fields</fullName>
        <active>true</active>
        <booleanFilter>1 OR 2</booleanFilter>
        <criteriaItems>
            <field>TermCondition__c.EffectiveFrom__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>TermCondition__c.InactiveOn__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>InactiveStatus</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>TermCondition__c.InactiveOn__c</offsetFromField>
            <timeLength>0</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>ActiveStatus</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>TermCondition__c.EffectiveFrom__c</offsetFromField>
            <timeLength>0</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
</Workflow>
