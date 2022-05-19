public with sharing class SM_PaymentCreateProcessor {
  public static String generatePayment(RequestWrapper requestWrapper) {
    HttpRequest httpRequest = new HttpRequest();
    httpRequest.setHeader('Content-type', 'application/json');
    httpRequest.setMethod('POST');
    String endpoint = getCalloutUrl('Default');
    httpRequest.setEndpoint(endpoint);

    String requestBody = JSON.serialize(requestWrapper, true);
    httpRequest.setBody(requestBody);
    Http http = new Http();
    HttpResponse httpResponse = http.send(httpRequest);

    Map<String, Object> responseObject = (Map<String, Object>) JSON.deserializeUntyped(
      httpResponse.getBody()
    );
    PaymentWrapper paymentWrapper = (PaymentWrapper) JSON.deserialize(
      JSON.serialize(responseObject.get('payment'), true),
      PaymentWrapper.class
    );

    return paymentWrapper.id;
  }

  public static string getCalloutUrl(String settingName) {
    SM_Community_Setting__mdt setting = SM_Community_Setting__mdt.getInstance(
      settingName
    );
    return 'callout:' +
      setting.NamedCredential__c +
      setting.CommercePaymentSalesEndpoint__c;
  }

  public class RequestWrapper {
    public string accountId;
    public decimal amount;
    public string comments;
    public string currencyIsoCode;
    public Datetime effectiveDate;
    public string paymentGatewayId;
    public PaymentMethodWrapper paymentMethod;
    public String phone;
    public string email;
    public map<string, string> additionalData;
  }

  public class PaymentMethodWrapper {
    @AuraEnabled
    public String id;
  }

  public class PaymentWrapper {
    @AuraEnabled
    public String id;
  }
}
