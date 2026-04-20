local item
package.preload["item"] = package.preload["item"] or function(...)
  local item = {}
  local player = require("player")
  local CARD_STAGGER = 6
  local CARD_ENTRY_DURATION = 10
  local CARD_CONFIRM_DURATION = 8
  local function reward_key(reward)
    if (reward.kind == "spell-upgrade") then
      return (tostring(reward.kind) .. ":" .. reward["spell-id"] .. ":" .. reward.id)
    else
      return (tostring(reward.kind) .. ":" .. reward.id)
    end
  end
  local function reward_kind_label(reward)
    if (reward.kind == "sword-upgrade") then
      return "Upgrade epee"
    else
      if (reward.kind == "spell") then
        return "Sort"
      else
        if (reward.kind == "spell-upgrade") then
          return "Upgrade sort"
        else
          return "Utility"
        end
      end
    end
  end
  local function reward_desc(reward)
    return (reward.data.desc or "")
  end
  local function reward_icon_spr(reward)
    local _139_ = reward.kind
    if (_139_ == "sword-upgrade") then
      return 203
    elseif (_139_ == "spell") then
      if (reward.id == 1) then
        return 200
      else
        return 204
      end
    elseif (_139_ == "spell-upgrade") then
      if (reward["spell-id"] == 1) then
        return 200
      else
        return 204
      end
    elseif (_139_ == "utility") then
      if (reward.id == 1) then
        return 205
      else
        return 209
      end
    else
      local _ = _139_
      return nil
    end
  end
  local function build_choices(p)
    local choices = {}
    local seen = {}
    local attempts = 0
    while ((#choices < 3) and (attempts < 30)) do
      local reward = player["get-random-reward"](p)
      attempts = (attempts + 1)
      if reward then
        local key = reward_key(reward)
        if not seen[key] then
          seen[key] = true
          table.insert(choices, reward)
        else
        end
      else
      end
    end
    return choices
  end
  item.new = function()
    return {selected = 1, choices = {}, ["open-timer"] = 0, ["confirm-timer"] = 0, ["confirmed-choice"] = nil, ["pending-choice"] = nil, ["open?"] = false}
  end
  item.open = function(state, p)
    state["open?"] = true
    state.selected = 1
    state.choices = build_choices(p)
    state["open-timer"] = 0
    state["confirm-timer"] = 0
    state["confirmed-choice"] = nil
    state["pending-choice"] = nil
    return nil
  end
  item.close = function(state)
    state["open?"] = false
    state.selected = 1
    state.choices = {}
    state["open-timer"] = 0
    state["confirm-timer"] = 0
    state["confirmed-choice"] = nil
    state["pending-choice"] = nil
    return nil
  end
  item["is-open?"] = function(state)
    return state["open?"]
  end
  item.update = function(state, p)
    if state["open?"] then
      state["open-timer"] = (state["open-timer"] + 1)
      if (state["confirm-timer"] > 0) then
        state["confirm-timer"] = (state["confirm-timer"] - 1)
        if (state["confirm-timer"] <= 0) then
          if state["pending-choice"] then
            player["apply-reward"](p, state["pending-choice"])
          else
          end
          return item.close(state)
        else
          return nil
        end
      else
        if ((#state.choices > 0) and btnp(2)) then
          state.selected = math.max(1, (state.selected - 1))
        else
        end
        if ((#state.choices > 0) and btnp(3)) then
          state.selected = math.min(#state.choices, (state.selected + 1))
        else
        end
        if ((#state.choices > 0) and btnp(4)) then
          local choice = state.choices[state.selected]
          state["pending-choice"] = choice
          state["confirmed-choice"] = state.selected
          state["confirm-timer"] = CARD_CONFIRM_DURATION
          return nil
        else
          return nil
        end
      end
    else
      return nil
    end
  end
  local function entry_offset_y(timer)
    if (timer <= 0) then
      return 10
    else
      local progress = math.min(1, (timer / CARD_ENTRY_DURATION))
      return math.floor(((1 - progress) * 10))
    end
  end
  local function pulse_color(timer, a, b)
    if (((timer // 2) % 2) == 0) then
      return a
    else
      return b
    end
  end
  item["draw-card"] = function(reward, x, y, w, h, selected_3f, pulse_timer, confirm_3f)
    local bg
    if selected_3f then
      bg = 6
    else
      bg = 1
    end
    local border
    if selected_3f then
      border = pulse_color(pulse_timer, 12, 9)
    else
      border = 13
    end
    local title_color
    if selected_3f then
      title_color = 12
    else
      title_color = 6
    end
    local icon = reward_icon_spr(reward)
    rect(x, y, w, h, bg)
    rectb(x, y, w, h, border)
    if confirm_3f then
      rectb((x - 1), (y - 1), (w + 2), (h + 2), pulse_color(pulse_timer, 10, 9))
    else
    end
    print(reward_kind_label(reward), (x + 5), (y + 6), title_color, false, 1, true)
    if icon then
      spr(icon, (x + (w - 14)), (y + 6), 15)
    else
    end
    print(reward.data.name, (x + 5), (y + 18), 12, false, 1, true)
    return print(reward_desc(reward), (x + 5), (y + 32), 13, false, 1, true)
  end
  item.draw = function(state)
    if state["open?"] then
      rect(12, 16, 216, 104, 0)
      rectb(12, 16, 216, 104, 12)
      print("Choisis une carte", 70, 22, 12, false, 1, true)
      if (state["confirm-timer"] > 0) then
        print("Validation...", 84, 108, 9, false, 1, true)
      else
        print("< > changer  X valider", 51, 108, 13, false, 1, true)
      end
      for i, reward in ipairs(state.choices) do
        local delay = ((i - 1) * CARD_STAGGER)
        local timer = (state["open-timer"] - delay)
        local y_offset = entry_offset_y(timer)
        if (timer > 0) then
          item["draw-card"](reward, (20 + ((i - 1) * 68)), (38 + y_offset), 64, 58, (i == state.selected), state["open-timer"], ((state["confirm-timer"] > 0) and (i == state["confirmed-choice"])))
        else
        end
      end
      return nil
    else
      return nil
    end
  end
  return item
end
package.preload["player"] = package.preload["player"] or function(...)
  local player = {}
  local abilities = require("abilities")
  local SLOT_BUMP_DURATION = 6
  local SLOT_PULSE_DURATION = 10
  local SLOT_MISSING_PULSE_DURATION = 10
  local HP_HIT_DURATION = 12
  local HP_HEAL_DURATION = 12
  local GOLD_POP_DURATION = 20
  local GOLD_SPEND_DURATION = 14
  local PLAYER_HIT_KNOCKBACK = 6
  local function random_choice(xs)
    if (#xs > 0) then
      return xs[math.random(1, #xs)]
    else
      return nil
    end
  end
  player.new = function()
    return {x = 24, y = 64, size = 8, speed = 2, color = 12, hp = 20, ["max-hp"] = 20, ["id-sword-upgrades"] = {0}, ["id-spell-upgrades"] = {id = nil, ["applied-upgrades"] = {}}, ["id-utility"] = -1, ["utility-cooldown"] = 0, ["i-frames"] = 0, ["spell-cooldown"] = 0, ["sword-cooldown"] = 0, ["sword-flash"] = 0, gold = 0, ["gold-pop-timer"] = 0, ["gold-spend-timer"] = 0, ["sword-hits-left"] = 0, ["hp-display"] = 10, ["hp-hit-timer"] = 0, ["hp-heal-timer"] = 0, ["slot-bump-attack"] = 0, ["slot-bump-spell"] = 0, ["slot-bump-utility"] = 0, ["slot-ready-pulse-attack"] = 0, ["slot-ready-pulse-spell"] = 0, ["slot-ready-pulse-utility"] = 0, ["slot-missing-pulse-spell"] = 0, ["slot-missing-pulse-utility"] = 0, ["last-sword-cooldown"] = 1, ["last-spell-cooldown"] = 1, ["last-utility-cooldown"] = 1, ["anim-timer"] = 0, ["anim-frame"] = 1, direction = "down", ["moving?"] = false, ["sword-hit-due"] = false}
  end
  player.update = function(p, world, enemies)
    local function hit_enemy_3f(nx, ny)
      local hit = false
      do
        local soft_size = (p.size - 2)
        for _, e in ipairs(enemies) do
          if world["collide?"]((nx + 1), (ny + 1), soft_size, e.x, e.y, e.size) then
            hit = true
          else
          end
        end
      end
      return hit
    end
    do
      local dy
      if btn(0) then
        dy = ( - p.speed)
      else
        if btn(1) then
          dy = p.speed
        else
          dy = 0
        end
      end
      if (dy ~= 0) then
        if (world["can-move?"](p.x, (p.y + dy), p.size) and not hit_enemy_3f(p.x, (p.y + dy))) then
          p.y = (p.y + dy)
        else
        end
      else
      end
    end
    do
      local dx
      if btn(2) then
        dx = ( - p.speed)
      else
        if btn(3) then
          dx = p.speed
        else
          dx = 0
        end
      end
      if (dx ~= 0) then
        if (world["can-move?"]((p.x + dx), p.y, p.size) and not hit_enemy_3f((p.x + dx), p.y)) then
          p.x = (p.x + dx)
        else
        end
      else
      end
    end
    if (p.x < 0) then
      p.x = 0
    else
    end
    if (p.y < 16) then
      p.y = 16
    else
    end
    if (p.x > (240 - p.size)) then
      p.x = (240 - p.size)
    else
    end
    if (p.y > (136 - p.size)) then
      p.y = (136 - p.size)
    else
    end
    do
      local dx
      if btn(2) then
        dx = -1
      else
        if btn(3) then
          dx = 1
        else
          dx = 0
        end
      end
      local dy
      if btn(0) then
        dy = -1
      else
        if btn(1) then
          dy = 1
        else
          dy = 0
        end
      end
      if ((dx ~= 0) or (dy ~= 0)) then
        p["facing-angle"] = math.atan2(dy, dx)
      else
      end
    end
    if (p["sword-flash"] > 0) then
      p["sword-flash"] = (p["sword-flash"] - 1)
      if (p["sword-flash"] == 0) then
        p["sword-hit-due"] = true
        if (p["sword-hits-left"] > 1) then
          p["sword-hits-left"] = (p["sword-hits-left"] - 1)
          p["sword-flash"] = 8
        else
        end
      else
      end
    else
    end
    do
      local prev_spell = p["spell-cooldown"]
      local prev_sword = p["sword-cooldown"]
      local prev_util = p["utility-cooldown"]
      if (p["spell-cooldown"] > 0) then
        p["spell-cooldown"] = (p["spell-cooldown"] - 1)
      else
      end
      if (p["sword-cooldown"] > 0) then
        p["sword-cooldown"] = (p["sword-cooldown"] - 1)
      else
      end
      if (p["utility-cooldown"] > 0) then
        p["utility-cooldown"] = (p["utility-cooldown"] - 1)
      else
      end
      if ((prev_spell > 0) and (p["spell-cooldown"] == 0)) then
        p["slot-ready-pulse-spell"] = SLOT_PULSE_DURATION
      else
      end
      if ((prev_sword > 0) and (p["sword-cooldown"] == 0)) then
        p["slot-ready-pulse-attack"] = SLOT_PULSE_DURATION
      else
      end
      if ((prev_util > 0) and (p["utility-cooldown"] == 0)) then
        p["slot-ready-pulse-utility"] = SLOT_PULSE_DURATION
      else
      end
    end
    if (p["i-frames"] > 0) then
      p["i-frames"] = (p["i-frames"] - 1)
    else
    end
    if (p["hp-hit-timer"] > 0) then
      p["hp-hit-timer"] = (p["hp-hit-timer"] - 1)
    else
    end
    if (p["hp-heal-timer"] > 0) then
      p["hp-heal-timer"] = (p["hp-heal-timer"] - 1)
    else
    end
    if (p["gold-pop-timer"] > 0) then
      p["gold-pop-timer"] = (p["gold-pop-timer"] - 1)
    else
    end
    if (p["gold-spend-timer"] > 0) then
      p["gold-spend-timer"] = (p["gold-spend-timer"] - 1)
    else
    end
    if (p["slot-bump-attack"] > 0) then
      p["slot-bump-attack"] = (p["slot-bump-attack"] - 1)
    else
    end
    if (p["slot-bump-spell"] > 0) then
      p["slot-bump-spell"] = (p["slot-bump-spell"] - 1)
    else
    end
    if (p["slot-bump-utility"] > 0) then
      p["slot-bump-utility"] = (p["slot-bump-utility"] - 1)
    else
    end
    if (p["slot-ready-pulse-attack"] > 0) then
      p["slot-ready-pulse-attack"] = (p["slot-ready-pulse-attack"] - 1)
    else
    end
    if (p["slot-ready-pulse-spell"] > 0) then
      p["slot-ready-pulse-spell"] = (p["slot-ready-pulse-spell"] - 1)
    else
    end
    if (p["slot-ready-pulse-utility"] > 0) then
      p["slot-ready-pulse-utility"] = (p["slot-ready-pulse-utility"] - 1)
    else
    end
    if (p["slot-missing-pulse-spell"] > 0) then
      p["slot-missing-pulse-spell"] = (p["slot-missing-pulse-spell"] - 1)
    else
    end
    if (p["slot-missing-pulse-utility"] > 0) then
      p["slot-missing-pulse-utility"] = (p["slot-missing-pulse-utility"] - 1)
    else
    end
    if (p["hp-display"] == nil) then
      p["hp-display"] = p.hp
    else
    end
    do
      local delta = (p.hp - p["hp-display"])
      if (delta ~= 0) then
        p["hp-display"] = (p["hp-display"] + (delta * 0.3))
        if (math.abs((p.hp - p["hp-display"])) < 0.1) then
          p["hp-display"] = p.hp
        else
        end
      else
      end
    end
    p["anim-timer"] = (p["anim-timer"] + 1)
    local dx
    if btn(2) then
      dx = -1
    else
      if btn(3) then
        dx = 1
      else
        dx = 0
      end
    end
    local dy
    if btn(0) then
      dy = -1
    else
      if btn(1) then
        dy = 1
      else
        dy = 0
      end
    end
    local moving_3f = ((dx ~= 0) or (dy ~= 0))
    p["moving?"] = moving_3f
    if moving_3f then
      if (dx > 0) then
        p.direction = "right"
      elseif (dx < 0) then
        p.direction = "left"
      elseif (dy > 0) then
        p.direction = "down"
      elseif (dy < 0) then
        p.direction = "up"
      else
      end
    else
    end
    if moving_3f then
      if (p["anim-timer"] > 8) then
        p["anim-timer"] = 0
        p["anim-frame"] = (p["anim-frame"] + 1)
        if (p["anim-frame"] > 3) then
          p["anim-frame"] = 1
          return nil
        else
          return nil
        end
      else
        return nil
      end
    else
      if (p["anim-timer"] > 20) then
        p["anim-timer"] = 0
        p["anim-frame"] = (p["anim-frame"] + 1)
        if (p["anim-frame"] > 2) then
          p["anim-frame"] = 1
          return nil
        else
          return nil
        end
      else
        return nil
      end
    end
  end
  player.draw = function(p)
    local walk_base
    if ((p.direction == "right") or (p.direction == "down")) then
      walk_base = 102
    elseif (p.direction == "left") then
      walk_base = 105
    else
      walk_base = 108
    end
    local walk_spr = (walk_base + (math.min(p["anim-frame"], 3) - 1))
    local idle_spr = (100 + (math.min(p["anim-frame"], 2) - 1))
    local final_spr
    if p["moving?"] then
      final_spr = walk_spr
    else
      final_spr = idle_spr
    end
    if ((p["i-frames"] <= 0) or (((p["i-frames"] // 4) % 2) == 0)) then
      return spr(final_spr, p.x, p.y, 15)
    else
      return nil
    end
  end
  player["add-gold"] = function(p, amount)
    p.gold = (p.gold + amount)
    p["gold-pop-timer"] = GOLD_POP_DURATION
    p["gold-spend-timer"] = 0
    return nil
  end
  player["spend-gold"] = function(p, amount)
    p.gold = math.max(0, (p.gold - amount))
    p["gold-spend-timer"] = GOLD_SPEND_DURATION
    return nil
  end
  player["draw-gold-icon"] = function(x, y)
    return spr(206, x, y, 15)
  end
  player["draw-gold-ui"] = function(p)
    local label = tostring(p.gold)
    local text_width = (#label * 6)
    local icon_x = (240 - 10 - text_width - 12)
    local text_x = (icon_x + 11)
    local lift
    if (p["gold-pop-timer"] > 0) then
      lift = math.floor((p["gold-pop-timer"] / 6))
    else
      lift = 0
    end
    local color
    if (p["gold-spend-timer"] > 0) then
      color = 6
    elseif (p["gold-pop-timer"] > 0) then
      if (((p["gold-pop-timer"] // 2) % 2) == 0) then
        color = 9
      else
        color = 12
      end
    else
      color = 12
    end
    player["draw-gold-icon"](icon_x, (4 - lift))
    return print(label, text_x, (5 - lift), color, false, 1, true)
  end
  local function apply_hit_knockback(p, hit_x, hit_y, world)
    if (hit_x and hit_y) then
      local cx = (p.x + (p.size / 2))
      local cy = (p.y + (p.size / 2))
      local dx = (cx - hit_x)
      local dy = (cy - hit_y)
      local len = math.sqrt(((dx * dx) + (dy * dy)))
      if (len > 0.001) then
        local knx = (dx / len)
        local kny = (dy / len)
        local nx = math.max(0, math.min((p.x + (knx * PLAYER_HIT_KNOCKBACK)), (240 - p.size)))
        local ny = math.max(16, math.min((p.y + (kny * PLAYER_HIT_KNOCKBACK)), (136 - p.size)))
        if world then
          if world["can-move?"](nx, p.y, p.size) then
            p.x = nx
          else
          end
          if world["can-move?"](p.x, ny, p.size) then
            p.y = ny
            return nil
          else
            return nil
          end
        else
          p.x = nx
          p.y = ny
          return nil
        end
      else
        return nil
      end
    else
      return nil
    end
  end
  player["take-damage"] = function(p, dmg, hit_x, hit_y, world)
    if (p["i-frames"] <= 0) then
      p.hp = (p.hp - dmg)
      p["i-frames"] = 40
      p["hp-hit-timer"] = HP_HIT_DURATION
      p["hp-heal-timer"] = 0
      apply_hit_knockback(p, hit_x, hit_y, world)
      if (p.hp < 0) then
        p.hp = 0
      else
      end
      return true
    else
      return false
    end
  end
  local function slot_bump_offset(timer)
    if (timer > 0) then
      if ((timer % 2) == 0) then
        return -1
      else
        return 0
      end
    else
      return 0
    end
  end
  local function pulse_color(timer, a, b)
    if (timer > 0) then
      if (((timer // 2) % 2) == 0) then
        return a
      else
        return b
      end
    else
      return a
    end
  end
  local function draw_slot_cooldown(x, y, cooldown, max_cooldown)
    if (cooldown > 0) then
      local ratio = math.min(1, (cooldown / math.max(max_cooldown, 1)))
      local h = math.max(1, math.floor((10 * ratio)))
      local top = (y + 11 + ( - h))
      return rect((x + 1), top, 10, h, 1)
    else
      return nil
    end
  end
  player["draw-ui"] = function(p)
    do
      local hp_ratio = (math.max(p["hp-display"], 0) / p["max-hp"])
      local hp_color
      if (p["hp-hit-timer"] > 0) then
        hp_color = pulse_color(p["hp-hit-timer"], 6, 11)
      elseif (p["hp-heal-timer"] > 0) then
        hp_color = pulse_color(p["hp-heal-timer"], 10, 11)
      else
        hp_color = 11
      end
      local border_color
      if (p["hp-hit-timer"] > 0) then
        border_color = 6
      else
        border_color = 12
      end
      rect(5, 5, 50, 6, 1)
      rect(5, 5, math.floor((50 * hp_ratio)), 6, hp_color)
      rectb(5, 5, 50, 6, border_color)
    end
    do
      local oy = slot_bump_offset(p["slot-bump-attack"])
      local y = (2 + oy)
      local border = pulse_color(p["slot-ready-pulse-attack"], 12, 9)
      rect(60, y, 12, 12, 0)
      draw_slot_cooldown(60, y, p["sword-cooldown"], p["last-sword-cooldown"])
      rectb(60, y, 12, 12, border)
      spr(203, 62, (y + 2), 15)
    end
    do
      local has_spell = (p["id-spell-upgrades"].id ~= nil)
      local spell_sprite
      if (p["id-spell-upgrades"].id == 1) then
        spell_sprite = 200
      else
        spell_sprite = 204
      end
      local oy = slot_bump_offset(p["slot-bump-spell"])
      local y = (2 + oy)
      local border_base
      if has_spell then
        border_base = 12
      else
        border_base = 13
      end
      local border
      if (p["slot-missing-pulse-spell"] > 0) then
        border = pulse_color(p["slot-missing-pulse-spell"], 8, 6)
      else
        border = pulse_color(p["slot-ready-pulse-spell"], border_base, 9)
      end
      rect(74, y, 12, 12, 0)
      if has_spell then
        draw_slot_cooldown(74, y, p["spell-cooldown"], p["last-spell-cooldown"])
      else
      end
      rectb(74, y, 12, 12, border)
      if has_spell then
        spr(spell_sprite, 76, (y + 2), 15)
      else
      end
    end
    local has_util = (p["id-utility"] ~= -1)
    local util_sprite
    if (p["id-utility"] == 1) then
      util_sprite = 205
    else
      util_sprite = 209
    end
    local oy = slot_bump_offset(p["slot-bump-utility"])
    local y = (2 + oy)
    local border_base
    if has_util then
      border_base = 12
    else
      border_base = 13
    end
    local border
    if (p["slot-missing-pulse-utility"] > 0) then
      border = pulse_color(p["slot-missing-pulse-utility"], 8, 6)
    else
      border = pulse_color(p["slot-ready-pulse-utility"], border_base, 9)
    end
    rect(88, y, 12, 12, 0)
    if has_util then
      draw_slot_cooldown(88, y, p["utility-cooldown"], p["last-utility-cooldown"])
    else
    end
    rectb(88, y, 12, 12, border)
    if has_util then
      return spr(util_sprite, 90, (y + 2), 15)
    else
      return nil
    end
  end
  player.heal = function(p, amount)
    local old_hp = p.hp
    p.hp = (p.hp + amount)
    if (p.hp > p["max-hp"]) then
      p.hp = p["max-hp"]
    else
    end
    if (p.hp > old_hp) then
      p["hp-heal-timer"] = HP_HEAL_DURATION
      p["hp-hit-timer"] = 0
      return nil
    else
      return nil
    end
  end
  player["get-random-reward"] = function(p)
    local choices = {}
    local sword_id = random_choice(abilities["get-all-sword-upgrade-ids"]())
    local spell_id = p["id-spell-upgrades"].id
    local spell_upgrade_ids = abilities["get-available-spell-upgrade-ids"](p["id-spell-upgrades"])
    local utility_ids = {}
    if sword_id then
      table.insert(choices, {kind = "sword-upgrade", id = sword_id, data = abilities["get-sword-upgrade"](sword_id)})
    else
    end
    if (spell_id == nil) then
      local new_spell_id = random_choice(abilities["get-all-spell-ids"]())
      if new_spell_id then
        table.insert(choices, {kind = "spell", id = new_spell_id, data = abilities["get-spell"](new_spell_id)})
      else
      end
    else
      local spell_upgrade_id = random_choice(spell_upgrade_ids)
      if spell_upgrade_id then
        table.insert(choices, {kind = "spell-upgrade", ["spell-id"] = spell_id, id = spell_upgrade_id, data = abilities["get-spell-upgrade"](spell_id, spell_upgrade_id)})
      else
      end
    end
    for _, id in ipairs(abilities["get-all-utility-ids"]()) do
      if (id ~= p["id-utility"]) then
        table.insert(utility_ids, id)
      else
      end
    end
    do
      local utility_id = random_choice(utility_ids)
      if utility_id then
        table.insert(choices, {kind = "utility", id = utility_id, data = abilities["get-utility"](utility_id)})
      else
      end
    end
    return random_choice(choices)
  end
  player["apply-reward"] = function(p, reward)
    if reward then
      if (reward.kind == "sword-upgrade") then
        table.insert(p["id-sword-upgrades"], reward.id)
        p["slot-bump-attack"] = SLOT_BUMP_DURATION
        p["slot-ready-pulse-attack"] = SLOT_PULSE_DURATION
        return nil
      else
        if (reward.kind == "spell") then
          p["id-spell-upgrades"]["id"] = reward.id
          p["id-spell-upgrades"]["applied-upgrades"] = {}
          p["slot-bump-spell"] = SLOT_BUMP_DURATION
          p["slot-ready-pulse-spell"] = SLOT_PULSE_DURATION
          return nil
        else
          if (reward.kind == "spell-upgrade") then
            table.insert(p["id-spell-upgrades"]["applied-upgrades"], reward.id)
            p["slot-bump-spell"] = SLOT_BUMP_DURATION
            p["slot-ready-pulse-spell"] = SLOT_PULSE_DURATION
            return nil
          else
            if (reward.kind == "utility") then
              p["id-utility"] = reward.id
              p["slot-bump-utility"] = SLOT_BUMP_DURATION
              p["slot-ready-pulse-utility"] = SLOT_PULSE_DURATION
              return nil
            else
              return nil
            end
          end
        end
      end
    else
      return nil
    end
  end
  player["feedback-action-status"] = function(p, slot, status)
    if status then
      if (slot == "attack") then
        if (status == "cooldown") then
          p["slot-bump-attack"] = SLOT_BUMP_DURATION
          p["slot-ready-pulse-attack"] = SLOT_PULSE_DURATION
        else
        end
      elseif (slot == "spell") then
        if (status == "cooldown") then
          p["slot-bump-spell"] = SLOT_BUMP_DURATION
          p["slot-ready-pulse-spell"] = SLOT_PULSE_DURATION
        elseif (status == "missing") then
          p["slot-bump-spell"] = SLOT_BUMP_DURATION
          p["slot-missing-pulse-spell"] = SLOT_MISSING_PULSE_DURATION
        else
        end
      elseif (slot == "utility") then
        if (status == "cooldown") then
          p["slot-bump-utility"] = SLOT_BUMP_DURATION
          p["slot-ready-pulse-utility"] = SLOT_PULSE_DURATION
        elseif (status == "missing") then
          p["slot-bump-utility"] = SLOT_BUMP_DURATION
          p["slot-missing-pulse-utility"] = SLOT_MISSING_PULSE_DURATION
        else
        end
      else
        local _ = slot
      end
      return status
    else
      return nil
    end
  end
  player["use-utility"] = function(p, world)
    if (p["id-utility"] == -1) then
      return "missing"
    elseif (p["utility-cooldown"] > 0) then
      return "cooldown"
    else
      local util = abilities["get-utility"](p["id-utility"])
      if (util.type ~= "active") then
        return "missing"
      elseif (p["id-utility"] == 1) then
        local facing = (p["facing-angle"] or 0)
        local dist = util.stats.distance
        local dx = math.cos(facing)
        local dy = math.sin(facing)
        local safe_x, safe_y = nil, nil
        do
          local bx = p.x
          local by = p.y
          local i = 1
          while (i <= dist) do
            do
              local tx = math.max(0, math.min((p.x + (i * dx)), (240 - p.size)))
              local ty = math.max(20, math.min((p.y + (i * dy)), (136 - p.size)))
              if world["can-move?"](tx, ty, p.size) then
                bx = tx
                by = ty
              else
                i = (dist + 1)
              end
            end
            i = (i + 1)
          end
          safe_x, safe_y = bx, by
        end
        p.x = safe_x
        p.y = safe_y
        p["i-frames"] = util.stats["i-frames"]
        p["utility-cooldown"] = util.stats.cooldown
        p["last-utility-cooldown"] = util.stats.cooldown
        return "ok"
      else
        return "missing"
      end
    end
  end
  player["draw-attack-cone"] = function(p)
    local stats = abilities["compute-sword-stats"](p["id-sword-upgrades"])
    local facing = (p["facing-angle"] or 0)
    local half_arc = ((math.max(stats.arc, 15) / 2) * (math.pi / 180))
    local cx = (p.x + (p.size / 2))
    local cy = (p.y + (p.size / 2))
    local r = stats.range
    local a1 = (facing - half_arc)
    local progress = ((8 - p["sword-flash"]) / 8)
    local swept = (progress * 2 * half_arc)
    local cur_angle = (a1 + swept)
    line(cx, cy, (cx + (r * math.cos(cur_angle))), (cy + (r * math.sin(cur_angle))), 13)
    for i = 0, 5 do
      local t1 = (a1 + ((i / 6) * swept))
      local t2 = (a1 + (((i + 1) / 6) * swept))
      line((cx + (r * math.cos(t1))), (cy + (r * math.sin(t1))), (cx + (r * math.cos(t2))), (cy + (r * math.sin(t2))), 13)
    end
    return nil
  end
  player["do-sword-hit"] = function(p, enemies, enemie)
    local stats = abilities["compute-sword-stats"](p["id-sword-upgrades"])
    local facing = (p["facing-angle"] or 0)
    local half_arc = ((math.max(stats.arc, 15) / 2) * (math.pi / 180))
    local cx = (p.x + (p.size / 2))
    local cy = (p.y + (p.size / 2))
    local function point_in_sector_3f(px, py)
      local dx = (px - cx)
      local dy = (py - cy)
      local dist = math.sqrt(((dx * dx) + (dy * dy)))
      if (dist > stats.range) then
        return false
      else
        local angle_to_point = math.atan2(dy, dx)
        local diff = math.abs((angle_to_point - facing))
        local norm_diff
        if (diff > math.pi) then
          norm_diff = ((2 * math.pi) - diff)
        else
          norm_diff = diff
        end
        return (norm_diff <= half_arc)
      end
    end
    for _, e in ipairs(enemies) do
      local x = e.x
      local y = e.y
      local s = e.size
      local x2 = (x + s)
      local y2 = (y + s)
      local mid_x = (x + (s / 2))
      local mid_y = (y + (s / 2))
      local points = {{mid_x, mid_y}, {x, y}, {x2, y}, {x, y2}, {x2, y2}, {mid_x, y}, {mid_x, y2}, {x, mid_y}, {x2, mid_y}}
      local hit_3f = false
      if ((cx >= x) and (cx <= x2) and (cy >= y) and (cy <= y2)) then
        hit_3f = true
      else
      end
      if not hit_3f then
        for _0, pt in ipairs(points) do
          if (not hit_3f and point_in_sector_3f(pt[1], pt[2])) then
            hit_3f = true
          else
          end
        end
      else
      end
      if hit_3f then
        enemie["take-damage"](e, stats.damage)
        if enemie["apply-knockback"] then
          enemie["apply-knockback"](e, cx, cy, 2.8)
        else
        end
      else
      end
    end
    return nil
  end
  player.attack = function(p, enemies, enemie)
    local stats = abilities["compute-sword-stats"](p["id-sword-upgrades"])
    if (p["sword-cooldown"] > 0) then
      return "cooldown"
    else
      p["sword-flash"] = 8
      p["sword-hits-left"] = stats.hits
      p["sword-cooldown"] = stats.cooldown
      p["last-sword-cooldown"] = stats.cooldown
      return "ok"
    end
  end
  player["spell-attack"] = function(p, enemies, enemie, projectiles, lightning_flashes)
    if (p["id-spell-upgrades"].id == nil) then
      return "missing"
    elseif (p["spell-cooldown"] > 0) then
      return "cooldown"
    else
      local stats = abilities["compute-spell-stats"](p["id-spell-upgrades"])
      local facing = (p["facing-angle"] or 0)
      local cx = (p.x + (p.size / 2))
      local cy = (p.y + (p.size / 2))
      p["spell-cooldown"] = stats.cooldown
      p["last-spell-cooldown"] = stats.cooldown
      if (p["id-spell-upgrades"].id == 1) then
        local total = stats.projectiles
        local spread_rad = ((stats.spread or 0) * (math.pi / 180))
        local start_angle
        if (total > 1) then
          start_angle = (facing - (spread_rad * 0.5))
        else
          start_angle = facing
        end
        local step
        if (total > 1) then
          step = (spread_rad / (total - 1))
        else
          step = 0
        end
        for i = 0, (total - 1) do
          local angle = (start_angle + (i * step))
          table.insert(projectiles, {x = cx, y = cy, vx = (stats.speed * math.cos(angle)), vy = (stats.speed * math.sin(angle)), damage = stats.damage, radius = stats.radius, aoe = (stats.aoe or 0), dot = (stats.dot or 0), ["dot-dur"] = (stats["dot-dur"] or 0), alive = true, lifetime = 120})
        end
      else
        local range = 80
        local best_e = nil
        local best_dist = 9999
        for _, e in ipairs(enemies) do
          local dx = (e.x - cx)
          local dy = (e.y - cy)
          local dist = math.sqrt(((dx * dx) + (dy * dy)))
          if ((dist < range) and (dist < best_dist)) then
            best_e = e
            best_dist = dist
          else
          end
        end
        if best_e then
          enemie["take-damage"](best_e, stats.damage)
          if (stats.stun > 0) then
            enemie["apply-stun"](best_e, stats.stun)
          else
          end
          do
            local ex = (best_e.x + (best_e.size / 2))
            local ey = (best_e.y + (best_e.size / 2))
            local ddx = (ex - cx)
            local ddy = (ey - cy)
            table.insert(lightning_flashes, {x1 = cx, y1 = cy, x2 = ex, y2 = ey, jx = (( - ddy) / 4), jy = (ddx / 4), timer = 8})
          end
          if (stats.chain > 0) then
            local hit_set = {}
            hit_set[best_e] = true
            local last_target = best_e
            local chains_left = stats.chain
            while (chains_left > 0) do
              local next_e = nil
              local next_dist = 9999
              for _, e in ipairs(enemies) do
                if not hit_set[e] then
                  local dx = (e.x - last_target.x)
                  local dy = (e.y - last_target.y)
                  local dist = math.sqrt(((dx * dx) + (dy * dy)))
                  if ((dist < 40) and (dist < next_dist)) then
                    next_e = e
                    next_dist = dist
                  else
                  end
                else
                end
              end
              if next_e then
                enemie["take-damage"](next_e, stats.damage)
                if (stats.stun > 0) then
                  enemie["apply-stun"](next_e, stats.stun)
                else
                end
                do
                  local lx = (last_target.x + (last_target.size / 2))
                  local ly = (last_target.y + (last_target.size / 2))
                  local nx = (next_e.x + (next_e.size / 2))
                  local ny = (next_e.y + (next_e.size / 2))
                  local ddx = (nx - lx)
                  local ddy = (ny - ly)
                  table.insert(lightning_flashes, {x1 = lx, y1 = ly, x2 = nx, y2 = ny, jx = (( - ddy) / 4), jy = (ddx / 4), timer = 8})
                end
                hit_set[next_e] = true
                last_target = next_e
                chains_left = (chains_left - 1)
              else
                chains_left = 0
              end
            end
          else
          end
        else
        end
      end
      return "ok"
    end
  end
  return player
end
package.preload["abilities"] = package.preload["abilities"] or function(...)
  local abilities = {}
  local SWORD_BASE = {damage = 3, cooldown = 18, range = 20, arc = 120, hits = 1}
  local sword_upgrades = {{name = "Degats+", type = "stat", ["stack?"] = true, effects = {damage = 2}}, {name = "Vitesse+", type = "stat", ["stack?"] = true, effects = {cooldown = -2}}, {name = "Portee+", type = "stat", ["stack?"] = true, effects = {range = 4}}, {name = "Arc tranchant", type = "behavior", ["stack?"] = true, effects = {arc = 60}}, {name = "Double frappe", type = "behavior", effects = {hits = 1}, ["stack?"] = false}}
  abilities["compute-sword-stats"] = function(upgrade_ids)
    local stats = {damage = SWORD_BASE.damage, cooldown = SWORD_BASE.cooldown, range = SWORD_BASE.range, arc = SWORD_BASE.arc, hits = SWORD_BASE.hits}
    for _, id in ipairs(upgrade_ids) do
      if (id ~= 0) then
        local upg = sword_upgrades[id]
        for k, v in pairs(upg.effects) do
          if (type(v) == "boolean") then
            stats[k] = v
          else
            stats[k] = (stats[k] + v)
          end
        end
      else
      end
    end
    if (stats.cooldown < 6) then
      stats.cooldown = 6
    else
    end
    return stats
  end
  local spells = {{name = "Boule de feu", desc = "", base = {damage = 3, cooldown = 40, speed = 3, radius = 8, aoe = 0, dot = 0, ["dot-dur"] = 0, projectiles = 1, spread = 0}, upgrades = {{name = "Explosion", desc = "", effects = {aoe = 16}}, {name = "Brulure", desc = "", effects = {dot = 1, ["dot-dur"] = 120}}, {name = "Triple boule", desc = "", effects = {projectiles = 2, spread = 30}}}}, {name = "Foudre", desc = "", base = {damage = 2, cooldown = 70, chain = 0, stun = 0}, upgrades = {{name = "Chaine", desc = "", effects = {chain = 2}}, {name = "Paralysie", desc = "", effects = {stun = 30}}}}}
  abilities["compute-spell-stats"] = function(spell_state)
    if (spell_state.id ~= nil) then
      local def = spells[spell_state.id]
      local stats = {}
      for k, v in pairs(def.base) do
        stats[k] = v
      end
      for _, sub_id in ipairs(spell_state["applied-upgrades"]) do
        local upg = def.upgrades[sub_id]
        for k, v in pairs(upg.effects) do
          stats[k] = ((stats[k] or 0) + v)
        end
      end
      return stats
    else
      return nil
    end
  end
  local utilities = {{name = "Dash", type = "active", desc = "", stats = {distance = 32, cooldown = 90, ["i-frames"] = 10}}, {name = "Bouclier d'epines", type = "passive", desc = "", stats = {["reflect-damage"] = 2}}}
  abilities["get-sword-upgrade"] = function(id)
    return sword_upgrades[id]
  end
  abilities["get-all-sword-upgrade-ids"] = function()
    local ids = {}
    for id, _ in pairs(sword_upgrades) do
      table.insert(ids, id)
    end
    return ids
  end
  abilities["get-spell"] = function(id)
    return spells[id]
  end
  abilities["get-all-spell-ids"] = function()
    local ids = {}
    for id, _ in pairs(spells) do
      table.insert(ids, id)
    end
    return ids
  end
  abilities["get-utility"] = function(id)
    return utilities[id]
  end
  abilities["get-all-utility-ids"] = function()
    local ids = {}
    for id, _ in pairs(utilities) do
      table.insert(ids, id)
    end
    return ids
  end
  abilities["get-spell-upgrade"] = function(spell_id, sub_id)
    local spell = spells[spell_id]
    if spell then
      return spell.upgrades[sub_id]
    else
      return nil
    end
  end
  abilities["get-available-spell-upgrade-ids"] = function(spell_state)
    if (spell_state.id == nil) then
      return {}
    else
      local ids = {}
      local def = spells[spell_state.id]
      local applied_set = {}
      for _, sub_id in ipairs(spell_state["applied-upgrades"]) do
        applied_set[sub_id] = true
      end
      for sub_id, _ in pairs(def.upgrades) do
        if not applied_set[sub_id] then
          table.insert(ids, sub_id)
        else
        end
      end
      return ids
    end
  end
  abilities["remaining-spell-upgrades"] = function(spell_state)
    if (spell_state.id == nil) then
      return 0
    else
      local def = spells[spell_state.id]
      local total
      do
        local n = 0
        for _, _0 in pairs(def.upgrades) do
          n = (n + 1)
        end
        total = n
      end
      local applied = #spell_state["applied-upgrades"]
      return (total - applied)
    end
  end
  return abilities
end
item = require("item")
local player = require("player")
local world
package.preload["world"] = package.preload["world"] or function(...)
  local M = {}
  M["design-spr"] = function(id, hex)
    local addr = (16384 + (id * 32))
    for i = 1, 64, 2 do
      local s1 = hex:sub(i, i)
      local s2 = hex:sub((i + 1), (i + 1))
      local p1
      local _163_
      if (s1 == "") then
        _163_ = "0"
      else
        _163_ = s1
      end
      p1 = tonumber(_163_, 16)
      local p2
      local _165_
      if (s2 == "") then
        _165_ = "0"
      else
        _165_ = s2
      end
      p2 = tonumber(_165_, 16)
      poke((addr + ((i - 1) // 2)), ((p2 * 16) + p1))
    end
    return nil
  end
  local map_pool = {{kind = "combat", c = {{1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1}, {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1}, {1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1}, {1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1}, {1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1}, {1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 1, 1}, {1, 1, 0, 0, 0, 1, 1, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 1, 1}, {1, 1, 0, 0, 0, 1, 1, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 2}, {1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 2}, {1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 1, 1}, {1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 1, 1}, {1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1}, {1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1}, {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1}, {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1}}, v = {{11, 10, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 15, 14}, {9, 8, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 13, 12}, {1, 0, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 2, 3}, {1, 0, 24, 24, 24, 24, 24, 26, 25, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 25, 24, 24, 24, 24, 24, 24, 24, 24, 2, 3}, {1, 0, 24, 24, 24, 24, 24, 24, 24, 24, 36, 32, 32, 32, 32, 37, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 2, 3}, {1, 0, 24, 24, 24, 24, 24, 24, 24, 24, 35, 31, 31, 31, 31, 34, 24, 24, 24, 24, 24, 24, 27, 29, 24, 24, 24, 24, 2, 3}, {1, 0, 24, 24, 24, 27, 29, 24, 24, 24, 35, 31, 31, 31, 31, 31, 32, 37, 24, 24, 24, 24, 28, 30, 24, 24, 24, 24, 2, 3}, {1, 0, 24, 24, 24, 28, 30, 24, 24, 24, 35, 31, 31, 31, 31, 31, 31, 34, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 212, 213}, {1, 0, 24, 24, 24, 24, 24, 24, 24, 24, 35, 31, 31, 31, 31, 31, 33, 39, 24, 24, 24, 24, 24, 25, 24, 24, 24, 24, 210, 211}, {1, 0, 24, 24, 24, 24, 24, 24, 24, 24, 38, 33, 33, 33, 33, 39, 24, 24, 24, 27, 29, 24, 24, 24, 24, 24, 24, 24, 2, 3}, {1, 0, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 28, 30, 24, 24, 24, 24, 24, 24, 24, 2, 3}, {1, 0, 24, 24, 26, 24, 24, 24, 24, 24, 24, 24, 26, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 2, 3}, {1, 0, 24, 24, 24, 24, 24, 24, 24, 25, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 25, 24, 24, 24, 24, 24, 2, 3}, {23, 22, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 19, 18}, {21, 20, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 17, 16}}}, {kind = "combat", c = {{1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1}, {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1}, {1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1}, {1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1}, {1, 1, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1}, {1, 1, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 1, 1}, {1, 1, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 1, 1}, {1, 1, 0, 0, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 2}, {1, 1, 0, 0, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 2}, {1, 1, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1}, {1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1}, {1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1}, {1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1}, {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1}, {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1}}, v = {{11, 10, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 15, 14}, {9, 8, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 13, 12}, {1, 0, 24, 24, 24, 24, 25, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 2, 3}, {1, 0, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 25, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 2, 3}, {1, 0, 24, 24, 25, 24, 24, 36, 32, 32, 32, 32, 37, 24, 24, 24, 24, 24, 24, 25, 24, 24, 24, 24, 24, 24, 24, 24, 2, 3}, {1, 0, 24, 24, 24, 24, 24, 35, 31, 31, 31, 31, 34, 24, 24, 24, 24, 24, 24, 24, 27, 29, 24, 24, 24, 24, 24, 24, 2, 3}, {1, 0, 24, 24, 24, 24, 24, 35, 31, 31, 31, 31, 31, 32, 37, 24, 24, 24, 24, 24, 28, 30, 24, 24, 24, 24, 24, 24, 2, 3}, {1, 0, 24, 24, 27, 29, 24, 35, 31, 31, 31, 31, 31, 31, 34, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 2, 3}, {1, 0, 24, 24, 28, 30, 24, 35, 31, 31, 31, 31, 31, 31, 34, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 212, 213}, {1, 0, 24, 24, 24, 24, 24, 38, 33, 33, 33, 33, 33, 33, 39, 24, 24, 24, 27, 29, 24, 24, 24, 24, 24, 24, 24, 24, 210, 211}, {1, 0, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 28, 30, 24, 24, 24, 24, 24, 24, 24, 24, 2, 3}, {1, 0, 24, 24, 24, 26, 24, 24, 24, 24, 24, 24, 26, 26, 24, 24, 24, 24, 24, 24, 25, 24, 24, 24, 24, 24, 24, 24, 2, 3}, {1, 0, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 25, 24, 24, 24, 24, 24, 2, 3}, {23, 22, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 19, 18}, {21, 20, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 17, 16}}}, {kind = "combat", c = {{1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1}, {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1}, {1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1}, {1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1}, {1, 1, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 1, 1}, {1, 1, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 1, 1}, {1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1}, {1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 2}, {1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 2}, {1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1}, {1, 1, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 1, 1}, {1, 1, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 1, 1}, {1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1}, {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1}, {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1}}, v = {{11, 10, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 15, 14}, {9, 8, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 13, 12}, {1, 0, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 2, 3}, {1, 0, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 2, 3}, {1, 0, 24, 24, 24, 24, 27, 29, 24, 24, 24, 24, 25, 24, 24, 24, 26, 24, 24, 24, 24, 27, 29, 24, 24, 24, 24, 24, 2, 3}, {1, 0, 24, 24, 24, 24, 28, 30, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 28, 30, 24, 24, 24, 24, 24, 2, 3}, {1, 0, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 2, 3}, {1, 0, 24, 24, 24, 24, 24, 24, 24, 24, 25, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 212, 213}, {1, 0, 24, 26, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 25, 24, 24, 24, 24, 24, 24, 24, 210, 211}, {1, 0, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 2, 3}, {1, 0, 24, 24, 24, 24, 27, 29, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 27, 29, 24, 24, 24, 24, 24, 2, 3}, {1, 0, 24, 24, 24, 24, 28, 30, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 28, 30, 24, 24, 24, 24, 24, 2, 3}, {1, 0, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 26, 24, 24, 2, 3}, {23, 22, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 19, 18}, {21, 20, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 17, 16}}}, {kind = "combat", c = {{1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1}, {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1}, {1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1}, {1, 1, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1}, {1, 1, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1}, {1, 1, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1}, {1, 1, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1}, {1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 2}, {1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 2}, {1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1}, {1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 1, 1}, {1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 1, 1}, {1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1}, {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1}, {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1}}, v = {{11, 10, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 15, 14}, {9, 8, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 13, 12}, {1, 0, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 2, 3}, {1, 0, 24, 24, 27, 29, 36, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 37, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 2, 3}, {1, 0, 24, 24, 28, 30, 38, 31, 31, 31, 31, 33, 33, 33, 33, 33, 33, 39, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 2, 3}, {1, 0, 24, 24, 24, 24, 24, 35, 31, 31, 34, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 2, 3}, {1, 0, 24, 24, 24, 24, 24, 38, 33, 33, 39, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 25, 24, 24, 24, 2, 3}, {1, 0, 24, 26, 24, 25, 24, 24, 24, 24, 24, 24, 24, 24, 24, 25, 24, 24, 24, 24, 24, 24, 24, 24, 26, 24, 24, 24, 212, 213}, {1, 0, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 210, 211}, {1, 0, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 2, 3}, {1, 0, 24, 24, 24, 24, 24, 25, 24, 24, 24, 36, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 37, 24, 24, 24, 24, 2, 3}, {1, 0, 24, 24, 24, 24, 24, 24, 24, 24, 24, 38, 33, 33, 33, 33, 33, 33, 33, 33, 33, 33, 33, 39, 24, 24, 24, 24, 2, 3}, {1, 0, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 2, 3}, {23, 22, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 19, 18}, {21, 20, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 17, 16}}}, {kind = "combat", c = {{1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1}, {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1}, {1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1}, {1, 1, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 1, 1}, {1, 1, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 1, 1}, {1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1}, {1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1}, {1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 2}, {1, 1, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 2}, {1, 1, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1}, {1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 1, 1}, {1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 1, 1}, {1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1}, {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1}, {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1}}, v = {{11, 10, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 15, 14}, {9, 8, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 13, 12}, {1, 0, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 2, 3}, {1, 0, 24, 24, 27, 29, 24, 24, 24, 24, 24, 24, 24, 27, 29, 24, 24, 24, 24, 24, 24, 24, 27, 29, 24, 24, 24, 24, 2, 3}, {1, 0, 24, 24, 28, 30, 24, 24, 24, 24, 24, 24, 24, 28, 30, 24, 24, 24, 24, 24, 24, 24, 28, 30, 24, 24, 24, 24, 2, 3}, {1, 0, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 2, 3}, {1, 0, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 2, 3}, {1, 0, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 212, 213}, {1, 0, 24, 24, 24, 24, 24, 27, 29, 24, 24, 24, 24, 24, 24, 24, 24, 27, 29, 24, 24, 24, 24, 24, 24, 24, 24, 24, 210, 211}, {1, 0, 24, 24, 24, 24, 24, 28, 30, 24, 24, 24, 24, 24, 24, 24, 24, 28, 30, 24, 24, 24, 24, 24, 24, 24, 24, 24, 2, 3}, {1, 0, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 27, 29, 24, 24, 2, 3}, {1, 0, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 28, 30, 24, 24, 2, 3}, {1, 0, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 26, 24, 24, 24, 24, 24, 24, 2, 3}, {23, 22, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 19, 18}, {21, 20, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 17, 16}}}}
  local shop_map = {c = {{1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1}, {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1}, {1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1}, {1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1}, {1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1}, {1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1}, {1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1}, {1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 2}, {1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 2}, {1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1}, {1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1}, {1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1}, {1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1}, {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1}, {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1}}, v = {{11, 10, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 15, 14}, {9, 8, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 13, 12}, {1, 0, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 2, 3}, {1, 0, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 2, 3}, {1, 0, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 2, 3}, {1, 0, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 2, 3}, {1, 0, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 2, 3}, {1, 0, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 212, 213}, {1, 0, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 210, 211}, {1, 0, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 2, 3}, {1, 0, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 2, 3}, {1, 0, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 2, 3}, {1, 0, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 2, 3}, {23, 22, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 19, 18}, {21, 20, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 17, 16}}}
  local boss_map = {kind = "boss", c = {{1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1}, {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1}, {1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1}, {1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1}, {1, 1, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 1, 1}, {1, 1, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 1, 1}, {1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1}, {1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 2}, {1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 2}, {1, 1, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 1, 1}, {1, 1, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 1, 1}, {1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1}, {1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1}, {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1}, {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1}}, v = {{11, 10, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 15, 14}, {9, 8, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 13, 12}, {1, 0, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 2, 3}, {1, 0, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 2, 3}, {1, 0, 25, 25, 25, 25, 25, 27, 29, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 27, 29, 25, 25, 25, 25, 25, 2, 3}, {1, 0, 25, 25, 25, 25, 25, 28, 30, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 28, 30, 25, 25, 25, 25, 25, 2, 3}, {1, 0, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 2, 3}, {1, 0, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 212, 213}, {1, 0, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 210, 211}, {1, 0, 25, 25, 25, 25, 25, 27, 29, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 27, 29, 25, 25, 25, 25, 25, 2, 3}, {1, 0, 25, 25, 25, 25, 25, 28, 30, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 28, 30, 25, 25, 25, 25, 25, 2, 3}, {1, 0, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 2, 3}, {1, 0, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 2, 3}, {23, 22, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 19, 18}, {21, 20, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 17, 16}}}
  local map_v = {}
  local matrice_active = map_pool[1].c
  M["current-map-id"] = 1
  M["door-open"] = false
  M["current-map-kind"] = "combat"
  M["rooms-since-shop"] = 0
  M["load-boss-map"] = function()
    M["current-map-id"] = -2
    M["current-map-kind"] = "boss"
    M["door-open"] = false
    map_v = {}
    matrice_active = boss_map.c
    for _, ligne in ipairs(boss_map.v) do
      local new_ligne = {}
      for _0, id in ipairs(ligne) do
        table.insert(new_ligne, id)
      end
      table.insert(map_v, new_ligne)
    end
    return nil
  end
  M["load-map"] = function(map_id)
    M["current-map-id"] = map_id
    M["door-open"] = false
    map_v = {}
    local map_data = map_pool[map_id]
    M["current-map-kind"] = (map_data.kind or "combat")
    matrice_active = map_data.c
    for num_ligne, ligne in ipairs(map_data.v) do
      local new_ligne = {}
      for num_col, id in ipairs(ligne) do
        table.insert(new_ligne, id)
      end
      table.insert(map_v, new_ligne)
    end
    return nil
  end
  M["is-shop?"] = function()
    return (M["current-map-kind"] == "shop")
  end
  M["is-boss-room"] = function()
    return (M["current-map-kind"] == "boss")
  end
  M["load-random-map"] = function()
    local next_id = M["current-map-id"]
    if (#map_pool > 1) then
      while (next_id == M["current-map-id"]) do
        next_id = math.random(1, #map_pool)
      end
    else
      next_id = 1
    end
    return M["load-map"](next_id)
  end
  M["construire-map"] = function()
    M["rooms-since-shop"] = 0
    return M["load-random-map"]()
  end
  M["load-shop-map"] = function()
    M["current-map-id"] = -1
    M["current-map-kind"] = "shop"
    M["door-open"] = false
    map_v = {}
    matrice_active = shop_map.c
    for _, ligne in ipairs(shop_map.v) do
      local new_ligne = {}
      for _0, id in ipairs(ligne) do
        table.insert(new_ligne, id)
      end
      table.insert(map_v, new_ligne)
    end
    return nil
  end
  M["load-next-room"] = function()
    if M["is-shop?"]() then
      return M["load-boss-map"]()
    else
      if M["is-boss-room"]() then
        M["rooms-since-shop"] = 0
        return M["load-random-map"]()
      else
        M["rooms-since-shop"] = (M["rooms-since-shop"] + 1)
        if (M["rooms-since-shop"] >= 4) then
          return M["load-shop-map"]()
        else
          return M["load-random-map"]()
        end
      end
    end
  end
  M["open-door"] = function()
    M["door-open"] = true
    for lig, ligne in ipairs(matrice_active) do
      for col, val in ipairs(ligne) do
        if (val == 2) then
          map_v[lig][col] = 24
        else
        end
      end
    end
    return nil
  end
  local function walkable_rect_3f(x, y, size)
    return (not M["wall?"](x, y) and not M["wall?"]((x + (size - 1)), y) and not M["wall?"](x, (y + (size - 1))) and not M["wall?"]((x + (size - 1)), (y + (size - 1))))
  end
  local function find_safe_fallback_spawn(size)
    local found = nil
    for lig = 3, 13 do
      for col = 3, 27 do
        if not found then
          local x = ((col - 1) * 8)
          local y = (16 + ((lig - 1) * 8))
          if walkable_rect_3f(x, y, size) then
            found = {x = x, y = y}
          else
          end
        else
        end
      end
    end
    return (found or {x = 120, y = 72})
  end
  M["get-door-reward-spawn"] = function(size)
    local sum_col = 0
    local sum_lig = 0
    local count = 0
    for lig, ligne in ipairs(matrice_active) do
      for col, valeur in ipairs(ligne) do
        if (valeur == 2) then
          sum_col = (sum_col + col)
          sum_lig = (sum_lig + lig)
          count = (count + 1)
        else
        end
      end
    end
    if (count > 0) then
      local door_col = (sum_col // count)
      local door_lig = (sum_lig / count)
      local door_center_y = (16 + ((door_lig - 1) * 8) + 4)
      local base_y = math.floor((door_center_y - (size / 2)))
      local base_x = ((door_col - 2) * 8)
      local candidates = {{x = base_x, y = base_y}, {x = (base_x - 8), y = base_y}, {x = (base_x - 16), y = base_y}, {x = base_x, y = (base_y - 8)}, {x = base_x, y = (base_y + 8)}}
      local fallback = find_safe_fallback_spawn(size)
      local chosen = nil
      for _, candidate in ipairs(candidates) do
        if (not chosen and walkable_rect_3f(candidate.x, candidate.y, size)) then
          chosen = candidate
        else
        end
      end
      return (chosen or fallback)
    else
      return find_safe_fallback_spawn(size)
    end
  end
  M["get-random-spawn"] = function(size, avoid_x, avoid_y, min_dist)
    local found = nil
    local attempts = 0
    local md_sq
    if min_dist then
      md_sq = (min_dist * min_dist)
    else
      md_sq = 1600
    end
    while (not found and (attempts < 50)) do
      do
        local x = math.random(16, 224)
        local y = math.random(32, 120)
        local dist_ok = true
        if (avoid_x and avoid_y) then
          local dx = (x - avoid_x)
          local dy = (y - avoid_y)
          local d_sq = ((dx * dx) + (dy * dy))
          if (d_sq < md_sq) then
            dist_ok = false
          else
          end
        else
        end
        if (dist_ok and walkable_rect_3f(x, y, size)) then
          found = {x = x, y = y}
        else
        end
      end
      attempts = (attempts + 1)
    end
    return (found or find_safe_fallback_spawn(size))
  end
  M["init-assets"] = function()
    poke(16320, 68)
    poke(16321, 36)
    poke(16322, 52)
    poke(16323, 20)
    poke(16324, 12)
    poke(16325, 28)
    poke(16326, 133)
    poke(16327, 76)
    poke(16328, 48)
    poke(16329, 210)
    poke(16330, 125)
    poke(16331, 44)
    poke(16332, 41)
    poke(16333, 170)
    poke(16334, 254)
    poke(16335, 93)
    poke(16336, 81)
    poke(16337, 72)
    poke(16338, 252)
    poke(16339, 241)
    poke(16340, 236)
    poke(16341, 255)
    poke(16342, 202)
    poke(16343, 171)
    poke(16344, 222)
    poke(16345, 125)
    poke(16346, 59)
    poke(16347, 247)
    poke(16348, 229)
    poke(16349, 120)
    poke(16350, 235)
    poke(16351, 176)
    poke(16352, 80)
    poke(16353, 177)
    poke(16354, 62)
    poke(16355, 83)
    poke(16356, 112)
    poke(16357, 19)
    poke(16358, 39)
    poke(16359, 252)
    poke(16360, 13)
    poke(16361, 65)
    poke(16362, 61)
    poke(16363, 6)
    poke(16364, 18)
    poke(16365, 222)
    poke(16366, 238)
    poke(16367, 214)
    M["design-spr"](0, "0010010100100110001001011110011000100101001111100010010100100110")
    M["design-spr"](1, "0312201203122012031220120321111103122012031220120312201203122012")
    M["design-spr"](2, "0110010010100100011111001010010001100111101001000110010010100100")
    M["design-spr"](3, "2102213021022130210221302102213011111230210221302102213021022130")
    M["design-spr"](4, "0000100000001000111111110010000000100000111111111010101001010101")
    M["design-spr"](5, "0000000033333333111121112222122222221222000010001111111122221222")
    M["design-spr"](6, "1010101001010101111111110000010000000100111111110001000000010000")
    M["design-spr"](7, "2221222211111111000100002221222222212222111211113333333300000000")
    M["design-spr"](8, "2100000012100000012111110010100000110100001010110010010100100110")
    M["design-spr"](9, "0321111103122012031220120312201203122012031220120312201203122012")
    M["design-spr"](10, "0000000033333333211111111222222212222222100000001111111112222222")
    M["design-spr"](11, "3330000032233333322111110312322203133122031213000312203103122013")
    M["design-spr"](12, "1111123021022130210221302102213021022130210221302102213021022130")
    M["design-spr"](13, "0000001200000121111112100001010000101100110101001010010001100100")
    M["design-spr"](14, "0000033333333223111112232223213022133130003121301302213031022130")
    M["design-spr"](15, "0000000033333333111111122222222122222221000000011111111122222221")
    M["design-spr"](16, "3102213013022130003121302213313022232130111112233333322300000333")
    M["design-spr"](17, "2222222111111111000000012222222122222221111111123333333300000000")
    M["design-spr"](18, "2102213021022130210221302102213021022130210221302102213011111230")
    M["design-spr"](19, "0110010010100100110101000010110000010100111112100000012100000012")
    M["design-spr"](20, "1222222211111111100000001222222212222222211111113333333300000000")
    M["design-spr"](21, "0312201303122031031213000313312203123222322111113223333333300000")
    M["design-spr"](22, "0010011000100101001010110011010000101000012111111210000021000000")
    M["design-spr"](23, "0312201203122012031220120312201203122012031220120312201203211111")
    M["design-spr"](24, "0000000000000000000000000000000000000000000000000000000000000000")
    M["design-spr"](25, "0000000000001110010000000100000001000000010000100000001000000000")
    M["design-spr"](26, "0000000000010110000000010100000100000011011111110011111000000000")
    M["design-spr"](27, "0000000000000000000000110000113300113333001333330010333200100022")
    M["design-spr"](28, "0132222213332222113333321112222211022222110022221110022101112211")
    M["design-spr"](29, "0000000000000000111100003333100033332100333221002222210022222100")
    M["design-spr"](30, "2223331022333331222223110000211100022221002222011022001111201111")
    M["design-spr"](31, "1111111111111111111111111111111111111111111111111111111111111111")
    M["design-spr"](32, "0022220022000022001111001120001112111102111101111001101111111111")
    M["design-spr"](33, "1111111111111111111111111111111111111111111111111122211122000222")
    M["design-spr"](34, "1111112011111120111111121111111211111112111111121111112011111120")
    M["design-spr"](35, "0211111102111111211111112111111121111111211111110211111102111111")
    M["design-spr"](36, "0000222200220000002111110201121202011212210110112111111121111010")
    M["design-spr"](37, "2222000000002200111112002121102021211020110110121111111201011112")
    M["design-spr"](38, "2111111121111111211111110211111102111111002111110022111100002222")
    M["design-spr"](39, "1111111211111112111111121111111211111120111112201112200022200000")
    M["design-spr"](40, "0000000200000002000000020000002100000021000022000002211222200121")
    M["design-spr"](41, "2000000020000000200000001200000012000000002200002112200012100222")
    M["design-spr"](42, "2221111100022111000022110000002100000021000000020000000200000002")
    M["design-spr"](43, "1111122211122000112200001200000012000000200000002000000020000000")
    M["design-spr"](44, "1111111100000000000000000000000000000000000000000000000000000000")
    M["design-spr"](45, "2222222210000001100000011111111111111111100000011000000101111110")
    M["design-spr"](100, "F000000F055555500557777005747740F0777770F066560F07655570F066560F")
    M["design-spr"](101, "FFFFFFFFF000000F055555500557777005747740F077777007655570F066560F")
    M["design-spr"](102, "F000000F055555500557777005747740F07777700766560FF0655570F066500F")
    M["design-spr"](103, "FFFFFFFFF000000F055555500557777005747740F0777770F065550FF066560F")
    M["design-spr"](104, "F000000F055555500557777005747740F0777770F06656700765550FF006560F")
    M["design-spr"](105, "F000000F0555555007777550047747500777770FF06566700755560FF005660F")
    M["design-spr"](106, "FFFFFFFFF000000F0555555007777550047747500777770FF055560FF065660F")
    M["design-spr"](107, "F000000F0555555007777550047747500777770F0765660FF0555670F065600F")
    M["design-spr"](108, "F000000F0555555005555550055555500755570FF06666700766660FF006660F")
    M["design-spr"](109, "FFFFFFFFF000000F055555500555555005555550F075570FF066660FF066660F")
    M["design-spr"](110, "F000000F055555500555555005555550F075557F0766660FF0666670F066660F")
    M["design-spr"](111, "FF1111FFF1CCCC1F1CC7C7C11BC7C7B11BBBCBB11B1BBBB111F1B1B1FFFF1F1F")
    M["design-spr"](112, "FFFFFFFFFF1111FFF1CCCC1F1CC7C7C11CB7C7C11BBBBBB11B1BBBB1F1F1B1BF")
    M["design-spr"](113, "FFFFFFFFFF1111FFF1CCCC1F1CCC7C711CBB7B711BBBBBB1BB1BBBB1111B1B1F")
    M["design-spr"](114, "FF1111FFF1CCCC1F1CCC7C711CBC7C711CBBBBB11BBBBBB11B1B1BB1F1F1F11F")
    M["design-spr"](115, "FF1111FFF1CCCC1F1CCCCCC11CBC7C711CBB7B711CBBBBB11B1B1B1FF1F1F1FF")
    M["design-spr"](116, "FFFFFFFFFF1111FFF1CCCC1F17C7CCC117B7BBC11BBBBBB11BBBB1BBF1B1B111")
    M["design-spr"](117, "FF1111FFF1CCCC1F17C7CCC117C7CBC11BBBBBC11BBBBBB11BB1B1B1F11F1F1F")
    M["design-spr"](118, "FF1111FFF1CCCC1F1CCCCCC117C7CBC117B7BBC11BBBBBC1F1B1B1B1FF1F1F1F")
    M["design-spr"](119, "FF1111FFF1CCCC1F1CCCCCC11BCCCCB11BBBCBB11B1BBBB111F1B1B1FFFF1F1F")
    M["design-spr"](120, "FFFFFFFFFF1111FFF1CCCC1F1CCCCCC11CBCCCC11BBBCBB11B1BBBB1F1F1B1BF")
    M["design-spr"](121, "FFFF1111FF11CEBBF1B3BCE1F1B3331C1CCB133C1BBC1CDC1BBB1CCCF1C1B11C")
    M["design-spr"](122, "1111FFFFBBEC11FF1ECB3B1FC1333B1FC331BCC1CDC1CBB1CCC1BBB1C11B1C1F")
    M["design-spr"](123, "1CC11EE11CCC1EEE1CCCB1EEF1BBDD1EFF1DD1E1F11D1E1FF1B1B1FFF1CCC1FF")
    M["design-spr"](124, "1EE11CC1EEE1CCC1EE1BCCC1E1DDBB1F1E1DD1FFF1E1D11FFF1B1B1FFF1CCC1F")
    M["design-spr"](125, "FFFFFFFFFFFF1111FF11BCEBF1B3BBC1F1C3331C1BBC133C1BBB1CDCF1C11CCC")
    M["design-spr"](126, "FFFFFFFF1111FFFFBECB11FF1CBB3B1FC1333C1FC331CBB1CDC1BBB1CCC11C1F")
    M["design-spr"](127, "1CCC111C1CCCC1E1F1CCBD1EFF1BDD1EFF1BD1E1F1111E1FF1B1B1FFF1CCCC1F")
    M["design-spr"](128, "C111CCC11E1CCCC1E1DBCC1FE1DDB1FF1E111FFFF1E1D1FFFF1B1B1FF1CCC1FF")
    M["design-spr"](129, "FFFF1111FF11CEBBF1BBBCEBF1B3BBC11CC3331C1BBC133C1BBB1CDCF1C11CCC")
    M["design-spr"](130, "1111FFFFBBEC11FFBECBBB1F1CBB3B1FC1333CC1C331CBB1CDC1BBB1CCC11C1F")
    M["design-spr"](131, "1CCC111C1CCCC1E1F1CCBD1EFF1BDD1EFF1BD1E1F1111E1FF1B1B1FFF1CCCC1F")
    M["design-spr"](132, "C111CCC11E1CCCC1E1DBCC1FE1DDB1FF1E111FFFF1E1D1FFFF1B1B1FF1CCC1FF")
    M["design-spr"](133, "FFFFFF11FFFFF1BBFFFF1BC3FFFF1CBBFFF1BBBBFFF1CBBBFF1BCBBBFF1CBCC1")
    M["design-spr"](134, "1FFFFFFFBCFFFFFF3B11FFFF333C1FFFB133C1FF1CCDC1FF1CCCC1FFC11111FF")
    M["design-spr"](135, "FF1CCBBBFFF1CCCCFFF1CCCCFFF1CCCCFFFF1CCCFFFF111DFFF1BBB1FF1CCCCC")
    M["design-spr"](136, "1EEE1C1F1EE1CCD1C1E1CD1FCD1F11FFDD11FFFFD1BB1FFF1F1BB1FF1F1CC1CF")
    M["design-spr"](137, "FFFFFF11FFFFF1B3FFFF1BCBFFFF1CBBFF11BBBBFF11CBBBF11BCBBBF11CBCC1")
    M["design-spr"](138, "1FFFFFFF3C11FFFFB3311FFFBB3311FFB1BDC1FF1CCCC1FF111111FFEEEEE1FF")
    M["design-spr"](139, "1CCCCB1ECCCCC11EDCCC1F1E1DD1FF11F1FFF1BBFFFF1CBBFFFFF1CBFFFFF1C1")
    M["design-spr"](140, "EEEE1FFFEEE1D1FFEEE1D1FFEE1F1FFFCB1FFFFF1B1FFFFF1BB1FFFFCCC1FFFF")
    M["design-spr"](141, "FFFFFF11FFFFF1BBFFFF1BC3FFFF1CBBFFF1BBBBFFF1CBBBFF1BCBBBFF1CBCC1")
    M["design-spr"](142, "1FFFFFFFBCFFFFFF3B11FFFF333C1FFFB133C1FF1CCDC1FF1CCCC1FFC11111FF")
    M["design-spr"](143, "FF1CCBB1FFF1CCC1FFF1CCC1FFF1CC11FFF1DCD1FFFF1D1DFFFF1BB1FFF1CCCC")
    M["design-spr"](144, "EEEE1C1FEEE1CCD1EEE1CD1FEE1F11FFBBB1FFFF1BBB1FFF11BBB1FF11CCC1FF")
    M["design-spr"](145, "FFFFFFF1FFFFFFCBFFFF11B3FFF1C333FF1C331BFF1CDCC1FF1CCCC1FF11111C")
    M["design-spr"](146, "11FFFFFFBB1FFFFF3CB1FFFFBBC1FFFFBBBB1FFFBBBC1FFFBBBCB1FF1CCBC1FF")
    M["design-spr"](147, "F1C1EEE11DCC1EE1F1DC1E1CFF11F1DCFFFF11DDFFF1BB1DFF1BB1F1FC1CC1F1")
    M["design-spr"](148, "BBBCC1FFCCCC1FFFCCCC1FFFCCCC1FFFCCC1FFFFD111FFFF1BBB1FFFCCCCC1FF")
    M["design-spr"](149, "FFFFFFF1FFFF11C3FFF1133BFF1133BBFF1CDB1BFF1CCCC1FF111111FF1EEEEE")
    M["design-spr"](150, "11FFFFFF3B1FFFFFBCB1FFFFBBC1FFFFBBBB11FFBBBC11FFBBBCB11F1CCBC11F")
    M["design-spr"](151, "FFF1EEEEFF1D1EEEFF1D1EEEFFF1F1EEFFFFF1BCFFFFF1B1FFFF1BB1FFFF1CCC")
    M["design-spr"](152, "E1BCCCC1E11CCCCCE1F1CCCD11FF1DD1BB1FFF1FBBC1FFFFBC1FFFFF1C1FFFFF")
    M["design-spr"](153, "FFFFFFF1FFFFFFCBFFFF11B3FFF1C333FF1C331BFF1CDCC1FF1CCCC1FF11111C")
    M["design-spr"](154, "11FFFFFFBB1FFFFF3CB1FFFFBBC1FFFFBBBB1FFFBBBC1FFFBBBCB1FF1CCBC1FF")
    M["design-spr"](155, "F1C1EEEE1DCC1EEEF1DC1EEEFF11F1EEFFFF1BBBFFF1BBB1FF1BBB11FF1CCC11")
    M["design-spr"](156, "1BBCC1FF1CCC1FFF1CCC1FFF11CC1FFF1DCD1FFFD1D1FFFF1BB1FFFFCCCC1FFF")
    M["design-spr"](157, "FFFF1111FF11CEBBF1B3BCE1F1B3331C1CCB133C1BBC1CDC1BBB1CCCF1C1B11C")
    M["design-spr"](158, "1111FFFFBBEC11FF1ECB3B1FC1333B1FC331BCC1CDC1CBB1CCC1BBB1C11B1C1F")
    M["design-spr"](159, "1CC11EE11CCC1EEE1CCCB1EEF1BBDD1EFF1DD1E1F11D1E1FF1B1B1FFF1CCC1FF")
    M["design-spr"](160, "1EE11CC1EEE1CCC1EE1BCCC1E1DDBB1F1E1DD1FFF1E1D11FFF1B1B1FFF1CCC1F")
    M["design-spr"](161, "FFFFFF11FFF111BBFF1BBCE1F1B3331CF1CB133C1BBC1CDC1BBB1CCCF1C1B11C")
    M["design-spr"](162, "11FFFFFFBB111FFF1ECBB1FFC1333B1FC331BC1FCDC1CBB1CCC1BBB1C11B1C1F")
    M["design-spr"](163, "1CC11EE11CCC11EE1CCCBD1EF1CDD1BEF1D11BE1FF1CCC1FFF1111FFFFFFFFFF")
    M["design-spr"](164, "1EE11CC1EEE1CCC1EE1BCCC1E1DDBB1F1E1DD1FFF1E1D11FFF1B1B1FFF1CCC1F")
    M["design-spr"](165, "FFFF1111FF11CEBBF1B3BCE1F1B3331C1CCB133C1BBC1CDC1BBB1CCCF1C1B11C")
    M["design-spr"](166, "1111FFFFBBEC11FF1ECB3B1FC1333B1FC331BCC1CDC1CBB1CCC1BBB1C11B1C1F")
    M["design-spr"](167, "1CC11EE11CCC1EEE1CCCB1EEF1BBDD1EFF1DD1E1F11D1E1FF1B1B1FFF1CCC1FF")
    M["design-spr"](168, "1EE11CC1EE11CCC1E1DBCCC1EB1DDC1F1EB11D1FF1CCC1FFFF1111FFFFFFFFFF")
    M["design-spr"](169, "FFFF1111FF11CEBBF1B3BCE1F1B3331C1CCB133C1BBC1CDC1BBB1CCCF1C1B11C")
    M["design-spr"](170, "1111FFFFBBEC11FF1ECB3B1FC1333B1FC331BCC1CDC1CBB1CCC1BBB1C11B1C1F")
    M["design-spr"](171, "1CC11EE11DCDD1EE1DDD1EEEF111CCCEFF1CCCC1F11CCC1FF1BBB1FFF1CCC1FF")
    M["design-spr"](172, "1EE11CC1EE1DDCD1EEE1DDD1ECCC111F1CCCC1FFF1CCC11FFF1BBB1FFF1CCC1F")
    M["design-spr"](173, "FFFF1111FF11CEBBF1B3BCE1FDBDD31C1DDD133C1CCC1CDC1BCC1CCCF1C1B11C")
    M["design-spr"](174, "1111FFFFBBEC11FF1ECB3B1FC13DDBDFC331DDD1CDC1CCC1CCC1CCB1C11B1C1F")
    M["design-spr"](175, "F1CC1EE1FF11F1EEFFFF1EEEFF11CCCEFF1CCCC1F11CCC1FF1BBB1FFF1CCC1FF")
    M["design-spr"](176, "1EE1CC1FEE1F11FFEEE1FFFFECCC11FF1CCCC1FFF1CCC11FFF1BBB1FFF1CCC1F")
    M["design-spr"](177, "FFFFFFFFF9FF9FFFF999F111FF991BBBFF19ABB1F1BC9A1C1BBB1AAC11C11CDC")
    M["design-spr"](178, "FFFFFFFFFFF9FF9F111F999FBB1199FF1BBA91FFC1A9CB1FCAA1BBB1CDC11C11")
    M["design-spr"](179, "1CC11CCC1CCC111C1CCCB1E1FDBBBB1EDD1BBBE1FDDBBD1FF11DBD1FF1DDDDD1")
    M["design-spr"](180, "CCC11CC1C111CCC11E1BCC11E1BBBB1D1EDBB1DDF1DBBDDFF11BDD1F1DDDDD1F")
    M["design-spr"](181, "FFF1FFFFF11211FF1222221F1242431F1336331F1366631FF13331FFFF111FFF")
    M["design-spr"](182, "F11211FF1222221F1242421F1336331F1366631F1333331FF13131FFFF1F1FFF")
    M["design-spr"](183, "FF1121FFFF12231FF122241F1224331F1233361F1333661FF13131FFFF1F1FFF")
    M["design-spr"](184, "FFFFFFFFFF1211FFF122221F1222341F1234331F1333361F1333661FF13131FF")
    M["design-spr"](186, "FF1211FFF13221FFF142221FF1334221F1633321F1663331FF13131FFFF1F1FF")
    M["design-spr"](187, "FFFFFFFFFF1121FFF122221FF1432221F1334321F1633331F1663331FF13131F")
    M["design-spr"](189, "FF1211FFF13221FFF142221FF1334221F1633321F1663331FF13131FFFF1F1FF")
    M["design-spr"](190, "FFFFFFFFFF1121FFF122221FF1432221F1334321F1633331F1663331FF13131F")
    M["design-spr"](191, "FFF11FFFF112211F122222211C9229C11C2882C11CC22CC1F11CC11FFFF11FFF")
    M["design-spr"](192, "FFF11FFF1112211FF1222221FF122991FF1C2281F1CCC8C1111CC11FFFF11FFF")
    M["design-spr"](193, "FFF11FFFFF12211FF122222112222991122C2281F1CCC8C1FF1CC11FFFF11FFF")
    M["design-spr"](195, "FFF11FFFF11221111222221F199221FF1822C1FF1C8CCC1FF11CC111FFF11FFF")
    M["design-spr"](196, "FFF11FFFF11221FF1222221F199222211822C2211C8CCC1FF11CC1FFFFF11FFF")
    M["design-spr"](198, "FFF11FFFF11221111222221F199221FF1822C1FF1C8CCC1FF11CC111FFF11FFF")
    M["design-spr"](199, "FFF11FFFF11221FF1222221F199222211822C2211C8CCC1FF11CC1FFFFF11FFF")
    M["design-spr"](200, "FFFFFFFFF88888FF8AAAAA8FFF8A99A88A9999A8888AAA8FFFF888FFFFFFFFFF")
    M["design-spr"](201, "FFFFFFFFFFF888FF888AAA8F8A9999A8FF8A99A88AAAAA8FF88888FFFFFFFFFF")
    M["design-spr"](202, "FFFFFFFFFFF888FF8F8AAA8FF89999A88AAA99A8F8AAAA8FFF8888FFFFFFFFFF")
    M["design-spr"](203, "FFFFFF66FFFFF667FFFF667F9AF667FFF9667FFFF227FFFF1229AFFF91FF9FFF")
    M["design-spr"](204, "FFFF99FFFFF996FFFF996FFFF999FFFFF99999FFFFF996FFFF996FFFF99FFFFF")
    M["design-spr"](205, "FFFFFFFFFFF444FFFF44446FFFFFF46F4446F44FF446F4FFFF44FFFFFFF4FFFF")
    M["design-spr"](206, "FF1111FFF199991F19996991199966911999669119996991F199991FFF1111FF")
    M["design-spr"](207, "FFF22FFFFF6226FFFFF66FFFFF6666FFF6FFFF6F6BBBBBB66BBBBBB6F666666F")
    M["design-spr"](208, "FFFF111FF111BB511667BB5117674B51156777B1155777B1156747511711111F")
    M["design-spr"](209, "FFFFFFFF1111111112255221152552511255552111222211F112211FFF1111FF")
    M["design-spr"](210, "EEEE9E29EEE2299255555555EEEEE222E222222255555555EEEEE22211111111")
    M["design-spr"](211, "22222E1F22EEEE1F5555551F2222E13F2222113F5551113F1112213F2102213F")
    M["design-spr"](212, "11111111EEEEE22255555555E2222222EEEEE22255555555EEE22992EEEE9E29")
    M["design-spr"](213, "2102213F1112213F5551113F2222113F2222E13F5555551F22EEEE1F22222E1F")
    math.randomseed(tstamp())
    return M["construire-map"]()
  end
  M["wall?"] = function(x, y)
    if (y < 16) then
      return true
    else
      local col = ((x // 8) + 1)
      local lig = (((y - 16) // 8) + 1)
      local ligne = matrice_active[lig]
      local valeur
      if ligne then
        valeur = (ligne[col] or 1)
      else
        valeur = 1
      end
      if (valeur == 2) then
        return not M["door-open"]
      else
        return (valeur == 1)
      end
    end
  end
  M["can-move?"] = function(x, y, size)
    return not (M["wall?"](x, y) or M["wall?"]((x + (size - 1)), y) or M["wall?"](x, (y + (size - 1))) or M["wall?"]((x + (size - 1)), (y + (size - 1))))
  end
  M["collide?"] = function(x1, y1, s1, x2, y2, s2)
    return ((x1 < (x2 + s2)) and ((x1 + s1) > x2) and (y1 < (y2 + s2)) and ((y1 + s1) > y2))
  end
  M["is-door?"] = function(x, y, size)
    local cx = (x + (size / 2))
    local cy = (y + (size / 2))
    local col = ((cx // 8) + 1)
    local lig = (((cy - 16) // 8) + 1)
    local ligne = matrice_active[lig]
    if (ligne and ligne[col]) then
      return ((ligne[col] == 2) and M["door-open"])
    else
      return false
    end
  end
  M.draw = function()
    for num_ligne, ligne in ipairs(map_v) do
      for num_col, id in ipairs(ligne) do
        spr(id, ((num_col - 1) * 8), (16 + ((num_ligne - 1) * 8)), 15)
      end
    end
    return nil
  end
  return M
end
world = require("world")
local enemie
package.preload["enemie"] = package.preload["enemie"] or function(...)
  local enemie = {}
  local astar = require("astar")
  local abilities = require("abilities")
  local LASER_SPRITE_ID = 10
  local KAMIKAZE_SPRITE_ID = 10
  local LASER_RANGE = 96
  local LASER_WINDUP = 48
  local LASER_COOLDOWN = 70
  local LASER_DAMAGE = 1
  local KAMIKAZE_TRIGGER_DIST = 15
  local KAMIKAZE_ARMING_TIME = 34
  local KAMIKAZE_EXPLOSION_RADIUS = 40
  local KAMIKAZE_EXPLOSION_DAMAGE = 4
  local KAMIKAZE_EXPLOSION_FLASH = 8
  local HURT_FLASH_DURATION = 8
  local SWORD_KNOCKBACK_DURATION = 7
  local SWORD_KNOCKBACK_FRICTION = 0.72
  local function center_x(e)
    return (e.x + (e.size / 2))
  end
  local function center_y(e)
    return (e.y + (e.size / 2))
  end
  local function normalize(dx, dy)
    local len = math.sqrt(((dx * dx) + (dy * dy)))
    if (len > 0.001) then
      return {(dx / len), (dy / len)}
    else
      return {1, 0}
    end
  end
  local function point_in_player_3f(px, py, joueur)
    return ((px >= joueur.x) and (px < (joueur.x + joueur.size)) and (py >= joueur.y) and (py < (joueur.y + joueur.size)))
  end
  local function trace_laser(sx, sy, dx, dy, world, joueur)
    local end_x = sx
    local end_y = sy
    local hit_player = false
    local step = 1
    local done = false
    while ((step <= LASER_RANGE) and not done) do
      do
        local px = (sx + (dx * step))
        local py = (sy + (dy * step))
        if world["wall?"](px, py) then
          done = true
        else
          end_x = px
          end_y = py
          if (joueur and point_in_player_3f(px, py, joueur)) then
            hit_player = true
          else
          end
        end
      end
      step = (step + 1)
    end
    return {end_x, end_y, hit_player}
  end
  local function process_dot(e)
    if (e["dot-timer"] > 0) then
      e["dot-timer"] = (e["dot-timer"] - 1)
      e["dot-tick"] = (e["dot-tick"] + 1)
      if (e["dot-tick"] >= 60) then
        e["dot-tick"] = 0
        e.hp = (e.hp - e["dot-dmg"])
        e["hurt-timer"] = HURT_FLASH_DURATION
      else
      end
      if (e["dot-timer"] <= 0) then
        e["dot-dmg"] = 0
        e["dot-tick"] = 0
        return nil
      else
        return nil
      end
    else
      return nil
    end
  end
  local function process_stun(e)
    if (e["stun-timer"] > 0) then
      e["stun-timer"] = (e["stun-timer"] - 1)
      return nil
    else
      return nil
    end
  end
  local function tick_attack_cooldown(e)
    if (e["attack-timer"] > 0) then
      e["attack-timer"] = (e["attack-timer"] - 1)
      return nil
    else
      return nil
    end
  end
  local function ensure_path_state(e)
    if not e.path then
      e.path = {}
    else
    end
    if not e["path-timer"] then
      e["path-timer"] = 0
      return nil
    else
      return nil
    end
  end
  local function apply_knockback_motion(e, world, enemies, joueur)
    if (e["knockback-timer"] > 0) then
      e["knockback-timer"] = (e["knockback-timer"] - 1)
      do
        local nx = (e.x + e["knockback-vx"])
        local ny = (e.y + e["knockback-vy"])
        if (world["can-move?"](nx, e.y, e.size) and not world["collide?"](nx, e.y, e.size, joueur.x, joueur.y, joueur.size)) then
          e.x = nx
        else
        end
        if (world["can-move?"](e.x, ny, e.size) and not world["collide?"](e.x, ny, e.size, joueur.x, joueur.y, joueur.size)) then
          e.y = ny
        else
        end
      end
      e["knockback-vx"] = (e["knockback-vx"] * SWORD_KNOCKBACK_FRICTION)
      e["knockback-vy"] = (e["knockback-vy"] * SWORD_KNOCKBACK_FRICTION)
      return nil
    else
      return nil
    end
  end
  local function move_with_path(e, joueur, world, enemies)
    ensure_path_state(e)
    e["path-timer"] = (e["path-timer"] - 1)
    if (e["path-timer"] <= 0) then
      local custom_walkable_fn
      local function _204_(px, py)
        local valid = world["can-move?"](px, py, e.size)
        if valid then
          for _, other in ipairs(enemies) do
            if ((other ~= e) and world["collide?"](px, py, e.size, other.x, other.y, other.size)) then
              valid = false
            else
            end
          end
        else
        end
        return valid
      end
      custom_walkable_fn = _204_
      e.path = astar["find-path"](e.x, e.y, joueur.x, joueur.y, custom_walkable_fn)
      e["path-timer"] = (60 + math.random(0, 10))
    else
    end
    local dx = 0
    local dy = 0
    if (#e.path > 0) then
      local target = e.path[1]
      local tx = target[1]
      local ty = target[2]
      local diff_x = (tx - e.x)
      local diff_y = (ty - e.y)
      local dist = math.sqrt(((diff_x * diff_x) + (diff_y * diff_y)))
      if (dist <= e.speed) then
        e.x = tx
        e.y = ty
        table.remove(e.path, 1)
      else
        dx = (diff_x / dist)
        dy = (diff_y / dist)
      end
    else
    end
    local function hit_other_enemie_3f(nx, ny)
      local hit = false
      do
        local soft_size = (e.size - 2)
        for _, other in ipairs(enemies) do
          if ((other ~= e) and world["collide?"]((nx + 1), (ny + 1), soft_size, other.x, other.y, other.size)) then
            hit = true
          else
          end
        end
      end
      return hit
    end
    local nx = (e.x + (dx * e.speed))
    local ny = (e.y + (dy * e.speed))
    if ((dx ~= 0) and world["can-move?"](nx, e.y, e.size) and not world["collide?"](nx, e.y, e.size, joueur.x, joueur.y, joueur.size) and not hit_other_enemie_3f(nx, e.y)) then
      e.x = nx
    else
    end
    if ((dy ~= 0) and world["can-move?"](e.x, ny, e.size) and not world["collide?"](e.x, ny, e.size, joueur.x, joueur.y, joueur.size) and not hit_other_enemie_3f(e.x, ny)) then
      e.y = ny
      return nil
    else
      return nil
    end
  end
  local function update_grunt(e, joueur, world, enemies, _)
    local prev_x = e.x
    local prev_y = e.y
    move_with_path(e, joueur, world, enemies)
    local dx = (e.x - prev_x)
    local dy = (e.y - prev_y)
    local moving_3f = ((dx ~= 0) or (dy ~= 0))
    e["moving?"] = moving_3f
    if moving_3f then
      if (dx > 0) then
        e.direction = "right"
      elseif (dx < 0) then
        e.direction = "left"
      elseif (dy > 0) then
        e.direction = "down"
      elseif (dy < 0) then
        e.direction = "up"
      else
      end
    else
    end
    e["anim-timer"] = ((e["anim-timer"] or 0) + 1)
    if moving_3f then
      if (e["anim-timer"] > 8) then
        e["anim-timer"] = 0
        e["anim-frame"] = (e["anim-frame"] + 1)
        if (e["anim-frame"] > 3) then
          e["anim-frame"] = 1
          return nil
        else
          return nil
        end
      else
        return nil
      end
    else
      if (e["anim-timer"] > 20) then
        e["anim-timer"] = 0
        e["anim-frame"] = (e["anim-frame"] + 1)
        if (e["anim-frame"] > 2) then
          e["anim-frame"] = 1
          return nil
        else
          return nil
        end
      else
        return nil
      end
    end
  end
  local function begin_laser_windup(e, joueur, world)
    local dx = ((joueur.x + (joueur.size / 2)) - center_x(e))
    local dy = ((joueur.y + (joueur.size / 2)) - center_y(e))
    local _let_220_ = normalize(dx, dy)
    local nx = _let_220_[1]
    local ny = _let_220_[2]
    local sx = center_x(e)
    local sy = center_y(e)
    local _let_221_ = trace_laser(sx, sy, nx, ny, world, nil)
    local end_x = _let_221_[1]
    local end_y = _let_221_[2]
    local _ = _let_221_[3]
    e["laser-dir-x"] = nx
    e["laser-dir-y"] = ny
    e["laser-windup"] = LASER_WINDUP
    e["laser-end-x"] = end_x
    e["laser-end-y"] = end_y
    e.path = {}
    return nil
  end
  local function fire_laser(e, joueur, world, take_damage)
    local sx = center_x(e)
    local sy = center_y(e)
    local _let_222_ = trace_laser(sx, sy, e["laser-dir-x"], e["laser-dir-y"], world, joueur)
    local end_x = _let_222_[1]
    local end_y = _let_222_[2]
    local hit_player = _let_222_[3]
    e["laser-end-x"] = end_x
    e["laser-end-y"] = end_y
    e["laser-flash"] = 6
    if hit_player then
      return take_damage(joueur, LASER_DAMAGE, sx, sy)
    else
      return nil
    end
  end
  local function track_movement(e, prev_x, prev_y)
    local dx = (e.x - prev_x)
    local dy = (e.y - prev_y)
    local moving_3f = ((dx ~= 0) or (dy ~= 0))
    e["moving?"] = moving_3f
    if moving_3f then
      if (math.abs(dx) > math.abs(dy)) then
        if (dx > 0) then
          e.direction = "right"
          return nil
        else
          e.direction = "left"
          return nil
        end
      elseif (dy > 0) then
        e.direction = "down"
        return nil
      elseif (dy < 0) then
        e.direction = "up"
        return nil
      else
        return nil
      end
    else
      return nil
    end
  end
  local function tick_anim_2(e)
    e["anim-timer"] = ((e["anim-timer"] or 0) + 1)
    local threshold
    if e["moving?"] then
      threshold = 8
    else
      threshold = 20
    end
    if (e["anim-timer"] > threshold) then
      e["anim-timer"] = 0
      if (e["anim-frame"] == 1) then
        e["anim-frame"] = 2
      else
        e["anim-frame"] = 1
      end
      return nil
    else
      return nil
    end
  end
  local function update_laser(e, joueur, world, enemies, take_damage)
    if (e["laser-flash"] > 0) then
      e["laser-flash"] = (e["laser-flash"] - 1)
    else
    end
    do
      local prev_x = e.x
      local prev_y = e.y
      if (e["laser-windup"] > 0) then
        e["moving?"] = false
        if (math.abs(e["laser-dir-x"]) > math.abs(e["laser-dir-y"])) then
          if (e["laser-dir-x"] > 0) then
            e.direction = "right"
          else
            e.direction = "left"
          end
        elseif (e["laser-dir-y"] > 0) then
          e.direction = "down"
        elseif (e["laser-dir-y"] < 0) then
          e.direction = "up"
        else
        end
        e["laser-windup"] = (e["laser-windup"] - 1)
        if (e["laser-windup"] <= 0) then
          fire_laser(e, joueur, world, take_damage)
          e["laser-cooldown"] = LASER_COOLDOWN
        else
        end
      else
        move_with_path(e, joueur, world, enemies)
        track_movement(e, prev_x, prev_y)
        e["laser-cooldown"] = (e["laser-cooldown"] - 1)
        if (e["laser-cooldown"] <= 0) then
          begin_laser_windup(e, joueur, world)
        else
        end
      end
    end
    return tick_anim_2(e)
  end
  local function in_kamikaze_radius_3f(e, joueur)
    local dx = ((joueur.x + (joueur.size / 2)) - center_x(e))
    local dy = ((joueur.y + (joueur.size / 2)) - center_y(e))
    local dist = math.sqrt(((dx * dx) + (dy * dy)))
    return (dist <= (KAMIKAZE_EXPLOSION_RADIUS + (joueur.size / 2)))
  end
  local function update_kamikaze(e, joueur, world, enemies, take_damage)
    e["moving?"] = false
    if (e["kami-state"] == "chase") then
      local prev_x = e.x
      local prev_y = e.y
      move_with_path(e, joueur, world, enemies)
      track_movement(e, prev_x, prev_y)
      if in_kamikaze_radius_3f(e, joueur) then
        e["kami-state"] = "arming"
        e["kami-arming-timer"] = KAMIKAZE_ARMING_TIME
        e.path = {}
      else
      end
    elseif (e["kami-state"] == "arming") then
      e["kami-arming-timer"] = (e["kami-arming-timer"] - 1)
      if (e["kami-arming-timer"] <= 0) then
        e["kami-state"] = "exploding"
        e["kami-explosion-timer"] = KAMIKAZE_EXPLOSION_FLASH
        e["kami-did-damage"] = false
      else
      end
    elseif (e["kami-state"] == "exploding") then
      if not e["kami-did-damage"] then
        e["kami-did-damage"] = true
        if in_kamikaze_radius_3f(e, joueur) then
          take_damage(joueur, KAMIKAZE_EXPLOSION_DAMAGE, center_x(e), center_y(e))
        else
        end
      else
      end
      e["kami-explosion-timer"] = (e["kami-explosion-timer"] - 1)
      if (e["kami-explosion-timer"] <= 0) then
        e.hp = 0
      else
      end
    else
    end
    return tick_anim_2(e)
  end
  enemie.new = function(x, y, enemy_type)
    local kind = (enemy_type or "grunt")
    local e = {x = x, y = y, size = 8, speed = 0.5, color = 8, hp = 10, ["max-hp"] = 10, type = kind, ["sprite-id"] = nil, ["attack-timer"] = 0, ["stun-timer"] = 0, ["dot-timer"] = 0, ["dot-dmg"] = 0, ["dot-tick"] = 0, ["hurt-timer"] = 0, ["knockback-vx"] = 0, ["knockback-vy"] = 0, ["knockback-timer"] = 0, path = {}, ["path-timer"] = 0, ["anim-timer"] = math.random(0, 10), ["anim-frame"] = 1, direction = "down", ["laser-cooldown"] = (20 + math.random(0, 20)), ["laser-windup"] = 0, ["laser-dir-x"] = 1, ["laser-dir-y"] = 0, ["laser-end-x"] = x, ["laser-end-y"] = y, ["laser-flash"] = 0, ["kami-state"] = "chase", ["kami-arming-timer"] = 0, ["kami-explosion-timer"] = 0, ["kami-did-damage"] = false, ["moving?"] = false}
    if (kind == "laser") then
      e.speed = 0.45
      e.hp = 4
      e["max-hp"] = 4
      e["sprite-id"] = LASER_SPRITE_ID
    elseif (kind == "kamikaze") then
      e.speed = 0.9
      e.hp = 24
      e["max-hp"] = 24
      e["sprite-id"] = KAMIKAZE_SPRITE_ID
    else
      e.speed = 0.5
      e.hp = 5
      e["max-hp"] = 5
      e["sprite-id"] = nil
    end
    return e
  end
  enemie.distance = function(e, joueur)
    return math.sqrt((((joueur.x - e.x) * (joueur.x - e.x)) + ((joueur.y - e.y) * (joueur.y - e.y))))
  end
  enemie.update = function(e, joueur, world, enemies, take_damage)
    local do_damage
    local or_243_ = take_damage
    if not or_243_ then
      local function _244_(_, _0)
        return nil
      end
      or_243_ = _244_
    end
    do_damage = or_243_
    process_dot(e)
    process_stun(e)
    tick_attack_cooldown(e)
    if (e["hurt-timer"] > 0) then
      e["hurt-timer"] = (e["hurt-timer"] - 1)
    else
    end
    if (e["stun-timer"] > 0) then
      e["moving?"] = false
    else
    end
    if (e["knockback-timer"] > 0) then
      e["moving?"] = true
      apply_knockback_motion(e, world, enemies, joueur)
      return tick_anim_2(e)
    else
      if (e["stun-timer"] <= 0) then
        if (e.type == "laser") then
          return update_laser(e, joueur, world, enemies, do_damage)
        elseif (e.type == "kamikaze") then
          return update_kamikaze(e, joueur, world, enemies, do_damage)
        else
          return update_grunt(e, joueur, world, enemies, do_damage)
        end
      else
        return nil
      end
    end
  end
  enemie.attack = function(e, joueur, take_damage, world)
    if ((e.type == "grunt") or (e.type == nil)) then
      if (world["collide?"]((e.x - 1), (e.y - 1), (e.size + 2), joueur.x, joueur.y, joueur.size) and (e["attack-timer"] == 0)) then
        take_damage(joueur, 1, center_x(e), center_y(e))
        e["attack-timer"] = 30
        if (joueur["id-utility"] == 2) then
          local util = abilities["get-utility"](2)
          return enemie["take-damage"](e, util.stats["reflect-damage"])
        else
          return nil
        end
      else
        return nil
      end
    else
      return nil
    end
  end
  enemie["take-damage"] = function(e, dmg)
    if (dmg > 0) then
      e.hp = (e.hp - dmg)
      e["hurt-timer"] = HURT_FLASH_DURATION
      return nil
    else
      return nil
    end
  end
  enemie["apply-dot"] = function(e, dmg, dur)
    e["dot-dmg"] = dmg
    e["dot-timer"] = dur
    e["dot-tick"] = 0
    return nil
  end
  enemie["apply-stun"] = function(e, frames)
    if (frames > e["stun-timer"]) then
      e["stun-timer"] = frames
      return nil
    else
      return nil
    end
  end
  enemie["apply-knockback"] = function(e, from_x, from_y, power)
    local cx = center_x(e)
    local cy = center_y(e)
    local dx = (cx - from_x)
    local dy = (cy - from_y)
    local len = math.sqrt(((dx * dx) + (dy * dy)))
    if (len > 0.001) then
      local strength = (power or 2.6)
      e["knockback-vx"] = ((dx / len) * strength)
      e["knockback-vy"] = ((dy / len) * strength)
      e["knockback-timer"] = SWORD_KNOCKBACK_DURATION
      e["stun-timer"] = math.max(e["stun-timer"], 3)
      return nil
    else
      return nil
    end
  end
  enemie["is-dead?"] = function(e)
    return (e.hp <= 0)
  end
  local function draw_health(e, x, y)
    local ratio = (math.max(e.hp, 0) / math.max(e["max-hp"], 1))
    rect(x, (y - 3), e.size, 2, 1)
    return rect(x, (y - 3), math.floor((e.size * ratio)), 2, 11)
  end
  local function draw_laser_telegraph(e)
    if (e["laser-windup"] > 0) then
      local function _256_()
        if (((e["laser-windup"] // 4) % 2) == 0) then
          return 8
        else
          return 12
        end
      end
      line(center_x(e), center_y(e), e["laser-end-x"], e["laser-end-y"], _256_())
    else
    end
    if (e["laser-flash"] > 0) then
      return line(center_x(e), center_y(e), e["laser-end-x"], e["laser-end-y"], 6)
    else
      return nil
    end
  end
  local function draw_kamikaze_telegraph(e)
    if (e["kami-state"] == "arming") then
      local blink_color
      if (((e["kami-arming-timer"] // 4) % 2) == 0) then
        blink_color = 6
      else
        blink_color = 8
      end
      return circb(center_x(e), center_y(e), KAMIKAZE_EXPLOSION_RADIUS, blink_color)
    elseif (e["kami-state"] == "exploding") then
      circ(center_x(e), center_y(e), KAMIKAZE_EXPLOSION_RADIUS, 6)
      return circb(center_x(e), center_y(e), KAMIKAZE_EXPLOSION_RADIUS, 15)
    else
      return nil
    end
  end
  enemie.draw = function(e)
    local x = math.floor(e.x)
    local y = math.floor(e.y)
    if (e.type == "laser") then
      local f = (e["anim-frame"] or 1)
      local sprite
      if not e["moving?"] then
        sprite = 191
      elseif (e.direction == "right") then
        if (f == 1) then
          sprite = 192
        else
          sprite = 193
        end
      elseif (e.direction == "left") then
        if (f == 1) then
          sprite = 195
        else
          sprite = 196
        end
      else
        if (f == 1) then
          sprite = 198
        else
          sprite = 199
        end
      end
      draw_laser_telegraph(e)
      spr(sprite, x, y, 15)
      return draw_health(e, x, y)
    elseif (e.type == "kamikaze") then
      local f = (e["anim-frame"] or 1)
      local sprite
      if not e["moving?"] then
        if (f == 1) then
          sprite = 181
        else
          sprite = 182
        end
      elseif (e.direction == "right") then
        if (f == 1) then
          sprite = 183
        else
          sprite = 184
        end
      elseif (e.direction == "left") then
        if (f == 1) then
          sprite = 186
        else
          sprite = 187
        end
      else
        if (f == 1) then
          sprite = 189
        else
          sprite = 190
        end
      end
      draw_kamikaze_telegraph(e)
      spr(sprite, x, y, 15)
      return draw_health(e, x, y)
    else
      local base_spr
      if not e["moving?"] then
        base_spr = 111
      elseif ((e.direction == "right") or (e.direction == "down")) then
        base_spr = 113
      elseif (e.direction == "left") then
        base_spr = 116
      else
        base_spr = 119
      end
      local final_spr = (base_spr + ((e["anim-frame"] or 1) - 1))
      spr(final_spr, x, y, 15)
      return draw_health(e, x, y)
    end
  end
  return enemie
end
package.preload["astar"] = package.preload["astar"] or function(...)
  local M = {}
  M.heuristic = function(x1, y1, x2, y2)
    local dx = math.abs((x1 - x2))
    local dy = math.abs((y1 - y2))
    return ((10 * math.max(dx, dy)) + (4 * math.min(dx, dy)))
  end
  M["find-path"] = function(start_x, start_y, target_x, target_y, walkable_3f)
    local step = 8
    local sx = (((start_x + (step / 2)) // step) * step)
    local sy = (((start_y + (step / 2)) // step) * step)
    local gx = (((target_x + (step / 2)) // step) * step)
    local gy = (((target_y + (step / 2)) // step) * step)
    local open_list = {}
    local closed_set = {}
    local came_from = {}
    local g_score = {}
    local f_score = {}
    local function get_key(x, y)
      return (x .. "," .. y)
    end
    local start_key = get_key(sx, sy)
    table.insert(open_list, {x = sx, y = sy})
    g_score[start_key] = 0
    f_score[start_key] = M.heuristic(sx, sy, gx, gy)
    local path = nil
    local iter = 0
    local max_iter = 300
    while ((#open_list > 0) and not path and (iter < max_iter)) do
      iter = (iter + 1)
      local current_idx = 1
      local current = open_list[1]
      local min_f = (f_score[get_key(current.x, current.y)] or 999999)
      for i = 2, #open_list do
        local node = open_list[i]
        local f = (f_score[get_key(node.x, node.y)] or 999999)
        if (f < min_f) then
          current_idx = i
          current = node
          min_f = f
        else
        end
      end
      local cur_key = get_key(current.x, current.y)
      if ((current.x == gx) and (current.y == gy)) then
        local best_path = {}
        local curr_key = cur_key
        while came_from[curr_key] do
          local p = came_from[curr_key]
          table.insert(best_path, 1, {p["to-x"], p["to-y"]})
          curr_key = get_key(p.x, p.y)
        end
        table.insert(best_path, {target_x, target_y})
        path = best_path
      else
        table.remove(open_list, current_idx)
        closed_set[cur_key] = true
        local neighbors = {{( - step), 0, 10}, {step, 0, 10}, {0, ( - step), 10}, {0, step, 10}, {( - step), ( - step), 14}, {step, ( - step), 14}, {( - step), step, 14}, {step, step, 14}}
        for _, offset in ipairs(neighbors) do
          local nx = (current.x + offset[1])
          local ny = (current.y + offset[2])
          local cost = offset[3]
          local n_key = get_key(nx, ny)
          if (not closed_set[n_key] and walkable_3f(nx, ny)) then
            local tentative_g = (g_score[cur_key] + cost)
            local old_g = (g_score[n_key] or 999999)
            if (tentative_g < old_g) then
              came_from[n_key] = {x = current.x, y = current.y, ["to-x"] = nx, ["to-y"] = ny}
              g_score[n_key] = tentative_g
              f_score[n_key] = (tentative_g + M.heuristic(nx, ny, gx, gy))
              local in_open = false
              for _0, node in ipairs(open_list) do
                if ((node.x == nx) and (node.y == ny)) then
                  in_open = true
                else
                end
              end
              if not in_open then
                table.insert(open_list, {x = nx, y = ny})
              else
              end
            else
            end
          else
          end
        end
      end
    end
    return (path or {})
  end
  return M
end
enemie = require("enemie")
local boss
package.preload["boss"] = package.preload["boss"] or function(...)
  local boss = {}
  local BOSS_SIZE = 16
  local CONTACT_DAMAGE = 1
  local CONTACT_COOLDOWN = 26
  local CHARGE_SPEED = 2.5
  local DODGE_SPEED = 2
  local HURT_FLASH_DURATION = 8
  local function clamp(v, lo, hi)
    return math.max(lo, math.min(hi, v))
  end
  local function normalize(dx, dy)
    local len = math.sqrt(((dx * dx) + (dy * dy)))
    if (len > 0.001) then
      return {(dx / len), (dy / len)}
    else
      return {1, 0}
    end
  end
  local function move_safe(e, world, dx, dy)
    local nx = (e.x + dx)
    local ny = (e.y + dy)
    if world["can-move?"](nx, e.y, e.size) then
      e.x = nx
    else
    end
    if world["can-move?"](e.x, ny, e.size) then
      e.y = ny
      return nil
    else
      return nil
    end
  end
  local function center_x(e)
    return (e.x + (e.size / 2))
  end
  local function center_y(e)
    return (e.y + (e.size / 2))
  end
  local function new_radial_burst(e)
    local count = 12
    local speed = 1.3
    for i = 0, (count - 1) do
      local a = ((i / count) * 2 * math.pi)
      local vx = (speed * math.cos(a))
      local vy = (speed * math.sin(a))
      table.insert(e.projectiles, {x = center_x(e), y = center_y(e), vx = vx, vy = vy, life = 140, radius = 3, damage = 1})
    end
    return nil
  end
  local function begin_windup(e, joueur)
    e.phase = "windup"
    e["phase-timer"] = 30
    e["did-impact"] = false
    e["impact-flash"] = 0
    e["pattern-data"] = {}
    if (e["pattern-index"] == 1) then
      local tx = (joueur.x + (joueur.size / 2))
      local ty = (joueur.y + (joueur.size / 2))
      local _let_275_ = normalize((tx - center_x(e)), (ty - center_y(e)))
      local nx = _let_275_[1]
      local ny = _let_275_[2]
      local line_len = 96
      e["pattern-data"] = {vx = (nx * CHARGE_SPEED), vy = (ny * CHARGE_SPEED), ["line-x2"] = (center_x(e) + (nx * line_len)), ["line-y2"] = (center_y(e) + (ny * line_len))}
      return nil
    elseif (e["pattern-index"] == 2) then
      e["pattern-data"] = {["burst-radius"] = 26}
      return nil
    elseif (e["pattern-index"] == 3) then
      local tx = clamp((joueur.x + (joueur.size / 2)), 20, 220)
      local ty = clamp((joueur.y + (joueur.size / 2)), 36, 124)
      e["pattern-data"] = {["target-x"] = tx, ["target-y"] = ty, radius = 18}
      return nil
    else
      return nil
    end
  end
  local function begin_action(e)
    e.phase = "action"
    if (e["pattern-index"] == 1) then
      e["phase-timer"] = 22
      return nil
    elseif (e["pattern-index"] == 2) then
      e["phase-timer"] = 24
      return new_radial_burst(e)
    elseif (e["pattern-index"] == 3) then
      e["phase-timer"] = 12
      return nil
    else
      return nil
    end
  end
  local function begin_recover(e)
    e.phase = "recover"
    e["phase-timer"] = 18
    return nil
  end
  local function begin_dodge(e, world)
    local tries = 0
    local picked = false
    e["dodge-vx"] = 0
    e["dodge-vy"] = 0
    while ((tries < 8) and not picked) do
      local a = ((math.random(0, 360) / 180) * math.pi)
      local vx = (math.cos(a) * DODGE_SPEED)
      local vy = (math.sin(a) * DODGE_SPEED)
      local tx = (e.x + vx)
      local ty = (e.y + vy)
      tries = (tries + 1)
      if world["can-move?"](tx, ty, e.size) then
        picked = true
        e["dodge-vx"] = vx
        e["dodge-vy"] = vy
      else
      end
    end
    e.phase = "dodge"
    e["phase-timer"] = 12
    e["invuln-timer"] = 8
    return nil
  end
  local function update_dot(e)
    if (e["dot-timer"] > 0) then
      e["dot-timer"] = (e["dot-timer"] - 1)
      e["dot-tick"] = (e["dot-tick"] + 1)
      if (e["dot-tick"] >= 60) then
        e["dot-tick"] = 0
        e.hp = (e.hp - e["dot-dmg"])
        e["hurt-timer"] = HURT_FLASH_DURATION
      else
      end
      if (e["dot-timer"] <= 0) then
        e["dot-dmg"] = 0
        e["dot-tick"] = 0
        return nil
      else
        return nil
      end
    else
      return nil
    end
  end
  local function projectile_hit_player_3f(proj, joueur, world)
    return world["collide?"]((proj.x - proj.radius), (proj.y - proj.radius), (proj.radius * 2), joueur.x, joueur.y, joueur.size)
  end
  local function update_projectiles(e, joueur, world, take_damage)
    for i = #e.projectiles, 1, -1 do
      local proj = e.projectiles[i]
      proj.x = (proj.x + proj.vx)
      proj.y = (proj.y + proj.vy)
      proj.life = (proj.life - 1)
      if ((proj.life <= 0) or world["wall?"](proj.x, proj.y)) then
        proj.dead = true
      else
      end
      if (not proj.dead and projectile_hit_player_3f(proj, joueur, world)) then
        take_damage(joueur, proj.damage, proj.x, proj.y)
        proj.dead = true
      else
      end
      if proj.dead then
        table.remove(e.projectiles, i)
      else
      end
    end
    return nil
  end
  boss.new = function(x, y)
    local e = {type = "boss", x = x, y = y, size = BOSS_SIZE, hp = 40, ["max-hp"] = 40, ["attack-timer"] = 0, ["stun-timer"] = 0, ["dot-timer"] = 0, ["dot-dmg"] = 0, ["dot-tick"] = 0, ["hurt-timer"] = 0, ["invuln-timer"] = 0, phase = "windup", ["phase-timer"] = 0, ["pattern-index"] = 1, ["pattern-data"] = {}, projectiles = {}, ["dodge-vx"] = 0, ["dodge-vy"] = 0, ["impact-flash"] = 0, ["anim-timer"] = 0, ["anim-frame"] = 1, facing = "down", ["did-impact"] = false, ["moving?"] = false}
    begin_windup(e, {x = (x + 1), y = (y + 1), size = 1})
    return e
  end
  local function update_facing(e, vx, vy)
    if ((math.abs(vx) + math.abs(vy)) > 0.01) then
      e["moving?"] = true
      if (math.abs(vx) > math.abs(vy)) then
        if (vx > 0) then
          e.facing = "right"
          return nil
        else
          e.facing = "left"
          return nil
        end
      else
        e.facing = "down"
        return nil
      end
    else
      return nil
    end
  end
  local function advance_anim(e)
    local threshold
    if (e["moving?"] or (e.phase == "action")) then
      threshold = 28
    else
      threshold = 56
    end
    e["anim-timer"] = (e["anim-timer"] + 1)
    if (e["anim-timer"] >= threshold) then
      e["anim-timer"] = 0
      e["anim-frame"] = (1 + (e["anim-frame"] % 3))
      return nil
    else
      return nil
    end
  end
  boss.update = function(e, joueur, world, _, take_damage)
    e["moving?"] = false
    update_dot(e)
    update_projectiles(e, joueur, world, take_damage)
    if (e["attack-timer"] > 0) then
      e["attack-timer"] = (e["attack-timer"] - 1)
    else
    end
    if (e["invuln-timer"] > 0) then
      e["invuln-timer"] = (e["invuln-timer"] - 1)
    else
    end
    if (e["impact-flash"] > 0) then
      e["impact-flash"] = (e["impact-flash"] - 1)
    else
    end
    if (e["hurt-timer"] > 0) then
      e["hurt-timer"] = (e["hurt-timer"] - 1)
    else
    end
    if (e["stun-timer"] > 0) then
      e["stun-timer"] = (e["stun-timer"] - 1)
    else
    end
    if (e["stun-timer"] <= 0) then
      if (e.phase == "windup") then
        e["phase-timer"] = (e["phase-timer"] - 1)
        if (e["phase-timer"] <= 0) then
          begin_action(e)
        else
        end
      elseif (e.phase == "action") then
        if (e["pattern-index"] == 1) then
          update_facing(e, e["pattern-data"].vx, e["pattern-data"].vy)
          move_safe(e, world, e["pattern-data"].vx, e["pattern-data"].vy)
        elseif (e["pattern-index"] == 3) then
          if (not e["did-impact"] and (e["phase-timer"] <= 4)) then
            e["did-impact"] = true
            e["impact-flash"] = 10
            local dx = ((joueur.x + (joueur.size / 2)) - e["pattern-data"]["target-x"])
            local dy = ((joueur.y + (joueur.size / 2)) - e["pattern-data"]["target-y"])
            local dist = math.sqrt(((dx * dx) + (dy * dy)))
            if (dist <= e["pattern-data"].radius) then
              take_damage(joueur, 1, e["pattern-data"]["target-x"], e["pattern-data"]["target-y"])
            else
            end
          else
          end
        else
        end
        e["phase-timer"] = (e["phase-timer"] - 1)
        if (e["phase-timer"] <= 0) then
          begin_recover(e)
        else
        end
      elseif (e.phase == "recover") then
        e["phase-timer"] = (e["phase-timer"] - 1)
        if (e["phase-timer"] <= 0) then
          begin_dodge(e, world)
        else
        end
      elseif (e.phase == "dodge") then
        update_facing(e, e["dodge-vx"], e["dodge-vy"])
        move_safe(e, world, e["dodge-vx"], e["dodge-vy"])
        e["phase-timer"] = (e["phase-timer"] - 1)
        if (e["phase-timer"] <= 0) then
          e["pattern-index"] = (e["pattern-index"] + 1)
          if (e["pattern-index"] > 3) then
            e["pattern-index"] = 1
          else
          end
          begin_windup(e, joueur)
        else
        end
      else
      end
    else
    end
    return advance_anim(e)
  end
  boss.attack = function(e, joueur, take_damage, world)
    if (world["collide?"](e.x, e.y, e.size, joueur.x, joueur.y, joueur.size) and (e["attack-timer"] == 0)) then
      take_damage(joueur, CONTACT_DAMAGE, center_x(e), center_y(e))
      e["attack-timer"] = CONTACT_COOLDOWN
      return nil
    else
      return nil
    end
  end
  boss["take-damage"] = function(e, dmg)
    if ((dmg > 0) and (e["invuln-timer"] <= 0)) then
      e.hp = (e.hp - dmg)
      e["hurt-timer"] = HURT_FLASH_DURATION
      return nil
    else
      return nil
    end
  end
  boss["apply-dot"] = function(e, dmg, dur)
    e["dot-dmg"] = dmg
    e["dot-timer"] = dur
    e["dot-tick"] = 0
    return nil
  end
  boss["apply-stun"] = function(e, frames)
    if (frames > e["stun-timer"]) then
      e["stun-timer"] = frames
      return nil
    else
      return nil
    end
  end
  boss["apply-knockback"] = function(_, _0, _1, _2)
    return nil
  end
  boss["is-dead?"] = function(e)
    return (e.hp <= 0)
  end
  local function draw_telegraph(e)
    if (e.phase == "windup") then
      if (e["pattern-index"] == 1) then
        local function _308_()
          if (((time() // 120) % 2) < 1) then
            return 12
          else
            return 8
          end
        end
        line(center_x(e), center_y(e), e["pattern-data"]["line-x2"], e["pattern-data"]["line-y2"], _308_())
      elseif (e["pattern-index"] == 2) then
        circb(center_x(e), center_y(e), e["pattern-data"]["burst-radius"], 8)
      elseif (e["pattern-index"] == 3) then
        circb(e["pattern-data"]["target-x"], e["pattern-data"]["target-y"], e["pattern-data"].radius, 8)
        circb(e["pattern-data"]["target-x"], e["pattern-data"]["target-y"], 8, 12)
      else
      end
    else
    end
    if (e["impact-flash"] > 0) then
      return circ(e["pattern-data"]["target-x"], e["pattern-data"]["target-y"], e["pattern-data"].radius, 6)
    else
      return nil
    end
  end
  local function draw_projectiles(e)
    for _, proj in ipairs(e.projectiles) do
      circ(math.floor(proj.x), math.floor(proj.y), proj.radius, 8)
      circb(math.floor(proj.x), math.floor(proj.y), proj.radius, 12)
    end
    return nil
  end
  boss.draw = function(e)
    draw_telegraph(e)
    draw_projectiles(e)
    if ((e["invuln-timer"] <= 0) or ((e["invuln-timer"] % 4) == 0)) then
      local f = (e["anim-frame"] or 1)
      local idle_bases = {121, 125, 129}
      local right_bases = {133, 137, 141}
      local left_bases = {145, 149, 153}
      local down_bases = {157, 161, 165}
      local attack_bases = {169, 173, 177}
      local base
      if ((e.phase == "action") and ((e["pattern-index"] == 2) or (e["pattern-index"] == 3))) then
        base = attack_bases[f]
      elseif e["moving?"] then
        if (e.facing == "right") then
          base = right_bases[f]
        elseif (e.facing == "left") then
          base = left_bases[f]
        else
          base = down_bases[f]
        end
      else
        base = idle_bases[f]
      end
      spr(base, e.x, e.y, 15)
      spr((base + 1), (e.x + 8), e.y, 15)
      spr((base + 2), e.x, (e.y + 8), 15)
      spr((base + 3), (e.x + 8), (e.y + 8), 15)
    else
    end
    local bar_w = 28
    local x = (e.x - 6)
    local y = (e.y - 6)
    rect(x, y, bar_w, 3, 1)
    rect(x, y, math.floor((bar_w * (math.max(e.hp, 0) / e["max-hp"]))), 3, 8)
    return rectb(x, y, bar_w, 3, 0)
  end
  return boss
end
boss = require("boss")
local initialized = false
local enemies = {}
local projectiles = {}
local lightning_flashes = {}
local pickups = {}
local reward_screen = item.new()
local reward_pickup_size = 8
local room_reward_spawned = false
local room_reward_required = false
local game_state = "intro"
local intro_timer = 120
local menu_blink = 0
local spr_potion = 207
local spr_item_upgrade = 203
local shop_items = {}
local shop_msg = ""
local shop_msg_timer = 0
local DOOR_PULSE_DURATION = 24
local PLAYER_HIT_OVERLAY_DURATION = 8
local PICKUP_BOB_AMPLITUDE = 2
local PICKUP_BOB_SPEED = 8
local fx = {frame = 0, ["door-pulse"] = 0, ["door-pulse-x"] = 120, ["door-pulse-y"] = 72, ["player-hit-overlay"] = 0}
local joueur = player.new()
local SWORD_KNOCKBACK_PX = 12
local SWORD_KNOCKBACK_STEP = 1.5
local function tick_fx()
  fx.frame = (fx.frame + 1)
  if (fx["door-pulse"] > 0) then
    fx["door-pulse"] = (fx["door-pulse"] - 1)
  else
  end
  if (fx["player-hit-overlay"] > 0) then
    fx["player-hit-overlay"] = (fx["player-hit-overlay"] - 1)
    return nil
  else
    return nil
  end
end
local function trigger_door_pulse()
  local spawn = world["get-door-reward-spawn"](reward_pickup_size)
  fx["door-pulse"] = DOOR_PULSE_DURATION
  fx["door-pulse-x"] = (spawn.x + 4)
  fx["door-pulse-y"] = (spawn.y + 4)
  return nil
end
local function player_take_damage_with_fx(p, dmg, hit_x, hit_y)
  if player["take-damage"](p, dmg, hit_x, hit_y, world) then
    fx["player-hit-overlay"] = PLAYER_HIT_OVERLAY_DURATION
    return true
  else
    return nil
  end
end
local function is_boss_3f(e)
  return (e.type == "boss")
end
local function entity_update(e)
  if is_boss_3f(e) then
    return boss.update(e, joueur, world, enemies, player_take_damage_with_fx)
  else
    return enemie.update(e, joueur, world, enemies, player_take_damage_with_fx)
  end
end
local function entity_attack(e)
  if is_boss_3f(e) then
    return boss.attack(e, joueur, player_take_damage_with_fx, world)
  else
    return enemie.attack(e, joueur, player_take_damage_with_fx, world)
  end
end
local function entity_draw(e)
  if is_boss_3f(e) then
    return boss.draw(e)
  else
    return enemie.draw(e)
  end
end
local function entity_is_dead_3f(e)
  if is_boss_3f(e) then
    return boss["is-dead?"](e)
  else
    return enemie["is-dead?"](e)
  end
end
local function entity_center_x(e)
  return (e.x + (e.size / 2))
end
local function entity_center_y(e)
  return (e.y + (e.size / 2))
end
local function can_occupy_entity_3f(e, nx, ny)
  local and_322_ = world["can-move?"](nx, ny, e.size) and not world["collide?"](nx, ny, e.size, joueur.x, joueur.y, joueur.size)
  if and_322_ then
    local blocked = false
    for _, other in ipairs(enemies) do
      if ((other ~= e) and not entity_is_dead_3f(other) and world["collide?"](nx, ny, e.size, other.x, other.y, other.size)) then
        blocked = true
      else
      end
    end
    and_322_ = not blocked
  end
  return and_322_
end
local function queue_sword_knockback(e, from_x, from_y, dist)
  if (dist > 0) then
    local dx = (entity_center_x(e) - from_x)
    local dy = (entity_center_y(e) - from_y)
    local len = math.sqrt(((dx * dx) + (dy * dy)))
    if (len > 0.001) then
      e["kb-dx"] = (dx / len)
      e["kb-dy"] = (dy / len)
    else
      e["kb-dx"] = 1
      e["kb-dy"] = 0
    end
    e["kb-left"] = dist
    return nil
  else
    return nil
  end
end
local function apply_entity_knockback(e)
  if ((e["kb-left"] or 0) > 0) then
    local step = math.min(SWORD_KNOCKBACK_STEP, e["kb-left"])
    local vx = ((e["kb-dx"] or 0) * step)
    local vy = ((e["kb-dy"] or 0) * step)
    local moved = false
    do
      local nx = (e.x + vx)
      if can_occupy_entity_3f(e, nx, e.y) then
        e.x = nx
        moved = true
      else
      end
    end
    do
      local ny = (e.y + vy)
      if can_occupy_entity_3f(e, e.x, ny) then
        e.y = ny
        moved = true
      else
      end
    end
    if moved then
      e["kb-left"] = (e["kb-left"] - step)
    else
      e["kb-left"] = 0
    end
    if (e["kb-left"] < 0.001) then
      e["kb-left"] = 0
      return nil
    else
      return nil
    end
  else
    return nil
  end
end
local function entity_take_damage(e, dmg, hit_context)
  local hp_before = e.hp
  if is_boss_3f(e) then
    boss["take-damage"](e, dmg)
  else
    enemie["take-damage"](e, dmg)
  end
  if (hit_context and (hit_context.source == "sword") and (dmg > 0) and (e.hp < hp_before) and not entity_is_dead_3f(e)) then
    return queue_sword_knockback(e, hit_context["from-x"], hit_context["from-y"], SWORD_KNOCKBACK_PX)
  else
    return nil
  end
end
local function entity_apply_dot(e, dmg, dur)
  if is_boss_3f(e) then
    return boss["apply-dot"](e, dmg, dur)
  else
    return enemie["apply-dot"](e, dmg, dur)
  end
end
local function entity_apply_stun(e, frames)
  if is_boss_3f(e) then
    return boss["apply-stun"](e, frames)
  else
    return enemie["apply-stun"](e, frames)
  end
end
local function entity_apply_knockback(e, from_x, from_y, strength)
  if is_boss_3f(e) then
    return boss["apply-knockback"](e, from_x, from_y, strength)
  else
    return enemie["apply-knockback"](e, from_x, from_y, strength)
  end
end
local combat_api = {["take-damage"] = entity_take_damage, ["apply-dot"] = entity_apply_dot, ["apply-stun"] = entity_apply_stun, ["apply-knockback"] = entity_apply_knockback, ["is-dead?"] = entity_is_dead_3f}
local function random_enemy_type()
  local roll = math.random(1, 100)
  if (roll <= 40) then
    return "grunt"
  elseif (roll <= 70) then
    return "laser"
  else
    return "kamikaze"
  end
end
local function spawn_room_enemies(count)
  for _ = 1, count do
    local pos = world["get-random-spawn"](8, joueur.x, joueur.y, 60)
    table.insert(enemies, enemie.new(pos.x, pos.y, random_enemy_type()))
  end
  return nil
end
local function clear_list(xs)
  while (#xs > 0) do
    table.remove(xs, 1)
  end
  return nil
end
local function setup_room_encounter()
  clear_list(enemies)
  if world["is-boss-room"]() then
    return table.insert(enemies, boss.new(112, 64))
  else
    if not world["is-shop?"]() then
      return spawn_room_enemies(4)
    else
      return nil
    end
  end
end
local function player_overlap_item_3f(p, pickup)
  return (pickup.active and (math.abs((p.x - pickup.x)) < pickup.size) and (math.abs((p.y - pickup.y)) < pickup.size))
end
local function player_near_item_3f(p, pickup)
  local dx = ((p.x + (p.size / 2)) - (pickup.x + (pickup.size / 2)))
  local dy = ((p.y + (p.size / 2)) - (pickup.y + (pickup.size / 2)))
  return (((dx * dx) + (dy * dy)) < 450)
end
local function shop_set_msg(txt)
  shop_msg = txt
  shop_msg_timer = 60
  return nil
end
local function init_shop_items()
  shop_items = {{kind = "heal", cost = 50, amount = 5, x = 80, y = 72, size = 8, active = true}, {kind = "itemUpgrade", cost = 100, x = 152, y = 72, size = 8, active = true}}
  return nil
end
local function try_buy_shop_item(it)
  if (joueur.gold < it.cost) then
    return shop_set_msg((it.cost .. "g requis"))
  else
    player["spend-gold"](joueur, it.cost)
    if (it.kind == "heal") then
      player.heal(joueur, it.amount)
      return shop_set_msg(("+" .. it.amount .. " PV"))
    else
      shop_set_msg("Upgrade")
      return item.open(reward_screen, joueur)
    end
  end
end
local function update_shop_items()
  if (shop_msg_timer > 0) then
    shop_msg_timer = (shop_msg_timer - 1)
    if (shop_msg_timer <= 0) then
      shop_msg = ""
    else
    end
  else
  end
  for _, it in ipairs(shop_items) do
    if (it.active and player_overlap_item_3f(joueur, it) and (btnp(4) or keyp(23))) then
      try_buy_shop_item(it)
    else
    end
  end
  return nil
end
local function draw_shop_items()
  for _, it in ipairs(shop_items) do
    if it.active then
      local label = (it.cost .. "g")
      local sid
      if (it.kind == "heal") then
        sid = spr_potion
      else
        sid = spr_item_upgrade
      end
      local bob = math.floor((math.sin(((fx.frame + (it.x * 0.5)) / PICKUP_BOB_SPEED)) * PICKUP_BOB_AMPLITUDE))
      local draw_y = (it.y + bob)
      local near_3f = player_near_item_3f(joueur, it)
      local pulse_r = (7 + math.floor((math.sin(((fx.frame + (it.y * 0.4)) / 5)) * 1.5)))
      if near_3f then
        local function _345_()
          if (((fx.frame // 4) % 2) == 0) then
            return 9
          else
            return 10
          end
        end
        circb((it.x + 4), (draw_y + 4), pulse_r, _345_())
      else
      end
      spr(sid, it.x, draw_y, 15)
      local _347_
      if near_3f then
        _347_ = 12
      else
        _347_ = 13
      end
      print("W acheter", (it.x - 6), (draw_y - 10), _347_, false, 1, true)
      print(label, (it.x - 2), (draw_y + 10), 12, false, 1, true)
    else
    end
  end
  return nil
end
if (shop_msg ~= "") then
  local t = shop_msg_timer
  local y = (124 - math.floor(((60 - t) / 10)))
  local color
  if (t < 15) then
    if (((t // 2) % 2) == 0) then
      color = 12
    else
      color = 6
    end
  else
    color = 12
  end
  print(shop_msg, 10, y, color, false, 1, true)
else
end
local function spawn_pickup()
  if (#pickups < __fnl_global__max_2dpickups) then
    local attempts = 0
    local spawned = false
    while ((attempts < 20) and not spawned) do
      local x = (math.random(1, 28) * 8)
      local y = (20 + (math.random(1, 13) * 8))
      attempts = (attempts + 1)
      if (not world["wall?"](x, y) and not world["wall?"]((x + 7), (y + 7))) then
        table.insert(pickups, {x = x, y = y, size = 8, active = true, phase = math.random(0, 60)})
        spawned = true
      else
      end
    end
    return nil
  else
    return nil
  end
end
local function update_game()
  player.update(joueur, world, enemies)
  if world["is-shop?"]() then
    if not world["door-open"] then
      world["open-door"]()
      trigger_door_pulse()
    else
    end
    if (#shop_items == 0) then
      init_shop_items()
    else
    end
    update_shop_items()
  else
  end
  if (not world["is-shop?"]() and keyp(5)) then
    local status = player.attack(joueur, enemies, combat_api)
    player["feedback-action-status"](joueur, "attack", status)
  else
  end
  if joueur["sword-hit-due"] then
    joueur["sword-hit-due"] = false
    player["do-sword-hit"](joueur, enemies, combat_api)
  else
  end
  if (not world["is-shop?"]() and keyp(1)) then
    local status = player["spell-attack"](joueur, enemies, combat_api, projectiles, lightning_flashes)
    player["feedback-action-status"](joueur, "spell", status)
  else
  end
  if (not world["is-shop?"]() and keyp(26)) then
    local status = player["use-utility"](joueur, world)
    player["feedback-action-status"](joueur, "utility", status)
  else
  end
  if not world["is-shop?"]() then
    for i = #enemies, 1, -1 do
      local e = enemies[i]
      entity_update(e)
      apply_entity_knockback(e)
      entity_attack(e)
      if entity_is_dead_3f(e) then
        local function _362_()
          if is_boss_3f(e) then
            return 80
          else
            return math.random(5, 20)
          end
        end
        player["add-gold"](joueur, _362_())
        table.remove(enemies, i)
      else
      end
    end
  else
  end
  if (not world["is-shop?"]() and (#enemies == 0) and not room_reward_spawned) then
    world["open-door"]()
    trigger_door_pulse()
    do
      local spawn = world["get-door-reward-spawn"](reward_pickup_size)
      table.insert(pickups, {x = spawn.x, y = spawn.y, size = reward_pickup_size, active = true, phase = math.random(0, 60)})
    end
    room_reward_spawned = true
    room_reward_required = true
  else
  end
  for i = #pickups, 1, -1 do
    local pickup = pickups[i]
    if player_overlap_item_3f(joueur, pickup) then
      table.remove(pickups, i)
      item.open(reward_screen, joueur)
      room_reward_required = false
    else
    end
  end
  if (not room_reward_required and world["is-door?"](joueur.x, joueur.y, joueur.size)) then
    world["load-next-room"]()
    joueur.x = 24
    joueur.y = 64
    clear_list(projectiles)
    clear_list(lightning_flashes)
    clear_list(pickups)
    setup_room_encounter()
    room_reward_spawned = false
    room_reward_required = false
    shop_items = {}
    shop_msg = ""
    shop_msg_timer = 0
    if world["is-shop?"]() then
      init_shop_items()
    else
    end
  else
  end
  if not world["is-shop?"]() then
    for i = #projectiles, 1, -1 do
      local proj = projectiles[i]
      proj.x = (proj.x + proj.vx)
      proj.y = (proj.y + proj.vy)
      proj.lifetime = (proj.lifetime - 1)
      if (proj.lifetime <= 0) then
        proj.alive = false
      else
      end
      if world["wall?"](proj.x, proj.y) then
        proj.alive = false
      else
      end
      if proj.alive then
        for _, e in ipairs(enemies) do
          if (proj.alive and not entity_is_dead_3f(e)) then
            local dx = (e.x - proj.x)
            local dy = (e.y - proj.y)
            local dist = math.sqrt(((dx * dx) + (dy * dy)))
            if (dist < (proj.radius + (e.size / 2))) then
              entity_take_damage(e, proj.damage)
              if (proj.dot > 0) then
                entity_apply_dot(e, proj.dot, proj["dot-dur"])
              else
              end
              if (proj.aoe > 0) then
                for _0, e2 in ipairs(enemies) do
                  if (e2 ~= e) then
                    local ax = (e2.x - proj.x)
                    local ay = (e2.y - proj.y)
                    local adist = math.sqrt(((ax * ax) + (ay * ay)))
                    if (adist < proj.aoe) then
                      entity_take_damage(e2, proj.damage)
                      if (proj.dot > 0) then
                        entity_apply_dot(e2, proj.dot, proj["dot-dur"])
                      else
                      end
                    else
                    end
                  else
                  end
                end
              else
              end
              proj.alive = false
            else
            end
          else
          end
        end
      else
      end
      if not proj.alive then
        table.remove(projectiles, i)
      else
      end
    end
  else
  end
  for i = #lightning_flashes, 1, -1 do
    local f = lightning_flashes[i]
    f.timer = (f.timer - 1)
    if (f.timer <= 0) then
      table.remove(lightning_flashes, i)
    else
    end
  end
  return nil
end
local function draw_game()
  cls(0)
  world.draw()
  if (fx["door-pulse"] > 0) then
    local progress = (DOOR_PULSE_DURATION - fx["door-pulse"])
    local radius = (8 + math.floor((progress * 1.2)))
    local col
    if (((fx["door-pulse"] // 2) % 2) == 0) then
      col = 9
    else
      col = 12
    end
    circb(fx["door-pulse-x"], fx["door-pulse-y"], radius, col)
  else
  end
  for _, e in ipairs(enemies) do
    entity_draw(e)
  end
  for _, proj in ipairs(projectiles) do
    local elapsed = (120 - proj.lifetime)
    local frame = ((elapsed // 6) % 3)
    local angle = math.atan2(proj.vy, proj.vx)
    local rot = ((math.floor((0.5 + ((angle * 2) / math.pi))) + 4) % 4)
    spr((200 + frame), (math.floor(proj.x) - 4), (math.floor(proj.y) - 4), 15, 1, 0, rot)
  end
  for i, pickup in ipairs(pickups) do
    local phase = (fx.frame + (pickup.phase or (i * 9)))
    local bob = math.floor((math.sin((phase / PICKUP_BOB_SPEED)) * PICKUP_BOB_AMPLITUDE))
    local draw_y = (pickup.y + bob)
    local pulse_r = (6 + math.floor((math.sin((phase / 6)) * 1.5)))
    spr(spr_item_upgrade, pickup.x, draw_y, 15)
    local function _384_()
      if (((phase // 4) % 2) == 0) then
        return 9
      else
        return 12
      end
    end
    circb((pickup.x + 4), (draw_y + 4), pulse_r, _384_())
  end
  if (joueur["sword-flash"] > 0) then
    player["draw-attack-cone"](joueur)
  else
  end
  for _, f in ipairs(lightning_flashes) do
    local mx = (((f.x1 + f.x2) / 2) + f.jx)
    local my = (((f.y1 + f.y2) / 2) + f.jy)
    line(f.x1, f.y1, mx, my, 9)
    line(mx, my, f.x2, f.y2, 9)
  end
  if (fx["player-hit-overlay"] > 0) then
    local col
    if (((fx["player-hit-overlay"] // 2) % 2) == 0) then
      col = 6
    else
      col = 12
    end
    rect(0, 16, 240, 2, col)
    rect(0, 134, 240, 2, col)
    rect(0, 16, 2, 120, col)
    rect(238, 16, 2, 120, col)
  else
  end
  if world["is-shop?"]() then
    draw_shop_items()
  else
  end
  player["draw-ui"](joueur)
  player["draw-gold-ui"](joueur)
  return player.draw(joueur)
end
local global_t = 0
local stars = {}
for i = 1, 60 do
  table.insert(stars, {x = (math.random(200) - 100), y = (math.random(200) - 100), z = math.random(10, 200)})
end
local function update_stars()
  for _, s in ipairs(stars) do
    s.z = (s.z - 1.5)
    if (s.z < 1) then
      s.z = 200
      s.x = (math.random(200) - 100)
      s.y = (math.random(200) - 100)
    else
    end
  end
  return nil
end
local function draw_stars()
  for _, s in ipairs(stars) do
    local px = (120 + ((s.x * 100) / s.z))
    local py = (68 + ((s.y * 100) / s.z))
    if ((px > 0) and (px < 240) and (py > 0) and (py < 136)) then
      local col
      if (s.z < 50) then
        col = 15
      elseif (s.z < 120) then
        col = 13
      else
        col = 8
      end
      pix(math.floor(px), math.floor(py), col)
    else
    end
  end
  return nil
end
local cube_verts = {{-1, -1, -1}, {1, -1, -1}, {1, 1, -1}, {-1, 1, -1}, {-1, -1, 1}, {1, -1, 1}, {1, 1, 1}, {-1, 1, 1}}
local cube_edges = {{1, 2}, {2, 3}, {3, 4}, {4, 1}, {5, 6}, {6, 7}, {7, 8}, {8, 5}, {1, 5}, {2, 6}, {3, 7}, {4, 8}}
local angle_x = 0
local angle_y = 0
local angle_z = 0
local function rotate_3d(x, y, z, ax, ay, az)
  local sy = math.sin(ax)
  local cy = math.cos(ax)
  local y1 = ((y * cy) - (z * sy))
  local z1 = ((y * sy) + (z * cy))
  local sp = math.sin(ay)
  local cp = math.cos(ay)
  local x2 = ((x * cp) + (z1 * sp))
  local z2 = ((x * (0 - sp)) + (z1 * cp))
  local sr = math.sin(az)
  local cr = math.cos(az)
  local x3 = ((x2 * cr) - (y1 * sr))
  local y3 = ((x2 * sr) + (y1 * cr))
  return {x3, y3, z2}
end
local function draw_wireframe()
  angle_x = (angle_x + 0.02)
  angle_y = (angle_y + 0.03)
  angle_z = (angle_z + 0.01)
  local proj_verts = {}
  for _, v in ipairs(cube_verts) do
    local r = rotate_3d(v[1], v[2], v[3], angle_x, angle_y, angle_z)
    local z = (( - r[3]) + 2.5)
    local scale = (45 / z)
    local px = (120 + (r[1] * scale))
    local py = (68 + (r[2] * scale))
    table.insert(proj_verts, {px, py, z})
  end
  for _, e in ipairs(cube_edges) do
    local v1 = proj_verts[e[1]]
    local v2 = proj_verts[e[2]]
    local col
    if (v1[3] < 2.5) then
      col = 11
    else
      col = 5
    end
    line(v1[1], v1[2], v2[1], v2[2], col)
  end
  return nil
end
local function draw_wobbling_text(text, cx, cy, base_color, time_var)
  local len = string.len(text)
  local width = (len * 6)
  local start_x = (cx - (width / 2))
  for i = 1, len do
    local char = string.sub(text, i, i)
    local oy = (math.sin((time_var + (i * 0.5))) * 4)
    print(char, (start_x + ((i - 1) * 6)), (cy + oy), base_color)
  end
  return nil
end
local function update_intro()
  global_t = (global_t + 0.05)
  update_stars()
  intro_timer = (intro_timer - 1)
  if (intro_timer < -30) then
    game_state = "menu"
    return nil
  else
    return nil
  end
end
local function draw_intro()
  cls(0)
  draw_stars()
  draw_wireframe()
  if (intro_timer > 0) then
    return draw_wobbling_text("LES ZIGOTOS V3", 120, 64, 14, global_t)
  else
    return nil
  end
end
local function update_menu()
  global_t = (global_t + 0.05)
  update_stars()
  if (keyp(26) or btnp(4)) then
    game_state = "game"
    return nil
  else
    return nil
  end
end
local function draw_menu()
  cls(0)
  draw_stars()
  draw_wireframe()
  draw_wobbling_text("LES ZIGOTOS V3", 120, 40, 14, global_t)
  menu_blink = (menu_blink + 1)
  if ((menu_blink % 60) < 30) then
    return print("Appuyez sur Z pour jouer", 52, 100, 15)
  else
    return nil
  end
end
local function reset_game()
  joueur = player.new()
  joueur.x = 24
  joueur.y = 64
  clear_list(enemies)
  clear_list(projectiles)
  clear_list(lightning_flashes)
  clear_list(pickups)
  world["construire-map"]()
  setup_room_encounter()
  room_reward_spawned = false
  room_reward_required = false
  shop_items = {}
  shop_msg = ""
  shop_msg_timer = 0
  fx["door-pulse"] = 0
  fx["player-hit-overlay"] = 0
  game_state = "game"
  return nil
end
local function update_gameover()
  if (keyp(26) or btnp(4)) then
    return reset_game()
  else
    return nil
  end
end
local function draw_gameover()
  cls(0)
  print("GAME OVER", 70, 50, 12, false, 2)
  menu_blink = (menu_blink + 1)
  if ((menu_blink % 60) < 30) then
    return print("Appuyez sur Z pour recommencer", 45, 90, 15)
  else
    return nil
  end
end
music(0)
music(0)
_G.TIC = function()
  if not initialized then
    world["init-assets"]()
    setup_room_encounter()
    initialized = true
  else
  end
  tick_fx()
  if (game_state == "intro") then
    update_intro()
    return draw_intro()
  elseif (game_state == "menu") then
    update_menu()
    return draw_menu()
  elseif (game_state == "game") then
    if item["is-open?"](reward_screen) then
      item.update(reward_screen, joueur)
    else
      update_game()
    end
    if (joueur.hp <= 0) then
      game_state = "gameover"
    else
    end
    draw_game()
    if item["is-open?"](reward_screen) then
      return item.draw(reward_screen)
    else
      return nil
    end
  elseif (game_state == "gameover") then
    update_gameover()
    return draw_gameover()
  else
    return nil
  end
end
return _G.TIC
