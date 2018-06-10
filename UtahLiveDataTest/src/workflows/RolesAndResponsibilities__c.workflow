<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Grantee_Notify_Users_when_they_are_assigned_role_in_Strategic_Plan</fullName>
        <description>Grantee - Notify Users when they are assigned role in Strategic Plan</description>
        <protected>false</protected>
        <recipients>
            <field>Name__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>GovGrants_Email_Templates/Notify_Grantee_Strategic_Plan_Roles_Upon_Assignment</template>
    </alerts>
    <alerts>
        <fullName>Grantee_Send_Email_to_Reviewer_to_Review_the_Application</fullName>
        <description>Grantee Send Email to Reviewer to Review the Application</description>
        <protected>false</protected>
        <recipients>
            <field>Name__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>GovGrants_Email_Templates/Grantee_Notify_Reviewer_to_Review_Application</template>
    </alerts>
    <alerts>
        <fullName>Grantee_Send_Email_to_Reviewer_to_Review_the_PreApplication</fullName>
        <description>Grantee Send Email to Reviewer to Review the Pre-Application</description>
        <protected>false</protected>
        <recipients>
            <field>Name__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>GovGrants_Email_Templates/Grantee_Notify_Reviewer_to_Review_PreApplication</template>
    </alerts>
    <rules>
        <fullName>Grantee Send Email to Reviewer for Application Review</fullName>
        <actions>
            <name>Grantee_Send_Email_to_Reviewer_to_Review_the_Application</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <booleanFilter>1 AND 2 AND 3</booleanFilter>
        <criteriaItems>
            <field>RolesAndResponsibilities__c.BusinessRole__c</field>
            <operation>equals</operation>
            <value>Program Approver,Program Reviewer,Fiscal Approver,Fiscal Reviewer,Legal Approver,Executive Approver,Grants Administrator</value>
        </criteriaItems>
        <criteriaItems>
            <field>RolesAndResponsibilities__c.Notify__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>RolesAndResponsibilities__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Application</value>
        </criteriaItems>
        <description>This email is sent to the reviewers to review the application whenever the roles and responsibilities are inserted</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Grantee Send Email to Reviewer for Pre-Application Review</fullName>
        <actions>
            <name>Grantee_Send_Email_to_Reviewer_to_Review_the_PreApplication</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>RolesAndResponsibilities__c.Notify__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>RolesAndResponsibilities__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>PreApplication</value>
        </criteriaItems>
        <description>This email is sent to the reviewers to review the application whenever the roles and responsibilities are inserted</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
