<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>FDM_approved_email_to_Owner</fullName>
        <description>FDM approved email to Owner</description>
        <protected>false</protected>
        <recipients>
            <field>announcementOwner__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>GovGrants_Email_Templates/FDM_Approved</template>
    </alerts>
    <alerts>
        <fullName>Notify_Review_Step_Owner_When_deadline_approaches</fullName>
        <description>Notify Review Step Owner When deadline approaches</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>GovGrants_Email_Templates/Notify_Review_Step_owner_when_deadline_approaches</template>
    </alerts>
    <fieldUpdates>
        <fullName>Approved</fullName>
        <field>ReviewApprovalStatus__c</field>
        <literalValue>Approved</literalValue>
        <name>Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ODApproved</fullName>
        <field>ReviewApprovalStatus__c</field>
        <literalValue>OD Approved</literalValue>
        <name>ODApproved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Rejected</fullName>
        <field>ReviewApprovalStatus__c</field>
        <literalValue>Rejected</literalValue>
        <name>Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SetToCreated</fullName>
        <field>ReviewApprovalStatus__c</field>
        <literalValue>Created</literalValue>
        <name>SetToCreated</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Status_to_Submitted_for_Approval</fullName>
        <field>ReviewApprovalStatus__c</field>
        <literalValue>Submitted for Approval</literalValue>
        <name>Status to Submitted for Approval</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Submit_for_Approval</fullName>
        <field>ReviewApprovalStatus__c</field>
        <literalValue>Submitted for Approval</literalValue>
        <name>Submit for Approval</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Notify Review Step owner when deadline approaches</fullName>
        <active>false</active>
        <criteriaItems>
            <field>ReviewStep__c.Status__c</field>
            <operation>notEqual</operation>
            <value>Completed</value>
        </criteriaItems>
        <criteriaItems>
            <field>ReviewStep__c.OrganizationName__c</field>
            <operation>notEqual</operation>
            <value>USBE</value>
        </criteriaItems>
        <description>When a review step is approaches its deadline = (close date -7 days), send an email alert to review step owner.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Notify_Review_Step_Owner_When_deadline_approaches</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>ReviewStep__c.EndDate__c</offsetFromField>
            <timeLength>-7</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
</Workflow>
