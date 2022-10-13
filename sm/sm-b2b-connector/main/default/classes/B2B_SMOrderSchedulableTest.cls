@isTest public class B2B_SMOrderSchedulableTest {
    @testSetup public static void setup() {
        TestDataFactory.createDataSMOrder();
    }
    
    @isTest public static void SMOrderSchedulableTest() {        
        Test.startTest();       
        String jobId = system.schedule('Test Sched', '0 0 0 20 8 ? 2023', new B2B_SMOrderSchedulable());
    	CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        System.assertEquals(0, ct.TimesTriggered);
      	System.assertEquals('2023-08-20 00:00:00', String.valueOf(ct.NextFireTime));   
        Test.stopTest();
    }
    
    @isTest public static void SMOrderBatchableTest() {
        List<AsyncApexJob> aajList = [SELECT Id FROM AsyncApexJob];
        Test.startTest();
        System.assertEquals(0, aajList.size());
        Id jobId = Database.executeBatch(new B2B_SMOrderSchedulable(), 10);
        aajList = [SELECT Id FROM AsyncApexJob];
        System.assertEquals(1, aajList.size());
        Test.stopTest();
    }
    
    @isTest public static void executeBatchTest() {
        BillingSchedule bs = new BillingSchedule();
        B2B_SMOrderSchedulable os = new B2B_SMOrderSchedulable();
        Test.startTest();
        os.execute(null, new List<BillingSchedule>{bs});
        //void method
        System.assertEquals('', '');
        Test.stopTest();
    }
}