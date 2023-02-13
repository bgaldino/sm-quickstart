/**
 * Tests for the Asset Management Controller
 * ConnectAPI needs SeeAllData = true.
 */
@IsTest(SeeAllData=true)
public with sharing class AssetManagementControllerTest {
    
    private static void makeData(){
        
        //Inserting Product
        Product2 product = new Product2(Name = 'Revenue Cloud Test Product 1', IsActive = true);
        insert product;
        
        // Get the Standard Price Book ID
        Id spb = Test.getStandardPricebookId();
        //Updating Standard Price Book
        update new Pricebook2(Id = spb , isActive = true);
 
        PricebookEntry priceBookEntry = new PricebookEntry(
            Pricebook2Id = spb, Product2Id = product.Id, 
            UnitPrice = 100, UseStandardPrice = false, IsActive = true);
       
        
        insert priceBookEntry;
        
        
        //Test Account
        Account acc = new Account(Name = 'Revenue Cloud Test Account');
        insert acc;
        //Test Asset
        Asset asset = new Asset(Name = 'Testing', AccountId = acc.Id, Product2Id = product.Id);
        insert asset;
    }
    
    @isTest static void testRenewAsset() {
        makeData();
        
        List<Asset> assetList = [Select Id, Name from Asset limit 1];
        System.assertEquals(assetList.size(), 1, 'Asset size should be 1');
        List<AssetManagementController.AssetInfo> responseList;
        if(!assetList.isEmpty()){
            responseList = AssetManagementController.renewAssets(makeAssetInfo(assetList));
            System.assertEquals(1, responseList.size(), 'Response size should be 1');
        }
    }
    
    @IsTest static void testCancelAsset() {
        makeData();
        
        List<Asset> assetList = [Select Id, Name from Asset limit 1];
        System.assertEquals(assetList.size(), 1, 'Asset size should be 1');
        List<AssetManagementController.AssetInfo> responseList;
        if(!assetList.isEmpty()){
            responseList = AssetManagementController.cancelAssets(makeAssetInfo(assetList), system.today());
            System.assertEquals(1, responseList.size(), 'Response size should be 1');
        }
    }

    @IsTest static void testAmendAsset() {
        makeData();
        
        List<Asset> assetList = [Select Id, Name from Asset limit 1];
        System.assertEquals(assetList.size(), 1, 'Asset size should be 1');
        List<AssetManagementController.AssetInfo> responseList;
        if(!assetList.isEmpty()){
            responseList = AssetManagementController.amendAssets(makeAssetInfo(assetList), system.today(), 5);
            System.assertEquals(1, responseList.size(), 'Response size should be 1');
        }
    }
    
    @IsTest static void testAssetData() {
        makeData();
        
        Id accountId = [Select Id from Account limit 1].Id;
        System.assertNotEquals(accountId, null, 'Account should not be null');
        
        List<AssetManagementController.AssetInfo> assetList = AssetManagementController.getAssetsByAccount(accountId);
        System.assertNotEquals(assetList.size(), null, 'asset are not retrived');
    }

    private static List<AssetManagementController.AssetInfo> makeAssetInfo(List<Asset> assetsList) {
        List<AssetManagementController.AssetInfo> assetInfoList = new List<AssetManagementController.AssetInfo>();
        for(Asset a : assetsList) {
            AssetManagementController.AssetInfo info = new AssetManagementController.AssetInfo();
            info.assetId = a.Id;
            info.Name = a.Name;
            assetInfoList.add(info);
        }
        return assetInfoList;
    }
}