@IsTest
private class DCM_LoggerSettingsTest {

    @IsTest
    static void testLogLevelNotSupported() {
        try {
            DCM_LoggerSettings.shouldCreateLog(LoggingLevel.FINE);
        }
        catch(Exception e) {
            System.assertEquals('r1sm.DCM_LoggerSettings.LogException', e.getTypeName());
        }
    }
    
    @IsTest
    static void testLogLevelSupported() {
    	Boolean shouldCreateLog = DCM_LoggerSettings.shouldCreateLog(LoggingLevel.ERROR);
		System.assertEquals(true, shouldCreateLog);
    }
    
    @IsTest
    static void testRetentionDate() {
    	Date retentionDate = DCM_LoggerSettings.getRetentionDate();
		System.assertNotEquals(null, retentionDate);
    }
}