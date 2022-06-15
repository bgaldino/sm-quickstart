public without sharing class SM_QuoteProcessor {
  public static String createStandaloneQuote(
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
    List<QuoteLineItem> qlis = new List<QuoteLineItem>();
    for (Map<String, Object> product : products) {
      //Integer qty = Integer.valueOf((Decimal) product.get('quantity'));
      Integer qty = Integer.valueOf(String.valueOf(product.get('quantity')));
      Decimal price = (Decimal) product.get('price');
      String pbe = (String) product.get('pricebookEntryId');
      QuoteLineItem qli = new QuoteLineItem(
        QuoteId = q.Id,
        Quantity = qty,
        UnitPrice = price,
        PricebookEntryId = pbe
      );
      pbeIds.add(pbe);
      qlis.add(qli);
    }

    Map<ID, PricebookEntry> qliPbes = new Map<ID, PricebookEntry>(
      [
        SELECT Id, ProductSellingModelId, ProductSellingModel.SellingModelType
        FROM PricebookEntry
        WHERE Id IN :pbeIds
      ]
    );
    for (QuoteLineItem ql : qlis) {
      PricebookEntry pb = qliPbes.get(ql.PricebookEntryId);
      if (pb.ProductSellingModel.SellingModelType == 'OneTime') {
        System.debug('OneTime');
      }

      // Evergreen
      if (pb.ProductSellingModel.SellingModelType == 'Evergreen') {
        System.debug('Evergreen');
        ql.StartDate = startDate;
        ql.PeriodBoundary = 'Anniversary';
        ql.BillingFrequency = 'Monthly';
      }

      // Term
      if (pb.ProductSellingModel.SellingModelType == 'TermDefined') {
        System.debug('TermDefined');
        Integer numMonths = 12;

        Date endDate = Date.today().addMonths(numMonths).addDays(-1);
        ql.StartDate = startDate;
        ql.EndDate = endDate;

        //ql.PricingTermCount = numMonths;
        ql.PeriodBoundary = 'Anniversary';
        ql.BillingFrequency = 'Monthly';
      }
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
  public static Id quoteToOrder(Id quoteId) {
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
    // Map QuoteLines to OrderProducts

    // get Quote Lnes
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
        Product2.TaxPolicy.DefaultTaxTreatmentId,
        PricebookEntryId,
        PricebookEntry.ProductSellingModelId,
        PricebookEntry.ProductSellingModel.SellingModelType
      FROM QuoteLineItem
      WHERE QuoteId = :quoteId
    ];
    List<OrderItem> ois = new List<OrderItem>();

    for (QuoteLineItem ql : qlis) {
      System.debug(
        'Selling Model: ' +
        ql.PricebookEntry.ProductSellingModel.SellingModelType
      );
      OrderItem oi = new OrderItem();
      oi.OrderId = o.Id;
      // map data from ql
      oi.ServiceDate = startDate;
      oi.Quantity = ql.Quantity;
      oi.UnitPrice = ql.ListPrice;
      oi.NetUnitPrice = ql.UnitPrice;
      oi.TotalLineAmount = ql.TotalPrice;
      oi.PricebookEntryId = ql.PricebookEntryId;
      // 238 field is not writeable
      //oi.ProductSellingModelId = ql.PricebookEntry.ProductSellingModelId;
      oi.TaxTreatmentId = ql.Product2.TaxPolicy.DefaultTaxTreatmentId;

      // One time
      if (
        ql.PricebookEntry.ProductSellingModel.SellingModelType == 'OneTime'
      ) {
        System.debug('One Time');
      }

      // Evergreen
      if (
        ql.PricebookEntry.ProductSellingModel.SellingModelType == 'Evergreen'
      ) {
        System.debug('Evergreen');
        oi.PeriodBoundary = 'Anniversary';
        oi.BillingFrequency2 = 'Monthly';
      }

      // Term
      if (
        ql.PricebookEntry.ProductSellingModel.SellingModelType == 'TermDefined'
      ) {
        System.debug('Term-Defined');
        Integer numMonths = 12;
        Decimal totalLine = numMonths * ql.TotalPrice;
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
