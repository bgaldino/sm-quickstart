public with sharing class SM_AccountInvoiceListController {
  private static final DCM_Logger LOGGER = DCM_Logger.getInstance();

  @AuraEnabled(cacheable=true)
  public static List<Invoice> getAccountInvoices(Id accountId) {
    try {
      return [
        SELECT
          Id,
          DocumentNumber,
          BillingAccountId,
          CreatedDate,
          Balance,
          TotalAmount,
          ReferenceEntityId,
          ReferenceEntity.Name,
          FullSettlementDate
        FROM Invoice
        WHERE BillingAccountId = :accountId
        ORDER BY CreatedDate DESC
        LIMIT 50
      ];
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }
}
