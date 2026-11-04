-- Handles ::: {.instructor} blocks according to the `mode` metadata:
--   full (default)  instructor notes shown as red callouts (what you see in preview)
--   attendee        instructor notes removed
--   instructor      only the instructor notes, under the headings they belong to
--
-- Each note is wrapped in a div with class "instructor-note", which
-- scripts/check.sh looks for to make sure no notes leak into attendee copies.

local mode = "full"

local function is_instructor(el)
  return el.t == "Div" and el.classes:includes("instructor")
end

local function as_callout(div)
  return pandoc.Div(
    quarto.Callout({
      type = "important",
      title = "Instructor notes",
      icon = false,
      content = div.content,
    }),
    pandoc.Attr("", { "instructor-note" })
  )
end

-- Number headings ourselves (before any are dropped) so the guide's
-- section numbers match the attendee notes
local function number_headers(blocks)
  local counts = {}
  for _, el in ipairs(blocks) do
    if el.t == "Header" and not el.classes:includes("unnumbered") then
      counts[el.level] = (counts[el.level] or 0) + 1
      for level = el.level + 1, 6 do counts[level] = nil end
      local parts = {}
      for level = 1, el.level do table.insert(parts, tostring(counts[level] or 0)) end
      el.content:insert(1, pandoc.Space())
      el.content:insert(1, pandoc.Span(table.concat(parts, "."), { class = "header-section-number" }))
    end
    if el.t == "Header" then el.classes:insert("unnumbered") end
  end
end

-- Keep only headings and instructor notes, then drop headings with no notes under them
local function instructor_only(doc)
  if doc.meta["number-sections"] then number_headers(doc.blocks) end

  local kept = pandoc.List()
  for _, block in ipairs(doc.blocks) do
    if block.t == "Header" then
      kept:insert(block)
    elseif is_instructor(block) then
      kept:insert(as_callout(block))
    else
      block:walk({
        Div = function(div)
          if is_instructor(div) then kept:insert(as_callout(div)) end
        end,
      })
    end
  end

  local result = pandoc.List()
  for i, block in ipairs(kept) do
    local keep = true
    if block.t == "Header" then
      keep = false
      for j = i + 1, #kept do
        if kept[j].t ~= "Header" then keep = true break end
        if kept[j].level <= block.level then break end
      end
    end
    if keep then result:insert(block) end
  end

  doc.blocks = result
  doc.meta.subtitle = "Instructor guide"
  return doc
end

return {
  {
    Meta = function(meta)
      if meta.mode then mode = pandoc.utils.stringify(meta.mode) end
    end,
  },
  {
    Div = function(div)
      if not is_instructor(div) or mode == "instructor" then return nil end
      if mode == "attendee" then return {} end
      return as_callout(div)
    end,
    Pandoc = function(doc)
      if mode == "instructor" then return instructor_only(doc) end
    end,
  },
}
