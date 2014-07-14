-- { requirement
--local beautiful = require("beautiful")
local naughty = require("naughty")
local os = require("os")
local awful = require("awful")
local helpers =require("blingbling.helpers")
local string = require("string")
local superproperties = require('blingbling.superproperties')
---Differents popups for Awesome widgets
--@module blingbling.popups
-- }

-- { colorize
local function colorize(string, pattern, color)

    local mystring=""
    mystring=string.gsub(string,pattern,'<span color="'..color..'">%1</span>')
    return mystring
end
-- }

-- { processe
local processpopup = nil
local processstats = nil
local proc_offset = 25

local function hide_process_info()
    if processpopup ~= nil then
        naughty.destroy(processpopup)
        processpopup = nil
        proc_offset = 25
    end
end
local function show_process_info(inc_proc_offset, title_color,user_color, root_color, sort_order)
    local save_proc_offset = proc_offset
    hide_process_info()
    proc_offset = save_proc_offset + inc_proc_offset
    if sort_order == "cpu" then
        processstats = awful.util.pread('/usr/bin/ps --sort -c,-s -eo fname,user,%cpu,%mem,pid,gid,ppid,tname,priority | /usr/bin/head -n '..proc_offset)
    elseif sort_order == "mem" then
        processstats = awful.util.pread('/usr/bin/ps --sort -rss,-s -eo fname,user,%cpu,%mem,pid,gid,ppid,tname,priority | /usr/bin/head -n '..proc_offset)
    end

    processstats = colorize(processstats, "COMMAND", title_color)
    processstats = colorize(processstats, "USER", title_color)
    processstats = colorize(processstats, "%%CPU", title_color)
    processstats = colorize(processstats, "%%MEM", title_color)
    processstats = colorize(processstats, " PID", title_color)
    processstats = colorize(processstats, "GID", title_color)
    processstats = colorize(processstats, "PPID", title_color)
    processstats = colorize(processstats, "TTY", title_color)
    processstats = colorize(processstats, "LABEL", title_color)
    processstats = colorize(processstats, "PRI", title_color)
    processstats = colorize(processstats, "STAT", title_color)
    processstats = colorize(processstats, "root", root_color)
    processstats = colorize(processstats, "%d%d%.%d", root_color)
    processstats = colorize(processstats, os.getenv("USER"), user_color)
    processpopup = naughty.notify({
        text = processstats,
        timeout = 0, hover_timeout = 0.5,
    })
end
---Top popup.
--It binds a colorized output of the top command to a widget, and the possibility to launch htop with a click on the widget.
--</br>Example blingbling.popups.htop(mycairograph,{ title_color = "#rrggbbaa", user_color    = "#rrggbbaa", root_color="#rrggbbaa", terminal = "urxvt"})
--</br>The terminal parameter is not mandatory, htop will be launch in xterm. Mandatory arguments:
-- <ul> <li>title_color define the color of the title's columns.</li>
--  <li>user_color display the name of the current user with this color in the top output.</li>
--  <li>root_color display the root name with this color in the top output. </li></ul>
--@param mywidget the widget
--@param args a table of arguments { title_color = "#rrggbbaa", user_color = "#rrggbbaa", root_color="#rrggbbaa", terminal = a terminal name})
function htop(mywidget, args)
    local args = args or {}
    mywidget:connect_signal("mouse::enter", function()
        show_process_info(0,  args["title_color"] or superproperties.htop_title_color,
        args["user_color"] or superproperties.htop_user_color,
        args["root_color"] or superproperties.htop_root_color,
        args["sort_order"])
    end)
    mywidget:connect_signal("mouse::leave", function()
        hide_process_info()
    end)

    mywidget:buttons(awful.util.table.join(
    awful.button({ }, 4, function()
        show_process_info(-1,  args["title_color"] or superproperties.htop_title_color,
        args["user_color"] or superproperties.htop_user_color,
        args["root_color"] or superproperties.htop_root_color,
        args["sort_order"])
    end),
    awful.button({ }, 5, function()
        show_process_info(1, args["title_color"] or superproperties.htop_title_color,
        args["user_color"] or superproperties.htop_user_color,
        args["root_color"] or superproperties.htop_root_color,
        args["sort_order"])
    end),
    awful.button({ }, 1, function()
        if args["terminal"] then
            awful.util.spawn_with_shell(args["terminal"] .. " -e htop")
        else
            awful.util.spawn_with_shell("xterm" .. " -e htop")
        end
    end)
    ))
end
-- }

-- { netstat
local netpopup = nil
local function get_netinfo( my_title_color, my_established_color, my_listen_color)
    str=awful.util.pread('netstat -np | grep -v TIME_WAIT')
    str=colorize(str,"Proto", my_title_color)
    str=colorize(str,"PID/Program name", my_title_color)
    str=colorize(str,'Recv%XQ', my_title_color)
    str=colorize(str,"Send%XQ", my_title_color)
    str=colorize(str,"Local Address", my_title_color)
    str=colorize(str,"Foreign Address", my_title_color)
    str=colorize(str,"State", my_title_color)
    str=colorize(str,"Security Context", my_title_color)
    str=colorize(str,"RefCnt", my_title_color)
    str=colorize(str,"Flags", my_title_color)
    str=colorize(str,"Type", my_title_color)
    str=colorize(str,"I%XNode", my_title_color)
    str=colorize(str,"Path", my_title_color)
    str=colorize(str,"ESTABLISHED", my_established_color)
    str=colorize(str,"LISTEN", my_listen_color)
    str=colorize(str,"CONNECTED", my_listen_color)
    return str
end
local function hide_netinfo()
    if netpopup ~= nil then
        naughty.destroy(netpopup)
        netpopup = nil
    end
end
local function show_netinfo(c1,c2,c3)
    hide_netinfo()
    netpopup=naughty.notify({
        text = get_netinfo(c1,c2,c3),
        timeout = 0, hover_timeout = 0.5,
    })
end
---Netstat popup.
--It binds a colorized output of the netstat command to a widget.
--</br>Example: blingbling.popups.netstat(net,{ title_color = "#rrggbbaa", established_color= "#rrggbbaa", listen_color="#rrggbbaa"})
--</br>Mandatory arguments:
--<ul><li>widget (if blinbling widget add .widget ex: cpu.widget, if textbox or image box just put the widget name)</li>
--<li>title_color define the color of the title's columns.</li>
--<li>established_color display the state "ESTABLISHED" of a connexion  with this color in the netstat output.</li>
--<li>listen_color display the state "LISTEN" with this color in the netstat output.</li></ul>
--@param mywidget the widget
--@param args a table { title_color = "#rrggbbaa", established_color= "#rrggbbaa", listen_color="#rrggbbaa"}
function netstat(mywidget, args)
    local args = args or {}
    mywidget:connect_signal("mouse::enter", function()
        show_netinfo( args["title_color"] or superproperties.netstat_title_color,
        args["established_color"] or superproperties.netstat_established_color,
        args["listen_color"] or superproperties.netstat_listen_color)
    end)
    mywidget:connect_signal("mouse::leave", function()
        hide_netinfo()
    end)
end
-- }

-- { temperature
local temppopup = nil
local function get_tempinfo( cpu_color, safe_color, high_color, crit_color)
    str=awful.util.pread("/home/farseer/bin/gpu_temp && sensors |grep Core|awk -F '(' '{print $1}'")
    str=colorize(str,"Core %x", cpu_color)
    str=colorize(str,"Gpu", cpu_color)
    str=colorize(str,"high", high_color)
    str=colorize(str,"crit", crit_color)
    str=colorize(str,"off", crit_color)
    str=colorize(str,"+[0-5]%d.%d°C", safe_color)
    str=colorize(str,"+[6-7]%d.%d°C", high_color)
    str=colorize(str,"+[8-9]%d.%d°C", crit_color)
    return str
end

local function hide_tempinfo()
    if temppopup ~= nil then
        naughty.destroy(temppopup)
        temppopup = nil
    end
end
local function show_tempinfo(c1,c2,c3,c4)
    hide_tempinfo()
    temppopup=naughty.notify({
        text = get_tempinfo(c1,c2,c3,c4),
        timeout = 0, hover_timeout = 0.5,
    })
end

function cpusensors(mywidget, args)
    mywidget:connect_signal("mouse::enter", function()
        show_tempinfo( args["cpu_color"], args["safe_color"], args["high_color"], args["crit_color"])
    end)
    mywidget:connect_signal("mouse::leave", function()
        hide_tempinfo()
    end)
end

-- }

-- { file system
local fspopup = nil
local function get_fsinfo( title_color, total_color, percentage_color, tmp_color)
    str=awful.util.pread("/usr/bin/df -h")
    str=colorize(str,"Filesystem", title_color)
    str=colorize(str,"Size", title_color)
    str=colorize(str,"Used", title_color)
    str=colorize(str,"Avail", title_color)
    str=colorize(str,"Use%%", title_color)
    str=colorize(str,"Mounted on", title_color)
    str=colorize(str,"%d*%%", percentage_color)
    str=colorize(str,"[0-9.]*G", total_color)
    str=colorize(str,"tmpfs", tmp_color)
    return str
end

local function hide_fsinfo()
    if fspopup ~= nil then
        naughty.destroy(fspopup)
        fspopup = nil
    end
end
local function show_fsinfo(c1,c2,c3,c4)
    hide_fsinfo()
    fspopup=naughty.notify({
        text = get_fsinfo(c1,c2,c3,c4),
        timeout = 0, hover_timeout = 0.5,
    })
end

function fstat(mywidget, args)
    mywidget:connect_signal("mouse::enter", function()
        show_fsinfo( args["title_color"], args["total_color"], args["percentage_color"], args["tmp_color"])
    end)
    mywidget:connect_signal("mouse::leave", function()
        hide_fsinfo()
    end)
end

-- }


-- { Ip address
local ipopup = nil
local function get_ip( title_color, ip_color )
    str=awful.util.pread("/home/farseer/bin/show_ip")
    str=colorize(str,"LAN:", title_color)
    str=colorize(str,"EXTERNAL:", title_color)
    str=colorize(str,"[0-9.]%+", ip_color)
    return str
end

local function hide_ip()
    if ipopup ~= nil then
        naughty.destroy(ipopup)
        ipopup = nil
    end
end
local function show_ip(c1,c2)
    hide_ip()
    ipopup=naughty.notify({
        text = get_ip(c1,c2),
        timeout = 0, hover_timeout = 0.5,
    })
end

function ipstat(mywidget, args)
    mywidget:connect_signal("mouse::enter", function()
        show_ip( args["title_color"], args["ip_color"] )
    end)
    mywidget:connect_signal("mouse::leave", function()
        hide_ip()
    end)
end

-- }

-- { cpu frequency
local cpufreq = nil
local function get_cpufreq( title_color, high_color ,low_color)
    str=awful.util.pread("cat /proc/cpuinfo | grep MHz")
    str=colorize(str, "cpu MHz", title_color)
    str=colorize(str, "[1-2]%d%d%d.%d%d%d", low_color)
    str=colorize(str, "[8-9]%d%d.%d%d%d", low_color)
    str=colorize(str, "3%d%d%d.%d%d%d", high_color)
    return str
end

local function hide_cpufreq()
    if cfpopup ~= nil then
        naughty.destroy(cfpopup)
        cfpopup = nil
    end
end
local function show_cpufreq(c1,c2,c3)
    hide_ip()
    cfpopup=naughty.notify({
        text = get_cpufreq(c1,c2,c3),
        timeout = 0, hover_timeout = 0.5,
    })
end

function cpufreq(mywidget, args)
    mywidget:connect_signal("mouse::enter", function()
        show_cpufreq( args["title_color"], args["high_color"] ,args["low_color"])
    end)
    mywidget:connect_signal("mouse::leave", function()
        hide_cpufreq()
    end)
end

-- }

return {
    htop = htop ,
    netstat = netstat,
    cpusensors = cpusensors,
    cpufreq = cpufreq,
    fstat = fstat,
    ipstat = ipstat
}
-- vim:ts=4:sw=4:tw=0:ft=lua:fdm=marker:fdl=5
