/*
 * SecurityException is never be thrown directly by fflib_SecurityUtils, instead all
 * forms of CRUD and FLD violations throw subclasses of it. It is provided as a convenience
 * in the event you wish to handle CRUD and FLS violations the same way (e.g. die and display an error)
 */
public virtual class DCM_SecurityException extends Exception {
    @TestVisible
    protected DCM_OperationType operationType;
    @TestVisible
    protected Schema.SObjectType objectType;
    @TestVisible
    protected Schema.SObjectField fieldToken;
}
