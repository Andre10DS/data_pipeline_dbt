{% macro generate_schema_name(custom_schema_name, node) -%}
    {% if node.resource_type == 'seed' and custom_schema_name is not none %}
        {{ custom_schema_name }}
    {% elif custom_schema_name is not none %}
        {{ target.schema }}
    {% else %}
        {{ target.schema }}
    {% endif %}
{%- endmacro %}