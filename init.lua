local fill = {}
local pos1 = {}
local pos2 = {}
local selected_node = {}
local delete_mode = {}

local function sort_pos(p1, p2)
    return {
        x = math.min(p1.x, p2.x),
        y = math.min(p1.y, p2.y),
        z = math.min(p1.z, p2.z),
    }, {
        x = math.max(p1.x, p2.x),
        y = math.max(p1.y, p2.y),
        z = math.max(p1.z, p2.z),
    }
end

minetest.register_chatcommand("pos1", {
    privs = {server=true},
    func = function(name)
        local player = minetest.get_player_by_name(name)
        if not player then return end
        pos1[name] = vector.round(player:get_pos())
        return true, "Position 1 set to "..minetest.pos_to_string(pos1[name])
    end
})

minetest.register_chatcommand("pos2", {
    privs = {server=true},
    func = function(name)
        local player = minetest.get_player_by_name(name)
        if not player then return end
        pos2[name] = vector.round(player:get_pos())
        return true, "Position 2 set to "..minetest.pos_to_string(pos2[name])
    end
})

minetest.register_chatcommand("setnode", {
    privs = {server=true},
    func = function(name)
        local player = minetest.get_player_by_name(name)
        if not player then return end
        local item = player:get_wielded_item()
        if item:is_empty() then return false, "Hold a node in your hand." end
        selected_node[name] = item:get_name()
        return true, "Selected node: "..selected_node[name]
    end
})

minetest.register_chatcommand("fill", {
    description = "Fill selected area",
    privs = {server=true},
    func = function(name)
        if not pos1[name] or not pos2[name] then return false, "Set pos1 and pos2 first." end
        if not selected_node[name] then return false, "Use /setnode first." end
        local p1, p2 = sort_pos(pos1[name], pos2[name])
        local count = 0
        for x = p1.x, p2.x do
            for y = p1.y, p2.y do
                for z = p1.z, p2.z do
                    local current_node = minetest.get_node({x=x,y=y,z=z})
                    if current_node.name ~= "air" and not current_node.name:find("water") then
                        minetest.set_node({x=x,y=y,z=z}, {name=selected_node[name]})
                        count = count + 1
                    end
                end
            end
        end
        return true, "Filled "..count.." nodes with "..selected_node[name]
    end
})

minetest.register_chatcommand("delete", {
    description = "Delete all blocks within pos1 and pos2",
    privs = {server=true},
    func = function(name)
        if not pos1[name] or not pos2[name] then return false, "Set pos1 and pos2 first." end
        local p1, p2 = sort_pos(pos1[name], pos2[name])
        local count = 0
        for x = p1.x, p2.x do
            for y = p1.y, p2.y do
                for z = p1.z, p2.z do
                    local current_node = minetest.get_node({x=x,y=y,z=z})
                    if current_node.name ~= "air" and not current_node.name:find("water") then
                        minetest.set_node({x=x,y=y,z=z}, {name="air"})
                        count = count + 1
                    end
                end
            end
        end
        return true, "Deleted "..count.." nodes within the selected area"
    end
})
