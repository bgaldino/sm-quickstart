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

/**
 * Logs persistent messages in custom object records and emits platform event.
 *
 * @dependency:
 * @see Runtime
 *  @see Stringifier
 */
global with sharing class DCM_Logger {
    private Stringifier stringifier = new Stringifier();
    private Boolean immediate;
    private String applicationName;
    private String moduleName;
    private static List<DCM_Application_Log__c> logs = new List<DCM_Application_Log__c>();

    private static final String DEFAULT_APP = 'Subscription Management Accelerator';
    private static final String DEFAULT_MODULE = B2B_Constants.Module.ORG_DEFAULT;

    /**
     * Default constructor works in immediate mode.
     * This is preferred mode for controllers and async apex.
     */
    private DCM_Logger() {
        this(true);
    }

    private DCM_Logger(Boolean immediate) {
        this(immediate, DEFAULT_APP, DEFAULT_MODULE);
    }

    private DCM_Logger(Boolean immediate, String moduleName) {
        this(immediate, DEFAULT_APP, moduleName);
    }

    private DCM_Logger(Boolean immediate, String applicationName, String moduleName) {
        this.immediate = immediate;
        this.applicationName = applicationName;
        this.moduleName = moduleName;
    }

    global static DCM_Logger getInstance() {
        return new DCM_Logger();
    }

    global static DCM_Logger getInstance(String moduleName) {
        return new DCM_Logger(false, moduleName);
    }

    global static DCM_Logger getImmediateInstance() {
        return new DCM_Logger(true);
    }

    global static DCM_Logger getImmediateInstance(String moduleName) {
        return new DCM_Logger(true, moduleName);
    }

    /**
     * Logs message with INFO logging level
     */
    global void info(String message) {
        info(null, message);
    }
    global void info(String referenceId, String message) {
        log(LoggingLevel.INFO, referenceId, message);
    }
    global void info(DCM_Application_Log__c log) {
        log(LoggingLevel.INFO, log);
    }
    global void info(String referenceId, Exception ex) {
        log(LoggingLevel.INFO, referenceId, ex);
    }
    global void info(String referenceId, HttpRequest request, HttpResponse response) {
        log(LoggingLevel.INFO, referenceId, request, response);
    }
    global void info(String referenceId, RestRequest request, RestResponse response) {
        log(LoggingLevel.INFO, referenceId, request, response);
    }

    global void info(Exception ex) {
        log(LoggingLevel.INFO, '', ex);
    }
    global void info(HttpRequest request, HttpResponse response) {
        log(LoggingLevel.INFO, '', request, response);
    }
    global void info(RestRequest request, RestResponse response) {
        log(LoggingLevel.INFO, '', request, response);
    }

    /**
     * Logs message with DEBUG logging level
     */
    global void debug(String message) {
        debug(null, message);
    }
    global void debug(String referenceId, String message) {
        log(LoggingLevel.DEBUG, referenceId, message);
    }
    global void debug(DCM_Application_Log__c log) {
        log(LoggingLevel.DEBUG, log);
    }
    global void debug(String referenceId, Exception ex) {
        log(LoggingLevel.DEBUG, referenceId, ex);
    }
    global void debug(String referenceId, HttpRequest request, HttpResponse response) {
        log(LoggingLevel.DEBUG, referenceId, request, response);
    }
    global void debug(String referenceId, RestRequest request, RestResponse response) {
        log(LoggingLevel.DEBUG, referenceId, request, response);
    }
    global void debug(Exception ex) {
        log(LoggingLevel.DEBUG, '', ex);
    }
    global void debug(HttpRequest request, HttpResponse response) {
        log(LoggingLevel.DEBUG, '', request, response);
    }
    global void debug(RestRequest request, RestResponse response) {
        log(LoggingLevel.DEBUG, '', request, response);
    }

    /**
     * Logs message with WARNING logging level
     */
    global void warn(String message) {
        warn(null, message);
    }
    global void warn(String referenceId, String message) {
        log(LoggingLevel.WARN, referenceId, message);
    }
    global void warn(DCM_Application_Log__c log) {
        log(LoggingLevel.WARN, log);
    }
    global void warn(String referenceId, Exception ex) {
        log(LoggingLevel.WARN, referenceId, ex);
    }
    global void warn(String referenceId, HttpRequest request, HttpResponse response) {
        log(LoggingLevel.WARN, referenceId, request, response);
    }
    global void warn(String referenceId, RestRequest request, RestResponse response) {
        log(LoggingLevel.WARN, referenceId, request, response);
    }
    global void warn(Exception ex) {
        log(LoggingLevel.WARN, '', ex);
    }
    global void warn(HttpRequest request, HttpResponse response) {
        log(LoggingLevel.WARN, '', request, response);
    }
    global void warn(RestRequest request, RestResponse response) {
        log(LoggingLevel.WARN, '', request, response);
    }

    /**
     * Logs message with ERROR logging level
     */
    global void error(String message) {
        error(null, message);
    }
    global void error(String referenceId, String message) {
        log(LoggingLevel.ERROR, referenceId, message);
    }
    global void error(String referenceId, String message, Exception ex) {
        log(LoggingLevel.ERROR, referenceId, message, ex);
    }
    global void error(DCM_Application_Log__c log) {
        log(LoggingLevel.ERROR, log);
    }
    global void error(Exception ex) {
        error(null, ex);
    }
    global void error(String referenceId, Exception ex) {
        log(LoggingLevel.ERROR, referenceId, ex);
    }
    global void error(String referenceId, HttpRequest request, HttpResponse response) {
        log(LoggingLevel.ERROR, referenceId, request, response);
    }
    global void error(String referenceId, RestRequest request, RestResponse response) {
        log(LoggingLevel.ERROR, referenceId, request, response);
    }
    global void error(HttpRequest request, HttpResponse response) {
        log(LoggingLevel.ERROR, '', request, response);
    }
    global void error(RestRequest request, RestResponse response) {
        log(LoggingLevel.ERROR, '', request, response);
    }

    /**
     * Logs ERROR log when condition is not met.
     *
     * @param condition When false, error is logged
     * @param log Message to record
     */
    public void assert(Boolean condition, DCM_Application_Log__c log) {
        if (!condition) {
            log(LoggingLevel.ERROR, log);
        }
    }

    /**
     * Logs message with given logging level
     */
    public void log(LoggingLevel loggingLevel, String message) {
        log(loggingLevel, null, message);
    }

    public void log(LoggingLevel loggingLevel, String referenceId, String message) {
        log(loggingLevel, new DCM_Application_Log__c(Record_Id__c = referenceId, Message__c = message));
    }

    /**
     * Logs exception with given logging level
     */
    public void log(LoggingLevel loggingLevel, String referenceId, Exception ex) {
        log(
            loggingLevel,
            new DCM_Application_Log__c(
                Message__c = stringifier.toString(ex),
                Record_Id__c = referenceId,
                Exception_Type__c = ex.getTypeName(),
                Exception_Line_Number__c = ex.getLineNumber(),
                Exception_Stack_Trace__c = truncateFieldValueBasedOnFieldSize(
                    ex.getStackTraceString(),
                    Schema.SObjectType.DCM_Application_Log__c.fields.Exception_Stack_Trace__c
                ),
                Exception_Message__c = truncateFieldValueBasedOnFieldSize(
                    ex.getMessage(),
                    Schema.SObjectType.DCM_Application_Log__c.fields.Exception_Message__c
                )
            )
        );
    }

    /**
     * Logs exception with given logging level
     */
    public void log(LoggingLevel loggingLevel, String referenceId, String message, Exception ex) {
        log(
            loggingLevel,
            new DCM_Application_Log__c(
                Message__c = message,
                Record_Id__c = referenceId,
                Exception_Type__c = ex.getTypeName(),
                Exception_Line_Number__c = ex.getLineNumber(),
                Exception_Stack_Trace__c = truncateFieldValueBasedOnFieldSize(
                    ex.getStackTraceString(),
                    Schema.SObjectType.DCM_Application_Log__c.fields.Exception_Stack_Trace__c
                ),
                Exception_Message__c = truncateFieldValueBasedOnFieldSize(
                    ex.getMessage(),
                    Schema.SObjectType.DCM_Application_Log__c.fields.Exception_Message__c
                )
            )
        );
    }

    /**
     * Formats and logs Http request and response (null-safe).
     */
    public void log(LoggingLevel loggingLevel, String referenceId, HttpRequest request, HttpResponse response) {
        DCM_Application_Log__c log = new DCM_Application_Log__c(
            Record_Id__c = referenceId,
            Message__c = String.join(
                new List<String>{ stringifier.toString(request), stringifier.toString(response) },
                '\n\n'
            )
        );

        if (response != null) {
            log.Response_Status_Code__c = response.getStatusCode();
        }

        log(loggingLevel, log);
    }

    /**
     * Formats and logs Http request and response (null-safe).
     */
    public void log(LoggingLevel loggingLevel, String referenceId, RestRequest request, RestResponse response) {
        DCM_Application_Log__c log = new DCM_Application_Log__c(
            Record_Id__c = referenceId,
            Message__c = String.join(
                new List<String>{ stringifier.toString(request), stringifier.toString(response) },
                '\n\n'
            )
        );

        if (response != null) {
            log.Response_Status_Code__c = response.statusCode;
        }

        log(loggingLevel, log);
    }

    /**
     * Logs log object with given logging level
     */
    public void log(LoggingLevel loggingLevel, DCM_Application_Log__c log) {
        if (DCM_LoggerSettings.shouldCreateLog(loggingLevel)) {
            Runtime.StackTraceLine stackTraceLine = Runtime.getCaller();

            log.Application_Name__c = this.applicationName;
            log.Module_Name__c = this.moduleName;
            log.Class_Name__c = (null != stackTraceLine) ? stackTraceLine.apexClass : '';
            log.Method_Name__c = (null != stackTraceLine) ? stackTraceLine.apexClassMethod : '';
            log.Logging_Level__c = loggingLevel.name();
            log.Salesforce_Limits__c = DCM_PlatformUtil.getLimitsString();
            log.Running_User__c = UserInfo.getUserId();

            logs.add(log);

            if (immediate == true) {
                flush();
            }
        }
    }

    /**
     * Publishes all recorded logs and clears log buffer.
     * When logging is done in-between callouts, flush should be made after all callouts are finished.
     *
     * Logs are translated to Platform Event and then back from events to records to maintain logs created before unhandled exception.
     * This is mainly for AuraEnabled methods which may have to throw AuraHandledException for proper aura handling,
     * but would not be able to save logs under normal circumstances.
     */
    global void flush() {
        List<DCM_LoggingEvent__e> loggingEvents = new List<DCM_LoggingEvent__e>();

        for (DCM_Application_Log__c log : logs) {
            loggingEvents.add(
                new DCM_LoggingEvent__e(
                    Application_Name__c = log.Application_Name__c,
                    Module_Name__c = log.Module_Name__c,
                    Class_Name__c = log.Class_Name__c,
                    Method_Name__c = log.Method_Name__c,
                    Logging_Level__c = log.Logging_Level__c,
                    Message__c = log.Message__c,
                    Record_Id__c = log.Record_Id__c,
                    Exception_Line_Number__c = log.Exception_Line_Number__c,
                    Exception_Message__c = log.Exception_Message__c,
                    Exception_Stack_Trace__c = log.Exception_Stack_Trace__c,
                    Exception_Type__c = log.Exception_Type__c,
                    Response_Status_Code__c = log.Response_Status_Code__c,
                    Running_User__c = log.Running_User__c,
                    Salesforce_Limits__c = log.Salesforce_Limits__c
                )
            );
        }

        EventBus.publish(loggingEvents);
        logs.clear();
    }

    private static String truncateFieldValueBasedOnFieldSize(
        String fieldValue,
        DescribeFieldResult describeFieldResult
    ) {
        Integer maxFieldLength = describeFieldResult.getLength();
        if (String.isNotBlank(fieldValue)) {
            return (fieldValue.length() > maxFieldLength) ? fieldValue.substring(0, (maxFieldLength - 1)) : fieldValue;
        } else {
            return '';
        }
    }
}