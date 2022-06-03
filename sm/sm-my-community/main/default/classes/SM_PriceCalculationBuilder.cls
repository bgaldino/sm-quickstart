public with sharing class SM_PriceCalculationBuilder {
  public class Graph {
    public String graphId;
    public List<Records> records;
  }

  public String listPricebookId;
  public List<String> candidatePricebookIds;
  public String pricingFlow;
  public Graph graph;
  //public String subscriptionTermUnit;
  public Integer subscriptionTerm;
  public String startDate;

  public class Attributes {
    public String type;
  }

  public class Record {
    public Attributes attributes;
    public String CurrencyIsoCode;
    public String SalesTransactionId;
    public String ProductId;
    public String ProductSellingModelId;
    public Integer Quantity;
  }

  public class Records {
    public String referenceId;
    public Record record;
  }

  public static SM_PriceCalculationBuilder parse(String json) {
    return (SM_PriceCalculationBuilder) System.JSON.deserialize(
      json,
      SM_PriceCalculationBuilder.class
    );
  }
}
