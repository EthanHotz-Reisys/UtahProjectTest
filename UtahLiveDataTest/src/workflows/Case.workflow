<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>GovGrantsTS_Case_Closure</fullName>
        <description>GovGrantsTS - Case Closure</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>GovGrants_Email_Templates/GovGrants_GC_CaseClosure</template>
    </alerts>
    <alerts>
        <fullName>GovGrantsTS_New_Case</fullName>
        <description>GovGrantsTS - New Case</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>GovGrants_Email_Templates/GovGrants_CC_CaseCreation</template>
    </alerts>
    <fieldUpdates>
        <fullName>Assign_To_Tier1_Queue</fullName>
        <description>Auto assign cases to GovGrants Tier 1 Queue</description>
        <field>OwnerId</field>
        <lookupValue>GovGrants_Helpdesk_Tier1</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Assign To Tier1 Queue</name>
        <notifyAssignee>true</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Case Closure Rule</fullName>
        <actions>
            <name>GovGrantsTS_Case_Closure</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Closed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status__c</field>
            <operation>equals</operation>
            <value>Closed</value>
        </criteriaItems>
        <description>Send Email alert when case is resolved/closed</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Case Creation Rule</fullName>
        <actions>
            <name>GovGrantsTS_New_Case</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Assign_To_Tier1_Queue</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>New</value>
        </criteriaItems>
        <description>When a new case is created, owner update, email notification</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
