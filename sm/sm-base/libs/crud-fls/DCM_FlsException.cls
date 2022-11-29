/*
 * DCM_FlsException represents a running user's lack of field level security to a specific field at a profile (or permission set) level.
 */
public class DCM_FlsException extends DCM_SecurityException {
    public DCM_FlsException(DCM_OperationType operation, Schema.SObjectType objectType, Schema.SObjectField fieldToken) {
        this.operationType = operation;
        this.objectType = objectType;
        this.fieldToken = fieldToken;
        if (operation == DCM_OperationType.CREATE)
            this.setMessage(System.Label.fflib_security_error_field_not_insertable);
        else if (operation == DCM_OperationType.READ)
            this.setMessage(System.Label.fflib_security_error_field_not_readable);
        else if (operation == DCM_OperationType.MODIFY)
            this.setMessage(System.Label.fflib_security_error_field_not_updateable);

        this.setMessage(String.format(this.getMessage(), new List<String>{ objectType.getDescribe().getName(), fieldToken.getDescribe().getName() }));
    }
}
