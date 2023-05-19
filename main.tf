resource "genesyscloud_integration_action" "action" {
    name           = var.action_name
    category       = var.action_category
    integration_id = var.integration_id
    secure         = var.secure_data_action
    
    contract_input  = jsonencode({
        "additionalProperties" = true,
        "properties" = {
            "ANI" = {
                "type" = "string"
            },
            "Interval" = {
                "description" = "UTC, example: 2020-07-10T05:00:00.000Z/2020-07-11T05:00:00.000Z",
                "type" = "string"
            }
        },
        "type" = "object"
    })
    contract_output = jsonencode({
        "additionalProperties" = true,
        "properties" = {
            "Count" = {
                "type" = "integer"
            }
        },
        "type" = "object"
    })
    
    config_request {
        request_template     = "{\n \"interval\": \"$${input.Interval}\",\n \"order\": \"asc\",\n \"orderBy\": \"conversationStart\",\n \"paging\": {\n  \"pageSize\": 25,\n  \"pageNumber\": 1\n },\n \"segmentFilters\": [\n  {\n   \"type\": \"and\",\n   \"predicates\": [\n    {\n     \"type\": \"dimension\",\n     \"dimension\": \"ani\",\n     \"operator\": \"matches\",\n     \"value\": \"$${input.ANI}\"\n    }\n   ]\n  }\n ],\n \"conversationFilters\": [\n  {\n   \"type\": \"and\",\n   \"predicates\": [\n    {\n     \"type\": \"dimension\",\n     \"dimension\": \"conversationEnd\",\n     \"operator\": \"exists\",\n     \"value\": null\n    }\n   ]\n  }\n ]\n}"
        request_type         = "POST"
        request_url_template = "/api/v2/analytics/conversations/details/query"
        
    }

    config_response {
        success_template = "{ \"Count\": $${count} }"
        translation_map = { 
			count = "$.conversations.size()"
		}
        translation_map_defaults = {       
			count = "0"
		}
    }
}