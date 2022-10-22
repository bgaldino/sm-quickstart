@isTest()
private class QueryUtilsTest {
   @testSetup
    static void main(){
        TestDataFactory.createData(); 
    }
    @isTest
    static void One(){
        Schema.sObjectType table = Account.sObjectType;
        QueryUtils.SelectClause result = new QueryUtils.SelectClause(table,true);
        
        Test.startTest();
        QueryUtils qu = new QueryUtils(table);
        result=qu.getSelectClause();
        System.assert(result!=null);
        Test.stopTest();
    }
    @isTest
    static void Two(){
        String result;
        Schema.sObjectType table = Account.sObjectType;
        Test.startTest();
        QueryUtils qu = new QueryUtils(table);
        result =qu.buildSOQL();
        System.assertNotEquals(result, null);
        Test.stopTest();
    }
    @isTest
    static void Two2(){
        String wc= 'Test'; 
        Schema.sObjectType table = Account.sObjectType;
        Test.startTest();
        QueryUtils qu = new QueryUtils(table);
        qu.setWhereClause(wc);
        // V O I D   M E T H O D
        String str = qu.buildSOQL();
        System.assertEquals(str, 'SELECT  FROM Account Test');
        Test.stopTest();
    }
    @isTest
    static void Four(){
        Schema.sObjectType table = Account.sObjectType;
        QueryUtils.SelectClause result = new QueryUtils.SelectClause(table,true);
        Test.startTest();
        QueryUtils qu = new QueryUtils(table);
        result= qu.getSelectClause().addField('GatewayAuthCode', false);
        System.assert(result!=null);
        Test.stopTest();
    }
    @isTest
    static void Five(){
       Schema.sObjectField[] fieldList = new sObjectField[] {
        Account.Name, Account.Industry
        };
        Schema.sObjectType table = Account.sObjectType;
        Boolean result;
        Boolean expect =false;
        Test.startTest();
        QueryUtils qu = new QueryUtils(table);
        result=qu.getSelectClause().toTranslate(fieldList.get(0));
        System.assertEquals(expect, result);
        Test.stopTest();
    }
    @isTest
    static void Six(){
       Schema.sObjectField[] fieldList = new sObjectField[] {
        Account.Name, Account.Industry
        };
        Schema.sObjectType table = Account.sObjectType;
        QueryUtils.SelectClause result = new QueryUtils.SelectClause(table,true);
        Test.startTest();
        QueryUtils qu = new QueryUtils(table);
        result =qu.getSelectClause().addFields(fieldList);
        System.assert(result!=null);
        Test.stopTest();
    }
    @isTest
    static void Seven(){
       Schema.sObjectType table = Account.sObjectType;
        Test.startTest();
        QueryUtils qu = new QueryUtils(table);
        String result;
        qu.getSelectClause().addField('GatewayAuthCode', true);
        QueryUtils.FieldExpression fe = new QueryUtils.FieldExpression('relationship','field',true);
        result=fe.buildSOQL();
        System.assert(result!=null);
        Test.stopTest();
    }
    @isTest
    static void Eight(){
       Schema.sObjectType table = Account.sObjectType;
        String result;
        QueryUtils qu = new QueryUtils(table);
        qu.getSelectClause().addField('GatewayAuthCode', true);
        Test.startTest();
        QueryUtils.FieldExpression fe = new QueryUtils.FieldExpression(Null,'field',true);
        result=fe.buildSOQL();
        System.assert(result!=null);
        Test.stopTest();
    }

}