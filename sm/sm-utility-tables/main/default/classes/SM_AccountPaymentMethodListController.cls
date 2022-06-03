public with sharing class SM_AccountPaymentMethodListController {
   @AuraEnabled(cacheable=true)
  public static List<CardPaymentMethod> getAccountCardPayments(Id accountId) {
    try {
      return [
        SELECT
          Id,
          NickName,
          AccountId,
          CreatedDate,
          Status,
          CardLastFour,
          CardType,
          PaymentGatewayId,
          PaymentGateway.PaymentGatewayName
        FROM CardPaymentMethod
        WHERE AccountId = :accountId
        ORDER BY CreatedDate DESC
        LIMIT 10
      ];
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }
}
