/**
* MIT License
*
* Copyright (c) 2019 Piotr Kożuchowski
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
*/
// TODO: Create false-positive!
trigger DCM_LoggingEventTrigger on DCM_LoggingEvent__e (after insert) {
    List<DCM_Application_Log__c> logs = new List<DCM_Application_Log__c>();

    for (DCM_LoggingEvent__e loggingEvent : Trigger.new) {
        logs.add(new DCM_Application_Log__c(
                Application_Name__c = loggingEvent.Application_Name__c,
                Module_Name__c = loggingEvent.Module_Name__c,
                Class_Name__c = loggingEvent.Class_Name__c,
                Method_Name__c = loggingEvent.Method_Name__c,
                Logging_Level__c = loggingEvent.Logging_Level__c,
                Message__c = loggingEvent.Message__c,
                Record_Id__c = loggingEvent.Record_Id__c,
                Running_User__c = loggingEvent.Running_User__c,
                Exception_Line_Number__c = loggingEvent.Exception_Line_Number__c,
                Exception_Message__c = loggingEvent.Exception_Message__c,
                Exception_Stack_Trace__c = loggingEvent.Exception_Stack_Trace__c,
                Exception_Type__c = loggingEvent.Exception_Type__c,
                Response_Status_Code__c = loggingEvent.Response_Status_Code__c,
                Salesforce_Limits__c = loggingEvent.Salesforce_Limits__c
        ));
    }

    insert logs;
}