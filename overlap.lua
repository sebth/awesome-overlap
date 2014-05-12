--- Overlapping tiling layout for awesome window manager.
-- @author Sebastian Thorarensen &lt;sebth@naju.se&gt;

local overlap = { name = "overlap" }
local tag = require "awful.tag"

local function getnlayers(nother, ncol)
  local nlayers = {}
  for i = 0,nother-1 do
    local col = ncol - i % ncol
    nlayers[col] = (nlayers[col] == nil and 0 or nlayers[col]) + 1
  end
  return nlayers
end

function overlap.arrange(p, orientation)
  orientation = orientation or "right"

  local width, height, x, y = "width", "height", "x", "y"
  if orientation == "top" or orientation == "bottom" then
    width, height, x, y = "height", "width", "y", "x"
  end

  local cls = p.clients
  local wa = p.workarea
  local t = tag.selected(p.screen)
  local nmaster = tag.getnmaster(t)
  local nother = #cls - nmaster
  local ncol = math.min(tag.getncol(t), nother)
  local mwidth = nmaster > 0 and (#cls > nmaster and wa[width] *
                                  tag.getmwfact(t) or wa[width]) or 0
  local owidth = (wa[width] - mwidth) / ncol
  local nlayers = getnlayers(nother, ncol)

  local col, layer = 1, 1
  for i,c in ipairs(cls) do
    local g = { [y] = wa[y], [height] = wa[height] }

    if i <= nmaster then
      g[width] = mwidth
      g[x] = wa[x]
    else
      g[width] = owidth
      g[x] = wa[x] + mwidth + (col - 1)*owidth
      layer = layer + 1
      if layer > nlayers[col] then
        col = col + 1
        layer = 1
      end
    end

    if orientation == "left" or orientation == "top" then
      g[x] = wa[width] - g[x] - g[width] + 2*wa[x]
    end
    c:geometry(g)
  end
end

overlap.left = { name = "overlapleft" }
function overlap.left.arrange(p)
  return overlap.arrange(p, "left")
end

overlap.bottom = { name = "overlapbottom" }
function overlap.bottom.arrange(p)
  return overlap.arrange(p, "bottom")
end

overlap.top = { name = "overlaptop" }
function overlap.top.arrange(p)
  return overlap.arrange(p, "top")
end

return overlap
