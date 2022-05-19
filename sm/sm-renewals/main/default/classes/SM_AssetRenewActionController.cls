public with sharing class SM_AssetRenewActionController {
  @AuraEnabled
  public static void initAssetRenewal(Id assetId) {
    Map<String, Object> inputs = new Map<String, Object>();
    inputs.put('recordId', assetId);
    Flow.Interview.SM_Renew_Asset renewFlow = new Flow.Interview.SM_Renew_Asset(
      inputs
    );
    renewFlow.start();
    return;
  }

  @AuraEnabled
  public static void updateAsset(Asset a) {
    try {
      if (String.isBlank(a.RenewalTermUnit)) {
        a.RenewalTermUnit = 'Months';
      }
      Database.update(a);
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  @AuraEnabled
  public static Asset getAssetRenewalTerms(Id assetId) {
    Asset asset = [
      SELECT
        Id,
        RenewalPricingType,
        RenewalTerm,
        RenewalTermUnit,
        CurrentLifecycleEndDate,
        LifecycleEndDate
      FROM Asset
      WHERE Id = :assetId
    ];

    return asset;
  }
}
