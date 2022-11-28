---@param plugin LazyPlugin
---@param filter fun(task:LazyTask):boolean?
local function has_task(plugin, filter)
  if plugin._.tasks then
    for _, task in ipairs(plugin._.tasks) do
      if filter(task) then
        return true
      end
    end
  end
end

---@alias LazySection {title:string, filter:fun(plugin:LazyPlugin):boolean?}

---@type LazySection[]
return {
  {
    filter = function(plugin)
      return has_task(plugin, function(task)
        return task.error ~= nil
      end)
    end,
    title = "Failed",
  },
  {
    filter = function(plugin)
      return has_task(plugin, function(task)
        return task:is_running()
      end)
    end,
    title = "Working",
  },
  {
    filter = function(plugin)
      return has_task(plugin, function(task)
        if task.type ~= "log" then
          return
        end
        local lines = vim.split(task.output, "\n")
        for _, line in ipairs(lines) do
          if line:find("^%w+ %S+!:") then
            return true
          end
        end
      end)
    end,
    title = "Breaking Changes",
  },
  {
    ---@param plugin LazyPlugin
    filter = function(plugin)
      return plugin._.updated and plugin._.updated.from ~= plugin._.updated.to
    end,
    title = "Updated",
  },
  {
    filter = function(plugin)
      return has_task(plugin, function(task)
        return task.type == "log" and vim.trim(task.output) ~= ""
      end)
    end,
    title = "Log",
  },
  {
    filter = function(plugin)
      return plugin._.installed and not plugin.uri
    end,
    title = "Clean",
  },
  {
    filter = function(plugin)
      return not plugin._.installed and not plugin.uri
    end,
    title = "Cleaned",
  },
  {
    filter = function(plugin)
      return plugin._.loaded
    end,
    title = "Loaded",
  },
  {
    filter = function(plugin)
      return plugin._.installed
    end,
    title = "Installed",
  },
  {
    filter = function()
      return true
    end,
    title = "Not Installed",
  },
}
