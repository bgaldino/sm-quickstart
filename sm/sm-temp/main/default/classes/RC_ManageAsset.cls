public with sharing class RC_ManageAsset {
  private static final Integer REVCLOUDAPILIMIT = Integer.valueOf(
    System.Label.RevCloudAPILimit
  );
  private static final String ORG_BASE_URL = URL.getSalesforceBaseUrl()
    .getHost();
  private static final DCM_Logger LOGGER = DCM_Logger.getInstance();

  @AuraEnabled(cacheable=true)
  public static List<AssetInfo> getAssetInfo(Id assetId) {
    Map<Id, AssetInfo> assetInfoMap = new Map<Id, AssetInfo>();
    AssetInfo assetInfo;
    //First getting all the Assets of the Account and adding AssetInfo into the map
    for (Asset asset : [
      SELECT
        Id,
        Name,
        Next_Billing_Date__c,
        LifecycleStartDate,
        LifecycleEndDate,
        RenewalTerm,
        RenewalTermUnit,
        AccountId,
        CurrentQuantity,
        Product2Id
      FROM Asset
      WHERE Id = :assetId AND HasLifecycleManagement = TRUE
      WITH SECURITY_ENFORCED
      ORDER BY createdDate
    ]) {
      assetInfo = new AssetInfo();
      assetInfo.asset = asset;
      assetInfo.assetId = asset.Id;
      assetInfo.name = asset.name;
      assetInfo.lifeCycleStartDate = asset.LifecycleStartDate;
      assetInfo.lifeCycleEndDateStr = asset.LifecycleEndDate.format(
        'MM/dd/yyyy'
      );
      assetInfo.lifeCycleEndDate = asset.LifecycleEndDate;
      assetInfo.lifeCycleEndDateStr = asset.LifecycleEndDate.format(
        'MM/dd/yyyy'
      );
      assetInfo.renewalTerm = asset.RenewalTerm;
      assetInfo.renewalTermUnit = asset.RenewalTermUnit;
      assetInfo.nextBillingDate = asset.Next_Billing_Date__c;
      assetInfo.nextBillingDateStr = asset.Next_Billing_Date__c.format();
      assetInfo.recordURL = ORG_BASE_URL + '/' + asset.Id;
      assetInfo.modifyDate = string.valueof(asset.Next_Billing_Date__c)+'T00:00:00-00:00';
      assetInfoMap.put(asset.Id, assetInfo);
    }

    return assetInfoMap.values();
  }

  @AuraEnabled
  public static Map<String, Object> getAssetData(Id assetId) {
    Map<String, Object> assetData = new Map<String, Object>();
    if (assetId != null) {
      List<Asset> assets = [
        SELECT
          Id,
          Next_Billing_Date__c,
          Name,
          LifecycleStartDate,
          LifecycleEndDate
        FROM Asset
        WHERE Id = :assetId
        LIMIT 1
      ];

      if (!assets.isEmpty()) {
        Asset asset = assets[0];
        assetData.put('assetId', asset.Id);
        assetData.put('nextBillingDate', asset.Next_Billing_Date__c);
        assetData.put('nextBillingDateStr', asset.Next_Billing_Date__c.format());
        assetData.put('assetEndDate', asset.LifecycleEndDate);
        assetData.put('assetEndDateStr', asset.LifecycleEndDate.format('MM/dd/yyyy'));
        assetData.put('productName', asset.Name);
        assetData.put('assetStartDate', asset.LifecycleStartDate);
        assetData.put('assetStartDateStr', asset.LifecycleStartDate.format('MM/dd/yyyy'));
        assetData.put('modifyDate', string.valueof(asset.Next_Billing_Date__c)+'T00:00:00-00:00');
      }
    }
    return assetData;
  }

  /**
   * Used to call the SM Renew service through the Apex via Connect API
   * @param assetList list of assets to be renewed or cancelled
   * @return list of responses from the connectAPI output
   */

  @AuraEnabled
  public static List<AssetInfo> renewAssets(List<AssetInfo> assetList) {
    Map<Id, AssetInfo> responseList = new Map<Id, AssetInfo>();
    Map<Id, AssetInfo> assetMap = new Map<Id, AssetInfo>();
    List<Id> assetIds = new List<String>();
    ConnectApi.RevenueAsyncRepresentation response;
    for (AssetInfo asset : assetList) {
      assetIds.add(asset.assetId);
      assetMap.put(asset.assetId, asset);
      if (assetIds.size() == REVCLOUDAPILIMIT) {
        response = initiateRenewalAPI(assetIds);
        responseList = addStatusURL(assetIds, assetMap, response);
        assetIds = new List<String>();
      }
    }
    if (!assetIds.isEmpty()) {
      response = initiateRenewalAPI(assetIds);
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
  public static List<AssetInfo> cancelAssets(
    Id assetId,
    //List<AssetInfo> assetList,
    Datetime modifyDate
  ) {
    Datetime cancelDate;
    List<AssetInfo> assetList = getAssetInfo(assetId);
    LOGGER.error('assetList: '+assetList);
    Map<Id, AssetInfo> responseList = new Map<Id, AssetInfo>();
    Map<Id, AssetInfo> assetMap = new Map<Id, AssetInfo>();
    List<Id> assetIds = new List<String>();
    ConnectApi.RevenueAsyncRepresentation response;
    for (AssetInfo asset : assetList) {
      LOGGER.error('assetId: '+asset.assetId);
      assetIds.add(asset.assetId);
      assetMap.put(asset.assetId, asset);
      cancelDate = asset.nextBillingDate;
      LOGGER.error('assetIds.size(): '+assetIds.size()+' REVCLOUDAPILIMIT: '+REVCLOUDAPILIMIT+' assetIds: '+assetIds+' assetMap: '+assetMap+' response: '+response+' responseList: '+responseList+' asset: '+asset+' assetList: '+assetList+' cancelDate: '+cancelDate+' assetId: '+assetId+' assetList: '+assetList);
      if (assetIds.size() == REVCLOUDAPILIMIT) {
        response = initiateCancellationAPI(assetIds, cancelDate);
        LOGGER.error('response: '+response);
        responseList = addStatusURL(assetIds, assetMap, response);
        assetIds = new List<String>();
      }
    }
    if (!assetIds.isEmpty()) {
      response = initiateCancellationAPI(assetIds, cancelDate);
      LOGGER.error('response: '+response);
      responseList = addStatusURL(assetIds, assetMap, response);
    }
    return responseList.values();
  }

/*   @AuraEnabled
  public static Map<String,Object> cancelAsset(
    Id assetId
  ) {
    List<AssetInfo> assetList = getAssetInfo(assetId);
    String cancelDate = assetList[0].nextBillingDate.format();
    List<AssetInfo> responseList = new List<AssetInfo>();
    Map<Id, AssetInfo> assetMap = cancelAssets(assetList, cancelDate);
  }
 */
  @AuraEnabled
  public static List<AssetInfo> amendAssets(
    List<AssetInfo> assetList,
    Datetime amendDate,
    Integer quantity
  ) {
    Map<Id, AssetInfo> responseList = new Map<Id, AssetInfo>();
    Map<Id, AssetInfo> assetMap = new Map<Id, AssetInfo>();
    List<Id> assetIds = new List<String>();
    ConnectApi.RevenueAsyncRepresentation response;
    for (AssetInfo asset : assetList) {
      assetIds.add(asset.assetId);
      assetMap.put(asset.assetId, asset);
      if (assetIds.size() == REVCLOUDAPILIMIT) {
        response = initiateAmendQuantityAPI(assetIds, amendDate, quantity);
        responseList = addStatusURL(assetIds, assetMap, response);
        assetIds = new List<String>();
      }
    }
    if (!assetIds.isEmpty()) {
      response = initiateAmendQuantityAPI(assetIds, amendDate, quantity);
      responseList = addStatusURL(assetIds, assetMap, response);
    }
    return responseList.values();
  }

  public static ConnectApi.RevenueAsyncRepresentation initiateRenewalAPI(
    List<String> assetIds
  ) {
    ConnectApi.AssetMgmtInitiateRenewalInput input = new ConnectApi.AssetMgmtInitiateRenewalInput();
    input.assetIds = assetIds;
    return ConnectApi.AssetMgmt.initiateRenewal(input);
  }

  public static ConnectApi.RevenueAsyncRepresentation initiateCancellationAPI(
    List<String> assetIds,
    Datetime cancelDate
  ) {
    ConnectApi.AssetMgmtInitiateCancellationInput input = new ConnectApi.AssetMgmtInitiateCancellationInput();
    input.cancellationOutputType = ConnectApi.AssetMgmtCancellationType.Order;
    input.assetIds = assetIds;
    input.cancellationDate = cancelDate;
    return ConnectApi.AssetMgmt.initiateCancellation(input);
  }

  public static ConnectApi.RevenueAsyncRepresentation initiateAmendQuantityAPI(
    List<String> assetIds,
    Datetime amendDate,
    Integer quantity
  ) {
    ConnectApi.AssetMgmtInitiateAmendQtyInput input = new ConnectApi.AssetMgmtInitiateAmendQtyInput();
    input.amendmentOutputType = ConnectApi.AssetMgmtAmendmentType.Order;
    input.assetIds = assetIds;
    input.startDate = amendDate;
    input.quantityChange = quantity;
    return ConnectApi.AssetMgmt.initiateAmendQuantity(input);
  }

  private static Map<Id, AssetInfo> addStatusURL(
    List<String> assetIds,
    Map<Id, AssetInfo> assetMap,
    ConnectApi.RevenueAsyncRepresentation response
  ) {
    if (response.requestIdentifier != null) {
      Integer index = response.statusURL.lastIndexOf('/');
      for (Id assetId : assetIds) {
        assetMap.get(assetId).statusURL = response.statusURL.substring(
          index + 1
        ); //Status temporory field used to datatable
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
    public Asset asset { get; set; }

    @AuraEnabled
    public Id assetId { get; set; }

    @AuraEnabled
    public String name { get; set; }

    @AuraEnabled
    public String recordURL { get; set; }

    @AuraEnabled
    public Datetime lifeCycleStartDate { get; set; }

    @AuraEnabled
    public String lifeCycleStartDateStr { get; set; }

    @AuraEnabled
    public Datetime lifeCycleEndDate { get; set; }

    @AuraEnabled
    public String lifeCycleEndDateStr { get; set; }

    @AuraEnabled
    public String renewalTermUnit { get; set; }

    @AuraEnabled
    public Decimal renewalTerm { get; set; }

    @AuraEnabled
    public String statusURL { get; set; }

    @AuraEnabled
    public String requestIdentifier { get; set; }

    @AuraEnabled
    public Date nextBillingDate { get; set; }

    @AuraEnabled
    public String nextBillingDateStr { get; set; }

    @AuraEnabled
    public String modifyDate { get; set; }

    @AuraEnabled
    public String parentId {get;set;}
  }
}
