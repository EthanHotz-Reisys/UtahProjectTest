<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Send_Email_When_Excel_Processed</fullName>
        <description>Send Email When Excel Processed</description>
        <protected>false</protected>
        <recipients>
            <field>UploadedBy__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/AWSTest</template>
    </alerts>
    <rules>
        <fullName>SendEmailAfterExcelProcessed</fullName>
        <actions>
            <name>Send_Email_When_Excel_Processed</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>POC_FinancialBatch__c.Status__c</field>
            <operation>equals</operation>
            <value>Processed</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
