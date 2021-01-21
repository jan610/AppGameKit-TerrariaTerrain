// File: world.agc
// Created: 21-01-21

// including here is fine right ?
#include "noise.agc"
#include "core.agc"

type ColorData
	Red as integer
	Green as integer
	Blue as integer
endtype

type BlockData
	TypID as integer
	ImageID as integer
	Color as ColorData
endtype

type WorldData
	Block as BlockData[-1,-1]
	Biome as integer[-1]
endtype

#constant BLOCK_AIR		0
#constant BLOCK_DIRT		1

function World_Init(WorldSizeX,WorldSizeY,TileSize)
	AtlasImageID=loadimage("images/Tiles32.png")
	SetImageMagFilter(AtlasImageID,0)
	
	global TileImageID as integer[15]
	for Index=0 to TileImageID.length
		TileImageID[Index]=LoadSubImage(AtlasImageID,"img"+str(Index)) //For now I use LoadSubImage but i will make a shader for it
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
			BlockTypID=round(Noise#)
			
			World_CreateBlock(BlockX,BlockY,BlockTypID)
		next BlockY
	next BlockX
	
	global WorldSpriteID
	WorldSpriteID=createsprite(TileImageID[0])
	SetSpriteSize(WorldSpriteID,TileSize,TileSize)
	SetSpriteSnap(WorldSpriteID,1)
	
	global WorldTileSize
	WorldTileSize=TileSize
endfunction

function World_GetBlockTypID(BlockX,BlockY)
endfunction World.Block[BlockX,BlockY].TypID

function Autotiling(BlockX,BlockY)
	BlockX=Core_Clamp(BlockX,1,World.Block.length-1)
	BlockY=Core_Clamp(BlockY,1,World.Block[0].length-1)

	if World.Block[BlockX,BlockY-1].TypID<>0 then TileBit=TileBit+1
	if World.Block[BlockX+1,BlockY].TypID<>0 then TileBit=TileBit+2
	if World.Block[BlockX,BlockY+1].TypID<>0 then TileBit=TileBit+4
	if World.Block[BlockX-1,BlockY].TypID<>0 then TileBit=TileBit+8
endfunction TileBit

function World_CreateBlock(BlockX,BlockY,TypID)
	BlockX=Core_Clamp(BlockX,1,World.Block.length-1)
	BlockY=Core_Clamp(BlockY,1,World.Block[0].length-1)
	
	World.Block[BlockX,BlockY].Color.Red=255
	World.Block[BlockX,BlockY].Color.Green=255
	World.Block[BlockX,BlockY].Color.Blue=255
	World.Block[BlockX,BlockY].TypID=TypID
	TileBit=Autotiling(BlockX,BlockY)
	World.Block[BlockX,BlockY].ImageID=TileImageID[TileBit]

	if World.Block[BlockX,BlockY-1].TypID<>0
		TileBit=Autotiling(BlockX,BlockY-1)
		World.Block[BlockX,BlockY-1].ImageID=TileImageID[TileBit]
	endif
	if World.Block[BlockX+1,BlockY].TypID<>0
		TileBit=Autotiling(BlockX+1,BlockY)
		World.Block[BlockX+1,BlockY].ImageID=TileImageID[TileBit]
	endif
	if World.Block[BlockX,BlockY+1].TypID<>0
		TileBit=Autotiling(BlockX,BlockY+1)
		World.Block[BlockX,BlockY+1].ImageID=TileImageID[TileBit]
	endif
	if World.Block[BlockX-1,BlockY].TypID<>0
		TileBit=Autotiling(BlockX-1,BlockY)
		World.Block[BlockX-1,BlockY].ImageID=TileImageID[TileBit]
	endif
endfunction

function World_DeleteBlock(BlockX,BlockY)
	BlockX=Core_Clamp(BlockX,1,World.Block.length-1)
	BlockY=Core_Clamp(BlockY,1,World.Block[0].length-1)
	
	World.Block[BlockX,BlockY].ImageID=0
	World.Block[BlockX,BlockY].TypID=0
	World.Block[BlockX,BlockY].Color.Red=0
	World.Block[BlockX,BlockY].Color.Green=0
	World.Block[BlockX,BlockY].Color.Blue=0

	if World.Block[BlockX,BlockY-1].TypID<>0
		TileBit=Autotiling(BlockX,BlockY-1)
		World.Block[BlockX,BlockY-1].ImageID=TileImageID[TileBit]
	endif
	if World.Block[BlockX+1,BlockY].TypID<>0
		TileBit=Autotiling(BlockX+1,BlockY)
		World.Block[BlockX+1,BlockY].ImageID=TileImageID[TileBit]
	endif
	if World.Block[BlockX,BlockY+1].TypID<>0
		TileBit=Autotiling(BlockX,BlockY+1)
		World.Block[BlockX,BlockY+1].ImageID=TileImageID[TileBit]
	endif
	if World.Block[BlockX-1,BlockY].TypID<>0
		TileBit=Autotiling(BlockX-1,BlockY)
		World.Block[BlockX-1,BlockY].ImageID=TileImageID[TileBit]
	endif
endfunction

function World_Update()
	ViewLeft=trunc(ScreenToWorldX(GetScreenBoundsLeft())/WorldTileSize)
	ViewTop=trunc(ScreenToWorldY(GetScreenBoundsTop())/WorldTileSize)
	ViewRight=trunc(ScreenToWorldX(GetScreenBoundsRight())/WorldTileSize)
	ViewBottom=trunc(ScreenToWorldY(GetScreenBoundsBottom())/WorldTileSize)
	
	ViewLeftClamp=Core_Clamp(ViewLeft-1,0,World.Block.length)
	ViewTopClamp=Core_Clamp(ViewTop-1,0,World.Block[0].length)
	ViewRightClamp=Core_Clamp(ViewRight+1,0,World.Block.length)
	ViewBottomClamp=Core_Clamp(ViewBottom+1,0,World.Block[0].length)
	
	for BlockX=ViewLeftClamp to ViewRightClamp
		for BlockY=ViewTopClamp to ViewBottomClamp
			if World.Block[BlockX,BlockY].TypID<>0
				SetSpritePositionByOffset(WorldSpriteID,BlockX*WorldTileSize,BlockY*WorldTileSize)
				SetSpriteImage(WorldSpriteID,World.Block[BlockX,BlockY].ImageID)
				SetSpriteColor(WorldSpriteID,World.Block[BlockX,BlockY].Color.Red,World.Block[BlockX,BlockY].Color.Green,World.Block[BlockX,BlockY].Color.Blue,255)
				DrawSprite(WorldSpriteID)
			endif
		next BlockY
	next BlockX
endfunction