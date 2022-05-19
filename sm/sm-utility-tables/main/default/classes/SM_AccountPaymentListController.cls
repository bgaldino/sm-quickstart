public with sharing class SM_AccountPaymentListController {
  @AuraEnabled(cacheable=true)
  public static List<Payment> getAccountPayments(Id accountId) {
    try {
      return [
        SELECT
          Id,
          PaymentNumber,
          AccountId,
          CreatedDate,
          Balance,
          TotalApplied,
          NetApplied,
          TotalUnapplied
        FROM Payment
        WHERE AccountId = :accountId
        ORDER BY CreatedDate DESC
        LIMIT 10
      ];
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }
}
