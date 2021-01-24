// File: world_light.agc
// Created: 21-01-21

function world_ColculateLight()
	while AddLightFrontier.length>=0
		BlockX=AddLightFrontier[0].x
		BlockY=AddLightFrontier[0].y
		AddLightFrontier.remove(0)
		
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
					AddLightFrontier.insert(TempFrontier)
					
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
endfunction

/*
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
*/

function World_SetSunLight(BlockX) // need a function to also remove the last sunlight if there is a new higher point
	BlockY=World.Height[BlockX]
	if BlockY>=0
		World.Block[BlockX,BlockY].Color.Red=255
		World.Block[BlockX,BlockY].Color.Green=255
		World.Block[BlockX,BlockY].Color.Blue=255
		
		TempFrontier.X=BlockX
		TempFrontier.Y=BlockY
		AddLightFrontier.insert(TempFrontier)
	endif
endfunction

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
	AddLightFrontier.insert(TempFrontier)
endfunction World.Light.length

function World_DeleteLight(LightID)
	World.Light.remove(LightID)
endfunction