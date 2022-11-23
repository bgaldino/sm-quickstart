/*
* Use this class only when you want multiple configraion in one tranaction
* if you want to get only one config in transaction you can use standard getInstance method
* i.e Games__mdt mc = Games__mdt.getInstance('FirstRecord');
*/

public with sharing class RSM_ConnectorConfigrationSelector {
    private static Map<String, RSM_Connector_Configuration__mdt> configByDeveloperName {
        get {
            if (configByDeveloperName == null) {
                configByDeveloperName = RSM_Connector_Configuration__mdt.getAll();
            }
            return configByDeveloperName;
        }
        set;
    }

    public String getConfigByDeveloperName(string devName) {
        return configByDeveloperName.get(devName)?.Key__c;
    }

    public Map<String, String> getAllConfigByType(string configType) {
        return ( Map<String, String>) Collection.of([SELECT Id, Key__c,DeveloperName FROM RSM_Connector_Configuration__mdt WHERE Config_Type__c =: configType]).mapBy('DeveloperName', 'Key__c');
    }
}


// RSM_ConnectorConfigrationSelector sel = new RSM_ConnectorConfigrationSelector();
// system.debug(sel.getAllConfigByType(''));