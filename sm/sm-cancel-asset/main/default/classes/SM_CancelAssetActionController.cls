public with sharing class SM_CancelAssetActionController {
  @AuraEnabled
  public static void initAssetCancellation(Id assetId) {
    Map<String, Object> inputs = new Map<String, Object>();
    inputs.put('recordId', assetId);
    Flow.Interview.SM_Cancel_Asset cancelFlow = new Flow.Interview.SM_Cancel_Asset(
      inputs
    );
    cancelFlow.start();
    return;
  }

  @AuraEnabled
  public static Boolean canCancelAsset(Id assetId) {
    try {
      BillingScheduleGroup bsg = [
        SELECT Id, ReferenceEntityId, EffectiveNextBillingDate, CancellationDate
        FROM BillingScheduleGroup
        WHERE ReferenceEntityId = :assetId
      ];

      // if no effective next billing date or the cancellation date is populated (already cancelled) can't cancel
      if (
        bsg.EffectiveNextBillingDate == null ||
        bsg.CancellationDate != null
      ) {
        return false;
      }
      return true;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  @AuraEnabled
  public static String getAssetCancellationEffectiveDate(Id assetId) {
    BillingScheduleGroup bsg = [
      SELECT Id, ReferenceEntityId, EffectiveNextBillingDate
      FROM BillingScheduleGroup
      WHERE ReferenceEntityId = :assetId
    ];
    System.debug(bsg);
    DateTime dt = datetime.newInstance(
      bsg.EffectiveNextBillingDate,
      Time.newInstance(0, 0, 0, 0)
    );
    String formattedCancelDate = dt.format('yyyy-MM-dd\'T\'HH:mm:ssXXX');

    return formattedCancelDate;
  }
}
