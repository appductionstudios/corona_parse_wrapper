-------------------------------------------------------------------------------
--
-- parse_wrapper.lua
--
-- How To Use
-- 
-- parse = require("parse_wrapper")
-- parse.config:applicationId("myApplicationId")
-- parse.config:cloudAddress("https://example.com/parse/")
--
-------------------------------------------------------------------------------


local mod_parse = require("mod_parse")

local Parse = {
    config = {},
    Object = {
        query = {func = "object_query"}
    },
    Cloud = {
        call = {func = "cloud_call"}
    },
    Session = {
        logout = {func = "session_logout"}
    },
    User = {
        create = {func = "user_create"},
        login = {func = "user_login"},
        me = {func = "user_me"},
        requestPasswordReset = {func = "user_requestpasswordreset"}
    }
}

function logoutUser(callback)
    uri = mod_parse:getEndpoint("logout")

    function cb(event)
        if not event.error then mod_parse:clearSessionToken() end

        callback(event)
    end

    return mod_parse:sendRequest(uri, {}, "logout", mod_parse.POST, cb)
end

function Parse.config:applicationId(app_id)
    mod_parse.appId = app_id
end

function Parse.config:cloudAddress(cloud_address)
    mod_parse.endpoint = cloud_address
end

function Parse.config:sessionToken(session_token)
    mod_parse:setSessionToken(session_token)
end

function Parse:request(cls)
    self.params_table = {}

    self.data = function(req, data_table)
        -- Handling special case of cloud call with no params.
        if data_table == "{}" then data_table = nil end

        self.params_table = data_table
        return self
    end

    self.where = function(req, where_table)
        self.params_table["where"] = where_table
        return self
    end

    self.options = function(req, options_table)
        for k, v in pairs(options_table) do
            -- Ignore keys for now.
            if k ~= "keys" then
                self.params_table[k] = v
            end
        end

        return self
    end

    self.set = function(req, key, val)
        self.params_table[key] = val
        return self
    end

    self.response = function(req, callback)
        function cb(event)
            if event.networkError == true then
                callback(false, nil, nil)
            else
                local res = event.response

                -- Handling error case.
                if event.error then res = event end

                callback(true, res, {})
            end
        end

        if self.func == "object_query" then mod_parse:getObjects(cls, self.params_table, cb)
        elseif self.func == "cloud_call" then mod_parse:run(cls, self.params_table, cb)
        elseif self.func == "session_logout" then logoutUser(cb)
        elseif self.func == "user_create" then mod_parse:createUser(self.params_table, cb)
        elseif self.func == "user_login" then mod_parse:loginUser(self.params_table, cb)
        elseif self.func == "user_me" then mod_parse:getMe(cb)
        elseif self.func == "user_requestpasswordreset" then mod_parse:requestPassword(self.params_table["email"], cb)
        end

        return self
    end

    return self
end

return Parse
