<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Application_Approved_Internally</fullName>
        <description>Application Approved Internally</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>GovGrants_Email_Templates/ApplicationApproved</template>
    </alerts>
    <alerts>
        <fullName>Application_Internally_Rejected</fullName>
        <description>Application Internally Rejected</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>Approver__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>LEAKeyPOC__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>GovGrants_Email_Templates/Application_Reject</template>
    </alerts>
    <alerts>
        <fullName>Application_Send_Back</fullName>
        <description>Application Send Back</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>GovGrants_Email_Templates/Application_Send_Back</template>
    </alerts>
    <alerts>
        <fullName>Application_Waive_Internally_Approved</fullName>
        <description>Application Waive Internally Approved</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>LEAKeyPOC__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>GovGrants_Email_Templates/Application_Waive</template>
    </alerts>
    <alerts>
        <fullName>Application_Waive_Internally_Approved_GM</fullName>
        <description>Application Waive Internally Approved GM</description>
        <protected>false</protected>
        <recipients>
            <field>GrantsManager__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>GovGrants_Email_Templates/Application_Waive_GM</template>
    </alerts>
    <alerts>
        <fullName>Application_Waived_Internally_Rejected</fullName>
        <description>Application Waived Internally Rejected</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>Approver__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>GovGrants_Email_Templates/ApplicationRejectionNotification</template>
    </alerts>
    <alerts>
        <fullName>Application_Withdraw_Internally_Approved</fullName>
        <description>Application Withdraw Internally Approved</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>GovGrants_Email_Templates/ApplicationApproved</template>
    </alerts>
    <alerts>
        <fullName>Approval_email_to_PO_andFO</fullName>
        <description>Approval email to PO and FO</description>
        <protected>false</protected>
        <recipients>
            <field>FiscalApproval__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>ProgramApprover__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>GovGrants_Email_Templates/Application_PO_FO_Approval</template>
    </alerts>
    <alerts>
        <fullName>Approval_email_to_PO_and_FO</fullName>
        <description>Approval email to PO and FO</description>
        <protected>false</protected>
        <recipients>
            <field>FiscalApproval__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>ProgramApprover__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>GovGrants_Email_Templates/Application_PO_FO_Approval</template>
    </alerts>
    <alerts>
        <fullName>Change_Request_Approval_Notification</fullName>
        <description>Change Request Approval Notification</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>utahgrants.support@reisystems.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>GovGrants_Email_Templates/ChangeRequestApproved</template>
    </alerts>
    <alerts>
        <fullName>Email_alert_to_owner_informing_them_of_application_rejection</fullName>
        <description>Email alert to owner informing them of application rejection</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>GovGrants_Email_Templates/Application_Rejection_notification_to_owner</template>
    </alerts>
    <alerts>
        <fullName>Email_alert_to_owner_informing_them_of_applicationrejection</fullName>
        <description>Email alert to owner informing them of application rejection</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>Approver__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>GovGrants_Email_Templates/Application_Rejection_notification_to_owner</template>
    </alerts>
    <alerts>
        <fullName>Email_to_PM_when_sub_submits_the_revision_request_of_application</fullName>
        <description>Email to PM when sub submits the revision request of application</description>
        <protected>false</protected>
        <recipients>
            <field>ProgramManager__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>GovGrants_Email_Templates/PreAwardRequestEvaluationCompleted</template>
    </alerts>
    <alerts>
        <fullName>Grantee_Notify_Application_Owner_that_Application_in_Approved_internally</fullName>
        <description>Grantee Notify Application Owner that Application in Approved internally</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>FedBizOps__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Grantee_Email_Templates/Grantee_Notify_Application_Owner_that_Minimum_reviews_are_completed</template>
    </alerts>
    <alerts>
        <fullName>Grantee_Notify_Application_Owner_that_Minimum_required_reviews_are_done</fullName>
        <description>Grantee Notify Application Owner that Minimum required reviews are done</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Grantee_Email_Templates/Notify_Application_owner_that_Minimum_reviews_are_completed</template>
    </alerts>
    <alerts>
        <fullName>Notify_owner_that_Application_has_been_approved</fullName>
        <description>Notify owner that Application has been approved</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>GovGrants_Email_Templates/Application_approval_email_to_owner</template>
    </alerts>
    <alerts>
        <fullName>Notify_owner_that_Application_has_been_rejected</fullName>
        <description>Notify owner that Application has been rejected</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>GovGrants_Email_Templates/Application_rejection_email_to_owner</template>
    </alerts>
    <alerts>
        <fullName>SendEmailNotificationToApplicantOnApplicationSubmission</fullName>
        <description>Send Email Notification to Applicant when Application is Submitted</description>
        <protected>false</protected>
        <recipients>
            <field>SubmittedBy__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>utahgrants.support@reisystems.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>GovGrants_Email_Templates/Grantor_ConfirmationEmailToApplicant</template>
    </alerts>
    <alerts>
        <fullName>Send_Rejection_Email</fullName>
        <description>Send Rejection Email</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>Approver__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>utahgrants.support@reisystems.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>GovGrants_Email_Templates/Change_Request_Reviewer_Rejection</template>
    </alerts>
    <fieldUpdates>
        <fullName>ApplicationWithdraw_Internal_Approved</fullName>
        <field>Status__c</field>
        <literalValue>Withdrawn</literalValue>
        <name>ApplicationWithdraw Internal Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Application_Approved_Internally</fullName>
        <field>Status__c</field>
        <literalValue>Submitted to Grantor</literalValue>
        <name>Application Approved Internally</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Application_Waive_Approve_Status_Update</fullName>
        <field>Status__c</field>
        <literalValue>Waived</literalValue>
        <name>Application Waive Approve Status Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Application_Waived_Internally_Rejected</fullName>
        <field>Status__c</field>
        <literalValue>Created</literalValue>
        <name>Application Waived Internally Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Application_Withdraw_Internally_Rejected</fullName>
        <field>Status__c</field>
        <literalValue>Rejected</literalValue>
        <name>Application Withdraw Internally Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Grantee_Application_Status_to_Submitted</fullName>
        <field>Status__c</field>
        <literalValue>Submitted For Approval</literalValue>
        <name>Grantee Application Status to Submitted</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Internal_Reject_Application</fullName>
        <field>Status__c</field>
        <literalValue>Rejected</literalValue>
        <name>Internal Reject Application</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Populate_field</fullName>
        <field>Title__c</field>
        <formula>Announcement__r.AnnouncementName__c</formula>
        <name>Populate field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Reset_WaiveWithdraw</fullName>
        <field>WaiveWithdraw__c</field>
        <literalValue>Not Applicable</literalValue>
        <name>Reset WaiveWithdraw</name>
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
        <fullName>StatusUpdate</fullName>
        <description>Change the status of an Application to Reviewed if the Reviews are deleted</description>
        <field>Status__c</field>
        <literalValue>Reviewed</literalValue>
        <name>Status Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SubmittedForApproval</fullName>
        <field>Status__c</field>
        <literalValue>Submitted For Approval</literalValue>
        <name>SubmittedForApproval</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Status_to</fullName>
        <field>Status__c</field>
        <literalValue>Submitted to Grantor</literalValue>
        <name>Update Status to</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Status_toApproved</fullName>
        <field>Status__c</field>
        <literalValue>Approved</literalValue>
        <name>Update Status to Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Waive_Application_Approved_Internally</fullName>
        <field>Status__c</field>
        <literalValue>Approved Internally</literalValue>
        <name>Waive Application Approved Internally</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>ApplicationSubmissionNotificationEmail</fullName>
        <actions>
            <name>SendEmailNotificationToApplicantOnApplicationSubmission</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Application__c.Status__c</field>
            <operation>equals</operation>
            <value>Submitted to Grantor</value>
        </criteriaItems>
        <criteriaItems>
            <field>Application__c.GrantorOrganizationName__c</field>
            <operation>notEqual</operation>
            <value>USBE</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Change the Application Status to Reviewed</fullName>
        <actions>
            <name>StatusUpdate</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Application__c.Status__c</field>
            <operation>equals</operation>
            <value>Sent for Review</value>
        </criteriaItems>
        <criteriaItems>
            <field>Application__c.NumberOfReviews__c</field>
            <operation>greaterOrEqual</operation>
            <value>1</value>
        </criteriaItems>
        <criteriaItems>
            <field>Application__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Grantor</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Grantee Notify Application Owner that Minimum reviews are completed</fullName>
        <actions>
            <name>Grantee_Notify_Application_Owner_that_Minimum_required_reviews_are_done</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Application__c.Status__c</field>
            <operation>equals</operation>
            <value>Reviewed</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Grantee Notify Owner that application is Approved</fullName>
        <actions>
            <name>Grantee_Notify_Application_Owner_that_Application_in_Approved_internally</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Application__c.Status__c</field>
            <operation>equals</operation>
            <value>Approved</value>
        </criteriaItems>
        <description>The Application Owner is notified that the Application is now approved internally</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>If Application outside system update Status after Approval to Submitted to Grantor</fullName>
        <actions>
            <name>Update_Status_to</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Application__c.ApplicationCreatedOutside__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Application__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Grantee</value>
        </criteriaItems>
        <criteriaItems>
            <field>Application__c.Status__c</field>
            <operation>equals</operation>
            <value>Approved</value>
        </criteriaItems>
        <description>If the Application is created &amp; submitted outside of the system then in that case we need to update the opportunity Status to Sent to Grantor immediately after it is Apporved</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>RevisionSubmissionbyApplicant</fullName>
        <actions>
            <name>Email_to_PM_when_sub_submits_the_revision_request_of_application</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Application__c.ChangeRequestStatus__c</field>
            <operation>equals</operation>
            <value>Revision Request Completed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Application__c.GrantorOrganizationName__c</field>
            <operation>notEqual</operation>
            <value>USBE</value>
        </criteriaItems>
        <description>When applicant submits the revision, pm should get email.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <tasks>
        <fullName>Approve_Change_Request</fullName>
        <assignedToType>owner</assignedToType>
        <dueDateOffset>2</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <offsetFromField>Application__c.SubmittedOn__c</offsetFromField>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>Approve Change Request</subject>
    </tasks>
    <tasks>
        <fullName>Complete_Assignment</fullName>
        <assignedToType>owner</assignedToType>
        <dueDateOffset>2</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <offsetFromField>Application__c.SubmittedOn__c</offsetFromField>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>Complete Assignment</subject>
    </tasks>
</Workflow>
