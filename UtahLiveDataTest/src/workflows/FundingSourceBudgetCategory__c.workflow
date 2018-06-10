<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>CalculateRemainingAmount</fullName>
        <field>RemainingAmount__c</field>
        <formula>TotalAmountAllocated__c  -  AllocatedAmount__c</formula>
        <name>Calculate Remaining Amount</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
</Workflow>
