<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Change_Request_Rejection_Email_to_Initiator</fullName>
        <description>Change Request Rejection  Email to Initiator</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>GovGrants_Email_Templates/Change_Request_Rejection</template>
    </alerts>
    <alerts>
        <fullName>Email_Send_Back</fullName>
        <description>Email Send Back</description>
        <protected>false</protected>
        <recipients>
            <field>Applicant__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>GovGrants_Email_Templates/Negotiation_Request_Send_Back_USBE</template>
    </alerts>
    <fieldUpdates>
        <fullName>SetToCreated</fullName>
        <field>Status__c</field>
        <literalValue>Not Initiated</literalValue>
        <name>SetToCreated</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Status_to_Submitted</fullName>
        <field>Status__c</field>
        <literalValue>Submitted</literalValue>
        <name>Status to Submitted</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Status_to_Submitted_for_Approval</fullName>
        <field>Status__c</field>
        <literalValue>Submitted for Approval</literalValue>
        <name>Status to Submitted for Approval</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Change Request Rejected Email</fullName>
        <actions>
            <name>Change_Request_Rejection_Email_to_Initiator</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>ChangeRequest__c.ApplicantApprovalStatus__c</field>
            <operation>equals</operation>
            <value>Denied</value>
        </criteriaItems>
        <description>This workflow automatically sends an email to the Change request initiator if request is rejected by the applicant.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>RevisionSubmissionbyApplicant2</fullName>
        <active>false</active>
        <criteriaItems>
            <field>ChangeRequest__c.AppChangeRequestStatus__c</field>
            <operation>equals</operation>
            <value>Revision Request Completed</value>
        </criteriaItems>
        <description>When applicant submits the revision, pm should get email.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
