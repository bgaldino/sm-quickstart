/**
 * @author Sam Check
 * @date 03/14/2022
 * @description Controller for Community Checkout LWC
 */

public with sharing class SM_CommunityCheckoutController {
  /**
   * @description utility to return current user's SessionId for API auth
   * @return Current User's Session Id
   */
  @AuraEnabled(cacheable=true)
  public static String getSessionId() {
    return UserInfo.getSessionId();
  }

  /**
   * @description utility to populate current user details
   * @return UserWrapper class with accountId and address fields
   */

  @AuraEnabled
  public static UserWrapper getCurrentUserInfo() {
    User currentUserAccount = [
      SELECT Contact.AccountId, Contact.Account.BillingAddress
      FROM User
      WHERE Id = :Userinfo.getUserid()
    ];
    UserWrapper userWrapper = new UserWrapper();
    userWrapper.accountId = currentUserAccount.Contact.AccountId;
    userWrapper.address = new AddressWrapper();
    userWrapper.address.street = currentUserAccount.Contact.Account.BillingAddress.getStreet();
    userWrapper.address.city = currentUserAccount.Contact.Account.BillingAddress.getCity();
    userWrapper.address.province = currentUserAccount.Contact.Account.BillingAddress.getState();
    userWrapper.address.postalCode = currentUserAccount.Contact.Account.BillingAddress.getPostalCode();
    userWrapper.address.country = currentUserAccount.Contact.Account.BillingAddress.getCountry();
    return userWrapper;
  }

  // place order
  @AuraEnabled
  public static Id placeOrder(
    List<Map<String, Object>> products,
    Map<String, Object> address,
    String pricebookId
  ) {
    User currentUserAccount = [
      SELECT Contact.AccountId, Contact.Id
      FROM User
      WHERE Id = :Userinfo.getUserid()
    ];
    Map<String, Object> details = new Map<String, Object>();
    details.put('address', address);
    details.put('accountId', currentUserAccount.Contact.AccountId);
    details.put('contactId', currentUserAccount.Contact.Id);
    details.put('pricebookId', pricebookId);

    return SM_OrderProcessor.createStandaloneOrder(products, details);
  }

  // place quote
  @AuraEnabled
  public static Id placeQuote(
    List<Map<String, Object>> products,
    Map<String, Object> address,
    String pricebookId
  ) {
    User currentUserAccount = [
      SELECT ContactId, Contact.Name
      FROM User
      WHERE Id = :Userinfo.getUserid()
    ];

    Map<String, Object> details = new Map<String, Object>();
    details.put('address', address);
    details.put('contactId', currentUserAccount.ContactId);
    details.put('contactName', currentUserAccount.Contact.Name);
    details.put('pricebookId', pricebookId);
    //return SM_QuoteProcessor.createStandaloneQuote(products, details);
    // 238 fix
    return SM_CartProcessor.createStandaloneCart(products, details);
  }

  @AuraEnabled
  public static string convertQuoteToOrder(String quoteId) {
    try {
      return SM_CartProcessor.quoteCartToOrder(quoteId);
      //return SM_QuoteProcessor.quoteToOrder(quoteId);
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  @AuraEnabled
  public static string payInvoiceInFull(
    Map<String, Object> paymentCard,
    Boolean newCard,
    Invoice invoice,
    String paymentMethodId,
    String gatewayId
  ) {
    system.debug('payInvoiceInFull');
    User currentUserAccount = [
      SELECT Contact.AccountId
      FROM User
      WHERE Id = :Userinfo.getUserid()
    ];
    SM_PaymentMethodProcessor.RequestWrapper requestWrapper = new SM_PaymentMethodProcessor.RequestWrapper();
    SM_PaymentMethodProcessor.PaymentMethod paymentMethod = new SM_PaymentMethodProcessor.PaymentMethod();

    requestWrapper.paymentGatewayId = gatewayId;
    requestWrapper.paymentMethod = paymentMethod;
    requestWrapper.accountId = currentUserAccount.Contact.AccountId;
    requestWrapper.amount = invoice.TotalAmountWithTax;
    requestWrapper.comments = 'No Comment';
    requestWrapper.effectiveDate = system.Now();
    requestWrapper.currencyIsoCode = 'USD';

    if (newCard) {
      paymentCard.put('accountId', currentUserAccount.Contact.AccountId);
      SM_PaymentMethodProcessor.CardDetails cardDetail = SM_PaymentMethodProcessor.buildCardDetails(
        paymentCard
      );
      paymentMethod.saveForFuture = (Boolean) paymentCard.get('saveForFuture');
      paymentMethod.cardPaymentMethod = cardDetail;
    } else {
      paymentMethod.id = paymentMethodId;
    }
    system.debug(JSON.serializePretty(requestWrapper));
    return SM_PaymentMethodProcessor.makeSale(requestWrapper);
  }

  public class UserWrapper {
    @AuraEnabled
    public String accountId { get; set; }
    @AuraEnabled
    public AddressWrapper address { get; set; }
  }

  public class AddressWrapper {
    @AuraEnabled
    public string street { get; set; }
    @AuraEnabled
    public string city { get; set; }
    @AuraEnabled
    public string province { get; set; }
    @AuraEnabled
    public string postalCode { get; set; }
    @AuraEnabled
    public string country { get; set; }
  }
}
