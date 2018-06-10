<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>ANnouncement_Send_back_email</fullName>
        <description>ANnouncement Send back email</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>GovGrants_Email_Templates/AnnouncementSendBack</template>
    </alerts>
    <alerts>
        <fullName>Approval_Process_Rejection_Email_for_Announcement</fullName>
        <description>Approval Process Rejection Email for Announcement</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>utahgrants.support@reisystems.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>GovGrants_Email_Templates/ApprovalProcessAnnouncementRejection</template>
    </alerts>
    <alerts>
        <fullName>Email_alert_informing_Funding_Oppurtunity_Owner_that_FO_has_been_approved_by_Pro</fullName>
        <description>Email alert informing Funding Oppurtunity Owner that FO has been approved by Program Approver</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>GovGrants_Email_Templates/Grantor_Program_Manger_Approval_of_Funding_Opportunity</template>
    </alerts>
    <alerts>
        <fullName>Email_alert_informing_Funding_Oppurtunity_Owner_that_FO_has_been_rejected_by_Pro</fullName>
        <description>Email alert informing Funding Oppurtunity Owner that FO has been rejected by Program Approver</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>GovGrants_Email_Templates/Grantor_Program_Manger_Rejection_of_Funding_Opportunity</template>
    </alerts>
    <alerts>
        <fullName>FAP_Email_alert_informing_Funding_Oppurtunity_Owner_that_FO_has_been_approved_by</fullName>
        <description>FAP Email alert informing Funding Oppurtunity Owner that FO has been approved by Program Approver</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>GovGrants_Email_Templates/FAP_Program_Manager_approves_Funding_opportunity_email_to_FO_Owner</template>
    </alerts>
    <alerts>
        <fullName>FAP_Email_alert_informing_Funding_Oppurtunity_Owner_that_FO_has_been_rejected_by</fullName>
        <description>FAP Email alert informing Funding Oppurtunity Owner that FO has been rejected by Program Approver</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>GovGrants_Email_Templates/FAP_Program_Manager_rejects_Funding_opportunity_email_to_FO_Owner</template>
    </alerts>
    <alerts>
        <fullName>Funding_Opportunity_Approval_Email</fullName>
        <description>Funding Opportunity Approval Email</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>GovGrants_Email_Templates/Opportunity_Approval</template>
    </alerts>
    <alerts>
        <fullName>Funding_Opportunity_Rejection_Email</fullName>
        <description>Funding Opportunity Rejection Email</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>GovGrants_Email_Templates/Funding_Opportunity_Rejection</template>
    </alerts>
    <alerts>
        <fullName>RFA_Email_alert_informing_Funding_Oppurtunity_Owner_that_FO_has_been_approved_by</fullName>
        <description>RFA Email alert informing Funding Oppurtunity Owner that FO has been approved by Program Approver</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>GovGrants_Email_Templates/RFA_Program_Manager_approves_Funding_opportunity_email_to_FO_Owner</template>
    </alerts>
    <alerts>
        <fullName>RFA_Email_alert_informing_Funding_Oppurtunity_Owner_that_FO_has_been_rejected_by</fullName>
        <description>RFA Email alert informing Funding Oppurtunity Owner that FO has been rejected by Program Approver</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>GovGrants_Email_Templates/RFA_Program_Manager_rejects_Funding_opportunity_email_to_FO_Owner</template>
    </alerts>
    <alerts>
        <fullName>Reminder_FOA_publication</fullName>
        <description>This is a reminder email for your tomorrows FOA publication</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>utahgrants.support@reisystems.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/SUPPORTSelfServiceNewCommentNotificationSAMPLE</template>
    </alerts>
    <alerts>
        <fullName>Revision_Request_Email</fullName>
        <description>Revision Request Email</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>utahgrants.support@reisystems.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>GovGrants_Email_Templates/Application_Revision_Requested_Templated</template>
    </alerts>
    <alerts>
        <fullName>SSA_Email_alert_informing_Funding_Oppurtunity_Owner_that_FO_has_been_approved_by</fullName>
        <description>SSA Email alert informing Funding Oppurtunity Owner that FO has been approved by Program Approver</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>GovGrants_Email_Templates/SSA_Program_Manager_approves_Funding_opportunity_email_to_FO_Owner</template>
    </alerts>
    <alerts>
        <fullName>SSA_Email_alert_informing_Funding_Oppurtunity_Owner_that_FO_has_been_rejected_by</fullName>
        <description>SSA Email alert informing Funding Oppurtunity Owner that FO has been rejected by Program Approver</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>GovGrants_Email_Templates/SSA_Program_Manager_rejects_Funding_opportunity_email_to_FO_Owner</template>
    </alerts>
    <alerts>
        <fullName>Sending_Opportunity_Approval_to_next_Approver</fullName>
        <description>Sending Opportunity Approval to next Approver</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>GovGrants_Email_Templates/Opportunity_Approval</template>
    </alerts>
    <alerts>
        <fullName>Test_process_notification</fullName>
        <description>Test process notification</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>GovGrants_Email_Templates/ApprovalProcessAnnouncementRejection</template>
    </alerts>
    <fieldUpdates>
        <fullName>Approval_Status</fullName>
        <field>Status__c</field>
        <literalValue>Approved</literalValue>
        <name>Update status to Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Change_to_Created</fullName>
        <field>Status__c</field>
        <literalValue>Created</literalValue>
        <name>Change to Created</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>FAP_Approved_Status</fullName>
        <description>FAP Approved Status</description>
        <field>FundingAllocationStatus__c</field>
        <literalValue>Approved</literalValue>
        <name>FAP Approved Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Make_Status_Archived</fullName>
        <field>Status__c</field>
        <literalValue>Archived</literalValue>
        <name>Make Status Archived</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Make_Status_Archived1</fullName>
        <field>Status__c</field>
        <literalValue>Archived</literalValue>
        <name>Make Status Archived1</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Make_Status_Closed</fullName>
        <field>Status__c</field>
        <literalValue>Closed</literalValue>
        <name>Make Status Closed</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Make_Status_Closed1</fullName>
        <field>Status__c</field>
        <literalValue>Closed</literalValue>
        <name>Make Status Closed1</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>OpportunityStatustoSubmitted</fullName>
        <description>Opportunity Status to Submitted</description>
        <field>Status__c</field>
        <literalValue>Submitted for Approval</literalValue>
        <name>Opportunity Status to Submitted</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>true</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>RFAStatusUpdate</fullName>
        <field>RFAStatus__c</field>
        <literalValue>Submitted for Approval</literalValue>
        <name>RFAStatusUpdate</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Rejection_Status</fullName>
        <field>Status__c</field>
        <literalValue>Rejected</literalValue>
        <name>Update status to Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>StatusUpdate</fullName>
        <description>Updating Status field on RFA Action</description>
        <field>Status__c</field>
        <literalValue>RFA Submitted for Approval</literalValue>
        <name>StatusUpdate</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Status_to_Reviewed</fullName>
        <field>Status__c</field>
        <literalValue>Reviewed</literalValue>
        <name>Status to Reviewed</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>StatustoRFAApproved</fullName>
        <field>Status__c</field>
        <literalValue>RFA Approved</literalValue>
        <name>Status to RFA Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>StatustoRFADisapproved</fullName>
        <field>Status__c</field>
        <literalValue>RFA Rejected</literalValue>
        <name>Status to RFA Disapproved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateRFAStatustoApproved</fullName>
        <field>RFAStatus__c</field>
        <literalValue>Approved</literalValue>
        <name>Update RFA Status to Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateStatusToRejected</fullName>
        <description>Update Status to rejected if Opportunity is Rejected</description>
        <field>Status__c</field>
        <literalValue>Rejected</literalValue>
        <name>Update Status To Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateStatusToReviewed</fullName>
        <description>Update Opportunity Status to Review once it is initially Submitted</description>
        <field>Status__c</field>
        <literalValue>Reviewed</literalValue>
        <name>Update Status To Reviewed</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>true</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_FAP_Field</fullName>
        <field>FundingAllocationStatus__c</field>
        <literalValue>Submitted for Approval</literalValue>
        <name>Update FAP Field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_FAP_to_Rejected</fullName>
        <description>Update FAP to Rejected</description>
        <field>FundingAllocationStatus__c</field>
        <literalValue>Rejected</literalValue>
        <name>Update FAP to Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_FOAStatus_to_Approved</fullName>
        <field>FOAStatus__c</field>
        <literalValue>Approved</literalValue>
        <name>Update FOAStatus to Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_FOAStatus_to_Submitted</fullName>
        <field>FOAStatus__c</field>
        <literalValue>Submitted for Approval</literalValue>
        <name>Update FOAStatus to Submitted</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_FOA_Status_to_Approved</fullName>
        <field>FOAStatus__c</field>
        <literalValue>Approved</literalValue>
        <name>Update FOA Status to Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_FOA_Status_to_Disapproved</fullName>
        <field>FOAStatus__c</field>
        <literalValue>Disapproved</literalValue>
        <name>Update FOA Status to Disapproved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Field_to_Rejected</fullName>
        <field>RFAStatus__c</field>
        <literalValue>Disapproved</literalValue>
        <name>Update Field to Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Status</fullName>
        <description>Updates thestatus of the Announcement to &quot;Submitted for Approval&quot;</description>
        <field>Status__c</field>
        <literalValue>Submitted for Approval</literalValue>
        <name>Update Status to Submitted for Approval</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Status_to_created</fullName>
        <description>Whenever the Opportunity review is deleted update the status to Created</description>
        <field>Status__c</field>
        <literalValue>Created</literalValue>
        <name>Update Status to created</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>AnnouncementSendBack</fullName>
        <actions>
            <name>ANnouncement_Send_back_email</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Announcement__c.Status__c</field>
            <operation>equals</operation>
            <value>Change Requested</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Approval Revision</fullName>
        <actions>
            <name>Revision_Request_Email</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Announcement__c.Status__c</field>
            <operation>equals</operation>
            <value>Change Requested</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Make Announcement Closed</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Announcement__c.ApplicationDeadlineWithDateTime__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Announcement__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Grantor</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Make_Status_Closed1</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Announcement__c.ApplicationDeadlineWithDateTime__c</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Make_Status_Archived1</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Announcement__c.ApplicationDeadlineWithDateTime__c</offsetFromField>
            <timeLength>90</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>SendEmailbeforeFOA</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Announcement__c.Status__c</field>
            <operation>equals</operation>
            <value>Approved</value>
        </criteriaItems>
        <description>Send a reminder email before the day of publishing FOA</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Reminder_FOA_publication</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Announcement__c.FOAPublicationDate__c</offsetFromField>
            <timeLength>-1</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Update Funding Opportunity Status to Review</fullName>
        <actions>
            <name>Status_to_Reviewed</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2</booleanFilter>
        <criteriaItems>
            <field>Announcement__c.FOAReviews__c</field>
            <operation>greaterOrEqual</operation>
            <value>1</value>
        </criteriaItems>
        <criteriaItems>
            <field>Announcement__c.Status__c</field>
            <operation>equals</operation>
            <value>Created</value>
        </criteriaItems>
        <description>Update Opportunity Status to Reviewed</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update Status to created</fullName>
        <actions>
            <name>Update_Status_to_created</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Announcement__c.FOAReviews__c</field>
            <operation>equals</operation>
            <value>0</value>
        </criteriaItems>
        <description>Update status to created whenever the Review is deleted</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
