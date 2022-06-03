public without sharing class SM_CartProcessor {
  // Hack for 238 restrictions
  public static String createStandaloneCart(
    List<Map<String, Object>> products,
    Map<String, Object> details
  ) {
    system.debug(JSON.serializePretty(details));
    Date startDate = System.today();
    String contactName = (String) details.get('contactName');
    String todayDate = Datetime.now().format('yyyy-MM-dd');
    Quote q = new Quote(
      Name = 'Cart for ' + contactName + ' - ' + todayDate,
      Status = 'Draft',
      ContactId = (String) details.get('contactId'),
      Pricebook2Id = (String) details.get('pricebookId')
    );

    try {
      Database.insert(q);
    } catch (DmlException e) {
      System.debug(e);
    }

    List<String> pbeIds = new List<String>();
    List<CartItem__c> qlis = new List<CartItem__c>();
    for (Map<String, Object> product : products) {
      //Integer qty = Integer.valueOf((Decimal) product.get('quantity'));
      Integer qty = Integer.valueOf(String.valueOf(product.get('quantity')));
      Decimal price = (Decimal) product.get('price');
      String pbe = (String) product.get('pricebookEntryId');
      CartItem__c qli = new CartItem__c();
      qli.Quote__c = q.Id;
      qli.Quantity__c = qty;
      qli.UnitPrice__c = price;
      qli.PricebookEntryId__c = pbe;
      qli.Product__c = (String) product.get('productId');
      qli.TotalPrice__c = qty * price;
      pbeIds.add(pbe);
      qlis.add(qli);
    }

    Map<ID, PricebookEntry> qliPbes = new Map<ID, PricebookEntry>(
      [
        SELECT
          Id,
          UnitPrice,
          ProductSellingModelId,
          ProductSellingModel.SellingModelType
        FROM PricebookEntry
        WHERE Id IN :pbeIds
      ]
    );
    for (CartItem__c ql : qlis) {
      PricebookEntry pb = qliPbes.get(ql.PricebookEntryId__c);
      // set selling model type for all
      ql.SellingModelType__c = pb.ProductSellingModel.SellingModelType;
      ql.ListPrice__c = pb.UnitPrice;
      // if (pb.ProductSellingModel.SellingModelType == 'One Time') {
      //   System.debug('One Time');
      // }

      // // Evergreen
      // if (pb.ProductSellingModel.SellingModelType == 'Evergreen') {
      //   System.debug('Evergreen');
      //   ql.StartDate = startDate;
      //   ql.PeriodBoundary = 'Anniversary';
      //   ql.BillingFrequency = 'Monthly';
      // }

      // // Term
      // if (pb.ProductSellingModel.SellingModelType == 'TermDefined') {
      //   System.debug('Term-Defined');
      //   Integer numMonths = 12;

      //   Date endDate = Date.today().addMonths(numMonths).addDays(-1);
      //   ql.StartDate = startDate;
      //   ql.EndDate = endDate;

      //   //ql.PricingTermCount = numMonths;
      //   ql.PeriodBoundary = 'Anniversary';
      //   ql.BillingFrequency = 'Monthly';
      // }
    }

    try {
      System.debug(JSON.serializePretty(qlis));
      Database.insert(qlis);
    } catch (DmlException e) {
      System.debug(e);
    }

    return q.Id;
  }

  @AuraEnabled
  public static Id quoteCartToOrder(Id quoteId) {
    Date startDate = System.today();
    // Map Quote to Order
    Order o = new Order();
    Quote q = [
      SELECT Id, ContactId, Contact.AccountId, ExpirationDate, Pricebook2Id
      FROM Quote
      WHERE Id = :quoteId
    ];
    o.Status = 'Draft';
    o.EffectiveDate = startDate;

    o.Pricebook2Id = q.Pricebook2Id;
    o.AccountId = q.Contact.AccountId;
    o.BillToContactId = q.ContactId;

    try {
      Database.insert(o);
    } catch (DmlException e) {
      system.debug(e);
    }

    AppUsageAssignment buyNow = new AppUsageAssignment();
    buyNow.AppUsageType = 'BuyNow';
    buyNow.RecordId = o.Id;
    AppUsageAssignment subMgmt = new AppUsageAssignment();
    subMgmt.AppUsageType = 'SubscriptionManagement';
    subMgmt.RecordId = o.Id;

    OrderAction oa = new OrderAction();
    oa.OrderId = o.Id;
    oa.Type = 'New Sale';
    try {
      Database.insert(buyNow);
      Database.insert(subMgmt);
      Database.insert(oa);
    } catch (DmlException e) {
      System.debug(e);
    }
    // Map QuoteLines to OrderProducts

    // get Quote Lnes
    List<CartItem__c> qlis = [
      SELECT
        Id,
        Quote__c,
        Quantity__c,
        UnitPrice__c,
        ListPrice__c,
        TotalPrice__c,
        Product__c,
        Product__r.TaxPolicy.DefaultTaxTreatmentId,
        PricebookEntryId__c,
        SellingModelType__c
      FROM CartItem__c
      WHERE Quote__c = :quoteId
    ];
    List<OrderItem> ois = new List<OrderItem>();

    for (CartItem__c ql : qlis) {
      OrderItem oi = new OrderItem();
      oi.OrderId = o.Id;
      // map data from ql
      oi.ServiceDate = startDate;
      oi.Quantity = ql.Quantity__c;
      oi.UnitPrice = ql.ListPrice__c;
      oi.NetUnitPrice = ql.UnitPrice__c;
      oi.TotalLineAmount = ql.TotalPrice__c;
      oi.PricebookEntryId = ql.PricebookEntryId__c;
      oi.OrderActionId = oa.Id;
      // 238 field is not writeable
      //oi.ProductSellingModelId = ql.PricebookEntry.ProductSellingModelId;
      oi.TaxTreatmentId = ql.Product__r.TaxPolicy.DefaultTaxTreatmentId;

      // One time
      if (ql.SellingModelType__c == 'OneTime') {
        System.debug('One Time');
      }

      // Evergreen
      if (ql.SellingModelType__c == 'Evergreen') {
        System.debug('Evergreen');
        oi.PeriodBoundary = 'Anniversary';
        oi.BillingFrequency2 = 'Monthly';
      }

      // Term
      if (ql.SellingModelType__c == 'TermDefined') {
        System.debug('Term-Defined');
        Integer numMonths = 12;
        Decimal totalLine = numMonths * ql.TotalPrice__c;
        oi.TotalLineAmount = totalLine;

        Date endDate = Date.today().addMonths(numMonths).addDays(-1);
        oi.EndDate = endDate;

        oi.PricingTermCount = numMonths;
        oi.PeriodBoundary = 'Anniversary';
        oi.BillingFrequency2 = 'Monthly';
      }
      System.debug(JSON.serializePretty(oi));
      // add order items to list
      ois.add(oi);
    }

    try {
      Database.insert(ois);
    } catch (DmlException e) {
      system.debug(e);
    }

    return o.Id;
  }
}
