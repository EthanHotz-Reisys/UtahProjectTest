<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Notifications_that_applications_are_ready_for_review</fullName>
        <description>Notifications that applications are ready for review</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>utahgrants.support@reisystems.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>GovGrants_Email_Templates/Applications_ready_for_review</template>
    </alerts>
    <fieldUpdates>
        <fullName>Update_field_to_closed</fullName>
        <field>Status__c</field>
        <literalValue>Completed</literalValue>
        <name>Update field to closed</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Send notifications that applications are ready for review</fullName>
        <actions>
            <name>Notifications_that_applications_are_ready_for_review</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>ReviewGroup__c.Status__c</field>
            <operation>equals</operation>
            <value>In Progress</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
