<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Email_Alert_to_Owner_that_Record_is_Rejected</fullName>
        <description>Email Alert to Owner that Record is Rejected</description>
        <protected>false</protected>
        <recipients>
            <field>LastModifiedById</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>GovGrants_Email_Templates/NotificationofGrantCloseoutSubmission</template>
    </alerts>
    <alerts>
        <fullName>PO_Approval_Template</fullName>
        <description>PO Approval Template</description>
        <protected>false</protected>
        <recipients>
            <field>FOApprover__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>GovGrants_Email_Templates/NotificationofGrantCloseoutSubmission</template>
    </alerts>
    <alerts>
        <fullName>email_to_grantor_notifying_the_acceptance_of_closeout_notification</fullName>
        <description>email to grantor notifying the acceptance of closeout notification</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>GovGrants_Email_Templates/NotificationofGrantCloseoutSubmission</template>
    </alerts>
    <fieldUpdates>
        <fullName>CloseoutField_Update_to_Approved</fullName>
        <description>Field Update to Approved</description>
        <field>Status__c</field>
        <literalValue>Approved</literalValue>
        <name>Closeout_Field Update to Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Closeout_Field_Update_to_Rejected</fullName>
        <field>Status__c</field>
        <literalValue>Rejected</literalValue>
        <name>Closeout_Field Update to Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Field_Update_to_Approved</fullName>
        <field>Status__c</field>
        <literalValue>Approved</literalValue>
        <name>Field Update to Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Field_Update_to_Rejected</fullName>
        <field>Status__c</field>
        <literalValue>Rejected</literalValue>
        <name>Field Update to Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Submitted_for_Approval</fullName>
        <field>Status__c</field>
        <literalValue>Submitted for Approval</literalValue>
        <name>Submitted for Approval</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>closeoutAcceptedEmailToGrantor</fullName>
        <actions>
            <name>email_to_grantor_notifying_the_acceptance_of_closeout_notification</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Closeout__c.Status__c</field>
            <operation>equals</operation>
            <value>Notification Accepted</value>
        </criteriaItems>
        <description>email to grantor notifying the acceptance of closeout notification from sub recip</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
