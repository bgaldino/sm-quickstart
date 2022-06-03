public with sharing class SM_OrderProcessor {
  public static Id createStandaloneOrder(
    List<Map<String, Object>> products,
    Map<String, Object> details
  ) {
    Order newOrder = new Order();
    newOrder.Status = 'Draft';
    newOrder.EffectiveDate = Date.today();
    newOrder.AccountId = (String) details.get('accountId');
    newOrder.Pricebook2Id = (String) details.get('pricebookId');
    newOrder.BillToContactId = (String) details.get('contactId');
    // system.debug(JSON.serializePretty(details));
    // Address
    Map<String, Object> address = (Map<String, Object>) details.get('address');
    // system.debug(address);
    newOrder.BillingStreet = (String) address.get('street');
    newOrder.BillingCity = (String) address.get('city');
    newOrder.BillingState = (String) address.get('province');
    newOrder.BillingPostalCode = (String) address.get('postalCode');
    newOrder.BillingCountry = (String) address.get('country');
    newOrder.BillingStreet = (String) address.get('street');
    newOrder.BillingCity = (String) address.get('city');
    newOrder.BillingState = (String) address.get('province');
    newOrder.BillingPostalCode = (String) address.get('postalCode');
    newOrder.BillingCountry = (String) address.get('country');

    List<OrderItem> ois = generateOrderItems(products);

    try {
      Database.insert(newOrder);
    } catch (DmlException e) {
      System.debug(e);
    }

    AppUsageAssignment buyNow = new AppUsageAssignment();
    buyNow.AppUsageType = 'BuyNow';
    buyNow.RecordId = newOrder.Id;
    AppUsageAssignment subMgmt = new AppUsageAssignment();
    subMgmt.AppUsageType = 'SubscriptionManagement';
    subMgmt.RecordId = newOrder.Id;

    OrderAction oa = new OrderAction();
    oa.OrderId = newOrder.Id;
    oa.Type = 'New Sale';
    try {
      Database.insert(buyNow);
      Database.insert(subMgmt);
      Database.insert(oa);
    } catch (DmlException e) {
      System.debug(e);
    }

    for (OrderItem oi : ois) {
      oi.OrderId = newOrder.Id;
      oi.OrderActionId = oa.Id;
    }
    try {
      Database.insert(ois);
    } catch (DmlException e) {
      System.debug(e);
    }

    return newOrder.Id;
  }

  public static List<OrderItem> generateOrderItems(
    List<Map<String, Object>> products
  ) {
    // get tax treatments
    Map<Id, TaxPolicy> tps = new Map<Id, TaxPolicy>(
      [SELECT Id, Name, DefaultTaxTreatmentId FROM TaxPolicy]
    );
    // get psms
    Map<Id, ProductSellingModel> psms = new Map<Id, ProductSellingModel>(
      [
        SELECT Id, Name, SellingModelType, PricingTerm, PricingTermUnit, Status
        FROM ProductSellingModel
      ]
    );

    List<OrderItem> newOIs = new List<OrderItem>();
    for (Map<String, Object> product : products) {
      OrderItem oi = new OrderItem();

      oi.ServiceDate = Date.today();
      //oi.Quantity = Integer.valueOf((Decimal) product.get('quantity'));
      oi.Quantity = Integer.valueOf(String.valueOf(product.get('quantity')));
      oi.Unitprice = (Decimal) product.get('price');
      oi.NetUnitPrice = (Decimal) product.get('price');
      // 238 field is not writeable
      //oi.ProductSellingModelId = (String) product.get('productSellingModelId');
      oi.PricebookEntryId = (String) product.get('pricebookEntryId');
      oi.TaxTreatmentId = tps.get((String) product.get('taxPolicyId'))
        .DefaultTaxTreatmentId;

      String sellingModelType = psms.get(
          (String) product.get('productSellingModelId')
        )
        .SellingModelType;

      // Evergreen
      if (sellingModelType == 'Evergreen') {
        oi.PeriodBoundary = 'Anniversary';
        oi.BillingFrequency2 = 'Monthly';
      }

      // Term
      if (sellingModelType == 'TermDefined') {
        System.debug('Term-Defined');
        Integer numMonths = 12;
        Decimal totalLine = numMonths * oi.Unitprice * oi.Quantity;
        oi.TotalLineAmount = totalLine;

        Date endDate = Date.today().addMonths(numMonths).addDays(-1);
        oi.EndDate = endDate;

        oi.PricingTermCount = numMonths;
        oi.PeriodBoundary = 'Anniversary';
        oi.BillingFrequency2 = 'Monthly';
      }
      System.debug(JSON.serializePretty(oi));
      // add order items to list
      newOIs.add(oi);
    }
    return newOIs;
  }
}
