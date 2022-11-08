/**
 * Copyright (c), FinancialForce.com, inc
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without modification,
 *   are permitted provided that the following conditions are met:
 *
 * - Redistributions of source code must retain the above copyright notice,
 *      this list of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright notice,
 *      this list of conditions and the following disclaimer in the documentation
 *      and/or other materials provided with the distribution.
 * - Neither the name of the FinancialForce.com, inc nor the names of its contributors
 *      may be used to endorse or promote products derived from this software without
 *      specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 *  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
 *  OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL
 *  THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 *  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 *  OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
 *  OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 *  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 **/

/**
 * Utility class for checking FLS/CRUD.
 * NOTE: all "check" methods will throw a DCM_SecurityException (or subclass) if the user does not have
 * the proper security granted.
 **/
public class fflib_SecurityUtils {
    /**
     * If set to true all check methods will always return void, and never throw exceptions.
     * This should really only be set to true if an app-wide setting to disable in-apex
     * FLS and CRUD checks exists and is enabled.
     * Per security best practices setting BYPASS should be an a opt-in, and not the default behavior.
     **/
    public static Boolean BYPASS_INTERNAL_FLS_AND_CRUD = false;

    /**
     * Checks both insert FLS and CRUD for the specified object type and fields.
     * @exception DCM_FlsException if the running user does not have insert rights to any fields in {@code fieldNames}.
     * @exception DCM_CrudException if the running user does not have insert rights to {@code objectType}
     **/
    public static void checkInsert(SObjectType objectType, List<String> fieldNames) {
        checkObjectIsInsertable(objectType);

        for (String fieldName : fieldNames) {
            checkFieldIsInsertable(objectType, fieldName);
        }
    }

    /**
     * Identical to {@link #checkInsert(SObjectType,List<String>)}, except with SObjectField instead of String field references.
     * @exception DCM_FlsException if the running user does not have insert rights to any fields in {@code fieldTokens}.
     * @exception DCM_CrudException if the running user does not have insert rights to {@code objectType}
     **/
    public static void checkInsert(SObjectType objectType, List<SObjectField> fieldTokens) {
        checkObjectIsInsertable(objectType);

        for (SObjectField fieldToken : fieldTokens) {
            checkFieldIsInsertable(objectType, fieldToken);
        }
    }

    /**
     * Checks both read FLS and CRUD for the specified object type and fields.
     * @exception DCM_FlsException if the running user does not have read rights to any fields in {@code fieldNames}.
     * @exception DCM_CrudException if the running user does not have read rights to {@code objectType}
     **/
    public static void checkRead(SObjectType objectType, List<String> fieldNames) {
        checkObjectIsReadable(objectType);

        for (String fieldName : fieldNames) {
            checkFieldIsReadable(objectType, fieldName);
        }
    }

    /**
     * Identical to {@link #checkRead(SObjectType,List<String>)}, except with SObjectField instead of String field references.
     * @exception DCM_FlsException if the running user does not have read rights to any fields in {@code fieldTokens}.
     * @exception DCM_CrudException if the running user does not have read rights to {@code objectType}
     **/
    public static void checkRead(SObjectType objectType, List<SObjectField> fieldTokens) {
        checkObjectIsReadable(objectType);

        for (SObjectField fieldToken : fieldTokens) {
            checkFieldIsReadable(objectType, fieldToken);
        }
    }

    /**
     * Checks both update FLS and CRUD for the specified object type and fields.
     * @exception DCM_FlsException if the running user does not have update rights to any fields in {@code fieldNames}.
     * @exception DCM_CrudException if the running user does not have update rights to {@code objectType}
     **/
    public static void checkUpdate(SObjectType objectType, List<String> fieldNames) {
        checkObjectIsUpdateable(objectType);

        for (String fieldName : fieldNames) {
            checkFieldIsUpdateable(objectType, fieldName);
        }
    }

    /**
     * Identical to {@link #checkUpdate(SObjectType,List<String>)}, except with SObjectField instead of String field references.
     * @exception DCM_FlsException if the running user does not have update rights to any fields in {@code fieldTokens}.
     * @exception DCM_CrudException if the running user does not have update rights to {@code objectType}
     **/
    public static void checkUpdate(SObjectType objectType, List<SObjectField> fieldTokens) {
        checkObjectIsUpdateable(objectType);

        for (SObjectField fieldToken : fieldTokens) {
            checkFieldIsUpdateable(objectType, fieldToken);
        }
    }

    /**
     * Checks insert field level security only (no CRUD) for the specified fields on {@code objectType}
     * @exception DCM_FlsException if the running user does not have insert rights to the {@code fieldName} field.
     **/
    public static void checkFieldIsInsertable(SObjectType objectType, String fieldName) {
        checkFieldIsInsertable(objectType, SchemaDescriptions.getFieldsMap(objectType).get(fieldName));
    }

    /**
     * Identical to {@link #checkFieldIsInsertable(SObjectType,String)}, except with SObjectField instead of String field reference.
     * @exception DCM_FlsException if the running user does not have insert rights to the {@code fieldName} field.
     **/
    public static void checkFieldIsInsertable(SObjectType objectType, SObjectField fieldToken) {
        checkFieldIsInsertable(objectType, fieldToken.getDescribe());
    }

    /**
     * Identical to {@link #checkFieldIsInsertable(SObjectType,String)}, except with DescribeFieldResult instead of String field reference.
     * @exception DCM_FlsException if the running user does not have insert rights to the {@code fieldName} field.
     **/
    public static void checkFieldIsInsertable(SObjectType objectType, DescribeFieldResult fieldDescribe) {
        if (BYPASS_INTERNAL_FLS_AND_CRUD)
            return;

        if (!fieldDescribe.isCreateable()) {
            throw new DCM_FlsException(DCM_OperationType.CREATE, objectType, fieldDescribe.getSObjectField());
        }
    }

    /**
     * Checks read field level security only (no CRUD) for the specified fields on {@code objectType}
     * @exception DCM_FlsException if the running user does not have read rights to the {@code fieldName} field.
     **/
    public static void checkFieldIsReadable(SObjectType objectType, String fieldName) {
        checkFieldIsReadable(objectType, SchemaDescriptions.getFieldsMap(objectType).get(fieldName));
    }

    /**
     * Identical to {@link #checkFieldIsReadable(SObjectType,String)}, except with SObjectField instead of String field reference.
     * @exception DCM_FlsException if the running user does not have read rights to the {@code fieldName} field.
     **/
    public static void checkFieldIsReadable(SObjectType objectType, SObjectField fieldToken) {
        checkFieldIsReadable(objectType, fieldToken.getDescribe());
    }

    /**
     * Identical to {@link #checkFieldIsReadable(SObjectType,String)}, except with DescribeFieldResult instead of String field reference.
     * @exception DCM_FlsException if the running user does not have read rights to the {@code fieldName} field.
     **/
    public static void checkFieldIsReadable(SObjectType objectType, DescribeFieldResult fieldDescribe) {
        if (BYPASS_INTERNAL_FLS_AND_CRUD)
            return;

        if (!fieldDescribe.isAccessible()) {
            throw new DCM_FlsException(DCM_OperationType.READ, objectType, fieldDescribe.getSObjectField());
        }
    }

    /**
     * Checks update field level security only (no CRUD) for the specified fields on {@code objectType}
     * @exception DCM_FlsException if the running user does not have update rights to the {@code fieldName} field.
     **/
    public static void checkFieldIsUpdateable(SObjectType objectType, String fieldName) {
        checkFieldIsUpdateable(objectType, SchemaDescriptions.getFieldsMap(objectType).get(fieldName));
    }

    /**
     * Identical to {@link #checkFieldIsUpdateable(SObjectType,String)}, except with SObjectField instead of String field reference.
     * @exception DCM_FlsException if the running user does not have update rights to the {@code fieldName} field.
     **/
    public static void checkFieldIsUpdateable(SObjectType objectType, SObjectField fieldToken) {
        checkFieldIsUpdateable(objectType, fieldToken.getDescribe());
    }

    /**
     * Identical to {@link #checkFieldIsUpdateable(SObjectType,String)}, except with DescribeFieldResult instead of String field reference.
     * @exception DCM_FlsException if the running user does not have update rights to the {@code fieldName} field.
     **/
    public static void checkFieldIsUpdateable(SObjectType objectType, DescribeFieldResult fieldDescribe) {
        if (BYPASS_INTERNAL_FLS_AND_CRUD)
            return;

        if (!fieldDescribe.isUpdateable()) {
            throw new DCM_FlsException(DCM_OperationType.MODIFY, objectType, fieldDescribe.getSObjectField());
        }
    }

    /**
     * Checks insert CRUD for the specified object type.
     * @exception DCM_CrudException if the running user does not have insert rights to the {@code objectType} SObject.
     **/
    public static void checkObjectIsInsertable(SObjectType objectType) {
        if (BYPASS_INTERNAL_FLS_AND_CRUD)
            return;

        if (!objectType.getDescribe().isCreateable()) {
            throw new DCM_CrudException(DCM_OperationType.CREATE, objectType);
        }
    }

    /**
     * Checks read CRUD for the specified object type.
     * @exception DCM_CrudException if the running user does not have read rights to the {@code objectType} SObject.
     **/
    public static void checkObjectIsReadable(SObjectType objectType) {
        if (BYPASS_INTERNAL_FLS_AND_CRUD)
            return;

        if (!objectType.getDescribe().isAccessible()) {
            throw new DCM_CrudException(DCM_OperationType.READ, objectType);
        }
    }

    /**
     * Checks update CRUD for the specified object type.
     * @exception DCM_CrudException if the running user does not have update rights to the {@code objectType} SObject.
     **/
    public static void checkObjectIsUpdateable(SObjectType objectType) {
        if (BYPASS_INTERNAL_FLS_AND_CRUD)
            return;

        if (!objectType.getDescribe().isUpdateable()) {
            throw new DCM_CrudException(DCM_OperationType.MODIFY, objectType);
        }
    }

    /**
     * Checks delete CRUD for the specified object type.
     * @exception DCM_CrudException if the running user does not have delete rights to the {@code objectType} SObject.
     **/
    public static void checkObjectIsDeletable(SObjectType objectType) {
        if (BYPASS_INTERNAL_FLS_AND_CRUD)
            return;

        if (!objectType.getDescribe().isDeletable()) {
            throw new DCM_CrudException(DCM_OperationType.DEL, objectType);
        }
    }
}
