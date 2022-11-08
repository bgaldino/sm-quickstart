/**
 * @description       :
 * @author            : Girish Kalidindi
 * @group             :
 * @last modified on  : 04-06-2021
 * @last modified by  : Devanshu Sood
 * Modifications Log
 * Ver   Date         Author             Modification
 * 1.0   08-12-2020   Girish Kalidindi   Initial Version
 **/
public inherited sharing class DCM_PlatformUtil {
    /**
     * @description Get Salesforce Governor Limits information
     * @author Girish Kalidindi | 08-12-2020
     * @return String Governor Limits Information as a String
     **/
    public static String getLimitsString() {
        String queryLimit =
            '1. SOQL Queries used / SOQL Queries allowed: ' +
            Limits.getQueries() +
            '/' +
            Limits.getLimitQueries();
        String dmlLimit =
            '2. Number of records queried so far /  Number allowed: ' +
            Limits.getDmlRows() +
            '/' +
            Limits.getLimitDmlRows();
        String dmlStat =
            '3. Number of DML statements used so far / Number allowed: ' +
            Limits.getDmlStatements() +
            '/' +
            Limits.getLimitDmlStatements();
        String cpuUsage =
            '4. Amount of CPU time (in ms) used so far / CPU usage time (in ms) allowed: ' +
            Limits.getCpuTime() +
            '/' +
            Limits.getLimitCpuTime();

        List<String> lstSalesforceLimit = new List<String>();
        lstSalesforceLimit.add(queryLimit);
        lstSalesforceLimit.add(dmlLimit);
        lstSalesforceLimit.add(dmlStat);
        lstSalesforceLimit.add(cpuUsage);

        return String.format('{0}\n{1}\n{2}\n{3}', lstSalesforceLimit);
    }

    /**
     * @description Get Stringified object using JSON.serializePretty. If that fails for any reason then it will instead use String.valueOf for the object.
     * @author Girish Kalidindi | 08-12-2020
     * @param obj Object to serialize
     * @return String Serialized Object
     **/
    // public static String getSerializedObject(Object obj) {
    //     if(null == obj) {
    //         return null;
    //     }
    //     String serializedOjb = null;
    //     try {
    //         serializedOjb = JSON.serializePretty(obj);
    //     }
    //     catch(Exception e) {
    //         serializedOjb = String.valueOf(obj);
    //     }
    //     return serializedOjb;
    // }

    /**
     * @description Check if specific Scheduled Job is currently Running
     * @author Girish Kalidindi | 08-13-2020
     * @param batchJobClassName
     * @return Boolean
     **/
    // public static Boolean isApexJobCurrentlyRunning(String batchJobClassName) {
    //     List<String> statusList = new List<String>{'Processing'};
    //     List<AsyncApexJob> jobList = [SELECT Id, Status, ApexClass.Name FROM AsyncApexJob where ApexClass.Name = :batchJobClassName and Status IN :statusList LIMIT 1];
    //     if (jobList.isEmpty()) {
    //         return false;
    //     }
    //     return true;
    // }
}
