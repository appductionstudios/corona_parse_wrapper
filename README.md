# Wrapper for Corona Parse plugin

The Corona parse plugin created by [develephant](https://github.com/develephant) does not work properly with parse-server. The older [mod_parse module](https://github.com/develephant/mod_parse) works, though.

Using this wrapper you can roll back to mod_parse without having to change your Corona code.

All you need to do is copy the parse_wrapper and the mod_parse modules into your Corona project and do:

```lua
local parse = require("parse_wrapper")
parse.config:applicationId("myApplicationId")
parse.config:cloudAddress("https://example.com/parse/")
```
