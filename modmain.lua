Assets = {
    Asset("ANIM", "anim/player_hug.zip"),
}

modimport("main/strings")

local AddAction = AddAction
local AddComponentAction = AddComponentAction
local AddStategraphState = AddStategraphState
local AddPlayerPostInit = AddPlayerPostInit
local AddStategraphActionHandler = AddStategraphActionHandler
GLOBAL.setfenv(1, GLOBAL)

AddPlayerPostInit(function(inst)
    if not TheWorld.ismastersim then
        return
    end

    local _getstatus = inst.components.inspectable.getstatus
    inst.components.inspectable.getstatus = function(inst, ...)
        if inst.sg ~= nil and inst.sg:HasStateTag("huging") then
            return "HUGGER"
        end
        return _getstatus(inst, ...)
    end
end)

local HUG = Action({ distance = 2, }) -- instant = true, mount_valid = true
HUG.id = "HUG"
HUG.fn = function(act)
    if act.doer and act.target then
        -- act.doer.sg:GoToState("hug", act.target)
        act.target.sg:GoToState("response_hug", act.doer)
    end
    return true
end
HUG.str = STRINGS.ACTIONS.HUG
AddAction(HUG)

AddComponentAction("SCENE", "locomotor", function(inst, doer, actions, right)
    if inst:HasTag("player") and not inst:HasTag("playerghost") and not (doer == inst) and not (inst.replica.rider:IsRiding() or doer.replica.rider:IsRiding()) then
        table.insert(actions, ACTIONS.HUG)
    end
end)

AddStategraphActionHandler("wilson", ActionHandler(ACTIONS.HUG, "hug"))
AddStategraphActionHandler("wilson_client", ActionHandler(ACTIONS.HUG, "hug"))

local function hug_onenter_common(inst, target)
    if target == nil or not target.sg:HasStateTag("huging") then
        inst.sg:GoToState("idle")
    end

    inst.DynamicShadow:Enable(false)
    inst.Transform:SetNoFaced()

    inst.sg.statemem.target = target
    RemovePhysicsColliders(inst)
    inst.components.locomotor:Stop()
    inst.AnimState:AddOverrideBuild("player_hug")
    inst.AnimState:PlayAnimation("player_hug_pre", false)
    inst.AnimState:PushAnimation("player_hug_loop", true)
end

local hug_events = {
    EventHandler("animover", function(inst)
        if inst.AnimState:AnimDone() then
            if inst.AnimState:IsCurrentAnimation("player_hug_loop") then
                inst.sg:RemoveStateTag("busy")
                inst.sg:RemoveStateTag("nopredict")
                inst.sg:RemoveStateTag("nomorph")
                inst.sg:RemoveStateTag("invisible")
                inst.sg:AddStateTag("idle")
            end
        end
    end),
}

local hug_onupdate = function(inst)
    local target = inst.sg.statemem.target
    if target ~= nil and not target.sg:HasStateTag("huging") then
        target.sg:RemoveStateTag("huging")
        target.AnimState:PlayAnimation("player_hug_pst", false)
        target.sg:GoToState("idle", true)

        if inst.components.temperature ~= nil and target.components.temperature ~= nil then
            inst.components.temperature:SetModifier("hug", target.temperature.current - inst.components.temperature.current)
        end
    end
end

local hug_onexit = function(inst)
    inst.DynamicShadow:Enable(true)
    inst.AnimState:SetScale(1, 1, 1)
    inst.Transform:SetFourFaced()
    MakeCharacterPhysics(inst, 75, .5)
    inst.components.locomotor:Stop()
    inst.AnimState:ClearOverrideBuild("player_hug")

    if inst.components.temperature ~= nil then
        inst.components.temperature:RemoveModifier("hug")
    end

    local target = inst.sg.statemem.target
    if target ~= nil and target.sg:HasStateTag("huging") then
        target.sg:RemoveStateTag("huging")
        target.AnimState:PlayAnimation("player_hug_pst", false)
        target.sg:GoToState("idle", true)
    end
end

local states = {
    State{
        name = "hug",
        tags = { "doing", "busy", "nomorph", "nopredict", "notalking", "huging", "invisible" },

        onenter = function(inst)
            local buffered_action = inst:GetBufferedAction()
            inst:PerformBufferedAction()
            hug_onenter_common(inst, buffered_action and buffered_action.target or nil)
        end,
        events = hug_events,
        onupdate = hug_onupdate,
        onexit = hug_onexit,
    },
    State{
        name = "response_hug",
        tags = { "doing", "busy", "nomorph", "nopredict", "notalking", "huging", "invisible" },

        onenter = function(inst, target)
            inst.AnimState:SetScale(-1, 1, 1)
            hug_onenter_common(inst, target)
            local x, y, z = inst.Transform:GetWorldPosition()
            local other_x, other_y, other_z = target.Transform:GetWorldPosition()
            inst.Transform:SetPosition(x, 0, z)
            target.Transform:SetPosition(x, 0, z)
        end,
        events = hug_events,
        onupdate = hug_onupdate,
        onexit = hug_onexit,
    }
}

for _, state in ipairs(states) do
    AddStategraphState("wilson", state)
end

AddStategraphState("wilson_client", State{
    name = "hug",
    server_states = { "hug" },
    forward_server_states = true,
    tags = { "notalking", "huging" },
    onenter = function(inst) inst.sg:GoToState("action_uniqueitem_busy") end,
})
