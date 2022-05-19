trigger SM_CartItemBefore on CartItem__c(before insert, before update) {
  for (CartItem__c ci : Trigger.New) {
    Decimal discount;
    if (ci.Discount__c > 0) {
      discount = ci.Discount__c / 100; // get percent value
    } else {
      discount = 0;
    }
    // set Total Price field
    ci.TotalPrice__c = (1 - discount) * ci.Quantity__c * ci.UnitPrice__c;
  }
}
