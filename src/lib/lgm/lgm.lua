lgm_path = "./lib/lgm/"
require(tostring(lgm_path) .. "lgm-base")
require(tostring(lgm_path) .. "lgm-entity")
require(tostring(lgm_path) .. "lgm-entityset")
require(tostring(lgm_path) .. "lgm-segment")
require(tostring(lgm_path) .. "lgm-vector")
LGM = {
  distance = lgm_distance,
  Entity = Entity,
  EntitySet = EntitySet,
  Segment = Segment,
  Vector = Vector
}
