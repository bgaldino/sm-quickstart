public with sharing class AssetManagementController {
  /**
   * This is used for retreiving the Assets from Account which has HasLifecycleManagement is true
   * @param accountId
   * @return list of Assets with StartDate, EndDate and Renewal Fields
   */
  @AuraEnabled(cacheable=true)
  public static List<Asset> getAssetsByAccount(String accountId) {
    return [
      SELECT
        Id,
        Name,
        LifecycleStartDate,
        LifecycleEndDate,
        RenewalTerm,
        RenewalTermUnit
      FROM Asset
      WHERE AccountId = :accountId AND HasLifecycleManagement = TRUE
      ORDER BY createdDate
    ];
  }

  /**
   * Used to call the SM Renew service through the Apex via Connect API
   * @param assetList list of assets to be renewed or cancelled
   * @return list of responses from the connectAPI output
   */

  @AuraEnabled
  public static List<String> renewAssets(List<Asset> assetList) {
    List<String> responseList = new List<String>();
    ConnectApi.RevenueAsyncRepresentation output;
    ConnectApi.AssetMgmtInitiateRenewalInput input;
    for (Asset asset : assetList) {
      List<String> idList = new List<String>();
      input = new ConnectApi.AssetMgmtInitiateRenewalInput();
      idList.add(asset.Id);
      input.assetIds = idList;

      output = ConnectApi.AssetMgmt.initiateRenewal(input);
      responseList.add(string.valueOf(output));
    }
    return responseList;
  }

  /**
   * Used to call the SM Cancel service through the Apex via Connect API
   * @param assetList list of assets to be renewed or cancelled
   * @param cancelDate Date for the Cancel Service,
   * @return list of responses from the connectAPI output
   */

  @AuraEnabled
  public static List<String> cancelAssets(
    List<Asset> assetList,
    Datetime cancelDate
  ) {
    system.debug('test');
    List<String> responseList = new List<String>();
    ConnectApi.RevenueAsyncRepresentation output;
    ConnectApi.AssetMgmtInitiateCancellationInput input;
    for (Asset asset : assetList) {
      List<String> idList = new List<String>();
      input = new ConnectApi.AssetMgmtInitiateCancellationInput();
      idList.add(asset.Id);
      input.assetIds = idList;
      input.cancellationDate = cancelDate;
      input.cancellationOutputType = ConnectApi.AssetMgmtCancellationType.Order;
      output = ConnectApi.AssetMgmt.initiateCancellation(input);
      responseList.add(string.valueOf(output));
    }
    return responseList;
  }

  /**
   * Used to call the SM Amend service through the Apex via Connect API
   * @param assetList list of assets to be amended
   * @param startlDate Date for the Amend Service
   * @param quantityChange Quantity to add to the asset's existing quantity
   * @return list of responses from the connectAPI output
   */

  @AuraEnabled
  public static List<String> amendAssets(
    List<Asset> assetList,
    Datetime startDate,
    Double quantityChange
  ) {
    system.debug('test');
    List<String> responseList = new List<String>();
    ConnectApi.RevenueAsyncRepresentation output;
    ConnectApi.AssetMgmtInitiateAmendQtyInput input;
    for (Asset asset : assetList) {
      List<String> idList = new List<String>();
      input = new ConnectApi.AssetMgmtInitiateAmendQtyInput();
      idList.add(asset.Id);
      input.assetIds = idList;
      input.startDate = startDate;
      input.quantityChange = quantityChange;
      input.amendmentOutputType = ConnectApi.AssetMgmtAmendmentType.Order;
      output = ConnectApi.AssetMgmt.initiateAmendQuantity(input);
      responseList.add(string.valueOf(output));
    }
    return responseList;
  }
}
