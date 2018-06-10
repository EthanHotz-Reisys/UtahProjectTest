<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Amendment_Approved</fullName>
        <description>Amendment Approved</description>
        <protected>false</protected>
        <recipients>
            <field>AwardOwner__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>GovGrants_Email_Templates/Amendment_Approved</template>
    </alerts>
    <alerts>
        <fullName>Amendment_Rejected</fullName>
        <description>Amendment Rejected</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>InternalApprover__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>GovGrants_Email_Templates/Amendment_Request_Rejected</template>
    </alerts>
    <alerts>
        <fullName>Amendment_Request_Disapproved</fullName>
        <description>Amendment Request Disapproved</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>GovGrants_Email_Templates/Amendment_Request_Rejection</template>
    </alerts>
    <alerts>
        <fullName>Amendment_Request_approved</fullName>
        <description>Amendment Request approved</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>FiscalApprover__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>GovGrants_Email_Templates/Amendment_Request_Approval</template>
    </alerts>
    <alerts>
        <fullName>Amendment_Send_back</fullName>
        <description>Amendment Send back</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>GovGrants_Email_Templates/AmendmentRequestSendBack</template>
    </alerts>
    <alerts>
        <fullName>Budget_Revision_Approval_USBE</fullName>
        <description>Budget Revision Approval USBE</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <recipients>
            <field>InternalApprover__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>GovGrants_Email_Templates/Budget_Revision_Approval_USBE</template>
    </alerts>
    <alerts>
        <fullName>Budget_Revision_Rejection_USBE</fullName>
        <description>Budget Revision Rejection USBE</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <recipients>
            <field>InternalApprover__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>GovGrants_Email_Templates/Budget_Revision_Rejection_USBE</template>
    </alerts>
    <alerts>
        <fullName>Budget_Revision_Send_Back_USBE</fullName>
        <description>Budget Revision Send Back USBE</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <recipients>
            <field>InternalApprover__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>GovGrants_Email_Templates/Budget_Revision_Send_Back_USBE</template>
    </alerts>
    <alerts>
        <fullName>EmailAlert_To_FA_amendment_approved</fullName>
        <description>EmailAlert To FA amendment approved</description>
        <protected>false</protected>
        <recipients>
            <field>FiscalApprover__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>GovGrants_Email_Templates/AmendmentApprovalEmailToFA</template>
    </alerts>
    <alerts>
        <fullName>Email_alert_informing_Amendment_request_owner_of_the_Amendment</fullName>
        <description>Email alert informing Amendment request owner of the Amendment</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>GovGrants_Email_Templates/Amendment_Request_Rejection</template>
    </alerts>
    <alerts>
        <fullName>Email_alert_informing_Executive_Approver_of_the_Revision</fullName>
        <description>Email alert informing Executive Approver of the Revision</description>
        <protected>false</protected>
        <recipients>
            <field>ExecutiveApprover__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>GovGrants_Email_Templates/Amendment_Request_Approved</template>
    </alerts>
    <alerts>
        <fullName>Email_alert_informing_Fiscal_Approver_of_the_Amendment</fullName>
        <description>Email alert informing Fiscal Approver of the Amendment</description>
        <protected>false</protected>
        <recipients>
            <field>FiscalApprover__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>GovGrants_Email_Templates/Amendment_Request_Approved</template>
    </alerts>
    <alerts>
        <fullName>Email_alert_informing_Fiscal_Approver_of_the_Revision</fullName>
        <description>Email alert informing Fiscal Approver of the Revision</description>
        <protected>false</protected>
        <recipients>
            <field>FiscalApprover__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>GovGrants_Email_Templates/Amendment_Request_Approved</template>
    </alerts>
    <alerts>
        <fullName>Email_alert_informing_Fiscal_Internal_Approver_of_the_Revision</fullName>
        <description>Email alert informing Fiscal Internal Approver of the Revision</description>
        <protected>false</protected>
        <recipients>
            <field>FiscalApprover__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>GovGrants_Email_Templates/Amendment_Request_Approved</template>
    </alerts>
    <alerts>
        <fullName>Email_alert_informing_Legal_Approver_of_the_Revision</fullName>
        <description>Email alert informing Legal Approver of the Revision</description>
        <protected>false</protected>
        <recipients>
            <field>LegalApprover__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>GovGrants_Email_Templates/Amendment_Request_Approved</template>
    </alerts>
    <alerts>
        <fullName>Email_alert_informing_Revision_request_owner_of_the_Revision_Internal_Rejection</fullName>
        <description>Email alert informing Revision request owner of the Revision Internal Rejection</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>GovGrants_Email_Templates/Amendment_Request_Rejection</template>
    </alerts>
    <alerts>
        <fullName>Email_alert_informing_Revision_request_owner_of_the_Revisoin</fullName>
        <description>Email alert informing Revision request owner of the Revisoin</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>InternalApprover__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>GovGrants_Email_Templates/Amendment_Request_Rejection</template>
    </alerts>
    <alerts>
        <fullName>Notify_Reviwer_to_Review_Amendment_Request</fullName>
        <description>Notify Reviwer to Review Amendment Request</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>GovGrants_Email_Templates/Notify_Reviewer_to</template>
    </alerts>
    <alerts>
        <fullName>Review_Amendment_Request</fullName>
        <description>Review Amendment Request</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>GovGrants_Email_Templates/Notify_Reviewer_to</template>
    </alerts>
    <alerts>
        <fullName>Revision_Request_Approved</fullName>
        <description>Revision Request Approved</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>FiscalApprover__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>GovGrants_Email_Templates/Amendment_Request_Approval</template>
    </alerts>
    <alerts>
        <fullName>Revision_Request_Approved_Internally</fullName>
        <description>Revision Request Approved Internally</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>FiscalApprover__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>GovGrants_Email_Templates/Amendment_Request_Approval</template>
    </alerts>
    <alerts>
        <fullName>Revision_Request_Disapproved</fullName>
        <description>Revision Request Disapproved</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>GovGrants_Email_Templates/Amendment_Request_Rejection</template>
    </alerts>
    <alerts>
        <fullName>Revision_Request_Disapproved_Internally</fullName>
        <description>Revision Request Disapproved Internally</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>InternalApprover__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>GovGrants_Email_Templates/Amendment_Request_Rejection</template>
    </alerts>
    <alerts>
        <fullName>Revision_Request_Final_Approval</fullName>
        <description>Revision Request Final Approval</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>GovGrants_Email_Templates/Amendment_Request_Approved</template>
    </alerts>
    <fieldUpdates>
        <fullName>Amendment_Reject</fullName>
        <field>Status__c</field>
        <literalValue>Rejected</literalValue>
        <name>Amendment Reject</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Amendment_Request_Approved</fullName>
        <field>Status__c</field>
        <literalValue>Approved</literalValue>
        <name>Amendment Request Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>true</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Amendment_Request_Disapproved</fullName>
        <field>Status__c</field>
        <literalValue>Rejected</literalValue>
        <name>Amendment Request Disapproved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ApprovalDate_Updated</fullName>
        <field>ApprovalDate__c</field>
        <formula>NOW()</formula>
        <name>ApprovalDate Updated</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Approval_Date_Updated</fullName>
        <field>ApprovalDate__c</field>
        <formula>NOW()</formula>
        <name>Approval Date Updated</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Budget_Revision_Revised</fullName>
        <field>Status__c</field>
        <literalValue>Revised</literalValue>
        <name>Budget Revision Revised</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Budget_Revision_Revised_Internally</fullName>
        <description>Revision Request Final Approval</description>
        <field>Status__c</field>
        <literalValue>Revised</literalValue>
        <name>Budget Revision Revised Internally</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Change_Status_to_Review_In_Progress</fullName>
        <field>Status__c</field>
        <literalValue>Change Requested</literalValue>
        <name>Change Status to Review In Progress</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>RevisionRequest_Disapproved</fullName>
        <field>Status__c</field>
        <literalValue>Change Requested</literalValue>
        <name>Revision Request Disapproved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Revision_Request_Approved</fullName>
        <field>Status__c</field>
        <literalValue>Approved</literalValue>
        <name>Revision Request Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Revision_Request_Approved_Internally</fullName>
        <description>Revision Request Approved Internally</description>
        <field>Status__c</field>
        <literalValue>Submitted to Grantor</literalValue>
        <name>Revision Request Approved Internally</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Revision_Request_Disapproved_Internally</fullName>
        <description>Revision Request Disapproved Internally</description>
        <field>Status__c</field>
        <literalValue>Change Requested</literalValue>
        <name>Revision Request Disapproved Internally</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Revision_Request_Internal_Final_Approval</fullName>
        <field>Status__c</field>
        <literalValue>Approved</literalValue>
        <name>Revision Request Internal Final Approval</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Revision_Request_Rejected_Internally</fullName>
        <field>Status__c</field>
        <literalValue>Change Requested</literalValue>
        <name>Revision Request Rejected Internally</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SendBack</fullName>
        <field>Status__c</field>
        <literalValue>Created</literalValue>
        <name>SendBack</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SentBackForChanges</fullName>
        <field>Status__c</field>
        <literalValue>Change Requested</literalValue>
        <name>SentBackForChanges</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SetToCreated</fullName>
        <field>Status__c</field>
        <literalValue>Change Requested</literalValue>
        <name>SetToCreated</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateStatustoSubmittedforApproval</fullName>
        <description>Update Status to Submitted for Approval</description>
        <field>Status__c</field>
        <literalValue>Submitted for Approval</literalValue>
        <name>Update Status to Submitted for Approval</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>true</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Status_to_Submitted_for_Approval</fullName>
        <description>Update Status to Submitted for Approval</description>
        <field>Status__c</field>
        <literalValue>Submitted to Grantor</literalValue>
        <name>Update Status to Submitted for Approval</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Submitted_for_Internal_Approval</fullName>
        <description>Update status to: Submitted for Internal Approval</description>
        <field>Status__c</field>
        <literalValue>Submitted for Internal Approval</literalValue>
        <name>Update Submitted for Internal Approval</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
</Workflow>
