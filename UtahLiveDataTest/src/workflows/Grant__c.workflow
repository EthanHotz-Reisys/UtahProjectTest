<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>UpdateGrantStatusToActive</fullName>
        <description>Update Grant Status to Active</description>
        <field>Status__c</field>
        <literalValue>Active</literalValue>
        <name>Update Grant Status To Active</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>true</protected>
    </fieldUpdates>
    <rules>
        <fullName>Update Grant Status</fullName>
        <actions>
            <name>UpdateGrantStatusToActive</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Grant__c.NumberOfApprovedAwards__c</field>
            <operation>greaterOrEqual</operation>
            <value>1</value>
        </criteriaItems>
        <description>Update Grant Status to Active if Number of Approved Awards greater than 1.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
