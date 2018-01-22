Page = {
  classname = "FNPage",
}


function Page:new(page_name, gui_name, num_per_page, forward_func, back_func)

  local obj = {
    page_name = page_name,
    num_per_page = num_per_page,
    forward_func = forward_func,
    back_func = back_func,
  }

  function init()
    Events.add_custom_event(gui_name, "sprite-button", obj.page_name .. "-forward", obj.page_forward_event)
    Events.add_custom_event(gui_name, "sprite-button", obj.page_name .. "-back", obj.page_back_event)
  end

  function obj:get_page_global()
    local global = Player.get_global()
    if not global["page-" .. page_name] then global["page-" .. page_name] = {} end
    return global["page-" .. page_name]
  end

  function obj:get_cur_page()
    return obj:get_page_global().cur_page or 1
  end

  function obj:set_cur_page(val)
    local max_page = self:amount_page()
    if max_page < 1 then max_page = 1 end
    local gl_page = obj:get_page_global()
    
    if val < 1 then 
      gl_page.cur_page = max_page
    elseif val > max_page then
      gl_page.cur_page = 1
    else
      gl_page.cur_page = val
    end
  end

  function obj:amount_page()
    return math.ceil(#obj:get_page_list() / self.num_per_page)
  end

  function obj:set_page_list(item_list)
    local page_list = {}

    for _, item in pairs(item_list) do
      if type(item) == "string" then
        table.insert(page_list, item)
      elseif item.name and type(item.name) == "string" then
        table.insert(page_list, item.name)
      end
    end

    self:get_page_global().list = page_list

    --set new cur_page
    local max_tab = self:amount_page()
    local cur_tab = self:get_cur_page()
    if cur_tab > max_tab then
      obj:set_cur_page(max_tab)
    end
  end

  function obj:get_page_list()
    return self:get_page_global().list
  end

  function obj:get_list_for_tab(tab_namber)
    if tab_namber < 1 and tab_namber > obj:amount_page() then
      return {}
    end
    local src_list = obj:get_page_list()
    local ret_list = {}

    local beg_ind = (tab_namber - 1) * self.num_per_page + 1
    local end_ind = math.min(tab_namber * self.num_per_page, #src_list)

    for i = beg_ind, end_ind do
      table.insert(ret_list, src_list[i])
    end

    return ret_list
  end

  function obj:draw_forward_arrow( parent )
    Gui.add_sprite_button(parent, { type = "sprite-button", name = self.page_name .. "-forward", style = "fnei_right_arrow_button_style" })
  end

  function obj:draw_back_arrow( parent )
    Gui.add_sprite_button(parent, { type = "sprite-button", name = self.page_name .. "-back", style = "fnei_left_arrow_button_style" })
  end

  function obj.page_forward_event(event, name)
    out(name)

    obj:set_cur_page(obj:get_cur_page() + 1)
    out(obj:get_cur_page())

    if obj.forward_func then
      obj.forward_func(event, tab_name)
    end
  end

  function obj.page_back_event(event, name)
    out(name)

    obj:set_cur_page(obj:get_cur_page() - 1)
    out(obj:get_cur_page())

    if obj.back_func then
      obj.back_func(event, tab_name)
    end

    local list = obj:get_list_for_tab(obj:get_cur_page())
    for _,el in pairs(list) do
      out(el)
    end

  end

  init()
  setmetatable(obj, self)
  self.__index = self; return obj
end