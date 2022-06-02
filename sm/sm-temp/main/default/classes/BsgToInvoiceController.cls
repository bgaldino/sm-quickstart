public without sharing class BsgToInvoiceController {
  @AuraEnabled
  public static String bsgToInvoice(Id orderId) {
    // namedCredential should match the name of your named credential from Setup
    String namedCredential = 'MySalesforce';
    String restApiUrl =
      'callout:' +
      namedCredential +
      '/services/data/v55.0/actions/standard/createInvoiceFromOrder/actions/standard/createInvoiceFromOrder';
    BillingSchedule bs1;
    //BillingSchedule bs2;

    System.debug(LoggingLevel.DEBUG,'OrderId: ' + orderId);
    List<BillingSchedule> bsg = [
      SELECT BillingScheduleGroupId
      FROM BillingSchedule
      WHERE ReferenceEntityId = :orderId
      WITH SECURITY_ENFORCED
    ];
    System.debug(LoggingLevel.DEBUG,'bsg: ' + bsg);
    System.debug(LoggingLevel.DEBUG,1);
    List<BillingSchedule> listOfBS = [
      SELECT Id, NextBillingDate, NextChargeFromDate, Status
      FROM BillingSchedule
      WHERE
        BillingScheduleGroupId = :bsg.get(0).BillingScheduleGroupId
        AND Status NOT IN ('CompletelyBilled')
      WITH SECURITY_ENFORCED
    ];
    bs1 = listOfBS.get(0);
    //bs2 = listOfBS.get(1);
    System.debug(LoggingLevel.DEBUG,'bsg nextBillingDate: ' + bs1.NextBillingDate);
    System.debug(LoggingLevel.DEBUG,'bsg nextChargeFromDate: ' + bs1.NextChargeFromDate);

    DateTime nextBillingDateDT = bs1.NextBillingDate;

    String nextBillingDate = nextBillingDateDT.formatGMT(
      'yyyy-MM-dd\'T\'HH:mm:ss.SSSZ'
    );
    System.debug(LoggingLevel.DEBUG,'nextBillingDate string: ' + nextBillingDate);

    String bodyJson =
      '{"inputs":[{"orderId":"' +
      orderId +
      '",' +
      '"correlationId":"",' +
      '"invoiceStatus":"Posted",' +
      '"targetDate":"' +
      nextBillingDate +
      '",' +
      '"invoiceDate":"' +
      nextBillingDate +
      '"}]}';

    System.debug(LoggingLevel.DEBUG,'bodyJson: ' + bodyJson);

    HttpRequest httpRequest = new HttpRequest();
    httpRequest.setMethod('POST');
    httpRequest.setHeader('Content-Type', 'application/json;charset=UTF-8');
    httpRequest.setEndpoint(restApiUrl);
    httpRequest.setBody(bodyJson);
    String response = '';
    try {
      HttpResponse httpResponse = new Http().send(httpRequest);
      System.debug(LoggingLevel.DEBUG,'Response' + httpResponse);
      System.debug(LoggingLevel.DEBUG,httpResponse.getStatusCode());
      while (httpResponse.getStatusCode() == 302) {
        httpRequest.setEndpoint(httpResponse.getHeader('Location'));
        httpResponse = new Http().send(httpRequest);
      }
      response = httpResponse.getBody();
    } catch (System.Exception e) {
      System.debug(LoggingLevel.DEBUG,'ERROR: ' + e);
      throw e;
    }
    System.debug(LoggingLevel.DEBUG,response);
    return response;
  }
}
