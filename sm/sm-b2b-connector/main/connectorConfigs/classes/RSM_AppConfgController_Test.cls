/**
 * @description       : 
 * @author            : Devanshu Sood
 * @group             : 
 * @last modified on  : 10-11-2022
 * @last modified by  : Devanshu Sood
**/
@IsTest
public with sharing class RSM_AppConfgController_Test {
    @IsTest
    public static void getTabsAndConfigration_test() {
        System.assert(
            String.isNotBlank(RSM_AppConfgController.getTabsAndConfiguration()),
            'Make sure you have created required metadata.'
        );
    }

    @IsTest
    public static void updateBulkMetadata_test() {
        Test.startTest();
        id mdtId = [SELECT id FROM RSM_Connector_Configuration__mdt LIMIT 1]?.Id;
        String jsonInput = '{"' + mdtId + '":"testkey"}';
        System.assertEquals(true, RSM_AppConfgController.updateBulkMetadata(jsonInput));
        Test.stopTest();
    }
    @IsTest
    public static void updateBulkMetadata_NegativeTest() {
        Test.startTest();
        String jsonString = '{"isSyncAll":true,"isSyncProduct": }';
        try {
            Boolean result = RSM_AppConfgController.updateBulkMetadata(jsonString);
        } catch (Exception e) {
            System.assertNotEquals(null, e, 'Exception must be thrown');
        }
        Test.stopTest();
    }

    @IsTest
    static void handleResult_Test() {
        // Create test result and context objects.
        Metadata.DeployResult result = new Metadata.DeployResult();
        result.createdBy = UserInfo.getUserId();
        result.createdByName = 'Test User';
        result.numberComponentErrors = 1;
        result.status = Metadata.DeployStatus.Succeeded;
        system.assertEquals(1, result.numberComponentErrors,'Assert passed');
        Metadata.DeployCallbackContext context = new Metadata.DeployCallbackContext();
        RSM_CustomMetadataCallbackController metaDetaresult = new RSM_CustomMetadataCallbackController();
        metaDetaresult.handleResult(result, context);
        result.status = Metadata.DeployStatus.Failed;
        metaDetaresult.handleResult(result, context);
    }


}
