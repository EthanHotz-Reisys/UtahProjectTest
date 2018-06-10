<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Email_alert_informing_SME_Reviewer_Approver_about_User_Registration_was_rejected</fullName>
        <description>Email alert informing SME Reviewer Approver about User Registration was rejected</description>
        <protected>false</protected>
        <recipients>
            <field>ExternalReviewerEmail__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>GovGrants_Email_Templates/SME_Reviewer_approver_reviews_registration_rejection</template>
    </alerts>
    <alerts>
        <fullName>Email_alert_informing_SME_Reviewer_about_User_Registration_was_approved</fullName>
        <description>Email alert informing SME Reviewer about User Registration was approved</description>
        <protected>false</protected>
        <recipients>
            <field>ExternalReviewerEmail__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>GovGrants_Email_Templates/SME_Reviewer_approver_reviews_registration_approval</template>
    </alerts>
    <alerts>
        <fullName>Email_alert_informing_User_Registration_Approver_about_User_Registration_was_app</fullName>
        <description>Email alert informing User Registration Approver about User Registration was approved by Registration Owner</description>
        <protected>false</protected>
        <recipients>
            <field>PrimaryRepEmail__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>SecondaryRepEmail__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>GovGrants_Email_Templates/User_Registration_approver_reviews_registration_approval</template>
    </alerts>
    <alerts>
        <fullName>Email_alert_informing_User_Registration_Approver_about_User_Registration_was_rej</fullName>
        <description>Email alert informing User Registration Approver about User Registration was rejected by Registration Owner</description>
        <protected>false</protected>
        <recipients>
            <field>PrimaryRepEmail__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>GovGrants_Email_Templates/User_Registration_approver_reviews_registration_rejection</template>
    </alerts>
    <alerts>
        <fullName>Email_notification_for_Program_Officer_when_an_external_reviewer_is_registered</fullName>
        <description>Email notification for Program Officer when an external reviewer is registered</description>
        <protected>false</protected>
        <recipients>
            <field>Approver__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>DefaultWorkflowUser</senderType>
        <template>GovGrants_Email_Templates/ProgramOfficerNotification</template>
    </alerts>
    <fieldUpdates>
        <fullName>Approve</fullName>
        <field>Status__c</field>
        <literalValue>Approved</literalValue>
        <name>Approve</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Rejected</fullName>
        <field>Status__c</field>
        <literalValue>Rejected</literalValue>
        <name>Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_status_to_Approved</fullName>
        <field>Status__c</field>
        <literalValue>Approved</literalValue>
        <name>Update status to Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_status_to_Disapproved</fullName>
        <field>Status__c</field>
        <literalValue>Rejected</literalValue>
        <name>Update status to Disapproved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_status_to_Review_In_Progress</fullName>
        <field>Status__c</field>
        <literalValue>Review In Progress</literalValue>
        <name>Update status to Review In Progress</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
</Workflow>
