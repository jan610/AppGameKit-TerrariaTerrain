
// Project: AppGameKit-TerrariaTerrain 
// Created: 21-01-21

// show all errors

SetErrorMode(2)

#include "world_init.agc"

// set window properties
SetWindowTitle( "AppGameKit-TerrariaTerrain" )
SetWindowSize( 1024, 768, 0 )
SetWindowAllowResize( 1 ) // allow the user to resize the window

// set display properties
SetVirtualResolution( 100, 100 ) // doesn't have to match the window
SetOrientationAllowed( 1, 1, 1, 1 ) // allow both portrait and landscape on mobile devices
SetSyncRate( 0, 0 ) // 30fps instead of 60 to save battery
SetScissor( 0,0,0,0 ) // use the maximum available screen space, no black borders
UseNewDefaultFonts( 1 )
SetViewZoomMode(1)
SetClearColor(32,64,128)

World_Init(1000,1000,4)

//~World_CreateLight(20,5,20,255,255,255)

do
    Print("FPS: "+str(ScreenFPS(),0))
    print("Calls: "+str(GetManagedSpriteDrawCalls()))
    print("Count: "+str(GetManagedSpriteCount()))
    print("Drawn: "+str(GetManagedSpriteDrawnCount()))
	
	PointerX#=GetPointerX()
	PointerY#=GetPointerY()
	
	PointerBlockX=round((ScreenToWorldX(PointerX#)/WorldTileSize))
	PointerBlockY=round((ScreenToWorldY(PointerY#)/WorldTileSize))
	PointerBlockX=Core_Clamp(PointerBlockX,0,World.Block.length)
	PointerBlockY=Core_Clamp(PointerBlockY,0,World.Block.length)
		
	if GetRawMouseRightReleased()
		World_CreateLight(PointerBlockX,PointerBlockY,10,255,0,0)
	endif
	
	if GetPointerPressed()
		PointerBlockTypID=World_GetBlockTypID(PointerBlockX,PointerBlockY)
	endif
	if GetPointerState()
		if PointerBlockTypID=BLOCK_AIR
			World_DeleteBlock(PointerBlockX,PointerBlockY)
		else
			World_CreateBlock(PointerBlockX,PointerBlockY,PointerBlockTypID)
		endif
	endif
    
    World_Update()
    Sync()
loop
