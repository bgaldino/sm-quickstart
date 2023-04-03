@isTest
private class SM_CouponServiceTest {
	@TestSetup
    static void setup() {
        System.runAs(RSM_TestEnvironment.portalAccountOwner) {
            TestDataFactory.createData();
        }
    }

    @isTest
    static void testGetCartItems() {
        WebCart cart = [SELECT Id FROM WebCart LIMIT 1];
        Community community = [ SELECT Id FROM Community  LIMIT 1];
        String couponCode = 'testCoupon';
        Account account = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1];
        String cartId = SM_CouponService.getCartItems(community.Id, couponCode, cart.Id, account.Id);
        System.assertNotEquals(null, cartId);
    }

    @isTest
    static void testGetAppliedCoupon() {
        WebCart cart = [SELECT Id FROM WebCart LIMIT 1];
        Community community = [ SELECT Id FROM Community  LIMIT 1];
        Account account = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1];
        List<String> couponsList = SM_CouponService.getAppliedCoupon(community.Id, cart.Id, account.Id);
        System.assertNotEquals(null, couponsList);
    }

    @isTest
    static void testDeleteCartCoupon() {
        WebCart cart = [SELECT Id FROM WebCart LIMIT 1];
        Community community = [ SELECT Id FROM Community  LIMIT 1];
        String couponCode = 'testCode';
        Account account = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1];
        String cartId = SM_CouponService.deleteCartCoupon(community.Id, cart.Id, couponCode, account.Id);
        System.assertNotEquals(null, cartId);
    }

    @isTest
    static void testIsQuoteDiscountApplied() {
        WebCart cart = [SELECT Id FROM WebCart LIMIT 1];
        Boolean result = SM_CouponService.isQuoteDiscountApplied(cart.Id);
        System.assertNotEquals(null, result);
    }
}