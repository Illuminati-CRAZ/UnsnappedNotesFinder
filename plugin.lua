function draw()
    imgui.Begin("Unsnapped Notes Finder")
    state.IsWindowHovered = imgui.IsWindowHovered()

    local vars = {
        snaps = "16, 12",
        leniency = 1,
        deltaInfo = {},
        selectedOnly = false
    }

    getVars(vars)
    _, vars.snaps = imgui.InputText("Snaps", vars.snaps, 50)
    vars.snaps = restrictSnapString(vars.snaps)
    _, vars.leniency = imgui.InputInt("Leniency", vars.leniency)
    vars.leniency = math.max(vars.leniency, 0) -- no negative numbers
    _, vars.selectedOnly = imgui.Checkbox("Use selected notes only",
                                          vars.selectedOnly)

    if imgui.Button("Find") then
        local snaps = {}
        for snap in string.gmatch(vars.snaps, "%d+") do
            table.insert(snaps, tonumber(snap))
        end
        local notes = vars.selectedOnly and state.SelectedHitObjects or
                          map.HitObjects
        vars.deltaInfo = findAllDeltas(snaps, notes, vars.leniency)
    end

    if #vars.deltaInfo == 0 then
        imgui.Text("No notes to resnap")
    else
        imgui.Text(#vars.deltaInfo .. " unsnapped notes found!")
        printTable(vars.deltaInfo)
    end

    saveVars(vars)
    imgui.End()
end

function restrictSnapString(s)
    local patterns = {
        {"[^0123456789,]"}, -- only allow digits and commas
        {",,+", ","}, -- remove duplicate commas
        {"^,"}, -- remove commas at beginning
        {",$"} -- remove commas at end
    }
    for _, pattern in pairs(patterns) do
        s = string.gsub(s, pattern[1], pattern[2] or "")
    end
    return s
end

function diffToClosestSnap(time, snaps)
    local timingPoint = map.GetTimingPointAt(time)
    local msPerSnaps = {}
    for _, snap in pairs(snaps) do
        table.insert(msPerSnaps, 60000 / timingPoint.Bpm / snap)
    end

    local smallestDelta = 10e6
    for _, msPerSnap in pairs(msPerSnaps) do
        local deltaForward = (time - timingPoint.StartTime) % msPerSnap
        local deltaBackward = deltaForward - msPerSnap
        local delta = deltaForward < -deltaBackward and deltaForward or
                          deltaBackward

        if math.abs(delta) < math.abs(smallestDelta) then
            smallestDelta = delta;
        end
    end

    return smallestDelta
end

function findAllDeltas(snaps, notes, leniency)
    local deltaInfo = {}
    for _, note in pairs(notes) do
        local startTimeDelta = diffToClosestSnap(note.StartTime, snaps)
        local endTimeDelta = note.EndTime > 0 and
                                 diffToClosestSnap(note.EndTime, snaps) or 0
        if math.abs(startTimeDelta) >= leniency or math.abs(endTimeDelta) >=
            leniency then
            table.insert(deltaInfo, {
                note = note,
                startTimeDelta = startTimeDelta,
                endTimeDelta = endTimeDelta
            })
        end
    end
    return deltaInfo
end

function printTable(deltaInfo)
    imgui.Columns(3)
    imgui.Text("Note")
    imgui.NextColumn()
    imgui.Text("StartTime Delta")
    imgui.NextColumn()
    imgui.Text("EndTime Delta")
    imgui.NextColumn()
    imgui.Separator()
    for _, info in pairs(deltaInfo) do
        local noteString = info.note.StartTime .. "|" .. info.note.Lane
        if imgui.Button(noteString) then actions.GoToObjects(noteString) end
        imgui.NextColumn()
        imgui.Text(info.startTimeDelta == 0 and "" or
                       string.format("%.2f", info.startTimeDelta))
        imgui.NextColumn()
        imgui.Text(info.endTimeDelta == 0 and "" or
                       string.format("%.2f", info.endTimeDelta))
        imgui.NextColumn()
    end
    imgui.Separator()
    imgui.Columns(1)
end

function getVars(vars)
    for key in pairs(vars) do vars[key] = state.GetValue(key) or vars[key] end
end

function saveVars(vars)
    for key in pairs(vars) do state.SetValue(key, vars[key]) end
end
