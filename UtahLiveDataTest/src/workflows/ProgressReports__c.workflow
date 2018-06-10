<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Email_alert_informing_Progress_Report_Owner_about_Progress_Report_Rejection</fullName>
        <description>Email alert informing Progress Report Owner about Progress Report Rejection</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>GovGrants_Email_Templates/Fiscal_Approve_Progress_Report_Rejection</template>
    </alerts>
    <alerts>
        <fullName>Email_alert_informing_Progress_Report_Owner_about_Report_Approval</fullName>
        <description>Email alert informing Progress Report Owner about Report Approval</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>GovGrants_Email_Templates/Fiscal_Approver_Progress_Report_Approval</template>
    </alerts>
    <alerts>
        <fullName>Email_alert_informing_Progress_Report_Owner_about_Report_Rejection</fullName>
        <description>Email alert informing Progress Report Owner about Report Rejection</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>GovGrants_Email_Templates/Fiscal_Approve_Progress_Report_Rejection</template>
    </alerts>
    <alerts>
        <fullName>Email_to_GA_when_about_approval_task</fullName>
        <description>Email to GA when about approval task</description>
        <protected>false</protected>
        <recipients>
            <field>GrantAdministrator__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>GovGrants_Email_Templates/DCDOHProgressReportSubmitted</template>
    </alerts>
    <fieldUpdates>
        <fullName>ChangeRequested</fullName>
        <description>When Grantor sends the progress report back, status should be changed to Change Requested.</description>
        <field>Status__c</field>
        <literalValue>Change Requested</literalValue>
        <name>ChangeRequested</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Forms_to_not_validated</fullName>
        <field>FormsValidated__c</field>
        <literalValue>0</literalValue>
        <name>Set Forms to not validated</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Status_to_Internally_Approved</fullName>
        <field>Status__c</field>
        <literalValue>Internally Approved</literalValue>
        <name>Set Status to Internally Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Status_Update_to_Submitted</fullName>
        <field>Status__c</field>
        <literalValue>Submitted for Approval</literalValue>
        <name>Status Update to Submitted</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Status_to_Created</fullName>
        <description>Update status to created</description>
        <field>Status__c</field>
        <literalValue>Created</literalValue>
        <name>Update Status to Created</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Status_to_Rejected</fullName>
        <field>Status__c</field>
        <literalValue>Rejected</literalValue>
        <name>Update Status to Rejected</name>
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
        <fullName>UpdatestatustoApproved</fullName>
        <field>Status__c</field>
        <literalValue>Approved</literalValue>
        <name>Update status to Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
</Workflow>
