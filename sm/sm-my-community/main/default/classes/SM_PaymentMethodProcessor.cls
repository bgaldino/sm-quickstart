public with sharing class SM_PaymentMethodProcessor {
  // returns a payment Id
  @AuraEnabled
  public static String makeSale(RequestWrapper requestWrapper) {
    System.debug('makeSale');
    HttpRequest httpRequest = new HttpRequest();
    httpRequest.setHeader('Content-type', 'application/json');
    httpRequest.setMethod('POST');
    String endpoint = getSalesCalloutUrl('Default');
    httpRequest.setEndpoint(endpoint);

    String requestBody = JSON.serialize(requestWrapper, true);
    system.debug(requestBody);
    httpRequest.setBody(requestBody);
    Http http = new Http();
    HttpResponse httpResponse = http.send(httpRequest);
    // To delete use it for test
    System.debug(JSON.serializePretty(httpResponse.getBody()));
    //
    Map<String, Object> responseObject = (Map<String, Object>) JSON.deserializeUntyped(
      httpResponse.getBody()
    );
    PaymentWrapper paymentWrapper = (PaymentWrapper) JSON.deserialize(
      JSON.serialize(responseObject.get('payment'), true),
      PaymentWrapper.class
    );

    return paymentWrapper.id;
  }

  private static string getSalesCalloutUrl(String settingName) {
    SM_Community_Setting__mdt setting = SM_Community_Setting__mdt.getInstance(
      settingName
    );
    return 'callout:' +
      setting.NamedCredential__c +
      setting.CommercePaymentSalesEndpoint__c;
  }

  // returns a payment method Id
  @AuraEnabled
  public static String saveNewPaymentMethod(
    NewPaymentMethodRequestWrapper requestWrapper
  ) {
    System.debug('saveNewPaymentMethod');
    HttpRequest httpRequest = new HttpRequest();
    httpRequest.setHeader('Content-type', 'application/json');
    httpRequest.setMethod('POST');
    String endpoint = getPaymentMethodCalloutUrl('Default');
    httpRequest.setEndpoint(endpoint);

    String requestBody = JSON.serialize(requestWrapper, true);
    system.debug(requestBody);
    httpRequest.setBody(requestBody);
    Http http = new Http();
    HttpResponse httpResponse = http.send(httpRequest);
    // To delete use it for test
    System.debug(JSON.serializePretty(httpResponse.getBody()));
    //
    Map<String, Object> responseObject = (Map<String, Object>) JSON.deserializeUntyped(
      httpResponse.getBody()
    );
    PaymentMethodWrapper paymentMethodWrapper = (PaymentMethodWrapper) JSON.deserialize(
      JSON.serialize(responseObject.get('paymentMethod'), true),
      PaymentMethodWrapper.class
    );

    return paymentMethodWrapper.id;
  }

  private static string getPaymentMethodCalloutUrl(String settingName) {
    SM_Community_Setting__mdt setting = SM_Community_Setting__mdt.getInstance(
      settingName
    );
    return 'callout:' +
      setting.NamedCredential__c +
      setting.CommercePaymentMethodEndpoint__c;
  }

  public static CardDetails buildCardDetails(Map<String, Object> paymentCard) {
    SM_PaymentMethodProcessor.CardDetails cardDetail = new SM_PaymentMethodProcessor.CardDetails();
    cardDetail.cardHolderName = (String) paymentCard.get('cardHolderName');
    List<String> cardExpiry = ((String) paymentCard.get('cardExpiry'))
      .split('/');
    cardDetail.expiryMonth = cardExpiry.get(0).trim();
    cardDetail.expiryYear = '20' + cardExpiry.get(1).trim();
    cardDetail.cardNumber = ((String) paymentCard.get('cardNumber'))
      .replaceAll(' ', '');
    cardDetail.cvv = (String) paymentCard.get('cardCVV');
    cardDetail.cardCategory = 'CreditCard';
    cardDetail.cardType = (String) paymentCard.get('cardType');
    cardDetail.nickName = cardDetail.cardHolderName;
    if (paymentCard.containsKey('accountId')) {
      cardDetail.accountId = (String) paymentCard.get('accountId');
    }
    return cardDetail;
  }

  public class RequestWrapper {
    @AuraEnabled
    public string paymentGatewayId;
    @AuraEnabled
    public string accountId;
    @AuraEnabled
    public decimal amount;
    @AuraEnabled
    public string comments;
    @AuraEnabled
    public Datetime effectiveDate;
    @AuraEnabled
    public PaymentMethod paymentMethod;
    @AuraEnabled
    public String phone;
    @AuraEnabled
    public string email;
    @AuraEnabled
    public string currencyIsoCode;
    @AuraEnabled
    public map<string, string> additionalData;
  }

  public class NewPaymentMethodRequestWrapper {
    @AuraEnabled
    public string paymentGatewayId;
    @AuraEnabled
    public CardDetails cardPaymentMethod;
    @AuraEnabled
    public String phone;
    @AuraEnabled
    public string email;
    @AuraEnabled
    public map<string, string> additionalData;
  }

  public class PaymentMethod {
    @AuraEnabled
    public boolean saveForFuture;
    @AuraEnabled
    public String id;
    @AuraEnabled
    public CardDetails cardPaymentMethod;
  }

  public class CardDetails {
    @AuraEnabled
    public string cardHolderName;
    @AuraEnabled
    public string expiryMonth;
    @AuraEnabled
    public string expiryYear;
    @AuraEnabled
    public string cardNumber;
    @AuraEnabled
    public string cvv;
    @AuraEnabled
    public string cardCategory;
    @AuraEnabled
    public string cardType;
    @AuraEnabled
    public string startYear;
    @AuraEnabled
    public string startMonth;
    @AuraEnabled
    public string nickName;
    @AuraEnabled
    public string accountId;
  }

  public class ResponseWrapper {
    @AuraEnabled
    public map<string, string> paymentMethod;
    @AuraEnabled
    public map<string, string> gatewayResponse;
  }

  public class PaymentWrapper {
    @AuraEnabled
    public String id;
  }

  public class PaymentMethodWrapper {
    @AuraEnabled
    public String id;
    @AuraEnabled
    public String accountId;
    @AuraEnabled
    public String status;
  }
}
