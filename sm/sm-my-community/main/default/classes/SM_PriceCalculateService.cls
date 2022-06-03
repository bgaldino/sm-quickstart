/**
 * Main price calculation service
 */
public with sharing class SM_PriceCalculateService {
  public static final String HTTP_METHOD = 'POST';
  public static final String REFERENCE_ID = 'ref_sales_txn';
  public static final String REFERENCE_ID_ITEM = 'ref_sales_txn_item';
  public static String PRICING_FLOW = 'GET_CATALOG_PRICE';
  public static final string SALES_TRANSACTION = 'SalesTransaction';
  public static final string SALES_TRANSACTION_ITEM = 'SalesTransactionItem';

  public static List<OutputRecord> InitiateCalculation(
    list<InputWrapper> input
  ) {
    String endpoint = getCalloutUrl('Default');
    System.debug('SM_PriceCalculateService | InitiateCalculation ');
    System.debug('endpoint: ' + endpoint);

    HttpRequest httpRequest = new HttpRequest();
    httpRequest.setHeader('Content-type', 'application/json');
    httpRequest.setMethod(HTTP_METHOD);
    httpRequest.setEndpoint(endpoint);

    String requestBody = calculatePrice(input);
    httpRequest.setBody(requestBody);
    Http http = new Http();
    HttpResponse httpResponse = http.send(httpRequest);

    System.debug(JSON.serializePretty(httpResponse.getBody()));
    List<OutputRecord> wrappedResponse = WrapIt(httpResponse.getBody());
    return wrappedResponse;
  }

  public static string calculatePrice(list<InputWrapper> inputList) {
    System.debug('InitiateCalculation | calculatePrice');
    System.debug(JSON.serializePretty(inputList[0]));
    list<Id> listPSMIds = new List<Id>();
    list<SM_PriceCalculationBuilder.record> listRecord = new List<SM_PriceCalculationBuilder.record>();

    SM_PriceCalculationBuilder pcb = new SM_PriceCalculationBuilder();
    pcb.listPricebookId = inputList[0].PriceBookId;
    pcb.candidatePricebookIds = new List<string>{ inputList[0].PriceBookId };
    pcb.pricingFlow = PRICING_FLOW;
    //pcb.subscriptionTermUnit = 'Months';
    pcb.subscriptionTerm = 12;
    Date dToday = Date.today();
    String dateStr = DateTime.newInstance(
        dToday.year(),
        dToday.month(),
        dToday.day()
      )
      .format('yyyy-MM-dd');
    pcb.startDate = dateStr;
    pcb.graph = buildGraph(inputList);
    return JSON.serialize(pcb, true);
  }

  public static SM_PriceCalculationBuilder.Graph buildGraph(
    list<InputWrapper> inputList
  ) {
    SM_PriceCalculationBuilder.Graph graph = new SM_PriceCalculationBuilder.Graph();
    graph.graphId = '1';
    integer recordItemCounter = 1;
    list<SM_PriceCalculationBuilder.Records> listRecords = new List<SM_PriceCalculationBuilder.Records>();

    SM_PriceCalculationBuilder.Attributes baseAttribute = new SM_PriceCalculationBuilder.Attributes();
    baseAttribute.Type = SALES_TRANSACTION;
    SM_PriceCalculationBuilder.Attributes itemAttribute = new SM_PriceCalculationBuilder.Attributes();
    itemAttribute.Type = SALES_TRANSACTION_ITEM;
    SM_PriceCalculationBuilder.Records parentRecords = new SM_PriceCalculationBuilder.Records();
    SM_PriceCalculationBuilder.Record baseRecord = new SM_PriceCalculationBuilder.Record();
    parentRecords.referenceId = REFERENCE_ID;
    baseRecord.attributes = baseAttribute;
    baseRecord.CurrencyIsoCode = inputList[0].productCurrency;
    parentRecords.record = baseRecord;
    listRecords.add(parentRecords);
    for (InputWrapper input : inputList) {
      SM_PriceCalculationBuilder.Records records = new SM_PriceCalculationBuilder.Records();
      SM_PriceCalculationBuilder.Record record = new SM_PriceCalculationBuilder.Record();
      records.referenceId = REFERENCE_ID_ITEM + (recordItemCounter++);
      record.CurrencyIsoCode = input.productCurrency;
      record.ProductId = input.ProductId;
      record.ProductSellingModelId = input.ProductSellingModelId;
      record.Quantity = input.quantity;
      record.Attributes = itemAttribute;
      record.SalesTransactionId = '@{' + REFERENCE_ID + '.id}';
      records.record = record;
      listRecords.add(records);
    }
    graph.records = listRecords;
    return graph;
  }

  public static string getCalloutUrl(String settingName) {
    SM_Pricing_Calculate_Setting__mdt setting = SM_Pricing_Calculate_Setting__mdt.getInstance(
      settingName
    );
    return 'callout:' + setting.Named_Credential__c + setting.Endpoint__c;
  }

  public class InputWrapper {
    public string ProductId;
    public string PricebookId;
    public string ProductSellingModelId;
    public integer quantity;
    public string productCurrency;
  }

  public class OutputWrapper {
    public String BillingFrequency;
    public String CurrencyIsoCode;
    public Decimal Quantity;
    public String ProductId;
    public Decimal ListPrice;
    public Decimal NetUnitPrice;
    public Decimal StartingUnitPrice;
    public String PricebookEntryId;
    public String ProductSellingModelId;
    public String SalesItemType;
  }
  public class OutputRecord {
    public String id;
    public OutputWrapper record;
  }

  public static List<OutputRecord> WrapIt(String response) {
    System.debug(JSON.serializePretty(response));
    Map<String, OutputWrapper> outputMap = new Map<string, OutputWrapper>();

    Map<String, Object> meta = (Map<String, Object>) JSON.deserializeUntyped(
      response
    );

    List<OutputRecord> outputRecords = (List<OutputRecord>) JSON.deserialize(
      JSON.serialize(meta.get('records'), true),
      List<OutputRecord>.class
    );
    if (outputRecords.size() > 1) {
      outputRecords.remove(0);
    }

    for (OutputRecord outputRecord : outputRecords) {
      outputRecord.id =
        outputRecord.record.ProductId +
        outputRecord.record.ProductSellingModelId;
    }
    return outputRecords;
  }
}
