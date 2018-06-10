<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Awards_activated_email_AC</fullName>
        <description>Awards activated email - Award Creator</description>
        <protected>false</protected>
        <recipients>
            <field>SecondApprover__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>GovGrants_Email_Templates/File_Batch_Awards_Created_AC</template>
    </alerts>
    <alerts>
        <fullName>Awards_activated_email_BC</fullName>
        <description>Awards activated email - Batch Creator</description>
        <protected>false</protected>
        <recipients>
            <field>FirstApprover__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>GovGrants_Email_Templates/File_Batch_Awards_Created_BC</template>
    </alerts>
    <alerts>
        <fullName>Email_for_batch_approval_award</fullName>
        <description>Email for batch approval - award creator</description>
        <protected>false</protected>
        <recipients>
            <field>SecondApprover__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>GovGrants_Email_Templates/File_Batch_Approved_AC</template>
    </alerts>
    <alerts>
        <fullName>Email_for_batch_approval_batch_creator</fullName>
        <description>Email for batch approval - batch creator</description>
        <protected>false</protected>
        <recipients>
            <field>FirstApprover__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>GovGrants_Email_Templates/File_Batch_Approved_BC</template>
    </alerts>
    <alerts>
        <fullName>Email_for_batch_processing</fullName>
        <description>Email for batch processing</description>
        <protected>false</protected>
        <recipients>
            <field>FirstApprover__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>SecondApprover__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>GovGrants_Email_Templates/File_Batch_Processed</template>
    </alerts>
    <alerts>
        <fullName>Email_for_batch_processing_AC</fullName>
        <description>Email for batch processing - Award creator</description>
        <protected>false</protected>
        <recipients>
            <field>SecondApprover__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>GovGrants_Email_Templates/File_Batch_Processed_AC</template>
    </alerts>
    <alerts>
        <fullName>Email_for_batch_processing_BC</fullName>
        <description>Email for batch processing - Batch creator</description>
        <protected>false</protected>
        <recipients>
            <field>FirstApprover__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>GovGrants_Email_Templates/File_Batch_Processed_BC</template>
    </alerts>
    <alerts>
        <fullName>File_batch_created</fullName>
        <description>Sent when a file batch is created</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>GovGrants_Email_Templates/File_Batch_Creation</template>
    </alerts>
    <alerts>
        <fullName>File_batch_created_AC</fullName>
        <description>Sent when a file batch is created - Award Creator</description>
        <protected>false</protected>
        <recipients>
            <field>SecondApprover__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>GovGrants_Email_Templates/File_Batch_Creation_AC</template>
    </alerts>
    <alerts>
        <fullName>File_batch_created_BC</fullName>
        <description>Sent when a file batch is created - Batch Creator</description>
        <protected>false</protected>
        <recipients>
            <field>FirstApprover__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>GovGrants_Email_Templates/File_Batch_Creation_BC</template>
    </alerts>
    <rules>
        <fullName>Email Batch Approved</fullName>
        <actions>
            <name>Email_for_batch_approval_award</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Email_for_batch_approval_batch_creator</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>FileBatch__c.Status__c</field>
            <operation>equals</operation>
            <value>Approved</value>
        </criteriaItems>
        <description>Sends an email when file batch is approved</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Email Batch Creator</fullName>
        <actions>
            <name>File_batch_created</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>FileBatch__c.Status__c</field>
            <operation>equals</operation>
            <value>Created</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Email Batch Processed</fullName>
        <actions>
            <name>Email_for_batch_processing</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>FileBatch__c.Status__c</field>
            <operation>equals</operation>
            <value>Processed</value>
        </criteriaItems>
        <description>Sends an email when file batch is processed</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>File Batch Activated</fullName>
        <actions>
            <name>Awards_activated_email_AC</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Awards_activated_email_BC</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>FileBatch__c.Status__c</field>
            <operation>equals</operation>
            <value>Active</value>
        </criteriaItems>
        <description>Sends an email when file batch is Activated</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>File Batch Approved</fullName>
        <actions>
            <name>Email_for_batch_approval_award</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Email_for_batch_approval_batch_creator</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>FileBatch__c.Status__c</field>
            <operation>equals</operation>
            <value>Approved</value>
        </criteriaItems>
        <description>Sends an email when file batch is approved</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>File Batch Created</fullName>
        <actions>
            <name>File_batch_created_AC</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>File_batch_created_BC</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>FileBatch__c.Status__c</field>
            <operation>equals</operation>
            <value>Created</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>File Batch Processed</fullName>
        <actions>
            <name>Email_for_batch_processing_AC</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Email_for_batch_processing_BC</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>FileBatch__c.Status__c</field>
            <operation>equals</operation>
            <value>Processed</value>
        </criteriaItems>
        <description>Sends an email when file batch is processed</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
