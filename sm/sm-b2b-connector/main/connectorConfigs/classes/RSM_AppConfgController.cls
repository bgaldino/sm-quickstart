/**
 * @description       : 
 * @author            : Devanshu Sood
 * @group             : 
 * @last modified on  : 10-10-2022
 * @last modified by  : Devanshu Sood
**/
public with sharing class RSM_AppConfgController {
    private static final DCM_Logger LOGGER = DCM_Logger.getInstance(B2B_Constants.Module.APP_CONFIG);
    @AuraEnabled
    public static String getTabsAndConfiguration() {
        String result;

        try {
            result = RSM_AppConfigService.getTabsAndConfiguration();
        } catch (Exception e) {
            LOGGER.error(e);
            throw new AuraHandledException(e.getMessage());
        } finally {
            LOGGER.flush();
        }

        return result;
    }

    @AuraEnabled
    public static Boolean updateBulkMetadata(String jsonString) {
        Boolean result;

        try {
            result = RSM_AppConfigService.updateBulkMetadata(jsonString);
        } catch (Exception e) {
            LOGGER.error(e);
            throw new AuraHandledException(e.getMessage());
        } finally {
            LOGGER.flush();
        }

        return result;
    }
}
