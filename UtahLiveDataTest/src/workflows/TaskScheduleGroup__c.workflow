<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Send_Sub_Tasks_Closed_Email</fullName>
        <description>Send Sub Tasks Closed Email</description>
        <protected>false</protected>
        <recipients>
            <field>AssignedTo__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>GovGrants_Email_Templates/Sub_Task_Closed_Email</template>
    </alerts>
    <rules>
        <fullName>Send Sub Tasks Closure Email</fullName>
        <actions>
            <name>Send_Sub_Tasks_Closed_Email</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <formula>AND(SubTaskCount__c != 0, SubTaskCount__c =  ClosedSubTaskCount__c)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
