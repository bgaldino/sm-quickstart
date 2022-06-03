public with sharing class SM_AssetBillingScheduleListController {
  @AuraEnabled(cacheable=true)
  public static List<BillingScheduleWrapper> getBillingSchedules(Id assetId) {
    try {
      List<BillingScheduleGroup> bsgs = [
        SELECT
          Id,
          ReferenceEntityId,
          (
            SELECT
              Id,
              BillingScheduleNumber,
              ReferenceEntityItemId,
              ReferenceEntityItem.Name,
              ReferenceEntityId,
              ReferenceEntity.Name,
              TotalAmount,
              BillingScheduleStartDate,
              BillingScheduleEndDate
            FROM BillingScheduleGroupToBillingSchedule
          )
        FROM BillingScheduleGroup
        WHERE ReferenceEntityId = :assetId
      ];

      List<BillingScheduleWrapper> bsgWrappers = new List<BillingScheduleWrapper>();
      for (BillingScheduleGroup bsg : bsgs) {
        for (BillingSchedule bs : bsg.BillingScheduleGroupToBillingSchedule) {
          BillingScheduleWrapper bsw = new BillingScheduleWrapper();
          bsw.id = bs.Id;
          bsw.name = bs.BillingScheduleNumber;
          bsw.refEntityId = bs.ReferenceEntityId;
          bsw.refEntityName = bs.ReferenceEntity.Name;
          bsw.refEntityItemId = bs.ReferenceEntityItemId;
          bsw.refEntityItemName = bs.ReferenceEntityItem.Name;
          bsw.totalAmount = bs.TotalAmount;
          bsw.startDate = bs.BillingScheduleStartDate;
          bsw.endDate = bs.BillingScheduleEndDate;
          bsgWrappers.add(bsw);
        }
      }
      return bsgWrappers;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  public class BillingScheduleWrapper {
    @AuraEnabled
    public String id { get; set; }
    @AuraEnabled
    public String name { get; set; }
    @AuraEnabled
    public String refEntityId { get; set; }
    @AuraEnabled
    public String refEntityName { get; set; }
    @AuraEnabled
    public String refEntityItemId { get; set; }
    @AuraEnabled
    public String refEntityItemName { get; set; }
    @AuraEnabled
    public Decimal totalAmount { get; set; }
    @AuraEnabled
    public Date startDate { get; set; }
    @AuraEnabled
    public Date endDate { get; set; }
  }
}
