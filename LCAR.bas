B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=StaticCode
Version=6.77
@EndOfDesignText@
'X/Y locations
'>MaxInt	% of width/height relative to left/top (%= (value-MaxInt) * 0.01)
'<MinINT	% of width/height relative to width/height (%= (value+MinINT) * 0.01)
'=>0 		relative to left/top
'<0  		relative to width/height

'LCAR_Button
'LWidth=Width of left curved part, RWidth=Width of right curved part, Number is only drawn if >-1

'LCAR_Timer
'Not drawn, but will still move if visible=true, so you can use it to delay the LCAR_StoppedMoving event

'LCAR_Slider, LCAR_Meter, LCAR_Chart
'Lwidth=current percent, rwidth=desired percent, align=LCAR_Random randomizes rwidth when lwidth=rwidth
'LCAR_Chart Align -1= top edge, LCAR_Random or 0=graph item, 1=bottom edge, sidetext=0,empty = normal, sidetext=-1 = left edge, sidetext=1 = right edge

'LCAR_SensorGrid
'Lwidth=current X, rwidth=current y, element.Align=desired X, element.TextAlign=desired y,  Enabled=true randomizes desired when = to current

'LCAR_Picture
'LWidth=Picture ID/Index, Align=5 Picture is centered on X/Y

'LCAR_Textbox
'Lwidth=Selection start, RWidth=Selection Width

'LCAR_Elbow
'Lwidth=BarWidth, Rwidth=BarHeight

'LCAR_Numbers
'LWidth=Number list ID

'LCAR_List
'Style 0=normal, 1(LCAR_Chart), 2(LCAR_Graph) =Chart ShowNumber=true randomizes item Number when Number = whitespace, Number=Desired Percent, WhiteSpace=Current Percent

'Code module
'Subs in this code module will be accessible from all modules.
Sub Process_Globals
	'These global variables will be declared once when the application starts.
	'These variables can be accessed from all modules.	
	Dim ScaleWidth As Int, 			ScaleHeight As Int , 	BiggestHeight As Int,  		Landscape As Boolean ,	MultiTouchEnabled As Boolean ,SpeedSensor As Int,	WasPlaying As Int ,		ChartWidth As Int, ChartEdgeHeight As Int, ChartHeight As Int , ChartSpace As Int,	ListIsMoving As Boolean 
	Dim LCAR_Black As Int, 			LCAR_DarkOrange As Int, LCAR_Orange As Int,  		LCAR_LightOrange As Int,LCAR_Purple As Int,		LCAR_RedAlert As Int,  		LCAR_LightPurple As Int,LCAR_LightBlue  As Int, LCAR_Red As Int,  LCAR_Yellow  As Int, LCAR_DarkBlue As Int,  LCAR_DarkYellow As Int,  LCAR_DarkPurple  As Int, LCAR_White  As Int,LCAR_Random As Int ,LCAR_RandomTheme As Int
	Dim LCARcolors As List ,		Mute As Boolean,		ElementMoving As Boolean ,	BlinkState As Boolean ,	ListitemWhiteSpace As Int,NumberWhiteSpace As Int, 	NumberTextSize As Int ,	Alphaspeed As Int,Stage As Int,MeterWidth As Int
	Dim Looping As Int,				HalfWhite As Int, 		FPS As Int,					FramesDrawn As Int ,AlphaBlending As Boolean ,SelectedIP As Int,VisibleList As Int, BackupKB As APIKeyboard  
	
	Dim MaxINT As Int, 				MinINT As Int, 			MAXDIM As Int, 				MINDIM As Int, 			BatteryPercent As Int, OldBattery As Int, isCharging As Boolean , LCAR_NumberTextSize As Int
	
	'ElementTypes: 0=button
	Type Point(X As Int, Y As Int)
	Type ColorTheme					(Name As String,		ColorList(5) As Int, 		ColorCount As Int)
	Type LCARColor					(Name As String, 		Normal As Int, 				Selected As Int, 		nR As Int, 				nG As Int, 					nB As Int, 				sR As Int, sG As Int, SB As Int) 
	Type tween						(currX As Int, 			currY As Int, 				offX As Int, 			offY As Int)
	Type TweenAlpha					(Current As Int, 		Desired As Int)
	Type ElementClicked				(ElementType As Int, 	X As Int, 					Y As Int, 				Index As Int, 			Dimensions As tween,		X2 As Int, 				Y2 As Int, Index2 As Int , EventType As Int , RespondToAll As Boolean )
	Type LCARnumberlist				(Rows As Int, 			ShowRows As Int, 			Cols As List)
	Type LCARnumberCol				(Numbers As List, 		Width As Int, 				Digits As Int, 			Align As Int)
	Type LCARpicture				(Name As String, 		Picture As Bitmap, 			Dir As String )
	Type LCARlistitem				(Text As String, 		Side As String, 			Tag As String , 		Selected As Boolean, 	Number As Int, 				IsClean As Boolean , 	ColorID As Int, WhiteSpace As Int)
	Type LCARlist					(Opacity As TweenAlpha, LastMint As Int, 			ForcedMint As LCARlistitem , ForcedMintCount As Int, Style As Int, 			ColsPortrait As Int, 	ColsLandscape As Int, Start As Int, LOC As tween, Size As tween ,SurfaceID As Int, ShowNumber As Boolean , Name As String,RhasCurve As Boolean , Tag As String, IsClean As Boolean , MultiSelect As Boolean , SelectedItems As Int, SelectedItem As Int, isDown As Boolean,isScrolling As Boolean , Visible As Boolean , RedX As Int, RedY As Int,Red As Int, WhiteSpace As Int, LWidth As Int, RWidth As Int, Alignment As Int, ListItems As List,Locked As Boolean, OneColOnly As Boolean ,Async As Boolean, SelectedXY As Point, Offset As Int,Ydown As Float)
	Type LCARelement				(LOC As tween ,			Size As tween,				Opacity As TweenAlpha, 	ElementType As Int, 	ColorID As Int, 			IsDown As Boolean, 		Name As String,SurfaceID As Int, Tag As String, Group As Int,Text As String,SideText As String,  LWidth As Int, RWidth As Int, IsClean As Boolean , TextAlign As Int, RedAlertHold As Int, RedAlertCycles As Int, State As Boolean, Visible As Boolean, Enabled As Boolean,Align As Int,Blink As Boolean, Async As Boolean , RespondToAll As Boolean   )
	Type LCARgroup					(Visible As Boolean, 	RedAlert As Int, 			LCARlist As List, HoldList As List, Hold As Int )
	
	Dim LCARelements As List , 		LCARGroups As List , 	LCARlists As List ,			LCARnumberlists As LCARnumberlist, 				LCARVisibleLists As List,	LCAR_Grey As Int,	ClearLocked As Boolean 
	Dim Fontsize As Int, 			LCARfont As Typeface ,	LCARfontheight As Int, 		RedAlert As Boolean ,	IsClean As Boolean, 	LCAR_Block As String ' , NeedsEnumerating As Boolean 
	
	Dim KBListID As Int, 			KBCancelID As Int, 									KBGroup As Int, 		KBShift As Boolean ,	NumListID As Int, 			NumButtonID As Int, 		NumGroup As Int, 		KBCaps As Boolean 
	Dim ItemHeight As Int,			AntiAliasing As Boolean, 							WebviewOffset As Int,	LessRandom As Boolean,	CurrRandom As Int,			CurrListID As Int:	AntiAliasing=True
	Dim LCARCorner As Bitmap, 		LCARCornerSlider As Bitmap,							LCARCornerElbow As Bitmap,						LCARCornerElbow2 As Bitmap,	ScreenIsOn As Boolean 
	Dim LCARCornera As Bitmap, 		LCARCornerSlidera As Bitmap,						LCARCornerElbowa As Bitmap,						LCARCornerElbow2a As Bitmap, UseAnotherFolder As Boolean 

	Dim LCAR_List As Int, 			LCAR_Button As Int,		LCAR_Elbow As Int,			LCAR_Textbox As Int, 	LCAR_Slider As Int,		LCAR_CodeChanged As Int,	LCAR_Meter As Int,			LCAR_Keyboard As Int
	Dim LCAR_StoppedMoving As Int, 	LCAR_Timer As Int,		LCAR_StoppedPlaying As Int, LCAR_Chart As Int,		LCAR_Picture As Int,	LCAR_SensorGrid As Int,		LCAR_ChartNeg As Int,		LCAR_Navigation As Int
	Dim LCAR_SensorChanged As Int,	LCAR_IGNORE As String,	LCAR_TimerIncrement As Int, leftside As Int,		Zoom As Int ,			LoadedFilename As String,   LOD As Boolean , 			LCAR_OK As Int
	Dim LCAR_Tactical As Int,		LCAR_LastListitem As Int,SymboardID As Int ,		ElbowTextHeight As Int,	LCAR_Borg As Int,		SmallScreen As Boolean ,	LCAR_Okuda As Int			',method1 As Boolean , 		
	Dim LCAR_Dpad As Int,			LCAR_Alert As Int, 		Classic_Yellow As Int,		Classic_Green As Int,	Classic_Blue As Int, 	Classic_LightBlue As Int,	LCAR_HardwareBTN As Int,	LCAR_HorSlider As Int
	Dim LCAR_Matrix As Int,			LCAR_StarBase As Int,	LCAR_Analysis As Int,		Klingon_Button As Int,	Klingon_Frame As Int,	Legacy_Button As Int,		LCAR_ToastDone As Int,		LCAR_Graph As Int 
	Dim LCAR_Engineering As Int ,	PCAR_Button As Int,		LCAR_SensorSweep As Int,	LCAR_Clear As Int,		LCAR_BigText As Int,	LCAR_Omega As Int,			LCAR_Ruler As Int ,			LCAR_MultiSpectral As Int
	Dim LCAR_ShieldStatus As Int,	LCAR_PdP As Int,		PCAR_Frame As Int ,			LCAR_PdPSelector As Int,LCAR_Static As Int,		SBALLS_Plaid As Int,		TOS_Moires As Int, 			Legacy_Sonar As Int
	Dim Classic_Turq As Int,		LCAR_RndNumbers As Int,	TOS_RndNumbers As Int,		LCAR_TextButton As Int, LCAR_PToE As Int,		LCAR_MSD As Int,			LCAR_NCC1701D As Int,		BTTF_Flux As Int
	Dim LCAR_LWP As Int,			LCAR_MiniButton As Int,	LCAR_WarpCore As Int,		LCAR_ShuttleBay As Int, IsInternal As Boolean,	LCAR_ASquare As Int ,		LCAR_Starfield As Int,		LCAR_MultiLine As Int 
	Dim LCAR_SMS As Int,			LCAR_Answer As Int,		LCAR_AnswerMade As Int,		LCAR_PhoneState As Int, AnswerScreen As Int  = 54
	
	Type LCARSound					(Name As String, 		Filename As String, Dir As String,   Length As Int, SPID As Int) 'UseSoundPool As Int,)
	Type GesturePoint				(Id As Int,				prevX As Int,				prevY As Int,			Element As ElementClicked )
	Dim GestureMap As List,			EventList As List,		SoundList As List ,			PictureList As List,	MP As MediaPlayer,		ThemeList As List,			CurrentTheme As ColorTheme, CTindex As Int
	'Dim MP2 As MediaPlayer 
	
	
	Dim Event_Down As Int, Event_Up As Int, Event_Move As Int, Event_Scroll As Int, OldX As Int, OldY As Int, MinTimer As Long,TimerPeriod As Int, VibratePeriod As Int ,didIncrementNumbers As Boolean 
	Dim IsAAon As Boolean ,cVol As Int, SmoothScrolling As Boolean,DoVector As Boolean  ,ResetVol As Boolean, Locked As Boolean  ,BGisInit As Boolean,SymbolsEnabled As Boolean, BypassHardwareKB As Boolean  
	Dim VolOpacity As Int, VolSeconds As Int ,VolVisible As Int ,FPSCounter As Boolean,DrawFPS As Boolean ,VolText As String , VolTextList As List,VolInc As Int  ,VolDimensions As Point 
	Dim HasHardwareKeyboard As Boolean, KBisVisible As Boolean,ToastAlign As Boolean ,CurrSound As LCARSound ,Fontfactor As Int, Vibrate As PhoneVibrate, RumbleUnit As Int ,IsRumbling As Boolean 
	'Dim SP As SoundPool,PlayID As Int :PlayID=-1:SP.Initialize(1)
	
	
	LCAR_StoppedPlaying=-5:			LCAR_Timer=-4:			LCAR_StoppedMoving=-3:		LCAR_CodeChanged=-2:	LCAR_List=-1:			LCAR_Button=0:				LCAR_Elbow=1
	LCAR_Textbox=2:					LCAR_Slider=3:			LCAR_Meter=4:				LCAR_SensorGrid=5:		LCAR_Picture =6:		LCAR_Chart=7:				LCAR_Navigation=8	
	LCAR_Tactical=9:				LCAR_LastListitem=-999: LCAR_Borg =10:				LCAR_Okuda=11:			LCAR_Dpad=12:			LCAR_Alert=13:				LCAR_HorSlider=14
	LCAR_ChartNeg=-6:				LCAR_SensorChanged=-7:	LCAR_IGNORE="IGNORETHIS":	LCAR_TimerIncrement=-8: LCAR_OK=-9:				LCAR_Keyboard=-10:			LCAR_HardwareBTN=-11
	LCAR_Matrix=15:					LCAR_StarBase=16:		LCAR_Analysis=17:			Klingon_Button=18:		Klingon_Frame=19:		Legacy_Button=20:			LCAR_ToastDone =21
	LCAR_Graph=22:					LCAR_Engineering=23:	PCAR_Button=24:				LCAR_SensorSweep=25:	LCAR_Omega=26:			LCAR_Ruler=27:				LCAR_MultiSpectral=28
	LCAR_ShieldStatus=29:			LCAR_PdP=30:			PCAR_Frame=31:				LCAR_PdPSelector=32:	LCAR_Static=33:			SBALLS_Plaid=34:			TOS_Moires=35
	Legacy_Sonar=36:				LCAR_RndNumbers=37:		TOS_RndNumbers=38:			LCAR_TextButton=39:		LCAR_PToE=40:			LCAR_MSD=41:				LCAR_NCC1701D=42
	BTTF_Flux=43:					LCAR_LWP=44:			LCAR_MiniButton=45:			LCAR_WarpCore=46:		LCAR_PhoneState=47:		LCAR_ASquare=48:			LCAR_Starfield=49
	LCAR_MultiLine=50:				LCAR_SMS=51:			LCAR_Answer =52:			LCAR_AnswerMade=53
	
	LCAR_RandomTheme=-9998:			MeterWidth=60:			ListitemWhiteSpace=3:		SpeedSensor=2:			Alphaspeed=16:			LCAR_Random=-9999:			ChartWidth=40
	ChartEdgeHeight=13:				ChartHeight=62:			ChartSpace=5:				CurrListID=-1:			HalfWhite =Colors.ARGB(128,255,255,255)		

	MaxINT= 2147483647:		MinINT = -2147483648:		MAXDIM=MaxINT-100: 		MINDIM=MinINT+100
	
	LCARCornerElbowa.Initialize(File.DirAssets,"elbow.gif"):							LCARCornerElbow2a.Initialize(File.DirAssets,"elbow2.gif")
	LCARCornerElbow.Initialize(File.DirAssets,"elbow.png"):								LCARCornerElbow2.Initialize(File.DirAssets,"elbow2.png")
	
	VolTextList.Initialize 
	
	Dim LCAR_SelectedItem As Int = -999, ButtonList As Int=-1 ,isInstalled As Boolean ,DirExternal As String ="",MinWidth As Int,ClickedOK As Boolean 
	Dim TextPos As Point , CharSize As Point ,LCAR_Sidebar As Int ,LCAR_ScreenEnabled As Boolean =True,KBLayout As Int ,LCAR_Beeps As Int ,CrazyRez As Float, LCARSDrawn As Int 
End Sub

Sub GUIcreated As Boolean 
	Return LCARelements.Size>0 And LCARlists.Size>0
End Sub
Sub GetInfo As Boolean 
	'Dim PM As PackageManager , Pic As Bitmap, tempstr As String 
	Try
		isInstalled = API.IsPackageInstalled("com.omnicorp.lcarui.test")
		
		'If Not(isInstalled) Then 
		'	tempstr = PM.GetApplicationLabel("com.omnicorp.lcarui.test")
		'	isInstalled = tempstr = "LCARS"
		'End If
			'debug(PM.GetApplicationLabel("com.omnicorp.lcarui.test"))
		'End If
		'API.debug("isInstalled=" & isInstalled & " (" & PM.GetApplicationLabel("com.omnicorp.lcarui.test") & ")")
		
		'Pic = API.GetBmpFromDrawable(PM.GetApplicationIcon("com.omnicorp.lcarui.test"))
		'tempstr = Pic.GetPixel(Pic.Width/2, Pic.height/2)
		'If tempstr <> -862348852 Then
		'	Log("ICONFAIL: " & tempstr)
		'	isInstalled = False
		'End If
		
		'API.debug("isInstalled=" & isInstalled & " (" & Pic.GetPixel(Pic.Width/2, Pic.height/2) & " should be -2056128")
		'If PM.GetVersionCode("com.omnicorp.lcarui.test") < 151 Then isInstalled = False
			'debug("VER FAIL: " & PM.GetVersionCode("com.omnicorp.lcarui.test"))
			'isInstalled = False
		'End If
		
		Return isInstalled
	Catch
		Return False
	End Try
End Sub

Sub DirDefaultExternal As String 
	Dim tempstr As String 
	If DirExternal.Length=0 Then
		If GetInfo Or isInstalled Then
			tempstr = File.Combine(File.DirRootExternal, "LCARS")
			If File.Exists(tempstr, "settings.ini") Then 'AND (DateTime.Now- File.LastModified(tempstr,"settings.ini")) / DateTime.TicksPerMinute >15 Then
				DirExternal= tempstr
			Else
				tempstr= File.DirDefaultExternal.Replace(".dialer", ".test")
				If File.Exists(tempstr, "settings.ini") Then  DirExternal= tempstr
			End If
		End If
	End If
	'API.debug("isInstalled: " & isInstalled & " Found directory: " & DirExternal)
	Return DirExternal
End Sub

Sub SetupTheVariables As Boolean 
	If Event_Down=0 Then 
		'LCARCornerElbowa.Initialize(File.DirAssets,"elbow.gif"):							LCARCornerElbow2a.Initialize(File.DirAssets,"elbow2.gif")
		'LCARCornerElbow.Initialize(File.DirAssets,"elbow.png"):								LCARCornerElbow2.Initialize(File.DirAssets,"elbow2.png")
		
		GestureMap.Initialize:			EventList.Initialize:	SoundList.Initialize:		PictureList.Initialize:	MP.Initialize2("MP") :			ThemeList.Initialize':		MP2.Initialize  
		LCARelements.Initialize:		LCARGroups.Initialize:	LCARlists.Initialize:		LCARnumberlists.Initialize :					LCARVisibleLists.Initialize 
		
		Event_Down=1: Event_Move=2:Event_Scroll=3
		'MultiTouchEnabled = True:
		LOD=True:AlphaBlending=True:SelectedIP=-1':method1=False
		cVol=100
		VolVisible=5
		Fontfactor=50
		'DoVector=True
		LCAR_Block = "‖"
		LCAR_Clear=Colors.ARGB(0,0,0,0)
		LCAR_BigText=-999'"BiGtExT"
		RumbleUnit=0
		LCAR_NumberTextSize=9999
		KBCaps=True
		
		Return True
	End If
	Return False
End Sub

Sub HandleRumbleTimer(CurrentTime As Int, StartTime As Int, EndTime As Int, Period As Int) As Boolean 
	If CurrentTime >= StartTime AND CurrentTime< EndTime AND Period <> VibratePeriod Then 
		RumblePeriod(Period)
		Return True
	End If
End Sub

Sub RumblePeriod(MS As Int)
	VibratePeriod=MS
	If MS =-1 Then 
		StopRumble
	Else
		RumblePattern( Array As Long( MS, RumbleUnit))
	End If
End Sub
Sub rumble(Units As Int)
	If RumbleUnit>0 Then Vibrate.Vibrate(Units*RumbleUnit)
End Sub
Sub RumblePattern(Pattern() As Long)
    Dim r As Reflector' 0=pause 1=rumble
    r.Target = r.GetContext
    r.Target = r.RunMethod2("getSystemService", "vibrator", "java.lang.String")
    r.RunMethod4("vibrate", Array As Object(Pattern, 0), Array As String("[J", "java.lang.int"))
	IsRumbling=True
End Sub
Sub StopRumble
    Dim r As Reflector
	r.Target = r.GetContext
	r.Target = r.RunMethod2("getSystemService", "vibrator", "java.lang.String")
	r.RunMethod("cancel")
	IsRumbling=False
End Sub








Sub ActivateAA(BG As Canvas, AAstate As Boolean ) As Boolean 
	Dim Obj1 As Reflector
	If AntiAliasing Then 
		'If AAstate =True AND AntiAliasing=False Then Return False
		Obj1.Target = BG
		Obj1.Target = Obj1.GetField("paint")
		Obj1.RunMethod2("setAntiAlias", AAstate, "java.lang.boolean")
		IsAAon=AAstate
		'debug("AA=" & AAstate)
		Return AAstate
	End If
End Sub

Sub LoadLCARSize(BG As Canvas)
	Dim NewLeftSide As Int , temp As Int, Lists As LCARlist , Filename As String 
	If Zoom>0 Then Filename=Zoom
	SetupColors
	LCARCorner.Initialize(File.DirAssets,"test1" & Filename & ".png")
	LCARCornera.Initialize(File.DirAssets,"test1" & Filename & ".gif")
	LCARCornerSlider.Initialize(File.DirAssets,"test2" & Filename & ".png")
	LCARCornerSlidera.Initialize(File.DirAssets,"test2" & Filename & ".gif")
	LoadedFilename= "test1" & Filename
	
	ItemHeight = LCARCorner.Height
	LCARfontheight=ItemHeight*(Fontfactor*0.01)
	If BG=Null Then 
		'If Fontsize=0 Then Fontsize=10
		Dim BMP As Bitmap ,tempBG As Canvas 
		BMP.InitializeMutable(1,1)
		tempBG.Initialize2(BMP)
		'debug("BG IS NULL: " & (BG=Null) & " BMP: " & BMP.IsInitialized )
		'Fontsize= API.GetTextHeight(tempBG, LCARfontheight, "ABC123", LCARfont)  '14+(Zoom*2)
		BG=tempBG
	'Else
	End If
		Fontsize= API.GetTextHeight(BG, LCARfontheight, "ABC123", LCARfont)  '14+(Zoom*2)
	'End If
	
	MinWidth = (LCARCorner.Width*2) + 4 + TextWidth(BG, "YES")
	NumberWhiteSpace=0
	
	NewLeftSide = LCARCorner.Width+4
	If leftside>0 Then
		For temp = 0 To LCARlists.Size-1
			Lists=LCARlists.Get(temp)
			If Lists.LWidth = leftside Then
				Lists.LWidth=NewLeftSide
				LCARlists.Set(temp,Lists)
			End If
		Next
	End If
	leftside=NewLeftSide
End Sub



Sub NewTheme(Name As String, ColorList As List) As Int
	Dim Theme As ColorTheme , temp As Int 
	Theme.Initialize
	Theme.ColorCount=ColorList.Size 
	For temp=0 To ColorList.Size -1
		Theme.ColorList(temp) = ColorList.Get(temp)
	Next
	ThemeList.Add(Theme)
	Return ThemeList.Size -1
End Sub
Sub ChangeTheme(Index As Int)
	CurrentTheme = ThemeList.Get(Index)
	CTindex = Index
End Sub



Sub LoadPicture(Filename As String, Dir As String)As Int 
	Dim temp As LCARpicture, Index As Int 
	Index=FindPicture(Filename,Dir)
	If Index>-1 Then Return Index 
	temp.Initialize 
	temp.Name = Filename 
	If Dir.Length = 0 Then Dir = File.DirAssets
	temp.Dir = Dir 
	temp.Picture.Initialize(Dir,Filename)
	If temp.Picture.IsInitialized Then
		PictureList.Add(temp)
		Return PictureList.Size-1
	Else
		Log(File.Combine(Dir, Filename) & " failed to load")
		Return -1
	End If
End Sub
Sub FindPicture(Filename As String, Dir As String) As Int
	Dim temp As Int ,Picture As LCARpicture 
	If Dir.Length = 0 Then Dir = File.DirAssets
	For temp = 0 To PictureList.Size-1
		Picture = PictureList.Get(temp)
		If Picture.Name=Filename Then
			If Picture.Dir = Dir Then Return temp
		End If
	Next
	Return -1
End Sub

Sub IsToastVisible(BG As Canvas, Resize As Boolean ) As Int
	If VolSeconds >0 OR VolOpacity >0 Then
		If VolText.Length = 0 Then
			Return 1
		Else
			If BG <> Null AND Resize Then SizeToast(BG, VolText.Replace(" " & CRLF , " "))
			Return 2
		End If
	End If
End Sub

Sub ToastMessage(BG As Canvas, Text As String, Seconds As Int)
	Dim temp As LCARtimer  'VolOpacity VolOpacity
	If Text.Length>0 Then
		Log("TOAST: " & Text)
		If VolSeconds >0 OR VolOpacity >0 OR Not( BGisInit ) Then'the toast is visible, push it onto the stack
			temp.Initialize 
			temp.Name = Text
			temp.Duration = Seconds
			VolTextList.Add(temp)
		Else
			VolSeconds=(1000/VolInc)*Seconds
			SizeToast(BG,Text)
		End If
	End If
End Sub
Sub SizeToast(BG As Canvas,Text As String)
	Dim MaxWidth As Int
	MaxWidth = ScaleWidth-50' Min(ScaleWidth,ScaleHeight)-50
	VolText= API.TextWrap(BG, LCARfont, Fontsize, Text.ToUpperCase, MaxWidth)
	If VolText.Contains(CRLF) Then
		MaxWidth= API.CountInstances(VolText,CRLF)'  (Regex.Matcher(CRLF, VolText).GroupCount+1)
		'debug(MaxWidth & " returns in " & VolText)
	Else
		MaxWidth=1
	End If
	VolDimensions=Trig.SetPoint(API.TextWidthAtHeight(BG,LCARfont,VolText,Fontsize),  TextHeight(BG, "TEST")*MaxWidth + API.IIF(MaxWidth=1, 0,2))
End Sub
Sub PullNextToast(BG As Canvas)
	Dim temp As LCARtimer
	If VolSeconds=0 AND VolOpacity=0 Then
		If VolTextList.Size =0 Then
			VolText=""
		Else
			temp = VolTextList.Get(0)
			ToastMessage(BG, temp.Name, temp.Duration )
			VolTextList.RemoveAt(0)
		End If
	End If
End Sub




Sub PlaySoundAnyway(Index As Int)
	Dim temp As Boolean 
	temp=Mute
	Mute=False
	MP.SetVolume(1,1)
	ResetVol=True
	PlaySound(Index,False)
	Mute=temp
End Sub

Sub EnumSounds(ListID As Int)
	Dim temp As Int ,Sound As LCARSound 
	'lcar_clearlist(listid,0)
	For temp=0 To SoundList.Size-1
		Sound = SoundList.Get(temp)
		LCAR_AddListItem(ListID, Sound.Name , LCAR_Random, File.Size(Sound.Dir, Sound.Filename)  , Sound.Filename ,False, "", 0, False,-1)
	Next
End Sub

Sub Volume(Value As Int, ShowToast As Boolean )As Int 
	Dim temp As Double 
	If Value<0 Then Value=0
	If Value>100 Then Value=100
	If Value=0 Then 
		Mute=True
		Stop
	Else 
		Mute=False
	End If
	temp=Value*0.01
	Try 
		MP.SetVolume(temp,temp)
	Catch
		MP.Initialize2("MP")
		MP.SetVolume(temp,temp)
	End Try
	'MP2.SetVolume(temp,temp)
	'If PlayID>-1 Then SP.SetVolume(PlayID, Value*0.01, Value*0.01)
	If ShowToast Then
		'VolOpacity=255
		VolSeconds=VolVisible
	End If
	cVol = Value
	Return cVol
End Sub

Sub SetVol(Direction As Boolean)As Boolean 
	Dim temp As Int ,Ret As Boolean 
	temp = cVol
	Ret = Volume(cVol+ API.IIF(Direction, 10,-10), True) <> temp
	If STimer.CurrentPhoneState>0 Then Ret=False
	Return Ret
End Sub

Sub IsPlaying As Boolean 
	Return MP.IsPlaying 'OR MP2.IsPlaying  'OR PlayID>-1
End Sub 
Sub Stop
	Looping=-1
	MP.Stop 
	'MP2.Stop 
	'If PlayID>-1 Then 
	'	SP.Stop (PlayID)
	'	SP.Unload(PlayID)
	'	PlayID=-1
	'End If
End Sub


Sub PlaySound(Index As Int, doLoop As Boolean )As Boolean 
	If ResetVol Then Volume(cVol,False)
	If Not(Mute) AND Index < SoundList.Size Then
		If MP.IsPlaying Then
			If (WasPlaying<>Looping) AND Not(doLoop) Then Return False'prevent interuptions
			MP.Stop
		End If
		If Index<0 Then Index = Rnd(0, SoundList.Size)
		If doLoop Then Looping = Index
		CurrSound = SoundList.Get(Index)
		WasPlaying=Index
'		If CurrSound.UseSoundPool>0 Then
'		'	PlayID=SP.Load(Sound.Dir, Sound.Filename)
'		'	SP.Play(PlayID, cVol*0.01,  cVol*0.01, 9999,-1,1)
'			MP2.Load(CurrSound.Dir, CurrSound.Filename)
'		End If
		'Else
		Try
			MP.Load(CurrSound.Dir, CurrSound.Filename)
			MP.Looping=doLoop 'AND (CurrSound.UseSoundPool=0)
			MP.Play 
			'MP.Looping=doLoop
		'End If
		Catch
			Return False
		End Try
		Return True
	End If
End Sub

Sub CheckLoopingSound( )
	Dim Clicked As ElementClicked
	If WasPlaying>-1 Then
		If MP.IsPlaying = False Then 'AND MP2.IsPlaying=False Then
			If CurrSound.Length=0 Then CurrSound.Length = MP.Position 
			If Looping=WasPlaying Then'AND CurrSound.UseSoundPool>0 Then
				'MP.Position=0
				'MP.Play 
				'MP.Looping=True
			Else
				Clicked.ElementType = LCAR_StoppedPlaying
				Clicked.Index = WasPlaying
				Clicked.Index2= MP.Position 
				WasPlaying=-1
				EventList.Add(Clicked)
				If Looping>-1 Then	PlaySound(Looping,True)
			End If
'		Else If CurrSound.UseSoundPool>0 Then
'			CheckSound(MP,MP2)
'			CheckSound(MP2,MP)
		End If
	End If
End Sub
'Sub CheckSound(MP1 As MediaPlayer, aMP2 As MediaPlayer)
'	If MP1.IsPlaying AND MP1.Position>= CurrSound.UseSoundPool Then 
'		If aMP2.IsPlaying Then
'			If aMP2.Position>0 Then
'				MP1.Pause 
'				MP1.Position=0
'			End If
'		Else
'			aMP2.Play  
'		End If
'	End If
'End Sub

Sub FindSound(Name As String) As Int
	Dim temp As Int,Sound As LCARSound 
	'If dir.Length = 0 Then dir = File.DirAssets
	For temp = 0 To SoundList.Size-1
		Sound=SoundList.Get(temp)
		If Sound.Name.EqualsIgnoreCase(Name) Then Return temp
	Next
	Return -1
End Sub
Sub AddSound(Name As String , Filename As String, Dir As String)As Int 
	Dim Sound As LCARSound,temp As Int 
	temp=FindSound(Name)
	If Dir.Length = 0 Then Dir = File.DirAssets
	If temp>-1 Then 	
		Sound = SoundList.Get(temp)
		Sound.Filename=Filename
		Sound.Dir =Dir 
		Return temp
	End If
	Sound.Initialize 
	Sound.Name = Name
	Sound.Filename = Filename
	Sound.Dir = Dir
	SoundList.Add(Sound)
	Return SoundList.Size-1
End Sub'1610
Sub SetSoundLength(SoundID As Int, Length As Int)
	Dim Sound As LCARSound 
	Sound=SoundList.Get(SoundID) 
	Sound.Length=Length
End Sub

'Sub SetSoundPool(SoundID As Int, UseSoundPool As Int)
'	Dim Sound As LCARSound 
'	Sound=SoundList.Get(SoundID) 
'	Sound.UseSoundPool=UseSoundPool
'End Sub
Sub GetColor2(ColorID As Int, State As Boolean) As Int
	Return GetColor(ColorID,State,255)
End Sub
Sub GetColor(ColorID As Int, State As Boolean, Alpha As Int)As Int
	Dim Color As LCARColor ,temp As Int
	If RedAlert AND ColorID< LCAR_White AND ColorID>LCAR_Black Then ColorID = LCAR_RedAlert
	If ColorID<0 Then ColorID=CurrentTheme.ColorList( Abs(ColorID)-1)
	If ColorID>= LCARcolors.Size Then ColorID= LCAR_Orange
	Color = LCARcolors.Get(ColorID)
	If Alpha<0 Then
		Alpha=Abs(Alpha)
		If State Then 
			If ColorID = LCAR_RedAlert Then
				temp=Min(255,256-Alpha)
				Return Colors.RGB(temp,temp,temp)
			Else
				Return Colors.RGB( Min(Color.sR+Alpha,255), Min(Color.sG+Alpha,255), Min(Color.SB+Alpha,255))
			End If
		Else
			Return Colors.RGB( Min(Color.nR+Alpha,255), Min(Color.nG+Alpha,255), Min(Color.nB+Alpha,255))
		End If
	Else If Alpha<255 Then
		If State Then 
			Return Colors.ARGB(Alpha, Color.sR, Color.sG, Color.SB ) 
		Else
			Return Colors.ARGB(Alpha, Color.nR, Color.nG, Color.nB ) 
		End If
	Else 
		If State Then
			Return Color.Selected 
		Else 
			Return Color.Normal 
		End If
	End If
End Sub
Sub DrawText2(BG As Canvas,X As Int, Y As Int, Textsize As Int, Text As String, Color As Int, Align As Int) As Int 
	BG.DrawText(Text,X, Y + BG.MeasureStringHeight(Text,LCARfont,Textsize), LCARfont, Textsize,Color, API.IIFIndex(Align, Array As String("LEFT", "CENTER", "RIGHT")))
	Return BG.MeasureStringwidth(Text,LCARfont, Textsize)
End Sub
Sub DrawText(BG As Canvas, X As Int,  Y As Int, Text As String, ColorID As Int, Align As Int,State As Boolean, Alpha As Int, Off As Int  )As Boolean 
	Dim Alignment As String  ,temp As Int, tempstr() As String ,doBG As Boolean ,Width As Int 
	If Text=Null Then Return False
	If Text.Length>0 Then
		ColorID=GetColor(ColorID, State,Alpha)
		doBG=Off<0
		If doBG Then Width=BG.MeasureStringWidth(Text,LCARfont,Fontsize)+1
		If Off <1 Then Off=BG.MeasureStringHeight("ABC123",LCARfont,Fontsize)'      Text,LCARfont,Fontsize)'+1'   TextHeight(BG, "ABC123")+1'bg.MeasureStringHeight(text,lcarfont,fontsize)'LCARfontheight+1'
		
		Select Case Align
			Case 0,1,4,7: Alignment = "LEFT"
				If doBG Then BG.DrawRect(SetRect(X,Y, Width+1, Off+1), Colors.Black, True,0)
			Case 2,5,8: Alignment = "CENTER"
				If doBG Then BG.DrawRect(SetRect(X-Width*0.5,Y, Width+1, Off+1), Colors.Black, True,0)
			Case 3,6,9: Alignment = "RIGHT"
				If doBG Then BG.DrawRect(SetRect(X-Width,Y, Width+1, Off+1), Colors.Black, True,0)
			Case Else
				Return False'invalid alignment, prevent crashing
		End Select
		
		Text=Text.Replace("\n", CRLF)
		If Text.Contains(CRLF) Then
			tempstr= Regex.Split(CRLF, Text)
			For temp = 0 To tempstr.Length -1
				BG.DrawText(tempstr(temp).Trim,X,Y +Off, LCARfont, Fontsize,ColorID, Alignment)
				Y=Y+Off+2
			Next
		Else
			BG.DrawText(Text,X,Y +Off, LCARfont, Fontsize,ColorID, Alignment)
		End If
	End If
End Sub

Sub TextHeight(BG As Canvas, Text As String)As Int 
	Return API.TextHeightAtHeight(BG, LCARfont, Text,Fontsize)
End Sub
Sub TextWidth(BG As Canvas, Text As String) As Int
	Return API.TextWidthAtHeight(BG,LCARfont,  Text, Fontsize)
End Sub

Sub GetARGB(Color As Int) As Int()
    Dim res(4) As Int
    res(0) = Bit.UnsignedShiftRight(Bit.AND(Color, 0xff000000), 24)
    res(1) = Bit.UnsignedShiftRight(Bit.AND(Color, 0xff0000), 16)
    res(2) = Bit.UnsignedShiftRight(Bit.AND(Color, 0xff00), 8)
    res(3) = Bit.AND(Color, 0xff)
    Return res
End Sub

Sub LCAR_RandomColor As Int'5 6 11
	'LCARcolors.Size-2
	Return Rnd(1, 12)'doesnt include black (0) or redalert (LCARcolors.Size-1), or white (LCARcolors.Size-2)
End Sub

Sub LCAR_RandomUnusedColor(ListID As Int, ExcludeBlack As Boolean ) As Int
	Dim TempList As LCARlist, TempItem As LCARlistitem, temp As Int, temp2 As Int, UsedColors As List 
	UsedColors.Initialize 
	For temp = 0 To LCARcolors.Size-1
		UsedColors.Add(False)
	Next
	If ExcludeBlack Then UsedColors.Set(LCAR_Black,True)
	UsedColors.Set(LCAR_RedAlert,True)
	
	TempList= GetList(ListID)
	For temp = 0 To TempList.ListItems.Size-1
		TempItem = TempList.ListItems.Get(temp)
		UsedColors.Set( TempItem.ColorID, True)
	Next
	
	For temp = 0 To LCARcolors.Size-1
		If UsedColors.Get(temp) Then temp2 = temp2+1
	Next

	If temp2 = LCARcolors.Size Then
		Return -1'all colors are used
	Else
		temp=Rnd(0, LCARcolors.Size)
		Do While UsedColors.Get(temp)
			temp=Rnd(0, LCARcolors.Size)
		Loop
		Return temp
	End If
End Sub

Sub FindLCARcolor(Name As String) As Int 
	Dim temp As Int, tempColor As LCARColor
	For temp = 0 To LCARcolors.Size-1
		tempColor = LCARcolors.Get(temp)
		If tempColor.Name.EqualsIgnoreCase(Name) Then Return temp
	Next
	Return -1
End Sub
Sub AddLCARcolor(Name As String, r As Int,G As Int, B As Int, Brightness As Int ) As Int 
	Dim temp As LCARColor ,temp2 As Int
	temp2=FindLCARcolor(Name)
	If temp2=-1 Then
		temp.Initialize 
		temp.Name = Name
		temp.Normal = Colors.ARGB(255,r,G,B)
		temp.nR=r:temp.nG=G:temp.nB=B 
		If r=0 AND G=0 AND B=0 Then
			temp.Selected = temp.Normal 
			temp.sR=r:temp.sG=G:temp.SB=B
		Else If Name = "Red Alert" Then
			temp.Selected = Colors.White 
			temp.sR=255:temp.sG=255:temp.SB=255
		Else
			temp.sR=Min(r+Brightness,255):temp.sG= Min(G+Brightness,255):temp.SB=Min(B+Brightness,255)
			temp.Selected = Colors.RGB(temp.sR, temp.sG,temp.SB )
		End If
		LCARcolors.Add(temp)
		Return LCARcolors.Size -1
	Else
		Return temp2
	End If
End Sub

Sub SetupLCARcolors(Act As Activity)As Boolean 
	Dim temp As Int, Lists As LCARlist , Ret As Boolean ,ActIsNull As Boolean 
	
	If Act=Null Then 
		ActIsNull=True
	Else If Not(Act.IsInitialized) Then
		ActIsNull=True
	End If
	
	If ActIsNull AND Event_Down>0 Then Return False
	Ret = SetupTheVariables
	If Not(ActIsNull) Then
		ScaleWidth = Act.Width 
		ScaleHeight = Act.Height 
	End If
	LCARSeffects.CacheAngles( Min(ScaleWidth,ScaleHeight)*2,-1)
	Landscape= ScaleWidth>ScaleHeight
	For temp =0 To LCARlists.Size-1
		Lists = LCARlists.Get(temp)
		Lists.RedX=0
		Lists.RedY=0
		LCARlists.Set(temp,Lists)
	Next
	IsClean=False
	HideToast
	SetupColors
	Return Ret
End Sub
Sub SetupColors As Boolean 
	Dim DB As Int
	If Not(LCARcolors.IsInitialized)  Then	
		DB=64
		If Landscape Then BiggestHeight = ScaleWidth Else BiggestHeight=ScaleHeight
		WasPlaying=-1
		Looping=-1
		LCARfont = Typeface.LoadFromAssets("lcars.ttf")
		LCARcolors.Initialize
		LCAR_Black = AddLCARcolor("Black",0,0,0, DB )						'0	checked manually
		
		LCAR_DarkOrange = AddLCARcolor("Dark Orange", 215, 107, 0, DB)		'1	checked
		LCAR_Orange = AddLCARcolor("Orange", 253,153,0, DB) 				'2	checked
		LCAR_LightOrange = AddLCARcolor("Light Orange", 255, 255, 0, DB*2)	'3	checked
		LCAR_Purple = AddLCARcolor("Purple", 255,0,255, DB*2)				'4	checked
		LCAR_LightPurple = AddLCARcolor("Light Purple", 204,153,204, DB)	'5
		LCAR_LightBlue = AddLCARcolor("Light Blue", 153,153,204, DB)		'6
		LCAR_Red = AddLCARcolor("Red", 204,102,102, DB)						'7	checked
		LCAR_Yellow = AddLCARcolor("Yellow", 255,255,0, DB*2)' 204,153, DB*2)				'8	checked
		LCAR_DarkBlue = AddLCARcolor("Dark Blue", 153,153,255, DB)			'9	checked
		LCAR_DarkYellow = AddLCARcolor("Dark Yellow", 255,153,102, DB)		'10	checked
		LCAR_DarkPurple = AddLCARcolor("Dark Purple", 204,102,153, DB)		'11
		LCAR_White = AddLCARcolor("White", 255,255,255, DB*2)				'12 checked
		
		LCAR_RedAlert = AddLCARcolor("Red Alert", 204,102,102, DB)			'13	checked manually
		
		Classic_Yellow = AddLCARcolor("Light Green", 152,255,102, DB)	'14
		Classic_Green = AddLCARcolor("Green", 6,138,3, DB)			'15
		Classic_LightBlue=AddLCARcolor("Lighter Blue",153,205,255,DB)	'16
		Classic_Blue = AddLCARcolor("Blue", 0,0,254, DB)			'17
		Classic_Turq = AddLCARcolor("Turq", 76,232,185, DB)'18
		
		LCAR_Grey = AddLCARcolor("Grey", 128,128,128,128)'19

		
		AddSound("KLAXON", "criticalstop.ogg", "")
		
		NewTheme("TNG", Array As Int(LCAR_LightPurple,LCAR_DarkPurple,LCAR_Orange,LCAR_Red,LCAR_LightOrange))
		ChangeTheme(0)
		
		Return True
	End If
End Sub

Sub FindTheme(Name As String) As Int
	Dim temp As Int, Theme As ColorTheme 
	For temp = 0 To ThemeList.Size-1
		Theme=ThemeList.Get(temp)
		If Theme.Name.EqualsIgnoreCase(Name) Then Return temp 
	Next
	Return -1
End Sub 

Sub ProcessScale(X As Int, Width As Int) As Int 
	If X>MAXDIM Then' is above maximum X, so scale to width by percent
		Return ((X-MAXDIM)*0.01)*Width
	Else If X<MINDIM Then'is below minimum X so scale to width by percent
		Return ((X+MINDIM)*0.01)*Width
	End If
	Return X
End Sub

Sub ProcessLocX(X As Int, Off As Int, Width As Int, IsWidth As Int )As Int 
	Dim temp As Int 
	temp=ProcessScale(X , Width)

	If IsWidth>0 Then'is a width/height
		If temp<=0 Then 
			temp = Width+temp -IsWidth
		'Else If smallscreen Then 
		'	temp=temp*0.5
		End If
	Else'is an x/y
		If temp<0 Then
			temp = Width+temp 
		'Else If smallscreen Then 
		'	temp=temp*0.5
		End If
	End If	
	Return temp+Off
End Sub

Sub ProcessLoc(LOC As tween, Size As tween) As tween 
	Dim temp As tween 
	If LOC<> Null AND Size <> Null Then
		temp.Initialize 
		temp.currX=ProcessLocX( LOC.currX , LOC.offX, ScaleWidth,0 )'X/left
		temp.curry=ProcessLocX( LOC.curry , LOC.offy, ScaleHeight,0 )'Y/top
		temp.offX = ProcessLocX( Size.currX , Size.offX, ScaleWidth,temp.currX)'-temp.currX'width
		temp.offy=ProcessLocX( Size.curry , Size.offy, ScaleHeight,temp.curry)'-temp.curry'height
		Return temp
	End If
End Sub


Sub NeedsClearing As Boolean 
	Return ElementMoving OR Not(IsClean) OR ListIsMoving 
End Sub 

Sub BlankScreen(BG As Canvas)
	If BGisInit AND Not(BG=Null) Then BG.Drawcolor(Colors.Black)'LCAR.DrawRect(BG,0,0,LCAR.ScaleWidth,LCAR.ScaleHeight,Colors.Black,0)
End Sub
Sub ClearScreen(BG As Canvas )
	If Not(ClearLocked) Then
		IsClean=False
		'If BG<> Null Then 	BG.Drawcolor(Colors.Black)
		IsAAon=False
		CurrListID=-1
	End If
End Sub

Sub SetSensorXY(LCARid As Int, Xpercent As Int, Ypercent As Int, ScaleToNeg As Boolean )
	Dim Element As LCARelement
	Element = LCARelements.Get(LCARid)
	If Element.Visible Then
		Element.IsClean=False
		If ScaleToNeg Then
			Xpercent= 50 + Xpercent*0.5
			Ypercent=50 + Ypercent*0.5
		End If
		Element.align= Xpercent
		Element.TextAlign=Ypercent
		'debug("X: " & Xpercent & " Y: " & Ypercent)
		LCARelements.Set(LCARid, Element)
	End If
End Sub

Sub IncrementSensorX(LCARid As Int, RWidth As Int, Z As Int)
	Dim Element As LCARelement
	Element = LCARelements.Get(LCARid)
	Element.RWidth = Increment(Element.RWidth, 5, RWidth)
	Element.align = Increment(Element.align, 5, Z)
	'debug(LCARid & " X: " & RWidth & " Z: " & Z)
	LCARelements.Set(LCARid, Element)
End Sub

Sub SetGraphPercent(ListID As Int, ListItems As List)
	Dim Lists As LCARlist , ListItem As LCARlistitem ,temp As Int ,Index As Int, Percent As Int
	If LCARVisibleLists.Get(ListID) Then
		Lists = LCARlists.Get(ListID)
	'If lists.Visible Then
		Lists.IsClean = False
		For temp = 0 To ListItems.Size-1 Step 2
			Index=ListItems.Get(temp)
			Percent=ListItems.Get(temp+1)
			'debug("I: " & index & " P: " & percent)
			ListItem=Lists.ListItems.Get(Index)
			ListItem.IsClean=False
			ListItem.Number=Abs(Percent)
		
			Lists.ListItems.Set(Index,ListItem)
		Next
		LCARlists.Set(ListID, Lists)
	End If
End Sub

Sub IncrementElement(ElementID As Int, Element As LCARelement,Speed As Int, SpeedSlider As Int )
	Dim  Didit As Boolean , Didit2 As Boolean , Didit3 As Boolean ,Old As Int
		If Element.Visible Then'AND group.Visible Then
	
		'move on 1 axis at a time
		If Element.LOC.offX <> 0 Then 
			Element.LOC.offX = Increment(Element.LOC.offX, Speed,0)
			Didit = True	
		Else If Element.LOC.offy <> 0 Then	
			Element.LOC.offy = Increment(Element.LOC.offy, Speed,0)
			Didit=True
		End If
		
		'resize
		If (Element.Size.offX <> 0) OR (Element.Size.offy <> 0) Then
			Element.Size.offX = Increment(Element.Size.offX, Speed,0)
			Element.Size.offy = Increment(Element.Size.offy, Speed,0)
			Didit=True
		End If
		
		'alpha
		If Element.Opacity.Current <> Element.Opacity.Desired Then
			If AlphaBlending Then 
				Element.Opacity.Current = Increment(Element.Opacity.Current, Alphaspeed,Element.Opacity.Desired)
			Else
				Element.Opacity.Current = Element.Opacity.Desired
			End If
			If Element.Opacity.Current = 0 Then Element.Visible = False 
			Didit=True
		End If	

		Select Case Element.ElementType 

			Case LCAR_Meter, LCAR_Slider,LCAR_HorSlider, LCAR_Tactical', LCAR_Chart
				Old=Element.LWidth
				Element.LWidth=Increment(Element.LWidth, SpeedSlider, Element.RWidth)
				If Old <> Element.LWidth Then 
					Didit3= True 
					If Element.RespondToAll AND ElementID>-1 Then	PushEvent(Element.ElementType , ElementID, Element.LWidth- Old,0,0,0,0, Event_Scroll)
				Else
					If Element.TextAlign= LCAR_Random Then 
						Didit3=True
						Element.RWidth = Rnd(0,101)
					End If
				End If
				
				
			Case LCAR_Textbox
				'element.IsClean = False
				'didit3=True
				
				If Element.SideText.Length>0 AND Element.Opacity.Current>0 Then
					Element.Text = Element.Text & Element.SideText.SubString2(0,1)'typewriter effect
					Element.SideText = Element.SideText.SubString(1)
					Didit3=True
				End If
			
			Case LCAR_Alert
				Element.rWidth=Element.rWidth+1
				If Element.RWidth = LCARSeffects.OkudaStages Then Element.rWidth=0
				Didit3=True
			
			
			Case LCAR_Graph
				'LCARSeffects2.IncrementGraph(Element.TextAlign, Element.Align)
				If Not(LCARSeffects2.isGraphClean(Element.TextAlign)) Then Didit3=True
			

			
			Case LCAR_ShieldStatus
				Pulse(Element,LCARSeffects.MaxShieldStages)
				Didit3=True
			
			Case LCAR_Static
				Pulse(Element,16)
				Didit3=True
				
			
			Case LCAR_RndNumbers, TOS_RndNumbers
				If Not(didIncrementNumbers) Then 
					didIncrementNumbers=True
					Didit3 = LCARSeffects2.IncrementNumbers
				Else
					Didit3=didIncrementNumbers
				End If
				
			Case LCAR_List
				Didit2 = IncrementList( Element.LWidth, Speed,SpeedSlider) 
			
			Case LCAR_Answer
				Old=2
				Locked = False
				Select Case Element.LWidth
					Case -2'false/red and larson red
						Element.RWidth=Element.RWidth-Old
						If Element.RWidth<0 Then 
							Element.RWidth=0 'Element.RWidth+Old
							Element.LWidth=-1
						End If
						Didit3=True
					Case -1'true/green and larson green
						Element.RWidth=Element.RWidth+Old
						If Element.RWidth>100 Then
							Element.RWidth=100'Element.RWidth-Old
							Element.LWidth=-2
						End If
						Didit3=True
				End Select
				
		End Select
	
		If Didit OR Didit3 Then
			Element.IsClean = False
			'LCARelements.Set(ElementID,Element)
			If Didit AND Not(Element.Async) Then Didit2=True  
			'isclean=False
		End If
		
	End If
	Return Didit2
End Sub

Sub IncrementList(ListID As Int, Speed As Int, SpeedSlider As Int)As Boolean 
	Dim ListItem As LCARlistitem , didit As Boolean , didit2 As Boolean, didit3 As Boolean ,Lists As LCARlist
	Lists= LCARlists.Get(ListID)
	'If lists.IsInitialized Then
				Lists.Visible = True
				'alpha
				If Lists.Opacity.Current <> Lists.Opacity.Desired Then
					If AlphaBlending Then 
						Lists.Opacity.Current = Increment(Lists.Opacity.Current, Alphaspeed,Lists.Opacity.Desired)
					Else 
						Lists.Opacity.Current =Lists.Opacity.Desired
					End If
					If Lists.Opacity.Current = 0 Then 
						LCARVisibleLists.Set(ListID,False)
						Lists.Visible = False 
						If VisibleList = ListID Then VisibleList=-1
					End If
					didit=True	
				End If	
				'cleanup
				If Lists.Visible AND Lists.Opacity.Current=0 Then 
					Lists.visible=False
					LCARVisibleLists.Set(ListID,False)
					didit=True
				End If
			
				'move on 1 axis at a time
				If Lists.LOC.offX <> 0 Then 
					Lists.LOC.offX = Increment(Lists.LOC.offX, Speed,0)
					didit = True	
				Else If Lists.LOC.offy <> 0 Then	
					Lists.LOC.offy = Increment(Lists.LOC.offy, Speed,0)
					didit=True
				End If
				
				'size
				If (Lists.Size.offX <>0) OR (Lists.Size.offy <> 0) Then
					Lists.Size.offX = Increment(Lists.Size.offX, Speed,0)
					Lists.Size.offy = Increment(Lists.Size.offy, Speed,0)
					didit=True
				End If
				
				'items
				Select Case Lists.Style 
					Case 0'Normal, GNDN
					Case LCAR_Chart, LCAR_Meter'Chart, '1=Chart ShowNumber=true randomizes item Numbers when = whitespace, Number=Desired Percent, WhiteSpace=Current Percent
						For temp2 = 0 To Lists.ListItems.Size-1
							ListItem = Lists.ListItems.Get(temp2)

							ListItem.WhiteSpace= Increment(ListItem.WhiteSpace,SpeedSlider,ListItem.Number)	
							If Lists.ShowNumber AND ListItem.Number = ListItem.WhiteSpace Then ListItem.Number = Rnd(0,101)
							
							Lists.ListItems.Set(temp2,ListItem)
						Next
						didit3=True
						ListIsMoving=True

				End Select
				
				If didit OR didit3 Then 
					Lists.IsClean = False
					'LCARlists.Set(temp,Lists)
					If didit AND Not (Lists.Async) Then didit2=True  
					Lists.IsClean=False
				End If
			
			'Else
			'	Log("List " & temp & " is not initialized")
			'End If
			Return didit2
End Sub
Sub IncrementLCARs(Speed As Int, SpeedSlider As Int, Interval As Int )
	Dim Element As LCARelement ,Didit As Boolean ,Didit2 As Boolean ,Didit3 As Boolean ,Old As Int ,WasMoving As Boolean ,Clicked As ElementClicked ,Lists As LCARlist 
	Dim temp2 As Int,  temp As Int ,temp2 As Int, Group As LCARgroup,ElementID As Int
	ListIsMoving=False
	WasMoving = ElementMoving
	ElementMoving=True
	didIncrementNumbers=False
	
	For temp=0 To LCARlists.Size-1
		Didit=False
		'If lists.Visible Then
		If LCARVisibleLists.Get(temp) Then
			If IncrementList(temp, Speed,SpeedSlider) Then Didit2=True
		End If
	Next
	
	For temp = 0 To  LCARGroups.Size-1
		Group= LCARGroups.Get(temp)
		If Group.Visible Then
			For temp2= 0 To Group.LCARlist.Size-1
				ElementID = Group.LCARlist.Get(temp2)
				Element= LCARelements.Get(ElementID)
				If IncrementElement(ElementID, Element, Speed, SpeedSlider) Then Didit2=True
			Next
		End If
	Next

	If Not(Didit2) Then 
		ElementMoving = False 
		'isclean=False
		If WasMoving Then 
			Clicked.ElementType = LCAR_StoppedMoving
			Clicked.Index = Stage
			EventList.Add(Clicked)
		End If
	End If
	
	CheckLoopingSound
	
	If VolSeconds>0 Then
		VolOpacity = Increment(VolOpacity,16,255)
	Else If VolOpacity>0 Then
		If VolSeconds=0 Then
			VolOpacity = Increment(VolOpacity,16,0)
			If VolOpacity=0 Then 
				PushEvent(LCAR_ToastDone,0,0,0,0,0,0, Event_Down)
			End If
		End If
	End If
	
	If TimerPeriod >0 Then
		If MinTimer = 0 Then 
			MinTimer = DateTime.Now 
		Else
			temp = DateTime.Now - MinTimer 
			If temp> TimerPeriod Then
				MinTimer = MinTimer + (Floor(temp / TimerPeriod)*TimerPeriod)
				temp = DateTime.Now - MinTimer 
			End If
			PushEvent(LCAR_TimerIncrement , -1, temp ,-1,0,0,0,0)
		End If
	End If
End Sub
Sub StartMicroTimer(Period As Int)
	If Period=0 Then
		MinTimer=0
	Else
		MinTimer = DateTime.Now 
	End If
	TimerPeriod=Period
End Sub

Sub Pulse(Element As LCARelement, Maximum As Int)
	If Element.RWidth=0 Then
		Element.Lwidth=Element.Lwidth+1
		If Element.Lwidth = Maximum Then 
			Element.Lwidth=Maximum-1
			Element.RWidth=1
		End If
	Else
		Element.Lwidth=Element.Lwidth-1
		If Element.Lwidth = 0 Then Element.RWidth=0
	End If
End Sub

Sub Increment(X As Int, Speed As Int, Neutral As Int) As Int
	If X=Neutral OR API.debugMode Then
		Return Neutral
	Else If X<Neutral Then
		If X+Speed<Neutral Then Return X+Speed Else Return Neutral
	Else If X>Neutral Then
		If X-Speed>Neutral Then Return X-Speed Else Return Neutral
	End If
End Sub

Sub SetAsync(Element As Int, IsList As Boolean )
	Dim temp As LCARelement,temp2 As LCARlist 
	If IsList Then
		temp2=LCARlists.Get(Element)
		temp2.Async=True
		'LCARlists.Set(Element,temp2)
	Else
		temp=LCAR_GetElement(Element)
		temp.Async=True
		'LCARelements.Set(Element, temp)
	End If
End Sub
Sub SetAlignment(ListID As Int, Alignment As Int)
	Dim temp As LCARlist 
	temp = LCARlists.Get(ListID)
	temp.Alignment = Alignment
	temp.IsClean=False
	'LCARlists.Set(ListID,temp)
End Sub

Sub ClearLRwidths(ListID As Int)
	Dim Lists As LCARlist 
	Lists = LCARlists.Get(ListID)
	Lists.LWidth=0
	Lists.RWidth=0
	'LCARlists.Set(ListID,Lists)
End Sub

Sub LockListStart(ListID As Int, State As Boolean)As Int 
	Dim Lists As LCARlist 
	Lists = LCARlists.Get(ListID)
	Lists.Locked=State
	Return ListID
	'LCARlists.Set(ListID,Lists)
End Sub

Sub NotMoving(ListID As Int)
	Dim Lists As LCARlist= LCARlists.Get(ListID) , HalfItemHeight As Int = GetListItemHeight(Lists) * 0.5
	If SmoothScrolling AND Lists.isScrolling Then 
		If Abs(Lists.Offset) < HalfItemHeight Then Lists.Start = Max(0, Lists.start-1)
	End If
	Lists.isScrolling=False
	Lists.Offset=0
	Lists.IsClean=False
	Lists.Ydown=0
	'LCARlists.Set(ListID,Lists)
End Sub



Sub MoveList(ListID As Int, X As Int, Y As Int)
	Dim Lists As LCARlist
	Lists = LCARlists.Get(ListID)
	Lists.LOC.currX=X
	Lists.LOC.currY=Y
	Lists.LOC.offX=0
	Lists.LOC.offy=0
	Lists.IsClean=False
	'LCARlists.Set(ListID, Lists)
End Sub
Sub ResizeList(ListID As Int, Width As Int, Height As Int, Rwidth As Int, X As Int, Y As Int, Move As Boolean )As Boolean 
	Dim Lists As LCARlist , Element As LCARelement , Size As tween , LOC As tween ,Visible As Boolean 
	If Rwidth=-2 Then
		If ListID < LCARelements.Size Then
			Element=LCARelements.Get(ListID)
			Size=Element.Size
			LOC=Element.LOC 
			Visible=Element.Visible 
		Else
			Return False
		End If
	Else
		If ListID < LCARlists.Size Then
			Lists = LCARlists.Get(ListID)
			Size=Lists.Size 
			LOC=Lists.LOC
			Visible=LCARVisibleLists.Get(ListID)  'lists.Visible 
		Else
			Return False
		End If
	End If
	
	If Visible Then 
		If Width>-1 Then Size.offX= Size.currX - Width
		Size.currX = Width
		If Height>-1 Then Size.offy= Size.curry - Height
		Size.curry = Height
		
		If Move Then
			LOC.offX=LOC.currX - X
			LOC.offY=LOC.currY - Y
			LOC.currX=X
			LOC.currY=Y
		End If
	Else
		Size.offX=0
		Size.offY=0
		Size.currx=Width
		Size.curry=Height
		If Move Then
			LOC.currX=X
			LOC.currY=Y
			LOC.offX=0
			LOC.offY=0
		End If
	End If
	
	If Rwidth=-2 Then
		Element.Size=Size
		Element.LOC = LOC
		'LCARelements.Set(ListID,Element)
	Else
		Lists.Size = Size
		Lists.LOC=LOC
		If Rwidth>-1 Then Lists.Rwidth = Rwidth
		'LCARlists.Set(ListID,Lists)
	End If
	Return True
End Sub

Sub MoveLCAR(LCARid As Int, X As Int, Y As Int, Width As Int, Height As Int, Alpha As Int, DoXY As Boolean , DoWH As Boolean , DoAlpha As Boolean )As Boolean 
	Dim Element As LCARelement  ,Group As LCARgroup 
	Element = LCARelements.Get(LCARid)
	Group= LCARGroups.Get( Element.Group )
	
	ElementMoving=True
	If DoXY Then
		If Element.Visible AND Group.Visible Then
			Element.LOC.currX = ProcessScale(Element.LOC.currX, ScaleWidth)
			Element.LOC.currY = ProcessScale(Element.LOC.currY, ScaleHeight)
			If X<0 AND Element.LOC.currX >0 Then Element.LOC.currX=-ScaleWidth + Element.LOC.currX'normalize
			If Y<0 AND Element.LOC.currY >0 Then Element.LOC.currY=-ScaleHeight + Element.LOC.currY'normalize
			Element.LOC.offX= Element.LOC.currX - X
			Element.LOC.offy= Element.LOC.curry - Y
			Element.LOC.currX=X
			Element.LOC.curry=Y
		Else
			Element.LOC.currX=X
			Element.LOC.currY=Y
			Element.LOC.offX=0
			Element.LOC.offY=0
		End If
	End If
	If DoWH Then
		If Element.Visible AND Group.Visible Then
		
		Else
			Element.size.currX=Width
			Element.size.currY=Height
			Element.size.offX=0
			Element.size.offY=0
		End If
	End If
	
	If DoAlpha Then 
		If API.debugMode Then Element.Opacity.Current = Alpha
		Element.Opacity.Desired= Alpha
		Element.Visible = True
	End If
	'LCARelements.Set(LCARid,Element)
	If Element.LOC.offX <> 0 AND Element.LOC.offy<>0 Then Return True
End Sub

Sub GetListHeight(ListID As Int)As Int 
	Dim Lists As LCARlist,Cols As Int ,RowHeight As Int ,ItemsPerCol As Int, Dimensions As tween 
	Lists= LCARlists.Get(ListID) 
	Select Case Lists.Style 
		Case 0'normal
			Cols=LCAR_ListCols(Lists.ColsLandscape,Lists.ColsPortrait )
			RowHeight= ItemHeight+ListitemWhiteSpace
			ItemsPerCol= LCAR_ListItemsPerCol(Lists.ColsLandscape, Lists.ColsPortrait, Lists.ListItems.Size)
			If Lists.ListItems.Size Mod Cols > 0 Then ItemsPerCol = ItemsPerCol + 1
		Case LCAR_Chart, LCAR_ChartNeg
			RowHeight=ChartHeight + ChartSpace
			ItemsPerCol=Lists.ListItems.Size
		Case LCAR_Meter
			Dimensions=ProcessLoc( Lists.LOC, Lists.Size)
			Return Dimensions.offY 		
	End Select
	Return RowHeight*ItemsPerCol
End Sub

Sub FindClickedElement(SurfaceID As Int, X As Int, Y As Int, GetIndex As Boolean ) As ElementClicked
	Dim temp As Int,temp2 As Int, Element As LCARelement, ElementID As Int, Dimensions As tween ,Group As LCARgroup, ReturnValue As ElementClicked,Lists As LCARlist , SideRect As Rect , TopRect As Rect ,Found As Boolean 
	Dim Cols As Int ,ItemsPerCol As Int ,Start As Int ,RowHeight As Int, ColWidth As Int 
	
	ReturnValue.Initialize
	ReturnValue.Index=-1
	
	If SurfaceID<0 Then Start= Abs(SurfaceID+1)
	

	
	If ReturnValue.Index=-1 AND LCAR_ScreenEnabled Then' not(found)
		For temp = Start To LCARlists.Size-1
			If LCARVisibleLists.Get(temp) AND (Lists.SurfaceID = SurfaceID OR SurfaceID<0) Then' lists.Visible
				Lists= LCARlists.Get(temp) 
				Dimensions=ProcessLoc( Lists.LOC, Lists.Size)
				If IsWithin(X,Y, Dimensions.currX, Dimensions.currY, Dimensions.offX, Dimensions.offY, False) Then
					ReturnValue.Index=temp
					ReturnValue.ElementType= LCAR_List
					ReturnValue.X = X-Dimensions.currX
					ReturnValue.Y = Y-Dimensions.curry
					
					Select Case Lists.Style 
						Case 0'normal
							Cols=LCAR_ListCols(Lists.ColsLandscape,Lists.ColsPortrait )
							ColWidth=Dimensions.offX/ Cols
							RowHeight= ItemHeight+ListitemWhiteSpace
							ItemsPerCol= LCAR_ListItemsPerCol(Lists.ColsLandscape, Lists.ColsPortrait, Lists.ListItems.Size)
							If Lists.ListItems.Size Mod Cols > 0 Then ItemsPerCol = ItemsPerCol + 1
						Case LCAR_Chart, LCAR_ChartNeg
							Cols=1
							ColWidth= Dimensions.offX 
							RowHeight=ChartHeight + ChartSpace
							ItemsPerCol=Lists.ListItems.Size
						Case LCAR_Meter
							ColWidth=(ChartSpace + MeterWidth)
							Cols=Floor( Dimensions.offX  / ColWidth)
							ItemsPerCol=Cols
							RowHeight=Dimensions.offY 
							If Lists.ListItems.Size > Cols Then RowHeight= RowHeight / Ceil(Lists.ListItems.Size / Cols)
							
							ItemsPerCol=1
						Case PCAR_Button
							Cols=LCAR_ListCols(Lists.ColsLandscape,Lists.ColsPortrait )
							If Cols=0 Then Cols = Lists.ListItems.Size 
							ItemsPerCol= Ceil(Lists.ListItems.Size/ Cols)
							ColWidth=Dimensions.offX/ Cols
							RowHeight= (Dimensions.offY /ItemsPerCol) - ListitemWhiteSpace
							
						Case LCAR_MiniButton
							Cols = Lists.ListItems.Size
							ColWidth=Dimensions.offX/ Cols
							RowHeight=Dimensions.offY 
							ItemsPerCol=1
					End Select
					
					ReturnValue.X2= Floor(ReturnValue.X/ (Dimensions.offX/ Cols))'COL
					ReturnValue.Y2= Floor(ReturnValue.Y/RowHeight)'ROW
					ReturnValue.Index2=-1'ListItem
					If GetIndex Then 
						Select Case Lists.Style 
							Case 0,PCAR_Button, LCAR_Chart, LCAR_ChartNeg'normal and ENT
								'ItemsPerCol= lcar_listitemspercol(Lists.ColsLandscape, Lists.ColsPortrait, Lists.ListItems.Size)
								If ReturnValue.Y2 >-1 AND ReturnValue.Y2 < Lists.LastMint Then
								'original formula: y = y + .Start + (ItemsPerCol * x)
								
									'debug("X: " & ReturnValue.X2 & " Y: " & ReturnValue.Y2 & " IPC: " & ItemsPerCol)
									'If ReturnValue.Y2<ItemsPerCol Then 
										ReturnValue.Index2 = ReturnValue.Y2 + Lists.Start + ((ItemsPerCol) * ReturnValue.X2)
										temp2  = ReturnValue.Y2 + Lists.Start + ((ItemsPerCol+1) * ReturnValue.X2)
										'Log ("Item: " & ReturnValue.Index2 & " or " & temp2   &  " Row: " & ReturnValue.Y2)
									'End If
									
									'ReturnValue.Index2 = ReturnValue.Y2 + lists.Start + (lists.LastMint * ReturnValue.X2)
									'Log ("START: " & lists.Start  & " ITEMSPERCOL: " & ItemsPerCol)
									'debug(ReturnValue.X2 & ", " & ReturnValue.Y2 & "CLICKED of: " & lists.LastMint & " ITEM: " & ReturnValue.Index2)
								End If
							'Case LCAR_Chart, LCAR_ChartNeg
								'If ReturnValue.Y2>-1 AND ReturnValue.Y2 < Lists.ListItems.Size Then
								'	ReturnValue.Index2 = ReturnValue.Y2
								'End If
							Case LCAR_Meter
								temp2= ReturnValue.X2 + (ReturnValue.Y2*Cols)
								If temp2>-1 AND temp2 < Lists.ListItems.Size Then 
									ReturnValue.Index2 = temp2
								End If
							Case LCAR_MiniButton
								ReturnValue.Index2=ReturnValue.X2
						End Select
					End If
					temp=LCARlists.Size
				End If
			End If
			If SurfaceID<0 Then temp = LCARlists.Size  
		Next
	End If
	
	'elements
	If SurfaceID>-1 AND ReturnValue.Index=-1 AND LCAR_ScreenEnabled Then
		For temp = 0 To LCARGroups.Size-1
			Group = LCARGroups.Get(temp)
			If Group.Visible Then
				For temp2 = 0 To Group.LCARlist.Size-1
					ElementID = Group.LCARlist.Get(temp2)
					Element = LCARelements.Get(ElementID)
					If Element.Visible AND Element.Opacity.Current>0 AND Element.Enabled AND (SurfaceID = Element.SurfaceID OR SurfaceID<0) Then
						Dimensions=ProcessLoc( Element.LOC, Element.Size)
						If Element.ElementType = LCAR_Elbow AND Element.Align<4 Then
							'If smallscreen Then
							'	element.LWidth=element.LWidth*0.5
							'	element.RWidth=element.RWidth*0.5
							'End If
							Select Case Element.Align
								Case 0,4' |-  top left
									SideRect =  SetRect(Dimensions.currX,Dimensions.currY,Element.LWidth,Dimensions.offY)
									TopRect = SetRect(Dimensions.currX+Element.LWidth-1,Dimensions.currY,Dimensions.offX-Element.LWidth,Element.RWidth)
								Case 1,5'  -| top right
									SideRect =  SetRect(Dimensions.currX,Dimensions.currY,Dimensions.offX,Element.RWidth) 
									TopRect = SetRect(Dimensions.currX+Dimensions.offX-Element.LWidth,Dimensions.currY+Element.RWidth-1,Element.LWidth,Dimensions.offY-Element.RWidth)
								Case 2,6,8' |_  bottom left
									SideRect =  SetRect(Dimensions.currX,Dimensions.currY,Element.LWidth,Dimensions.offY)
									TopRect = SetRect(Dimensions.currX+Element.LWidth-1,Dimensions.currY+Dimensions.offY-Element.RWidth,Dimensions.offX-Element.LWidth,Element.RWidth)
								Case 3,7,9'  _| bottom right
									SideRect =  SetRect(Dimensions.currX+Dimensions.offX-Element.LWidth,Dimensions.currY,Element.LWidth,Dimensions.offY)
									TopRect = SetRect(Dimensions.currX,Dimensions.currY+Dimensions.offY-Element.RWidth,Dimensions.offX-Element.LWidth+1,Element.RWidth)
							End Select
							Found= IsWithin(X,Y, SideRect.Left, SideRect.Top, SideRect.Right ,SideRect.Bottom ,True ) 
							If Not(Found) Then Found = IsWithin(X,Y, TopRect.Left, TopRect.Top, TopRect.Right ,TopRect.Bottom ,True )
						Else
							Found= IsWithin(X,Y, Dimensions.currX, Dimensions.currY, Dimensions.offX, Dimensions.offY, False) 
							If Element.ElementType = LCAR_PdP Then ReturnValue.Index2 = Element.LWidth 
						End If
						If Found OR SurfaceID<0 Then
							ReturnValue.RespondToAll = Element.RespondToAll
							ReturnValue.Index=ElementID
							ReturnValue.ElementType= Element.ElementType
							temp=LCARGroups.Size
							temp2=Group.LCARlist.Size
							ReturnValue.X = X-Dimensions.currX 
							ReturnValue.Y = Y-Dimensions.curry
						End If
					End If
				Next
			End If
		Next
	End If
	
	If ReturnValue.Index>-1 Then ReturnValue.Dimensions = Dimensions
	Return ReturnValue
End Sub



Sub IsWithin(X As Int, Y As Int, Left As Int, Top As Int, Width As Int, Height As Int, WidthIncludesX As Boolean ) As Boolean 
	If X >= Left Then
		If Y >= Top Then
			If WidthIncludesX Then
				If X<Width Then Return Y<Height
			Else
				If X< Left+Width Then  Return Y<Top+Height
			End If
		End If
	End If
End Sub

Sub IsElementMoving(LOC As tween, Size As tween,Alpha As TweenAlpha  ) As Boolean 
	Return LOC.offX<>0 OR LOC.offY<>0 OR Size.offX<>0 OR Size.offY<>0 OR Alpha.Current <> Alpha.Desired 
End Sub 

Sub ScientificNotation(Number As Int) As Int
	Dim tempstr As String 
	If Number>0 Then
		If Number <10 Then
			Return Number*100
		Else
			tempstr=Number
			Return API.left(tempstr,2) & (tempstr.Length-1)
		End If
	End If
End Sub

Sub DaysInYear(Year As Int)
	If Year Mod 4 = 0 Then Return 366 Else Return 365
End Sub

Sub Stardate(theDate As Long, ForceNoon As Boolean, DigitsAfterDecimal As Int )As Double 
	'DateTime.DateFormat(
	Dim Year As Long, Day As Long, hour As Double,temp As Int 
    Year = (DateTime.GetYear(theDate) - 2323) * 1000
    Day = DateTime.GetDayOfYear(theDate) /  DaysInYear(DateTime.GetYear(theDate)) * 1000
    hour = (DateTime.GetHour(theDate) * 3600 + DateTime.GetMinute(theDate) * 60 + DateTime.GetSecond(theDate) ) / 86400
    Year= Year + Day
	If DigitsAfterDecimal>0 Then
		hour=Round2(hour,DigitsAfterDecimal)
		'temp= Power( 10,DigitsAfterDecimal)
		'hour = Round(hour * temp)/temp
	End If
	If ForceNoon AND Year<0 Then
		Return Year+1-hour
	Else
		Return Year + hour
	End If
End Sub

'											lwidth			rwidth
Sub ResizeElbowDimensions(ElementID As Int, BarWidth As Int, BarHeight As Int)
	Dim Element As LCARelement
	Element= LCARelements.Get(ElementID)
		Element.LWidth = BarWidth
		Element.RWidth = BarHeight
	LCARelements.Set(ElementID, Element)
End Sub

Sub DrawElement(BG As Canvas, SurfaceID As Int, ElementID As Int, istheRedAlert As Boolean )As Boolean 
	Dim Element As LCARelement, Dimensions As tween  ,State As Boolean ,Drew As Boolean ,doAlpha As Boolean , BGC As Int,elementismoving As Boolean  ,temp As Int
	Element= LCARelements.Get(ElementID)
	If Element.Visible AND (SurfaceID= Element.SurfaceID OR SurfaceID=-1) Then
		'Group= lcargroups.Get(element.Group)
		If   Element.Opacity.Current>0  Then
			Drew=True
			If Not( Element.IsClean ) OR Not(IsClean) Then
				elementismoving=IsElementMoving( Element.LOC, Element.Size, Element.Opacity )
				State = Element.IsDown
				Dimensions=ProcessLoc( Element.LOC, Element.Size)

				If RedAlert AND istheRedAlert Then 
					'If group.LCARlist.Get( group.RedAlert ) = ElementID Then 
					State = True
				Else
					If Element.Blink AND BlinkState Then State=True
				End If
				Element.IsClean = True
				
				'Select Case Element.ElementType 
				'	Case LCAR_Alert
				'		ActivateAA(BG,True)
				'	Case LCAR_Button,LCAR_Elbow,LCAR_Slider,LCAR_HorSlider
				'		ActivateAA(BG, DoVector)
				'	Case Else: ActivateAA(BG,False)
				'End Select
				
				Select Case Element.ElementType 
					Case LCAR_Button 
						If Element.Align = 0 Then
							DrawLCARbutton(BG, Dimensions.currX,Dimensions.currY, Dimensions.offX ,Dimensions.offY , Element.ColorID, State, Element.Text , Element.SideText  , Element.LWidth , Element.RWidth ,Element.RWidth>0 AND Element.SideText.Length=0 , 4, Element.TextAlign, -1, Element.Opacity.Current,elementismoving)
						Else
							DrawLCARslantedbutton(BG,Dimensions.currX,Dimensions.currY, Dimensions.offX ,Dimensions.offY , Element.ColorID,  Element.Opacity.Current, State, Element.Text ,Element.Align, Element.TextAlign)
						End If
					Case LCAR_Elbow
						DrawLCARelbow(BG,  Dimensions.currX ,Dimensions.currY, Dimensions.offX ,Dimensions.offY , Element.LWidth, Element.RWidth , Element.Align , Element.ColorID , State, Element.Text, Element.TextAlign ,Element.Opacity.Current,elementismoving)
						'If element.Opacity.Current < 255 Then DrawLCARelbow(bg,  Dimensions.currX ,Dimensions.currY, Dimensions.offX ,Dimensions.offY , element.LWidth, element.RWidth , element.Align , lcar_black , state, element.Text, element.TextAlign , 255-element.Opacity.Current )
					Case LCAR_Textbox
						If Element.Align>0 Then LCARSeffects.MakeClipPath(BG,Dimensions.currX ,Dimensions.currY, Dimensions.offX, Element.Align)
						DrawLCARtextbox(BG, Dimensions.currX ,Dimensions.currY, Dimensions.offX,Dimensions.offY, Element.LWidth, Element.RWidth, Element.Text, Element.ColorID, Element.ColorID, LCAR_LightBlue,State, BlinkState, Element.TextAlign,Element.Opacity.Current )
						If Element.Align>0 Then BG.RemoveClip 
					Case LCAR_MultiLine
						'Element.tag = 
						DrawLCARMultiLineTextbox(BG, Dimensions.currX ,Dimensions.currY, Dimensions.offX,Dimensions.offY, Element.LWidth, Element.RWidth, Element.Text, Element.ColorID, State, BlinkState, Element.Opacity.Current, Element.TextAlign)
					Case LCAR_Slider
						DrawLCARSlider(BG , Dimensions.currX , Dimensions.currY,Dimensions.offY, Element.LWidth, Element.ColorID,  State,Element.Opacity.Current,elementismoving,False)
					Case LCAR_HorSlider
						DrawLCARSlider(BG , Dimensions.currX , Dimensions.currY,Dimensions.offx, Element.LWidth, Element.ColorID,  State,Element.Opacity.Current,elementismoving,True)	
					Case LCAR_Meter
						DrawLCARmeter(BG, Dimensions.currX ,Dimensions.currY, Dimensions.offX,Dimensions.offY, Element.LWidth, Element.ColorID,  State,Element.Opacity.Current)
					Case LCAR_SensorGrid
						'debug("DRAW GRID: " & Element.LWidth & " " &  Element.RWidth & " " & Element.Tag)
						DrawLCARSGrid(BG,  Dimensions.currX ,Dimensions.currY, Dimensions.offX,Dimensions.offY,  Element.LWidth, Element.RWidth, Element.ColorID, Element.Tag)
						doAlpha=Element.Opacity.Current < 255
					Case LCAR_Picture
						doAlpha=DrawLCARPicture(BG,  Dimensions.currX ,Dimensions.currY, Dimensions.offX,Dimensions.offY, Element.LWidth, Element.Align,  Element.Opacity.Current)
					'Case LCAR_Chart
						'DrawLCARchart(BG, Dimensions.currX ,Dimensions.currY, Dimensions.offX,Dimensions.offY, element.LWidth, element.ColorID, element.Align, element.SideText  , element.Opacity.Current)
					Case LCAR_Dpad
						temp= Min(Dimensions.offX,Dimensions.offY)
						LCARSeffects.DrawDpad(BG, Dimensions.currX + Dimensions.offX/2, Dimensions.currY+ Dimensions.offY/2, temp*0.5, LCAR_LightOrange, temp*LCARSeffects.DpadCenter, Element.ColorID , 2, Element.Opacity.Current , BlinkState, Element.LWidth)
					Case LCAR_Graph
						LCARSeffects2.DrawGraph(Element.TextAlign,  BG, Dimensions.currX ,Dimensions.currY, Dimensions.offX,Dimensions.offY,  Element.ColorID ,Colors.White,  Element.Opacity.Current, Element.Align, Element.LWidth, Element.RWidth)
					Case LCAR_SensorSweep
						'LCARSeffects.DrawSensorSweep(BG,Dimensions.currX ,Dimensions.currY, Dimensions.offX,Dimensions.offY, Element.align, Element.TextAlign )
					Case LCAR_Ruler
						'LCARSeffects2.DrawRuler(BG,Dimensions.currX ,Dimensions.currY, Dimensions.offX,Dimensions.offY, GetColor(Element.ColorID, State, Element.Opacity.Current),  Element.Align, Element.TextAlign, Element.LWidth, Element.RWidth) 
					Case LCAR_MultiSpectral
						'LCARSeffects2.DrawAllGraphs(BG,Dimensions.currX ,Dimensions.currY, Dimensions.offX,Dimensions.offY, Element.ColorID, Element.Opacity.Current, Element.Text)
					Case LCAR_ShieldStatus
						LCARSeffects.DrawShieldStatus(BG, Dimensions.currX ,Dimensions.currY, Dimensions.offX,Dimensions.offY, Element.LWidth,Element.RWidth, Element.ColorID, Element.Opacity.Current)
					Case LCAR_Static
						LCARSeffects2.DrawStatic(BG, Dimensions.currX ,Dimensions.currY, Dimensions.offX,Dimensions.offY, Dimensions.offX/64,Dimensions.offY/64, Min(255, Element.LWidth*16) )
					Case LCAR_TextButton
						LCARSeffects2.DrawTextButton(BG,Dimensions.currX ,Dimensions.currY, Dimensions.offX, Element.LWidth,  Element.Align, Element.RWidth, Element.Opacity.Current, State, Element.Text,  Element.ColorID, State, Element.Textalign=0, elementismoving)
					Case LCAR_NCC1701D
						'LCARSeffects2.DrawEnterprise(BG, Dimensions.currX ,Dimensions.currY, Dimensions.offX, Dimensions.offY, Element.Align, GetColor(Element.ColorID, State, Element.Opacity.Current))
					Case LCAR_List
						DrawList(BG, -1, Element.LWidth, Dimensions.currX ,Dimensions.currY, Dimensions.offX, Dimensions.offY)
					Case LCAR_MiniButton
						LCARSeffects2.DrawLegacyButton(BG, Dimensions.currX, Dimensions.currY, -Dimensions.offX, Dimensions.offY, GetColor(Element.ColorID, State, Element.Opacity.Current), Element.Text, Element.TextAlign)
					Case LCAR_Answer
						DrawAnswerSlider(BG, Dimensions.currX, Dimensions.currY,Dimensions.offX, ItemHeight,  Element.LWidth, Element.RWidth, Element.Opacity.Current, Element.Text, Element.colorid, Element.SideText, Element.TextAlign)
					'RANDOM NUMBER BLOCKS
					Case LCAR_RndNumbers,TOS_RndNumbers
						LCARSeffects2.DrawNumberBlock(BG,Dimensions.currX ,Dimensions.currY, Dimensions.offX,Dimensions.offY, Element.ColorID,  Element.LWidth, Element.ElementType, Element.Text)
					

					'TOS, TOS MOVIES and ENTERPRISE
					Case Legacy_Button
						LCARSeffects2.DrawLegacyButton(BG, Dimensions.currX, Dimensions.currY, Dimensions.offX,Dimensions.offY, GetColor(Element.ColorID, State, Element.Opacity.Current), Element.Text, Element.Align)

					'Other styles: Romulan, TOS, Nemesis LCARS (Gradients), TCARS
					
					Case Else
						DrawUnknownElement(BG, Dimensions.currX, Dimensions.currY, Dimensions.offX,Dimensions.offY, Element.ColorID, State, Element.Opacity.Current, "UNKNOWN ELEMENT TYPE")
				End Select
				If doAlpha Then
					'If element.Opacity.Current < 255 Then'AND element.Opacity.Current>0 Then
						BGC=Colors.ARGB(255-Element.Opacity.Current, 0,0,0)
						BG.DrawRect( SetRect(Dimensions.currX,Dimensions.currY, Dimensions.offX ,Dimensions.offY),  	BGC,	True ,0)
					'End If
				End If
				
				'LCARelements.Set(ElementID, Element)
				Return True
			End If
		End If
	End If
End Sub

Sub DrawUnknownElement (BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, ColorID As Int, State As Boolean, Alpha As Int,Text As String)
	DrawRect(BG, X +2, Y +2, Width-3, Height-3,  GetColor(ColorID, State, Alpha) , 4)
	DrawText(BG, X + Width/2, Y + Height/2 - TextHeight(BG,"U")*0.5 , Text, ColorID, 5, State, Alpha,0)
End Sub

'Sub DrawLegacyText(BG As Canvas, X As Int, Y As Int, dWidth As Int, dHeight As Int, Text As String, Textsize As Int, Color As Int, Align As Int )As Int
'	Dim Height As Int, Width As Int 
'	If LCARSeffects2.StarshipFont.IsInitialized AND Text.Length>0 Then 
'		Height=BG.MeasureStringHeight(Text,LCARSeffects2.StarshipFont, Textsize     )
'		Width=BG.MeasureStringwidth(Text,LCARSeffects2.StarshipFont, Textsize     )
'		
'		Select Case Align
'			Case 0
'				BG.DrawRect(SetRect(X,Y,Width+1,Height+1),Colors.Black, True,0)
'				Y=Y+ Height
'			Case 1,2,3: Y=Y+ Height
'			Case 4,5,6: Y=Y+(dHeight*0.5) -(Height*0.5)
'			Case 7,8,9: Y=Y+dHeight
'		End Select
'		Select Case Align
'			Case 2,5,8: X=X+(dWidth*0.5)-(Width*0.5)
'			Case 3,6,9: X=X+dWidth-Width
'		End Select
'		
'		BG.DrawText(Text, X, Y    , LCARSeffects2.StarshipFont , Textsize,Color, "LEFT")
'		Return Width
'	End If
'End Sub

Sub CheckNumbersize(BG As Canvas)
	If NumberWhiteSpace=0 OR NumberTextSize=0  Then 
		NumberTextSize = GetTextHeight(BG, LCARCorner.Height , "000")
		NumberWhiteSpace= BG.MeasureStringWidth("000", LCARfont, NumberTextSize)+ListitemWhiteSpace
	End If
End Sub

Sub DrawLCARs(BG As Canvas,SurfaceID As Int)As Boolean 
	Dim temp As Int,temp2 As Int,Group As LCARgroup ,State As Boolean 
	Try
		LCARSDrawn=0
		If ElementMoving Then IsClean=False
		If LCARfontheight=0 Then LCARfontheight = BG.MeasureStringHeight("ABC123",LCARfont,Fontsize)
		FramesDrawn=FramesDrawn+1
		If Not(BGisInit) Then 
			BGisInit=True
			PullNextToast(BG)
		End If
		IsInternal=True
		If Not( IsClean) AND Not(ClearLocked) Then  BG.Drawcolor(Colors.Black)
		
		IsAAon=False
		Locked=True
		For temp = 0 To LCARGroups.Size-1
			Group = LCARGroups.Get(temp)
			If Group.Visible Then
				For temp2 = 0 To Group.LCARlist.Size-1
					If DrawElement(BG, SurfaceID,  Group.LCARlist.Get(temp2 ) , Group.RedAlert = temp2 )  Then  LCARSDrawn=LCARSDrawn+1
				Next
			End If
		Next
		
		'ActivateAA(BG, DoVector)
		For temp = 0 To LCARlists.Size-1
			If DrawList(BG,SurfaceID, temp, 0,0,0,0)  Then  LCARSDrawn=LCARSDrawn+1
		Next
		Locked=False

		
		If VolOpacity > 0 Then
			If VolText.Length=0 Then
				DrawVolume(BG,API.IIF(SmallScreen, 200, 300),75)
			Else
				DrawVolume(BG, VolDimensions.X+20, VolDimensions.Y+20)
			End If
			If VolOpacity<255 Then IsClean=False
		'Else If VolTextList.Size>0 Then
			'PushEvent(LCAR_ToastDone,0,0,0,0,0,0, Event_Down)
		End If
		If DrawFPS AND FPSCounter Then
			DrawText(BG, ScaleWidth, 0, FPS, LCAR_Orange, 3,False,255,-1)
		End If
		
		Return LCARSDrawn>0
	Catch 
		BGisInit=False
		Return False
	End Try
End Sub

Sub DrawVolume(BG As Canvas, Width As Int, Height As Int)
	Dim X As Int, Y As Int , BarHeight As Int,P As Path ,temp As Int,WhiteSpace As Int,Black As Int,tempstr() As String   'cvol
	X=ScaleWidth*0.5-Width*0.5
	WhiteSpace=2
	If ToastAlign Then
		Y=0'Height*2
	Else
		Y=ScaleHeight-Height*2
	End If
	
	BarHeight=15
	Black=Colors.ARGB(VolOpacity,0,0,0)
	LCARSeffects2.DrawLegacyButton(BG, X-WhiteSpace,Y-WhiteSpace,Width+WhiteSpace*2,Height+WhiteSpace*2, Black, "", 1)
	LCARSeffects2.DrawLegacyButton(BG, X,Y,Width,Height, GetColor(LCAR_Orange,False, VolOpacity), "", 1)
	
	If VolText.Length=0 Then
		DrawText(BG, X + 10,Y+10, "VOLUME: ", LCAR_Black, 1,False,VolOpacity,0)
		
		LCARSeffects2.DrawLegacyButton(BG, X+10, Y+Height-10-BarHeight, Width-20, BarHeight, Black,"",-5)' GetColor(LCAR_Black,False, VolOpacity), "", -5)
		If cVol<100 Then
			temp=(Width-20) * (cVol*0.01)+ (X+10)
			P.Initialize(X,Y)
			P.LineTo(temp,Y)
			P.LineTo(temp,Y+Height)
			P.LineTo(X,Y+Height)
			BG.ClipPath(P)
		End If
		If RedAlert Then
			WhiteSpace=Colors.ARGB(VolOpacity,255,255,255)
		Else
			WhiteSpace=GetColor(LCAR_Purple,False, VolOpacity)
		End If
		LCARSeffects2.DrawLegacyButton(BG, X+10, Y+Height-10-BarHeight, Width-20, BarHeight, WhiteSpace, "", -5)
		If cVol<100 Then BG.RemoveClip
	Else
		If VolText.Contains(CRLF) Then
			tempstr = Regex.Split(CRLF, VolText)
			For temp = 0 To tempstr.Length-1 
				DrawText(BG, X + 10,Y+10, tempstr(temp), LCAR_Black,   1,False,VolOpacity, 0)
				Y=Y+ TextHeight(BG, "HELLO")
			Next
		Else
			DrawText(BG, X + 10,Y+10, VolText, LCAR_Black,   1,False,VolOpacity, 0)
		End If
	End If
End Sub

Sub DrawLCARPicture(BG As Canvas,X As Int, Y As Int, Width As Int,Height As Int,PictureID As Int,Align As Int,Alpha As Int  )As Boolean 
	Dim Picture As LCARpicture ,Size As tween , X2 As Int,Y2 As Int,Dest As Rect  ',retval As Boolean 
	Picture=PictureList.Get(PictureID)
	Size = ThumbSize( Picture.Picture.Width, Picture.Picture.Height, Width,Height,  True,False)
	
	Select Case Align
		Case 0,1'top left
			
			X2=X+Width/2 - Size.currX/2
			Y2=Y+Height/2 - Size.curry/2
			
			'debug(X2 & "," & Y2 & "   " & Width & "," & Height & "   " & Size.currX & "," & Size.currY & " " & Alpha)
		Case 5'center
			'retval=False
			X2=X-Size.currX/2
			Y2=Y- Size.curry/2
	End Select
	
	Dest=SetRect( X2, Y2, Size.currX+1 , Size.currY+1 )
	'debug(Dest)
	
	BG.DrawBitmap( Picture.Picture, Null, Dest )
	If Alpha < 255  Then BG.DrawRect( 	Dest,  Colors.ARGB(255-Alpha, 0,0,0),	True ,0) ' AND Not(retval)
	'Return retval
End Sub 
Sub ThumbSize(PicWidth As Int, PicHeight As Int, ThumbWidth As Int, ThumbHeight As Int, ForceToEdge As Boolean, ForceFull As Boolean  ) As tween
	Dim Size As tween 
	Size.Initialize 
	
	If ForceToEdge Then'Zooms/crops image to force it to fill the entire space
        If PicHeight < ThumbHeight Then
            PicWidth = PicWidth * ThumbHeight / PicHeight
            PicHeight = ThumbHeight
        End If
    End If
	
    If PicWidth > ThumbWidth Then
        PicHeight = PicHeight / (PicWidth / ThumbWidth)
        PicWidth = ThumbWidth
    End If
    If PicHeight > ThumbHeight Then
        PicWidth = PicWidth / (PicHeight / ThumbHeight)
        PicHeight = PicHeight / (PicHeight / ThumbHeight)
    End If
	
    If ForceFull Then'if the image is smaller than the thumbnail, it zooms in to fit an edge
        If PicWidth < ThumbWidth Then
            PicHeight = PicHeight * (ThumbWidth / PicWidth)
            PicWidth = ThumbWidth
        End If
        If PicHeight < ThumbHeight Then
            PicWidth = PicWidth * (ThumbHeight / PicHeight)
            PicHeight = PicHeight * (ThumbHeight / PicHeight)
        End If
    End If
	
	Size.currX=PicWidth
	Size.currY=PicHeight 
	Return Size
End Sub

Sub DrawLCARtextbox(BG As Canvas, X As Int, Y As Int, Width As Int,Height As Int, SelStart As Int, SelWidth As Int, Text As String, ColorID As Int, CursorColorID As Int, HighliteColorID As Int, State As Boolean, Blink As Boolean,Align As Int ,Alpha As Int  )As String 
	Dim OlfFontSize As Int, StartChar As Int, EndChar As Int, StartX As Long, FinishX As Long , Color As LCARColor ,SelText As String , tHeight As Int,SelTextColorID As Int, Maxsize As Int 
	If Align<20 Then
		OlfFontSize=Fontsize
		If Height=LCAR_NumberTextSize Then 
			CheckNumbersize(BG)
			Height =NumberTextSize 
		End If
		If Align>9 Then
			Align=Align-10
			If BG.MeasureStringWidth(Text, LCARfont, Height) > Width Then Height = API.GetTextHeight(BG, -Width, Text, LCARfont)
		End If
		
		Fontsize=Height
		SelTextColorID=LCAR_Black
		Maxsize=TextHeight(BG,API.IIF(Text.Length=0, "ABC123",  Text))
		If RedAlert Then
			HighliteColorID = LCAR_RedAlert
			CursorColorID= LCAR_White
			ColorID= LCAR_RedAlert
			If Not(Blink) Then SelTextColorID=LCAR_White
		End If
		'If Not( elementmoving) Then
		If Align>-1 Then 
			BG.DrawRect( SetRect(X-1,Y, Width+1, Maxsize+3), Colors.black, True,0) 
		Else 
			Align=-1-Align
		End If
		Select Case Align
			Case 0, 1,4,7
				DrawText(BG, X,Y, Text, ColorID, Align,State, Alpha,0)
				tHeight=Maxsize'bg.MeasureStringHeight(Text , lcarfont, height )+1
				If SelStart>-1 Then
					If SelWidth<>0 AND HighliteColorID> LCAR_Black Then
						If SelWidth<0 Then 
							StartChar= SelStart+SelWidth
						Else
							StartChar=SelStart
						End If
						EndChar = StartChar+ Abs(SelWidth)
						StartX = BG.MeasureStringWidth(Text.SubString2(0, StartChar)  ,LCARfont, Height)
						SelText=Text.SubString2(StartChar, EndChar)
						FinishX=BG.MeasureStringWidth(SelText,LCARfont, Height)
						Color = LCARcolors.Get(HighliteColorID)
						BG.DrawRect( SetRect(X+StartX-1,Y,FinishX+2, tHeight),  Color.Normal ,True,0)
						DrawText(BG, X+StartX,Y, SelText, SelTextColorID,  1,State, Alpha,0)
					End If
					If Blink AND CursorColorID>LCAR_Black AND SelStart>-1 Then
						StartX= BG.MeasureStringWidth(API.left(Text,SelStart)  ,LCARfont, Height)
						Color = LCARcolors.Get(CursorColorID)
						BG.DrawRect( SetRect(X+StartX-1,Y,3, tHeight), Color.Normal,True,0)
					End If
				End If
			Case 2,5,8'center
				DrawText(BG, X+Width/2,Y, Text, ColorID, 2,State, Alpha,0)
			Case 3,6,9
				DrawText(BG, X+Width-1,Y, Text, ColorID, 3,State, Alpha,0)
		End Select
		'If alpha<255 Then bg.DrawRect( setrect(x,y, width, textheight(bg, text)+1), Colors.ARGB(255-alpha,0,0,0), True,0)
		Fontsize=OlfFontSize
		Return SelText
	Else
		Return Null
	End If
End Sub

Sub DrawTextbox(BG As Canvas, Text As String,ColorID As Int, X As Int, Y As Int, Width As Int, Height As Int, Align As Int)
	If Text.Length>0 Then
		Select Case Align
			'case 1,4,7:x=x'Left Col
			Case 2,5,8: X = X+Width/2'Center
			Case 3,6,9:X=X+Width-1
		End Select
		Select Case Align
			'case 1,2,3:y=y'top row
			Case 4,5,6:Y= Y+Height/2 - TextHeight(BG,Text)/2'middle row
			Case 7,8,9:Y=Y+Height-1 - TextHeight(BG,Text)'bottom row
		End Select
		DrawText(BG, X,Y, Text,ColorID,Align,False,255,0)
	End If
End Sub

Sub DrawRect(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Color As Int, Stroke As Int)As Rect 
	Dim Dest As Rect 
	If Width=1 AND Height=1 Then
		BG.DrawPoint(X,Y,Color)
	Else
		Dest=SetRect(X,Y,Width,Height)
		BG.DrawRect(Dest, Color, Stroke=0,Stroke)
		Return Dest
	End If
End Sub
Sub DrawPic(BG As Canvas, X As Int, Y As Int, BMP As Bitmap, FlipX As Boolean, FlipY As Boolean )
	If FlipX OR FlipY Then
		BG.DrawBitmapFlipped(BMP, Null, SetRect(X,Y, BMP.Width, BMP.Height) , FlipX,FlipY)
	Else
		BG.DrawBitmap(BMP, Null, SetRect(X,Y, BMP.Width, BMP.Height) )
	End If
End Sub


Sub ResizeElement(ElementID As Int, LandscapeX As Int, LandscapeY As Int, LandscapeWidth As Int, LandscapeHeight As Int, PortraitX As Int, PortraitY As Int, PortraitWidth As Int, PortraitHeight As Int)
	If Landscape Then
		ForceElementData(ElementID,  LandscapeX,LandscapeY, 0,0, LandscapeWidth,LandscapeHeight,0,0,255,255,True,False)
	Else
		ForceElementData(ElementID,  PortraitX,PortraitY, 0,0, PortraitWidth,PortraitHeight,0,0,255,255,True,False)
	End If
End Sub

Sub ForceElementData(ElementID As Int,X As Int, Y As Int, XOffset As Int, YOffset As Int, Width As Int, Height As Int, WidthOffset As Int, HeightOffset As Int, CurrAlpha As Int, DesAlpha As Int, Visible As Boolean, IsAnimated As Boolean  )As Int
	Dim Element As LCARelement 
	If API.debugMode Then CurrAlpha=DesAlpha
	If Not(IsAnimated) Then
		XOffset=0
		YOffset=0
		WidthOffset=0
		HeightOffset=0
		CurrAlpha=DesAlpha
	End If
	'If ElementID<LCARelements.Size Then
		Element=LCARelements.Get(ElementID)
			Element.LOC.currX=X
			Element.LOC.currY=Y
			Element.LOC.offX=XOffset
			Element.LOC.offY=YOffset
			Element.Size.currX=Width
			Element.Size.currY=Height
			Element.Size.offx = WidthOffset
			Element.Size.offy = HeightOffset
			Element.Opacity.Current=CurrAlpha
			Element.Opacity.Desired=DesAlpha
			Element.IsClean=False
			Element.Visible = Visible
		LCARelements.Set(ElementID,Element)
	'End If
	Return X+Width
End Sub


Sub DrawLCARelbow(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, BarWidth As Int, BarHeight As Int, Align As Int, ColorID As Int, State As Boolean , Text As String, TextAlign As Int,Alpha As Int,IsMoving As Boolean)As Boolean 
	Dim Color As Int,  Start As Int ,X2 As Int , TextColorID As Int , Corner As Rect ,  FlipX As Boolean , FlipY As Boolean, TextWhiteSpace As Int 'LCARC As LCARColor ,
	Dim ElbowMode As Int,ElbowMode2 As Int = LCARCornerElbow2.Width 'LCARC As LCARColor ,
	If BG=Null Then Return False
	If BarWidth >100 OR BarHeight >100 Then 
		ElbowMode = Min(BarWidth,BarHeight)
		ElbowMode2 = ElbowMode * 0.5
	End If
	TextWhiteSpace=4'previous was 10
	'If smallscreen Then
	'	BarWidth=BarWidth*0.5
	'	BarHeight=BarHeight*0.5
	'End If
	'If colorid= lcar_black Then'AND alpha<255 Then
		'Color= Colors.argb( Alpha,0,0,0)
	'Else
		If ColorID>-1 Then Color=GetColor(ColorID, State,Alpha)
		'If redalert AND colorid<> lcar_black Then colorid= LCAR_RedAlert
		'LCARC= lcarcolors.Get(colorid)
		'If state Then  Color = lcarc.Selected Else color = lcarc.Normal
		TextColorID=LCAR_Black
		If Not (RedAlert) AND ColorID=LCAR_Black Then TextColorID =LCAR_Orange
	'End If
	
	Select Case Align
'		'		 _
'		Case 0' |  top left
'			'If TextAlign =10 Then height=height-barheight
'			If ColorID>-1 Then BG.DrawRect( SetRect(X,Y,BarWidth,Height) , Color, True,1)'left
'			'bg.DrawRect(setrect(x,y,width,barheight), Color, True,1)'top
'			If ColorID>-1 Then BG.DrawRect(SetRect(X+BarWidth-1,Y,Width-BarWidth+1,BarHeight), Color, True,1)'top
'			'If colorid> lcar_black Then 
'				'bg.DrawBitmap(LCARCornerElbow, Null,  setrect(X, Y ,LCARCornerElbow.Width,LCARCornerElbow.Height  ))
'				DrawBitmap(BG,LCARCornerElbow,LCARCornerElbowa, SetRect(X, Y ,LCARCornerElbow.Width,LCARCornerElbow.Height  ), False,False,IsMoving)
'				Corner=SetRect(X+BarWidth-1,Y+BarHeight-1, LCARCornerElbow2.Width,LCARCornerElbow2.Height)
'				If TextAlign =10 Then
'					DrawLCARtextbox(BG,  X+BarWidth+LCARCornerElbow2.Width,Y, API.TextWidthAtHeight(BG,LCARfont, Text, ElbowTextHeight)+3    , ElbowTextHeight,  0,0, Text, ColorID, ColorID, ColorID, False,False,4,Alpha) 
'					'DrawLCARelbow(BG, X, Y+height-1, Width,Height,BarWidth, BarHeight, 2, colorid,state, "", 0, Alpha,ismoving)
'				Else
'					DrawTextbox(BG, Text, TextColorID, X+ListitemWhiteSpace,Y+ListitemWhiteSpace+LCARCornerElbow2.Height ,BarWidth-ListitemWhiteSpace*2,Height-ListitemWhiteSpace*2-LCARCornerElbow2.Height ,TextAlign)
'				End If
'			'End If
'			
'		'        _
'		Case 1'   | top right
'			If ColorID>-1 Then BG.DrawRect( SetRect(X,Y,Width,BarHeight) , Color, True,1)'top
'			If ColorID>-1 Then BG.DrawRect(SetRect(X+Width-BarWidth,Y+BarHeight-1,BarWidth,Height-BarHeight), Color, True,1)'right
'			'If colorid> lcar_black Then 
'				'bg.DrawBitmapFlipped(LCARCornerElbow, Null,  setrect(X +width-LCARCornerElbow.Width+1, Y ,LCARCornerElbow.Width,LCARCornerElbow.Height  ), False,True)
'				DrawBitmap(BG, LCARCornerElbow,LCARCornerElbowa, SetRect(X +Width-LCARCornerElbow.Width+1, Y ,LCARCornerElbow.Width,LCARCornerElbow.Height  ),True,False,IsMoving)
'				Corner=SetRect(X+Width-BarWidth-LCARCornerElbow2.Width+1,Y+BarHeight-1, LCARCornerElbow2.Width,LCARCornerElbow2.Height)
'				FlipX=True
'				If TextAlign<0 Then
'					DrawTextbox(BG, Text, TextColorID, X+TextWhiteSpace, Y+TextWhiteSpace, BarWidth, BarHeight-(TextWhiteSpace*2), API.IIF(TextAlign=-1, 1,7))'previous boundaries were 10, not 4
'				Else
'					DrawTextbox(BG, Text, TextColorID, X+ListitemWhiteSpace+Width-BarWidth-1,Y+ListitemWhiteSpace+LCARCornerElbow2.Height ,BarWidth-ListitemWhiteSpace*2,Height-ListitemWhiteSpace*2-LCARCornerElbow2.Height ,TextAlign)
'				End If
'			'End If
'			
'		Case 2' |_  bottom left
'			If ColorID>-1 Then BG.DrawRect( SetRect(X,Y,BarWidth,Height) , Color, True,1)'left
'			If ColorID>-1 Then BG.DrawRect(SetRect(X+BarWidth-1,Y+Height-BarHeight,Width-BarWidth+1,BarHeight), Color, True,1)'bottom
'			'If colorid> lcar_black Then
'				'bg.DrawBitmapFlipped(LCARCornerElbow, Null,  setrect(X, Y +height-LCARCornerElbow.height+1,LCARCornerElbow.Width,LCARCornerElbow.Height  ) ,True,False)
'				DrawBitmap(BG, LCARCornerElbow,LCARCornerElbowa,SetRect(X, Y +Height-LCARCornerElbow.Height+1,LCARCornerElbow.Width,LCARCornerElbow.Height  ) ,False,True,IsMoving)
'				Corner=SetRect(X+BarWidth-1,Y+Height-BarHeight-LCARCornerElbow2.Height+1, LCARCornerElbow2.Width,LCARCornerElbow2.Height)
'				FlipY=True
'				DrawTextbox(BG, Text,TextColorID, X+ListitemWhiteSpace, Y+ListitemWhiteSpace, BarWidth -ListitemWhiteSpace*2, Height- LCARCornerElbow2.Height-ListitemWhiteSpace*2, TextAlign)
'			'End If
'			
'		Case 3'  _| bottom right
'			If ColorID>-1 Then BG.DrawRect( SetRect(X+Width-BarWidth,Y,BarWidth,Height) , Color, True,1)'left
'			If ColorID>-1 Then BG.DrawRect(SetRect(X,Y+Height-BarHeight,Width-BarWidth+1,BarHeight), Color, True,1)'bottom
'			'If colorid> lcar_black Then 
'				'bg.DrawBitmapFlipped(LCARCornerElbow, Null,  setrect(X +width-LCARCornerElbow.Width+1, Y +height-LCARCornerElbow.height+1,LCARCornerElbow.Width,LCARCornerElbow.Height  ), True,True)
'				DrawBitmap(BG, LCARCornerElbow,LCARCornerElbowa, SetRect(X +Width-LCARCornerElbow.Width+1, Y +Height-LCARCornerElbow.Height+1,LCARCornerElbow.Width,LCARCornerElbow.Height  ), True,True,IsMoving)
'				Corner=SetRect(X+Width-BarWidth-LCARCornerElbow2.Width+1,Y+Height-BarHeight-LCARCornerElbow2.Height+1, LCARCornerElbow2.Width,LCARCornerElbow2.Height)
'				FlipX=True:FlipY=True
'				If TextAlign<0 Then
'					DrawTextbox(BG, Text, TextColorID, X+TextWhiteSpace, Y+TextWhiteSpace+ (Height-BarHeight), BarWidth, BarHeight-(TextWhiteSpace*2), API.IIF(TextAlign=-1, 1,7))
'				Else
'					DrawTextbox(BG, Text,TextColorID, X+ListitemWhiteSpace+Width-1-BarWidth, Y+ListitemWhiteSpace, BarWidth -ListitemWhiteSpace*2, Height- LCARCornerElbow2.Height-ListitemWhiteSpace*2, TextAlign)
'				End If
'			'End If		
'			
			Case 0' |  top left
			'If TextAlign =10 Then height=height-barheight
			If ColorID>-1 Then 
				BG.DrawRect( SetRect(X,Y,BarWidth,Height) , Color, True,1)'left
			'bg.DrawRect(setrect(x,y,width,barheight), Color, True,1)'top
				BG.DrawRect(SetRect(X+BarWidth-1,Y,Width-BarWidth+1,BarHeight), Color, True,1)'top
			End If
			'If colorid> lcar_black Then 
				'bg.DrawBitmap(LCARCornerElbow, Null,  setrect(X, Y ,LCARCornerElbow.Width,LCARCornerElbow.Height  ))
				If ElbowMode < LCARCornerElbow.Width  Then
					DrawBitmap(BG,LCARCornerElbow,LCARCornerElbowa, SetRect(X, Y ,LCARCornerElbow.Width,LCARCornerElbow.Height  ), False,False,IsMoving)
					Corner=SetRect(X+BarWidth-1,Y+BarHeight-1, LCARCornerElbow2.Width,LCARCornerElbow2.Height)
				Else
					DrawCircle2(BG, X,Y, ElbowMode,ElbowMode, 1, Color, True)
					DrawCircle2(BG, X+BarWidth-1, Y+BarHeight-1, ElbowMode2,  ElbowMode2, -1 , Color, False)
				End If
				
				Select Case TextAlign
					Case 10
						DrawLCARtextbox(BG,  X+BarWidth+ElbowMode2,Y, API.TextWidthAtHeight(BG,LCARfont, Text, ElbowTextHeight)+3    , ElbowTextHeight,  0,0, Text, ColorID, ColorID, ColorID, False,False,4,Alpha) 
					Case Else	
						If TextAlign<0 Then
							DrawTextbox(BG, Text, TextColorID, X+BarWidth-10,Y+10,Width-BarWidth-9,BarHeight-20 ,Abs(TextAlign))
						Else
							DrawTextbox(BG, Text, TextColorID, X+ListitemWhiteSpace,Y+ListitemWhiteSpace+LCARCornerElbow2.Height ,BarWidth-ListitemWhiteSpace*2,Height-ListitemWhiteSpace*2-LCARCornerElbow2.Height ,TextAlign)
						End If
				End Select
			'End If
			
		'        _
		Case 1'   | top right
			If ColorID>-1 Then 
				BG.DrawRect( SetRect(X,Y,Width,BarHeight) , Color, True,1)'top
				BG.DrawRect(SetRect(X+Width-BarWidth,Y+BarHeight-1,BarWidth,Height-BarHeight), Color, True,1)'right
			End If
			'If colorid> lcar_black Then 
				'bg.DrawBitmapFlipped(LCARCornerElbow, Null,  setrect(X +width-LCARCornerElbow.Width+1, Y ,LCARCornerElbow.Width,LCARCornerElbow.Height  ), False,True)
				If ElbowMode < LCARCornerElbow.Width  Then
					DrawBitmap(BG, LCARCornerElbow,LCARCornerElbowa, SetRect(X +Width-LCARCornerElbow.Width+1, Y ,LCARCornerElbow.Width,LCARCornerElbow.Height  ),True,False,IsMoving)
					Corner=SetRect(X+Width-BarWidth-LCARCornerElbow2.Width+1,Y+BarHeight-1, LCARCornerElbow2.Width,LCARCornerElbow2.Height)
				Else
					DrawCircle2(BG, X +Width-ElbowMode,Y, ElbowMode,ElbowMode, 3, Color, True)
					DrawCircle2(BG, X+Width-BarWidth-ElbowMode2-1,Y+BarHeight-1, ElbowMode2,  ElbowMode2, -3 , Color, False)
				End If
				
				FlipX=True
				If TextAlign<0 Then
					DrawTextbox(BG, Text, TextColorID, X+TextWhiteSpace, Y+TextWhiteSpace, BarWidth, BarHeight-(TextWhiteSpace*2), API.IIF(TextAlign=-1, 1,7))'previous boundaries were 10, not 4
				Else
					DrawTextbox(BG, Text, TextColorID, X+ListitemWhiteSpace+Width-BarWidth-1,Y+ListitemWhiteSpace+LCARCornerElbow2.Height ,BarWidth-ListitemWhiteSpace*2,Height-ListitemWhiteSpace*2-LCARCornerElbow2.Height ,TextAlign)
				End If
			'End If
			
		Case 2' |_  bottom left
			If ColorID>-1 Then 
				BG.DrawRect( SetRect(X,Y,BarWidth,Height) , Color, True,1)'left
				BG.DrawRect(SetRect(X+BarWidth-1,Y+Height-BarHeight,Width-BarWidth+1,BarHeight), Color, True,1)'bottom
			End If
			'If colorid> lcar_black Then
				'bg.DrawBitmapFlipped(LCARCornerElbow, Null,  setrect(X, Y +height-LCARCornerElbow.height+1,LCARCornerElbow.Width,LCARCornerElbow.Height  ) ,True,False)
				If ElbowMode < LCARCornerElbow.Width  Then
					DrawBitmap(BG, LCARCornerElbow,LCARCornerElbowa,SetRect(X, Y +Height-LCARCornerElbow.Height+1,LCARCornerElbow.Width,LCARCornerElbow.Height  ) ,False,True,IsMoving)
					Corner=SetRect(X+BarWidth-1,Y+Height-BarHeight-LCARCornerElbow2.Height+1, LCARCornerElbow2.Width,LCARCornerElbow2.Height)
				Else
					DrawCircle2(BG, X,Y +Height-ElbowMode, ElbowMode,ElbowMode,  7, Color, True)
					DrawCircle2(BG, X+BarWidth-1,Y+Height-BarHeight-ElbowMode2-1, ElbowMode2,ElbowMode2,  -7, Color, False)
				End If
				
				FlipY=True
				DrawTextbox(BG, Text,TextColorID, X+ListitemWhiteSpace, Y+ListitemWhiteSpace, BarWidth -ListitemWhiteSpace*2, Height- LCARCornerElbow2.Height-ListitemWhiteSpace*2, TextAlign)
			'End If
			
		Case 3'  _| bottom right
			If ColorID>-1 Then 
				BG.DrawRect( SetRect(X+Width-BarWidth,Y,BarWidth,Height) , Color, True,1)'left
				BG.DrawRect(SetRect(X,Y+Height-BarHeight,Width-BarWidth+1,BarHeight), Color, True,1)'bottom
			End If
			'If colorid> lcar_black Then 
				'bg.DrawBitmapFlipped(LCARCornerElbow, Null,  setrect(X +width-LCARCornerElbow.Width+1, Y +height-LCARCornerElbow.height+1,LCARCornerElbow.Width,LCARCornerElbow.Height  ), True,True)
				If ElbowMode < LCARCornerElbow.Width  Then
					DrawBitmap(BG, LCARCornerElbow,LCARCornerElbowa, SetRect(X +Width-LCARCornerElbow.Width+1, Y +Height-LCARCornerElbow.Height+1,LCARCornerElbow.Width,LCARCornerElbow.Height  ), True,True,IsMoving)
					Corner=SetRect(X+Width-BarWidth-LCARCornerElbow2.Width+1,Y+Height-BarHeight-LCARCornerElbow2.Height+1, LCARCornerElbow2.Width,LCARCornerElbow2.Height)
				Else
					DrawCircle2(BG,X +Width-ElbowMode, Y +Height-ElbowMode, ElbowMode,ElbowMode,  9, Color, True)
					DrawCircle2(BG,X+Width-BarWidth-ElbowMode2,Y+Height-BarHeight-ElbowMode2, ElbowMode2,ElbowMode2,  -9, Color, False)
				End If
				FlipX=True:FlipY=True
				If TextAlign<0 Then
					DrawTextbox(BG, Text, TextColorID, X+TextWhiteSpace, Y+TextWhiteSpace+ (Height-BarHeight), BarWidth, BarHeight-(TextWhiteSpace*2), API.IIF(TextAlign=-1, 1,7))
				Else
					DrawTextbox(BG, Text,TextColorID, X+ListitemWhiteSpace+Width-1-BarWidth, Y+ListitemWhiteSpace, BarWidth -ListitemWhiteSpace*2, Height- LCARCornerElbow2.Height-ListitemWhiteSpace*2, TextAlign)
				End If
			'End If		
			
	End Select
	If Corner.IsInitialized Then 
		If ColorID>-1 Then BG.DrawRect (Corner, Color,True,1)
		'If flipx OR flipy Then
			If ColorID<> LCAR_Black  Then 'bg.DrawBitmapFlipped(LCARCornerElbow2, Null, Corner, FlipY, FlipX)
				DrawBitmap(BG, LCARCornerElbow2, LCARCornerElbow2a, Corner, FlipX,FlipY,IsMoving)
			End If
		'Else
		'	If colorid> lcar_black Then' bg.DrawBitmap(LCARCornerElbow2, Null,  corner)
		'		drawbitmap(bg, LCARCornerElbow2, LCARCornerElbow2a, corner, False,False)
		'	End If
		'End If
	End If
End Sub

'TOP: 1=left, 2=middle, 3=right	MIDDLE: 4=left, 5=middle, 6=right BOTTOM: 7=left, 8=middle, 9=right, use negatives for inside curve
Sub DrawCircle2(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Corner As Int, Color As Int, ClearFirst As Boolean )
	Dim temp As Int , PT As Point , BiggestAxis As Int 
	If Corner = 5 Then
		BG.DrawOval(SetRect(X,Y,Width,Height), Color, True, 0)
	Else
		LCARSeffects.MakeClipPath(BG,X,Y,Width+1,Height+1)
		If ClearFirst Then DrawRect(BG,X,Y,Width+1,Height+1,Colors.Black,0)
		ActivateAA(BG,True)
		If Corner<0 Then'inside corner
			DrawRect(BG,X,Y,Width+2,Height+2, Color,0)
			Select Case Corner
				Case -1: PT=Trig.SetPoint(X+Width,Y+Height)'top left
				Case -3: PT=Trig.SetPoint(X+2,Y+Height)'top right
				Case -7: PT=Trig.SetPoint(X+Width, Y+1)'bottom left
				Case -9: PT=Trig.SetPoint(X+2, Y+1)'bottom right
				Case Else:Return
			End Select
			BG.DrawCircle(PT.X,PT.Y,Width,Colors.Transparent,True,0)
		Else
			Select Case Corner
				Case 1:	BG.DrawOval(SetRect(X,Y,Width*2,Height*2), Color, True, 0)				'top left
				Case 2:	BG.DrawOval(SetRect(X,Y,Width,Height*2), Color, True, 0)				'top middle
				Case 3:	BG.DrawOval(SetRect(X-Width,Y,Width*2,Height*2), Color, True, 0)		'top right
				Case 4:	BG.DrawOval(SetRect(X-Width,Y,Width*2,Height), Color, True, 0)			'middle left
				Case 6:	BG.DrawOval(SetRect(X,Y,Width*2,Height), Color, True, 0)				'middle right
				Case 7:	BG.DrawOval(SetRect(X,Y-Height,Width*2,Height*2), Color, True, 0)		'bottom left
				Case 8:	BG.DrawOval(SetRect(X,Y-Height,Width,Height*2), Color, True, 0)			'bottom middle
				Case 9:	BG.DrawOval(SetRect(X-Width,Y-Height,Width*2,Height*2), Color, True, 0)	'bottom right
			End Select
		End If
		BG.RemoveClip
		If Corner = -3 OR Corner = -9 Then BG.DrawLine(X+Width+1, Y, X+Width+1,Y+Height+1, Color, 1)
		If Corner = -7 OR Corner = -9 Then BG.DrawLine(X, Y+Height+1, X+Width+1, Y+Height+1, Color, 1)
	End If
End Sub

Sub GetTextHeight(BG As Canvas, DesiredHeight As Int, Text As String) As Int 
	Return API.GetTextHeight(BG,DesiredHeight,Text,LCARfont)
End Sub

Sub DrawMiniGradient(BG As Canvas, Color1 As Int, Color2 As Int, Alignment As Int, X As Int, Y As Int, X2 As Int, Y2 As Int,X3 As Int, Y3 As Int,X4 As Int, Y4 As Int,Width As Int, Height As Int)
	Dim P As Path
	P.Initialize(X,Y)
	P.LineTo(X2, Y2)
	P.LineTo(X3,Y3)
	BG.ClipPath(P)
	DrawGradient(BG,Color1,Color2,Alignment,X4,Y4,Width,Height,0,0)
	BG.RemoveClip 
End Sub
Sub DrawGradient(BG As Canvas, Color1 As Int, Color2 As Int, Alignment As Int, X As Int, Y As Int, Width As Int, Height As Int, CornerRadius As Int, Angle As Int)As Boolean 
	Dim CLRS(2) As Int,CLRS2(9) As Int, Align As String, X2 As Int, Y2 As Int ' , Alignments As List 
	Dim grad As GradientDrawable , grad2 As ColorDrawable ,DoRainbow As Boolean 
	DoRainbow = (Color1=Color2) AND (Color1= Colors.Black )
	If Color1<>Color2 OR DoRainbow Then
		
		Select Case Alignment
			Case 0
				X2=X+(Width/2)
				Y2=Y+(Height/2)
				
				DrawMiniGradient(BG, Color1,Color2, 4, X,Y, X2,Y2, X, Y+Height, X,Y, Width/2, Height)'left
				DrawMiniGradient(BG, Color1,Color2, 2, X,Y, X2,Y2, X+Width, Y, X,Y, Width, Height/2)'top
				DrawMiniGradient(BG, Color1,Color2, 6, X+Width,Y, X2,Y2, X+Width, Y+Height, X2,Y, Width/2, Height)'right
				DrawMiniGradient(BG, Color1,Color2, 8, X,Y+Height, X2,Y2, X+Width, Y+Height, X,Y2, Width, Height/2)'bottom			
				Return False
				
			Case 1:Align="BR_TL"
			Case 2:Align="BOTTOM_TOP"
			Case 3:Align="BL_TR"
			Case 4:Align="RIGHT_LEFT"
			
			Case 5
				DrawGradient(BG, Color1,Color2,0,X,Y,Width,Height, CornerRadius,Angle)
				Return False
			
			Case 6:Align="LEFT_RIGHT"
			Case 7:Align="TR_BL"
			Case 8:Align="TOP_BOTTOM"
			Case 9:Align="TL_BR"'\
			
			Case Else:Return True
		End Select
		'Alignments.Initialize2(Array As String("BR_TL", "BOTTOM_TOP", "BL_TR", "RIGHT_LEFT", "", "LEFT_RIGHT", "TR_BL", "TOP_BOTTOM", "TL_BR"))
		If DoRainbow Then
			CLRS2(0) = Colors.White 
			CLRS2(1) = Colors.Red 
			CLRS2(2) = Colors.RGB(255, 128, 0)'Orange
			CLRS2(3) = Colors.Yellow
			CLRS2(4) = Colors.Green
			CLRS2(5) = Colors.Blue
			CLRS2(6) = Colors.rgb(75, 0, 130)'Indigo
			CLRS2(7) = Colors.RGB(138, 43, 226)'Violet
			CLRS2(8) = Colors.Black 
			grad.Initialize(Align,CLRS2 )
		Else
			CLRS(0) = Color1
			CLRS(1) = Color2
			grad.Initialize(Align,CLRS )' Alignments.Get(Alignment-1)  ,  clrs)
		End If
		
		If CornerRadius>0 Then grad.CornerRadius = CornerRadius
		DrawDrawable(BG, grad,X,Y,Width,Height,Angle)
	Else
		grad2.Initialize(Color1, CornerRadius)
		DrawDrawable(BG, grad2,X,Y,Width,Height,Angle)
	End If
End Sub
Sub DrawDrawable(BG As Canvas,Drawable As Object , X As Int, Y As Int, Width As Int,Height As Int, Angle As Int)
	If Angle = 0 Then
		BG.DrawDrawable(Drawable, SetRect(X,Y,Width,Height) )
	Else
		BG.DrawDrawableRotate(Drawable , SetRect(X,Y,Width,Height), Angle)
	End If
End Sub
Sub DrawLCARmeter(BG As Canvas, X As Int,Y As Int,Width As Int, Height As Int, Percent As Int, ColorID As Int,tBlinkState As Boolean , alpha As Int  )
	Dim  ColorInt As Int, Border As Int, Middle As Int , Unit As Int ,Y2 As Int,temp As Int,Width2 As Int, P As Path 'Color As LCARColor ,
	Border=2
	If RedAlert Then ColorID = LCAR_RedAlert
	'color = lcarcolors.Get(colorid)
	'If tBlinkState Then 
	'	colorint=color.Selected
	'Else 
	'	colorint=color.Normal
	'End If
	ColorInt=GetColor(ColorID, tBlinkState,alpha)
	BG.DrawRect(SetRect(X,Y,Width,Height), ColorInt, False,2)

	
	Middle= (Height-(Border*2)) * ( (100-Percent)/100 )
	Unit=Height/6
	
	
	'bg.DrawRect(setrect(x+Border,y+Border,width-Border*2,Middle), Colors.black, True,0)
	'DrawGradient(BG, Colors.Black , colorint, 8, x+Border,y+Border,width-Border*2,Middle)
	DrawGradient(BG, Colors.Black , ColorInt, 2, X+Border,Y+Middle+2,Width-Border*2,Height-Middle-4,0,0)

	
	Y2=Y+Height -Unit
	Middle = Y+Middle
	Width2=(Width-Border*2)
	
	Y2= DrawLCARunit(BG, X+Border, Y2, Width2, Unit, 1, Width2*0.3, ColorInt, Middle, Border)
	Y2= DrawLCARunit(BG, X+Border, Y2, Width2, Unit, 2, Width2*0.3, ColorInt, Middle, Border)
	Y2= DrawLCARunit(BG, X+Border, Y2, Width2, Unit, 3, Width2*0.15, ColorInt, Middle, Border)
	Y2= DrawLCARunit(BG, X+Border, Y2, Width2, Unit, 4, Width2*0.15, ColorInt, Middle, Border)
	Y2= DrawLCARunit(BG, X+Border, Y2, Width2, Unit, 5, Width2*0.3, ColorInt, Middle, Border)
	
	P.Initialize(X,Y)
	P.LineTo(X+Width,Y)
	P.LineTo(X+Width,Y+Height)
	P.LineTo(X,Y+Height)
	BG.ClipPath(P)
	DrawLCARunit(BG, X+Border, Y2, Width2, Unit, 0, Width2*0.3, ColorInt, Middle, Border)
End Sub
Sub DrawLCARunit(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Number As Int, Length As Int, Color As Int, Middle As Int, Border As Int)As Int 
	Dim Unit As Int, MaxLength As Int ,X2 As Int ,color2 As Int ,P As Path 
	Unit=Height/4
	If Number=0 Then
		MaxLength= Width*0.2		
'		If method1 Then
			DrawLCARunitLine(BG, X-1,Y-Border*2, MaxLength+1, Height+Border*2+1, Middle,Color)
			DrawLCARunitLine(BG,X+Width-MaxLength,Y-Border*2, MaxLength+1, Height+Border*2+1, Middle,Color)
'		Else
'			DrawLCARunitLine(BG, X-1,Y-Border, MaxLength+1, Height+Border*2, Middle,Color)
'			DrawLCARunitLine(BG,X+Width-MaxLength,Y-Border, MaxLength+1, Height+Border*2, Middle,Color)
'		End If
		BG.RemoveClip

	Else
		MaxLength = Width*0.4
		DrawLCARunitLine(BG,X,Y, MaxLength, Border, Middle, Color)
		DrawLCARunitLine(BG,X+Width-MaxLength,Y, MaxLength, Border, Middle, Color)
		'drawtext(BG, x+width/2, Y, Number, color,5,False)
		
		X2=Y + LCARfontheight*0.5
		color2=Color
		
		
		'If X2>=Middle Then color2 = Colors.Black 
		BG.DrawText(Number, X+Width/2, X2  , LCARfont, Fontsize,color2, "CENTER")
		
		If X2>=Middle Then' Color = Colors.Black 
			P.Initialize(X,Middle+1)
			P.lineto(X+Width,Middle+1)
			P.LineTo(X+Width,ScaleHeight)
			P.LineTo(X,ScaleHeight)
			BG.ClipPath(P)
			BG.DrawText(Number, X+Width/2, X2  , LCARfont, Fontsize,Colors.Black , "CENTER")
			BG.RemoveClip 
		End If
		
		
	End If
	X2= X+Width-Length
	
	DrawLCARunitLine(BG,X,Y+Unit, Length, Border, Middle, Color)
	DrawLCARunitLine(BG,X,Y+Unit*2, Length, Border, Middle, Color)
	DrawLCARunitLine(BG,X,Y+Unit*3, Length, Border, Middle, Color)
	
	DrawLCARunitLine(BG,X2,Y+Unit, Length, Border, Middle, Color)
	DrawLCARunitLine(BG,X2,Y+Unit*2, Length, Border, Middle, Color)
	DrawLCARunitLine(BG,X2,Y+Unit*3, Length, Border, Middle, Color)
	Return Y-Height
End Sub
Sub DrawLCARunitLine(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Middle As Int, Color As Int)
	Dim Height2 As Int ,P As Path 
	If Y< Middle Then
		If Y+Height-1 > Middle Then
			Height2= Middle-Y
			BG.DrawRect(SetRect(X,Y,Width,Height2),Color, True,0)
			Height=Height-Height2
			Y=Y+Height2
			
			'bg.DrawRect(setrect(x,y+height2,width,height-height2),Colors.black, True,0)
		End If
	End If

	If Y>=Middle Then Color = Colors.Black 
	BG.DrawRect(SetRect(X,Y,Width,Height),Color, True,0)
End Sub

Sub DrawLCARSlider(BG As Canvas, X As Int,Y As Int, Height As Int, Percent As Int, ColorID As Int,tBlinkState As Boolean,Alpha As Int ,IsMoving As Boolean, Horizontal As Boolean    )
	Dim FullSquares As Int, LastSquare As Int, ColorInt As Int, lastcolorint As Int, r As Int, G As Int, B As Int ,y2 As Int  , TotalHeight As Int,ItemHeight2 As Int,temp As Int,temp2 As Int',Perc As Double Color As LCARColor ,
	If RedAlert Then ColorID = LCAR_RedAlert
	ColorInt = GetColor(ColorID, tBlinkState, Alpha)
	FullSquares= Floor(Percent/10)
	LastSquare= (Percent Mod 10) * (Alpha/255)
	lastcolorint = GetColor(ColorID, tBlinkState, LastSquare*25.5)
	If Horizontal Then
		BG.DrawRect(SetRect(X, Y, Height, LCARCorner.Height),  Colors.black , True ,1)
		y2=X+Height-LCARCorner.Width 
		TotalHeight=Height-LCARCorner.width*2- ListitemWhiteSpace*2
		ItemHeight2=(TotalHeight/10)-ListitemWhiteSpace
		For temp = y2-ListitemWhiteSpace - ItemHeight2 To X+LCARCorner.width+ListitemWhiteSpace Step -(ItemHeight2+ListitemWhiteSpace)
			temp2=temp2+1
			If temp2<= FullSquares Then
				BG.DrawRect(SetRect(temp, Y, ItemHeight2,LCARCorner.Height ),   ColorInt , True ,1)
			Else If temp2=FullSquares+1 Then
				BG.DrawRect(SetRect(temp, Y, ItemHeight2,LCARCorner.Height ),   lastcolorint , True ,1)
			End If
		Next
		temp=temp+ (ItemHeight2-LCARCorner.width)
		BG.DrawRect(SetRect(temp, Y, LCARCorner.width,LCARCorner.Height),  ColorInt , True ,1)
		DrawBitmap(BG,LCARCorner,LCARCornera, SetRect(temp,Y, LCARCorner.Width , LCARCorner.Height), False,False ,IsMoving)
		BG.DrawRect(SetRect(y2, Y, LCARCorner.width,LCARCorner.Height-1),  ColorInt , True ,1)
		DrawBitmap(BG,LCARCornerSlider,LCARCornerSlidera, SetRect(X,y2, LCARCornerSlider.Width , LCARCornerSlider.Height), False,True ,IsMoving)
	Else
		BG.DrawRect(SetRect(X, Y,  LCARCornerSlider.Width,Height),  Colors.black , True ,1)
		y2=Y+Height-LCARCornerSlider.Height
		TotalHeight=Height-LCARCornerSlider.Height*2- ListitemWhiteSpace*2
		ItemHeight2=(TotalHeight/10)-ListitemWhiteSpace
		For temp = y2-ListitemWhiteSpace - ItemHeight2 To Y+LCARCornerSlider.Height+ListitemWhiteSpace Step -(ItemHeight2+ListitemWhiteSpace)
			temp2=temp2+1
			If temp2<= FullSquares Then
				BG.DrawRect(SetRect(X, temp, LCARCornerSlider.width,ItemHeight2),   ColorInt , True ,1)
			Else If temp2=FullSquares+1 Then'draw last square
				BG.DrawRect(SetRect(X, temp, LCARCornerSlider.width,ItemHeight2), lastcolorint,True,1)
			End If
		Next
		temp=temp+    (ItemHeight2-LCARCornerSlider.Height)
		BG.DrawRect(SetRect(X, temp, LCARCornerSlider.width,LCARCornerSlider.Height),  ColorInt , True ,1)
		DrawBitmap(BG,LCARCornerSlider,LCARCornerSlidera, SetRect(X,temp, LCARCornerSlider.Width , LCARCornerSlider.Height), False,False ,IsMoving)
		BG.DrawRect(SetRect(X, y2, LCARCornerSlider.width,LCARCornerSlider.Height-1),  ColorInt , True ,1)
		DrawBitmap(BG,LCARCornerSlider,LCARCornerSlidera, SetRect(X,y2, LCARCornerSlider.Width , LCARCornerSlider.Height), False,True ,IsMoving)
	End If
End Sub 

Sub DrawBitmap(BG As Canvas,  AAenabled As Bitmap, AAdisabled As Bitmap, Dest As Rect, FlipX As Boolean , FlipY As Boolean ,IsMoving As Boolean  ) As Boolean 
	If FlipX OR FlipY Then
		If LOD AND (Not(AntiAliasing) OR IsMoving) Then
			BG.DrawBitmapFlipped(AAdisabled,Null, Dest,FlipY,FlipX)
		Else
			BG.DrawBitmapFlipped(AAenabled,Null, Dest,FlipY,FlipX)
			Return True
		End If
	Else
		If LOD AND (Not(AntiAliasing) OR IsMoving) Then
			BG.DrawBitmap(AAdisabled, Null, Dest)
		Else
			BG.DrawBitmap(AAenabled, Null, Dest)
			Return True
		End If
	End If
End Sub

Sub DrawLCARslantedbutton(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, ColorID As Int,Alpha As Int, State As Boolean, Text As String , Align As Int, TextAlign As Int)
	'1 pixels shifted per 11 vertical pixels
	Dim P As Path, Plist As List,Slant As Int, Color As Int, Radius As Int
	Color = GetColor(ColorID, State, Alpha)
	Slant=Height/11
	Radius=10
	ActivateAA(BG,True)
	Select Case Align 
		Case -4, -5' ( and )
			Radius=Height*0.5
			If Align=-4 Then
				BG.DrawCircle(X+Radius,Y+Radius, Radius, Color, True, 0)
				DrawRect(BG,X+Radius,Y, Width-Radius+1,Radius*2+1,Color,0)
			Else
				BG.DrawCircle(X+Width-Radius,Y+Radius, Radius, Color, True, 0)
				DrawRect(BG,X,Y, Width-Radius+1,Radius*2+1,Color,0)
			End If
			ActivateAA(BG,False)
			Return
			
		Case -1,-2,-3'|_|
			LCARSeffects2.MakePoint(Plist, X,Y)
			LCARSeffects2.MakePoint(Plist, X+Width,Y)
			LCARSeffects2.MakePoint(Plist, X+Width,Y+Height)
			LCARSeffects2.MakePoint(Plist, X,Y+Height)
			If Align=-3 Then'|u| curved bottom
				BG.DrawOval( SetRect(X, Y+Height-Radius,Width,Radius*2) , Color,True,0)
			Else If Align=-2 Then'|^| curved top
				BG.DrawOval( SetRect(X, Y-Radius,Width,Radius*2) , Color,True,0)
			End If
			
		Case 1 '/_|
			TextAlign=9
			LCARSeffects.DrawPartOfCircle(BG, X+Slant, Y,Radius, 0, Color,0,0)'top
			LCARSeffects.DrawPartOfCircle(BG, X, Y+Height-Radius,Radius, 2, Color,0,0)'bottom 
			LCARSeffects2.MakePoint(Plist, X,Y+Height-Radius+1)
			LCARSeffects2.MakePoint(Plist, X+Radius-1,Y+Height-Radius+1)
			LCARSeffects2.MakePoint(Plist, X+Radius-1,Y+Height)
			LCARSeffects2.MakePoint(Plist, X+Width,Y+Height)
			LCARSeffects2.MakePoint(Plist, X+Width,Y)
			LCARSeffects2.MakePoint(Plist, X+Slant+Radius-1,Y)
			LCARSeffects2.MakePoint(Plist, X+Slant+Radius-1,Y+Radius-1)
			LCARSeffects2.MakePoint(Plist, X+Slant,Y+Radius-1)
			LCARSeffects2.MakePoint(Plist, X,Y+Height-Radius+1)
		Case 2' |_\
			TextAlign=7
			LCARSeffects.DrawPartOfCircle(BG, X+Width-Slant-Radius, Y,Radius, 1, Color,0,0)'top
			LCARSeffects.DrawPartOfCircle(BG, X+Width-Radius, Y+Height-Radius,Radius, 3, Color,0,0)'bottom 
			LCARSeffects2.MakePoint(Plist, X,Y)
			LCARSeffects2.MakePoint(Plist, X+Width-Slant-Radius+1,Y)
			LCARSeffects2.MakePoint(Plist, X+Width-Slant-Radius+1,Y+Radius-1)
			LCARSeffects2.MakePoint(Plist, X+Width-Slant,Y+Radius-1)
			LCARSeffects2.MakePoint(Plist, X+Width,Y+Height-Radius+1)
			LCARSeffects2.MakePoint(Plist, X+Width-Radius+1,Y+Height-Radius+1)
			LCARSeffects2.MakePoint(Plist, X+Width-Radius+1,Y+Height)
			LCARSeffects2.MakePoint(Plist, X,Y+Height)
	End Select
	
	BG.DrawRect(LCARSeffects2.CopyPlistToPath(Plist,P, BG, Color, 1, True,False) , Color, True, 0)
	BG.RemoveClip 
	If Text.length>0 Then DrawTextbox(BG,    Text,     LCAR_Black,X+Radius,Y+Height-Radius, Width-Radius*2, 0, TextAlign)
	ActivateAA(BG,False)
End Sub

'																	 false=normal/not clicked, true=bright/clicked
Sub DrawLCARbutton(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, ColorID As Int, State As Boolean, Text As String, SideText As String, LWidth As Int, RWidth As Int, RhasCurve As Boolean, WhiteSpace As Int, TextAlign As Int, Number As Int, Alpha As Int ,IsMoving As Boolean )
	Dim Color As Int , Start As Int ,X2 As Int , TextColorID As Int ,NumberText As String, NumberTextColorID As Int,NumberSize As Int  'Temp As Int, LCARC As LCARColor
	If RedAlert Then ColorID= LCAR_RedAlert
	'LCARC= lcarcolors.Get(colorid)
	NumberTextColorID=ColorID
	Color= GetColor(ColorID, State, Alpha)
	If State Then 
		'Color = lcarc.Selected
		If RedAlert Then NumberTextColorID = LCAR_White 
	Else 
		'color = lcarc.Normal
	End If
	'If RWidth<0 Then RWidth = Width+RWidth
	If LWidth>0 OR (RWidth>0 AND RhasCurve) Then 
		Height=LCARCorner.Height
		If RhasCurve AND (LCARCorner.Width*2)>Width+2 AND LWidth>0 Then 
			LWidth=0
			RhasCurve=False
			RWidth=0
		End If	
	End If
	Start=X
	TextColorID=LCAR_Black
	If Not (RedAlert) AND ColorID=TextColorID Then TextColorID =LCAR_Orange
	
	If LWidth>0 Then
		Height= LCARCorner.Height
	
		'bg.DrawBitmap(lcarcorner, Null, SetRect(x,y, lcarcorner.Width, lcarcorner.Height))
'		If DoVector Then
'			X2=Height*0.5
'			DrawCircle(BG, X,Y,X2, Height,  6 ,Color)
'			BG.DrawRect(SetRect(X+X2-1, Y, LWidth-X2+1,Height), Color, True ,1)
'		Else
			BG.DrawRect(SetRect(X, Y, LWidth,Height), Color, True ,1)
			DrawBitmap(BG, LCARCorner,LCARCornera, SetRect(X,Y, LCARCorner.Width, LCARCorner.Height), False, False , IsMoving)
'		End If
		
		'bg.DrawBitmapFlipped(lcarcorner, Null, SetRect(x,y+lcarcorner.Height+1, lcarcorner.Width, lcarcorner.Height) , True,False)
		Start=Start+LWidth+WhiteSpace
		Width=Width-LWidth-WhiteSpace
		
		If Number>-1 Then
			NumberText=Min(999, Number) 'API.Left(Number,3)
			Do Until NumberText.Length = 3
				NumberText = "0" & NumberText
			Loop
			CheckNumbersize(BG)
			NumberSize=NumberWhiteSpace
		Else If TextAlign=LCAR_BigText Then
			NumberText = Text
			Text=""
			CheckNumbersize(BG)
			NumberSize = API.TextWidthAtHeight(BG,LCARfont, NumberText, NumberTextSize)
		End If
		If NumberSize>0 Then
			DrawLCARtextbox(BG, Start,Y-1,  NumberSize, NumberTextSize,0,0, NumberText, NumberTextColorID, LCAR_Black, LCAR_Black, State,False, 1,Alpha)
			Start=Start+ NumberSize
			Width=Width-NumberSize		
		End If
		
	End If
	If RWidth>0 Then
		X2=Start+Width-RWidth
		If RhasCurve Then
			'bg.DrawBitmapFlipped(lcarcorner,Null, setrect(x2 + rwidth-lcarcorner.Width+1,y, lcarcorner.Width, lcarcorner.Height),False,True)
'			If DoVector Then
'				DrawCircle(BG, X2 + RWidth-LCARCorner.Width+1,Y,LCARCorner.Width, Height,  4 ,Color)
'			Else
				BG.DrawRect( SetRect(X2 , Y, RWidth, Height) , Color ,True,1)
				DrawBitmap(BG, LCARCorner,LCARCornera, SetRect(X2 + RWidth-LCARCorner.Width+1,Y, LCARCorner.Width, LCARCorner.Height),True,False ,IsMoving )
'			End If
			'bg.DrawBitmapFlipped(lcarcorner,Null, setrect(x2,y+lcarcorner.Height+1, lcarcorner.Width, lcarcorner.Height),True,True)
		Else
			BG.DrawRect( SetRect(X2 , Y, RWidth, Height) , Color ,True,1)
		End If
		If SideText.Length>0 Then  DrawTextbox(BG, SideText, TextColorID,X2,Y, RWidth,Height, 5 )
		'drawtextbox(bg, sidetext, textcolorid, x2, y, rwidth,Height, 5 )
		'If sidetext.Length>0 Then  drawtext(bg,x2+rwidth/2-1,y+ height/2 - TextHeight(bg,sidetext)/2, sidetext, Textcolorid,5)
		Width=Width-RWidth-WhiteSpace
	End If
	BG.DrawRect(SetRect(Start,Y,Width,Height), Color,True,1)
	
	'debug("start: " &  start & " width: " & width  & " twidth: " &  textwidth(bg,text))
	'Select Case TextAlign
    '    'Case 1, 2, 3: Y = Y  'top row
    '    Case 4, 5, 6: Y = Y + height/2 - TextHeight(bg,text)/2  'middle row
    '    Case 7, 8, 9: tY = Y + Height - TextHeight(bg,text) 'bottom row
    'End Select
    'Select Case TextAlign
    '    Case 1, 4, 7: X = start + 3 ' left column
    '    Case 2, 5, 8: X = start + (width/2) - (textwidth(bg,text)/2) 'middle column
    '    Case 3, 6, 9: X = start + Width - textwidth(bg,Text) - 2 'right column
    'End Select
		'debug(Text & " X: (after) " & X )
	'drawtext(bg,x,y, Text, Textcolorid,TextAlign,False,alpha, LCARfontheight)
	If Text.Length>0 Then 	
		If Text = LCAR_Block Then
			Start = Start + Width/2 - 2
			Width=Width/2 - 2
			Y= Y+ Height/2 + 2
			Height=Height/3
			DrawRect(BG, Start,Y,Width,Height,Colors.Black,0)
		Else
			If SmallScreen Then LCARSeffects.MakeClipPath(BG,X,Y,Width,Height)
			DrawTextbox(BG,  Text, TextColorID, Start+2,Y+2, Width-4,Height-4, TextAlign)
			If SmallScreen Then BG.RemoveClip 
		End If
	End If
	'If sidetext.Length>0 Then   drawtext(bg,x2+rwidth/2-1,y +LCARfontheight/2, sidetext, Textcolorid,5,False,alpha, LCARfontheight)'+ height/2 - TextHeight(bg,sidetext)/2
		'DrawTextbox(bg, text, Textcolorid, start+2,y+2, width-4,height-4, 5)
	'End If
End Sub






Sub ForceHide(ElementID As Int )
	Dim Element As LCARelement , Group As LCARgroup 
	Element= LCARelements.Get(ElementID)
	
	Group=LCARGroups.Get( Element.Group )
	Group.Visible=False
	LCARGroups.Set( Element.Group, Group)
	
	Element.Opacity.Current =0
	Element.Opacity.Desired=0
	Element.Visible=False
	LCARelements.Set(ElementID,Element)
End Sub

Sub ResetLCARAnswer(ElementID As Int, Direction As Int)As Int 
	Dim Element As LCARelement
	Element= LCARelements.Get(ElementID)
	Select Case Direction
		Case -1
			Element.LWidth= -1
			Element.RWidth= 0 
			Element.RespondToAll=True
			ForceShow(ElementID,True)
		
		Case -2'green/true/left to right
			Element.LWidth=1
			Element.RWidth=0

		Case -3'red/false/right to left
			Element.LWidth=0
			Element.RWidth=100
		
		Case -4'return direction
			Return Element.LWidth
		Case -5'return value
			Return Element.RWidth
		
		Case Else'value
			Element.RWidth=Direction'
			'If Element.LWidth = 1 Then'green/true/left to right
			'Else'red/false/right to left
			'End If
	End Select
End Sub

Sub ForceShow(ElementID As Int, Visible As Boolean )
	Dim Element As LCARelement , Group As LCARgroup 
	'If ElementID< LCARelements.Size Then
		Element= LCARelements.Get(ElementID)
		Element.Visible = True
		
		Group=LCARGroups.Get( Element.Group )
		Group.Visible=True
		LCARGroups.Set( Element.Group, Group)

		If Visible Then
			Element.IsClean=False
			Element.Opacity.Current=API.IIF(API.debugMode, 255,0)
			Element.Opacity.Desired=255
		Else 
			If Element.Visible Then
				Element.Opacity.Current=API.IIF(API.debugMode, 0,255)
				Element.Opacity.Desired=0
			Else
				Element.Opacity.Current =0
				Element.Opacity.Desired=0
			End If
		End If
		'LCARelements.Set(ElementID,Element)
	'End If
End Sub

Sub SetRect(X As Int, Y As Int, Width As Int, Height As Int) As Rect 
	Dim Rect1 As Rect 
	Rect1.Initialize(X,Y,X+Width-1,Y+Height-1)
	Return Rect1
End Sub

Sub AddGroup
	Dim group As LCARgroup
	group.Initialize 
	group.LCARlist.Initialize 
	group.HoldList.Initialize 
	group.Visible = True 
	LCARGroups.Add(group)
End Sub

Sub ForceGroupCount(Count As Long)
	Dim temp As Long
	For temp = LCARGroups.Size To Count
		AddGroup
	Next
End Sub

Sub AddLCARtoGroup(LCARid As Int, GroupID As Int)
	Dim Group As LCARgroup
	ForceGroupCount(GroupID+1)
	Group = LCARGroups.Get(GroupID)
	Group.LCARlist.Add(LCARid)
	Group.HoldList.add(1)
	LCARGroups.Set(GroupID,Group)
End Sub

Sub FindElementsGroup(LCARid As Int) As Point 'X = group, Y=index in group
	Dim Element As LCARelement ,Group As LCARgroup ,temp As Int,Ret As Point 
	Element = LCARelements.Get(LCARid)
	Ret.Initialize 
	Ret.X = Element.Group 
	Group = LCARGroups.Get(Element.Group)
	Ret.Y=Group.LCARlist.IndexOf(LCARid)
	
	'For temp = 0 To group.LCARlist.Size -1
	'	If group.LCARlist.Get(temp) = lcarid Then
	'		ret.Y=temp 
			Return Ret
	'	End If
	'Next 
End Sub 

Sub SetGroupIndexHold(LCARid As Int,HoldCount As Int )
	Dim Ret As Point ,Group As LCARgroup
	Ret=FindElementsGroup(LCARid)
	Group = LCARGroups.Get(Ret.x)
	Group.HoldList.Set(Ret.Y, HoldCount)
	LCARGroups.Set(Ret.x,Group)
End Sub
Sub ReorderGroup(LCARid As Int, Index As Int)
	Dim Ret As Point , Hold As Int, Group As LCARgroup
	Ret=FindElementsGroup(LCARid)
	Group = LCARGroups.Get(Ret.x)'X=group, Y=index
	
	Hold = Group.HoldList.Get(Ret.Y)
	Group.LCARlist.RemoveAt(Ret.y)
	Group.HoldList.RemoveAt(Ret.Y)
	Group.LCARlist.AddAllAt(Index, Array As Int(LCARid))
	Group.HoldList.AddAllAt(Index, Array As Int(Hold))
	LCARGroups.Set(Ret.X, Group)
End Sub
Sub ResetRedAlert()
	Dim temp As Int, Group As LCARgroup , Element As LCARelement 
	For temp = 0 To LCARGroups.Size-1
		Group = LCARGroups.Get(temp)
		Group.RedAlert=0
		If Group.HoldList.Size>0 Then Group.Hold = Group.HoldList.Get(0)  Else Group.Hold=1
		LCARGroups.Set(temp,Group)
	Next
End Sub











Sub SetRedAlert(State As Boolean)
	Dim event As ElementClicked 
	If Not( LCARSeffects.IsPromptVisible(Null)) Then
		If State Then ResetRedAlert
		RedAlert = State' Not( redalert)
		IsClean =False 
		event.Initialize 	
		event.ElementType=LCAR_CodeChanged
		If State Then event.Index =1
		EventList.Add(event)
	End If
End Sub

Sub LCAR_ListItemsPerCol(ColsLandscape As Int,ColsPortrait As Int, ListItemSize As Int ) As Int 'ListID As Int)As Int
	Dim Cols As Int', Lists As LCARlist',Rows As Int
	'Lists= lcarlists.Get(ListId)
	Cols=LCAR_ListCols(ColsLandscape , ColsPortrait )'rows=LCAR_ListRows(listid)
	Return Floor(ListItemSize / Cols)
End Sub

Sub LCAR_ListHeight(ListID As Int)As Int
	Dim Lists As LCARlist,  Dimensions As tween
	Dim ItemsOnScreen As Int, ItemsPerCol As Int 
	Lists= LCARlists.Get(ListID) 
	Dimensions=ProcessLoc( Lists.LOC, Lists.Size)
	ItemsOnScreen = LCAR_ListRows(Dimensions.offY )
	ItemsPerCol = LCAR_ListItemsPerCol(Lists.ColsLandscape, Lists.ColsPortrait, Lists.ListItems.Size )
	
    If ItemsPerCol < ItemsOnScreen Then
        Return ItemsOnScreen * (ItemHeight + ListitemWhiteSpace)
    Else
        Return Dimensions.offY 
    End If
End Sub

Sub LCAR_ListRows(ListHeight As Int) As Int' ListID As Int)As Int
	Dim Height As Long', Lists As LCARlist,  Dimensions As tween 
	'Lists= lcarlists.Get(ListID) 
	'Dimensions=ProcessLoc( Lists.LOC, Lists.Size)
	Return Floor(ListHeight  / (ItemHeight + ListitemWhiteSpace))
End Sub

Sub LCAR_ListCols(ColsLandscape As Int,ColsPortrait As Int) As Int' ListID As Int)As Int
	'If SmallScreen AND OneColOnly Then 
	'	Return 1
	'Else
		If Landscape Then 
			Return ColsLandscape'lists.
		Else
			Return ColsPortrait'lists.
		End If
	'End If
End Sub

Sub LCAR_ListID(Name As String) As Int
	Dim temp As Int, Lists As LCARlist 
	For temp = 0 To LCARlists.Size-1
		Lists= LCARlists.Get(temp) 
		If Lists.Name.EqualsIgnoreCase(Name) Then
			Return temp
		End If
	Next
	Return -1
End Sub
Sub LCAR_AddList(Name As String, SurfaceID As Int, ColsPortrait As Long, ColsLandscape As Long, X As Long, Y As Long, Width As Long, Height As Long, Visible As Boolean, WhiteSpace As Int,  LWidth As Int,  RWidth As Int, RhasCurve As Boolean ,  ShowNumber As Boolean, MultiSelect As Boolean, Style As Int  ) As Int
	Dim Lists As LCARlist
	Lists.Initialize 
	Lists.alignment=4
	Lists.SurfaceID = SurfaceID 
	Lists.Name = Name
	Lists.Style=Style
	Lists.ColsLandscape = ColsLandscape
	Lists.ColsPortrait=ColsPortrait
	Lists.IsClean=False
	Lists.isDown = False
	Lists.isScrolling=False
	Lists.MultiSelect = MultiSelect
	Lists.SelectedItem=-1
	Lists.RhasCurve = RhasCurve
	Lists.Visible = Visible
	Lists.WhiteSpace = WhiteSpace
	Lists.LWidth=LWidth
	Lists.RWidth =RWidth
	Lists.ShowNumber= ShowNumber
	
	Lists.ListItems.Initialize 
	
	Lists.Opacity.Initialize 
	Lists.Opacity.Desired=255
	Lists.Opacity.Current=255
	
	Lists.LOC.Initialize 
	Lists.LOC.currX=X
	Lists.LOC.currY=Y 
	
	Lists.Size.Initialize 
	Lists.Size.currX=Width
	Lists.Size.currY =Height
	
	LCARlists.Add(Lists)
	LCARVisibleLists.Add(Visible)

	Return LCARlists.Size-1
End Sub

Sub LCAR_AddListItems(ListID As Int, ColorID As Int, WhiteSpace As Int, Items As List)As Int
	Dim temp As Int
	For temp = 0 To Items.Size-1
		LCAR_AddListItem(ListID, Items.Get(temp),  ColorID,  -1 , "", False, "",  WhiteSpace,  False,-1)
	Next
	Return (Items.Size)'*itemheight) +3)
End Sub
Sub LCAR_SetListItemSides(ListID As Int, Text As List)
	Dim temp As Int, Lists As LCARlist ,Item As LCARlistitem 
	Lists= LCARlists.Get(ListID)
	For temp = 0 To Min(Lists.ListItems.Size -1,Text.size-1)
		Item = Lists.ListItems.Get(temp)
		Item.IsClean=False
		Item.Side = Text.Get(temp)
	Next
	Lists.IsClean=False
End Sub

Sub LCAR_AddLCARcolors(ListID As Int, doText As Boolean )As Int
	Dim temp As Int ,Text As String , COLOR As LCARColor ,ret As Int
	For temp = 0 To LCARcolors.Size -1
		If temp <> LCAR_RedAlert Then
			If doText Then 
				COLOR = LCARcolors.Get(temp)
				Text = COLOR.Name 
			End If
			LCAR_AddListItem(ListID, Text.ToUpperCase, temp, -1, "", False, "", 0, False,-1)
			ret=ret+1
		End If
	Next
	Return ret
End Sub

Sub LCAR_RemoveListitem(ListID As Int, ItemID As Int)
	Dim Lists As LCARlist 
	If ListID>-1 AND ListID< LCARlists.Size Then 'AND ItemID>-1  Then
		Lists=LCARlists.Get(ListID) 
		If ItemID <0 Then ItemID = Lists.SelectedItem 
		If ItemID=-1 Then Return 
		If ItemID=LCAR_LastListitem OR ItemID>=Lists.ListItems.Size Then ItemID = Lists.ListItems.Size-1
		Lists.ListItems.RemoveAt(ItemID)
		Lists.IsClean=False
		'LCARlists.Set(ListID,Lists)
	End If
End Sub 

Sub ForceRandomColor As Int 
	Dim temp As Int 
	temp = LCAR_RandomColor
	Do While temp = CurrRandom
		temp = LCAR_RandomColor
	Loop
	CurrRandom=temp
	Return temp
End Sub
Sub LCAR_AddListItem(ListID As Int, Text As String, ColorID As Int, Number As Int, Tag As String, Selected As Boolean, SideText As String, WhiteSpace As Int,IsMint As Boolean, Index As Int ) As Int
	Dim ListItem As LCARlistitem , Lists As LCARlist
	ListItem.Initialize
	If ColorID= LCAR_Random Then
		'LessRandom As Boolean,	CurrRandom As Int,			CurrListID As Int:
		'debug(LessRandom & " " & CurrRandom)
		If LessRandom Then
			If CurrListID <> ListID Then
				'debug("FORCED RANDOM " & CurrListID & " " & ListID)
				ForceRandomColor
				CurrListID=ListID
			End If
			ColorID = CurrRandom
		Else
			ColorID = LCAR_RandomColor
		End If
	Else If ColorID = LCAR_RandomTheme Then
		ColorID = Rnd(-CurrentTheme.ColorCount ,0)
	End If
	
	ListItem.ColorID=ColorID
	ListItem.IsClean=False
	ListItem.Number =Number
	ListItem.Selected=Selected
	ListItem.Side=SideText
	ListItem.Tag=Tag
	ListItem.Text=Text
	ListItem.WhiteSpace =WhiteSpace
	
	Lists=LCARlists.Get(ListID) 
	If IsMint Then 
		Lists.IsClean = False
		Lists.ForcedMint = ListItem
	Else
		If Index=-1 Then
			Lists.ListItems.Add(ListItem)
			Return Lists.ListItems.Size-1
		Else
			Lists.ListItems.InsertAt(Index,ListItem)
			Return Index
		End If
	End If
	'LCARlists.Set(ListID, Lists)
End Sub



Sub MaxRandomColors As Int
	Return 6
End Sub
Sub DrawLCARchart(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Percent As Int , ColorID As Int, Align As Int, Align2 As Int, Alpha As Int,Style As Int,SecColorID As String  )
	Dim Color As Int,  BGColor As Int,Stroke As Int,temp As Int,temp2 As Int
	Stroke=2

	
	If RedAlert Then
		Color=GetColor(LCAR_DarkBlue, False,Alpha)
		BGColor=Colors.White'GetColor(LCAR_DarkBlue, False,Alpha)
	Else
		Color=GetColor(ColorID, False,Alpha)
		Select Case SecColorID
			Case 0, "": BGColor=GetColor(LCAR_DarkBlue, False,Alpha)
			Case 1: BGColor=GetColor(LCAR_DarkBlue, True,Alpha)
			Case 2: BGColor=GetColor(Classic_Blue, False,Alpha)
			Case 3: BGColor=GetColor(Classic_Blue, True,Alpha)
			Case 4: BGColor=GetColor(LCAR_Purple, False,Alpha)
			Case 5: BGColor=GetColor(LCAR_Purple, True,Alpha)
		End Select
	End If
	Select Case Align
		Case -1'top
			BG.DrawLine(X, Y, X+Width, Y, Color,Stroke)
		Case 0,LCAR_Random 'normal
			Select Case Style
				Case LCAR_Chart
					BG.DrawRect(SetRect(X,Y,  Width* (Percent*0.01), Height), BGColor, True,0)
				Case LCAR_ChartNeg
					temp=(Width*0.5)
					If Percent>0 Then
						BG.DrawRect(SetRect(X+temp,Y,  temp * (Percent*0.01), Height), BGColor, True,0)
					Else If Percent<0 Then
						temp2=temp * (Percent*0.01)
						BG.DrawRect(SetRect(X+temp-temp2,Y,  temp2, Height), BGColor, True,0)
					End If
			End Select
			BG.DrawRect(SetRect(X,Y,  Width, Height),Color,False,Stroke)
		Case 1'bottom
			BG.DrawLine(X, Y+Height-1, X+Width, Y+Height-1, Color,Stroke)
	End Select
	Select Case Align2
		Case -1'left edge
			If Align=0 Then
				BG.DrawRect(SetRect(X,Y,  ChartSpace, Height),Color,True,0)
			Else
				BG.DrawRect(SetRect(X-Stroke,Y,  ChartSpace+Stroke, Height),Color,True,0)
			End If
		Case 1'right edge
			BG.DrawRect(SetRect(X+Width-1-ChartSpace,Y,  ChartSpace, Height),Color,True,0)
			If Align <> 0 Then BG.DrawRect(SetRect(X-Stroke,Y,  Stroke+Stroke, Height),Color,True,0)
	End Select
	
	For BGColor = X To X+Width Step ChartWidth
		BG.DrawLine(BGColor, Y, BGColor, Y+Height-1, Color,Stroke)
	Next
	'If align<>0 Then bg.DrawLine(x,  y, BGColor, y+height-1, color,Stroke)
End Sub 


Sub SetListitemColor(ListID As Int, ItemID As Int, ColorID As Int) As Int 
	Dim Lists As LCARlist, ListItem As LCARlistitem
	If ListID < LCARlists.Size Then
		Lists= LCARlists.Get(ListID)
		If ItemID < Lists.ListItems.Size Then 
			ListItem=Lists.ListItems.Get(ItemID)
			If ColorID =-1 Then ColorID=CurrRandom
			ListItem.ColorID=ColorID
			Return ColorID
		End If
	End If
	Return -1
End Sub
Sub RandomizeColors(ListID As Int)
	Dim temp As Int, Lists As LCARlist, ListItem As LCARlistitem, dochart As Boolean ,Old As String 
	If Not(LessRandom) Then
		Lists= LCARlists.Get(ListID)
		Select Case Lists.Style 
			Case LCAR_Chart, LCAR_ChartNeg: dochart = True
		End Select
		For temp = 0 To Lists.ListItems.Size-1
			ListItem=Lists.ListItems.Get(temp)
			If dochart Then
				If ListItem.WhiteSpace <> ListItem.Number Then 
					Old = ListItem.side
					Do Until Not(Old.EqualsIgnoreCase(ListItem.side))
						ListItem.side = Rnd(0,MaxRandomColors)
					Loop
				End If
			Else
				ListItem.ColorID= LCAR_RandomColor
			End If
			ListItem.IsClean=False 
			Lists.ListItems.Set(temp,ListItem)
		Next
		Lists.IsClean=False
		'LCARlists.Set(ListID,Lists)
	End If
End Sub

Sub SmallScreenMode(ListID As Int) As Int 
	Dim Lists As LCARlist ,temp As Int
	If ListID=-1 Then
		SmallScreen = (CrazyRez=0)
		For temp = 0 To LCARlists.Size-1
			Lists = LCARlists.Get(temp)
			If Lists.OneColOnly Then
				Lists.ColsLandscape=1
				Lists.ColsPortrait =1
				LCARlists.Set(temp,Lists)
			End If
		Next
		
		LCARCornerElbow.Initialize(File.DirAssets,"elbows.png")
		LCARCornerElbow2.Initialize(File.DirAssets,"elbow2s.png")
		LCARCornerElbowa.Initialize(File.DirAssets,"elbows.gif")
		LCARCornerElbow2a.Initialize(File.DirAssets,"elbow2s.gif")
		
		LCARSeffects.SmallScreenMode
		If SmallScreen Then ChartHeight=ChartHeight*0.5 Else ChartHeight=ChartHeight*CrazyRez 
		
		temp = API.IIF(CrazyRez=0, 50, 100*CrazyRez)
		If NumGroup>0 Then 'resize IP numboard
			ClearLRwidths(NumListID)
			ResizeElbowDimensions(NumButtonID,temp,ItemHeight)
			ResizeElbowDimensions(NumButtonID+4,temp,ItemHeight)
		End If
		If KBCancelID>0 Then'resize keyboard
			ClearLRwidths(KBListID)
			ResizeElbowDimensions(KBCancelID, temp, ItemHeight)
			ResizeElbowDimensions(KBCancelID+4,temp, ItemHeight)
		End If
	Else If CrazyRez=0 Then
		Lists = LCARlists.Get(ListID)
		Lists.OneColOnly=True
		'LCARlists.Set(ListID,Lists)
	End If
	Return ListID
End Sub

Sub DrawList(BG As Canvas,SurfaceID As Int , ListID As Int, X2 As Int, Y2 As Int, Width2 As Int, Height2 As Int)As Boolean 
	Dim temp As Int, Lists As LCARlist, Dimensions As tween, ListItem As LCARlistitem 'ListitemWhiteSpace ItemHeight
	Dim temp As Int, temp2 As Int, temp3 As Int, X As Int, Y As Int',ItemsDrawn As Int ',Number As Int
    Dim ItemsOnScreen As Int, ItemsPerCol As Int, ItemWidth As Int,tItemHeight As Int, Cols As Int, color As Int
    Dim Width As Int, Height As Int, tX As Int, tY As Int, Mint As Int,State As Boolean ,Start As Int 
    Dim WhiteSpace2 As Int, RText As String,ChartStart As Int, P As Path ,Scrolling As Boolean ,Selected As Boolean , IsSmooth As Boolean 
	
	If LCARVisibleLists.Get(ListID) OR Width2>0 Then
		CheckNumbersize(BG)
		Lists= LCARlists.Get(ListID)
		Start = Max(0, Lists.Start )
		If  (Lists.SurfaceID = SurfaceID OR SurfaceID=-1) AND (Not(Lists.IsClean) OR Not(IsClean)) Then
			If Width2=0 Then
				Dimensions=ProcessLoc( Lists.LOC, Lists.Size)
			Else 
				Dimensions.Initialize 
				Dimensions.currX =X2
				Dimensions.currY =Y2
				Dimensions.offX =Width2
				Dimensions.offY =Height2
				Lists.Opacity.Current=255
			End If
			tX = Dimensions.currX 
			tY = Dimensions.currY 
			Width = Dimensions.offX 
			Height= Dimensions.offY 
			If Lists.Locked OR Lists.Start<0 Then Lists.Start=0
			If Lists.SelectedItem=-1 Then Lists.SelectedXY = LCARSeffects.SetPoint(-1,-1)
			
			Select Case Lists.Style
				Case 0, PCAR_Button' normal/LCAR_Buttons
					If SmoothScrolling AND Lists.Style=0 AND Lists.offset<0 AND Lists.isScrolling AND Start>0 Then
						If Not( LimitStart(Lists,0, True)) Then
							Mint=Lists.Offset*-1
							IsSmooth=True
							'LCARSeffects4.DrawRect(BG,tX,tY-(ItemHeight+ListitemWhiteSpace), Width, ItemHeight+ListitemWhiteSpace, Colors.Black, 0)
							'BG.DrawLine(tX, tY-Mint, tX+Width, tY-Mint, Colors.Red,3)
							
							LCARSeffects.MakeClipPath(BG, tX, tY, Width+1,Height+1)	
							'LCARSeffects4.DrawRect(BG,tX, tY, Width,Height, Colors.Black, 0)
							'Start=Start-1
							tY=tY- Mint
							Height=Height+ItemHeight-ListitemWhiteSpace *2
							Scrolling=True
							'Log(Lists.Start & " : " &  Start & " : " & Lists.Offset & " : " & Mint)
						End If
					End If
				
					
					Cols= LCAR_ListCols(Lists.ColsLandscape,Lists.ColsPortrait)
					If Lists.Style=0 Then
						ItemsOnScreen= LCAR_ListRows(Height   )
						ItemsPerCol=LCAR_ListItemsPerCol(Lists.ColsLandscape, Lists.ColsPortrait, Lists.ListItems.Size)
						If Lists.ListItems.Size Mod Cols > 0 Then ItemsPerCol = ItemsPerCol + 1
					Else
						If Lists.ListItems.Size=0 Then Return False
						'ItemsOnScreen= Floor(  Height / (50+ListitemWhiteSpace))
						If Cols=0 Then Cols = Lists.ListItems.Size 
						ItemsPerCol= Ceil(Lists.ListItems.Size/ Cols)
						ItemsOnScreen=ItemsPerCol
						tItemHeight= (Height/ItemsPerCol) - ListitemWhiteSpace
						
						'ItemWidth = Floor(  (Width- (ListitemWhiteSpace*(Cols-1)) / Cols))' - ListitemWhiteSpace
					End If
					ItemWidth = Floor(Width / Cols) - ListitemWhiteSpace
					
					
					Mint = ItemsOnScreen
					Lists.LastMint=Mint
					If Mint > ItemsPerCol Then 
						Lists.LastMint=ItemsPerCol
						If Not(Lists.ForcedMint.IsInitialized) Then  Mint = ItemsPerCol
					End If
					If Lists.LastMint=0 Then Lists.LastMint = Mint 
					temp =  ItemsPerCol-ItemsOnScreen
					If temp<0 Then temp =Min(ItemsOnScreen, Lists.ListItems.Size)
					'temp=Lists.ListItems.Size-Mint
					'debug("List start: " & lists.Start & " mint: " & mint & " lists.ListItems.Size " & lists.ListItems.Size )
					If Start<=0 Then
						Start=0
					Else If Start > temp Then 
						Start=temp
					End If
					
					X = tX
					If Not(Lists.IsClean) Then BG.DrawRect( SetRect(tX,tY,Width,Height), Colors.Black, True,0)
					For temp = 0 To Cols-1
						temp3 = Start + (ItemsPerCol * temp)
						Y = tY
						If Scrolling Then
							'Y=Y+ItemHeight+ListitemWhiteSpace
							temp3=temp3-1
						End If
						For temp2 = 1 To Mint
							If temp3 < Lists.ListItems.Size  AND temp3 > -1 Then
								ListItem= Lists.ListItems.Get(temp3)
								
								If Lists.Style=0 Then
									Selected= DrawListItem(BG, Lists, ListItem, X,Y, temp3,ItemWidth, temp,temp2, Lists.Opacity.Current, Lists.Alignment) 'Then Lists.SelectedXY=LCARSeffects.SetPoint(temp, temp2-1 )
								Else
									Selected= BlinkState AND  ((temp3= Lists.SelectedItem) OR ListItem.Selected )
									
									LCARSeffects2.DrawLegacyButton(BG, X,Y, -ItemWidth+ChartSpace, tItemHeight, GetColor(ListItem.ColorID, Selected, Lists.Opacity.Current), ListItem.Text, 2)
									If ListItem.Side.Length>0 Then
										LCARSeffects2.DrawLegacyButton(BG, X,Y, -ItemWidth+ChartSpace, tItemHeight, Colors.Transparent, ListItem.Side, 8)
									End If
								End If
								If Selected Then Lists.SelectedXY=LCARSeffects.SetPoint(temp, temp2-1 )
								'State= BlinkState AND listitem.Selected 
								'If redalert AND temp= lists.RedX AND temp2=lists.RedY Then
								'	state=True
								'	listitem.IsClean = False
								'End If
								'If Not(listitem.IsClean) OR Not(lists.IsClean) OR Not(isclean)  Then
								'	Number=-1
								'	If lists.ShowNumber Then Number = listitem.Number 
								'	DrawLCARButton(BG, X, Y, ItemWidth, ItemHeight, listitem.ColorID, State, listitem.Text, listitem.Side, lists.LWidth, lists.RWidth, lists.RhasCurve, lists.WhiteSpace, 4,Number)
								'	listitem.IsClean = True
								'	lists.ListItems.Set(temp3,listitem)
								'End If
							Else If Lists.ForcedMint.IsInitialized Then
								DrawListItem(BG, Lists, Lists.ForcedMint, X,Y, -2,ItemWidth,temp,temp2, Lists.Opacity.Current,Lists.Alignment)
							End If
							temp3=temp3+1
							
							If Lists.Style=0 Then
								Y=Y+ItemHeight+ListitemWhiteSpace
							Else
								Y=Y+tItemHeight+ListitemWhiteSpace
							End If
							If Lists.ForcedMintCount = temp2 Then temp2=Mint
						Next
						X = X + ItemWidth + ListitemWhiteSpace
					Next
					
					If P.IsInitialized Then BG.RemoveClip 
				Case LCAR_Chart, LCAR_ChartNeg 'ChartWidth=40:ChartEdgeHeight=13:ChartHeight=62:ChartSpace=5
					X=tX:Y=tY
					If Lists.ColsLandscape>0 OR Lists.ColsPortrait>0 Then
						ChartStart=100
						If CrazyRez>0 Then
							ChartStart=ChartStart * CrazyRez 
						Else
							If SmallScreen Then ChartStart = 50
						End If
						X=X+ChartStart+3
						Width=Width-ChartStart-3
						Y=Y-(ChartEdgeHeight + ChartSpace)
					End If
					ChartWidth= Floor(Width/10)
					ItemsOnScreen= (Dimensions.offY - (ChartEdgeHeight + ChartSpace)*2) / (ChartSpace+ChartHeight)
					Lists.LastMint=ItemsOnScreen
					Width= Floor(Width / ChartWidth)*ChartWidth
					DrawLCARchart(BG, X, Y, Width, ChartEdgeHeight,0, LCAR_Orange, 1, Lists.LWidth, Lists.Opacity.Current,0,0)
					Y=Y+ChartEdgeHeight + ChartSpace
					For temp = Start To Start +ItemsOnScreen' 0 To ItemsOnScreen
						If temp < Lists.ListItems.Size Then
							ListItem= Lists.ListItems.Get(temp)
							If Not(ListItem.IsClean)  OR Not(Lists.IsClean) OR Not(IsClean)  Then'																								  A
								If ChartStart>0 Then DrawLCARbutton(BG,  tX,Y-1, ChartStart, ChartHeight+2, ListItem.ColorID,   False, API.LimitTextWidth(BG, ListItem.Text, LCARfont, Fontsize, ChartStart, "..."  ), "", 0,0,False,0,  1 ,-1,255,False)
								ListItem.IsClean = True
								'Lists.ListItems.Set(temp,ListItem)
								DrawLCARchart(BG, X, Y, Width,  ChartHeight, ListItem.WhiteSpace , ListItem.ColorID, 0, Lists.LWidth, Lists.Opacity.Current, Lists.Style, ListItem.Side  )
							End If
							Y=Y+ChartHeight + ChartSpace
						Else
							temp=Start +ItemsOnScreen
						End If
					Next
					temp=Max(tY+ Height - Y +ChartEdgeHeight*2, ChartEdgeHeight)
					DrawLCARchart(BG, X, Y, Width, ChartEdgeHeight,0, LCAR_Orange, -1, Lists.LWidth, Lists.Opacity.Current,0,0 )
					DrawRect(BG,X-ChartStart-3,Y-1, ChartStart, temp, GetColor(LCAR_Orange,False,255), 0)' (ItemsDrawn * (ChartHeight + ChartSpace)) 
					
				Case LCAR_Meter
					X=tX:Y=tY
					ItemsOnScreen= Width/ (ChartSpace + MeterWidth)
					tItemHeight= Height
					If Lists.ListItems.Size > ItemsOnScreen Then tItemHeight= Height / Ceil(Lists.ListItems.Size / ItemsOnScreen) - ChartSpace

					For temp = 0 To Lists.ListItems.Size-1' ItemsOnScreen-1
						If temp < Lists.ListItems.Size Then
							ListItem= Lists.ListItems.Get(temp)
							If Not(ListItem.IsClean)  OR Not(Lists.IsClean) OR Not(IsClean)  Then
								ListItem.IsClean = True
								'Lists.ListItems.Set(temp,ListItem)
								DrawLCARmeter(BG, X,Y, MeterWidth, tItemHeight,  ListItem.WhiteSpace , ListItem.ColorID, ListItem.Selected, Lists.Opacity.Current)
							End If
							X=X+ChartSpace + MeterWidth
							If X> tX+Width-MeterWidth Then 
								X=tX
								Y=Y+tItemHeight+ChartSpace
							End If
						End If
					Next

				
				Case LCAR_MiniButton
					If Lists.ListItems.Size>0 Then
						ItemWidth = Width/ Lists.ListItems.Size 
						X=tX
						For temp = 0 To Lists.ListItems.Size-1
							ListItem= Lists.ListItems.Get(temp)
							Selected = BlinkState AND (ListItem.Selected  OR (Lists.SelectedItem = temp))
							LCARSeffects2.DrawLegacyButton(BG, X,tY, -ItemWidth+ChartSpace, Height, GetColor(ListItem.ColorID, Selected, Lists.Opacity.Current), ListItem.Text, 9)
							X=X+ItemWidth
						Next
					End If
			End Select
			'If lists.ForcedMintCount >0 AND lists.ForcedMintCount< mint Then 
			'	lists.ForcedMintCount=lists.ForcedMintCount+1
			'Else
			'	lists.ForcedMintCount=0'Just in case
				Lists.IsClean = True
			'End If
			
			LCARlists.Set(ListID,Lists)
			Return True
		End If
	End If
	If IsSmooth Then BG.removeclip
End Sub

Sub AddChartItem(ListID As Int, ColorID As Int, Percent As Int, Index As Int,Text As String,Tag As String   )
	If Percent<0 OR Percent>100 Then Percent = Rnd(0,101)
	LCAR_AddListItem(ListID, Text, ColorID, Percent,   Tag, False, "", 0,  False, Index)
End Sub



Sub LCAR_GetSelectedItem(ListId As Int) As Int
	Dim lists As LCARlist
	lists=LCARlists.Get(ListId)
	Return lists.SelectedItem 
End Sub
Sub LCAR_GetListItem(ListID As Int, Item As Int) As LCARlistitem 
	Dim temp As List , lists As LCARlist,listitem As LCARlistitem 
	
	If ListID>-1 AND ListID< LCARlists.Size Then
		lists=LCARlists.Get(ListID)
		If Item>-1 AND Item < lists.ListItems.Size Then
			Return lists.ListItems.Get(Item)
			'temp.Initialize2(Array As String( listitem.Text, listitem.Side, listitem.Tag))
			'Return temp
		Else If Item = LCAR_SelectedItem AND lists.SelectedItem>-1 Then
			Return lists.ListItems.Get(lists.SelectedItem)
		End If
	End If
	Return listitem
End Sub

Sub LCAR_FindListItem(ListID As Int, Text As String, TextIs0SidetextIs1TagIs2 As Int, RemoveIt As Boolean, Number As Int)As Int
	Dim temp As Int , lists As LCARlist ,listitem As LCARlistitem ,found As Boolean 
	If TextIs0SidetextIs1TagIs2=3 AND Not(IsNumber(Text)) Then Return -1
	If ListID>-1 AND ListID< LCARlists.Size Then
		lists=LCARlists.Get(ListID)
		For temp = 0 To lists.ListItems.Size-1
			listitem = lists.ListItems.Get(temp)
			Select Case TextIs0SidetextIs1TagIs2
				Case 0: found = listitem.Text.EqualsIgnoreCase(Text) 'text
				Case 1: found = listitem.side.EqualsIgnoreCase(Text) 'sidetext
				Case 2: found = listitem.Tag.EqualsIgnoreCase(Text)'tag
				Case 3: found = (listitem.Number = Text)'number
			End Select
			If found Then 
				found=False
				If RemoveIt Then 
					lists.ListItems.RemoveAt(temp)
				Else If Number>-1 Then 
					listitem.Number=Number
					found=True
				Else If Number=-2 Then
					listitem.Selected=True
				End If
				If found Then lists.ListItems.Set(temp,listitem)
				Return temp
			End If
		Next
	End If
	Return -1
End Sub

'Sub SetIncrementingList(ListID As Int)'
	'Dim lists As LCARlist 
	'lists = lcarlists.Get(listid)
	'lists.ForcedMintCount=1
	'lcarlists.Set(listid,lists)
'End Sub

Sub DrawListItem(BG As Canvas, Lists As LCARlist , ListItem As LCARlistitem , X As Int, Y As Int, ItemIndex As Int,ItemWidth As Int, temp As Int, temp2 As Int, Alpha As Int , Alignment As Int   )As Boolean 
	Dim Number As Int,State As Boolean,Text As String ,L As Int, r As Int
	'If ShowNumber Then WhiteSpace2 = 41		
    'WhiteSpace2 = listitem.WhiteSpace 
	If RedAlert Then
		If temp= Lists.RedX AND temp2=Lists.RedY Then
			State=True
			Lists.Red=ItemIndex
			ListItem.IsClean = False
		Else If ItemIndex = Lists.Red Then
			ListItem.IsClean = False
			Lists.Red = -1
		End If
	Else
		State= BlinkState AND (ListItem.Selected  OR (Lists.SelectedItem = ItemIndex))
	End If
	If Not(ListItem.IsClean) OR Not(Lists.IsClean) OR Not(IsClean) OR (ItemIndex<0)  Then
		BG.DrawRect( SetRect(X,Y,ItemWidth,ItemHeight), Colors.Black, True,0)
		Number=-1
		If Lists.ShowNumber Then 
			'If itemindex<0 then load cached numbers
			Number = ListItem.Number 
		End If
		L=PreProcessLRwidth(ItemWidth, Lists.LWidth)
		r=PreProcessLRwidth(ItemWidth,Lists.RWidth)
		If ListItem.Text.Length<6 Then
			Text= ListItem.Text
		Else
			Text= API.LimitTextWidth(BG, ListItem.Text, LCARfont, Fontsize, ItemWidth-ListItem.WhiteSpace-L-r-Lists.WhiteSpace*2,  "...")
		End If
		DrawLCARbutton(BG, X+ ListItem.WhiteSpace, Y, ItemWidth- ListItem.WhiteSpace, ItemHeight, ListItem.ColorID, State, Text, ListItem.Side, L, r, Lists.RhasCurve, Lists.WhiteSpace, Alignment,Number, Alpha,False)
		ListItem.IsClean = True
		If ItemIndex>-1 Then Lists.ListItems.Set(ItemIndex,ListItem)
	End If
	Return Lists.SelectedItem = ItemIndex 
End Sub
Sub PreProcessLRwidth(ItemWidth As Int, LRWidth As Int) As Int
	If LRWidth<0 Then
		Return LRWidth/-100*ItemWidth
	Else
		Return LRWidth
	End If
End Sub

'Public Function LCAR_AddListItem(ListId As Long, Text As String, Optional color As Long = -1, Optional LightColor As Long = -1, Optional Size As Long = -1, Optional Tag As String, Optional Icon As Long = -1, Optional Selected As Boolean, Optional Side As String, Optional WhiteSpace As Long = -1, Optional FILEsize As String, Optional LCARtext As String) As Long
Sub LCAR_ClearList(ListId As Int, DownToItem As Int)
	Dim Lists As LCARlist, temp As Int 
	Lists= LCARlists.Get(ListId) 
	If DownToItem=0 Then
		Lists.ListItems.Clear 
	Else
		For temp = Lists.ListItems.Size-1 To DownToItem Step -1
			Lists.ListItems.RemoveAt(DownToItem)' Lists.ListItems.Size-1)
		Next
	End If
	Lists.Red=-1
	Lists.IsClean = False
	Lists.SelectedItem = -1
	Lists.SelectedItems=0 
	Lists.Start=0	
	LCARlists.Set(ListId,Lists)
End Sub

Sub LCAR_FindLCAR(Name As String, Group As Int, Index As Int) As Int 'If Index=-1 then it will count the occurances of that button id
	Dim temp As Long, temp2 As Long,Element As LCARelement 
    For temp = 0 To LCARelements.Size - 1
		Element = LCARelements.Get(temp)
        If Name.EqualsIgnoreCase(Element.Name) Then
            If Group <0 OR Group = Element.Group Then
                If Index = 0 Then
                    Return temp
                Else
                    If temp2 = Index Then Return temp
                    temp2 = temp2 + 1
                End If
            End If
        End If
    Next
    If Index = -1 Then Return temp2 Else Return -1
End Sub

Sub ForceShowGroup(GroupID As Int)
	Dim temp As Long, Element As LCARelement ,Group As LCARgroup ,Alpha As Int, Index As Int 
	If GroupID< LCARGroups.Size Then
		Group = LCARGroups.Get(GroupID)
		ismoving = True
		For temp = 0 To Group.LCARlist.Size-1 'lcarelements.Size - 1
			Index=Group.LCARlist.Get(temp)
			Element = LCARelements.Get( Index  )
			'If  element.Visible <> state Then		'element.Group = groupid AND
				Element.Opacity.Desired=255
				Element.Opacity.Current=0
				Element.Visible = True
				Element.IsClean = False
				LCARelements.Set(Index, Element)
			'End If
		Next
		Group.Visible=True
		LCARGroups.Set(GroupID,Group)
		IsClean=False
	End If
End Sub 

Sub HideGroup(GroupID As Int, State As Boolean, UseAlpha As Boolean )
	Dim temp As Long, Element As LCARelement ,Group As LCARgroup ,Alpha As Int, Index As Int 
	If GroupID< LCARGroups.Size Then
		Group = LCARGroups.Get(GroupID)
		If UseAlpha Then
			ismoving = True
			If State Then Alpha = 255 
			
			
			For temp = 0 To Group.LCARlist.Size-1 'lcarelements.Size - 1
				Index=Group.LCARlist.Get(temp)
				Element = LCARelements.Get( Index  )
				If  Element.Visible <> State Then		'element.Group = groupid AND
					Element.Opacity.Desired=Alpha
					Element.Visible = ( (Alpha>0)  OR (Element.Opacity.Current >0) )
					Element.IsClean = False
					LCARelements.Set(Index, Element)
				End If
			Next
		'Else
			'state=True
		End If
		'If Not(state) Then
			'group = lcargroups.Get(groupid)
			Group.Visible=State
			LCARGroups.Set(GroupID,Group)
			IsClean=False
		'End If
	End If
End Sub

Sub ForceHideAll(BG As Canvas)
	Dim temp As Long
	LCAR_HideAll(BG,False)
	For temp=0 To LCARelements.Size-1
		ForceHide( temp)
	Next
	ClearScreen(BG)
End Sub

Sub LCAR_HideAll(BG As Canvas, UseAlpha As Boolean )
	Dim temp As Long
	VisibleList=-1
	CurrListID=-1
	
	
	
	For temp = 0 To LCARlists.Size-1
		LCAR_HideElement(BG, temp,   True, False ,  Not(UseAlpha))
	Next
'	For temp=0 To LCARelements.Size-1
'		LCAR_HideElement(BG, temp,False,False, Not(UseAlpha))
'	Next
	For temp = 0 To LCARGroups.Size-1
		HideGroup(temp,False,  UseAlpha )
	Next
	LCARSeffects.FrameBitsVisible=False
	KBisVisible=False
	
	'If ClearLocked Then
		
		'WallpaperService.SettingsLoaded=False
	'End If
	
	WebviewOffset=0
	IsClean=False
	ClearLocked=False
	IsClean=False
	
End Sub


Sub LCAR_SetListStyle(BG As Canvas, ListID As Int, Style As Int, Visible As Boolean )
	Dim Lists As LCARlist,Dimensions As tween	
	Lists=LCARlists.Get(ListID)
	If LCARVisibleLists.Get(ListID) Then' lists.Visible Then
		
		Lists.IsClean = False
		Dimensions=ProcessLoc(Lists.LOC, Lists.Size)
		BG.DrawRect( SetRect( Dimensions.currX, Dimensions.currY, Dimensions.offX, Dimensions.offY), Colors.Black , True,0 )
	End If
		LCARVisibleLists.Set(ListID, Visible)
		'lists.Visible = visible
		Lists.Style = Style
		LCARlists.Set(ListID,Lists)
	
End Sub

Sub LCAR_SetListCols(ListID As Int, ColsPortrait As Int, ColsLandscape As Int)
	Dim Lists As LCARlist
	Lists=LCARlists.Get(ListID)
	Lists.IsClean=False
	Lists.ColsLandscape = ColsLandscape
	Lists.ColsPortrait = ColsPortrait
End Sub

Sub LCAR_SortList(ListID As Int)
	Dim Lists As LCARlist, ListItem1 As LCARlistitem , temp As Int 
	Lists=LCARlists.Get(ListID)
	Lists.IsClean=False
	Lists.ListItems.SortType("Text", True)
End Sub

Sub TweenOpacity(IsVisible As Boolean , Visible As Boolean ,Alpha As TweenAlpha ) As TweenAlpha 
	If IsVisible Then
		If Visible Then 
			Alpha.Desired = 255
			Alpha.Current=0
		Else
			Alpha.Desired = 0
			Alpha.Current = 255
		End If
	Else
		Alpha.Current=0
		Alpha.Desired = 0
	End If
	Return Alpha
End Sub

Sub FadeList(BG As Canvas, ListID As Int,Visible As Boolean )
	Dim Lists As LCARlist
	
	If Visible OR LCARVisibleLists.Get(ListID) Then
		Lists=LCARlists.Get(ListID)
		LCARVisibleLists.Set(ListID,True)' lists.Visible = True
		Lists.Opacity= TweenOpacity(True,Visible, Lists.Opacity)
	
		LCARlists.Set(ListID,Lists)
	End If
End Sub

Sub LCAR_HideElement(BG As Canvas, LCARid As Int, isList As Boolean,Visible As Boolean,Nofade As Boolean  ) As Boolean 
	Dim Lists As LCARlist, Element As LCARelement ,Dimensions As tween, Rect1 As Rect,Did As Boolean 
	If LCARid>-1 Then
		If BG=Null Then ClearScreen(Null)
		If isList Then
			If Visible Then	
				VisibleList=LCARid
			Else If VisibleList = LCARid Then
				VisibleList = -1
			End If 
			
			If LCARid < LCARlists.Size Then
				Lists=LCARlists.Get(LCARid)
				If LCARVisibleLists.Get(LCARid) = False AND Visible = True Then
					LCARVisibleLists.Set(LCARid,True)'lists.Visible = visible
					Lists.Opacity.Desired=255
					If Nofade Then Lists.Opacity.Current=255
				Else If LCARVisibleLists.Get(LCARid) = True AND Visible = False Then
					If Nofade Then
						LCARVisibleLists.Set(LCARid,False)
					Else
						Lists.Opacity.Desired=0
					End If
				End If
				Lists.IsClean = False
				LCARlists.Set(LCARid,Lists)
				If Not(Visible) Then
					Did=True
					Dimensions=ProcessLoc(Lists.LOC, Lists.Size)
				End If
			End If
		Else
			If LCARid<LCARelements.Size Then
				Element = LCARelements.Get(LCARid)
				Element.Visible = Visible
				Element.IsClean = False
				LCARelements.Set(LCARid, Element)
				If Not(Visible) Then
					If Nofade OR (Element.ElementType = LCAR_LWP AND Element.LWidth=-1) Then
						Element.Opacity.Current=0
						Element.Opacity.Desired=0
					End If
					If BG <>Null Then
						Dimensions=ProcessLoc(Element.LOC, Element.Size)
						If Element.ElementType=LCAR_Elbow Then
							DrawLCARelbow(BG, Dimensions.currx,  Dimensions.currY, Dimensions.offX, Dimensions.offY, Element.LWidth, Element.RWidth, Element.Align, LCAR_Black, False, "", 0,255 ,False)
						Else
							Did=True
						End If
					End If
				End If
			End If
		End If
		If Did AND BG <> Null AND Dimensions.offY>0 AND Dimensions.offX>0 Then 
			Rect1=SetRect( Dimensions.currX, Dimensions.currY, Dimensions.offX, Dimensions.offY)
			Try
				BG.DrawRect(Rect1, Colors.Black , True,0 )
			Catch
				Did = False
			End Try
		End If
	End If
	Return Did
End Sub

Sub LCAR_HideLCAR(Name As String, Visible As Boolean)
	Dim temp As Long, Element As LCARelement 
    For temp = 0 To LCARelements.Size - 1
		Element = LCARelements.Get(temp)
        If Name.EqualsIgnoreCase(Element.Name) Then
        	Element.Visible = Visible
			Element.IsClean = False
			LCARelements.Set(temp,Element)
        End If
    Next
End Sub
Sub LCAR_GetElement(LCARid As Int) As LCARelement  
	Return LCARelements.Get(LCARid)
End Sub
Sub LCAR_Blink(LCARid As Int, State As Boolean )
	Dim  Element As LCARelement
	Element = LCARelements.Get(LCARid)
	Element.Blink = State
	LCARelements.Set(LCARid, Element)
End Sub

Sub LCAR_State(LCARid As Int, State As Boolean)
	Dim Element As LCARelement
	'If lcarid>-1 Then
		Element = LCARelements.Get(LCARid)
		If Element.Enabled Then
			Element.isdown = State
			Element.IsClean = False
		End If
		LCARelements.Set(LCARid, Element)
	'End If
End Sub

Sub GotoNextVisibleElement(GroupID As Int)As Int
	Dim temp As Int, Group As LCARgroup, Element As LCARelement,ID As Int
	Group = LCARGroups.Get(GroupID)
	If Group.Visible AND Group.LCARlist.Size>0 Then
		If Group.LCARlist.Size=1 Then
			If Group.RedAlert>-1 Then
				Group.RedAlert=-1
				LCARGroups.Set(GroupID,Group)
			End If
		Else
			Group.Hold = Group.Hold -1
			If Group.Hold <1 Then 
		
				ID= Group.LCARlist.Get(Group.RedAlert)
				Element = LCARelements.Get(ID)
				Element.IsClean = False
				LCARelements.Set(ID, Element)
		
				For temp = Group.RedAlert+1 To Group.LCARlist.Size-1
					If IsRedAlert(temp, Group, GroupID) Then Return temp
				Next
				For temp = 0 To Group.RedAlert-1
					If IsRedAlert(temp, Group, GroupID) Then Return temp
				Next
				
			End If
		End If
	End If
End Sub
Sub IsRedAlert(temp As Int,  Group As LCARgroup, GroupID As Int  )As Boolean 
	Dim Element As LCARelement,ElementID As Int 
	ElementID=Group.LCARlist.get(temp)'group.RedAlert'(temp)
	Element = LCARelements.Get(ElementID )
	If Element.Visible Then 
		Element.IsClean = False
		LCARelements.Set(ElementID,Element)
		Group.RedAlert = temp
		Group.Hold = Group.HoldList.Get(temp)
		LCARGroups.Set(GroupID, Group)
		Return True
	End If
End Sub

Sub LCAR_BlinkLCARs
	Dim temp As Long, temp2 As Long, Element As LCARelement,ElementID As Int ,Group As LCARgroup ,Lists As LCARlist 
	BlinkState=Not(BlinkState)
	If RedAlert Then
		For temp = 0 To LCARGroups.Size-1
			GotoNextVisibleElement(temp)
		Next
		For temp = 0 To LCARlists.Size-1
			
			If LCARVisibleLists.Get(temp) Then ' lists.Visible Then
				Lists= LCARlists.Get(temp)
				Lists.RedY =Lists.RedY+1
				If Lists.RedY-1 > Lists.LastMint Then
					Lists.RedY =0
					Lists.RedX = Lists.RedX + 1
					If Lists.RedX =LCAR_ListCols(Lists.ColsLandscape,Lists.ColsPortrait) Then Lists.RedX = 0'LCAR_ListCols
				End If
				LCARlists.Set(temp,Lists)
			End If
		Next
	Else
	
		'For temp = 0 To lcarelements.Size - 1
			'element = lcarelements.Get(temp)
			'If element.Blink Then
				'element.IsClean = False
				'lcarelements.Set(temp,element)
			'End If
		'Next
	
		For temp = 0 To LCARGroups.Size-1
			Group = LCARGroups.Get(temp)
			If Group.Visible Then
				For temp2 = 0 To Group.LCARlist.Size-1
					ElementID = Group.LCARlist.Get(temp2)
					Element = LCARelements.Get(ElementID)
					If Element.Blink Then
						Element.IsClean = False
						LCARelements.Set(ElementID,Element)
					End If
				Next
			End If
		Next
	
		For temp = 0 To LCARlists.Size-1
			
			If LCARVisibleLists.Get(temp) Then'lists.Visible
				Lists= LCARlists.Get(temp)
				Lists.IsClean =False
				LCARlists.Set(temp,Lists)
				
				'Log ( "LIST: " &  lists.SelectedItems)
				'If  lists.SelectedItems=1 Then
				'	DirtyListItem(lists, lists.SelectedItem , False,False,False)
				'	lcarlists.Set(temp,lists)
				'Else If lists.SelectedItems>1 Then
				'	lists.IsClean = False
				'	lcarlists.Set(temp,lists)
				'End If
			End If
		Next
	End If
	If VolOpacity=255 Then 'Dim VolOpacity As Int, VolSeconds As Int VolVisible
		If VolSeconds>0 Then VolSeconds=VolSeconds-1
	End If
End Sub


Sub HideToast
	'debug("HIDE TOAST")
	VolOpacity=0
	VolSeconds=0
	VolText=""
	VolTextList.Clear 
End Sub



Sub LCAR_DeleteLCAR(LCARid As Int)As Boolean 
	Dim temp As Int, Element As LCARelement ,Group As LCARgroup 
	If LCARid>-1 AND LCARid< LCARelements.Size Then
		Element = LCARelements.Get(LCARid)
		Group = LCARGroups.Get( Element.Group)
		For temp = 0 To Group.LCARlist.Size-1
			If Group.LCARlist.get(temp) = LCARid Then
				Group.LCARlist.RemoveAt(temp)
				temp=Group.LCARlist.Size
			End If
		Next
		LCARelements.RemoveAt(LCARid)
		Return True
	End If
End Sub

Sub MakeLCAR(Name As String,SurfaceID As Int, X As Int, Y As Int, Width As Int, Height As Int, LWidth As Int, RWidth As Int, ColorID As Int, ElementType As Int, Text As String,SideText As String , Tag As String, Group As Int, Visible As Boolean, TextAlign As Int, Enabled As Boolean, Align As Int, Alpha As Int )  As LCARelement 
	Dim temp As LCARelement ,Picture As LCARpicture 
	temp.Initialize 
	temp.LOC.Initialize 
	temp.Size.Initialize 
	temp.Opacity.Initialize 
	
	temp.SurfaceID = SurfaceID
	temp.Opacity.Current=Alpha
	temp.Opacity.Desired=Alpha
	
	temp.Name=Name
	temp.Tag = Tag
	
	Select Case ElementType
		Case LCAR_Picture
			If Width=0 OR Height=0 Then
				Picture = PictureList.Get(LWidth)
				Width = Picture.Picture.Width 
				Height=Picture.Picture.Height 
				Select Case Align
					Case 1'top left
						X=X-Width/2
						Y=Y-Height/2
				End Select
			End If
		Case LCAR_Button 
			If (LWidth>0 OR RWidth>0) AND Align=0 Then Height=ItemHeight
	End Select
	
	temp.LOC.currX=X
	temp.LOC.currY=Y
	temp.Size.currX=Width
	temp.Size.currY=Height
	
	temp.ColorID =ColorID
	temp.ElementType =ElementType
	temp.Enabled =Enabled
	temp.Group=Group
	temp.Visible=Visible
	
	temp.Text=Text
	temp.SideText=SideText
	temp.TextAlign =TextAlign
	
	temp.LWidth=LWidth
	temp.RWidth=RWidth
	temp.Align = Align 

	temp.RedAlertHold =1
	temp.State=False
	temp.IsDown = False
	temp.IsClean = False
	
	Return temp
End Sub
Sub LCAR_AddLCAR(Name As String,SurfaceID As Int, X As Int, Y As Int, Width As Int, Height As Int, LWidth As Int, RWidth As Int, ColorID As Int, ElementType As Int, Text As String,SideText As String , Tag As String, Group As Int, Visible As Boolean, TextAlign As Int, Enabled As Boolean, Align As Int, Alpha As Int ) As Int
	Dim temp As LCARelement
	temp=MakeLCAR(Name,SurfaceID,X,Y,Width,Height,LWidth,RWidth,ColorID,ElementType,Text,SideText,Tag,Group,Visible,TextAlign,Enabled,Align,Alpha) 
	LCARelements.Add(temp)	
	AddLCARtoGroup( LCARelements.Size-1, Group)
	Return LCARelements.Size-1
End Sub

Sub SizeToColor(Size As Int) As Int
	If Size<1025 Then
		Return LCAR_Orange
	Else If Size<13108 Then
		Return LCAR_Orange
	Else If Size<1048577 Then
		Return LCAR_Yellow
	Else If Size<13421773 Then
		Return LCAR_DarkBlue
	Else If Size<1073741825 Then
		Return LCAR_DarkYellow
	Else
		Return LCAR_DarkPurple
	End If
End Sub



Sub ClickedType(Element As ElementClicked)As String 
	If Element.Index > -1 Then
		Select Case Element.ElementType 
			Case LCAR_List: 			Return "List"
			Case LCAR_Button:			Return "Button"
			Case LCAR_Elbow:			Return "Elbow"
			Case LCAR_Textbox:			Return "Textbox"
			Case LCAR_Slider:			Return "Slider"
			Case LCAR_HorSlider: 		Return "Horizontal Slider"
			
			Case LCAR_StoppedPlaying:	Return "Sound Stopped"
			Case LCAR_Timer:			Return "Timer Tick"
			Case LCAR_StoppedMoving:	Return "Animation Stopped"
			Case LCAR_CodeChanged:		Return "Alert Condition Changed"
			Case LCAR_Meter:			Return "Meter"
			Case LCAR_SensorGrid:		Return "Sensor Grid"
			Case LCAR_Picture:			Return "Picture"
			Case LCAR_Chart:			Return "Chart"
			Case LCAR_Navigation:		Return "Navigation"
			Case LCAR_Tactical:			Return "Tactical"
			Case LCAR_Borg:				Return "Borg"
			Case LCAR_Okuda:			Return "Okudagram"
			Case LCAR_Dpad:				Return "Dpad"
			Case LCAR_Alert:			Return "Alert Condition Status"
		End Select
	Else
		Return "Nothing"
	End If
End Sub

Sub GetListItemCount(ListID As Int) As Int
	Dim lists As LCARlist
	lists=LCARlists.Get(ListID)
	Return lists.ListItems.Size 
End Sub
Sub GetListItem(ListID As Int, Col As Int, Row As Int,MakeItSelected As Boolean, IgnoreMINT As Boolean  ) As Int
	Dim lists As LCARlist ,Ret As Int , ItemsPerCol As Int, Cols As Int, Start As Int, Dimensions As tween ,ItemsOnScreen As Int
	Ret=-1
	lists=LCARlists.Get(ListID)

	Cols=LCAR_ListCols(lists.ColsLandscape,lists.ColsPortrait )
	ItemsPerCol= LCAR_ListItemsPerCol(lists.ColsLandscape, lists.ColsPortrait, lists.ListItems.Size)
	Dimensions=ProcessLoc( lists.LOC, lists.Size )
	ItemsOnScreen= LCAR_ListRows(Dimensions.offY )
	
	If lists.ListItems.Size Mod Cols > 0 Then ItemsPerCol = ItemsPerCol + 1
	If Col<0 Then Col= Cols-1
	If Col>=Cols Then Col=0
		
	If Row >-1 AND Row <= lists.LastMint OR IgnoreMINT Then
		If Row < ItemsPerCol Then
			Start= lists.Start + (ItemsPerCol * Col)
            Row = Row + Start
			If Row<Start Then
				lists.Start = lists.Start-1 
				lists.IsClean=False
			Else If Row>= Start+ItemsOnScreen Then
				lists.Start=lists.Start+1
				lists.IsClean=False
			End If
            If Row < lists.ListItems.Size Then 
				If MakeItSelected Then
					SetSelectedItem(lists,Row)
					LCARlists.Set(ListID,lists)
				End If
				Return Row
			End If
        End If
	End If
	Return Ret
End Sub

Sub LCAR_SliderState(Clicked As ElementClicked, State As Boolean)
	Dim Element As LCARelement
	'If lcarid>-1 Then
		Element = LCARelements.Get(Clicked.Index )
		If Element.Enabled Then
			Element.isdown = State
			Element.IsClean = False
			'If state Then
				Select Case Clicked.ElementType 
					Case LCAR_Slider
						Element.RWidth = (1- Clicked.Y / Clicked.Dimensions.offY)*100
						'Msgbox (clicked.Y &  CRLF & clicked.Dimensions.offY & CRLF &  (clicked.Y/clicked.Dimensions.offY) & CRLF & element.RWidth,"Slider")
					Case LCAR_HorSlider
						Element.RWidth = (1- Clicked.x / Clicked.Dimensions.offx)*100
				End Select
			'End If
		End If
		LCARelements.Set(Clicked.Index, Element)
	'End If
End Sub

Sub RespondToAll(ElementID As Int) 
	Dim Element As LCARelement 
	Element = LCARelements.Get(ElementID)
	Element.RespondToAll=True
	LCARelements.Set(ElementID,Element)
End Sub

Sub GetElement(Index As Int) As LCARelement 
	If Index>-1 AND Index< LCARelements.Size Then Return LCARelements.Get(Index)
End Sub

Sub IfRside(Clicked As ElementClicked  )
	Dim Width As Int ,X As Int ,Element As LCARelement 
	X= Clicked.X
	Width = Clicked.Dimensions.offx 
	Element=GetElement(Clicked.Index)
	'Msgbox (Element.Rwidth & CRLF & Width & CRLF & X & CRLF & (Width-Element.Rwidth), "TEST")
	Return X> (Width-Element.Rwidth )
End Sub

Sub MouseEvent(Down As Boolean , Element As ElementClicked,IsWithinBounds As Boolean, EventType As Int   )
	Dim Clicked As ElementClicked ,WasScrolling As Boolean,Radius As Int
	If Element.Index>-1 Then
		Clicked.Initialize 
		If EventType = Event_Move Then
			Clicked.X2=Element.X2
			Clicked.y2=Element.y2
		End If
		Select Case Element.ElementType
			Case LCAR_Button
				If IfRside(Element) Then  Clicked.Index2 =1 
				LCAR_State(Element.Index, Down)
				'If IfRside(Clicked , GetElement(Element.Index)) Then Element.Index2 =1 
				
			Case LCAR_List 
				Clicked.X=Element.X2'COL X
				Clicked.Y=Element.y2'ROW Y
				Clicked.X2=Element.Index2
				
				Clicked.Index2=Element.Index2
				If Down Then 
					LCAR_SetSelectedItem(Element.Index , Element.Index2)
					VisibleList=Element.Index 
					If SmoothScrolling Then Element.RespondToAll = True
				Else If EventType = Event_Up Then
					NotMoving(Element.Index)	'set list to not scrolling	
					If SmoothScrolling Then IsClean = True
				End If
				IsWithinBounds= Element.Index2>-1
				
				
			Case LCAR_Slider,LCAR_HorSlider
				LCAR_SliderState(Element, Down)
			Case LCAR_Dpad
				Radius= Min(Element.Dimensions.offX,Element.Dimensions.offY) * LCARSeffects.DpadCenter ' * 0.5
				Clicked.X2 = Element.Dimensions.offX/2
				Clicked.Y2 = Element.Dimensions.offY/2
				If Element.X >  Clicked.X2 - Radius AND Element.x < Clicked.X2+Radius AND Element.y >  Clicked.y2 - Radius AND Element.y < Clicked.y2+Radius Then
					Clicked.Index2=0
					Clicked.X2=0
					Clicked.Y2=-1
				Else
					Clicked.Index2=Trig.FindDistance(Element.Dimensions.currX + Element.Dimensions.offX/2-1, Element.Dimensions.curry + Element.Dimensions.offy/2-1, Element.Dimensions.currX + Element.X,Element.Dimensions.curry + Element.Y)
					Clicked.X2 = Trig.GetCorrectAngle(Element.Dimensions.currX + Element.Dimensions.offX/2-1, Element.Dimensions.curry + Element.Dimensions.offy/2-1, Element.Dimensions.currX + Element.X,Element.Dimensions.curry + Element.Y)
					Clicked.Y2 = Trig.FindSection(Clicked.X2)
				End If

			Case LCAR_Answer
				
				Select Case EventType
					Case Event_Up
						'ResetLCARAnswer -4=direction (0=false/red/right to left, 1=true/green/left to right), -5=value 	'LCAR_AnswerMade
						If ResetLCARAnswer(Element.Index, -4) = 0 Then'false/red/right to left
							If ResetLCARAnswer(Element.Index,-5)<=5 Then PushEvent(LCAR_AnswerMade,Element.Index,0, 0,0,0,0, Event_Up)
						Else
							If ResetLCARAnswer(Element.Index,-5)>=95 Then PushEvent(LCAR_AnswerMade,Element.Index,1, 0,0,0,0, Event_Up)
						End If
						ResetLCARAnswer(Element.Index,-1)
					
					Case Event_Down
						If Element.X <= MinWidth Then
							ResetLCARAnswer(Element.Index, -2)
						Else If Element.X > Element.Dimensions.offX-MinWidth Then
							ResetLCARAnswer(Element.Index, -3)
						End If
					
					Case Event_Move
						Element.X = Element.X+Clicked.x2
						If Element.X<= MinWidth Then
							Radius=0
						Else If Element.x >=Element.Dimensions.offX-MinWidth Then
							Radius=100
						Else
							Radius = (Element.x-MinWidth) / (Element.Dimensions.offX-(MinWidth*2)) * 100
						End If
						ResetLCARAnswer(Element.Index,Radius)
						
				End Select
				'debug(EventType & " " & Element.X)
			Case LCAR_MultiLine, LCAR_Textbox
				Select Case EventType
					Case Event_Down:	HandleTextboxMouse(Element.Index, Element.ElementType, EventType, Element.X,Element.Y)
					Case Event_Move:	HandleTextboxMouse(Element.Index, Element.ElementType, EventType, Element.X2,Element.Y2)
				End Select
				
			Case Else
				LCAR_State(Element.Index, Down)
		End Select
		If (Not(Down) AND IsWithinBounds) OR Element.RespondToAll Then' OR multitouchenabled  Then			'must uncomment when GestureLibrary works again
			'IsWithinBounds not suitable for small screens
			Clicked.EventType=EventType
			Clicked.ElementType= Element.ElementType
			Clicked.Index=Element.Index
			
			EventList.Add(Clicked)
		End If
	End If
End Sub

'use -999 for all elementypes
Sub NukeQueue(ElementType As Int)
	Dim temp As Int ,Clicked As ElementClicked 
	If ElementType = -999 Then
		EventList.Initialize 
	Else
		For temp = EventList.Size-1 To 0 Step -1 
			Clicked=EventList.Get(temp)
			If Clicked.ElementType=ElementType Then 
				EventList.RemoveAt(temp)
			End If
		Next
	End If
End Sub
Sub PushEvent(ElementType As Int,Index As Int,Index2 As Int,X As Int, Y As Int, X2 As Int, Y2 As Int, EventType As Int )
	Dim Clicked As ElementClicked 
	Clicked.Initialize
	Clicked.ElementType= ElementType
	Clicked.Index=Index
	Clicked.Index2=Index2
	Clicked.X =X
	Clicked.X2 =X2
	Clicked.Y =Y
	Clicked.Y2 =Y2
	Clicked.EventType=EventType
	EventList.Add(Clicked) 
End Sub

Sub LCAR_GetListitemText(ListID As Int, Item As Int, TextIs0SidetextIs1TagIs2 As Int ) As String
	Dim Lists As LCARlist , Listitem As LCARlistitem 
	Lists = LCARlists.Get(ListID)
	If Item <0 Then Item = Lists.SelectedItem 
	If Item< Lists.listitems.Size AND Item>-1 Then
		Listitem = Lists.ListItems.Get(Item)
		Select Case TextIs0SidetextIs1TagIs2
			Case 0: Return Listitem.Text 
			Case 1: Return Listitem.Side 
			Case 2: Return Listitem.Tag 
		End Select
	End If
End Sub
Sub LCAR_SetListitemText(ListID As Int, Item As Int, Text As String, Side As String) 
	Dim Lists As LCARlist , Listitem As LCARlistitem 
	Lists = LCARlists.Get(ListID)
	Listitem = Lists.ListItems.Get(Item)
	If Text <> LCAR_IGNORE Then Listitem.Text=Text
	If Side <> LCAR_IGNORE Then Listitem.Side = Side
	'Lists.ListItems.Set(Item,Listitem)
	'LCARlists.Set(ListID,Lists)
End Sub
Sub LCAR_SetElementText(ElementID As Int, Text As String, Side As String)
	Dim Element As LCARelement 
	'If ElementID<LCARelements.Size Then
		Element = LCARelements.Get(ElementID)
		Element.IsClean =False
		If Text <> LCAR_IGNORE Then Element.Text=Text
		If Side <> LCAR_IGNORE Then Element.SideText = Side
		'LCARelements.Set(ElementID,Element)
	'End If
End Sub

Sub DirtyListItem(Lists As LCARlist, Listindex As Int, ToggleSelected As Boolean, SetOff As Boolean, SetOn As Boolean  )
	Dim ListItem As LCARlistitem ,WasSelected As Boolean 
	If Listindex>-1 AND Listindex< Lists.ListItems.Size Then
		ListItem=Lists.ListItems.Get(Listindex)
		ListItem.IsClean = False
		If Lists.MultiSelect AND ToggleSelected Then 
			WasSelected= ListItem.Selected 
			ListItem.Selected = Not(ListItem.Selected)
			If WasSelected AND Not(ListItem.Selected) Then
				Lists.SelectedItems= Lists.SelectedItems-1
				If Lists.SelectedItem = Listindex Then Lists.SelectedItem=-1
			Else If ListItem.Selected AND Not(WasSelected) Then
				Lists.SelectedItems= Lists.SelectedItems+1
				Lists.SelectedItem = Listindex
			End If
		Else
			If ToggleSelected Then SetOn= Not( ListItem.Selected)
			SelectNone(Lists)
			If SetOn Then
				ListItem.Selected =True
				ListItem.IsClean= False
				Lists.SelectedItem = Listindex
				Lists.SelectedItems=1
			End If
		End If
		Lists.ListItems.Set(Listindex,ListItem)
	End If
End Sub 
Sub SelectNone(Lists As LCARlist)
	Dim ListItem As LCARlistitem ,temp As Int
	For temp = 0 To Lists.ListItems.Size-1
		ListItem=Lists.ListItems.Get(temp)
		If ListItem.Selected Then
			ListItem.Selected = False
			ListItem.IsClean = False
		End If
		Lists.ListItems.Set(temp,ListItem)
	Next
	Lists.SelectedItems=0
	Lists.SelectedItem=-1
End Sub
Sub SetSelectedItem(Lists As LCARlist, ListIndex As Int)
	DirtyListItem(Lists,Lists.SelectedItem, False,False,False )
	Lists.SelectedItem = ListIndex
	DirtyListItem(Lists,Lists.SelectedItem,True,False,False)
End Sub




Sub LCAR_DpadList(ListID As Int, Direction As Int)As Boolean 
	Dim lists As LCARlist
	If ListID>-1 AND ListID < LCARlists.Size Then
		If IsListVisible(ListID) Then
			lists = LCARlists.Get(ListID)
			If Direction = -1 Then' center
				If lists.SelectedItem>-1 Then
					PushEvent(LCAR_List, ListID, lists.SelectedItem, lists.SelectedXY.X, lists.SelectedXY.Y, lists.SelectedItem, 0, Event_Up)
				End If
			Else
				If lists.SelectedItem=-1 Then
					SetSelectedItem(lists,0)
					LCARlists.Set(ListID, lists)
				Else
					Select Case Direction
						Case 0:GetListItem(ListID, lists.SelectedXY.X, lists.SelectedXY.Y-1, True,True) 'up
						Case 1:GetListItem(ListID, lists.SelectedXY.X+1, lists.SelectedXY.Y, True,True) 'right
						Case 2:GetListItem(ListID, lists.SelectedXY.X, lists.SelectedXY.Y+1, True,True) 'down
						Case 3:GetListItem(ListID, lists.SelectedXY.X-1, lists.SelectedXY.Y, True,True) 'left
					End Select
				End If
			End If
			Return True
		End If
	End If
End Sub

Sub LCAR_SetSelectedItem(ListID As Int, SelectedItem As Int)
	Dim lists As LCARlist
	lists= LCARlists.Get(ListID)
	SetSelectedItem(lists,SelectedItem)
	LCARlists.Set(ListID,lists)
End Sub

Sub GroupVisible(GroupID As Int ) As Boolean 
	Dim group As LCARgroup 
	If LCARGroups.IsInitialized Then 
		If GroupID>-1 AND GroupID< LCARGroups.Size Then
			group=LCARGroups.get(GroupID)
			Return group.Visible 
		End If
	End If
	Return False
End Sub

Sub LimitOffset(Value As Int) As Int
	Dim Limit As Int 
	Limit=ItemHeight+ListitemWhiteSpace
	If Value < -Limit  Then
		Do Until Value>=-Limit
			Value=Value+Limit
		Loop
	Else If Value> 0 Then 
		Do Until Value<0
			Value=Value-Limit
		Loop
	End If
	Return Value
End Sub

Sub DoesSmoothlyScroll(Lists As LCARlist)
	Select Case Lists.Style 
		Case LCAR_Button: Return True
	End Select
End Sub

Sub GetListItemHeight(Lists As LCARlist) As Int   
	Dim Dimensions As tween, Cols As Int, ColWidth As Int 
	Select Case Lists.Style 
		Case LCAR_Meter, LCAR_MiniButton,Legacy_Button,Klingon_Button,LCAR_List
			Dimensions = ProcessLoc(Lists.LOC, Lists.Size)
	End Select
	Select Case Lists.Style 
		Case LCAR_Button: Return ItemHeight+ListitemWhiteSpace
		Case LCAR_Chart, LCAR_ChartNeg: Return ChartHeight + ChartSpace
		Case PCAR_Button: Return (50*ScaleFactor)+ ListitemWhiteSpace	
		Case LCAR_Meter		
			ColWidth=(ChartSpace + MeterWidth)
			Cols=Floor( Dimensions.offX  / ColWidth)
			If Lists.ListItems.Size > Cols Then Return Dimensions.offY  / Ceil(Lists.ListItems.Size / Cols)' Else Return Dimensions.offY 
		'Case LCAR_MiniButton,Legacy_Button,Klingon_Button,TOS_Button,LCAR_List, CHX_Iconbar: Return Dimensions.offY 
	End Select
	Return Dimensions.offY 
End Sub

Sub GesturesTouch(SurfaceID As Int, G As Gestures, PointerID As Int, Action As Int, X As Float, Y As Float) As Boolean
	'GestureMap As List GesturePoint
	Dim Point As GesturePoint ,Element As ElementClicked,Act As String ,ret As Boolean ,lists As LCARlist 
	Select Action
		Case G.ACTION_DOWN, G.ACTION_POINTER_DOWN
			'New Point is assigned to the new touch
			Act="DOWN"
			Point.Id = PointerID
			Element = FindClickedElement(SurfaceID, X,Y,True)
			Point.Element = Element 
			GestureMap.Add(Point)
			MouseEvent(True, Element, True, Event_Down)
			ret=True
		Case  G.ACTION_POINTER_UP, G.ACTION_UP
			'remove id
			If PointerID< GestureMap.Size Then
				Act="UP"
				Point = GestureMap.Get(PointerID)
				GestureMap.RemoveAt(PointerID)
				ret=True
				
				If Point.Element.Index>-1 Then
					MouseEvent(False, Point.Element, IsWithin(X, Y, Point.Element.Dimensions.currX, Point.Element.Dimensions.currY, Point.Element.Dimensions.offX,Point.Element.Dimensions.offY, False), Event_Up)
				End If
			End If
			If Action = G.ACTION_UP Then GestureMap.Clear		
		Case G.ACTION_MOVE 
			Act="MOVE"
			If PointerID< GestureMap.Size Then
				Point = GestureMap.Get(PointerID)
				Select Case Point.Element.ElementType
					Case LCAR_List 
							Element = FindClickedElement(-1-Point.Element.Index , X,Y,False)

							If Element.Y2 <> Point.Element.y2 Then
								If Not( lists.IsInitialized) Then  lists = LCARlists.Get(Point.Element.Index)
								If Point.Element.Index2>=-1 Then
									If Not (lists.Locked) Then lists.SelectedItem = -1
									Point.Element.Dimensions.Initialize 
									DirtyListItem(lists, Point.Element.Index2, True,True,False)
									If Not (lists.Locked) Then Point.Element.Index2=-1
									GestureMap.Set(PointerID, Point)
								End If
								
								If Not (lists.Locked) Then
									'MouseEvent(False, point.Element, False)
									lists.isScrolling = True
									lists.IsClean = False
									'debug("SCROLL: " & Point.Element.y2 & " " & Element.Y2)
									LimitStart(lists, Point.Element.y2-Element.Y2, False)
									Point.Element.y2=Element.Y2
								End If
								'lists.Start = lists.Start + (element.Y2-point.Element.y2)
								ret=True
							End If

							If SmoothScrolling Then
								If Not(lists.IsInitialized) Then lists = LCARlists.Get(Point.Element.Index)					
								Dim temp As Int = GetListItemHeight(lists) 'LCAR_Button  ItemHeight+ListitemWhiteSpace
								If lists.Style=0 Then
									lists.Offset = 0 
									If lists.isScrolling OR lists.Ydown <>0 Then
										If lists.Start>0 Then 'If Not( LimitStart(lists,0) ) Then
											'Log(Y & " : " & Point.Element )
											If Element.dimensions.OffY = 0 Then Element.Dimensions = ProcessLoc(lists.LOC, lists.Size)
											'lists.Offset = Abs(Y- Point.Element.Y) * -1 Mod (ItemHeight+ListitemWhiteSpace)
											'Log(Y & " " & temp & " " &  Element.Dimensions)
											lists.Offset =  (Y - Element.dimensions.currY) Mod temp 'LimitOffset(y -lists.Ydown)
											'Log("B: " & lists.Offset)
											lists.Offset = -temp + lists.Offset
											'Log("A: " & lists.Offset)
											lists.IsClean = False
										End If
									End If
									lists.Ydown=Y
									ret=True
								End If
								'Log(SmoothScrolling & " " & temp & " " & lists.Offset)
							End If
							
							
					Case LCAR_Slider,LCAR_HorSlider
						Element = Point.Element' FindClickedElement(-1-Point.Element.Index, x,y,False)
						Element.X2=X-OldX
						Element.Y2=Y-OldY
						Element.X = Element.X + Element.X2
						Element.Y = Element.Y + Element.Y2
						Element.RespondToAll=True
						MouseEvent(True, Element, True, Event_Move)
'					Case Klingon_Frame
'						Log("MOVE AT " & Element.X & ", " & Element.Y)
'						Games.TRI_HandleMouse(Element.X,Element.Y,Event_Move)
'						
					Case Else
						If Point.Element.RespondToAll Then
							Point.Element.X2=X-OldX
							Point.Element.Y2=Y-OldY
							MouseEvent(True, Point.Element, True, Event_Move)
						End If
				End Select
			End If
	End Select
	'debug(act & " " & PointerID & " (" & x & "," & y & ")")
	OldX=X
	OldY=Y
	Return ret
End Sub
Sub LimitStart(Lists As LCARlist, ScrollBy As Int, RetIfEqualTo As Boolean)As Boolean
	Dim MAXLIMIT As Int = Max(0, LCAR_ListItemsPerCol(Lists.ColsLandscape, Lists.ColsPortrait, Lists.ListItems.Size)-Lists.LastMint+2), Ret As Boolean 
	Lists.Start = Max(0,Lists.Start + ScrollBy)
	'If Lists.Start<0 Then Lists.Start=0
	'If Lists.Start> Lists.LastMint Then Lists.Start=Lists.LastMint 
	'Log("SCROLLING " & ScrollBy)
	'MAXLIMIT=Lists.ListItems.Size-Lists.LastMint
	If RetIfEqualTo Then
		'Log(Lists.start & " - " &  MAXLIMIT)
		If Lists.start >= MAXLIMIT-2 Then Ret=True
	End If
	
	
	If Lists.Start > MAXLIMIT Then
		Lists.Start=MAXLIMIT
		'Lists.Offset=0
		Return True
	End If
	Return Ret
End Sub


Sub DrawLCARSGrid(BG As Canvas, X As Long, Y As Long, Width As Long, Height As Long, oX As Long, oY As Long, ColorID As Int, Angle As Float )
	Dim OvalHeight As Int, OvalWidth As Int , tX As Int, tY As Int , W2 As Int, H2 As Int,temp As Int 
	If SmallScreen Then OvalHeight=10 Else OvalHeight=20
	OvalWidth=OvalHeight*2
	
	W2=Width-OvalWidth'*2
	H2=Height-OvalWidth'*2
	
	tX=Max(5, oX)/100 * W2
	tY=Max(5, oY)/100 * H2
	
	BG.DrawRect( SetRect(X,Y,Width,Height), Colors.Black, True ,0)
	DrawLCARSensorGrid(BG,  X+OvalWidth ,Y+OvalWidth, W2,H2, tX,tY, ColorID, Angle)
	
	temp=OvalHeight*1.5
	BG.DrawOval(SetRect( X,Y+tY+temp, OvalWidth,OvalHeight), Colors.white,True,0)
	'BG.DrawOval(SetRect( X+Width-OvalWidth,Y+tY+temp, OvalWidth,OvalHeight), Colors.white,True,0)
	
	BG.DrawOval(SetRect( X+tX+temp,Y,OvalHeight, OvalWidth), Colors.white,True,0)
	'BG.DrawOval(SetRect( X+tX+temp,Y+Height-OvalWidth,OvalHeight, OvalWidth), Colors.white,True,0)
End Sub

Sub DrawLCARSensorGrid(BG As Canvas, X As Long, Y As Long, Width As Long, Height As Long, oX As Long, oY As Long, ColorID As Int, Angle As Float )
    Dim Cx As Double, CWidth As Double,  color As LCARColor ,temp As Int,Width2 As Int, Height2 As Int
	Dim StartSize As Float , Factor As Float, Border As Int
	StartSize= 0.1:Factor = 0.95:Border = 2
	If RedAlert Then ColorID= LCAR_RedAlert
	color = LCARcolors.Get(ColorID)
	ColorID= color.normal' getcolor(colorid, False,255)

	BG.DrawRect( SetRect(X + Border, Y + Border, Width - Border * 2, Height - Border * 2), ColorID, True,0)
	BG.DrawRect( SetRect(X + Border, Y + Border, Width - Border * 2, Height - Border * 2), Colors.White, False,Border)
    
	'Height2=width2*0.5
	temp=color.Selected
	If RedAlert Then temp = HalfWhite
	If Width<Height Then 
		Width2=Trig.MaxSizeOfOval2(Width, Height, Angle+90)*0.9
	Else 
		Width2= Height
	End If
	'Width2=Trig.MaxSizeOfOval2(Width, Height, Angle+90)*0.9
	Height2=Width2*0.5
	'debug(cwidth)
	BG.DrawOvalRotated(SetRect(X+Width/2-Width2/2,Y+Height/2-Height2/2,Width2,Height2), temp, True, 0,  Angle)'0=east instead of north
	
    CWidth = StartSize * oX
    Cx = oX + X
	BG.DrawRect(SetRect(Cx, Y + 1, 1, Height - 2), Colors.White,False,3)
	BG.DrawRect(SetRect(X + 1, oY + Y, Width - 2, 1), Colors.White,False,3)
    
    temp = X + Border
    Do While Cx > temp
        CWidth = Max(2, CWidth * Factor)
        Cx = Cx - CWidth
        If Cx > X Then BG.DrawRect(SetRect(Cx, Y, 1, Height), Colors.White,False,1)
        If CWidth < 2 Then Cx = 0'exit loop
    Loop
    
    CWidth = StartSize * (Width - oX)
    Cx = oX + X
    temp = X + Width - Border
    Do While Cx < temp
        CWidth = Max(2, CWidth * Factor)
        Cx = Cx + CWidth
        If Cx < temp Then BG.DrawRect(SetRect(Cx, Y, 1, Height), Colors.White,False,1) 
        If CWidth < 2 Then Cx = X + Width'exit loop
    Loop
    
    CWidth = StartSize * oY
    Cx = oY + Y
    temp = Y + Border
    Do While Cx > temp
       CWidth = Max(2, CWidth * Factor)
        Cx = Cx - CWidth
        If Cx > temp Then  BG.DrawRect(SetRect(X, Cx, Width, 1), Colors.White,False,1) 
        If CWidth < 2 Then Cx = 0'exit loop
    Loop
    
    CWidth = StartSize * (Height - oY)
    Cx = oY + Y
    temp = Y + Height - Border
    Do While Cx < temp
        CWidth = Max(2, CWidth * Factor)
        Cx = Cx + CWidth
        If Cx < temp Then BG.DrawRect(SetRect(X, Cx, Width, 1), Colors.White,False,1) 
        If CWidth < 2 Then Cx = temp'exit loop
    Loop
End Sub

Sub GetList(ListID As Int) As LCARlist 
	Return LCARlists.Get(ListID)
End Sub
Sub IsListVisible(ListID As Int)As Boolean 
	If ListID< LCARVisibleLists.Size Then Return LCARVisibleLists.Get(ListID) 'GetList(ListID).Visible 
End Sub 
Sub SelectNextVisibleList
	Dim temp As Int 
	For temp = 0 To LCARVisibleLists.Size-1
		If temp <> VisibleList Then
			If LCARVisibleLists.Get(temp) Then
				VisibleList =temp
			End If
		End If
	Next
End Sub
Sub DirtyElement (ElementID As Int) 
	Dim temp As LCARelement 
	If ElementID<LCARelements.Size Then
		temp = LCARelements.Get(ElementID)
		If temp.Visible Then
			temp.IsClean=False
			'LCARelements.Set(ElementID,temp)
		End If
	End If
End Sub





Sub GetSelectedText As String 
	Return LCAR_GetElement(KBCancelID+5).Text
End Sub

Sub HideSideBar(BG As Canvas,ListID As Int ,TheStage As Int)
	If ListID = -1 Then 
		LCAR_HideElement(BG, LCAR_Sidebar, True,False,True)
	Else
		LCAR_ClearList(LCAR_Sidebar,0)
		LCARSeffects.frameoffset=0
		LCARSeffects.NeedsRedrawFrame=True
		LCAR_HideElement(BG, LCAR_Sidebar, True,False,True)
		LCARSeffects.ShowFrame(BG, False, True, TheStage)
	End If
End Sub
Sub HideButtonBar(BG As Canvas)
	If ButtonList>-1 Then LCAR_HideElement(BG, ButtonList, True,False,True)
End Sub
'Sub SeedButtonBar(BG As Canvas, Items As List)
'	Dim Height As Int, Y As Int ,Width As Int
'	Height=ButtonBarHeight
'	LCAR_ClearList(ButtonList,0)
'	LCAR_AddListItems(ButtonList, LCAR_Random,0,  Items)
'	'bottom = 72,145
'	Y=BG.MeasureStringHeight("TEST", LCARfont, BigTextboxHeight)+ ChartSpace'height of text box
'	Height=Height- Y - ChartSpace
'	Width=Min((Height*1.5) * Items.Size, Min(ScaleWidth,ScaleHeight)- API.iif(SmallScreen,53,103))
'	ResizeList(ButtonList, Width,Height, -1, -Width-ChartSpace, Y, True)
'	LCAR_HideElement(BG, ButtonList,True,True,False)
'	RemoveAnimation(ButtonList,True)
'End Sub 
'Sub ButtonBarHeight As Int
'	If ButtonList=-1 Then ButtonList = LockListStart(LCAR_AddList("ButtonBar", 0, 0,0, -100,0, 100,50, False, 0, 0,0, False,False,False, LCAR_MiniButton), True)
'	Return API.IIF(SmallScreen,72,145)
'End Sub

Sub SeedButtonBar(BG As Canvas, Items As List)
	Dim Height As Int, Y As Int ,Width As Int
	Height=ButtonBarHeight
	LCAR_ClearList(ButtonList,0)
	LCAR_AddListItems(ButtonList, LCAR_Random,0,  Items)
	'bottom = 72,145
	Y=BG.MeasureStringHeight("TEST", LCARfont, BigTextboxHeight)+ ChartSpace'height of text box
	Height=Height- Y - ChartSpace
	Width=Min((Height*1.5) * Items.Size, Min(ScaleWidth,ScaleHeight)- GetScaledPosition(3,True))' API.iif(SmallScreen,53,103))
	ResizeList(ButtonList, Width,Height, -1, -Width-ChartSpace, Y, True)
	LCAR_HideElement(BG, ButtonList,True,True,False)
	RemoveAnimation(ButtonList,True)
End Sub 
Sub ButtonBarHeight As Int
	If ButtonList=-1 Then ButtonList = LockListStart(LCAR_AddList("ButtonBar", 0, 0,0, -100,0, 100,50, False, 0, 0,0, False,False,False, LCAR_MiniButton), True)
	Return GetScaledPosition(0,False)' API.IIF(SmallScreen,72,145)
End Sub


Sub SeedSideBar(BG As Canvas, ListID As Int, Items As List,DoAnimation As Boolean, LeftBar As Boolean ,TheStage As Int) As Boolean 
	Dim Lists As LCARlist , Width As Int = 100, Y As Int = 256
	If SmallScreen Then 
		Width = 50
		Y=132
	Else If CrazyRez>0 Then 
		Width= Width*CrazyRez
		Y= GetScaledPosition(4,False)'  (CrazyRez*250)+LCARSeffects.frameoffset'    503
	End If
	
	LCAR_Sidebar=ListID
	LCAR_ClearList(ListID,0)
	LCARSeffects.NeedsRedrawFrame=True
	LCAR_AddListItems(ListID, LCAR_Random,0,  Items)
	LockListStart(ListID,True)
	LCAR_SetSelectedItem(ListID,0)
	LCARSeffects.frameoffset=ListItemsHeight(Items.size)
	ResizeList(ListID,  Width+ListitemWhiteSpace, LCARSeffects.frameoffset, -1,0,Y, True)
	LCARSeffects.ShowFrame(BG, DoAnimation, LeftBar, TheStage)
	LCAR_HideElement(BG, ListID,True,True,False)
	
	Lists = LCARlists.Get(ListID)
	Lists.Opacity.Current=0
End Sub
'Sub SeedSideBar(BG As Canvas, ListID As Int, Items As List,DoAnimation As Boolean, LeftBar As Boolean ,TheStage As Int) As Boolean 
'	LCAR_ClearList(ListID,0)
'	LCAR_Sidebar=ListID
'	LCARSeffects.NeedsRedrawFrame=True
'	LCAR_AddListItems(ListID, LCAR_Random,0,  Items)
'	LockListStart(ListID,True)
'	LCAR_SetSelectedItem(ListID,0)
'	LCARSeffects.frameoffset=ListItemsHeight(Items.size)
'	ResizeList(ListID, API.IIF(SmallScreen, 53,103), LCARSeffects.frameoffset, -1,0,API.IIF(SmallScreen, 132,256), True)
'	LCARSeffects.ShowFrame(BG, DoAnimation, LeftBar, TheStage)
'	LCAR_HideElement(BG, ListID,True,True,False)
'End Sub

Sub IsNumboardVisible As Boolean 
	Return IsListVisible(NumListID) AND NumListID>0
End Sub
Sub MakeNumBoard(SurfaceID As Int, Group As Int, Settings As Map )
	'NumListID as Int, NumButtonID as Int, NumGroup as int
	'0,1,2,3,4,5,6,7,8,9, next, prev, left, right, delete, backspace, ok, cancel
	
	Dim X As Int, Y As Int, Width As Int, Height As Int , MidHeight As Int, MidWidth As Int
	X=0'105
	Y=400
	Width=200
	Height=( 4*(ItemHeight+ListitemWhiteSpace))
	
	
	NumGroup=Group
	NumListID= LCAR_AddList("Numboard",  SurfaceID,  3  ,3,  X+110,Y+ItemHeight+5, Width ,Height,  False,  -1, leftside, leftside,  True, False,False ,0 )
	SetAlignment(NumListID,5)
	LockListStart(NumListID,True)
	
	Dim Keys As List, temp As Int 
	Keys.Initialize2(Array As String("7", "4", "1", "0", "8", "5", "2", "<ı", "9", "6", "3", "ı>"))
	For temp = 0 To Keys.Size-1
		LCAR_AddListItem(NumListID, Keys.Get(temp), LCAR_Random, API.GetKeyCode(Keys.Get(temp),False, False)    , "", False, "", 0,False,-1)
	Next
	
	MidHeight=Height/2 + ItemHeight+2
	MidWidth=(Width-20)/2-2
	NumButtonID=LCAR_AddLCAR("NumCancel", SurfaceID,  X,Y, 130,MidHeight,100  ,ItemHeight, LCAR_Orange, LCAR_Elbow ,"CANCEL","","", Group,   True, 8,  True,0, 0)
		LCAR_AddLCAR("NumBKSP", SurfaceID,  X+133,Y, MidWidth,ItemHeight,0 ,0, LCAR_Orange, LCAR_Button ,"BKSP","","", Group,   True, 5,  True,0,  0)'+1
		LCAR_AddLCAR("NumDEL", SurfaceID,  X+136+MidWidth,Y, MidWidth,ItemHeight,0 ,0, LCAR_Orange, LCAR_Button ,"DEL","","", Group,   True, 5,  True,0,  0)'+2
		LCAR_AddLCAR("NumDELIP", SurfaceID,  X+139+MidWidth*2,Y, -1,ItemHeight,0 ,0, LCAR_Orange, LCAR_Button ,"DELETE IP","","", Group,   True, 5,  True,0,  0)'+3
	
	LCAR_AddList("NumboardIPs",  SurfaceID, 1  ,1, X+139+MidWidth*2,Y+ItemHeight+5, 0 , Height,  False,  -1,0, 0, False, False,False ,0 )
	LoadIPs(NumListID+1, Settings )
	
	LCAR_AddLCAR("NumOK", SurfaceID,  X,Y+MidHeight+3, 130,MidHeight,100  ,ItemHeight, LCAR_Orange, LCAR_Elbow ,"OK","","", Group,  True, 2,  True,2,  0)'+4
		LCAR_AddLCAR("NumPREV", SurfaceID,  X+133,Y+Height+ItemHeight+7, MidWidth,ItemHeight,0 ,0, LCAR_Orange, LCAR_Button ,"PREV","","", Group,   True, 5,  True,0,  0)'+5
		LCAR_AddLCAR("NumNEXT", SurfaceID,  X+136+MidWidth,Y+Height+ItemHeight+7, MidWidth,ItemHeight,0 ,0, LCAR_Orange, LCAR_Button ,"NEXT","","", Group,   True, 5,  True,0,  0)'+6
		LCAR_AddLCAR("NumSAVE", SurfaceID,  X+139+MidWidth*2,Y+Height+ItemHeight+7, -1,ItemHeight,0 ,0, LCAR_Orange, LCAR_Button ,"SAVE IP","","", Group,   True, 5,  True,0,  0)'+7
	
	LCAR_AddLCAR("NumText1", SurfaceID,  105, 16,  -1 , 16 , -1,0,LCAR_Orange, LCAR_Textbox , "192.", "", "",   Group, False,    1, False, 0,0)'+8
		LCAR_AddLCAR("NumText2", SurfaceID,  120, 0,  -1 , BigTextboxHeight , 0,3,LCAR_Orange, LCAR_Textbox , "168", "", "",   Group, False,    1,True, 0,0)'+9
		LCAR_AddLCAR("NumText3", SurfaceID,  140, 16,  -1 , 16 ,-1,0,LCAR_Orange, LCAR_Textbox , ".0.1:3030", "", "",   Group, False,    1,False, 0,0)'+10
		
	LCAR_Blink(NumButtonID+9,True)
End Sub
Sub LoadIPs(ListID As Int, Settings As Map) 
	Dim temp As Int, Count As Int
	Count = Settings.GetDefault("SaveIPs", 0)
	For temp = 0 To Count-1
		LCAR_AddListItem(ListID, Settings.Get("SavedIP" & temp), LCAR_Random, -1, "", False, "", 0, False,-1)
	Next
End Sub
Sub LoadIP(BG As Canvas, Index As Int, Settings As Map, CurrentPort As Int )As IPaddress 
	Dim IP As IPaddress  
	SelectedIP = Index 
	IP = API.ParseIP(Settings.Getdefault("SavedIP" & Index, "0.0.0.0"))
	IP.Port = CurrentPort
	If IP.Octets(0) = 0 Then 
		Return IP
	Else
		Return ResizeNumboard(BG, IP, 4,True)
	End If
End Sub
Sub GetSavedIP(IP As String, Settings As Map) As Int 
	Dim temp As Int, Count As Int
	Count = Settings.GetDefault("SaveIPs", 0)
	For temp = 0 To Count-1
		If IP.EqualsIgnoreCase(Settings.Get("SavedIP" & temp)) Then Return temp
	Next
	Return -1
End Sub

Sub SaveIP(IP As IPaddress, Settings As Map) As Boolean 
	Dim Count As Int, IPA As String 
	Count = Settings.GetDefault("SaveIPs", 0)
	IPA=API.GetIP(IP,False)  '
	If GetSavedIP( IPA,Settings )=-1 Then
		LCAR_AddListItem(NumListID+1, IPA, LCAR_Random, -1, "", False, "", 0, False,-1)
		Settings.Put("SavedIP" & Count , IPA)
		Settings.put("SaveIPs", Count+1)
		Return True
	End If
End Sub 
Sub DeleteIP(Index As Int, Settings As Map) As Boolean 
	Dim temp As Int, Count As Int
	Count = Settings.GetDefault("SaveIPs", 0)
	If Index>-1 Then
		LCAR_RemoveListitem(NumListID+1,Index)
		For temp = Index To Count-2
			Settings.put("SavedIP" & temp,  Settings.Get("SavedIP" & (temp+1) ) )
		Next
		Count=Count-1
		Settings.put("SaveIPs", Count)
		Settings.Remove("SavedIP" & Count)
	End If
	If SelectedIP =Index Then SelectedIP =-1
End Sub

Sub ResizeNumboard(BG As Canvas, IP As IPaddress, SelectedOctet As Int, SelectAll As Boolean )As IPaddress 
	Dim tempstr As StringBuilder ,temp As Int, temp2 As Int, tempstr2 As String ,oldsize As Int , startofmiddle As Int,tempstr3 As StringBuilder ,X As Int
	SelectedOctet= Min(4,SelectedOctet)
	temp2=SelectedOctet
	tempstr.Initialize 
	tempstr3.Initialize 
	X=105

	If temp2>3 Then 
		'temp2=3
		tempstr2=  IP.Port
	Else
		tempstr2 = IP.Octets(SelectedOctet)
		For temp = SelectedOctet+1 To 3
			tempstr3.Append ("." & IP.Octets(temp) )
		Next
		tempstr3.Append(":" & IP.Port)
	End If
	For temp = 0 To temp2-1
		tempstr.Append( IP.Octets(temp))
		If temp < 3 Then tempstr.Append (".") Else tempstr.Append(":")
	Next
	
	'text before the selected octet
	LCAR_SetElementText( NumButtonID+8,tempstr.ToString, "")
	temp=TextWidth(BG, tempstr.ToString )
	ForceElementData( NumButtonID+8,  X, 16, 0,0, temp,16,0,0,0,255,True,False)
	
	'Selected Octet
	startofmiddle=X+ temp
	ForceElementData(NumButtonID+9, startofmiddle,0,0,0,20,BigTextboxHeight,0,0,255,255,True,False)
	LCAR_SetElementText( NumButtonID+9,tempstr2, "")
	If SelectAll Then API.SelectAll(NumButtonID+9)
	
	oldsize=Fontsize
	Fontsize=BigTextboxHeight
	startofmiddle=startofmiddle+ TextWidth(BG, tempstr2)+2
	Fontsize=oldsize
	
	ForceElementData(NumButtonID+10, startofmiddle, 16, 0,0, TextWidth(BG, tempstr3.ToString) ,16, 0,0,255,255,True,False)
	LCAR_SetElementText( NumButtonID+10,tempstr3.ToString, "")
	
	'startofmiddle=startofmiddle+ textwidth(bg, tempstr3.ToString)
	BG.DrawRect( SetRect(X,0,200,40),Colors.Black,True,1)
	
	IP.SelectedOctet = SelectedOctet
	Return IP 
End Sub

Sub ShowNumBoard(Bg As Canvas,IP As IPaddress )
	Dim X As Int, Y As Int, Width As Int, Height As Int , MidHeight As Int, MidWidth As Int ,OFF As Int, BarWidth As Int,Element As LCARelement 
	X=0'105
	Y=40
	Width=200
	BarWidth=100
	If SmallScreen Then BarWidth = 50
	Height=( 4*(ItemHeight+ListitemWhiteSpace))
	MidHeight=Height/2 + ItemHeight+2
	MidWidth=(Width-20)/2-2

	RandomizeColors(NumListID)
	ResizeList(NumListID, Width ,0 ,-1, X+BarWidth+10,Y+Height, True)
	LCAR_HideElement(Bg, NumListID, True, True,False )
	ResizeList(NumListID, Width ,Height ,-1, X+BarWidth+10,Y+ItemHeight+5,True)
	
	RandomizeColors(NumListID+1)
	ResizeList(NumListID+1, 0 ,0 , -1, X+BarWidth+39+MidWidth*2,Y+Height, True)
	LCAR_HideElement(Bg, NumListID+1, True, True,False)
	ResizeList(NumListID+1, 0 ,Height ,-1,X+BarWidth+39+MidWidth*2,Y+ItemHeight+5,True)
	
	HideGroup(NumGroup, True,  True)
	ResizeNumboard(Bg, IP, 1,True)
	
	OFF=MidHeight-ItemHeight
	ForceElementData(NumButtonID, X,Y, 0, OFF, BarWidth+30,MidHeight,0,-OFF,0,255,True,True)'CANCEL
	ForceElementData(NumButtonID+1,X+BarWidth+33,Y,0,OFF,MidWidth,ItemHeight,0,0,0,255,True,True)'BKSP
	ForceElementData(NumButtonID+2,X+BarWidth+36+MidWidth,Y,0,OFF,MidWidth,ItemHeight,0,0,0,255,True,True)'DEL
	ForceElementData(NumButtonID+3,X+BarWidth+39+MidWidth*2,Y,0,OFF,0,ItemHeight,0,0,0,255,True,True)'DELETE IP
	
	ForceElementData(NumButtonID+4, X,Y+MidHeight+3, 0,0, BarWidth+30,MidHeight,0,-OFF,0,255,True,True)'OK
	ForceElementData(NumButtonID+5,X+BarWidth+33,Y+Height+ItemHeight+7,0,-OFF,MidWidth,ItemHeight,0,0,0,255,True,True)'PREV
	ForceElementData(NumButtonID+6,X+BarWidth+36+MidWidth,Y+Height+ItemHeight+7,0,-OFF,MidWidth,ItemHeight,0,0,0,255,True,True)'NEXT
	ForceElementData(NumButtonID+7,X+BarWidth+39+MidWidth*2,Y+Height+ItemHeight+7,0,-OFF,0,ItemHeight,0,0,0,255,True,True)'SAVE IP
	
	Element= GetElement(NumButtonID)
	Element.RWidth = ItemHeight
	Element= GetElement(NumButtonID+4)
	Element.RWidth = ItemHeight
End Sub

Sub HideNumboard(BG As Canvas)
	LCAR_HideElement(BG, NumListID, True,  False, False )
	LCAR_HideElement(BG, NumListID+1, True, False,False)
	HideGroup(NumGroup, False, False)
End Sub


Sub HandleNumboard(BG As Canvas, Key As String, IP As IPaddress, Settings As Map) As IPaddress 
	Dim Element As LCARelement ,APIKB As APIKeyboard, SelectAll As Boolean 
	SelectAll= False
	If Key.EqualsIgnoreCase("PREV") Then
		If IP.SelectedOctet>0 Then
			IP.SelectedOctet = IP.SelectedOctet-1
			SelectAll=True
		End If
	Else If Key.EqualsIgnoreCase("NEXT") Then
		If IP.SelectedOctet<4 Then 
			IP.SelectedOctet = IP.SelectedOctet+1
			SelectAll=True
		End If
	Else If Key.EqualsIgnoreCase("SAVE IP") Then
		SaveIP(IP,Settings) 
		Return IP
	Else If Key.EqualsIgnoreCase("DELETE IP") Then
		'deleteip( getsavedip ( api.GetIP(ip,False), settings) , settings )
		DeleteIP(SelectedIP, Settings)
		SelectedIP=-1
		Return IP
	Else If Key.EqualsIgnoreCase("ENTER") Then
		PushEvent(LCAR_OK, KBCancelID+5,0,0,0,0,0,Event_Up)
	 	Return IP
	Else If Key.EqualsIgnoreCase("FIRST") Then 
		IP.SelectedOctet = 0
		SelectAll=True
	Else
		Element=LCARelements.Get(NumButtonID+9)
		APIKB=API.MakeKB(Element.Text, Element.LWidth, Element.RWidth, KBShift,KBCaps)
		APIKB=API.HandleKeyboard(APIKB,Key)
		HandleElement(Element,APIKB,NumButtonID+9)
		If APIKB.Text.Length = 0 Then
			APIKB.Text= "0"
			SelectAll=True
		End If
		If IP.SelectedOctet <3 AND APIKB.Text > 255 Then
			IP.SelectedOctet=IP.SelectedOctet+1
			SelectAll=True
		Else
			IP = API.SetOctet(IP, IP.SelectedOctet, APIKB.Text)
			If  IP.SelectedOctet<4 AND APIKB.Text.Length=3 OR (APIKB.Text ="0" AND Key = KeyCodes.KEYCODE_0) Then 
				IP.SelectedOctet=IP.SelectedOctet+1
				SelectAll=True
			End If
		End If
	End If
	IsClean=False
	Return ResizeNumboard(BG, IP, IP.SelectedOctet,SelectAll)
End Sub

Sub BackupRestoreKB(Save As Boolean, Text As String)
	Dim Element As LCARelement 
	Element=LCARelements.Get(KBCancelID+5)
	If Save Then
		BackupKB = API.MakeKB(Element.Text, Element.LWidth, Element.RWidth, KBShift,KBCaps)
	Else If BackupKB.IsInitialized Then 'restore
		If Text.length>0 Then
			BackupKB=API.SetSelText(BackupKB, Text , False)
			BackupKB.Shift=False
		End If
		HandleElement(Element,BackupKB, KBCancelID+5)
		IsClean=False
	End If
End Sub

Sub HandleElement(Element As LCARelement , APIKB As APIKeyboard, ElementID As Int)
	Element.IsClean=False
	Element.Text = APIKB.Text'.ToUpperCase 
	Element.LWidth = APIKB.SelStart 
	Element.RWidth = APIKB.SelLength 
	LCARelements.Set(ElementID, Element)
End Sub

Sub InsertText(Text As String) 
	Dim Element As LCARelement ,APIKB As APIKeyboard 
	ClearScreen(Null)
	Element=LCARelements.Get(KBCancelID+5)
	APIKB=API.MakeKB(Element.Text, Element.LWidth, Element.RWidth, KBShift, KBCaps)
	APIKB=API.SetSelText(APIKB, Text , False)
	APIKB.Shift=False
	HandleElement(Element,APIKB, KBCancelID+5)
	IsClean=False
End Sub
Sub HandleKeyboard(KeyCode As Int) As Boolean 
	Dim Element As LCARelement, APIKB As APIKeyboard, ret As Boolean
	Select Case KeyCode
		Case KeyCodes.KEYCODE_SHIFT_LEFT, KeyCodes.KEYCODE_SHIFT_RIGHT
			If SymbolsEnabled Then 	KBLayout=(KBLayout+1) Mod 3
			SeedKeyboard
		Case -97: 	KBShift = Not(KBShift)'insert
		Case -100: 	InsertText( API.Clipboard(1,"") )'paste
		Case 4, API.BUTTON_C, -96 'back button, caps
			Log("Caps")
			KBCaps = Not(KBCaps)
			ret=True
		Case Else
			ClearScreen(Null)
			Element=LCARelements.Get(KBCancelID+5)
			APIKB=API.MakeKB(Element.Text, Element.LWidth, Element.RWidth, KBShift,KBCaps)
			APIKB=API.HandleKeyboard(APIKB,KeyCode)
			HandleElement(Element,APIKB, KBCancelID+5)
	End Select
	IsClean=False
	Return ret
End Sub 

Sub IsKeyboardVisible(BG As Canvas, AnimationStage As Int,Toggle As Boolean  ) As Boolean
	Dim Visible As Boolean ''HasHardwareKeyboard As Boolean , KBisVisible As Boolean
	If HasHardwareKeyboard Then
		Visible = KBisVisible'
	Else
		Visible =  IsListVisible(KBListID)
	End If
	'If Visible Then DirtyElement(KBCancelID+5)
	If AnimationStage>0 AND Not( ElementMoving) Then 
		If Visible Then
			If Toggle Then
				HideKeyboard(BG,AnimationStage)
			Else
				ShowKeyboard(BG, AnimationStage)
			End If
		Else
			If Toggle Then ShowKeyboard(BG, AnimationStage)
		End If
	End If
	Return Visible
End Sub

Sub SeedKeyboard
	Dim Keys As List, temp As Int,tempstr As String 
	LCAR_ClearList(KBListID,0)
	If Not(SymbolsEnabled) Then KBLayout=0
	Select Case KBLayout
		Case 0: Keys.Initialize2(Array As String("Q", "A", "Z", "W", "S", "X", "E", "D", "C", "R", "F", "V", "T", "G", "B", "Y", "H", "N", "U", "J", "M", "I", "K", "SHIFT", "O", "L", "<ı", "P", ".", "ı>" ))
		Case 1: Keys.Initialize2(Array As String("1", "!", "/", "2", "@", "-", "3", "?", "+", "4", "$", "=", "5", "%", ",", "6", "^", "'", "7", "&", "|", "8", "*", "SHIFT", "9", "(", "<ı", "0", ")", "ı>" ))
		Case 2: Keys.Initialize2(Array As String("~", "CAPS", "COPY", "`", "INS", "CUT", "#", "", "PST", "", "", "", "•", "", "", "{", "<", "-", "}", ">", "_", "[", ";", "SHIFT", "]", ":", "<ı", "\", """", "ı>" ))
	End Select
	
	For temp = 0 To Keys.Size-1
		tempstr = Keys.Get(temp)
		If tempstr = "_" Then tempstr = "—"
		LCAR_AddListItem(KBListID, tempstr, LCAR_Random, API.GetKeyCode(Keys.Get(temp),False, KBShift)    , "", False, "", 0,False,-1)
	Next
End Sub
Sub MakeKeyboard(SurfaceID As Int,  Group As Int)
	'Dim ListID As Int',X As Int, Y As Int, Width As Int, Height As Int'  ,temp As Int ,temp2 As Int ,Unit As Int
	'height=3*(itemheight+listitemwhitespace)
	KBGroup=Group
	KBListID= LCAR_AddList("Keyboard",  SurfaceID,  10  ,10,  0,0, -1 ,0,   False,  -1, leftside, leftside,  True, False,False ,0 )
	SetAlignment(KBListID,5)
	LockListStart(KBListID,True)
	
	'lcar_addlistitem(KBListID, "Q", LCAR_Random,KeyCodes.KEYCODE_Q, "", False, "", 0,False,-1)
	
	'SeedKeyboard
	'LCAR_AddListItems(KBListID , LCAR_Random,0 , Array As String("Q", "A", "Z", "W", "S", "X", "E", "D", "C", "R", "F", "V", "T", "G", "B", "Y", "H", "N", "U", "J", "M", "I", "K", "SHIFT", "O", "L", "<", "P", "#", ">" ))
	
	KBCancelID=LCAR_AddLCAR("KBCancel", SurfaceID,  0,0,130,88,100,ItemHeight, LCAR_Orange, LCAR_Elbow ,"CNCL","","", Group,  False, 2,  True, 2,0)
	LCAR_AddLCAR("KBBackspace" , SurfaceID,  134,88-ItemHeight, 0 ,ItemHeight, 0,0, LCAR_Orange, LCAR_Button, "BKSP", "", "", Group, False, 5,True,0,0)'+1
	LCAR_AddLCAR("KBSpace" , SurfaceID,  134,88-ItemHeight, 0 ,ItemHeight, 0,0, LCAR_Orange, LCAR_Button, "SPACE", "", "", Group, False, 5,True,0,0)'+2
	LCAR_AddLCAR("KBDelete" , SurfaceID,  134,88-ItemHeight, 0 ,ItemHeight, 0,0, LCAR_Orange, LCAR_Button, "DEL", "", "", Group, False, 5,True,0,0)'+3
	LCAR_AddLCAR("KBOK",SurfaceID,0,0,130,88 ,100,ItemHeight, LCAR_Orange, LCAR_Elbow ,"OK","","", Group,  False, 2 ,  True, 3,0)'+4
	
	RespondToAll(LCAR_AddLCAR("KBText", SurfaceID,  105, 0,  -1 , BigTextboxHeight , 0,6,LCAR_Orange, LCAR_Textbox , "SEARCH", "", "",   Group, False,    1,True, 0,0))'5
End Sub
Sub SelectText(Text As String ) 
	Dim Element As LCARelement ,ElementID As Int 
	ElementID=KBCancelID+5
	Element = LCARelements.Get(ElementID)
	Element.IsClean =False
	Element.Text=Text.ToUpperCase 
	Element.LWidth=0
	Element.rWidth=Text.Length 
	LCARelements.Set(ElementID,Element)
End Sub
Sub GetInputText As String 
	Return LCAR_GetElement(KBCancelID+5).Text 
End Sub

Sub KeyboardHeight As Int
	Dim BarHeight As Int = 88, BarWidth As Int ,Corner As Int = LCARCornerElbow2.Height
	If CrazyRez>0 Then
		BarWidth = (100*CrazyRez) + 30 
		If BarWidth >100 OR ItemHeight>100 Then Corner=(Min(ItemHeight,BarWidth) *0.5)
		BarHeight = ItemHeight + Corner + ListitemWhiteSpace
	End If
	If HasHardwareKeyboard Then
		Return BarHeight
	Else
		Return ( 3*(ItemHeight+ListitemWhiteSpace))+BarHeight
	End If
End Sub
'Sub KeyboardHeight As Int
'	If HasHardwareKeyboard Then
'		Return 88
'	Else
'		Return ( 3*(ItemHeight+ListitemWhiteSpace))+88
'	End If
'End Sub
Sub HideKeyboard(BG As Canvas, AnimationStage As Int ) 
	Dim Height As Int, Unit As Int , Element As LCARelement
	Height=KeyboardHeight
	Unit=(ScaleWidth-276)/4
	KBisVisible=False
	KBShift=False
	ToggleMultiLine(False)
	ResizeList(KBListID,  ScaleWidth,  Height,   -1,0, ScaleHeight, True)
	LCAR_HideElement(BG, KBListID, True , False ,False)
	'FadeList(bg,KBListID,False)
	MoveLCAR(KBCancelID,    0, ScaleHeight, 0,0,0,True,False,True)
	MoveLCAR(KBCancelID+1,134, ScaleHeight, 0,0,0,True,False,True)
	MoveLCAR(KBCancelID+2,138+Unit, ScaleHeight, 0,0,0,True,False,True)
	MoveLCAR(KBCancelID+3,-134-Unit, ScaleHeight, 0,0,0,True,False,True)
	MoveLCAR(KBCancelID+4,-130, ScaleHeight, 0,0,0,True,False,True)
	
	LCAR_HideElement(BG,KBCancelID+5,False,False ,False)
	
	'Element= lcarelements.Get(17)
	'If element.Visible Then ForceElementData(17, Element.LOC.currX , Element.LOC.currY ,0,0, Element.Size.currX, Element.Size.currY +Height+4,0, Height-4, 255,255, True,True)
	WebviewOffset=Height+16
	PushEvent(LCAR_Keyboard,  -1 ,Height+4,0,0,0,0,0)
	'LCARSeffects.ResizeLeftBar( -1,WebviewOffset)'  Event.Index, Event.Index2)
End Sub

Sub ListItemsHeight(Items As Double) As Int
	Return Items*(ItemHeight+ListitemWhiteSpace)
End Sub

Sub RemoveAnimation(ID As Int, IsList As Boolean )
	Dim Lists As LCARlist, Element As LCARelement, LOC As tween, Size As tween 
	If IsList Then
		Lists = LCARlists.Get(ID)
		LOC=Lists.LOC
		Size= Lists.Size
	Else
		Element = LCARelements.Get(ID)
		LOC = Element.LOC
		Size=Element.Size 
	End If
	LOC.offX=0
	LOC.offY=0
	Size.offX=0
	Size.offY=0
	If IsList Then
		Lists.LOC=LOC
		Lists.Size=Size
	Else
		Element.LOC=LOC
		Element.Size=Size
	End If
End Sub


Sub ShowTextbox(BG As Canvas)
	Dim temp As Int 
	MoveLCAR(KBCancelID+5, GetScaledPosition(0,True), 0, -1,0, 255,True,False,False)
	ForceShow(KBCancelID+5,True)
	For temp = 0 To 4
		LCAR_HideElement(BG, KBCancelID+ temp, False, False ,False)
	Next
	InitCharsize(BG)
End Sub
'Sub ShowTextbox(BG As Canvas)
'	Dim temp As Int 
'	ForceShow(KBCancelID+5,True)
'	For temp = 0 To 4
'		LCAR_HideElement(BG, KBCancelID+ temp, False, False ,False)
'	Next
'End Sub
'Sub ShowKeyboard(BG As Canvas, AnimationStage As Int )
'	Dim Height As Int,Yoff As Int ,Y As Int ,KBHeight As Int, temp As Int ,temp2 As Int ,Unit As Int, Element As LCARelement ,BarWidth As Int,X As Int, UseKB As Boolean 
'	'If AnimationStage>0 Then y=scaleheight
'	'forceshow(18,False)'HARDCODED-BAD
'	ClickedOK=False
'	HideSideBar(BG,-1,0)
'	UseKB = Not(HasHardwareKeyboard) OR BypassHardwareKB
'	ToggleMultiLine(False)
'	InitCharsize(BG)
'	LCARSeffects.QuestionAsked=False
'	
'	If UseKB Then 
'		Height= ListItemsHeight(3)' 3*(itemheight+listitemwhitespace)
'		KBShift=False
'		KBCaps=True
'		SeedKeyboard
'	End If
'	
'	KBHeight=Height+88
'	Y=ScaleHeight-KBHeight
'	If AnimationStage>0 Then
'		Stage=AnimationStage
'		If UseKB Then ResizeList(KBListID, ScaleWidth, Height,  -1,0, ScaleHeight ,True)
'	End If
'	If UseKB Then 
'		LCAR_HideElement(BG, KBListID, True, True  ,False)
'		ResizeList(KBListID, ScaleWidth,  Height,  -1,0, Y,True)
'		RandomizeColors(KBListID)
'	End If
'	
'	HideGroup(KBGroup, True, False)
'	
'	If SmallScreen Then
'		BarWidth=70
'		X=55
'	Else
'		BarWidth=130
'		X=105
'	End If
'	
'	temp=ScaleWidth-BarWidth
'	temp2=ScaleWidth-268
'	'temp=width-130+1
'	Unit=(temp2-8)/4
'
'	ForceElementData(KBCancelID,   0, Y +Height,0,KBHeight, BarWidth,88,0,0,0 ,255,True,AnimationStage>0)										'KBCancel
'	ForceElementData(KBCancelID+4, -BarWidth, Y +Height,0,KBHeight, BarWidth,88,0,0,0 ,255,True,AnimationStage>0)								'KBOK
'	
'	temp2=Y+Height+88-ItemHeight
'	If SmallScreen Then
'		Unit= ( (ScaleWidth- (BarWidth*2) ) / 3) - 2
'		ForceElementData(KBCancelID+2, BarWidth+8+Unit, temp2,0,KBHeight, -BarWidth-8-Unit ,  ItemHeight,0,0,0,255,True,AnimationStage>0)		'KBSpace	 Unit*2+1	
'	Else
'		ForceElementData(KBCancelID+2, BarWidth+8+Unit, temp2,0,KBHeight, -BarWidth-8-Unit ,  ItemHeight,0,0,0,255,True,AnimationStage>0)		'KBSpace	 Unit*2+1
'	End If
'	ForceElementData(KBCancelID+1, BarWidth+4, temp2,0,KBHeight, Unit,  ItemHeight,0,0,0,255,True,AnimationStage>0)								'KBBackspace
'	ForceElementData(KBCancelID+3, -BarWidth-4-Unit, temp2,0,KBHeight, Unit,  ItemHeight,0,0,0,255,True,AnimationStage>0)						'KBDelete
'	
'	ForceElementData(KBCancelID+5, X, 0, 0,0,  -1, 40,0,0,0 ,255,True,AnimationStage>0)															'KBText
'	
'	'MoveLCAR(KBCancelID+5,105, 0,  scalewidth-105,40, 255,True, True,True)
'	
'	'LCAR_HideElement(BG,KBCancelID+5,False,True ,false)
'	
'	Element= LCARelements.Get(KBCancelID)
'	Element.RWidth=ItemHeight
'	LCARelements.Set(KBCancelID, Element)
'	Element= LCARelements.Get(KBCancelID+4)
'	Element.RWidth=ItemHeight
'	LCARelements.Set(KBCancelID+4, Element)
'	
'	'Element= lcarelements.Get(17)
'	'If element.Visible Then ForceElementData(17, Element.LOC.currX , Element.LOC.currY ,0,0, Element.Size.currX, Element.Size.currY -kbHeight-4,0, kbHeight, 255,255, True,True)
'	WebviewOffset=-KBHeight-16
'	PushEvent(LCAR_Keyboard, 1 ,-KBHeight-4,0,0,0,0,0)
'	KBisVisible =True
'End Sub
Sub ShowKeyboard(BG As Canvas, AnimationStage As Int ) As Int 
	Dim Height As Int,Yoff As Int ,Y As Int ,KBHeight As Int, temp As Int ,temp2 As Int ,Unit As Int, Element As LCARelement ,BarWidth As Int,X As Int, UseKB As Boolean ,Corner As Int = LCARCornerElbow2.Height, BarHeight As Int 
	If SmallScreen Then
		BarWidth=70
		X=55
	Else
		X=100*GetScalemode' 105
		BarWidth=X + 30
		If BarWidth >100 OR ItemHeight>100 Then Corner=(Min(ItemHeight,BarWidth) *0.5)
		X=X+Corner
	End If
	BarHeight = ItemHeight + Corner
	
	'If AnimationStage>0 Then y=scaleheight
	'forceshow(18,False)'HARDCODED-BAD
	ClickedOK=False
	HideSideBar(BG,-1,0)
	UseKB = Not(HasHardwareKeyboard) OR BypassHardwareKB
	
	ToastMessage(BG, API.IIF(UseKB, "PRESS BACK TO TOGGLE CAPS LOCK", "THE HARDWARE KEYBOARD SETTING IS ENABLED, AS SUCH, THE SOFT KEYBOARD IS DISABLED"), 3)

	ToggleMultiLine(False)
	InitCharsize(BG)
	LCARSeffects.QuestionAsked=False
	
	If UseKB Then 
		Height= ListItemsHeight(3)' 3*(itemheight+listitemwhitespace)
		KBShift=False
		KBCaps=True
		SeedKeyboard
	End If
	
	KBHeight=Height+BarHeight
	Y=ScaleHeight-KBHeight
	If AnimationStage>0 Then
		Stage=AnimationStage
		If UseKB Then ResizeList(KBListID, ScaleWidth, Height,  -1,0, ScaleHeight ,True)
	End If
	If UseKB Then 
		LCAR_HideElement(BG, KBListID, True, True  ,False)
		ResizeList(KBListID, ScaleWidth,  Height,  -1,0, Y,True)
		RandomizeColors(KBListID)
	End If
	
	HideGroup(KBGroup, True, False)
	
	
	
	temp=ScaleWidth-BarWidth
	temp2=ScaleWidth-268
	'temp=width-130+1
	Unit=(temp2-8)/4

	ForceElementData(KBCancelID,   0, Y +Height,0,KBHeight,         BarWidth,BarHeight,0,0,0 ,255,True,AnimationStage>0)						'KBCancel
	ForceElementData(KBCancelID+4, -BarWidth, Y +Height,0,KBHeight, BarWidth,BarHeight,0,0,0 ,255,True,AnimationStage>0)						'KBOK
	
	temp2=Y+Height+BarHeight-ItemHeight
	If SmallScreen Then
		Unit= ( (ScaleWidth- (BarWidth*2) ) / 3) - 2
		ForceElementData(KBCancelID+2, BarWidth+8+Unit, temp2,0,KBHeight, -BarWidth-8-Unit ,  ItemHeight,0,0,0,255,True,AnimationStage>0)		'KBSpace	 Unit*2+1	
	Else
		ForceElementData(KBCancelID+2, BarWidth+8+Unit, temp2,0,KBHeight, -BarWidth-8-Unit ,  ItemHeight,0,0,0,255,True,AnimationStage>0)		'KBSpace	 Unit*2+1
	End If
	ForceElementData(KBCancelID+1, BarWidth+4, temp2,0,KBHeight, Unit,  ItemHeight,0,0,0,255,True,AnimationStage>0)								'KBBackspace
	ForceElementData(KBCancelID+3, -BarWidth-4-Unit, temp2,0,KBHeight, Unit,  ItemHeight,0,0,0,255,True,AnimationStage>0)						'KBDelete
	
	ForceElementData(KBCancelID+5, X, 0, 0,0,  -1, 40,0,0,0 ,255,True,AnimationStage>0)															'KBText
	
	'MoveLCAR(KBCancelID+5,105, 0,  scalewidth-105,40, 255,True, True,True)
	
	'LCAR_HideElement(BG,KBCancelID+5,False,True ,false)
	
	Element= LCARelements.Get(KBCancelID)
	Element.RWidth=ItemHeight
	Element= LCARelements.Get(KBCancelID+4)
	Element.RWidth=ItemHeight
	
	'Element= lcarelements.Get(17)
	'If element.Visible Then ForceElementData(17, Element.LOC.currX , Element.LOC.currY ,0,0, Element.Size.currX, Element.Size.currY -kbHeight-4,0, kbHeight, 255,255, True,True)
	WebviewOffset=-KBHeight-16
	PushEvent(LCAR_Keyboard, 1 ,-KBHeight-4,0,0,0,0,0)
	KBisVisible =True
	'KeyboardHeight = KBHeight
	Return KBHeight
End Sub

Sub SwapMode(ElementID As Int , TheStage As Int, DoSound As Boolean) As Int
	Dim Element As LCARelement ,Color As Int
	Element = LCARelements.Get(ElementID)
	If DoSound Then Stop 
	If TheStage=0 Then
		Element.lWidth= Classic_Green 
	Else
		Select Case TheStage
			Case -1:TheStage=LCAR_Red'switch to condition green
			Case -2:TheStage=Classic_Green'switch to yellow alert
			Case -3:TheStage=LCAR_Yellow 'switch to red alert
			Case Else
				TheStage= Element.lWidth
		End Select
		
		Select Case TheStage'Element.lWidth
			Case Classic_Green 
				Element.lWidth=LCAR_Yellow
			Case LCAR_Yellow 
				Element.lWidth=LCAR_Red 
				If DoSound Then PlaySound(13,True)
			Case LCAR_Red 
				Element.lWidth=Classic_Green
			'Case Else
			'	Msgbox(Element.RWidth, "INVALID COLOR")
		End Select
	End If
End Sub

Sub SetGraphStyle(ElementID As Int, Style As Int, Cols As Int, Rows As Int)
	Dim Element As LCARelement 
	Element = LCARelements.Get(ElementID)
	Element.Align= Style
	If Cols>-1 Then Element.LWidth= Cols
	If Rows>-1 Then Element.rWidth= Rows
	Element.IsClean=False
End Sub
Sub SetGraphID(ElementID As Int, GraphID As Int)
	Dim Element As LCARelement 
	Element = LCARelements.Get(ElementID)
	Element.TextAlign=GraphID
	Element.IsClean=False
End Sub


Sub DrawAnswerSlider(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Direction As Int, Value As Int, Alpha As Int, LeftText As String, LeftColorID As Int, RightText As String, RightColorID As Int)
	Dim ColorID As Int, Wid As Double, temp As Int,temp2 As Int ,X2 As Double,Alpha2 As Int, Stages As Int=10
	Select Case Direction
		Case 0,-2'false/red/right and larson red
			ColorID = RightColorID'LCAR_Red
		Case 1,-1'true/green/left and larson green
			ColorID = LeftColorID'Classic_Green
	End Select
	'debug(Direction & "  " & Value)
	'ColorHalf= GetColor(ColorID, False,Alpha*0.5)
	'ColorID = GetColor(ColorID, False,Alpha)
	
	Wid=(Width - MinWidth*2 - 2) / Stages
	X2=X+MinWidth
	
	DrawLCARbutton(BG,X,Y,MinWidth, ItemHeight, LeftColorID, False, LeftText, "", leftside, 0, False,  -1, 5,-1,255,False)
	
	For temp = 0 To Stages-1
		temp2=temp*Stages
		If Direction<0 Then
			Alpha2= API.IIF(API.IsBetween(temp2,temp2+Stages-1,Value),255, 128)
		Else If Direction = 1 Then'green left-to-right
			temp2=temp2+Stages-1
			Alpha2 = API.IIF(Value>temp2,255,128)
		Else'red right-to-left
			Alpha2 = API.IIF(temp2>=Value,255,128)
		End If
		DrawLCARslantedbutton(BG, X2+2,Y,Wid-2,ItemHeight-1,ColorID, Alpha2, False, "", -1,0)
		X2=X2+Wid
	Next
	
	DrawLCARbutton(BG,X+Width-MinWidth,Y,MinWidth, ItemHeight, RightColorID, False, RightText, "", 0, leftside, True,-1, 5,-1,255,False)
End Sub






















Sub BigTextboxHeight As Int
	Return 32
End Sub
Sub InitCharsize(BG As Canvas)
	If Not(CharSize.IsInitialized) Then CharSize = Trig.SetPoint( API.TextHeightAtHeight(BG,LCARfont, "A", BigTextboxHeight), API.TextWidthAtHeight(BG,LCARfont, "A", BigTextboxHeight))
End Sub
Sub HandleTextboxMouse(ElementIndex As Int, ElementType As Int, EventType As Int, X As Int , Y As Int)
	Dim Element As LCARelement
	Log(ElementIndex & " " & ElementType & " " & EventType & " " & X & " " & Y)
	If ElementIndex = KBCancelID+5 Then
		Select Case EventType
			Case Event_Down
				TextPos=Trig.SetPoint(0,0)
				
			Case Event_Move 
				TextPos.X=TextPos.X+X
				TextPos.Y=TextPos.Y+Y
				
				If TextPos.X<-CharSize.X Then
					HandleKeyboard(KeyCodes.KEYCODE_DPAD_LEFT)
					TextPos.X=TextPos.X+CharSize.X
				Else If TextPos.X > CharSize.X Then
					HandleKeyboard(KeyCodes.KEYCODE_DPAD_RIGHT)
					TextPos.X=TextPos.X-CharSize.X
				End If
		End Select
	End If
End Sub

Sub IsMultiline As Boolean 
	Dim Element As LCARelement 
	Element = GetElement(KBCancelID+5)
	If Element.ElementType = LCAR_MultiLine Then LCARSeffects.IsMultiline =True
	Return LCARSeffects.IsMultiline 
End Sub
'Sub ToggleMultiLine(Enabled As Boolean )
'	Dim Element As LCARelement 
'	If KBCancelID>0 Then
'		Element= LCARelements.Get(KBCancelID+5)
'		Element.ElementType = API.IIF(Enabled, LCAR_MultiLine, LCAR_Textbox)
'		Element.LOC.currX = API.IIF(SmallScreen ,55, 105)
'		Element.LOC.currY =0
'		If Enabled Then
'			Element.Size.currY = API.IIF(SmallScreen ,72, 145)
'			Element.TextAlign=0
'		Else
'			Element.Size.currY =BigTextboxHeight
'			Element.TextAlign=1
'		End If
'	End If
'End Sub
Sub ToggleMultiLine(Enabled As Boolean )
	Dim Element As LCARelement 
	If KBCancelID>0 Then
		Element= LCARelements.Get(KBCancelID+5)
		Element.ElementType = API.IIF(Enabled, LCAR_MultiLine, LCAR_Textbox)
		Element.LOC.currX = GetScaledPosition(0,True)' API.IIF(SmallScreen ,55, 105)
		Element.LOC.currY =0
		If Enabled Then
			Element.Size.currY = API.IIF(SmallScreen ,72, 145)
			Element.TextAlign=0
		Else
			Element.Size.currY =BigTextboxHeight
			Element.TextAlign=1
		End If
	End If
End Sub

Sub DrawLCARMultiLineTextbox(BG As Canvas, X As Int, Y As Int, Width As Int,Height As Int, SelStart As Int, SelWidth As Int, Text As String, ColorID As Int, State As Boolean, Blink As Boolean,Alpha As Int ,LineStart As Int )As Int
	Dim SelTextColorID As Int,CursorColorID As Int,HighliteColorID As Int 'cursor and text are the same color
	'DrawLCARtextbox(BG, Dimensions.currX ,Dimensions.currY, Dimensions.offX,Dimensions.offY, Element.LWidth, Element.RWidth, Element.Text, Element.ColorID, Element.ColorID,   LCAR_LightBlue,State, BlinkState, Element.TextAlign,Element.Opacity.Current )
	If RedAlert Then
		HighliteColorID = LCAR_RedAlert'highlight color		LCAR_LightBlue
		CursorColorID= LCAR_White'caret color
		ColorID= LCAR_RedAlert'text color
		If Not(Blink) Then SelTextColorID=LCAR_White'highlighted text color
	Else 
		HighliteColorID = LCAR_LightBlue
		CursorColorID=ColorID
		SelTextColorID=LCAR_Black
	End If
	Return DrawMultiLineTextbox(BG, LCARfont, BigTextboxHeight, Text, X,Y,Width, Height, Colors.Black, GetColor(ColorID, False, Alpha), GetColor(SelTextColorID, False, Alpha), GetColor(HighliteColorID, False, Alpha),  GetColor(CursorColorID, False, Alpha),  LineStart, SelStart,SelWidth, Blink).X
End Sub

Sub DrawMultiLineTextbox(BG As Canvas,Font As Typeface, TextSize As Int, Text As String, X As Int, Y As Int,  Width As Int, Height As Int, BGColor As Int, TextColor As Int,SelTextColor As Int, HighlightColor As Int, CaretColor As Int, LineStart As Int, SelStart As Int, SelLength As Int, ShowCaret As Boolean) As Point
	Dim temppoint As Point ,Bottom As Int ,LineHeight As Int,Line As Int
	DrawRect(BG,X,Y,Width+1,Height+1, BGColor, 0)
	'debug("Line: " & Line)
	
	temppoint = DrawLineOfText(BG,Font,TextSize,Text,X,Y,Width,Colors.Transparent,TextColor, SelTextColor, HighlightColor, CaretColor, LineStart, SelStart, SelLength, ShowCaret) 
	Bottom=Y+Height
	LineHeight=temppoint.Y + 1
	Y=Y+ LineHeight
	Do Until LineStart >= Text.Length -1 OR Y +LineHeight >= Bottom
		Line=Line+1
		LineStart=LineStart+ temppoint.X+1
		If LineStart< Text.Length -1 Then
			If Y< Bottom Then 
				'debug("Line: " & Line)
				temppoint= DrawLineOfText(BG,Font,TextSize,Text,X,Y,Width,Colors.Transparent,TextColor,SelTextColor, HighlightColor, CaretColor, LineStart, SelStart, SelLength, ShowCaret) 
			End If
		End If
		Y=Y+ LineHeight
	Loop
	Return temppoint
End Sub

Sub DrawLineOfText(BG As Canvas,Font As Typeface, TextSize As Int, Text As String, X As Int, Y As Int,  Width As Int, BGColor As Int, TextColor As Int,SelTextColor As Int, HighlightColor As Int, CaretColor As Int, LineStart As Int, SelStart As Int, SelLength As Int, ShowCaret As Boolean) As Point
	Dim tempstr() As String, CRLFloc As Int, tempstr2 As StringBuilder, WidthofSpace As Int ,temp As Int, WidthofWord As Int ,WidthofLine As Int ,tempstr3 As String , LineHeight As Int,LengthOfLine As Int
	Dim SelText As String, StartChar As Int ,EndChar As Int 
	CRLFloc= Text.IndexOf2(CRLF, LineStart)-1
	If CRLFloc <0 Then CRLFloc = Text.Length-LineStart 
	Text = API.Mid(Text, LineStart, CRLFloc )
	tempstr2.Initialize
	If API.TextWidthAtHeight(BG,Font,Text,TextSize) <= Width Then
		tempstr2.Append(Text)
		LengthOfLine = Text.Length -1
	Else
		tempstr = Regex.Split(" ", Text)
		WidthofSpace=API.TextWidthAtHeight(BG,Font, " ", TextSize)
		For temp = 0 To tempstr.Length-1
			WidthofWord=API.TextWidthAtHeight(BG,Font, tempstr(temp), TextSize)
			'debug(tempstr(temp) & " is " & WidthofWord & " px, max " & WidthofLine & "/" & Width)
			If WidthofLine + WidthofWord > Width Then 
				If WidthofLine = 0 Then
					tempstr3=API.LimitTextWidth(BG, tempstr(temp), Font,TextSize, Width, "-")
					LengthOfLine=tempstr3.Length -2
					tempstr2.Append(tempstr3)
				End If
				temp=tempstr.Length
			Else
				tempstr2.Append(tempstr(temp) & " ")
				WidthofLine=WidthofLine + WidthofWord + WidthofSpace
			End If
		Next
		If LengthOfLine = 0 Then LengthOfLine = tempstr2.Length -1
	End If
	
	'debug("BEFORE: " & Text)
	Text= tempstr2.ToString
	
	If TextColor <> Colors.Transparent Then
		If Text=0 Then
			LineHeight = API.TextHeightAtHeight(BG,Font, "ABC", TextSize)+1
		Else
			LineHeight = API.TextHeightAtHeight(BG,Font, Text, TextSize)+1
		End If
		If BGColor <> Colors.Transparent Then DrawRect(BG,X,Y,Width, LineHeight, BGColor, 0)
		BG.DrawText(Text,X,Y+LineHeight, Font, TextSize, TextColor, "LEFT")
		SelStart= SelStart- LineStart
		If HighlightColor <> Colors.Transparent AND SelLength <> 0 Then
			If SelStart < 0 AND SelLength > -SelStart Then' selstart is before linestart, and sellength is larger than the difference between the 2
				ShowCaret=False
				SelLength = SelLength - (0- SelStart)
				SelStart=0
				'debug("PHASE1")
			Else If SelStart > LengthOfLine AND SelLength<0 AND Abs(SelLength)> SelStart-LengthOfLine  Then' selstart is after linestart, and sellength is below zero and abs(greater than the difference between selstart and linelength)
				ShowCaret=False
				SelLength= SelLength + (SelStart-LengthOfLine) - 1
				SelStart=LengthOfLine+1
				'debug("PHASE2")
			Else If SelStart >=0 AND SelStart <= 0+LengthOfLine+1 Then 'selstart is in between linestart and linestart+lengthofline
				If SelLength<0 Then
					If Abs(SelLength) > SelStart Then SelLength= -SelStart
					'debug("PHASE3")
				Else
					SelLength = Min(SelLength, LengthOfLine-SelStart+1)
					'debug("PHASE4")
				End If
			Else
				'debug("PHASE5")
				SelLength=0
			End If
			If SelLength <> 0 Then
				StartChar = API.IIF(SelLength<0, SelStart+SelLength, SelStart)
				EndChar = StartChar+ Abs(SelLength)
				StartChar=Max(0,StartChar)
				EndChar=Min(EndChar,LengthOfLine+1)
				
				temp = BG.MeasureStringWidth(Text.SubString2(0, StartChar)  ,Font, TextSize)
				SelText=Text.SubString2(StartChar, EndChar)
				'debug(SelStart & " " & SelLength & " " & SelText)
				WidthofWord=BG.MeasureStringWidth(SelText,Font, TextSize)
				BG.DrawRect( SetRect(X+temp-1,Y+2,WidthofWord+2, LineHeight-1),  HighlightColor ,True,0)
				BG.DrawText(SelText,X+temp,Y+LineHeight, Font, TextSize, SelTextColor, "LEFT")
			End If
		End If
		If CaretColor <> Colors.Transparent AND ShowCaret Then
			'debug(SelStart)
			'If SelStart=0 Then
			'	BG.DrawRect( SetRect(X,Y+1,3, LineHeight+1), CaretColor,True,0)
			If SelStart <= LengthOfLine+1 AND SelStart>-1 Then	
				'If SelLength =0 Then
					temp = SelStart
				'Else
				'	temp = API.IIF(SelLength<0, StartChar,EndChar)
				'End If
				temp = BG.MeasureStringWidth(API.left(Text, temp)  ,Font, TextSize)
				BG.DrawRect( SetRect(X+temp-1,Y+1,3, LineHeight), CaretColor,True,0)
			End If
		End If
	End If
	Return Trig.SetPoint(LengthOfLine, LineHeight)
End Sub











Sub ScaleFactor As Float
	Return Max(1, GetScalemode)
End Sub
Sub GetScalemode As Float
	If SmallScreen Then Return 0.5
	If CrazyRez = 0 Then Return 1
	Return CrazyRez 
End Sub
'Position:
'[] (0) top right corner
'[|_ _ ___1____ _
'  _ _ ___2____ _
'[|
'__ (3) bottom of the screen
'||
'(4) below the frame elbow
'||
'--
'(5) below the sidebar
Sub GetScaledPosition(Position As Int, isX As Boolean) As Int
	Dim Top As Int = 145, Bottom As Int = 165, Width As Int = 100, Factor As Float = 1, X As Int, Y As Int 
	If SmallScreen Then
		Top = 72
		Bottom = 85
		Width=50
		Factor=0.5
	Else If CrazyRez>1 Then 
		Factor=CrazyRez
		Width=Width*Factor
		Bottom = Bottom*Factor - (ListitemWhiteSpace*2)
		Top=Bottom - ((17*Factor)+ListitemWhiteSpace)
	End If
	Select Case Position
		Case 0'top right corner
			X=Width+ListitemWhiteSpace + LCARCornerElbow2.Width 
			Y=Top-LCARCornerElbow2.Height
		Case 1,2'along top/bottom of the frame divider
			X=(100*Factor) * 1.33 + ListitemWhiteSpace'' (71*Factor) +
			Y=Top
			If Position = 2 Then Y = Y  + (17*Factor) + ListitemWhiteSpace
		Case 3'bottom of the screen
			X=Width+ListitemWhiteSpace + LCARCornerElbow2.Width 
			Y=Bottom + (17*Factor) + LCARCornerElbow2.Height
		Case 4, 5'below the frame elbow
			Y=Bottom+ (88*Factor) + ListitemWhiteSpace 
			If Position = 5 Then Y=Y+ ListItemsHeight( GetList(LCAR_Sidebar).ListItems.Size )
	End Select
	If isX Then Return X Else Return Y
End Sub