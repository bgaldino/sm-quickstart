@IsTest
public with sharing class DCM_GenericStubProvider implements System.StubProvider {
    private Map<String, Object> responsesByMethodNames;

    public DCM_GenericStubProvider(Map<String, Object> responsesByMethodNames) {
        this.responsesByMethodNames = responsesByMethodNames;
    }

    public Object handleMethodCall(Object stubbedObject,
        String stubbedMethodName,
        System.Type returnType,
        List<System.Type> listOfParamTypes,
        List<String> listOfParamNames,
        List<Object> listOfArgs) {

        return responsesByMethodNames.get(stubbedMethodName);
    }
}