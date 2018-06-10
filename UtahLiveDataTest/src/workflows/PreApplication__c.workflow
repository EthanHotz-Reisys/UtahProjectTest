<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>PreApplication_Approval</fullName>
        <description>PreApplication Approval</description>
        <protected>false</protected>
        <recipients>
            <field>ProgramApprover__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>GovGrants_Email_Templates/Grantee_Notify_Reviewer_to_Review_PreApplication</template>
    </alerts>
    <fieldUpdates>
        <fullName>Make_Pre_Application_Status_Complete</fullName>
        <field>Status__c</field>
        <literalValue>Complete</literalValue>
        <name>Make Pre-Application Status Complete</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Status_updated_to_Approved</fullName>
        <field>Status__c</field>
        <literalValue>Approved</literalValue>
        <name>Status updated to Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Status_to_Disapproved</fullName>
        <field>Status__c</field>
        <literalValue>Rejected</literalValue>
        <name>Update Status to Disapproved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Status_to_Submitted</fullName>
        <field>Status__c</field>
        <literalValue>Submitted for Approval</literalValue>
        <name>Update Status to Submitted</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Make Pre-Application Status Complete</fullName>
        <actions>
            <name>Make_Pre_Application_Status_Complete</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>PreApplication__c.RecordCompletionPercentage__c</field>
            <operation>equals</operation>
            <value>100</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
