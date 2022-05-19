/**
 * @author SF EMEA Pro Services, Sam Check
 * @date 03/14/2022
 * @description Controller for 'My Orders' Community LWC
 */

public without sharing class SM_MyOrdersController {
  @AuraEnabled
  public static List<OrderWrapper> getAllOrdersForCurrentUser() {
    User currentUserAccount = [
      SELECT Contact.AccountId
      FROM User
      WHERE Id = :Userinfo.getUserid()
    ];
    return getAllOrdersByAccount(currentUserAccount.Contact.AccountId);
  }

  @AuraEnabled
  public static List<OrderWrapper> getAllOrdersByAccount(Id accountId) {
    List<OrderWrapper> OrderWrappers = new List<OrderWrapper>();

    List<Order> orders = [
      SELECT
        Id,
        Name,
        OrderNumber,
        AccountId,
        Account.Name,
        Account.BillingAddress,
        ActivatedDate,
        TotalAmount,
        CurrencyIsoCode,
        IsReductionOrder,
        (
          SELECT
            Id,
            NextBillingDate,
            Status,
            ReferenceEntityItemId,
            ReferenceEntityItem.Name,
            Quantity,
            TotalAmount
          FROM BillingSchedules
        )
      FROM Order
      WHERE accountId = :accountId AND Status = 'Activated'
      ORDER BY OrderNumber DESC
    ];

    for (Order order : orders) {
      OrderWrapper orderWrapper = new OrderWrapper();
      orderWrapper.id = order.Id;
      orderWrapper.orderNumber = order.orderNumber;
      orderWrapper.activatedDate = Date.valueOf(order.activatedDate);
      orderWrapper.accountName = order.Account.Name;
      orderWrapper.currencyIsoCode = order.CurrencyIsoCode;
      orderWrapper.totalAmount = order.TotalAmount;
      orderWrapper.isReduction = order.IsReductionOrder;
      orderWrapper.billingAddress = order.Account.BillingAddress;
      for (BillingSchedule orderProduct : order.BillingSchedules) {
        orderWrapper.billingScheduleIds.add(orderProduct.Id);
        orderWrapper.orderProducts.add(
          new OrderProductWrapper(
            orderProduct.ReferenceEntityItemId,
            orderProduct.ReferenceEntityItem.Name,
            orderProduct.NextBillingDate,
            orderProduct.TotalAmount,
            orderProduct.quantity
          )
        );
      }
      OrderWrappers.add(orderWrapper);
    }

    return OrderWrappers;
  }

  public class OrderWrapper {
    @AuraEnabled
    public string id { get; set; }
    @AuraEnabled
    public string orderNumber { get; set; }
    @AuraEnabled
    public string accountName { get; set; }
    @AuraEnabled
    public string currencyIsoCode { get; set; }
    @AuraEnabled
    public Decimal totalAmount { get; set; }
    @AuraEnabled
    public Boolean isReduction { get; set; }
    @AuraEnabled
    public Date activatedDate { get; set; }
    @AuraEnabled
    public System.Address billingAddress { get; set; }
    @AuraEnabled
    public List<Id> billingScheduleIds { get; set; }
    @AuraEnabled
    public List<OrderProductWrapper> orderProducts { get; set; }

    public OrderWrapper() {
      this.orderProducts = new List<OrderProductWrapper>();
      this.billingScheduleIds = new List<Id>();
    }
  }

  public class OrderProductWrapper {
    @AuraEnabled
    public string value { get; set; }
    @AuraEnabled
    public string label { get; set; }
    @AuraEnabled
    public date nextBillingDate { get; set; }
    @AuraEnabled
    public decimal totalPrice { get; set; }
    @AuraEnabled
    public decimal quantity { get; set; }

    OrderProductWrapper(
      String value,
      String label,
      date endDate,
      decimal totalPrice,
      decimal quantity
    ) {
      this.value = value;
      this.label = label;
      this.nextBillingDate = endDate;
      this.totalPrice = totalPrice;
      this.quantity = quantity;
    }
  }
}
