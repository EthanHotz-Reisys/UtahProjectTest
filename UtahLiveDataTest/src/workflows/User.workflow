<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>External_Reviewer_Deactivation_Email_Alert</fullName>
        <description>External Reviewer Deactivation Email Alert</description>
        <protected>false</protected>
        <recipients>
            <field>Email</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>GovGrants_Email_Templates/ExternalReviewerDeactivationEmail</template>
    </alerts>
    <rules>
        <fullName>ExternalReviewerDeactivationEmailAlert</fullName>
        <actions>
            <name>External_Reviewer_Deactivation_Email_Alert</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>User.IsActive</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.ProfileName__c</field>
            <operation>equals</operation>
            <value>External Reviewer</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
