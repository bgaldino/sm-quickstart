/**
 * @author SF EMEA Pro Services, Sam Check
 * @date 03/14/2022
 * @description Controller for 'My Assets' Community LWC
 */

public with sharing class SM_MyAssetsController {
  private static final DCM_Logger LOGGER = DCM_Logger.getInstance();

  @AuraEnabled
  public static List<AssetWrapper> getAllAssetsForCurrentUser() {
    User currentUserAccount = [
      SELECT Contact.AccountId
      FROM User
      WHERE Id = :Userinfo.getUserid()
    ];
    LOGGER.debug(
      'Current User accountId: ' + currentUserAccount.Contact.AccountId
    );
    return getAllAssetsByAccount(currentUserAccount.Contact.AccountId);
  }

  @AuraEnabled
  public static List<AssetWrapper> getAllAssetsByAccount(Id accountId) {
    List<AssetWrapper> assetWrappers = new List<AssetWrapper>();
    LOGGER.debug('Asset Query accountId: ' + accountId);
    List<Asset> assets = [
      SELECT
        Id,
        Name,
        CurrentQuantity,
        TotalLifecycleAmount,
        Status,
        Product2.DisplayUrl,
        Product2.Family,
        CurrencyIsoCode,
        LifecycleStartDate,
        LifecycleEndDate,
        CurrentMrr,
        AccountId,
        RenewalTerm,
        RenewalTermUnit,
        CreatedDate
      FROM Asset
      WHERE accountId = :accountId
      ORDER BY Createddate DESC
    ];

    LOGGER.debug('Retrieved Asset is: ' + assets.toString());

    for (Asset asset : assets) {
      logger.debug(asset.Id);
      AssetWrapper assetWrapper = new AssetWrapper();
      assetWrapper.id = asset.Id;
      assetWrapper.accountId = asset.accountId;
      assetWrapper.Name = asset.Name;
      assetWrapper.currentQuantity = asset.currentQuantity;
      assetWrapper.totalLifecycleAmount = asset.totalLifecycleAmount;
      assetWrapper.lifecycleStartDate = asset.lifecycleStartDate;
      assetWrapper.lifecycleEndDate = asset.lifecycleEndDate;
      assetWrapper.createddate = asset.createddate;
      assetWrapper.currentMrr = asset.CurrentMrr;
      assetWrapper.currencyIsoCode = asset.CurrencyIsoCode;
      assetWrapper.displayUrl = asset.Product2.DisplayUrl;
      assetWrapper.family = asset.Product2.Family;
      assetWrapper.status = asset.Status;
      assetWrapper.renewalTerm = asset.renewalTerm;
      assetWrapper.renewalTermUnit = asset.renewalTermUnit;
      assetWrappers.add(assetWrapper);
    }

    return assetWrappers;
  }

  public class AssetWrapper {
    @AuraEnabled
    public string id { get; set; }
    @AuraEnabled
    public string accountId { get; set; }
    @AuraEnabled
    public string name { get; set; }
    @AuraEnabled
    public string currencyIsoCode { get; set; }
    @AuraEnabled
    public string displayUrl { get; set; }
    @AuraEnabled
    public string family { get; set; }
    @AuraEnabled
    public string status { get; set; }
    @AuraEnabled
    public DateTime lifecycleStartDate { get; set; }
    @AuraEnabled
    public DateTime lifecycleEndDate { get; set; }
    @AuraEnabled
    public DateTime createddate { get; set; }
    @AuraEnabled
    public Decimal currentQuantity { get; set; }
    @AuraEnabled
    public Decimal totalLifecycleAmount { get; set; }
    @AuraEnabled
    public Decimal currentMrr { get; set; }
    @AuraEnabled
    public Boolean isSelected { get; set; }
    @AuraEnabled
    public Decimal renewalTerm { get; set; }
    @AuraEnabled
    public String renewalTermUnit { get; set; }

    public AssetWrapper() {
      this.isSelected = false;
    }
  }

    /**
   * Used to call the SM Renew service through the Apex via Connect API
   * @param assetList list of assets to be renewed or cancelled
   * @return list of responses from the connectAPI output
   */

   @AuraEnabled
   public static List<String> renewAssets(List<AssetWrapper> assetList) {
     List<String> responseList = new List<String>();
     ConnectApi.RevenueAsyncRepresentation output;
     ConnectApi.AssetMgmtInitiateRenewalInput input;
     for (AssetWrapper asset : assetList) {
       List<String> idList = new List<String>();
       input = new ConnectApi.AssetMgmtInitiateRenewalInput();
       idList.add(asset.id);
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
     List<AssetWrapper> assetList,
     Datetime cancelDate
   ) {
     system.debug('test');
     List<String> responseList = new List<String>();
     ConnectApi.RevenueAsyncRepresentation output;
     ConnectApi.AssetMgmtInitiateCancellationInput input;
     for (AssetWrapper asset : assetList) {
       List<String> idList = new List<String>();
       input = new ConnectApi.AssetMgmtInitiateCancellationInput();
       idList.add(asset.id);
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
     List<AssetWrapper> assetList,
     Datetime startDate,
     Double quantityChange
   ) {
     system.debug('test');
     List<String> responseList = new List<String>();
     ConnectApi.RevenueAsyncRepresentation output;
     ConnectApi.AssetMgmtInitiateAmendQtyInput input;
     for (AssetWrapper asset : assetList) {
       List<String> idList = new List<String>();
       input = new ConnectApi.AssetMgmtInitiateAmendQtyInput();
       idList.add(asset.id);
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
