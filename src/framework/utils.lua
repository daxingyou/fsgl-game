function circleIntersectRect(circle_pt, radius, rect)
  local cx, cy
  if circle_pt.x < rect.x then
    cx = rect.x
  elseif circle_pt.x > rect.x + rect.width then
    cx = rect.x + rect.width
  else
    cx = circle_pt.x
  end
  if circle_pt.y < rect.y then
    cy = rect.y
  elseif circle_pt.y > rect.y + rect.height then
    cy = rect.y + rect.height
  else
    cy = circle_pt.y
  end
  local distance = cc.pGetDistance(circle_pt, cc.p(cx, cy))
  if radius > distance then
    return true, distance
  end
  return false, distance
end
function circleIntersects(circle_pt_a, radius_a, circle_pt_b, radius_b)
  if cc.pGetDistance(circle_pt_a, circle_pt_b) < radius_a + radius_b then
    return true
  end
  return false
end
