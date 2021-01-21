
// Project: AppGameKit-TerrariaTerrain 
// Created: 21-01-21

// show all errors

SetErrorMode(2)

#include "world.agc"

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

World_Init(100,100,4)

ViewZoom#=1.0
do
    Print( ScreenFPS() )
    
    FrameTime#=GetFrameTime()
    
    Speed#=100.0
	if getrawkeystate(68) then ViewPosX#=ViewPosX#+Speed#*FrameTime#
	if getrawkeystate(65) then ViewPosX#=ViewPosX#-Speed#*FrameTime#
	if getrawkeystate(83) then ViewPosY#=ViewPosy#+Speed#*FrameTime#
	if getrawkeystate(87) then ViewPosY#=ViewPosy#-Speed#*FrameTime#
	if getrawkeystate(81) then ViewZoom#=ViewZoom#-0.5*FrameTime#
	if getrawkeystate(69) then ViewZoom#=ViewZoom#+0.5*FrameTime#
    
    SetViewZoom(ViewZoom#)
	SetViewOffset(ViewPosX#,ViewPosY#)
	
	PointerX#=GetPointerX()
	PointerY#=GetPointerY()
	
	PointerBlockX=round(ScreenToWorldX(PointerX#)/WorldTileSize)
	PointerBlockY=round(ScreenToWorldY(PointerY#)/WorldTileSize)
	
	if GetPointerPressed()
		PointerBlockTypID=World_GetBlockTypID(PointerBlockX,PointerBlockY)
	endif
	if GetPointerState()
		if PointerBlockTypID=BLOCK_AIR
			World_CreateBlock(PointerBlockX,PointerBlockY,BLOCK_AIR)
		else
			World_CreateBlock(PointerBlockX,PointerBlockY,PointerBlockTypID)
		endif
	endif
    
    World_Update()
    Sync()
loop
