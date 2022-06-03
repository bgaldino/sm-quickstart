public with sharing class SM_AccountInvoiceListController {
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
          ReferenceEntity.Name
        FROM Invoice
        WHERE BillingAccountId = :accountId
        ORDER BY CreatedDate DESC
        LIMIT 10
      ];
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }
}
