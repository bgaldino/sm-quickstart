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
 * Accessor class for custom metadata settings in LoggerSetting__mdt
 */
public with sharing class DCM_LoggerSettings {

    public static final String NONE_LEVEL = 'NONE'; // ignore all logging
    public static final String ERROR_LEVEL = 'ERROR';
    public static final String WARNING_LEVEL = 'WARN';
    public static final String INFO_LEVEL = 'INFO';
    public static final String DEBUG_LEVEL = 'DEBUG';

    public static final String DEFAULT_LOG_LEVEL = ERROR_LEVEL;
    private static final Map<String, Integer> LEVELS_PRIORITY = new Map<String, Integer>{
            NONE_LEVEL => 0,
            ERROR_LEVEL => 1,
            WARNING_LEVEL => 2,
            INFO_LEVEL => 3,
            DEBUG_LEVEL => 4
    };

    private static final String LOG_LEVEL_NOT_SUPPORTED = 'Log level {0} is not supported';

    /**
     * Logging level from system setting for the current user.
     * If settings was not set it returns default log level value.
     */
    @TestVisible
    private static String userLoggingLevel {
        get {
            if ( userLoggingLevel == null ) {
                DCM_LoggerSettings__c loggerSettings = DCM_LoggerSettings__c.getInstance();
                userLoggingLevel = ( loggerSettings == null ) ? DEFAULT_LOG_LEVEL : loggerSettings.LoggingLevel__c;
                if ( !LEVELS_PRIORITY.containsKey(userLoggingLevel) ) {
                    userLoggingLevel = DEFAULT_LOG_LEVEL;
                }
            }
            return userLoggingLevel;
        }
        set;
    }

    /**
     * @return True if log with given LoggingLevel should be created.
     */
    public static Boolean shouldCreateLog(LoggingLevel level) {
        Integer logPriority = LEVELS_PRIORITY.get(String.valueOf(level));

        if (logPriority == null) {
            throw new LogException(String.format(LOG_LEVEL_NOT_SUPPORTED, new List<String>{ String.valueOf(level) }));
        }

        Integer userPriority = LEVELS_PRIORITY.get(userLoggingLevel);

        return (Test.isRunningTest() || userPriority >= logPriority);
    }

    /**
     * @return Date of the last day when log should be retained.
     */
    public static Date getRetentionDate() {
        DCM_LoggerSettings__c setting = DCM_LoggerSettings__c.getInstance();

        if (setting == null || setting.RetentionDays__c == null) {
            return Date.newInstance(1900, 1, 1);
        } else {
            Integer days = Integer.valueOf(setting.RetentionDays__c);
            return Date.today().addDays(-days);
        }
    }

    private inherited sharing class LogException extends Exception {

    }
}