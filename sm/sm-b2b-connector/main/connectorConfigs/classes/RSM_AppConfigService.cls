/**
 * @description       : 
 * @author            : Devanshu Sood
 * @group             : 
 * @last modified on  : 10-10-2022
 * @last modified by  : Devanshu Sood
**/
public with sharing class RSM_AppConfigService {
    public static final String CONFIG_TABS = 'RSM_App_Tabs';
    public static final String META_NAME = 'RSM_Connector_Configuration__mdt';

    private static final DCM_Logger LOGGER = DCM_Logger.getInstance(B2B_Constants.Module.APP_CONFIG);

    /**
     * :get All tabs and configuration to show on Config  APP page
     *
     * @return string
     *
     * @author Devanshu Sood | 04-05-2021
     **/
    public static String getTabsAndConfiguration() {
        //get tabs which need to be displayed in DR App
        String response;

        RSM_Application_Configuration__mdt tabs = RSM_Application_Configuration__mdt.getInstance(CONFIG_TABS);
        List<String> visibleTabs = tabs.Key__c.split(',');
        Map<String, List<Object>> mapTypeConfig = new Map<String, List<Object>>();
        for (RSM_Connector_Configuration__mdt mdt : [
            SELECT Id, Label, Helper_Text__c, Key__c, Visible__c, Config_Type__c, Display_Order__c
            FROM RSM_Connector_Configuration__mdt
            WHERE Config_Type__c IN :visibleTabs AND Visible__c = TRUE
            WITH SECURITY_ENFORCED
            ORDER BY Display_Order__c ASC
        ]) {
            if (mapTypeConfig.containsKey(mdt.Config_Type__c)) {
                mapTypeConfig.get(mdt.Config_Type__c).add(mdt);
            } else {
                mapTypeConfig.put(mdt.Config_Type__c, new List<Object>{ mdt });
            }
        }

        response = JSON.serialize(mapTypeConfig);

        return response;
    }

    /**
     * :this method supports updating of bulk metadata
     *
     * @param jsonString
     *
     * @return Boolean
     *
     * @author Devanshu Sood | 04-05-2021
     **/
    public static Boolean updateBulkMetadata(String jsonString) {
        Boolean isSuccess = true;
        // String nameSpace = DRB2B_Utility.nameSpacePrefix();
        try {
            Map<String, Object> metaDataToUpdate = (Map<String, Object>) JSON.deserializeUntyped(jsonString);
            Metadata.DeployContainer mdContainer = new Metadata.DeployContainer();
            for (RSM_Connector_Configuration__mdt objMetadata : [
                SELECT Id, DeveloperName, MasterLabel, Label, Key__c
                FROM RSM_Connector_Configuration__mdt
                WHERE Id IN :metaDataToUpdate.keySet()
            ]) {
                Metadata.CustomMetadata metadataRec = new Metadata.CustomMetadata();

                //once namespace intoduced, we need to namespace here dynamically
                metadataRec.fullName = META_NAME + '.' + objMetadata.DeveloperName;
                metadataRec.label = objMetadata.MasterLabel;
                Metadata.CustomMetadataValue customFieldtoUpdate = new Metadata.CustomMetadataValue();
                customFieldtoUpdate.field = RSM_Connector_Configuration__mdt.Key__c.getDescribe().getName();
                customFieldtoUpdate.value = metaDataToUpdate.get(objMetadata.Id);
                metadataRec.values.add(customFieldtoUpdate);
                mdContainer.addMetadata(metadataRec);
            }

            RSM_CustomMetadataCallbackController callback = new RSM_CustomMetadataCallbackController();
            Id jobId;
            if (!Test.isRunningTest()) {
                jobId = Metadata.Operations.enqueueDeployment(mdContainer, callback);
            }
        } catch (Exception e) {
            isSuccess = false;
            LOGGER.error(e);

            throw new AuraHandledException(e.getMessage());
        } finally {
            LOGGER.flush();
        }

        return isSuccess;
    }

}
