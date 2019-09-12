local typedefs = require "kong.db.schema.typedefs"

return {
  name = "myplugin",
  fields = {
    -- Describe your plugin's configuration's schema here.
    { consumer = typedefs.no_consumer },
    { run_on = typedefs.run_on_first },
    { protocols = typedefs.protocols_http },
    { config = {
        type = "record",
        fields = {
          { header_key = {
              type = "string",
              required = true,
              default = "Bye-World",
          }, },
          { say_words = { type = "string", required = true, default = "this is on the response" }, },
          { redis_hosts = { type = "string", required = true }, },
          { redis_password = { type = "string", len_min = 0 }, },
          { redis_timeout = { type = "number", default = 2000 }, },
          { redis_database = { type = "integer", default = 0 }, },
        },
      }, 
    },
    
  },
  entity_checks = {
    -- Describe your plugin's entity validation rules
    
  },
}
