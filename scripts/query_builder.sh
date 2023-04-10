#!/bin/sh

# Function to build the SOQL query
build_soql_query() {
    select_fields_name="$1"
    select_object_name="$2"
    where_conditions_name="$3"

    soql_query="SELECT "

    select_fields_length="$(eval "echo \${#${select_fields_name}[@]}")"
    for i in $(seq 0 $(($select_fields_length - 1))); do
        field_value="$(eval "echo \${${select_fields_name}[$i]}")"
        soql_query="$soql_query$field_value"
        if [ $i -lt $(($select_fields_length - 1)) ]; then
            soql_query="$soql_query, "
        fi
    done

    soql_query="$soql_query FROM $select_object_name"

    where_conditions_length="$(eval "echo \${#${where_conditions_name}[@]}")"
    if [ $where_conditions_length -gt 0 ]; then
        soql_query="$soql_query WHERE "
        for i in $(seq 0 $(($where_conditions_length - 1))); do
            condition_value="$(eval "echo \${${where_conditions_name}[$i]}")"
            soql_query="$soql_query$condition_value"
            if [ $i -lt $(($where_conditions_length - 1)) ]; then
                soql_query="$soql_query "
            fi
        done
    fi

    echo "$soql_query"
}

# SELECT array
select_fields=("Field1" "Field2" "Field3")

# WHERE array (supports AND, OR, NOT logical operators, and NOT IN subquery)
where_conditions=("Field1 = 'value1'" "AND" "Field2 = 'value2'" "OR" "NOT Field3 = 'value3'" "AND" "Field4 NOT IN (SELECT Id FROM SubObject WHERE FieldX = 'valueX')")

# Build the SOQL query
soql_query=$(build_soql_query "select_fields" "Opportunity" "where_conditions")

# Print the SOQL query
echo "Generated SOQL query:"
echo "$soql_query"

# Execute the query using sfdx CLI (Salesforce CLI) if needed
# sfdx force:data:soql:query --query "$soql_query" --targetusername your_target_username
