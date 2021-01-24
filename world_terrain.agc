// File: world_terrain.agc
// Created: 21-01-21

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
	world_ColculateLight()
	
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
	
	ViewLeft=World_GetCameraLeftBound()
	ViewTop=World_GetCameraTopBound()
	ViewRight=World_GetCameraRightBound()
	ViewBottom=World_GetCameraBottomBound()
	
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