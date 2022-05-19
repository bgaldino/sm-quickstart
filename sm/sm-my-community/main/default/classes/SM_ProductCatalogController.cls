public with sharing class SM_ProductCatalogController {
  @AuraEnabled
  public static List<ProductWrapper> getActiveProducts(Id pricebookId) {
    Map<String, ProductWrapper> productWrappers = new Map<String, ProductWrapper>();
    List<Product2> products = [
      SELECT
        Id,
        Name,
        CurrencyIsoCode,
        Description,
        DisplayUrl,
        Family,
        TaxPolicyId,
        (
          SELECT
            Id,
            ProductSellingModelId,
            ProductSellingModel.Name,
            CurrencyIsoCode
          FROM PricebookEntries
          WHERE
            IsActive = TRUE
            AND Pricebook2Id = :pricebookId
            AND ProductSellingModelId != NULL
        )
      FROM Product2
      WHERE IsActive = TRUE
    ];

    // List<Product2> products = [
    //   SELECT
    //     Id,
    //     Name,
    //     CurrencyIsoCode,
    //     Description,
    //     DisplayUrl,
    //     Family,
    //     (
    //       SELECT Id, ProductSellingModelId, ProductSellingModel.Name
    //       FROM ProductSellingModelOptions
    //       WHERE ProductSellingModel.Status = 'Active'
    //     )
    //   FROM Product2
    //   WHERE IsActive = TRUE
    // ];

    list<SM_PriceCalculateService.InputWrapper> pricingInputs = new List<SM_PriceCalculateService.InputWrapper>();
    Integer counter = 0;
    for (Product2 product : products) {
      if (!product.PricebookEntries.isEmpty()) {
        ProductWrapper productWrapper = new ProductWrapper();
        productWrapper.id = counter++;
        productWrapper.productId = product.Id;
        productWrapper.currencyIsoCode = product.CurrencyIsoCode;
        productWrapper.productName = product.Name;
        productWrapper.description = product.Description;
        productWrapper.displayUrl = product.DisplayUrl;
        productWrapper.family = product.Family;
        productWrapper.pricebookId = pricebookId;
        productWrapper.taxPolicyId = product.TaxPolicyId;
        for (PricebookEntry pbe : product.PricebookEntries) {
          productWrapper.options.add(
            new ProductSellingOptionWrapper(
              pbe.ProductSellingModelId,
              pbe.ProductSellingModel.Name
            )
          );
        }
        for (
          ProductSellingModelOption productOption : product.ProductSellingModelOptions
        ) {
          productWrapper.options.add(
            new ProductSellingOptionWrapper(
              productOption.ProductSellingModelId,
              productOption.ProductSellingModel.Name
            )
          );
        }
        productWrapper.productSellingModelId = productWrapper.options.get(0)
          .value;
        productWrappers.put(
          product.Id + productWrapper.productSellingModelId,
          productWrapper
        );
        SM_PriceCalculateService.InputWrapper pricingInput = new SM_PriceCalculateService.InputWrapper();
        pricingInput.ProductId = product.Id;
        pricingInput.PricebookId = pricebookId;
        pricingInput.ProductSellingModelId = productWrapper.productSellingModelId;
        pricingInput.quantity = 1;
        pricingInput.productCurrency = product.CurrencyIsoCode;
        pricingInputs.add(pricingInput);
      }
    }

    List<SM_PriceCalculateService.OutputRecord> pricingOutputs = SM_PriceCalculateService.InitiateCalculation(
      pricingInputs
    );

    for (SM_PriceCalculateService.OutputRecord pricingOutput : pricingOutputs) {
      ProductWrapper productWrapper = productWrappers.get(pricingOutput.id);
      productWrapper.price = pricingOutput.record.NetUnitPrice;
      productWrapper.pricebookEntryId = pricingOutput.record.PricebookEntryId;
    }

    return productWrappers.values();
  }

  @AuraEnabled
  public static Map<String, Object> updatePricing(
    Map<String, Object> productWrapper
  ) {
    list<SM_PriceCalculateService.InputWrapper> pricingInputs = new List<SM_PriceCalculateService.InputWrapper>();
    SM_PriceCalculateService.InputWrapper pricingInput = new SM_PriceCalculateService.InputWrapper();
    pricingInput.ProductId = (String) productWrapper.get('productId');
    pricingInput.PricebookId = (String) productWrapper.get('pricebookId');
    pricingInput.ProductSellingModelId = (String) productWrapper.get(
      'productSellingModelId'
    );
    pricingInput.quantity = Integer.valueOf(
      String.valueOf(productWrapper.get('quantity'))
    );
    pricingInput.productCurrency = (String) productWrapper.get(
      'currencyIsoCode'
    );
    pricingInputs.add(pricingInput);

    // To be changed
    SM_PriceCalculateService.PRICING_FLOW = 'GET_FINAL_PRICE';
    List<SM_PriceCalculateService.OutputRecord> pricingOutputs = SM_PriceCalculateService.InitiateCalculation(
      pricingInputs
    );
    System.debug('Update Pricing');
    System.debug(JSON.serializePretty(pricingOutputs.get(0).record));
    System.debug('Price: ' + pricingOutputs.get(0).record.NetUnitPrice);
    System.debug(
      'pricebookEntryId: ' + pricingOutputs.get(0).record.PricebookEntryId
    );
    productWrapper.put('price', pricingOutputs.get(0).record.NetUnitPrice);
    productWrapper.put(
      'pricebookEntryId',
      pricingOutputs.get(0).record.PricebookEntryId
    );
    return productWrapper;
  }

  public class ProductWrapper {
    @AuraEnabled
    public Integer id { get; set; }
    @AuraEnabled
    public String productId { get; set; }
    @AuraEnabled
    public String currencyIsoCode { get; set; }
    @AuraEnabled
    public Boolean isSelected { get; set; }
    @AuraEnabled
    public String productName { get; set; }
    @AuraEnabled
    public String description { get; set; }
    @AuraEnabled
    public String displayUrl { get; set; }
    @AuraEnabled
    public String family { get; set; }
    @AuraEnabled
    public Integer quantity { get; set; }
    @AuraEnabled
    public String productSellingModelId { get; set; }
    @AuraEnabled
    public String taxPolicyId { get; set; }
    @AuraEnabled
    public Decimal price { get; set; }
    @AuraEnabled
    public String pricebookId { get; set; }
    @AuraEnabled
    public String pricebookEntryId { get; set; }
    @AuraEnabled
    public List<ProductSellingOptionWrapper> options { get; set; }

    public ProductWrapper() {
      this.options = new List<ProductSellingOptionWrapper>();
      this.isSelected = false;
      this.quantity = 1;
    }
  }

  public class ProductSellingOptionWrapper {
    @AuraEnabled
    public string value { get; set; }
    @AuraEnabled
    public string label { get; set; }

    ProductSellingOptionWrapper(String value, String label) {
      this.value = value;
      this.label = label;
    }
  }
}
