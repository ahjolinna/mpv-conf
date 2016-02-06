local utils = require 'mp.utils'


-- Select the options level appropriate for this computer
function determine_level(o, vo, vo_opts, options)
    -- Default level
    local level = o.hq

    -- Overwrite level from command line with --script-opts=ao-level=<level>
    local overwrite = mp.get_opt("ao-level")
    if overwrite then
        if not (vo[overwrite] and vo_opts[overwrite] and options[overwrite]) then
            print("Forced level does not exist: " .. overwrite)
            return level
        end
        return overwrite
    end

 --Call an function determining whether you are using battery or not if so...
    -- Go down to lq when we are on battery
      sp_ret = exec({"/usr/bin/acpitool", "-b", "| grep AC adapter",})
        if sp_ret == "<not available>.\n" then
        level = o.lq
    end
    return level
end


-- Use tables `vo` and `vo_opts` to build a `vo=key1=val1:key2=val2` string
function vo_property_string(level, vo, vo_opts)
    local result = {}
    for k, v in pairs(vo_opts[level]) do
        if type(v) == "function" then
            v = v()
        end
        if v and v ~= "" then
            table.insert(result, k .. "=" ..v)
        else
            table.insert(result, k)
        end
    end
    return vo[level] .. (next(result) == nil and "" or (":" .. table.concat(result, ":")))
end


 --Determine if the currently used resolution/DPI is higher than o.highres_threshold
function is_high_res(o)
    sp_ret = exec({"/usr/bin/inxi", "-xSGI", "| grep Resolution", "compare", o.highres_threshold})
    return not sp_ret.error and sp_ret.status > 2
end


function exec(process)
    p_ret = utils.subprocess({args = process})
    if p_ret.error and p_ret.error == "init" then
        print("ERROR executable not found: " .. process[1])
    end
    return p_ret
end


function set_ASS(b)
    return mp.get_property_osd("osd-ass-cc/" .. (b and "0" or "1"))
end


function red_border(s)
    return set_ASS(true) .. "{\\bord1}{\\3c&H3300FF&}{\\3a&H20&}" .. s .. "{\\r}" .. set_ASS(false)
end


function print_status(name, value, o)
    if not value or not o.level then
        return
    end

    if o.err_occ then
        print("Error setting level: " .. o.level)
        mp.osd_message(red_border("Error setting level: ") .. o.level, o.duration * o.duration_err_mult)
    else
        print("Active level: " .. o.level)
        mp.osd_message("Level: " .. o.level .. (is_high_res(o) and " HIGH RES" or ""), o.duration)
    end
    mp.unobserve_property(print_status)
end
