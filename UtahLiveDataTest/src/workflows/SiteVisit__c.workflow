<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Email_alert_informing_Site_Visit_owner_about_site_visit_rejection</fullName>
        <description>Email alert informing Site Visit owner about site visit rejection</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>GovGrants_Email_Templates/Site_Visit_Report_Rejection</template>
    </alerts>
    <alerts>
        <fullName>Email_to_GA_once_report_is_approved</fullName>
        <description>Email to GA once report is approved</description>
        <protected>false</protected>
        <recipients>
            <field>GrantAdministrator__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>GovGrants_Email_Templates/Site_Visit_Report_Approved</template>
    </alerts>
    <alerts>
        <fullName>Email_to_Sub_to_notify_that_site_visti_is_ready_for_review</fullName>
        <description>Email to Sub to notify that site visti is ready for review</description>
        <protected>false</protected>
        <recipients>
            <field>ApplicantEmail__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>GovGrants_Email_Templates/SiteVisitreportToSubEmail</template>
    </alerts>
    <alerts>
        <fullName>Grantor_Email_alert_informing_Site_Visit_owner_about_site_visit_rejection</fullName>
        <description>Grantor Email alert informing Site Visit owner about site visit rejection</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>GovGrants_Email_Templates/Site_Visit_Report_Rejection</template>
    </alerts>
    <alerts>
        <fullName>Notify_Site_Visitor</fullName>
        <description>Notify Site Visitor</description>
        <protected>false</protected>
        <recipients>
            <field>SiteVisitor__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>GovGrants_Email_Templates/Notify_Site_Visitor_of_the_Visit</template>
    </alerts>
    <alerts>
        <fullName>Reject_attachments</fullName>
        <description>Reject attachments</description>
        <protected>false</protected>
        <recipients>
            <field>SubAwardee__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>GovGrants_Email_Templates/Site_Visit_Attachments_Rejected</template>
    </alerts>
    <alerts>
        <fullName>Site_Visit_Approval</fullName>
        <description>Site Visit Approval</description>
        <protected>false</protected>
        <recipients>
            <field>ProgramApprover__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>GovGrants_Email_Templates/SiteVisitReportSubmitted</template>
    </alerts>
    <alerts>
        <fullName>Site_Visit_approved</fullName>
        <description>Site Visit approved</description>
        <protected>false</protected>
        <recipients>
            <field>SubAwardee__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>GovGrants_Email_Templates/Site_Visit_Attachments_Approved</template>
    </alerts>
    <fieldUpdates>
        <fullName>Attachment_Approval</fullName>
        <description>GA approves attachments</description>
        <field>Status__c</field>
        <literalValue>Reviewed by Grantor</literalValue>
        <name>Attachment Approval</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ChangestatustoPlannedAndSentTosub</fullName>
        <field>Status__c</field>
        <literalValue>Planned and Submitted to Subrecipient</literalValue>
        <name>Change status to PlannedAndSentTosub</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Reject_Attachments</fullName>
        <description>Send site visit process back one step</description>
        <field>Status__c</field>
        <literalValue>Planned and Submitted to Subrecipient</literalValue>
        <name>Reject Attachments</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Return_Status_to_Visited</fullName>
        <description>Update Status to Visited</description>
        <field>Status__c</field>
        <literalValue>Visited</literalValue>
        <name>Return Status to Visited</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>StatusUpdatetoSubmitted</fullName>
        <description>Status Update to Submitted</description>
        <field>Status__c</field>
        <literalValue>Report Submitted</literalValue>
        <name>Status Update to Submitted</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateStatustoRejected</fullName>
        <description>Update Status to Rejected</description>
        <field>Status__c</field>
        <literalValue>Rejected</literalValue>
        <name>Update Status to Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdatestatustoApproved</fullName>
        <description>Update status to Approved</description>
        <field>Status__c</field>
        <literalValue>Report Approved</literalValue>
        <name>Update status to Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Notify Site Visitor of the Visit</fullName>
        <actions>
            <name>Notify_Site_Visitor</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>SiteVisit__c.SiteVisitor__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>SiteVisitreportToSub</fullName>
        <actions>
            <name>Email_to_Sub_to_notify_that_site_visti_is_ready_for_review</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>SiteVisit__c.Status__c</field>
            <operation>equals</operation>
            <value>Sent to Subrecipient</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
