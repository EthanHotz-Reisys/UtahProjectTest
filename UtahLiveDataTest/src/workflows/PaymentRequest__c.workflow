<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Email_alert_informing_Payment_Request_Owner_about_Payment_Request_approval</fullName>
        <description>Email alert informing Payment Request Owner about Payment Request approval</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>GovGrants_Email_Templates/Payment_Request_Approved</template>
    </alerts>
    <alerts>
        <fullName>Email_alert_informing_Payment_Request_Owner_about_Payment_Request_rejection</fullName>
        <description>Email alert informing Payment Request Owner about Payment Request rejection</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>GovGrants_Email_Templates/Payment_Request_Rejection</template>
    </alerts>
    <alerts>
        <fullName>Email_to_PM</fullName>
        <description>Email to PM to take action on approval task of payment request submitted by owner</description>
        <protected>false</protected>
        <recipients>
            <field>ProgramManager__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>GovGrants_Email_Templates/PM_Payment_request_approval_task</template>
    </alerts>
    <alerts>
        <fullName>Notifying_FiscalApprover_that_Program_Owner_rejected_the_payment_request</fullName>
        <description>Notifying FiscalApprover that Program Owner rejected the payment request.</description>
        <protected>false</protected>
        <recipients>
            <field>FiscalApprover__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>GovGrants_Email_Templates/EmailToFiscalFromPO</template>
    </alerts>
    <alerts>
        <fullName>PaymentRequestRejectedInternal</fullName>
        <description>PaymentRequestRejectedInternal</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>GovGrants_Email_Templates/Payment_Request_Rejected</template>
    </alerts>
    <alerts>
        <fullName>Payment_Request_Approved</fullName>
        <description>Payment Request Approved</description>
        <protected>false</protected>
        <recipients>
            <field>Applicant__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>GovGrants_Email_Templates/Payment_Request_Approved</template>
    </alerts>
    <alerts>
        <fullName>Payment_Request_Approved_USBE</fullName>
        <description>Payment Request Approved USBE</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>Approver__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>GovGrants_Email_Templates/Payment_Request_Approved_USBE</template>
    </alerts>
    <alerts>
        <fullName>Payment_Request_Internally_Approved</fullName>
        <description>Payment Request Internally Approved</description>
        <protected>false</protected>
        <recipients>
            <field>Applicant__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>GovGrants_Email_Templates/Payment_Request_Internally_Approved</template>
    </alerts>
    <alerts>
        <fullName>Payment_Request_Internally_Rejected</fullName>
        <description>Payment Request Internally Rejected</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>GovGrants_Email_Templates/Payment_Request_Internally_Rejected</template>
    </alerts>
    <alerts>
        <fullName>Payment_Request_Internally_Send_Back</fullName>
        <description>Payment Request Internally Send Back</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>GovGrants_Email_Templates/Payment_Request_Internally_Send_Back_USBE</template>
    </alerts>
    <alerts>
        <fullName>Payment_Request_Rejected</fullName>
        <description>Payment Request Rejected</description>
        <protected>false</protected>
        <recipients>
            <field>Applicant__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>GovGrants_Email_Templates/Payment_Request_Rejected_USBE</template>
    </alerts>
    <alerts>
        <fullName>Payment_Request_Rejected_USBE</fullName>
        <description>Payment Request Rejected USBE</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>Approver__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>GovGrants_Email_Templates/Payment_Request_Rejected_USBE</template>
    </alerts>
    <alerts>
        <fullName>Payment_Request_Send_Back</fullName>
        <description>Payment Request Send Back</description>
        <protected>false</protected>
        <recipients>
            <field>Applicant__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>Approver__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>GovGrants_Email_Templates/Payment_Request_Send_Back</template>
    </alerts>
    <alerts>
        <fullName>Payment_Request_Send_Back_USBE</fullName>
        <description>Payment Request Send Back USBE</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>Approver__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>GovGrants_Email_Templates/Payment_Request_Send_Back_USBE</template>
    </alerts>
    <alerts>
        <fullName>Payment_Waiver_Approved</fullName>
        <description>Payment Waiver Approved</description>
        <protected>false</protected>
        <recipients>
            <field>Applicant__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>GovGrants_Email_Templates/Payment_Waiver_Approved</template>
    </alerts>
    <alerts>
        <fullName>Payment_Waiver_Internally_Approved</fullName>
        <description>Payment Waiver Internally Approved</description>
        <protected>false</protected>
        <recipients>
            <field>Applicant__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>GovGrants_Email_Templates/Payment_Waiver_Internally_Approved</template>
    </alerts>
    <alerts>
        <fullName>Payment_Waiver_Send_Back</fullName>
        <description>Payment Waiver Send Back</description>
        <protected>false</protected>
        <recipients>
            <field>Applicant__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>Approver__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>GovGrants_Email_Templates/Payment_Waiver_Send_Back</template>
    </alerts>
    <alerts>
        <fullName>PaymnetRequestEmailAlert</fullName>
        <description>The owner of payment request receives email when payment request is approved by reviewer</description>
        <protected>false</protected>
        <recipients>
            <field>Applicant__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>GovGrants_Email_Templates/PaymentRequestApproval</template>
    </alerts>
    <alerts>
        <fullName>email_to_sub_recip_notifying_the_approval_of_payment_request</fullName>
        <description>email to sub recip notifying the approval of payment request</description>
        <protected>false</protected>
        <recipients>
            <field>Applicant__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>GovGrants_Email_Templates/Payment_Request_Approved</template>
    </alerts>
    <alerts>
        <fullName>email_to_sub_recip_notifying_the_rejection_of_payment_request</fullName>
        <description>email to sub recip notifying the rejection of payment request</description>
        <protected>false</protected>
        <recipients>
            <field>Applicant__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>GovGrants_Email_Templates/payment_request_reject</template>
    </alerts>
    <fieldUpdates>
        <fullName>Approval1</fullName>
        <field>Status__c</field>
        <literalValue>Approval 1</literalValue>
        <name>Approval 1</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Approval2</fullName>
        <field>Status__c</field>
        <literalValue>Approval 2</literalValue>
        <name>Approval 2</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Approval3</fullName>
        <field>Status__c</field>
        <literalValue>Approval 3</literalValue>
        <name>Approval 3</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Approval4</fullName>
        <field>Status__c</field>
        <literalValue>Approval 4</literalValue>
        <name>Approval 4</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ApprovedbyFiscalManager</fullName>
        <field>Status__c</field>
        <literalValue>Approved</literalValue>
        <name>Approved by Fiscal Manager</name>
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
        <fullName>Submitted_for_Approval</fullName>
        <field>Status__c</field>
        <literalValue>Submitted for Approval</literalValue>
        <name>Submitted for Approval</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Submitted_to_Grantor</fullName>
        <field>Status__c</field>
        <literalValue>Submitted to Grantor</literalValue>
        <name>Submitted to Grantor</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SubmittedtoGrantor</fullName>
        <field>Status__c</field>
        <literalValue>Submitted to Grantor</literalValue>
        <name>Submitted to Grantor</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateStatusToApproved</fullName>
        <field>Status__c</field>
        <literalValue>Approved</literalValue>
        <name>Update Status To Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateStatusToChangeRequested</fullName>
        <field>Status__c</field>
        <literalValue>Rejected</literalValue>
        <name>Update Status To Change Requested</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateStatusToRejected</fullName>
        <field>Status__c</field>
        <literalValue>Rejected</literalValue>
        <name>Update Status To Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Status_To_Rejected</fullName>
        <field>Status__c</field>
        <literalValue>Rejected</literalValue>
        <name>Update Status To Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Status_to_Internally_Approved</fullName>
        <field>Status__c</field>
        <literalValue>Submitted to Grantor</literalValue>
        <name>Update Status to Internally Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <tasks>
        <fullName>RedoPaymentRequest</fullName>
        <assignedToType>owner</assignedToType>
        <dueDateOffset>7</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>Redo Payment Request</subject>
    </tasks>
</Workflow>
