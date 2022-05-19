/**
 * @author SF EMEA Pro Services, Sam Check
 * @date 03/14/2022
 * @description Controller for 'My Invoices' Community LWC
 */

public without sharing class SM_MyInvoicesController {
  @AuraEnabled
  public static List<InvoiceWrapper> getAllInvoicesForCurrentUser() {
    User currentUserAccount = [
      SELECT Contact.AccountId
      FROM User
      WHERE Id = :Userinfo.getUserid()
    ];
    return getAccountInvoices(currentUserAccount.Contact.AccountId);
  }

  @AuraEnabled
  public static List<InvoiceWrapper> getAccountInvoices(Id accountId) {
    List<InvoiceWrapper> invoiceWrappers = new List<InvoiceWrapper>();
    try {
      List<Invoice> invoices = [
        SELECT
          Id,
          CurrencyIsoCode,
          ReferenceEntityId,
          BillingAccountId,
          BillingAccount.BillingAddress,
          BillingAccount.Name,
          DocumentNumber,
          TotalAmount,
          TotalAmountWithTax,
          NetPaymentsApplied,
          ReferenceEntity.Name,
          Status,
          Balance,
          InvoiceDate,
          DueDate,
          (
            SELECT
              Id,
              ReferenceEntityItemId,
              BillingScheduleId,
              BillingSchedule.ReferenceEntityItemId,
              Product2.Name,
              Product2.Description,
              Product2.DisplayUrl,
              LineAmount,
              InvoiceLineStartDate,
              InvoiceLineEndDate,
              Quantity,
              Type
            FROM InvoiceLines
          )
        FROM Invoice
        WHERE BillingAccountId = :accountId AND Status = 'Posted'
        ORDER BY DocumentNumber DESC
      ];

      // Build list of RefIds
      List<Id> refIds = new List<Id>();
      for (Invoice i : invoices) {
        for (InvoiceLine il : i.InvoiceLines) {
          refIds.add(il.BillingSchedule.ReferenceEntityItemId);
        }
      }

      Map<Id, OrderItem> idsToOrderItems = new Map<Id, OrderItem>(
        [
          SELECT
            Id,
            Product2.Name,
            Product2.Description,
            Product2.DisplayUrl,
            BillingFrequency2,
            LineNumber,
            EndDate
          FROM OrderItem
          WHERE Id IN :refIds
        ]
      );

      for (Invoice invoice : invoices) {
        if (!invoice.InvoiceLines.isEmpty()) {
          InvoiceWrapper invoiceWrapper = buildInvoiceWrapper(invoice);
          for (InvoiceLine invoiceLine : invoice.InvoiceLines) {
            OrderItem oi = idsToOrderItems.get(
              invoiceLine.ReferenceEntityItemId
            );
            InvoiceLineWrapper ilw = buildInvoiceLineWrapper(invoiceLine, oi);
            invoiceWrapper.invoiceLines.add(ilw);
          }
          invoiceWrappers.add(invoiceWrapper);
        }
      }
      return invoiceWrappers;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  public static InvoiceWrapper buildInvoiceWrapper(Invoice invoice) {
    InvoiceWrapper invoiceWrapper = new InvoiceWrapper();
    invoiceWrapper.id = invoice.Id;
    invoiceWrapper.accountName = invoice.BillingAccount.Name;
    invoiceWrapper.billingAddress = invoice.BillingAccount.BillingAddress;
    invoiceWrapper.documentNumber = invoice.DocumentNumber;
    invoiceWrapper.balance = invoice.Balance;
    invoiceWrapper.totalAmount = invoice.TotalAmount;
    invoiceWrapper.totalAmountWithTax = invoice.TotalAmountWithTax;
    invoiceWrapper.currencyIsoCode = invoice.CurrencyIsoCode;
    invoiceWrapper.netPaymentsApplied = invoice.NetPaymentsApplied;
    invoiceWrapper.invoiceDate = invoice.InvoiceDate;
    invoiceWrapper.dueDate = invoice.DueDate;
    invoiceWrapper.isPayed = invoice.Balance == 0;

    return invoiceWrapper;
  }

  public static InvoiceLineWrapper buildInvoiceLineWrapper(
    InvoiceLine invoiceLine,
    OrderItem oi
  ) {
    Boolean isOneTime =
      invoiceLine.InvoiceLineStartDate == invoiceLine.InvoiceLineEndDate;

    InvoiceLineWrapper ilw = new InvoiceLineWrapper(
      invoiceLine.Id,
      invoiceLine.type,
      invoiceLine.InvoiceLineEndDate,
      invoiceLine.LineAmount,
      invoiceLine.quantity,
      invoiceLine.InvoiceLineStartDate,
      invoiceLine.Product2.Name,
      isOneTime
    );
    System.debug('*----------------');
    System.debug(JSON.serializePretty(ilw));
    if (invoiceLine.Product2.Description != null) {
      ilw.description = invoiceLine.Product2.Description;
    } else {
      ilw.description = '';
    }
    System.debug('Descr');
    if (invoiceLine.Product2.DisplayUrl != null) {
      ilw.displayUrl = invoiceLine.Product2.DisplayUrl;
    } else {
      ilw.displayUrl = '';
    }
    System.debug('disaplyUrl');
    // if (oi.LineNumber != null) {
    //   ilw.lineNumber = oi.LineNumber;
    // } else {
    //   ilw.lineNumber = 1;
    // }

    // System.debug('lineNumber');
    // if (oi.BillingFrequency2 != null) {
    //   ilw.billingFreq = oi.BillingFrequency2;
    // } else {
    //   ilw.billingFreq = '';
    // }
    // System.debug('BillingFreq');

    return ilw;
  }

  public class InvoiceWrapper {
    @AuraEnabled
    public string id { get; set; }
    @AuraEnabled
    public string accountName { get; set; }
    @AuraEnabled
    public System.Address billingAddress { get; set; }
    @AuraEnabled
    public string documentNumber { get; set; }
    @AuraEnabled
    public decimal balance { get; set; }
    @AuraEnabled
    public decimal totalAmount { get; set; }
    @AuraEnabled
    public decimal totalAmountWithTax { get; set; }
    @AuraEnabled
    public decimal netPaymentsApplied { get; set; }
    @AuraEnabled
    public string paymentId { get; set; }
    @AuraEnabled
    public string currencyIsoCode { get; set; }
    @AuraEnabled
    public Date invoiceDate { get; set; }
    @AuraEnabled
    public Date dueDate { get; set; }
    @AuraEnabled
    public Boolean isPayed { get; set; }
    @AuraEnabled
    public List<InvoiceLineWrapper> invoiceLines { get; set; }

    public InvoiceWrapper() {
      this.invoiceLines = new List<InvoiceLineWrapper>();
    }
  }

  public class InvoiceLineWrapper {
    @AuraEnabled
    public String name { get; set; }
    @AuraEnabled
    public String description { get; set; }
    @AuraEnabled
    public String displayUrl { get; set; }

    @AuraEnabled
    public String value { get; set; }
    @AuraEnabled
    public String type { get; set; }
    @AuraEnabled
    public Date dueDate { get; set; }
    @AuraEnabled
    public Date startDate { get; set; }
    @AuraEnabled
    public Decimal lineAmount { get; set; }
    @AuraEnabled
    public Decimal quantity { get; set; }
    @AuraEnabled
    public Boolean oneTime { get; set; }
    @AuraEnabled
    public String billingFreq { get; set; }
    @AuraEnabled
    public Integer lineNumber { get; set; }

    InvoiceLineWrapper(
      String value,
      String type,
      Date dueDate,
      Decimal lineAmount,
      Decimal quantity,
      Date startDate,
      String name,
      Boolean oneTime
    ) {
      this.value = value;
      this.type = type;
      this.dueDate = dueDate;
      this.lineAmount = lineAmount;
      this.quantity = quantity;
      this.startDate = startDate;
      this.name = name;
      this.oneTime = oneTime;
    }
  }
}
