/**
 * @author SF EMEA Pro Services, Sam Check
 * @date 03/14/2022
 * @description Controller for 'My Assets' Community LWC
 */

public with sharing class SM_MyAssetsController {
  @AuraEnabled
  public static List<AssetWrapper> getAllAssetsForCurrentUser() {
    User currentUserAccount = [
      SELECT Contact.AccountId
      FROM User
      WHERE Id = :Userinfo.getUserid()
    ];
    return getAllAssetsByAccount(currentUserAccount.Contact.AccountId);
  }

  @AuraEnabled
  public static List<AssetWrapper> getAllAssetsByAccount(Id accountId) {
    List<AssetWrapper> assetWrappers = new List<AssetWrapper>();

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
        CreatedDate
      FROM Asset
      WHERE accountId = :accountId
      ORDER BY Createddate DESC
    ];

    for (Asset asset : assets) {
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

    public AssetWrapper() {
      this.isSelected = false;
    }
  }
}
