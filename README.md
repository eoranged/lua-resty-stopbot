# lua-resty-stopbot

Simple bot protection framework.

# Status

Project is in early development stage and It is expected to be API breakage and lots of bugs.

# Features

* Flexible rate limiting
* Request precondition validation (user made a request to /api/xxx.html before calling /api/yyy)
* TODO cookie/captcha/redirect/timeout validation

# API

* [init_storage](#init_storage)
* [init_zone](#init_zone)
* [access_zone](#access_zone)

## Synopsis

```` lua
lua_package_path "/path/to/lua-resty-stopbot/lib/?.lua;/path/to/lua-resty-stopbot/lib/?/init.lua;;";

lua_shared_dict test 10m;

init_by_lua_block {
    stopbot = require "resty.stopbot"  -- global
    stopbot.init_storage ("default", "resty.stopbot.storage.shared_dict", {
        name = "test"
    })
    stopbot.init_zone("frontpage", {
        access_expires = 300,
    })
    stopbot.init_zone("login", {
        access_limit = 10,
        access_expires = 300,
        only_after = {"frontpage"},
    })
}

server {
    location =/ {
        access_by_lua_block {
            stopbot.access_zone("frontpage")
        }
    }

    location =/login.php {
        access_by_lua_block {
            stopbot.access_zone("login")
        }

        fastcgi_pass ...;
    }

}

````

# Initialization

## init_storage

## init_zone

## access_zone

# Author

Valdimir Protasov (eoranged@eoranged.com)

# License

MIT License
