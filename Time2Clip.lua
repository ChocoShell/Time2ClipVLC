--[[
INSTALLATION:
Put the file in the VLC subdir /lua/extensions, by default:
 Windows (all users): %ProgramFiles%\VideoLAN\VLC\lua\extensions\
Restart the VLC.
Then you simply use the extension by going to the "View" menu and selecting it.
--]]


function descriptor()
 --None of this descriptor info was done by me (ChocoShell). I'll put this info in an old metadata description to preserve the previous maintainer.
    return {
        title = "Time2Clip";
        version = "1.0";
        author = "valuex";
        url = 'http://addons.videolan.org/content/show.php?content=149618';
        shortdesc = "Time2Clip";
        description = "<div style=\"background-color:lightgreen;\"><b>just a simple VLC extension </b></div>";
        capabilities = {"input-listener"}
    }
end
function activate()
    input_callback("add") 
    create_dialog()
end
function deactivate()
    input_callback("del")
end
function close()
    vlc.deactivate()
end
function input_changed()
    input_callback("toggle")
end

callback=false
function input_callback(action)  -- action=add/del/toggle
    if (action=="toggle" and callback==false) then action="add"
    elseif (action=="toggle" and callback==true) then action="del" end

    local input = vlc.object.input()
    if input and callback==false and action=="add" then
        callback=true
        vlc.var.add_callback(input, "intf-event", input_events_handler, "Hello world!")
    elseif input and callback==true and action=="del" then
        callback=false
        vlc.var.del_callback(input, "intf-event", input_events_handler, "Hello world!")
    end
end

function input_events_handler(var, old, new, data)

end

function create_dialog()
    w = vlc.dialog("Time2Clip")
    w1 = w:add_label("<b>Current Time:</b>",1,1,1,1)
    w2 = w:add_text_input("0",2,1,1,1)  
    w1a = w:add_label("<b>Current Time Stamp:</b>",1,2,1,1)
    w2a = w:add_text_input("0",2,2,1,1)  
    w3 = w:add_button("jumpto", click_SEEK,1,3,1,1)
    w4 = w:add_button("Save to Clip", click_SAVE,2,3,1,1)
    w5 = w:add_button("Update Timestamp", click_UPDATE,1,4,1,1)
    update_timestamp()
end

function click_UPDATE()
    update_timestamp()
end

function update_timestamp()
    local input = vlc.object.input()
    if input then
        local curtime=vlc.var.get(input, "time")   --in microseconds
        local formatted_curtime = microseconds_to_timestamp(curtime)
        w2:set_text( curtime )
        w2a:set_text( formatted_curtime )
    end
    return formatted_curtime
end

function click_SAVE()
    update_timestamp()
    save_to_clipboard(w2a:get_text(formatted_curtime))
end

function click_SEEK()
    local time_togo = w2:get_text()
    local input = vlc.object.input()
    if input then
        vlc.var.set(input, "time", time_togo)   --jump to specified time
    end
end

function save_to_clipboard(var)
    strCmd = 'echo '..var..' |clip'
    os.execute(strCmd)
end

function microseconds_to_timestamp(total_microseconds)
    local total_seconds = floor_divide(total_microseconds, 1000000)
    local seconds = total_seconds % 60

    local total_minutes = floor_divide(total_seconds, 60)
    local minutes = total_minutes % 60

    local total_hours = floor_divide(total_minutes, 60)
    local hours = total_hours % 24

    return string.format("%02d:%02d:%02d", hours, minutes, seconds)
end

function floor_divide(numerator, denominator)
    return math.floor(numerator / denominator)
end
