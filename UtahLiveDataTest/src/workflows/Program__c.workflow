<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Email_alert_informing_Program_owner_of_the_Program_approved</fullName>
        <description>Email alert informing Program owner of the Program approved</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>GovGrants_Email_Templates/Program_Approved_Email_Template</template>
    </alerts>
    <alerts>
        <fullName>Email_alert_informing_Program_owner_of_the_Program_rejected</fullName>
        <description>Email alert informing Program owner of the Program rejected</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>GovGrants_Email_Templates/Program_Rejected_Email_Template</template>
    </alerts>
    <fieldUpdates>
        <fullName>Approval_Status</fullName>
        <field>Status__c</field>
        <literalValue>Active</literalValue>
        <name>Update Status to Active</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Reject_Program</fullName>
        <field>Status__c</field>
        <literalValue>Rejected</literalValue>
        <name>Reject Program</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SetToCreated</fullName>
        <field>Status__c</field>
        <literalValue>Created</literalValue>
        <name>SetToCreated</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>StatustoBeingAmended</fullName>
        <field>Status__c</field>
        <literalValue>Being Amended</literalValue>
        <name>StatustoBeingAmended</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateStatus</fullName>
        <field>Status__c</field>
        <literalValue>Review In Progress</literalValue>
        <name>Update status to Review In Progress</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Status_Submitted_for_Approval</fullName>
        <description>Update the Program Status to submitted for Approval</description>
        <field>Status__c</field>
        <literalValue>Submitted for Approval</literalValue>
        <name>Update Status Submitted for Approval</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Status_to_Approved</fullName>
        <field>Status__c</field>
        <literalValue>Approved</literalValue>
        <name>Update Status to Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <tasks>
        <fullName>Program_Review</fullName>
        <assignedToType>owner</assignedToType>
        <dueDateOffset>30</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <offsetFromField>Program__c.CreatedDate</offsetFromField>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>Program Review</subject>
    </tasks>
</Workflow>
