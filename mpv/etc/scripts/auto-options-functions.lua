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
 sp_ret =  exec({"/usr/bin/acpi", "-b",})
if sp_ret ~="on-line" then
    level = o.hq
else
level = o.lq
  end
  return level
end

function set_property(property, value, o)
  if type(value) == "function" then
    value = value()
  end
  success, err = mp.set_property(property, value)
  o.err_occ = o.err_occ or not (o.err_occ or success)
  if success and o.verbose then
    print("Set '" .. property .. "' to '" .. value .. "'")
  elseif o.verbose then
    print("Failed to set '" .. property .. "' to '" .. value .. "'")
    print(err)
  end
end

--Determine if the currently used resolution/DPI is higher than o.highres_threshold
function is_high_res(o)
  if o.force_low_res then
    return false
  end
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
