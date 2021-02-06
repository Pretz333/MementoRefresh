MementoRefresh = MementoRefresh or {
	name = "MementoRefresh",
  author = "@Pretz333 (NA)",
  version = "0.0.4",
  variableVersion = 2,
  defaults = {
    mementoId = nil,
    abilityId = nil,
    delay = 0,
  },
}

MementoRefresh.mementos = {
  -- ["storm"] = {mementoId = 596, abilityId = 0, memento = "Storm Atronach Transform"},
  -- ["stormaura"] = {mementoId = 594, abilityId = 0, memento = "Storm Atronach Aura"},
  ["wildhunt"] = {mementoId = 759, abilityId = 86977, memento = "Wild Hunt Transform", delay = 0},
  ["floral"] = {mementoId = 758, abilityId = 86978, memento = "Floral Swirl Aura", delay = 0},
  ["leaf"] = {mementoId = 760, abilityId = 86976, memento = "Wild Hunt Leaf-Dance Aura", delay = 0},
  ["lantern"] = {mementoId = 341, abilityId = 26829, memento = "Almalexia's Enchanted Lantern", delay = 1500},
  ["crows"] = {mementoId = 1384, abilityId = 97274, memento = "Swarm of Crows", delay = 0},
  ["dwemer"] = {mementoId = 1183, abilityId = 92868, memento = "Dwemervamidium Mirage", delay = 0},
  ["finvir"] = {mementoId = 336, abilityId = 21226, memento = "Finvir's Trinket", delay = 0},
  ["none"] = {mementoId = nil, abilityId = nil, memento = "no memento", delay = 0},
}

function MementoRefresh.OnAddOnLoaded(_, addonName)
	if (addonName ~= MementoRefresh.name) then return end
	EVENT_MANAGER:UnregisterForEvent(MementoRefresh.name, EVENT_ADD_ON_LOADED)
  
  MementoRefresh.savedVariables = ZO_SavedVars:NewCharacterIdSettings("MementoRefreshSavedVariables", MementoRefresh.variableVersion, nil, MementoRefresh.defaults)
  SLASH_COMMANDS["/memref"] = MementoRefresh.slashCommander
  MementoRefresh.shouldRefresh()
end

function MementoRefresh.slashCommander(command)
  command = string.lower(command)
  
  if MementoRefresh.mementos[command] ~= nil then
    MementoRefresh.savedVariables.mementoId = MementoRefresh.mementos[command].mementoId
    MementoRefresh.savedVariables.abilityId = MementoRefresh.mementos[command].abilityId
    MementoRefresh.savedVariables.delay = MementoRefresh.mementos[command].delay
    MementoRefresh.shouldRefresh()
  elseif command == 'debug on' then
    EVENT_MANAGER:RegisterForEvent(MementoRefresh.name .. 'Debug', EVENT_COMBAT_EVENT, MementoRefresh.debugOn)
    EVENT_MANAGER:AddFilterForEvent(MementoRefresh.name .. 'Debug', EVENT_COMBAT_EVENT, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_NONE)
    EVENT_MANAGER:AddFilterForEvent(MementoRefresh.name .. 'Debug', EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_EFFECT_FADED)
  elseif command == 'debug off' then
    EVENT_MANAGER:UnregisterForEvent(MementoRefresh.name .. 'Debug', EVENT_COMBAT_EVENT)
  else
    for key, val in pairs(MementoRefresh.mementos) do
      CHAT_SYSTEM:AddMessage('[Memento Refresh] "/memref ' .. key .. '" to refresh ' .. val.memento)
    end
  end
end

function MementoRefresh.shouldRefresh()
  if MementoRefresh.savedVariables.mementoId ~= nil then
    EVENT_MANAGER:RegisterForEvent(MementoRefresh.name, EVENT_COMBAT_EVENT, MementoRefresh.mementoRanOut)
    EVENT_MANAGER:AddFilterForEvent(MementoRefresh.name, EVENT_COMBAT_EVENT, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_NONE)
    EVENT_MANAGER:AddFilterForEvent(MementoRefresh.name, EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_EFFECT_FADED)
    -- EVENT_MANAGER:AddFilterForEvent(MementoRefresh.name, EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, MementoRefresh.savedVariables.abilityId)
    UseCollectible(MementoRefresh.savedVariables.mementoId)
  end
end

-- (eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
function MementoRefresh.mementoRanOut(_, result, _, abilityName, _, _, _, sourceType, _, _, _, _, _, _, _, _, abilityId)
  if abilityId == MementoRefresh.savedVariables.abilityId then
    zo_callLater(function() UseCollectible(MementoRefresh.savedVariables.mementoId) end, 1000 + MementoRefresh.savedVariables.delay) 
  end
end

function MementoRefresh.debugOn(_, result, _, abilityName, _, _, _, sourceType, _, _, _, _, _, _, _, _, abilityId)
  CHAT_SYSTEM:AddMessage('Used ' .. abilityName .. ' (' .. tostring(abilityId) .. ') with result ' .. tostring(result) .. ' from sourceType ' .. tostring(sourceType))
end

EVENT_MANAGER:RegisterForEvent(MementoRefresh.name, EVENT_ADD_ON_LOADED, MementoRefresh.OnAddOnLoaded)