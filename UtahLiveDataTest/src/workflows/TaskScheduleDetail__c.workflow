<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Task_Closure_Notification</fullName>
        <description>Task Closure Notification</description>
        <protected>false</protected>
        <recipients>
            <field>AssignedTo__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>GovGrants_Email_Templates/Task_Close_Notification_Template</template>
    </alerts>
    <alerts>
        <fullName>Task_Reminder_Template</fullName>
        <description>Task Reminder Template Before End Date</description>
        <protected>false</protected>
        <recipients>
            <field>AssignedTo__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>GovGrants_Email_Templates/TaskReminderTemplate</template>
    </alerts>
    <alerts>
        <fullName>Task_Reminder_Template_Before_Start_Date_1</fullName>
        <description>Task Reminder Template Before Start Date</description>
        <protected>false</protected>
        <recipients>
            <field>AssignedTo__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>GovGrants_Email_Templates/Task_Reminder_Template_Before_Start_date</template>
    </alerts>
    <rules>
        <fullName>Send Reminder Email Before End Date</fullName>
        <active>false</active>
        <criteriaItems>
            <field>TaskScheduleDetail__c.Status__c</field>
            <operation>equals</operation>
            <value>Not Started,In Progress</value>
        </criteriaItems>
        <criteriaItems>
            <field>TaskScheduleDetail__c.SendReminderBeforeEndDate__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Task_Reminder_Template</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>TaskScheduleDetail__c.EndDate__c</offsetFromField>
            <timeLength>-7</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Send Reminder Email Before start Date</fullName>
        <active>false</active>
        <criteriaItems>
            <field>TaskScheduleDetail__c.Status__c</field>
            <operation>equals</operation>
            <value>Not Started,In Progress</value>
        </criteriaItems>
        <criteriaItems>
            <field>TaskScheduleDetail__c.SendReminderBeforeStartDate__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Task_Reminder_Template_Before_Start_Date_1</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>TaskScheduleDetail__c.EndDate__c</offsetFromField>
            <timeLength>-7</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Task Closing Notification</fullName>
        <actions>
            <name>Task_Closure_Notification</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>TaskScheduleDetail__c.Status__c</field>
            <operation>equals</operation>
            <value>Closed</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
