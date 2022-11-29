@IsTest
public with sharing class DCM_BaseUtilitiesTest {
    @isTest
    static void isNullOrEmptyTest() {
        //Given
        List<String> strings = new List<String>{ 'test' };
        List<String> emptyStrings = new List<String>();

        Map<String, String> emptyMap = new Map<String, String>();
        Map<String, String> notEmptyMap = new Map<String, String>{ 'test' => 'test' };

        Map<Object, Object> objectMap = new Map<Object, Object>();
        Map<String, Object> stringObjectMap = new Map<String, Object>();

        //Then
        System.assert(DCM_BaseUtilities.isNullOrEmpty(emptyStrings));
        System.assert(!DCM_BaseUtilities.isNullOrEmpty(strings));
        System.assert(DCM_BaseUtilities.isNullOrEmpty(emptyMap));
        System.assert(DCM_BaseUtilities.isNotNullOrEmpty(notEmptyMap));
        System.assert(DCM_BaseUtilities.isNullOrEmpty(objectMap));
        System.assert(DCM_BaseUtilities.isNullOrEmpty(stringObjectMap));
    }
}
