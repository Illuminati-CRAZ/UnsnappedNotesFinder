local function not_has(table, val)
    for _, value in pairs(table) do
        if value == val then
            return false
        end
    end

    return true
end

function draw()
    imgui.Begin("Unsnapped Notes Finder")

    state.IsWindowHovered = imgui.IsWindowHovered()

    local n1 = state.GetValue("n1") or 12
    local n2 = state.GetValue("n2") or 16
    local leniency = state.GetValue("leniency") or 0

    if n1 < 1 then n1 = 1 end
    if n2 < 1 then n2 = 1 end
    if leniency < 0 then leniency = 0 end

    local errorstring = state.GetValue("errorstring") or ""

    local errors = state.GetValue("errors") or {}

    local currentobject = state.GetValue("currentobject") or 0

    local showcopytext = state.GetValue("showcopytext") or false

    --local debug = state.GetValue("debug") or "hi"

    _, n1 = imgui.InputInt("1/n Snap", n1)
    _, n2 = imgui.InputInt("1/n Snap ", n2)

    _, leniency = imgui.InputInt("Lenience", leniency)

    if imgui.Button("Search") then
        local tps = map.TimingPoints
        local notes = map.HitObjects

        errors = {}

        local i = 1
        for _, tp in pairs(tps) do
            local starttime = tp.StartTime
            local length = map.GetTimingPointLength(tp)
            local endtime = starttime + length
            local bpm = tp.Bpm
            local mspb = 60000/bpm

            local mspcheck1 = mspb / n1
            local mspcheck2 = mspb / n2

            local checktime1 = starttime
            local checktime2 = starttime

            while endtime > notes[i].StartTime do
                while checktime1 < notes[i].StartTime do
                    checktime1 = checktime1 + mspcheck1
                end
                while checktime2 < notes[i].StartTime do
                    checktime2 = checktime2 + mspcheck2
                end

                debug = endtime

                deviance1 = notes[i].StartTime - math.floor(checktime1)
                deviance2 = notes[i].StartTime - math.floor(checktime2)

                if not ((math.abs(deviance1) <= leniency) or (math.abs(mspcheck1 - deviance1) <= leniency) or (math.abs(deviance2) <= leniency) or (math.abs(mspcheck2 - deviance2) <= leniency)) then
                    table.insert(errors, notes[i])
                end

                if i < #notes then
                    i = i + 1
                else
                    break
                end
            end
        end

        currentobject = 0
        errorstring = ""

        for _,note in pairs(errors) do
            errorstring = errorstring .. note.StartTime .. "|" .. note.Lane .. ", "
        end
        errorstring = errorstring:sub(1,-3)

        if errorstring == "" then
            errorstring = "No unsnapped notes detected."
        end

        showcopytext = false
    end

    imgui.SameLine(0, 4)
    if imgui.Button("Detect 1 ms Differences Between Notes") then
        local notes = map.HitObjects
        errors = {}
        for i = 2, #notes do
            if notes[i].StartTime - notes[i-1].StartTime == 1 then
                table.insert(errors, notes[i-1])
            end
        end

        currentobject = 0
        errorstring = ""

        for _,note in pairs(errors) do
            errorstring = errorstring .. note.StartTime .. "|" .. note.Lane .. ", "
        end
        errorstring = errorstring:sub(1,-3)

        if errorstring == "" then
            errorstring = "No 1 ms differences detected."
        end

        showcopytext = false
    end

    if errors[1] then
        imgui.Text("")
        --imgui.Columns(3)
        if imgui.Button("Go to Previous Object") then
            if currentobject > 1 then
                currentobject = currentobject - 1
            else
                currentobject = #errors
            end
            actions.GoToObjects(errors[currentobject].StartTime .. "|" .. errors[currentobject].Lane)
            showcopytext = false
        end


        imgui.SameLine(0, 4)
        --imgui.separator()
        --imgui.NextColumn()
        if imgui.Button("Go to Next Object") then
            if currentobject < #errors then
                currentobject = currentobject + 1
            else
                currentobject = 1
            end
            actions.GoToObjects(errors[currentobject].StartTime .. "|" .. errors[currentobject].Lane)
            showcopytext = false
        end

        imgui.SameLine(0, 4)
        --imgui.NextColumn()
        if imgui.Button("Copy to Clipboard") then
            imgui.SetClipboardText(errorstring)
            showcopytext = true
        end

        --imgui.Columns(1)

        imgui.TextWrapped(currentobject .. "/" .. #errors)
        if showcopytext then
            imgui.SameLine(0,4)
            imgui.TextWrapped("Copied!")
        end
    end

    imgui.TextWrapped(errorstring)

    --imgui.TextWrapped(debug)

    state.SetValue("n1", n1)
    state.SetValue("n2", n2)
    state.SetValue("leniency", leniency)

    state.SetValue("errorstring", errorstring)
    state.SetValue("errors", errors)

    state.SetValue("currentobject", currentobject)

    state.SetValue("showcopytext", showcopytext)

    --state.SetValue("debug", debug)

    imgui.End()
end
