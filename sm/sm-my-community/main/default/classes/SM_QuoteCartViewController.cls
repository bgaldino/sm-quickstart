public without sharing class SM_QuoteCartViewController {
  @AuraEnabled
  public static List<QuoteLineWrapper> getAllQuotelinesByQuoteId(Id quoteId) {
    List<QuoteLineWrapper> qlWrappers = new List<QuoteLineWrapper>();

    List<QuoteLineItem> qlis = [
      SELECT
        Id,
        QuoteId,
        ServiceDate,
        Quantity,
        UnitPrice,
        Discount,
        ListPrice,
        Subtotal,
        TotalPrice,
        Product2Id,
        Product2.Name,
        Product2.DisplayUrl,
        Product2.Description,
        Product2.Family,
        PricebookEntry.CurrencyIsoCode,
        PricebookEntry.ProductSellingModel.Name
      FROM QuoteLineItem
      WHERE QuoteId = :quoteId
    ];
    for (QuoteLineItem ql : qlis) {
      QuoteLineWrapper qlWrap = new QuoteLineWrapper();
      qlWrap.id = ql.Id;
      qlWrap.productName = ql.Product2.Name;
      qlWrap.description = ql.Product2.Description;
      qlWrap.displayUrl = ql.Product2.DisplayUrl;
      qlWrap.family = ql.Product2.Family;
      qlWrap.quantity = ql.Quantity;
      qlWrap.salesPrice = ql.UnitPrice;
      qlWrap.discount = ql.Discount;
      qlWrap.subtotal = ql.Subtotal;
      qlWrap.totalPrice = ql.TotalPrice;
      qlWrap.currencyCode = ql.PricebookEntry.CurrencyIsoCode;
      qlWrap.sellingModel = ql.PricebookEntry.ProductSellingModel.Name;
      qlWrappers.add(qlWrap);
    }

    return qlWrappers;
  }

  @AuraEnabled
  public static List<QuoteLineWrapper> getAllCartItemsByQuoteId(Id quoteId) {
    List<QuoteLineWrapper> qlWrappers = new List<QuoteLineWrapper>();

    List<CartItem__c> qlis = [
      SELECT
        Id,
        Quote__c,
        Quantity__c,
        UnitPrice__c,
        Discount__c,
        ListPrice__c,
        TotalPrice__c,
        Product__c,
        Product__r.Name,
        Product__r.DisplayUrl,
        Product__r.Description,
        Product__r.Family,
        CurrencyIsoCode,
        SellingModelType__c
      FROM CartItem__c
      WHERE Quote__c = :quoteId
    ];
    for (CartItem__c ql : qlis) {
      QuoteLineWrapper qlWrap = new QuoteLineWrapper();
      qlWrap.id = ql.Id;
      qlWrap.productName = ql.Product__r.Name;
      qlWrap.description = ql.Product__r.Description;
      qlWrap.displayUrl = ql.Product__r.DisplayUrl;
      qlWrap.family = ql.Product__r.Family;
      qlWrap.quantity = ql.Quantity__c;
      qlWrap.salesPrice = ql.UnitPrice__c;
      qlWrap.discount = ql.Discount__c;
      qlWrap.subtotal = ql.Quantity__c * ql.UnitPrice__c;
      qlWrap.totalPrice = ql.TotalPrice__c;
      qlWrap.currencyCode = ql.CurrencyIsoCode;
      qlWrap.sellingModel = ql.SellingModelType__c;
      qlWrappers.add(qlWrap);
    }

    return qlWrappers;
  }

  public class QuoteLineWrapper {
    @AuraEnabled
    public string id { get; set; }
    @AuraEnabled
    public string productName { get; set; }
    @AuraEnabled
    public string description { get; set; }
    @AuraEnabled
    public string family { get; set; }
    @AuraEnabled
    public string displayUrl { get; set; }

    @AuraEnabled
    public Decimal quantity { get; set; }
    @AuraEnabled
    public Decimal salesPrice { get; set; }
    @AuraEnabled
    public Decimal discount { get; set; }
    @AuraEnabled
    public Decimal subtotal { get; set; }
    @AuraEnabled
    public Decimal totalPrice { get; set; }

    @AuraEnabled
    public string currencyCode { get; set; }
    @AuraEnabled
    public string sellingModel { get; set; }

    @AuraEnabled
    public Boolean isSelected { get; set; }

    public QuoteLineWrapper() {
      this.isSelected = false;
    }
  }
}
