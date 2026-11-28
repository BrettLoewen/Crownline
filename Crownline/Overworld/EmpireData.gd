class_name EmpireData
extends RefCounted

var id: String
var name: String
var commodityData: Dictionary[Commodity.CommodityType, CommodityData] = {}

var empire: Empire
