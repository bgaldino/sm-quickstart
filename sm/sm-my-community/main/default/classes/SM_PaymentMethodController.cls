public with sharing class SM_PaymentMethodController {
  @AuraEnabled
  public static List<PaymentMethodWrapper> getPaymentMethodsForCurrentUser() {
    User currentUserAccount = [
      SELECT Contact.AccountId
      FROM User
      WHERE Id = :Userinfo.getUserid()
    ];
    List<PaymentMethodWrapper> paymentMethodWrappers = new List<PaymentMethodWrapper>();

    for (CardPaymentMethod cardPaymentMethod : [
      SELECT Id, CardHolderName, DisplayCardNumber
      FROM CardPaymentMethod
      WHERE
        AccountId = :currentUserAccount.Contact.AccountId
        AND Status = 'Active'
    ]) {
      paymentMethodWrappers.add(
        new PaymentMethodWrapper(
          cardPaymentMethod.Id,
          cardPaymentMethod.CardHolderName +
          ' - ' +
          cardPaymentMethod.DisplayCardNumber
        )
      );
    }
    return paymentMethodWrappers;
  }

  // create New payment method and return the paymentMethodId
  @AuraEnabled
  public static string createNewPaymentMethod(
    Map<String, Object> paymentCard,
    String paymentGatewayId
  ) {
    System.debug('createNewPaymentMethod');
    User currentUserAccount = [
      SELECT ContactId, Contact.AccountId, Contact.Name
      FROM User
      WHERE Id = :Userinfo.getUserid()
    ];
    SM_PaymentMethodProcessor.NewPaymentMethodRequestWrapper requestWrapper = new SM_PaymentMethodProcessor.NewPaymentMethodRequestWrapper();

    requestWrapper.paymentGatewayId = paymentGatewayId;
    SM_PaymentMethodProcessor.CardDetails cardDetail = new SM_PaymentMethodProcessor.CardDetails();
    cardDetail.cardHolderName = (String) paymentCard.get('cardHolderName');
    List<String> cardExpiry = ((String) paymentCard.get('cardExpiry'))
      .split('/');
    cardDetail.expiryMonth = cardExpiry.get(0).trim();
    cardDetail.expiryYear = '20' + cardExpiry.get(1).trim();
    cardDetail.cardNumber = ((String) paymentCard.get('cardNumber'))
      .replaceAll(' ', '');
    cardDetail.cvv = (String) paymentCard.get('cardCVV');

    cardDetail.accountId = currentUserAccount.Contact.AccountId;
    cardDetail.cardCategory = 'CreditCard';
    cardDetail.cardType = (String) paymentCard.get('cardType');
    cardDetail.nickName = cardDetail.cardHolderName;

    // set the card details
    requestWrapper.cardPaymentMethod = cardDetail;
    system.debug(JSON.serializePretty(requestWrapper));
    return SM_PaymentMethodProcessor.saveNewPaymentMethod(requestWrapper);
  }

  public class PaymentMethodWrapper {
    @AuraEnabled
    public string value { get; set; }
    @AuraEnabled
    public string label { get; set; }

    PaymentMethodWrapper(String value, String label) {
      this.value = value;
      this.label = label;
    }
  }
}
