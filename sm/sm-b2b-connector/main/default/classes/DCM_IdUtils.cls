@IsTest
public with sharing class DCM_IdUtils {

    private static final String ID_PATTERN = '000000000000';
    private static Integer numOfGeneratedIds = 0;

    public static Id generate(SObjectType objectType) {
        String sobjectKeyPrefix = objectType.getDescribe().getKeyPrefix();
        numOfGeneratedIds++;
        String idBody = ID_PATTERN.substring(0, 12 - numOfGeneratedIds.format().length());
        return Id.valueOf(sobjectKeyPrefix + idBody + numOfGeneratedIds);
    }

}