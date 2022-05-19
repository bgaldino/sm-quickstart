/**
 * @author Sam Check
 * @date 03/14/2022
 * @description Constructs and performs API callout to 'Buy Now' endpoint
 */
public with sharing class SM_BuyNowFromOrder {
  /**
   * @param orderId Id of a draft Order to use for Buy Now
   * @param paymentMethodId Id of saved Payment Method to charge for Buy Now
   * @param gatewayId Id of the Payment Gateway to use for processing the Payment Method
   */
  @AuraEnabled
  public static String buyNowFromDraftOrder(
    Id orderId,
    Id paymentMethodId,
    Id gatewayId
  ) {
    try {
      HttpRequest httpRequest = new HttpRequest();
      httpRequest.setHeader('Content-type', 'application/json');
      httpRequest.setMethod('POST');

      String endpoint = getCalloutUrl('Default');
      httpRequest.setEndpoint(endpoint);

      String requestBody = buildRequestString(
        orderId,
        paymentMethodId,
        gatewayId
      );
      system.debug(requestBody);
      httpRequest.setBody(requestBody);
      Http http = new Http();
      HttpResponse httpResponse = http.send(httpRequest);

      System.debug(JSON.serializePretty(httpResponse.getBody()));
      return httpResponse.getBody();
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  public static string buildRequestString(
    Id orderId,
    Id paymentMethodId,
    Id gatewayId
  ) {
    JSONGenerator gen = JSON.createGenerator(true);
    gen.writeStartObject();
    gen.writeFieldName('inputs');
    gen.writeStartArray();
    gen.writeStartObject();
    gen.writeStringField('recordId', orderId);
    gen.writeStringField('paymentMethodId', paymentMethodId);
    gen.writeStringField('GatewayId', gatewayId);
    gen.writeEndObject();
    gen.writeEndArray();
    gen.writeEndObject();

    return gen.getAsString();
  }

  public static string getCalloutUrl(String settingName) {
    SM_Community_Setting__mdt setting = SM_Community_Setting__mdt.getInstance(
      settingName
    );
    return 'callout:' +
      setting.NamedCredential__c +
      setting.BuyNowExistingOrderEndpoint__c;
  }
}
