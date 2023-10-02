public with sharing class AssetManagementController {

    private static final Integer REVCLOUDAPILIMIT = Integer.valueOf(System.Label.RevCloudAPILimit);
    private static final String ORG_BASE_URL = URL.getOrgDomainUrl().getHost();
    
    /**
     * This is used for retreiving the Assets from Account which has HasLifecycleManagement is true
     * @param accountId
     * @return list of Assets with StartDate, EndDate and Renewal Fields
     */
    @AuraEnabled(cacheable=true)
    public static List<AssetInfo> getAssetsByAccount(String accountId){
        Map<Id, AssetInfo> assetInfoMap = new Map<Id, AssetInfo>();
        AssetInfo assetInfo;
        //First getting all the Assets of the Account and adding AssetInfo into the map
        for(Asset asset : [SELECT Id, Name, LifecycleStartDate, LifecycleEndDate, 
                            RenewalTerm, RenewalTermUnit, AccountId, CurrentQuantity, Product2Id
        FROM Asset Where AccountId =: accountId and HasLifecycleManagement = TRUE WITH SECURITY_ENFORCED Order By createdDate]){
            assetInfo = new AssetInfo();
            assetInfo.asset = asset;
            assetInfo.assetId = asset.Id;
            assetInfo.name = asset.name;
            assetInfo.lifeCycleStartDate = asset.LifecycleStartDate;
            assetInfo.lifeCycleEndDate = asset.LifecycleEndDate;
            assetInfo.renewalTerm = asset.RenewalTerm;
            assetInfo.renewalTermUnit = asset.RenewalTermUnit;
            assetInfo.recordURL = ORG_BASE_URL + '/'+ asset.Id;
            assetInfoMap.put(asset.Id, assetInfo);
        }

        //If there is a bundle to show the heirarchy, for every AssetInfo parent Id is required to generate the tree here
        //Using the relation to populate the parentId to the POJO AssetInfo.
        for(AssetRelationShip ars :  [SELECT Id, AssetId,  RelatedAssetid FROM AssetRelationship where Asset.AccountId =: accountId Order By AssetId]){
            assetInfoMap.get(ars.RelatedAssetid).parentId = ars.AssetId;
        }
        return assetInfoMap.values();
    }

    /**
     * Used to call the SM Renew service through the Apex via Connect API
     * @param assetList list of assets to be renewed or cancelled
     * @return list of responses from the connectAPI output
     */
    
    @AuraEnabled
    public static List<AssetInfo> renewAssets(List<AssetInfo> assetList){
        Map<Id, AssetInfo> responseList = new Map<Id, AssetInfo>();
        Map<Id, AssetInfo> assetMap = new Map<Id, AssetInfo>();
        List<Id> assetIds = new List<String>();
        ConnectApi.RevenueAsyncRepresentation response;
        for(AssetInfo asset : assetList) {
            assetIds.add(asset.assetId);
            assetMap.put(asset.assetId, asset);
            if(assetIds.size() == REVCLOUDAPILIMIT){
                response =  AssetManagementAPIs.renewAssetsAPI(assetIds);
                responseList = addStatusURL(assetIds, assetMap, response);
                assetIds = new List<String>();
            }
        }
        if(!assetIds.isEmpty()){
            response = AssetManagementAPIs.renewAssetsAPI(assetIds);
            responseList = addStatusURL(assetIds, assetMap, response);
        }
        return responseList.values();
    }

    /**
     * Used to call the SM Cancel service through the Apex via Connect API
     * @param assetList list of assets to be renewed or cancelled
     * @param cancelDate Date for the Cancel Service,
     * @return list of responses from the connectAPI output
     */
    
    @AuraEnabled
    public static List<AssetInfo> cancelAssets(List<AssetInfo> assetList, Datetime cancelDate){
        Map<Id, AssetInfo> responseList = new Map<Id, AssetInfo>();
        Map<Id, AssetInfo> assetMap = new Map<Id, AssetInfo>();
        List<Id> assetIds = new List<String>();
        ConnectApi.RevenueAsyncRepresentation response;
        for(AssetInfo asset : assetList) {
            assetIds.add(asset.assetId);
            assetMap.put(asset.assetId, asset);
            if(assetIds.size() == REVCLOUDAPILIMIT){
                response = AssetManagementAPIs.cancelAssetsAPI(assetIds, cancelDate);
                responseList = addStatusURL(assetIds, assetMap, response);
                assetIds = new List<String>();
            }
        }
        if(!assetIds.isEmpty()){
            response = AssetManagementAPIs.cancelAssetsAPI(assetIds, cancelDate);
            responseList = addStatusURL(assetIds, assetMap, response);
        }
        return responseList.values();
    }


    /**
     * Used to call the SM Amend service through the Apex via Connect API
     * @param assetList list of assets to be renewed or cancelled
     * @param amendDate Date for the amend Service extending
     * @param quantity number of quantity to increase on the Asset
     * @return list of responses from the connectAPI output
     */
    
    @AuraEnabled
    public static List<AssetInfo> amendAssets(List<AssetInfo> assetList, Datetime amendDate, Integer quantity){
        Map<Id, AssetInfo> responseList = new Map<Id, AssetInfo>();
        Map<Id, AssetInfo> assetMap = new Map<Id, AssetInfo>();
        List<Id> assetIds = new List<String>();
        ConnectApi.RevenueAsyncRepresentation response;
        for(AssetInfo asset : assetList) {
            assetIds.add(asset.assetId);
            assetMap.put(asset.assetId, asset);
            if(assetIds.size() == REVCLOUDAPILIMIT){
                response = AssetManagementAPIs.amendAssetsAPI(assetIds, amendDate, quantity);
                responseList = addStatusURL(assetIds, assetMap, response);
                assetIds = new List<String>();
            }
        }
        if(!assetIds.isEmpty()){
            response = AssetManagementAPIs.amendAssetsAPI(assetIds, amendDate, quantity);
            responseList = addStatusURL(assetIds, assetMap, response);
        }
        return responseList.values();
    }

    /**
     * Used to get RevenueAsyncOperation Status for the operation client made
     */
    @AuraEnabled
    public static Map<Id, RevenueAsyncOperation> processAsyncData(List<String> asyncIds) {
        return new Map<Id, RevenueAsyncOperation>([SELECT Id, Status FROM RevenueAsyncOperation Where Id IN: asyncIds WITH SECURITY_ENFORCED]);
    }

    private static Map<Id, AssetInfo> addStatusURL(List<String> assetIds, Map<Id, AssetInfo> assetMap, ConnectApi.RevenueAsyncRepresentation response){
        if(response.requestIdentifier != null) {
            Integer index=response.statusURL.lastIndexOf('/');
            for(Id assetId : assetIds){
                assetMap.get(assetId).statusURL = response.statusURL.substring(index+1); //Status temporory field used to datatable
                assetMap.get(assetId).requestIdentifier = response.requestIdentifier;
            }
            return assetMap;
        }
        throw new AuraHandledException('Error While sending the request');
    }

    /**
     * This POJO Class is used to show on the UI
     * Status URL and requestIdentifier are used to track the changes
     */
    public class AssetInfo { 
        @AuraEnabled
        public Asset asset{get;set;}

        @AuraEnabled
        public Id assetId{get;set;}

        @AuraEnabled
        public String name{get;set;}

        @AuraEnabled
        public String recordURL {get; set;}

        @AuraEnabled
        public Datetime lifeCycleStartDate{get;set;}

        @AuraEnabled
        public Datetime lifeCycleEndDate{get;set;}

        @AuraEnabled
        public String renewalTermUnit{get;set;}

        @AuraEnabled
        public Decimal renewalTerm{get;set;}

        @AuraEnabled
        public String statusURL{get;set;}

        @AuraEnabled
        public String requestIdentifier{get;set;}

        @AuraEnabled
        public String parentId {get;set;}
    }
}