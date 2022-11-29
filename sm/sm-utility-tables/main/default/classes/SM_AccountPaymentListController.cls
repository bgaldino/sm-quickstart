public with sharing class SM_AccountPaymentListController {
  private static final DCM_Logger LOGGER = DCM_Logger.getInstance();

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
