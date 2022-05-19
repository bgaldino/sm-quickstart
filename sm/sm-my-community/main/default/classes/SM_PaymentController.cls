public with sharing class SM_PaymentController {
  @AuraEnabled
  public static string createPayment(
    Decimal amount,
    String paymentMethodId,
    String paymentGatewayId
  ) {
    system.debug('SM_PaymentController | createPayment');
    User currentUserAccount = [
      SELECT Contact.AccountId
      FROM User
      WHERE Id = :Userinfo.getUserid()
    ];
    SM_PaymentCreateProcessor.RequestWrapper requestWrapper = new SM_PaymentCreateProcessor.RequestWrapper();

    requestWrapper.paymentGatewayId = paymentGatewayId;
    //requestWrapper.email = 'abc@xyz.com';
    requestWrapper.accountId = currentUserAccount.Contact.AccountId;
    requestWrapper.amount = amount;
    requestWrapper.currencyIsoCode = 'USD';
    requestWrapper.effectiveDate = system.Now();

    SM_PaymentCreateProcessor.PaymentMethodWrapper pm = new SM_PaymentCreateProcessor.PaymentMethodWrapper();
    pm.Id = paymentMethodId;
    requestWrapper.paymentMethod = pm;

    system.debug(JSON.serializePretty(requestWrapper));
    return SM_PaymentCreateProcessor.generatePayment(requestWrapper);
  }

  @AuraEnabled
  public static string applyPayment(
    String paymentId,
    String invoiceId,
    String amount
  ) {
    system.debug('SM_PaymentController | applyPayment');
    SM_PaymentApplyProcessor.RequestWrapper requestWrapperApplyPayment = new SM_PaymentApplyProcessor.RequestWrapper();
    requestWrapperApplyPayment.amount = Decimal.valueOf(amount);
    requestWrapperApplyPayment.appliedToId = invoiceId;
    requestWrapperApplyPayment.effectiveDate = Datetime.now();
    System.debug(JSON.serializePretty(requestWrapperApplyPayment));
    return SM_PaymentApplyProcessor.applyPayment(
      requestWrapperApplyPayment,
      paymentId
    );
  }
}
