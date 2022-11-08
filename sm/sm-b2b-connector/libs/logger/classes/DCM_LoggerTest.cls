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
@IsTest
private class DCM_LoggerTest {

    /**
     * In immediate mode all logs are saved in database right away.
     */
    @IsTest
    static void testLogMessageInImmediateMode() {
        DCM_LoggerSettings.userLoggingLevel = DCM_LoggerSettings.INFO_LEVEL;
        DCM_Logger logger = DCM_Logger.getImmediateInstance();


        Test.startTest();
        logger.info('INFO');
        logger.warn('WARN');
        logger.error('ERROR');
        Test.stopTest();

        DCM_Application_Log__c[] logs = [SELECT Class_Name__c,Record_Id__c, Message__c, Logging_Level__c, Method_Name__c FROM DCM_Application_Log__c];
        for (DCM_Application_Log__c log : logs) {
            System.assertEquals(String.valueOf(DCM_LoggerTest.class), log.Class_Name__c);
            System.assertEquals(DCM_LoggerTest.class + '.testLogMessageInImmediateMode', log.Method_Name__c);
            System.assertEquals(log.Message__c, log.Logging_Level__c);
            System.assertEquals(null, log.Record_Id__c);
        }
    }


    /**
     * In non-immediate mode all logs are saved in database when flush method is called.
     * This mode is especially useful for logging in-between callouts.
     */
    @IsTest
    static void testLogMessageInNonImmediateMode() {
        DCM_Logger logger = DCM_Logger.getInstance();


        Test.startTest();
        logger.info('INFO');
        logger.warn('WARN');
        logger.error('ERROR');
        logger.flush();
        Test.stopTest();


        DCM_Application_Log__c[] logs = [SELECT Class_Name__c,Record_Id__c, Message__c, Logging_Level__c, Method_Name__c FROM DCM_Application_Log__c];
        for (DCM_Application_Log__c log : logs) {
            System.assertEquals(String.valueOf(DCM_LoggerTest.class), log.Class_Name__c);
            System.assertEquals(DCM_LoggerTest.class + '.testLogMessageInNonImmediateMode', log.Method_Name__c);
            System.assertEquals(log.Message__c, log.Logging_Level__c);
            System.assertEquals(null, log.Record_Id__c);
        }
    }


    /**
     * Log record can be passed as argument for full details customization
     */
    @IsTest
    static void testLogRecord() {
        DCM_Logger logger = DCM_Logger.getImmediateInstance();


        Test.startTest();
        logger.info(new DCM_Application_Log__c(
                Message__c = 'INFO',
                Record_Id__c = '12345'
        ));
        logger.warn(new DCM_Application_Log__c(
                Message__c = 'WARN',
                Record_Id__c = '12345'
        ));
        logger.error(new DCM_Application_Log__c(
                Message__c = 'ERROR',
                Record_Id__c = '12345'
        ));
        Test.stopTest();


        DCM_Application_Log__c[] logs = [SELECT Class_Name__c,Record_Id__c, Message__c, Logging_Level__c FROM DCM_Application_Log__c];
        for (DCM_Application_Log__c log : logs) {
            System.assertEquals(String.valueOf(DCM_LoggerTest.class), log.Class_Name__c);
            System.assertEquals(log.Message__c, log.Logging_Level__c);
            System.assertEquals('12345', log.Record_Id__c);
        }
    }
    
    @IsTest
    static void testLogDebugMethod1() {
        DCM_Logger logger = DCM_Logger.getInstance('Test Module');

        Test.startTest();
            logger.debug('Test message');
        	logger.debug('refId', 'Test message');
            logger.flush();
        Test.stopTest();


        List<DCM_Application_Log__c> logs = [SELECT Class_Name__c,Record_Id__c, Message__c, Logging_Level__c FROM DCM_Application_Log__c];
        System.assertEquals(true, logs.size() > 0);
    }
    
    @IsTest
    static void testLogDebugMethod2() {
        DCM_Logger logger = DCM_Logger.getImmediateInstance('Test Module');

        Test.startTest();
            try {
                Date d = (Date) Datetime.now();
            } catch (Exception ex) {
                logger.debug(ex);
                logger.debug('refId', ex);
                logger.info(ex);
            }
        Test.stopTest();


        List<DCM_Application_Log__c> logs = [SELECT Class_Name__c,Record_Id__c, Message__c, Logging_Level__c FROM DCM_Application_Log__c];
        System.assertEquals(true, logs.size() > 0);
    }


    /**
     *@description
     * Logger.error() method can take exception as argument.
     * Logs message should contain exception's message, stack trace and cause.
     */
    @IsTest
    static void testLogExceptionMethod1() {
        DCM_Logger logger = DCM_Logger.getInstance();

        Test.startTest();
        try {
            Date d = (Date) Datetime.now();
        } catch (Exception ex) {
            logger.info('refId', ex);
            logger.warn('refId', ex);
            logger.error(ex);
        }
        finally {
            logger.flush();
        }
        Test.stopTest();


        DCM_Application_Log__c log = [SELECT Class_Name__c,Record_Id__c, Message__c, Logging_Level__c FROM DCM_Application_Log__c LIMIT 1];
        System.assert(log.Message__c.contains('Invalid conversion from runtime type Datetime to Date'), 'Message should contain exception message');
        System.assert(log.Message__c.contains(DCM_LoggerTest.class + '.testLogException'), 'Message should contain stack trace');
        System.assertEquals(String.valueOf(DCM_LoggerTest.class), log.Class_Name__c);
    }

    /**
     *@description
     * Logger.error() method can take exception as argument.
     * Logs message should contain exception's message, stack trace and cause.
     */
    @IsTest
    static void testLogExceptionMethod2() {
        DCM_Logger logger = DCM_Logger.getInstance();


        Test.startTest();
        try {
            Date d = (Date) Datetime.now();
        } catch (Exception ex) {
            logger.info('refId', ex);
            logger.warn('refId', ex);
            logger.error('refId', 'Test Error Message', ex);
        }
        finally {
            logger.flush();
        }
        Test.stopTest();


        DCM_Application_Log__c log = [SELECT Class_Name__c,Record_Id__c, Message__c, Logging_Level__c FROM DCM_Application_Log__c LIMIT 1];
        System.assert(log.Message__c.contains(DCM_LoggerTest.class + '.testLogException'), 'Message should contain stack trace');
        System.assertEquals(String.valueOf(DCM_LoggerTest.class), log.Class_Name__c);
    }

    /**
     *@description
     * Logger should be able to format and log HttpRequest and Responses
     */
    @IsTest
    static void testLogHttp() {
        DCM_LoggerSettings.userLoggingLevel = DCM_LoggerSettings.INFO_LEVEL;

        DCM_Logger logger = DCM_Logger.getInstance();
        HttpRequest request = new HttpRequest();
        request.setMethod('GET');
        request.setEndpoint('https://www.example.com');
        request.setBody('{"value":"test"}');

        HttpResponse response = new HttpResponse();
        response.setStatus('OK');
        response.setStatusCode(200);
        response.setBody('success');


        Test.startTest();
        logger.info('refId', request, response);
        logger.warn('refId', null, response);
        logger.error('refId', request, null);
        logger.flush();
        Test.stopTest();


        DCM_Application_Log__c log = [SELECT Message__c FROM DCM_Application_Log__c WHERE Logging_Level__c = 'INFO' LIMIT 1];
        System.assert(log.Message__c.contains('200 OK'));
        System.assert(log.Message__c.contains('{"value":"test"}'));
    }


    /**
     *@description
     * Logger should be able to format and log HttpRequest and Responses
     */
    @IsTest
    static void testLogREST() {
        DCM_LoggerSettings.userLoggingLevel = DCM_LoggerSettings.INFO_LEVEL;

        DCM_Logger logger = DCM_Logger.getInstance();
        RestRequest request = new RestRequest();
        request.httpMethod = 'GET';
        request.resourcePath = 'https://www.example.com?param=value';
        request.addParameter('param', 'value');
        request.requestBody = Blob.valueOf('request');

        RestResponse response = new RestResponse();
        response.statusCode = 200;
        response.responseBody = Blob.valueOf('success');


        Test.startTest();
        logger.info('refId', request, response);
        logger.warn('refId', null, response);
        logger.error('refId', request, null);
        logger.flush();
        Test.stopTest();


        DCM_Application_Log__c log = [SELECT Message__c FROM DCM_Application_Log__c WHERE Logging_Level__c = 'INFO' LIMIT 1];
        System.assert(log.Message__c.contains('200'));
        System.assert(log.Message__c.contains('success'));
        System.assert(log.Message__c.contains('request'));
        System.assert(log.Message__c.contains('param: value'));
    }
}