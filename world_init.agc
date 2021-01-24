// File: world_init.agc
// Created: 21-01-21

#include "noise.agc"
#include "core.agc"
#include "World_terrain.agc"
#include "World_light.agc"

type Vec2Data
	X# as float
	Y# as float
endtype

type Int2Data
	X as integer
	Y as integer
endtype

type ColorData
	Red as integer
	Green as integer
	Blue as integer
endtype

type LightData
	Pos as Int2Data
	Range as integer
	Color as ColorData
endtype

type BlockData
	TypID as integer
	ImageID as integer
	SpriteID as integer
	Color as ColorData
	OldColor as ColorData
endtype

type WorldData
	Block as BlockData[-1,-1]
	Biome as integer[-1]
	Height as integer[-1]
	Light as LightData[-1]
endtype

#constant BLOCK_AIR		0
#constant BLOCK_DIRT		1

function World_Init(WorldSizeX,WorldSizeY,TileSize)
	global WorldTileSize
	WorldTileSize=TileSize
	
	AtlasImageID=loadimage("images/Tiles32.png")
	SetImageMagFilter(AtlasImageID,0)
	
	global TileImageID as integer[15]
	for Index=0 to TileImageID.length
		TileImageID[Index]=LoadSubImage(AtlasImageID,"img"+str(Index))
	next
	
	global World as WorldData
	World.Block.length=WorldSizeX
	World.Biome.length=WorldSizeX
	for BlockX=0 to World.Block.length
		World.Block[BlockX].length=WorldSizeY
		World.Biome[BlockX]=0 // I need a 1D Noise Function here
	next BlockX
	
	Noise_Init()
	Noise_Seed(257)
	Frecueny#=10.0
	
	for BlockX=0 to World.Block.length
		for BlockY=World.Block[0].length to 0 step -1
			Noise#=0.5+Noise_Perlin2(BlockX/Frecueny#,BlockY/Frecueny#)
			World.Block[BlockX,BlockY].TypID=round(Noise#)
			World.Block[BlockX,BlockY].Color.Red=32
			World.Block[BlockX,BlockY].Color.Green=32
			World.Block[BlockX,BlockY].Color.Blue=32
		next BlockY
		Height=World_GetGroundHeight(BlockX)
		World.Height.insert(Height)
	next BlockX
	
	ViewLeft=World_GetCameraLeftBound()
	ViewTop=World_GetCameraTopBound()
	ViewRight=World_GetCameraRightBound()
	ViewBottom=World_GetCameraBottomBound()
	
	for BlockX=ViewLeft to ViewRight
		for BlockY=ViewTop to ViewBottom	
			World_CreateSprite(BlockX,BlockY)
		next BlockY
		
		World_SetSunLight(BlockX)
	next BlockX
	
	Global NumberTilesX
	Global NumberTilesY
    NumberTilesX=GetImageWidth(AtlasImageID)/32.0
    NumberTilesY=GetImageHeight(AtlasImageID)/32.0
    
	global AddLightFrontier as Int2Data[-1]
	global RemoveLightFrontier as Int2Data[-1]
	global TempFrontier as Int2Data
	
	global BlockNeighbors as Int2Data[3]
	
	BlockNeighbors[0].x=1
	BlockNeighbors[0].y=0
	
	BlockNeighbors[1].x=0
	BlockNeighbors[1].y=1
	
	BlockNeighbors[2].x=-1
	BlockNeighbors[2].y=0
	
	BlockNeighbors[3].x=0
	BlockNeighbors[3].y=-1
	
	global ViewZoom#
	ViewZoom#=1.0
	
	global ViewPosX#
	global ViewPosY#
endfunction

function World_GetGroundHeight(BlockX)
	for BlockY=1 to World.Block[0].length
		if World.Block[BlockX,BlockY].TypID<>0 then exitfunction BlockY
	next BlockY
endfunction 0

function World_GetBlockTypID(BlockX,BlockY)
endfunction World.Block[BlockX,BlockY].TypID

function World_GetCameraLeftBound()
	ViewLeft=round(ScreenToWorldX(GetScreenBoundsLeft())/WorldTileSize)-1
	ViewLeftClamp=Core_Clamp(ViewLeft,0,World.Block.length)
endfunction ViewLeftClamp

function World_GetCameraTopBound()
	ViewTop=round(ScreenToWorldY(GetScreenBoundsTop())/WorldTileSize)-1
	ViewTopClamp=Core_Clamp(ViewTop,0,World.Block[0].length)
endfunction ViewTopClamp

function World_GetCameraRightBound()
	ViewRight=round(ScreenToWorldX(GetScreenBoundsRight())/WorldTileSize)+1
	ViewRightClamp=Core_Clamp(ViewRight,0,World.Block.length)
endfunction ViewRightClamp

function World_GetCameraBottomBound()
	ViewBottom=round(ScreenToWorldY(GetScreenBoundsBottom())/WorldTileSize)+1
	ViewBottomClamp=Core_Clamp(ViewBottom,0,World.Block[0].length)
endfunction ViewBottomClamp