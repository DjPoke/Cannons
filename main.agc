
// Project: Cannons 
// Created: 23-03-17

// show all errors

SetErrorMode(2)

// set window properties
SetWindowTitle("Cannons")
SetWindowSize(320, 200, 1)
SetWindowAllowResize(0)

// set display properties
SetVirtualResolution(320, 200)
SetOrientationAllowed(0, 0, 1, 1)
SetSyncRate(60, 0)
SetScissor(0,0,0,0)
UseNewDefaultFonts(1)

// pixel art mode
SetDefaultMagFilter(0)
SetDefaultMinFilter(0)

// hide mouse
SetRawMouseVisible(0)

// check for joystick
CompleteRawJoystickDetection()

// constants
#Constant TOP_EDGE 40
#Constant BOTTOM_EDGE 168
#Constant LEFT_EDGE 32
#Constant RIGHT_EDGE 288

#Constant MAX_BALL_SPEED = 12

#Constant SMOKE_DEPTH = 8
#Constant CANNONS_DEPTH = 7

// vars
Global bx As Float
Global by As Float

Global px As Float
Global py As Float

Global ba As Float
Global bs As Float

Global cannons As Integer

Global level As Integer
Global score As Integer
Global time As Integer
Global target As Integer
Global ammos As Integer

// load medias
LoadFont(1, "CPCMode0.ttf")

LoadImage(1, "background.png")
LoadImage(2, "ball.png")
LoadImage(3, "cannon.png")
LoadImage(4, "fire.png")
LoadImage(5, "smoke.png")
LoadImage(6, "title.png")

LoadSoundOGG(1, "bounce.ogg")
LoadSoundOGG(2, "fire.ogg")
LoadSoundOGG(3, "fail.ogg")
LoadSoundOGG(4, "void.ogg")
LoadSoundOGG(5, "ready.ogg")
LoadSoundOGG(6, "winner.ogg")
LoadSoundOGG(7, "looser.ogg")

LoadMusicOGG(1, "cannons.ogg")

// game loop
Do
	// create title sprite
	CreateSprite(11, 6)
	SetSpriteOffset(11, GetSpriteWidth(11) / 2, GetSpriteHeight(11) / 2)
	SetSpritePositionByOffset(11, 160, 25)
	
	// create texts
	CreateText(1, "Push Space to Start")
	SetTextAlignment(1, 1)
	SetTextPosition(1, 160, 92)
	SetTextSize(1, 8)
	SetTextFont(1, 1)

	// create texts
	CreateText(2, "Use Joystick or Arrow Keys with Left Control")
	SetTextAlignment(2, 1)
	SetTextPosition(2, 160, 68)
	SetTextSize(2, 8)
	SetTextFont(2, 1)
	
	PlayMusicOGG(1, 1)
	
	// intro loop
	Do
		// quit the game
		If GetRawKeyPressed(27) = 1
			DeleteAllSprites()
			DeleteAllImages()
			DeleteAllText()

			End
		Endif

		// start the game
		If GetRawKeyPressed(32) = 1
			Exit
		Endif
		
		If Mod(GetMilliseconds(), 1000) < 500
			SetTextColor(1, 255, 255, 255, 255)
		Else
			SetTextColor(1, 0, 0, 0, 255)			
		Endif
		
    	Sync()
	Loop
	
	DeleteAllSprites()
	DeleteAllText()
	
	StopMusicOGG(1)

	// init game
	level = 1
	score = 0

	UpdateLevel()
		
	tm = GetMilliseconds()
	ttm = tm

	// main loop
	Do
		// count time
		If time > 0
			If GetMilliseconds() - tm >= 1000
				tm = GetMilliseconds()
		
				Dec time
				
			Endif
		Endif
				
		// move ball
		bx = bx + (bs * Cos(ba))
		by = by + (bs * Sin(ba))
	
		// touch top border
		If by < (GetSpriteHeight(2) / 2) + 16
			by = (GetSpriteHeight(2) / 2) + 16
			ba = 360 - ba
		
			PlaySound(1)
		Endif

		// touch bottom border
		If by > 200 - (GetSpriteHeight(2) / 2) - 8
			by = 200 - (GetSpriteHeight(2) / 2) - 8
			ba = 360 - ba		
		
			PlaySound(1)
		Endif

		// touch left border
		If bx < (GetSpriteWidth(2) / 2) + 8
			bx = (GetSpriteWidth(2) / 2) + 8
			ba = 180 - ba		
		
			PlaySound(1)
		Endif

		// touch right border
		If bx > 320 - (GetSpriteWidth(2) / 2) - 8
			bx = 320 - (GetSpriteWidth(2) / 2) - 8
			ba = 180 - ba		
		
			PlaySound(1)
		Endif
	
		While ba < 0
			Inc ba, 360
		EndWhile

		While ba >= 360
			Dec ba, 360
		EndWhile

		SetSpritePositionByOffset(2, bx, by)
	
		// restore cannon sprites
		For i = 1 To cannons
		SetSpriteImage(i + 2, 3)
		Next
	
		// move player
		If GetRawJoystickExists(1)
			// move horizontally
			If GetRawJoystickX(1) < -0.5
				If px > LEFT_EDGE
					Dec px, 2
				Endif
			Elseif GetRawJoystickX(1) > 0.5
				If px < RIGHT_EDGE
					Inc px, 2
				Endif
			Endif

			// move vertically
			If GetRawJoystickY(1) < -0.5
				If py > TOP_EDGE
					Dec py, 2
				Endif
			Elseif GetRawJoystickY(1) > 0.5
				If py < BOTTOM_EDGE
					Inc py, 2
				Endif
			Endif
		
			// fire !
			If GetRawJoystickButtonPressed(1, 1)
				If ammos > 0
					Dec ammos
				
					flag = 0
			
					For i = 1 To cannons
						// replace cannon sprite by fire one
						SetSpriteImage(i + 2, 4)

						If GetSpriteCollision(2, i + 2) = 1 And target > 0
							If bs < MAX_BALL_SPEED Then Inc bs, 0.5
					
							Dec target
							
							Inc score, 10
					
							// make smoke
							SetSpritePositionByOffset(6 + i, bx, by)
							SetSpriteVisible(6 + i, 1)
							PlaySprite(6 + i, 15, 0)

							ba = Random(0, 359)
							flag = 1
						Endif
					Next
			
					If flag = 1
						PlaySound(2)
					Else
						PlaySound(3)
					Endif
				Else
					PlaySound(4)
	
					Dec time, 5

					If time < 0 Then time = 0
				Endif
			Endif
		Endif

		// move horizontally
		If GetRawKeyState(37) = 1
			If px > LEFT_EDGE
				Dec px, 2
			Endif
		Elseif GetRawKeyState(39) = 1
			If px < RIGHT_EDGE
				Inc px, 2
			Endif
		Endif

		// move vertically
		If GetRawKeyState(38) = 1
			If py > TOP_EDGE
				Dec py, 2
			Endif
		Elseif GetRawKeyState(40) = 1
			If py < BOTTOM_EDGE
				Inc py, 2
			Endif
		Endif

		// fire !
		If GetRawKeyPressed(17) = 1
			If ammos > 0
				Dec ammos
			
				flag = 0
			
				For i = 1 To cannons
					// replace cannon sprite by fire one
					SetSpriteImage(i + 2, 4)

					If GetSpriteCollision(2, i + 2) = 1 And target > 0
						If bs < MAX_BALL_SPEED Then Inc bs, 0.5
					
						Dec target
						
						Inc score, 10
												
						// make smoke
						SetSpritePositionByOffset(6 + i, bx, by)
						SetSpriteVisible(6 + i, 1)
						PlaySprite(6 + i, 15, 0)

						ba = Random(0, 359)
						flag = 1
					Endif
				Next
			
				If flag = 1
					PlaySound(2)
				Else
					PlaySound(3)
				Endif
			Else
				PlaySound(4)
					
				Dec time, 5
				
				If time < 0 Then time = 0
			Endif
		Endif

		Select cannons
			Case 1
				SetSpritePositionByOffset(3, px, py)
			EndCase
			Case 2
				SetSpritePositionByOffset(3, px - 16, py)
				SetSpritePositionByOffset(4, px + 16, py)
			EndCase
			Case 3
				SetSpritePositionByOffset(3, px - 16, py)
				SetSpritePositionByOffset(4, px + 16, py)
				SetSpritePositionByOffset(5, px, py - 16)
			EndCase
			Case 4
				SetSpritePositionByOffset(3, px - 16, py - 16)
				SetSpritePositionByOffset(4, px + 16, py - 16)
				SetSpritePositionByOffset(5, px - 16, py + 16)
				SetSpritePositionByOffset(6, px + 16, py + 16)
			EndCase
		EndSelect
		
		// if time has ended
		If time = 0
			PlaySound(7)
			
			UpdateTexts()

	    	Sync()
	    	
			Delay(2000)
			
			Exit
		Endif

		// if target is done
		If target = 0
			PlaySound(6)
			
			UpdateTexts()
			Delay(2000)
			
			SetTextColor(4, 255, 255, 0, 255)
			
			While time > 0
				Dec time
				Inc score, 50
				
				PlaySound(2)
				
				UpdateTexts()
				
				Sync()
				
				Delay(100)
			EndWhile

			UpdateTexts()

			Delay(100)
			
			DeleteAllSprites()
			DeleteAllText()
			
			Inc level
			
			If level > 8 Then level = 1
			
			UpdateLevel()
		Endif

		// exit the game
		If GetRawKeyReleased(27) = 1
			Exit
		Endif

		UpdateTexts()

    	Sync()
	Loop
	
	DeleteAllSprites()
	DeleteAllText()
	
	// show score at game over...
	CreateText(1, "Score: " + Str(score) + Chr(10) + "Level: "+ Str(level))
	SetTextAlignment(1, 1)
	SetTextSize(1, 16)
	SetTextPosition(1, 160, 80)

   	Sync()
   	
   	Delay(4000)
   	
   	DeleteText(1)
Loop

End

// ===============================================================

Function Delay(d As Integer)
	tm = GetMilliseconds()
			
	Do
		// wait a delay
		If GetMilliseconds() - tm >= d Then Exit
			
		Sync()
	Loop
EndFunction

// convert score to string with zeros
Function GetScore(num As Integer)
	sc$ = Str(num)
	
	While Len(sc$) < 7
		sc$ = "0" + sc$
	EndWhile
	
	sc$ = "score: " + sc$
EndFunction sc$

// convert timer to string with zeros
Function GetTimer(num As Integer)
	sc$ = Str(num)
	
	While Len(sc$) < 2
		sc$ = "0" + sc$
	EndWhile
	
	sc$ = "time: " + sc$
EndFunction sc$

// convert target to string with zeros
Function GetTarget(num As Integer)
	sc$ = Str(num)
	
	While Len(sc$) < 3
		sc$ = "0" + sc$
	EndWhile
	
	sc$ = "target: " + sc$
EndFunction sc$

// convert ammos to string with zeros
Function GetAmmos(num As Integer)
	sc$ = Str(num)
	
	While Len(sc$) < 3
		sc$ = "0" + sc$
	EndWhile
	
	sc$ = "ammos: " + sc$
EndFunction sc$

// fill level's vars
Function GetLevelData(l)
	// set random ball angle
	ba = Random(0, 359)
	
	// set ball at center of the screen
	bx = 160
	by = 100
	
	// position the player around the ball
	px = bx
	py = by

	// for each different level...
	Select l
		Case 1
			time = 30 // timer
			target = 10 // number of hits to do
			ammos = 20 // ammos count
			cannons = 4 // number of cannons
			bs = 1 // ball speed
		EndCase
		Case 2
			time = 35 // timer
			target = 15 // number of hits to do
			ammos = 30 // ammos count
			cannons = 4 // number of cannons
			bs = 2 // ball speed
		EndCase
		Case 3
			time = 45 // timer
			target = 20 // number of hits to do
			ammos = 50 // ammos count
			cannons = 3 // number of cannons
			bs = 2 // ball speed
		EndCase
		Case 4
			time = 60 // timer
			target = 25 // number of hits to do
			ammos = 50 // ammos count
			cannons = 3 // number of cannons
			bs = 3 // ball speed
		EndCase
		Case 5
			time = 60 // timer
			target = 10 // number of hits to do
			ammos = 40 // ammos count
			cannons = 2 // number of cannons
			bs = 1 // ball speed
		EndCase
		Case 6
			time = 60 // timer
			target = 15 // number of hits to do
			ammos = 60 // ammos count
			cannons = 2 // number of cannons
			bs = 2 // ball speed
		EndCase
		Case 7
			time = 90 // timer
			target = 20 // number of hits to do
			ammos = 60 // ammos count
			cannons = 1 // number of cannons
			bs = 2 // ball speed
		EndCase
		Case 8
			time = 90 // timer
			target = 25 // number of hits to do
			ammos = 80 // ammos count
			cannons = 1 // number of cannons
			bs = 3 // ball speed
		EndCase
	EndSelect
EndFunction

// create pannel
Function CreatePannel()
	// create score text
	CreateText(1, "")
	SetTextFont(1, 1)
	SetTextSize(1, 6)
	SetTextPosition(1, 0, 0)
	SetTextAlignment(1, 0)

	CreateText(2, "")
	SetTextFont(2, 1)
	SetTextSize(2, 6)
	SetTextPosition(2, 120, 0)
	SetTextAlignment(2, 1)

	CreateText(3, "")
	SetTextFont(3, 1)
	SetTextSize(3, 6)
	SetTextPosition(3, 200, 0)
	SetTextAlignment(3, 1)

	CreateText(4, "")
	SetTextFont(4, 1)
	SetTextSize(4, 6)
	SetTextPosition(4, 320, 0)
	SetTextAlignment(4, 2)
EndFunction

// create sprites
Function CreateSprites()
	CreateSprite(1, 1)
	SetSpritePosition(1, 0, 0)

	CreateSprite(2, 2)
	SetSpriteOffset(2, 8, 8)
	SetSpritePositionByOffset(2, bx, by)
EndFunction

// create cannons
Function CreateCannons()
	Select cannons
		Case 1
			CreateSprite(3, 3)
			SetSpriteOffset(3, 8, 8)
			SetSpritePositionByOffset(3, px, py)
			SetSpriteDepth(3, CANNONS_DEPTH)
		EndCase
		Case 2
			CreateSprite(3, 3)
			SetSpriteOffset(3, 8, 8)
			SetSpritePositionByOffset(3, px - 16, py)
			SetSpriteDepth(3, CANNONS_DEPTH)

			CreateSprite(4, 3)
			SetSpriteOffset(4, 8, 8)
			SetSpritePositionByOffset(4, px + 16, py)
			SetSpriteDepth(4, CANNONS_DEPTH)
		EndCase
		Case 3
			CreateSprite(3, 3)
			SetSpriteOffset(3, 8, 8)
			SetSpritePositionByOffset(3, px - 16, py)
			SetSpriteDepth(3, CANNONS_DEPTH)

			CreateSprite(4, 3)
			SetSpriteOffset(4, 8, 8)
			SetSpritePositionByOffset(4, px + 16, py)
			SetSpriteDepth(4, CANNONS_DEPTH)

			CreateSprite(5, 3)
			SetSpriteOffset(5, 8, 8)
			SetSpritePositionByOffset(5, px, py - 16)
			SetSpriteDepth(5, CANNONS_DEPTH)
		EndCase
		Case 4
			CreateSprite(3, 3)
			SetSpriteOffset(3, 8, 8)
			SetSpritePositionByOffset(3, px - 16, py - 16)
			SetSpriteDepth(3, CANNONS_DEPTH)

			CreateSprite(4, 3)
			SetSpriteOffset(4, 8, 8)
			SetSpritePositionByOffset(4, px + 16, py - 16)
			SetSpriteDepth(4, CANNONS_DEPTH)

			CreateSprite(5, 3)
			SetSpriteOffset(5, 8, 8)
			SetSpritePositionByOffset(5, px - 16, py + 16)
			SetSpriteDepth(5, CANNONS_DEPTH)

			CreateSprite(6, 3)
			SetSpriteOffset(6, 8, 8)
			SetSpritePositionByOffset(6, px + 16, py + 16)
			SetSpriteDepth(6, CANNONS_DEPTH)
		EndCase
	EndSelect
EndFunction

// create smoke sprites
Function CreateSmoke()
	For i = 7 To 10
		CreateSprite(i, 5)
		SetSpriteAnimation(i, 32, 32, 8)
		SetSpriteOffset(i, 16, 16)
		SetSpriteDepth(i, SMOKE_DEPTH)
		SetSpriteVisible(i, 0)
	Next
EndFunction

Function UpdateLevel()
	GetLevelData(level)

	// create pannel
	CreatePannel()

	// create sprites
	CreateSprites()

	// create cannons
	CreateCannons()

	// create smoke sprites
	CreateSmoke()
	
	// update texts
	UpdateTexts()

	// ready screen
	CreateText(5, "READY ?")
	SetTextAlignment(5, 1)
	SetTextPosition(5, 160, 20)
	SetTextFont(5, 1)
	SetTextSize(5, 32)
	SetTextColor(5, 255, 255, 255, 255)
	SetTextDepth(5, 9)

	CreateText(6, "READY ?")
	SetTextAlignment(6, 1)
	SetTextPosition(6, 162, 22)
	SetTextFont(6, 1)
	SetTextSize(6, 32)
	SetTextColor(6, 0, 0, 0, 255)
	SetTextDepth(6, 10)
	
	PlaySound(5)
	
	Delay(1000)
	
	DeleteText(5)
	DeleteText(6)
EndFunction

Function UpdateTexts()
	SetTextString(1, GetScore(score))
	SetTextString(2, GetTarget(target))
	SetTextString(3, GetAmmos(ammos))
	SetTextString(4, GetTimer(time))
EndFunction
