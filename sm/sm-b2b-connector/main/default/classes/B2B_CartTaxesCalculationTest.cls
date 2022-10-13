@isTest public class B2B_CartTaxesCalculationTest {
    @testSetup public static void setup() {
        TestDataFactory.createData();
        TestDataFactory.createTaxEngine();
    }
    
    @isTest public static void calculateTaxAmountTest() {
        Test.setMock(HttpCalloutMock.class, new CalculateTaxAmountMock());
        
        Test.startTest();
        List<CartItem> cartItems = [SELECT Id, totalPrice FROM CartItem];
        Map<String, object> res = B2B_CartTaxesCalculation.calculateTaxAmount(cartItems);
        Test.stopTest();
        
        system.assertNotEquals(res.size(), 0);
    }
    
    @isTest public static void createTaxCartItemTest() {
        WebCart cart = [
            SELECT Id,
            (SELECT Id, ListPrice FROM CartItems LIMIT 1)
            FROM WebCart LIMIT 1
        ];
        system.assertEquals(1, cart.CartItems.size());
        
        RSM_TaxModelResponse res = new RSM_TaxModelResponse();
        
        res.lineItems = new List<RSM_TaxModelResponse.LineItem>();
        RSM_TaxModelResponse.LineItem lineItem = new RSM_TaxModelResponse.LineItem();
        system.debug(cart.CartItems);
        lineItem.lineNumber = cart.CartItems[0].Id;
        lineItem.taxes = new List<RSM_TaxModelResponse.TaxItem>();
        RSM_TaxModelResponse.TaxItem taxItem = new RSM_TaxModelResponse.TaxItem();
        taxItem.tax = 100;
        taxItem.rate = 100;
        lineItem.taxes.add(taxItem);
        res.lineItems.add(lineItem);
        
        B2B_CartTaxesCalculation.createTaxCartItem(cart.Id, JSON.serialize(res));
        
        CartTax cartTax = [SELECT Id FROM CartTax LIMIT 1];
        system.assertNotEquals(cartTax, null);
    }
}