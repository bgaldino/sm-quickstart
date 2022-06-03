public with sharing class SM_PaymentTerminalController {
  @AuraEnabled
  public static String makePayment(
    Map<String, Object> paymentCard,
    Boolean newCard,
    Decimal amount,
    String currencyIsoCode,
    String paymentMethodId,
    String gatewayId
  ) {
    system.debug('SM_PaymentTerminalController | makePayment');
    User currentUserAccount = [
      SELECT Contact.AccountId
      FROM User
      WHERE Id = :Userinfo.getUserid()
    ];
    SM_PaymentMethodProcessor.RequestWrapper requestWrapper = new SM_PaymentMethodProcessor.RequestWrapper();
    SM_PaymentMethodProcessor.PaymentMethod paymentMethod = new SM_PaymentMethodProcessor.PaymentMethod();

    requestWrapper.paymentGatewayId = gatewayId;
    requestWrapper.paymentMethod = paymentMethod;
    requestWrapper.accountId = currentUserAccount.Contact.AccountId;
    requestWrapper.amount = amount;
    requestWrapper.comments = 'No Comment';
    requestWrapper.effectiveDate = system.Now();
    requestWrapper.currencyIsoCode = currencyIsoCode;

    if (newCard) {
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
      paymentMethod.saveForFuture = (Boolean) paymentCard.get('saveForFuture');
      paymentMethod.cardPaymentMethod = cardDetail;
    } else {
      paymentMethod.id = paymentMethodId;
    }
    system.debug(JSON.serializePretty(requestWrapper));
    return SM_PaymentMethodProcessor.makeSale(requestWrapper);
  }
}
