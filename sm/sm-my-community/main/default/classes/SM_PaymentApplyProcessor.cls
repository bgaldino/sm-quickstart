public with sharing class SM_PaymentApplyProcessor {
  public static String applyPayment(
    RequestWrapper requestWrapper,
    string paymentId
  ) {
    System.debug('SM_PaymentApplyProcessor | applyPayment');
    HttpRequest httpRequest = new HttpRequest();
    httpRequest.setHeader('Content-type', 'application/json');
    httpRequest.setMethod('POST');
    String restApiEndpoint = getCalloutUrl('Default', paymentId);
    System.debug(restApiEndpoint);
    httpRequest.setEndpoint(restApiEndpoint);

    String requestBody = JSON.serialize(requestWrapper, true);
    system.debug(requestBody);
    httpRequest.setBody(requestBody);
    Http http = new Http();
    HttpResponse httpResponse = http.send(httpRequest);
    // To delete use it for test
    System.debug(JSON.serializePretty(httpResponse.getBody()));
    //

    ResponseWrapper paymentWrapper = (ResponseWrapper) JSON.deserialize(
      httpResponse.getBody(),
      ResponseWrapper.class
    );

    return paymentWrapper.id;
  }

  public static string getCalloutUrl(String settingName, String paymentId) {
    SM_Community_Setting__mdt setting = SM_Community_Setting__mdt.getInstance(
      settingName
    );
    return 'callout:' +
      setting.NamedCredential__c +
      setting.CommerceBillingPaymentEndpoint__c +
      paymentId +
      '/actions/apply';
  }

  public class RequestWrapper {
    public Decimal amount;
    public String appliedToId;
    public Datetime effectiveDate;
    public string comments;
  }

  public class ResponseWrapper {
    @AuraEnabled
    public Datetime appliedDate;
    @AuraEnabled
    public String id;
  }
}
