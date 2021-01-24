// File: world.agc
// Created: 21-01-21

// including here is fine right ?
#include "noise.agc"
#include "core.agc"

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
    
	global Frontier as Int2Data[-1]
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
	
	World.Block[BlockX,BlockY].TypID=TypID
	World.Block[BlockX,BlockY].Color.Red=32
	World.Block[BlockX,BlockY].Color.Green=32
	World.Block[BlockX,BlockY].Color.Blue=32
	
//~	if BlockY<World.Height[BlockX] then World.Height[BlockX]=BlockY
	Height=World_GetGroundHeight(BlockX)
	World.Height[BlockX]=Height
	World_SetSunLight(BlockX)
	
	World_CreateSprite(BlockX,BlockY)
endfunction

function World_CreateSprite(BlockX,BlockY)
	BlockX=Core_Clamp(BlockX,1,World.Block.length-1)
	BlockY=Core_Clamp(BlockY,1,World.Block[0].length-1)
	
	TileID=Autotiling(BlockX,BlockY)
	World.Block[BlockX,BlockY].ImageID=TileImageID[TileID]

	if World.Block[BlockX,BlockY].TypID<>0
		if World.Block[BlockX,BlockY].SpriteID=0
			SpriteID=CreateSprite(World.Block[BlockX,BlockY].ImageID)
			SetSpriteSize(SpriteID,WorldTileSize,WorldTileSize)
			SetSpritePositionByOffset(SpriteID,BlockX*WorldTileSize,BlockY*WorldTileSize)
			SetSpriteColor(SpriteID,World.Block[BlockX,BlockY].Color.Red,World.Block[BlockX,BlockY].Color.Green,World.Block[BlockX,BlockY].Color.Blue,255)
			World.Block[BlockX,BlockY].SpriteID=SpriteID
		endif
	endif
	
	if World.Block[BlockX,BlockY-1].TypID<>0
		TileID=Autotiling(BlockX,BlockY-1)
		World.Block[BlockX,BlockY-1].ImageID=TileImageID[TileID]
		if World.Block[BlockX,BlockY-1].SpriteID>0
			SetSpriteImage(World.Block[BlockX,BlockY-1].SpriteID,World.Block[BlockX,BlockY-1].ImageID)
		endif
	endif
	if World.Block[BlockX+1,BlockY].TypID<>0
		TileID=Autotiling(BlockX+1,BlockY)
		World.Block[BlockX+1,BlockY].ImageID=TileImageID[TileID]
		if World.Block[BlockX+1,BlockY].SpriteID>0
			SetSpriteImage(World.Block[BlockX+1,BlockY].SpriteID,World.Block[BlockX+1,BlockY].ImageID)
		endif
	endif
	if World.Block[BlockX,BlockY+1].TypID<>0
		TileID=Autotiling(BlockX,BlockY+1)
		World.Block[BlockX,BlockY+1].ImageID=TileImageID[TileID]
		if World.Block[BlockX,BlockY+1].SpriteID>0
			SetSpriteImage(World.Block[BlockX,BlockY+1].SpriteID,World.Block[BlockX,BlockY+1].ImageID)
		endif
	endif
	if World.Block[BlockX-1,BlockY].TypID<>0
		TileID=Autotiling(BlockX-1,BlockY)
		World.Block[BlockX-1,BlockY].ImageID=TileImageID[TileID]
		if World.Block[BlockX-1,BlockY].SpriteID>0
			SetSpriteImage(World.Block[BlockX-1,BlockY].SpriteID,World.Block[BlockX-1,BlockY].ImageID)
		endif
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
	
	Height=World_GetGroundHeight(BlockX)
	World.Height[BlockX]=Height
	World_SetSunLight(BlockX)
	
	World_DeleteSprite(BlockX,BlockY)
endfunction

function World_DeleteSprite(BlockX,BlockY)
	BlockX=Core_Clamp(BlockX,1,World.Block.length-1)
	BlockY=Core_Clamp(BlockY,1,World.Block[0].length-1)

	DeleteSprite(World.Block[BlockX,BlockY].SpriteID)
	World.Block[BlockX,BlockY].SpriteID=0

	if World.Block[BlockX,BlockY-1].TypID<>0
		TileID=Autotiling(BlockX,BlockY-1)
		World.Block[BlockX,BlockY-1].ImageID=TileImageID[TileID]
		if World.Block[BlockX,BlockY-1].SpriteID>0
			SetSpriteImage(World.Block[BlockX,BlockY-1].SpriteID,World.Block[BlockX,BlockY-1].ImageID)
		endif
	endif
	if World.Block[BlockX+1,BlockY].TypID<>0
		TileID=Autotiling(BlockX+1,BlockY)
		World.Block[BlockX+1,BlockY].ImageID=TileImageID[TileID]
		if World.Block[BlockX+1,BlockY].SpriteID>0
			SetSpriteImage(World.Block[BlockX+1,BlockY].SpriteID,World.Block[BlockX+1,BlockY].ImageID)
		endif
	endif
	if World.Block[BlockX,BlockY+1].TypID<>0
		TileID=Autotiling(BlockX,BlockY+1)
		World.Block[BlockX,BlockY+1].ImageID=TileImageID[TileID]
		if World.Block[BlockX,BlockY+1].SpriteID>0
			SetSpriteImage(World.Block[BlockX,BlockY+1].SpriteID,World.Block[BlockX,BlockY+1].ImageID)
		endif
	endif
	if World.Block[BlockX-1,BlockY].TypID<>0
		TileID=Autotiling(BlockX-1,BlockY)
		World.Block[BlockX-1,BlockY].ImageID=TileImageID[TileID]
		if World.Block[BlockX-1,BlockY].SpriteID>0
			SetSpriteImage(World.Block[BlockX-1,BlockY].SpriteID,World.Block[BlockX-1,BlockY].ImageID)
		endif
	endif
endfunction

function World_Update()	
	ViewLeft=World_GetCameraLeftBound()
	ViewTop=World_GetCameraTopBound()
	ViewRight=World_GetCameraRightBound()
	ViewBottom=World_GetCameraBottomBound()
	
	while Frontier.length>=0
		BlockX=Frontier[0].x
		BlockY=Frontier[0].y
		Frontier.remove(0)
		
		if BlockX>0 and BlockX<World.Block.length and BlockY>0 and BlockY<World.Block[0].length
			Red=World.Block[BlockX,BlockY].Color.Red
			Green=World.Block[BlockX,BlockY].Color.Green
			Blue=World.Block[BlockX,BlockY].Color.Blue
			
			for NeighbourID=0 to BlockNeighbors.length
				NeighbourX=BlockX+BlockNeighbors[NeighbourID].X
				NeighbourY=BlockY+BlockNeighbors[NeighbourID].Y
				if World.Block[NeighbourX,NeighbourY].Color.Red<Red or World.Block[NeighbourX,NeighbourY].Color.Green<Green or World.Block[NeighbourX,NeighbourY].Color.Blue<Blue
					TempFrontier.X=NeighbourX
					TempFrontier.Y=NeighbourY
					Frontier.insert(TempFrontier)
					
					if World.Block[NeighbourX,NeighbourY].TypID=0
						World.Block[NeighbourX,NeighbourY].Color.Red=Red*0.7
						World.Block[NeighbourX,NeighbourY].Color.Green=Green*0.7
						World.Block[NeighbourX,NeighbourY].Color.Blue=Blue*0.7
						if World.Block[NeighbourX,NeighbourY].SpriteID>0
							SetSpriteColor(World.Block[NeighbourX,NeighbourY].SpriteID,Red*0.9,Green*0.9,Blue*0.9,255)
						endif
					else
						World.Block[NeighbourX,NeighbourY].Color.Red=Red*0.5
						World.Block[NeighbourX,NeighbourY].Color.Green=Green*0.5
						World.Block[NeighbourX,NeighbourY].Color.Blue=Blue*0.5
						if World.Block[NeighbourX,NeighbourY].SpriteID>0
							SetSpriteColor(World.Block[NeighbourX,NeighbourY].SpriteID,Red*0.8,Green*0.8,Blue*0.8,255)
						endif
					endif
				endif
			next NeighbourID
		endif
	endwhile

    FrameTime#=GetFrameTime()
    
    Speed#=100.0
	if getrawkeystate(68)
		ViewSpeedX#=Speed#*FrameTime#
		ViewPosX#=ViewPosX#+ViewSpeedX#
	endif
	if getrawkeystate(65)
		ViewSpeedX#=-Speed#*FrameTime#
		ViewPosX#=ViewPosX#+ViewSpeedX#
	endif
	if getrawkeystate(83)
		ViewSpeedY#=Speed#*FrameTime#
		ViewPosY#=ViewPosy#+ViewSpeedY#
	endif
	if getrawkeystate(87)
		ViewSpeedY#=-Speed#*FrameTime#
		ViewPosY#=ViewPosy#+ViewSpeedY#
	endif
	if getrawkeystate(81) then ViewZoom#=ViewZoom#-0.5*FrameTime#
	if getrawkeystate(69) then ViewZoom#=ViewZoom#+0.5*FrameTime#
    
    SetViewZoom(ViewZoom#)
	SetViewOffset(ViewPosX#,ViewPosY#)
	
	CameraBlockX=round(ViewPosX#/WorldTileSize)
	CameraBlockY=round(ViewPosY#/WorldTileSize)
	
	if CameraBlockX<>OldCameraBlockX
		OldCameraBlockX=CameraBlockX
		ViewSignX=abs(Core_sign(ViewSpeedX#/WorldTileSize))
		if ViewSpeedX#>0
			for BlockX=ViewLeft to ViewLeft-ViewSignX step -1
				NewBlockX=Core_max(BlockX,0)
				for BlockY=ViewTop to ViewBottom
					World_DeleteSprite(NewBlockX,BlockY)
				next BlockY
			next BlockX
			for BlockX=ViewRight to ViewRight+ViewSignX
				NewBlockX=Core_min(BlockX,World.Block.length)
				
				World_SetSunLight(NewBlockX)
				
				for BlockY=ViewTop to ViewBottom
					World_CreateSprite(NewBlockX,BlockY)
				next BlockY
			next BlockX
		elseif ViewSpeedX#<0
			for BlockX=ViewRight to ViewRight+ViewSignX
				NewBlockX=Core_min(BlockX,World.Block.length)
				for BlockY=ViewTop to ViewBottom
					World_DeleteSprite(NewBlockX,BlockY)
				next BlockY
			next BlockX
			for BlockX=ViewLeft to ViewLeft-ViewSignX step -1
				NewBlockX=Core_max(BlockX,0)
				
				World_SetSunLight(NewBlockX)
				
				for BlockY=ViewTop to ViewBottom
					World_CreateSprite(NewBlockX,BlockY)
				next BlockY
			next BlockX
		endif
	endif
	if CameraBlockY<>OldCameraBlockY
		OldCameraBlockY=CameraBlockY
		ViewSignY=abs(Core_sign(ViewSpeedY#/WorldTileSize))
		if ViewSpeedY#>0
			for BlockY=ViewTop to ViewTop-ViewSignY step -1
				NewBlockY=Core_max(BlockY,0)
				for BlockX=ViewLeft to ViewRight
					World_DeleteSprite(BlockX,NewBlockY)
				next BlockX
			next BlockY
			for BlockY=ViewBottom to ViewBottom+ViewSignY
				NewBlockY=Core_min(BlockY,World.Block.length)
				for BlockX=ViewLeft to ViewRight
					World_CreateSprite(BlockX,NewBlockY)
				next BlockX
			next BlockY
		elseif ViewSpeedY#<0
			for BlockY=ViewBottom to ViewBottom+ViewSignY
				NewBlockY=Core_min(BlockY,World.Block.length)
				for BlockX=ViewLeft to ViewRight
					World_DeleteSprite(BlockX,NewBlockY)
				next BlockX
			next BlockY
			for BlockY=ViewTop to ViewTop-ViewSignY step -1
				NewBlockY=Core_max(BlockY,0)
				for BlockX=ViewLeft to ViewRight
					World_CreateSprite(BlockX,NewBlockY)
				next BlockX
			next BlockY
		endif
	endif
	
	/*
	for BlockX=ViewLeftClamp to ViewRightClamp
		GroundY=World_GetGroundHeight(BlockX)
		if GroundY>0
			World.Block[BlockX,GroundY].Color.Red=255
			World.Block[BlockX,GroundY].Color.Green=255
			World.Block[BlockX,GroundY].Color.Blue=255
		endif
		for BlockY=ViewTopClamp to ViewBottomClamp
			World_CalculateLight(BlockX,BlockY)
		next BlockY
	next BlockX
	
	for BlockX=ViewRightClamp to ViewLeftClamp
		for BlockY=ViewBottomClamp to ViewTopClamp
			World_CalculateLight(BlockX,BlockY)
		next BlockY
	next BlockX*/

	/*
	for BlockX=ViewLeftClamp to ViewRightClamp
		for BlockY=ViewTopClamp to ViewBottomClamp	
			if World.Block[BlockX,BlockY].TypID<>0
				SetSpritePositionByOffset(WorldSpriteID,BlockX*WorldTileSize,BlockY*WorldTileSize)
				SetSpriteImage(WorldSpriteID,World.Block[BlockX,BlockY].ImageID)
				    
			    regionIndex=World.Block[BlockX,BlockY].ImageID
				U#=mod(regionIndex,NumberTilesX)/(NumberTilesX+0.0)
				V#=(regionIndex/NumberTilesY)/(NumberTilesY+0.0)
				SetSpriteUVOffset(WorldSpriteID,U#,V#)
				SetSpriteColor(WorldSpriteID,World.Block[BlockX,BlockY].Color.Red,World.Block[BlockX,BlockY].Color.Green,World.Block[BlockX,BlockY].Color.Blue,255)
				DrawSprite(WorldSpriteID)
			endif
			World.Block[BlockX,BlockY].OldColor.Red=World.Block[BlockX,BlockY].Color.Red
			World.Block[BlockX,BlockY].OldColor.Green=World.Block[BlockX,BlockY].Color.Green
			World.Block[BlockX,BlockY].OldColor.Blue=World.Block[BlockX,BlockY].Color.Blue
		next BlockY
	next BlockX*/
endfunction

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

function World_CalculateLight(BlockX,BlockY)
	RedBottom=0
	GreenBottom=0
	BlueBottom=0
	RedRight=0
	GreenRight=0
	BlueRight=0
	RedTop=0
	GreenTop=0
	BlueTop=0
	RedLeft=0
	GreenLeft=0
	BlueLeft=0
	
	RedBottom=World.Block[BlockX,BlockY+1].OldColor.Red
	GreenBottom=World.Block[BlockX,BlockY+1].OldColor.Green
	BlueBottom=World.Block[BlockX,BlockY+1].OldColor.Blue

	RedRight=World.Block[BlockX+1,BlockY].OldColor.Red
	GreenRight=World.Block[BlockX+1,BlockY].OldColor.Green
	BlueRight=World.Block[BlockX+1,BlockY].OldColor.Blue

	RedTop=World.Block[BlockX,BlockY-1].OldColor.Red
	GreenTop=World.Block[BlockX,BlockY-1].OldColor.Green
	BlueTop=World.Block[BlockX,BlockY-1].OldColor.Blue
	
	RedLeft=World.Block[BlockX-1,BlockY].OldColor.Red
	GreenLeft=World.Block[BlockX-1,BlockY].OldColor.Green
	BlueLeft=World.Block[BlockX-1,BlockY].OldColor.Blue

	MaxRed=Core_max(RedBottom,Core_max(RedRight,Core_max(RedTop,RedLeft))) // this can be optimized
	MaxGreen=Core_max(GreenBottom,Core_max(GreenRight,Core_max(GreenTop,GreenLeft)))
	MaxBlue=Core_max(BlueBottom,Core_max(BlueRight,Core_max(BlueTop,BlueLeft)))
	
	if World.Block[BlockX,BlockY].TypID=0
		Attenuation#=0.92
		World.Block[BlockX,BlockY].Color.Red=(World.Block[BlockX,BlockY].Color.Red+MaxRed)*0.5*Attenuation#
		World.Block[BlockX,BlockY].Color.Green=(World.Block[BlockX,BlockY].Color.Green+MaxGreen)*0.5*Attenuation#
		World.Block[BlockX,BlockY].Color.Blue=(World.Block[BlockX,BlockY].Color.Blue+MaxBlue)*0.5*Attenuation#
	else
		Attenuation#=0.7
		World.Block[BlockX,BlockY].Color.Red=(World.Block[BlockX,BlockY].Color.Red+MaxRed)*0.5*Attenuation#
		World.Block[BlockX,BlockY].Color.Green=(World.Block[BlockX,BlockY].Color.Green+MaxGreen)*0.5*Attenuation#
		World.Block[BlockX,BlockY].Color.Blue=(World.Block[BlockX,BlockY].Color.Blue+MaxBlue)*0.5*Attenuation#
	endif
endfunction

function World_SetSunLight(BlockX) // need a function to also remove the last sunlight if there is a new higher point
	BlockY=World.Height[BlockX]
	if BlockY>=0
		World.Block[BlockX,BlockY].Color.Red=255
		World.Block[BlockX,BlockY].Color.Green=255
		World.Block[BlockX,BlockY].Color.Blue=255
		
		TempFrontier.X=BlockX
		TempFrontier.Y=BlockY
		Frontier.insert(TempFrontier)
	endif
endfunction

function World_GetGroundHeight(BlockX)
	for BlockY=1 to World.Block[0].length
		if World.Block[BlockX,BlockY].TypID<>0 then exitfunction BlockY
	next BlockY
endfunction 0

function World_CreateLight(BlockX,BlockY,Range,Red,Green,Blue)
	TempLight as LightData
	TempLight.Pos.X=BlockX
	TempLight.Pos.Y=BlockY
	TempLight.Range=Range
	TempLight.Color.Red=Red
	TempLight.Color.Green=Green
	TempLight.Color.Blue=Blue
	World.Light.insert(TempLight)
	
	World.Block[BlockX,BlockY].Color.Red=Red
	World.Block[BlockX,BlockY].Color.Green=Green
	World.Block[BlockX,BlockY].Color.Blue=Blue
	
	TempFrontier.X=BlockX
	TempFrontier.Y=BlockY
	Frontier.insert(TempFrontier)
endfunction World.Light.length

function World_DeleteLight(LightID)
	World.Light.remove(LightID)
endfunction