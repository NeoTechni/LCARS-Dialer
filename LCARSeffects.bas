B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=StaticCode
Version=6.77
@EndOfDesignText@
'Code module
'Subs in this code module will be accessible from all modules.
Sub Process_Globals
	'These global variables will be declared once when the application starts.
	'These variables can be accessed from all modules.

		
	'Prompt stuff
	Dim PromptID As Int,Prompt2Btns As Boolean, PromptQID As Int, PromptGroup As Int, BarHeight As Int, BarWidth As Int,IsMultiline As Boolean ,QuestionAsked As Boolean 
	Dim PromptHeight As Int,	PromptWidth As Int,	was2buttons As Boolean ',Width2 As Int :
	PromptHeight=200 :			BarHeight=32:		BarWidth=BarHeight*3:	PromptWidth= BarWidth+ LCAR.LCARCornerElbow2.width 
	
	'Frame stuff
	Dim FrameGroup1 As Int, FrameGroup2 As Int ,FrameElement As Int ,FrameLeftBar As Int ,NeedsRedrawFrame As Boolean ,NeedsLeftBar As Boolean , FrameOffset As Int,FrameBitsVisible As Boolean 
	
	'Dpad stuff
	Dim DpadCenter As Float :	DpadCenter=0.125
	
	'Condition status alert stuff
	Dim OkudaStages As Int,CachedRadius As Int,CachedAngles As List  :OkudaStages=25
	
	'SensorSweep and ShieldStatus Stuff
	Dim Enterprise As Bitmap, MaxShieldStages As Int:MaxShieldStages=16
	
	'GradientStuff
	Type GradientCache(ColorID As Int, State As Boolean, Stages(16) As Int )
	Dim Gradients As List :Gradients.Initialize :CachedAngles.Initialize 
End Sub
Sub CacheGradient(ColorID As Int, State As Boolean) As Int
	Dim temp As Int , tempcache As GradientCache,tempcolor As LCARColor,R As Int, G As Int, B As Int ,temp2 As Double 
	For temp = 0 To Gradients.Size-1
		tempcache=Gradients.Get(temp)
		If tempcache.ColorID=ColorID And tempcache.State=State Then Return temp
	Next
	tempcache.Initialize 
	tempcache.ColorID=ColorID
	tempcache.State=State
	tempcolor=LCAR.LCARcolors.get(ColorID)
	If State Then 
		R=tempcolor.sR 
		G=tempcolor.sG
		B=tempcolor.sB 
	Else
		R=tempcolor.nR 
		G=tempcolor.nG
		B=tempcolor.nB
	End If
	For temp = 0 To 15
		temp2=temp/15 
		tempcache.stages(temp) = Colors.RGB(  R * temp2, G*temp2, B*temp2)
	Next
	Gradients.Add(tempcache)
	Return Gradients.Size-1
End Sub




Sub GetTextHeight(BG As Canvas, DesiredHeight As Int, Text As String, tTypeFace As Typeface, IsHeight As Boolean ) As Int 
	Dim temp As Int,CurrentHeight As Int 
	Do Until temp >=  DesiredHeight
		CurrentHeight=CurrentHeight+1
		If IsHeight Then
			temp = BG.MeasureStringHeight(Text,tTypeFace, CurrentHeight)
		Else
			temp = BG.MeasureStringWidth(Text,tTypeFace, CurrentHeight)
		End If
	Loop
	If temp>DesiredHeight Then CurrentHeight=CurrentHeight-1
	Return CurrentHeight
End Sub


Sub SmallScreenMode
	BarHeight=LCAR.ItemHeight
	BarWidth=33 'Barheight*3
	PromptWidth= BarWidth+ LCAR.LCARCornerElbow2.width 
	
	If FrameElement>0 Then 'resize frame
		LCAR.ResizeElbowDimensions(FrameElement+1, 50, 10)
		LCAR.ResizeElbowDimensions(FrameElement+6, 50, 10)
	End If
	If PromptID>0 Then'resize prompt
		LCAR.ResizeElbowDimensions(PromptID,BarWidth,BarHeight)
		LCAR.ResizeElbowDimensions(PromptID+1,BarWidth,BarHeight)
		LCAR.ResizeElbowDimensions(PromptID+2,BarWidth,BarHeight)
		LCAR.ResizeElbowDimensions(PromptID+3,BarWidth,BarHeight)
	End If
End Sub







Sub ResizeLeftBar(Index As Int, Index2 As Int)
	Dim Y As Int =256,Width As Int=100
	If LCAR.SmallScreen Then 
		Y= 132
		Width=50
	Else If LCAR.CrazyRez>0 Then
		Y= LCAR.GetScaledPosition(4,False)'  Y*LCAR.CrazyRez
		Width=Width*LCAR.CrazyRez
	End If
	If Index = -1 Then 'hidekb, enlarge element 17
		LCAR.ForceElementData(FrameElement+11, 0 , Y , 0,0, Width,-1,0,-Index2, 255,255, True,True)
	Else'showkb, shrink element 17
		LCAR.ForceElementData(FrameElement+11, 0 , Y , 0,0, Width, Index2 ,0,Abs(Index2)-4, 255,255, True,True)
	End If
End Sub

'Sub ResizeLeftBar(Index As Int, Index2 As Int)
'	Dim Y As Int ,Width As Int
'	If LCAR.SmallScreen Then 
'		Y= 132
'		Width=50
'	Else
'		Y=256
'		Width=100
'	End If
'	If Index = -1 Then 'hidekb, enlarge element 17
'		LCAR.ForceElementData(FrameElement+11, 0 , Y , 0,0, Width,-1,0,-Index2, 255,255, True,True)
'	Else'showkb, shrink element 17
'		LCAR.ForceElementData(FrameElement+11, 0 , Y , 0,0, Width, Index2 ,0,Abs(Index2)-4, 255,255, True,True)
'	End If
'End Sub
Sub NextStage(Element1 As Int, Element2 As Int, LastStage As Int)
	LCAR.Stage=LCAR.Stage+1
	LCAR.LCAR_HideElement(Null, Element1, False,True,False)
	LCAR.LCAR_HideElement(Null, Element2,False,True,False)
	If NeedsLeftBar AND LCAR.Stage=LastStage Then LCAR.LCAR_HideElement(Null, FrameElement+11,False,True,False)'stage was 7
End Sub
Sub IsFrameVisible As Boolean 
	Return (LCAR.GroupVisible(FrameGroup1) AND FrameGroup1>0 ) OR (LCAR.GroupVisible(FrameGroup2) AND FrameGroup2>0 )
End Sub
'Sub ShowFrame(BG As Canvas, DoAnimation As Boolean, LeftBar As Boolean,Stage As Int ) 
'	Dim Element As LCARelement, OneThird As Int,X As Int,X2 As Int 'ForceElementData
'	
'	OneThird= LCAR.ScaleWidth/3
'	NeedsLeftBar=LeftBar
'	'elements 6-17, (group 3 and 5)	
'	DoAnimation=False
'	
'	'If LCAR.GroupVisible(FrameGroup1) AND LCAR.GroupVisible(FrameGroup2) AND Not(NeedsRedrawFrame) Then Return False
'	'If DoAnimation Then LCAR.LCAR_HideAll(BG,False)
'	
'	LCAR.Stage=Stage
'	LCAR.HideGroup(FrameGroup1,True,True)
'	LCAR.HideGroup(FrameGroup2,True,True)
'	
'	If LCAR.SmallScreen Then
'		LCAR.ForceElementData(FrameElement, 0,0,0,35,50,35,0,-35,0,255,True,DoAnimation)'top left square
'		
'		X=LCAR.ForceElementData(FrameElement+1,0,  38, 0,0,  OneThird,  44, -OneThird+ 50, 0, 0,255,True,DoAnimation)+3'7 and 12 elbows
'		LCAR.ForceElementData(FrameElement+6,0,85, 0,0,  OneThird, 44, -OneThird+ 50 , 0, 0,255,True,DoAnimation)
'		
'		X2=LCAR.ForceElementData(FrameElement+2, X, 72, 0,0,  12, 10,0, 0, 0,255,Not(DoAnimation),DoAnimation)+3'8 and 13 small squares
'		LCAR.ForceElementData(FrameElement+7, X, 85, 0,0,  12, 10, 0, 0, 0,255,Not(DoAnimation),DoAnimation)
'		
'		X=LCAR.ForceElementData(FrameElement+3, X2,   72, 0,        0,     OneThird-15, 10, -(OneThird-26), 0,0,255,Not(DoAnimation),DoAnimation)+3'9 and 14 long rectangles
'		LCAR.ForceElementData(FrameElement+8, X2,   85, 0,        0,     OneThird-15, 5,      -(OneThird-26), 0,0,255,Not(DoAnimation),DoAnimation)
'		
'		X2=LCAR.ForceElementData(FrameElement+4, X,72,0,0, OneThird-15, 10,-(OneThird-26), 0,0,255,Not(DoAnimation),DoAnimation)+3'10 and 15 long rectangles
'		LCAR.ForceElementData(FrameElement+9, X,85,0,0, OneThird-15, 10,-(OneThird-26), 0,0,255,Not(DoAnimation),DoAnimation)
'		
'		LCAR.ForceElementData(FrameElement+5, X2,72,0,0, 12,10,0,0,0,255,Not(DoAnimation),DoAnimation) '11 and 16 small squares
'		LCAR.ForceElementData(FrameElement+10, X2,85,0,0, 12,10,0,0,0,255,Not(DoAnimation),DoAnimation) 
'		
'		LCAR.ForceElementData(FrameElement+11, 0,132+FrameOffset, 0,0, 50,LCAR.ScaleHeight-132-FrameOffset,0,-(LCAR.ScaleHeight-132-FrameOffset),0,255,Not(DoAnimation),DoAnimation) 
'	Else
'		'top left square width=100, height=71
'		LCAR.ForceElementData(FrameElement, 0,0,0,71,100,71,0,-71,0,255,True,DoAnimation)
'		
'		'7 and 12 elbows			0,75,358,88,100,17,
'		X=LCAR.ForceElementData(FrameElement+1,0,  74, 0,0,  OneThird, 88, -OneThird+ 100, 0, 0,255,True,DoAnimation)+3
'		LCAR.ForceElementData(FrameElement+6,0,165, 0,0,  OneThird, 88, -OneThird+ 100 , 0, 0,255,True,DoAnimation)
'		
'		'8 and 13 small squares		361,146,23,17,
'		X2=LCAR.ForceElementData(FrameElement+2, X, 145, 0,0,  23, 17,0, 0, 0,255,Not(DoAnimation),DoAnimation)+3
'		LCAR.ForceElementData(FrameElement+7, X, 165, 0,0,  23, 17, 0, 0, 0,255,Not(DoAnimation),DoAnimation)
'		
'		'9 and 14 long rectangles	388,146,118,17
'		X=LCAR.ForceElementData(FrameElement+3,      X2,   145, 0,        0,     OneThird-26, 17,      -(OneThird-26), 0,0,255,Not(DoAnimation),DoAnimation)+3
'		LCAR.ForceElementData(FrameElement+8,      X2,   165, 0,        0,     OneThird-26, 6,      -(OneThird-26), 0,0,255,Not(DoAnimation),DoAnimation)
'		
'		'10 and 15 long rectangles	509,146,-27,17
'		X2=LCAR.ForceElementData(FrameElement+4, X,145,0,0, OneThird-26, 17,-(OneThird-26), 0,0,255,Not(DoAnimation),DoAnimation)+3
'		LCAR.ForceElementData(FrameElement+9, X,165,0,0, OneThird-26, 17,-(OneThird-26), 0,0,255,Not(DoAnimation),DoAnimation)
'		
'		'11 and 16 small squares	-24,146,24,17
'		LCAR.ForceElementData(FrameElement+5, X2,145,0,0, 23,17,0,0,0,255,Not(DoAnimation),DoAnimation) 
'		LCAR.ForceElementData(FrameElement+10, X2,165,0,0, 23,17,0,0,0,255,Not(DoAnimation),DoAnimation) 
'		
'		'If leftbar Then				  '0,256,100,-1,0,0,  lcar.ScaleHeight-256
'		LCAR.ForceElementData(FrameElement+11,  0,256+FrameOffset, 0,0, 100,LCAR.ScaleHeight-256-FrameOffset,0,-(LCAR.ScaleHeight-256-FrameOffset),0,255,Not(DoAnimation),DoAnimation) 
'	End If
'	If Not(NeedsLeftBar) Then 'LCAR.ForceHide(FrameElement+11) 
'		LCAR.LCAR_HideElement(BG, FrameElement+11, False, False,True)
'	End If
'	
'	NeedsRedrawFrame= False
'	FrameBitsVisible=True
'End Sub
Sub ShowFrame(BG As Canvas, DoAnimation As Boolean, LeftBar As Boolean,Stage As Int ) 
	Dim Element As LCARelement, OneThird As Int,X As Int,X2 As Int, Factor As Float = 1, temp As Int, Whitespace As Int = LCAR.ListitemWhiteSpace 'ForceElementData
	Dim Top As Int = 145, Bottom As Int = 165
	
	OneThird= LCAR.ScaleWidth/3
	NeedsLeftBar=LeftBar
	'elements 6-17, (group 3 and 5)	
	
	If LCAR.GroupVisible(FrameGroup1) AND LCAR.GroupVisible(FrameGroup2) AND Not(NeedsRedrawFrame) Then Return False
	DoAnimation=False
	
	'If DoAnimation Then LCAR.LCAR_HideAll(BG,False)
	
	LCAR.Stage=Stage
	LCAR.HideGroup(FrameGroup1,True,True)
	LCAR.HideGroup(FrameGroup2,True,True)
	
	If LCAR.SmallScreen Then
		LCAR.ForceElementData(FrameElement, 0,0,0,35,50,35,0,-35,0,255,True,DoAnimation)'top left square
		
		X=LCAR.ForceElementData(FrameElement+1,0, 38, 0,0,  OneThird,  44, -OneThird+ 50, 0, 0,255,True,DoAnimation)+3'7 and 12 elbows
		LCAR.ForceElementData(FrameElement+6,0,85, 0,0,  OneThird, 44, -OneThird+ 50 , 0, 0,255,True,DoAnimation)
		
		X2=LCAR.ForceElementData(FrameElement+2, X, 72, 0,0,  12, 10,0, 0, 0,255,Not(DoAnimation),DoAnimation)+3'8 and 13 small squares
		LCAR.ForceElementData(FrameElement+7, X, 85, 0,0,  12, 10, 0, 0, 0,255,Not(DoAnimation),DoAnimation)
		
		X=LCAR.ForceElementData(FrameElement+3, X2,   72, 0,        0,     OneThird-15, 10, -(OneThird-26), 0,0,255,Not(DoAnimation),DoAnimation)+3'9 and 14 long rectangles
		LCAR.ForceElementData(FrameElement+8, X2,   85, 0,        0,     OneThird-15, 5,      -(OneThird-26), 0,0,255,Not(DoAnimation),DoAnimation)
		
		X2=LCAR.ForceElementData(FrameElement+4, X,72,0,0, OneThird-15, 10,-(OneThird-26), 0,0,255,Not(DoAnimation),DoAnimation)+3'10 and 15 long rectangles
		LCAR.ForceElementData(FrameElement+9, X,85,0,0, OneThird-15, 10,-(OneThird-26), 0,0,255,Not(DoAnimation),DoAnimation)
		
		LCAR.ForceElementData(FrameElement+5, X2,72,0,0, 12,10,0,0,0,255,Not(DoAnimation),DoAnimation) '11 and 16 small squares
		LCAR.ForceElementData(FrameElement+10, X2,85,0,0, 12,10,0,0,0,255,Not(DoAnimation),DoAnimation) 
		
		LCAR.ForceElementData(FrameElement+11, 0,132+FrameOffset, 0,0, 50,LCAR.ScaleHeight-132-FrameOffset,0,-(LCAR.ScaleHeight-132-FrameOffset),0,255,Not(DoAnimation),DoAnimation) 
	Else 
		If LCAR.CrazyRez>0 Then 
			Factor=LCAR.CrazyRez
			Bottom = Bottom*Factor - (Whitespace*2)
			Top=Bottom - ((17*Factor)+Whitespace)
		End If
		
		LCAR.ForceElementData(FrameElement, 0,0,0,71*Factor,100*Factor,71*Factor,0,-71*Factor,0,255,True,DoAnimation)'top left square width=100, height=71
		
		'7 and 12 elbows			0,75,358,88,100,17,
		'If Factor > 2 Then X = Factor * 2 + ((Factor-3)*2)
		temp=(100*Factor)
		X2=temp*1.33
		If Factor <3 Then X=88*Factor Else X = Bottom - (71*Factor) - Whitespace*2
		X=LCAR.ForceElementData(FrameElement+1,	 	0, 71*Factor + Whitespace, 0,0,       X2, X , -X2+temp, 0, 0,255,True,DoAnimation)+3
		LCAR.ForceElementData(FrameElement+6,     0, Bottom, 0,0,      X2 , 88*Factor, -X2+temp , 0, 0,255,True,DoAnimation)
		
		OneThird = (LCAR.ScaleWidth - X+2) / 2
		
		Element=LCAR.LCARelements.Get(FrameElement+1)
		Element.LWidth=100*Factor
		Element.rWidth=17*Factor
		Select Case Factor
			Case 1.5: Element.Size.currY = Element.Size.currY - 4
			Case 2.5: Element.Size.currY = Element.Size.currY + 2
		End Select
		
		Element=LCAR.LCARelements.Get(FrameElement+6)
		Element.LWidth=100*Factor
		Element.rWidth=17*Factor
		
		'8 and 13 small squares		361,146,23,17,
		X2=LCAR.ForceElementData(FrameElement+2, X, Top, 0,0,  23*Factor, 17*Factor,0, 0, 0,255,Not(DoAnimation),DoAnimation)+3
		LCAR.ForceElementData(FrameElement+7, X, Bottom, 0,0,  23*Factor, 17*Factor, 0, 0, 0,255,Not(DoAnimation),DoAnimation)
		
		'9 and 14 long rectangles	388,146,118,17
		temp=OneThird - (23*Factor) - Whitespace' OneThird-26
		X=LCAR.ForceElementData(FrameElement+3,      X2,   Top, 0,        0,    temp, 17*Factor,      -temp, 0,0,255,Not(DoAnimation),DoAnimation)+3
		LCAR.ForceElementData(FrameElement+8,      X2,   Bottom, 0,        0,     temp, 6*Factor,      -temp, 0,0,255,Not(DoAnimation),DoAnimation)
		
		'10 and 15 long rectangles	509,146,-27,17
		X2=LCAR.ForceElementData(FrameElement+4, X,Top,0,0, temp, 17*Factor,-temp, 0,0,255,Not(DoAnimation),DoAnimation)+3
		LCAR.ForceElementData(FrameElement+9, X,Bottom,0,0, temp, 17*Factor,-temp, 0,0,255,Not(DoAnimation),DoAnimation)
		
		'11 and 16 small squares	-24,146,24,17
		LCAR.ForceElementData(FrameElement+5, X2,Top,0,0, 23*Factor,17*Factor,0,0,0,255,Not(DoAnimation),DoAnimation) 
		LCAR.ForceElementData(FrameElement+10, X2,Bottom,0,0, 23*Factor,17*Factor,0,0,0,255,Not(DoAnimation),DoAnimation) 
		
		'If leftbar Then				  '0,256,100,-1,0,0,  lcar.ScaleHeight-256
		
		X=Bottom +  (88*Factor) + Whitespace    '250*Factor + Whitespace*2'  API.iif(LCAR.crazyrez, 503,256)
		LCAR.ForceElementData(FrameElement+11,   0,X+FrameOffset, 0,0, 100*Factor,LCAR.ScaleHeight-X-FrameOffset,0,-(LCAR.ScaleHeight-X-FrameOffset),0,255,Not(DoAnimation),DoAnimation) 
	End If
	If Not(NeedsLeftBar) Then 'LCAR.ForceHide(FrameElement+11) 
		LCAR.LCAR_HideElement(BG, FrameElement+11, False, False,True)
	End If
	
	NeedsRedrawFrame= False
	FrameBitsVisible=True
End Sub

Sub MoveListY(ListID As Int)As Boolean  
	Dim Element As LCARelement ,AvailableSpace As Int  ,tList As LCARlist ,Y As Int = LCAR.GetScaledPosition(4,False)'= api.IIF(lcar.SmallScreen,12,17 * lcar.GetScalemode)
	If FrameElement>0 AND FrameElement+6 < LCAR.LCARelements.size AND ListID < LCAR.LCARlists.Size Then
		Element = LCAR.LCARelements.Get(FrameElement+6)
		tList= LCAR.LCARlists.Get(ListID)
		AvailableSpace = Max(0,Floor((Element.Size.currY + Element.Size.offY - Element.RWidth) / LCAR.ListItemsHeight(1)))'(Element.Size.currY + Element.Size.offY)

		tList.LOC.currY = Y - (AvailableSpace*LCAR.ListItemsHeight(1))
		tList.LOC.offY=0
		
		If ListID<>4 Then
			tList.LOC.currX = LCAR.GetScaledPosition(3,True) 'API.IIF(LCAR.SmallScreen, 50,100) + LCAR.ChartSpace
			tList.LOC.offX=0
		End If
		
		tList.IsClean=False
		Return True
	End If
End Sub

'Sub MoveListY(ListID As Int)As Boolean  
'	Dim Element As LCARelement ,AvailableSpace As Int ,tList As LCARlist ,Y As Int
'	If FrameElement>0 AND FrameElement+6 < LCAR.LCARelements.size AND ListID < LCAR.LCARlists.Size Then
'		Element = LCAR.LCARelements.Get(FrameElement+6)
'		tList= LCAR.LCARlists.Get(ListID)
'		AvailableSpace = (Element.Size.currY + Element.Size.offY) - Element.RWidth - LCAR.ListitemWhiteSpace
'		Y=Element.LOC.currY + Element.LOC.offY + Element.Size.currY + Element.Size.offY
'		If LCAR.ItemHeight <= AvailableSpace Then
'			Y = Y - LCAR.ItemHeight
'		Else
'			Y=Y + LCAR.ListitemWhiteSpace
'		End If
'		'debug("Moving list " & ListID & " from " & tList.LOC.currY & " to " & Y & " to fit in " & AvailableSpace)
'		tList.LOC.currY = Y
'		tList.LOC.offY=0
'		
'		If ListID<>4 Then
'			tList.LOC.currX = API.IIF(LCAR.SmallScreen, 50,100) + LCAR.ChartSpace
'			tList.LOC.offX=0
'		End If
'		
'		tList.IsClean=False
'		Return True
'	End If
'End Sub

Sub HideFrame
	NeedsRedrawFrame =False
	LCAR.HideGroup(FrameGroup1,False,False)
	LCAR.HideGroup(FrameGroup2,False,False)
End Sub
Sub MakeFrame(Group1 As Int, Group2 As Int)
	'frame top half (group 3)
	FrameGroup1=Group1
	FrameElement = LCAR.LCAR_AddLCAR("TopLeft", 0, 0,0,100,71,0,0, LCAR.LCAR_LightPurple, LCAR.LCAR_Button, "", "", "" , Group1, False, 2,True,0,0)'element 0 button
	LCAR.LCAR_AddLCAR("TopElbo", 0, 0,75,358,88,100,17, LCAR.LCAR_DarkPurple, LCAR.LCAR_Elbow ,"","","", Group1, False, 0, True, 2,0)'element 1 elbow
	LCAR.LCAR_AddLCAR("MidLef1", 0, 361,146,23,17,0,0, LCAR.LCAR_Orange, LCAR.LCAR_Button, "", "", "" , Group1, False, 0,False,0,0)'element 2 short -
	LCAR.LCAR_AddLCAR("MidLef2", 0, 388,146,118,17,0,0, LCAR.LCAR_LightPurple, LCAR.LCAR_Button, "", "", "" , Group1, False, 0,False,0,0)'element 3 100x -
	LCAR.LCAR_AddLCAR("MidLef3", 0, 509,146,-27,17,0,0, LCAR.LCAR_LightPurple, LCAR.LCAR_Button, "", "", "" , Group1, False, 0,False,0,0)'element 4 variable -
	LCAR.LCAR_AddLCAR("MidLef4", 0, -24,146,24,17,0,0, LCAR.LCAR_Red, LCAR.LCAR_Button, "", "", "" , Group1, False, 0,False,0,0)'element 5 last -
	
	'frame bottom half (group 5)
	FrameGroup2=Group2
	LCAR.LCAR_AddLCAR("Mi2Left", 0, 0,167,358,71,100,17, LCAR.LCAR_Red, LCAR.LCAR_Elbow, "", "", "" , Group2, False,  0,True,0,0)'element 6 elbow
	LCAR.LCAR_AddLCAR("Mi2Lef1", 0, 361,167,23,17,0,0, LCAR.LCAR_LightOrange, LCAR.LCAR_Button, "", "", "" , Group2, False, 0,False,0,0)'element 7 short -
	LCAR.LCAR_AddLCAR("Mi2Lef2", 0, 388,167,118,6,0,0, LCAR.LCAR_LightOrange, LCAR.LCAR_Button, "", "", "" , Group2, False, 0,False,0,0)'element 8 100x -
	LCAR.LCAR_AddLCAR("Mi2Lef3", 0, 509,167,-27,17,0,0, LCAR.LCAR_LightPurple, LCAR.LCAR_Button, "", "", "" , Group2, False, 0,False,0,0)'element 9 variable -
	LCAR.LCAR_AddLCAR("Mi2Lef4", 0, -24,167,24,17,0,0, LCAR.LCAR_LightOrange, LCAR.LCAR_Button, "", "", "" , Group2, False, 0,False,0,0)'element 10 last -
	
	FrameLeftBar= LCAR.LCAR_AddLCAR("LeftBar", 0, 0,256,100, -1,0,0, LCAR.LCAR_Orange, LCAR.LCAR_Button, "", "", "", Group2, False,8,True,0,0)'element 11'left bar if needed
	LCAR.SetAsync(FrameLeftBar, False)
	LCAR.ReorderGroup(FrameLeftBar,0)
	
	LCAR.HideGroup(Group1,False,False)
	LCAR.HideGroup(Group2,False,False)
End Sub
Sub HideAllFrameBits(BG As Canvas, Fade As Boolean, Visible As Boolean)
	HideFrameBits(BG,True, Fade,Visible)
	HideFrameBits(BG,False, Fade,Visible)
End Sub
Sub HideFrameBits(BG As Canvas, isTop As Boolean, Fade As Boolean, Visible As Boolean   )
	Dim temp As Int, Start As Int 
	Start=FrameElement + API.IIF(isTop, 2, 7)
	For temp = Start To Start + 3
		If Visible Then
			LCAR.ForceShow(temp, True)
		Else
			LCAR.LCAR_HideElement(BG, temp, False, Visible, Not(Fade) )
		End If
	Next
	FrameBitsVisible=Visible
End Sub

'Sub ResizeFrame(Offset As Int)
'	Dim Y As Int 
'	If LCAR.SmallScreen Then Y=132 Else Y= 256
'	If Offset<0 Then
'		FrameOffset=LCAR.ListItemsHeight(Abs(Offset))
'	Else
'		FrameOffset=Offset
'	End If
'	LCAR.ForceElementData(FrameElement+11,  0,Y+FrameOffset, 0,0,API.IIF(LCAR.SmallScreen ,50, 100),LCAR.ScaleHeight-Y-FrameOffset,0,-(LCAR.ScaleHeight-Y-FrameOffset),0,255, True,False) 
'End Sub
Sub ResizeFrame(Offset As Int)
	Dim Y As Int = LCAR.GetScaledPosition(4,False)
	'If LCAR.SmallScreen Then Y=132 Else Y= 256
	If Offset<0 Then
		FrameOffset=LCAR.ListItemsHeight(Abs(Offset))
	Else
		FrameOffset=Offset
	End If
	LCAR.ForceElementData(FrameElement+11,  0,Y+FrameOffset, 0,0,100*LCAR.GetScalemode ,LCAR.ScaleHeight-Y-FrameOffset,0,-(LCAR.ScaleHeight-Y-FrameOffset),0,255, True,False) 
End Sub





Sub IsEven(Number As Int) As Boolean 
	Return (Number Mod 2) = 0
End Sub	








Sub HidePrompt
	LCAR.HideGroup(PromptGroup,False,False)
End Sub
Sub MakePrompt(SurfaceID As Int, Group As Int)As Int
	Dim Width2 As Int
	
	PromptGroup=Group
	'lcar.LCAR_AddLCAR("TopElbo", 0, 0,75,358,88,100,17, lcar.LCAR_DarkPurple, lcar.LCAR_Elbow ,"","","", 3, False, 0, True, 2,0)'element 7 elbow
	PromptID= LCAR.LCAR_AddLCAR("PromptTopRight", SurfaceID, -PromptWidth,0,0,PromptHeight+1, BarWidth,BarHeight, LCAR.LCAR_Orange, LCAR.LCAR_Elbow , "", "", "", Group, False, 0,False,1,0)
	LCAR.LCAR_AddLCAR("PromptTopLeft", SurfaceID, 0,0,  -PromptWidth+1,PromptHeight, BarWidth,BarHeight, LCAR.LCAR_Orange, LCAR.LCAR_Elbow , "PROMPT", "", "", Group, False, 10,False,0,0)'+1
	LCAR.LCAR_AddLCAR("PromptBotLeft", SurfaceID, 0,PromptHeight-1, PromptWidth  ,PromptHeight, BarWidth,BarHeight*2, LCAR.LCAR_Orange, LCAR.LCAR_Elbow , "", "", "", Group, False, 0,False,2,0)'+2
	LCAR.LCAR_AddLCAR("PromptBotRight", SurfaceID, -PromptWidth,PromptHeight-1, PromptWidth  ,PromptHeight, BarWidth,BarHeight*2, LCAR.LCAR_Orange, LCAR.LCAR_Elbow , "", "", "", Group, False, 0,False,3,0)'+3
	
	LCAR.LCAR_AddLCAR("PromptText", SurfaceID, PromptWidth, BarHeight+LCAR.LCARCornerElbow2.Height,-PromptWidth, 18,-1,0, LCAR.LCAR_Orange, LCAR.LCAR_Textbox ,"","","", Group, False,1,False,0,0)'+4
	
	Width2=(LCAR.ScaleWidth/2) - PromptWidth-5
	Y=PromptHeight*2-BarHeight*2-1
	LCAR.LCAR_AddLCAR("PromptYes",SurfaceID, PromptWidth+3,Y, Width2,  BarHeight*2, 0,0, LCAR.LCAR_Orange, LCAR.LCAR_Button, "YES", "", "", Group, False, 5,True,0,0)'+5 left
	LCAR.LCAR_AddLCAR("PromptNo",SurfaceID, PromptWidth+Width2+6,Y, -PromptWidth-3,  BarHeight*2, 0,0, LCAR.LCAR_Orange, LCAR.LCAR_Button, "NO", "", "", Group, False, 5,True,0,0)'+6 right
	
	
	
	
	Return PromptID
End Sub
Sub IsPromptVisible(BG As Canvas) As Boolean 
	If LCAR.GroupVisible(PromptGroup) Then
		If Not(BG=Null)Then	ShowPrompt(BG,-1, "", "", 0, "", "")
		Return True
	End If
End Sub



'negative number animation stage=keyboard mode
'Sub ShowPrompt(BG As Canvas, AnimationStage As Int, Prompt As String, Text As String, QuestionID As Int, RightBtn As String,  LeftBtnOPTIONAL As String )
'	Dim Y As Int,DoAnimation As Boolean ,Y2 As Int,Width2 As Int,KBmode As Boolean , Height As Int, Y3 As Int
'	LCAR.LCAR_HideAll(BG,False)
'	If AnimationStage<0 Then
'		AnimationStage=Abs(AnimationStage)
'		LCAR.ShowKeyboard(BG,AnimationStage)
'		KBmode=True
'	End If
'	
'	DoAnimation= AnimationStage>0
'	LCAR.SetRedAlert(False)
'	If PromptHeight*2> LCAR.ScaleHeight Then PromptHeight=LCAR.ScaleHeight/2
'	If LCAR.IsKeyboardVisible(Null,0,False)  Then 
'		KBmode=True
'	Else
'		Y= (LCAR.ScaleHeight/2)-PromptHeight
'	End If
'	Y2=Y+PromptHeight*2-BarHeight*2-1
'	If AnimationStage>0 Then	 Prompt2Btns= LeftBtnOPTIONAL.Length>0 Else Prompt2Btns= was2buttons
'	If LCAR.ElbowTextHeight=0 Then LCAR.ElbowTextHeight = LCAR.GetTextHeight(BG,  BarHeight, "PROMPT")'BarHeight
'	
'	
'	LCAR.ForceElementData(PromptID, -PromptWidth,Y,0, PromptHeight-BarHeight, 0, PromptHeight+1,  0,-PromptHeight+BarHeight, 0,255,True, DoAnimation)'top right
'	LCAR.ForceElementData(PromptID+1, 0,Y,0,PromptHeight-BarHeight, -PromptWidth+1, PromptHeight,0,-PromptHeight+BarHeight,0,255,True,DoAnimation)'top left+caption
'	LCAR.ForceElementData(PromptID+2,0,Y+PromptHeight-1,0,0, API.IIF(Prompt2Btns, PromptWidth,LCAR.ScaleWidth/2-2)   ,PromptHeight,0,-PromptHeight+BarHeight,0,255,True,DoAnimation)'bottom left
'	LCAR.ForceElementData(PromptID+3, -PromptWidth,Y+PromptHeight-1,0,0,0,PromptHeight,0,-PromptHeight+BarHeight,0,255,True,DoAnimation)'bottom right
'	
'	Width2=(LCAR.ScaleWidth/2) - PromptWidth-5
'	Height = API.IIF(LCAR.SmallScreen, BarHeight, BarHeight*2)
'	Y3 = API.IIF(LCAR.SmallScreen, Y2+BarHeight, Y2)
'	LCAR.ForceElementData(PromptID+6, PromptWidth+Width2+6,Y3,0,-PromptHeight+BarHeight,-PromptWidth-3,Height,0,0,0,255,True, DoAnimation)' NO (right button)
'	LCAR.ForceElementData(PromptID+5, PromptWidth+3,Y3,0,-PromptHeight+BarHeight,Width2, Height,0,0,0,255,True, DoAnimation)' OK (left button)
'
'	LCAR.ForceElementData(PromptID+4, PromptWidth, Y+BarHeight+LCAR.LCARCornerElbow2.Height, 0, PromptHeight-BarHeight, -PromptWidth,18,0,0,0,255,True,DoAnimation)'Text
'	If KBmode Then 
'		LCAR.ToggleMultiLine(False)
'		Y3= Y2-50 + API.IIF(LCAR.SmallScreen, BarHeight,0)
'		LCAR.ForceElementData(LCAR.KBCancelID+5, PromptWidth, Y3, 0,-PromptHeight+BarHeight,  Width2*2, 40,0,0,0 ,255,True,AnimationStage>0)'KBText
'	End If
'	LCAR.HideGroup(PromptGroup, True,False)
'	
'	If DoAnimation Then
'		PromptQID=QuestionID
'		Text= API.TextWrap(BG, LCAR.LCARfont, 18, Text.ToUpperCase,     Min(LCAR.ScaleWidth,LCAR.ScaleHeight)-PromptWidth*2 )
'		LCAR.LCAR_SetElementText(PromptID+1,Prompt.ToUpperCase, "")
'		LCAR.LCAR_SetElementText(PromptID+4,"", Text.ToUpperCase & " ")
'		LCAR.LCAR_SetElementText(PromptID+6, RightBtn.ToUpperCase, "")
'		
'		was2buttons=Prompt2Btns
'		If Prompt2Btns Then
'			LCAR.LCAR_SetElementText(PromptID+5, LeftBtnOPTIONAL.ToUpperCase , "")
'		'Else
'		'	LCAR.LCAR_HideElement(BG,PromptID+5,  False,False,True)
'		End If
'		LCAR.Stage=AnimationStage
'	End If
'	If Not (was2buttons) Then LCAR.LCAR_HideElement(BG,PromptID+5,  False,False,True)
'End Sub

'negative number animation stage=keyboard mode
Sub ReshowPrompt(BG As Canvas)
	ShowPrompt(BG,API.IIF(LCAR.IsMultiline,-999, 0), "", "", API.IIF(LCAR.IsMultiline, -PromptQID, PromptQID), "", "")
End Sub

'negative number animation stage=keyboard mode
Sub ShowPrompt(BG As Canvas, AnimationStage As Int, Prompt As String, Text As String, QuestionID As Int, RightBtn As String,  LeftBtnOPTIONAL As String )
	Dim Y As Int,DoAnimation As Boolean ,Y2 As Int,Width2 As Int,KBmode As Boolean , Height As Int, Y3 As Int', Width As Int
	LCAR.LCAR_HideAll(BG,False)
	QuestionAsked=False
	'Element= LCARelements.Get(KBCancelID+5)		Element.ElementType = API.IIF(Enabled, LCAR_MultiLine, LCAR_Textbox)
	If AnimationStage<0 Then
		If AnimationStage=-999 Then AnimationStage=0 Else AnimationStage=Abs(AnimationStage)
		LCAR.ShowKeyboard(BG,AnimationStage)
		KBmode=True
	End If
	
	DoAnimation= AnimationStage>0
	If Not(DoAnimation) Then
		If QuestionID>0 AND IsMultiline Then QuestionID = -QuestionID
		LCAR.RemoveAnimation(LCAR.KBListID,True)
	End If
	
	LCAR.SetRedAlert(False)
	If PromptHeight*2> LCAR.ScaleHeight Then PromptHeight=LCAR.ScaleHeight/2
	'Width=PromptHeight
	If LCAR.IsKeyboardVisible(Null,0,False) OR KBmode Then 
		KBmode=True
		QuestionAsked=True
		Y2=(LCAR.ScaleHeight - LCAR.KeyboardHeight ) / 2
		'debug("SH: " & LCAR.ScaleHeight & " PH: " &  PromptHeight & " Y2: " & Y2 & " KBH: " & LCAR.KeyboardHeight)
		'If PromptHeight>Y2 Then PromptHeight=Y2
		PromptHeight=Y2
		IsMultiline = QuestionID<0
	Else
		Y= (LCAR.ScaleHeight/2)-PromptHeight
		IsMultiline=False
	End If
	Y2=Y+PromptHeight*2-BarHeight*2-1
	If AnimationStage>0 Then	 Prompt2Btns= LeftBtnOPTIONAL.Length>0 Else Prompt2Btns= was2buttons
	If LCAR.ElbowTextHeight=0 Then LCAR.ElbowTextHeight = LCAR.GetTextHeight(BG,  BarHeight, "PROMPT")'BarHeight
	
	'If QuestionID>=0 Then'replace x/width with Width
	If KBmode Then
		LCAR.ForceElementData(PromptID, 	-PromptWidth,Y, 					0, PromptHeight*2-BarHeight, 		0, PromptHeight*2+1,  													0,-PromptHeight*2+BarHeight, 			0,255,True, DoAnimation)'top right
		LCAR.ForceElementData(PromptID+1, 	0,Y,								0, PromptHeight*2-BarHeight, 		-PromptWidth+1, PromptHeight*2,											0,-PromptHeight*2+BarHeight,			0,255,True,DoAnimation)'top left+caption
	Else
		LCAR.ForceElementData(PromptID, 	-PromptWidth,Y, 					0, PromptHeight-BarHeight, 		0, PromptHeight+1,  													0,-PromptHeight+BarHeight, 			0,255,True, DoAnimation)'top right
		LCAR.ForceElementData(PromptID+1, 	0,Y,								0,PromptHeight-BarHeight, 		-PromptWidth+1, PromptHeight,											0,-PromptHeight+BarHeight,			0,255,True,DoAnimation)'top left+caption
		LCAR.ForceElementData(PromptID+2,	0,Y+PromptHeight-1,					0,0, 							API.IIF(Prompt2Btns, PromptWidth,LCAR.ScaleWidth/2-2),PromptHeight,		0,-PromptHeight+BarHeight,			0,255,True,DoAnimation)'bottom left
		LCAR.ForceElementData(PromptID+3, 	-PromptWidth,Y+PromptHeight-1,		0,0,							0,PromptHeight,															0,-PromptHeight+BarHeight,			0,255,True,DoAnimation)'bottom right
	End If
	Width2=(LCAR.ScaleWidth/2) - PromptWidth-5
	Height = LCAR.ItemHeight ' API.IIF(LCAR.SmallScreen, BarHeight, BarHeight*2)
	Y3 = API.IIF(LCAR.SmallScreen, Y2+BarHeight, Y2)
	
	If Not(IsMultiline) Then	LCAR.ForceElementData(PromptID+4, PromptWidth, Y+BarHeight+ API.IIF(LCAR.SmallScreen,0, LCAR.LCARCornerElbow2.Height), 0, PromptHeight-BarHeight, Width2,18,0,0,0,255,True,DoAnimation)'Text
	'If Not(IsMultiline) Then LCAR.ForceElementData(PromptID+4, PromptWidth, Y+BarHeight+LCAR.LCARCornerElbow2.Height, 0, PromptHeight-BarHeight, -PromptWidth,18,0,0,0,255,True,DoAnimation)'Text
	If KBmode Then 
		LCAR.ToggleMultiLine(IsMultiline)
		If IsMultiline Then
			QuestionID=Abs(QuestionID)
			'LCAR.ForceElementData(LCAR.KBCancelID+5, 0,0,      0,0,        -1,PromptHeight,        0,0,           0 ,255,True,AnimationStage>0)'KBText
			Y3=Y2-Y-BarHeight-LCAR.LCARCornerElbow2.Height
			Y2=Y+BarHeight+LCAR.LCARCornerElbow2.Height
			'Y3=PromptHeight*2'-BarHeight*2
			LCAR.LCAR_HideElement(BG,PromptID+4,False,False,True)
			LCAR.ForceElementData(LCAR.KBCancelID+5, 	PromptWidth, Y2, 	 0, PromptHeight*2, 	-PromptWidth,Y3,0,0,0,255,True,DoAnimation)'Text
		Else
			LCAR.ForceElementData(PromptID+4, 	PromptWidth, Y+BarHeight+LCAR.LCARCornerElbow2.Height, 	0, PromptHeight*2, 	-PromptWidth,18,0,0,0,255,True,DoAnimation)'Text
			Y3=Y2+10'-lcar.KeyboardHeight  -API.TextHeightAtHeight(BG, LCAR.LCARfont, "ABCDEFyqpjg", LCAR.BigTextboxHeight) '-50 + API.IIF(LCAR.SmallScreen, BarHeight,0) - 5
			LCAR.ForceElementData(LCAR.KBCancelID+5, PromptWidth-LCAR.LCARCornerElbow2.Width+10, Y3, 0,-PromptHeight+BarHeight,  Width2*2+LCAR.LCARCornerElbow2.Width*2-20, 40,0,0,0 ,255,True,AnimationStage>0)'KBText
		End If
	Else		
		Y3 = Y3 + Height
		LCAR.ForceElementData(PromptID+6, 	PromptWidth+Width2+6,Y3,			0,-PromptHeight+BarHeight,		-PromptWidth-3,Height,													0,0,								0,255,True, DoAnimation)' NO (right button)
		LCAR.ForceElementData(PromptID+5, 	PromptWidth+3,Y3,					0,-PromptHeight+BarHeight,		Width2, Height,															0,0,								0,255,True, DoAnimation)' OK (left button)
	End If
	LCAR.HideGroup(PromptGroup, True,False)
	
	If DoAnimation Then
		PromptQID=QuestionID
		Text= API.TextWrap(BG, LCAR.LCARfont, 18, Text.ToUpperCase,     Min(LCAR.ScaleWidth,LCAR.ScaleHeight)-PromptWidth*2 )
		LCAR.LCAR_SetElementText(PromptID+1,Prompt.ToUpperCase, "")
		If IsMultiline Then LCAR.LCAR_SetElementText(PromptID+4,"","") Else LCAR.LCAR_SetElementText(PromptID+4,"", Text.ToUpperCase & " ")
		LCAR.LCAR_SetElementText(PromptID+6, RightBtn.ToUpperCase, "")
		
		was2buttons=Prompt2Btns
		If Prompt2Btns Then
			LCAR.LCAR_SetElementText(PromptID+5, LeftBtnOPTIONAL.ToUpperCase , "")
		'Else
		'	LCAR.LCAR_HideElement(BG,PromptID+5,  False,False,True)
		End If
		LCAR.Stage=AnimationStage
	End If
	If Not (was2buttons) Then LCAR.LCAR_HideElement(BG,PromptID+5,  False,False,True)
End Sub



Sub DrawBitmap(BG As Canvas, BMP As Bitmap, X As Int, Y As Int)
	BG.DrawBitmap(BMP, Null, LCAR.SetRect( X - BMP.Width/2, Y - BMP.Height/2, BMP.Width, BMP.Height))
End Sub





Sub UniqueFilename(Dir As String, Filename As String, Append As String ) As String
	Dim temp As Int ,Lindex As Int, Lpart As String , Rpart As String ,DT As Boolean 
	If Append.Length=0 Then
		Append=" (#)"
	Else If Append = "DATETIME" Then
		DT = True
		'1 space, 10 date, 1 space, 8 time, 20 total
		Append = " " & DateTime.Date(DateTime.now).Replace("/", "-").Replace("\", "-") & " " & DateTime.Time(DateTime.now).Replace(":", "-")
	End If
	
	If File.Exists(Dir, Filename) OR DT Then
		Lindex= Filename.LastIndexOf(".")
		If Lindex=-1 Then
			Lpart=Filename
		Else
			Lpart = Filename.SubString2(0,Lindex)
			Rpart = Filename.SubString(Lindex)
		End If
		If DT Then
			Return Lpart & Append & Rpart
		Else
			temp=1
			Do Until Not( File.Exists(Dir, Lpart & Append.Replace("#", temp) & Rpart))
				temp=temp+1
			Loop
			Return Lpart & Append.Replace("#", temp) & Rpart
		End If
	Else
		Return Filename
	End If
End Sub


Sub SaveScreenshot(BMP As Bitmap, Dir As String, FilenamePNG As String )As String 
	Dim Out As OutputStream
	Try
		FilenamePNG=UniqueFilename(Dir, FilenamePNG, "DATETIME")
		Out = File.OpenOutput(Dir, FilenamePNG, False)
		BMP.WriteToStream(Out, 100, "PNG")
		Out.Close
		Return Dir & "/" & FilenamePNG
	Catch
		Return ""
	End Try
End Sub
Sub DrawBrackets(BG As Canvas, Left As Int, Top As Int, Width As Int, Height As Int, Color As Int, DoTop As Boolean)As Int
	Dim LineThickness As Int,Left2 As Int
	LineThickness=10
	LCAR.ActivateAA(BG,True)
	Left2=Left+Width-LineThickness
	If DoTop Then
		DrawPartOfCircle(BG, Left,Top,LineThickness,0, Color, 0,0)'left top corner
		BG.DrawRect(  LCAR.setrect(Left+LineThickness-1,Top,LineThickness*2,LineThickness), Color,True,0)'left top edge -
		BG.DrawRect(  LCAR.setrect(Left,Top+LineThickness-1,LineThickness,Height-LineThickness*2+2), Color,True,0)'left |
		
		DrawPartOfCircle(BG, Left2,Top,LineThickness,1, Color, 0,0)'right top corner
		BG.DrawRect(  LCAR.setrect(Left2-LineThickness*2+1,Top,LineThickness*2,LineThickness), Color,True,0)'right top edge -
		BG.DrawRect(  LCAR.setrect(Left2,Top+LineThickness-1,LineThickness,Height-LineThickness*2+2), Color,True,0)'right |
	Else
		BG.DrawRect(  LCAR.setrect(Left,Top,LineThickness,Height-LineThickness+1), Color,True,0)'left |
		BG.DrawRect(  LCAR.setrect(Left2,Top,LineThickness,Height-LineThickness+1), Color,True,0)'right |
	End If
	
	BG.DrawRect(  LCAR.setrect(Left+LineThickness-1,Top+Height-LineThickness,LineThickness*2,LineThickness), Color,True,0)'left bottom edge
	BG.DrawRect(  LCAR.setrect(Left2-LineThickness*2+1,Top+Height-LineThickness,LineThickness*2,LineThickness), Color,True,0)'right bottom edge -
	
	DrawPartOfCircle(BG, Left,Top+Height-LineThickness,LineThickness,2, Color, 0,0)'left bottom corner
	DrawPartOfCircle(BG, Left2,Top+Height-LineThickness,LineThickness,3, Color, 0,0)'right bottom corner
	LCAR.ActivateAA(BG,False)
	Return LineThickness
End Sub

Sub DrawPartOfCircle(BG As Canvas , X As Int, Y As Int, Radius As Int, Section As Int, Color As Int , Left As Int, Top As Int)
	Dim P As Path
	P.Initialize(X,Y)
	P.LineTo(X+Radius-1,Y)
	P.LineTo(X+Radius-1,Y+Radius-1)
	P.LineTo(X, Y+Radius-1)
	P.LineTo(X,Y)
	BG.ClipPath(P)
	Select Case Section
		Case 0:BG.DrawCircle(X+Radius,Y+Radius, Radius,Color,True,0) 'top left
		Case 1:BG.DrawCircle(X,Y+Radius, Radius,Color,True,0) 'top right	
		Case 2:BG.DrawCircle(X+Radius,Y, Radius,Color,True,0) 'bottom left
		Case 3:BG.DrawCircle(X,Y, Radius,Color,True,0) 'bottom right	
		
		Case 4: Radius=Radius*0.5:BG.DrawCircle(X+Radius, Y+Radius, Radius, Color,True,0)'left
		Case 5: Radius=Radius*0.5:BG.DrawCircle(X, Y+Radius, Radius, Color,True,0)  'right
		Case 6'top
		Case 7'bottom
	End Select
	BG.RemoveClip
End Sub

Sub DrawArc(cnvs As Canvas, x As Float, y As Float, radius As Float, startAngle As Float, endAngle As Float, Color As Int)
    Dim s As Float
    s = startAngle
    startAngle = 180 - endAngle
    endAngle = 180 - s
    If startAngle >= endAngle Then endAngle = endAngle + 360
    Dim p As Path
    p.Initialize(x, y)
    For i = startAngle To endAngle Step 10
        p.LineTo(x + 2 * radius * SinD(i), y + 2 * radius * CosD(i))
    Next
    p.LineTo(x + 2 * radius * SinD(endAngle), y + 2 * radius * CosD(endAngle))
    p.LineTo(x, y)
    cnvs.ClipPath(p) 'We are limiting the drawings to the required slice
    cnvs.DrawCircle(x, y, radius, Color, True, 0)
    cnvs.RemoveClip
End Sub


















Sub SetPoint(X As Int, Y As Int) As Point 
	Dim temp As Point
	temp.Initialize
	temp.X=X
	temp.Y=Y
	Return temp
End Sub

Sub CacheAngles(RadiusTimes2 As Int, Angle As Int)As Point 
	Dim temp As Int ,res As Point 
	If RadiusTimes2>0 Then
		If Not(CachedAngles.IsInitialized) OR (CachedRadius < RadiusTimes2)  Then
			CachedAngles.Initialize 
			For temp =0 To 359
				CachedAngles.Add( Trig.FindAnglePoint(0,0,RadiusTimes2,temp) )
			Next
			CachedRadius=RadiusTimes2
			'For temp =0 To 359
			'	res=CachedAngles.Get(temp)
			'	Log("CHECKING: " & temp & " X: " & res.X & " Y: " & res.Y)
			'Next
		End If
	End If
	If Angle>-1 Then
		Angle=Trig.CorrectAngle( Angle)
		res= CachedAngles.Get(Angle)
		'res.X= X + res.x 'NOT WORKING
		'res.y= Y + res.y 'NOT WORKING
		Return res
	End If
End Sub













Sub DrawDpad(BG As Canvas, X As Int, Y As Int, Radius As Int, ColorID As Int, InnerRadius As Int, InnerColorID As Int, Border As Int, Alpha As Int,BlinkState As Boolean, Direction As Int)
	Dim P As Path , Left As Int , MiddleLeft As Int,MiddleRight As Int, Right As Int  , Top As Int , Bottom As Int , MiddleTop As Int, MiddleBottom As Int, Color As Int,temp As Int 
	Left= X-Radius
	MiddleLeft=X-InnerRadius+1
	MiddleRight=X+InnerRadius-1
	Right= X+Radius
	
	Top=Y-Radius
	MiddleTop=Y-InnerRadius+1
	MiddleBottom=Y+InnerRadius-1
	Bottom=Y+Radius
	
	LCAR.ActivateAA(BG, True)	
	Color=LCAR.GetColor (ColorID, False, Alpha)
	BG.DrawCircle(X,Y, Radius, Color, True, 0)
	LCAR.ActivateAA(BG, False)	
	'bg.DrawRect( lcar.SetRect(x-radius,y-InnerRadius-Border, radius*2, (Border+InnerRadius)*2), Colors.Black, True, 0)'internal + black -
	'bg.DrawRect( lcar.SetRect(x-InnerRadius-Border,y-radius, (Border+InnerRadius)*2, radius*2), Colors.Black, True, 0)'internal + black |
	
	P.Initialize(Left, MiddleTop)'top left corner along left edge
	P.LineTo(MiddleLeft,MiddleTop)'top left corner inside
	P.LineTo(MiddleLeft,Top)'top left corner along top edge
	P.LineTo(MiddleRight, Top)'top right corner along top edge
	P.LineTo(MiddleRight,MiddleTop)'top right corner inside
	P.LineTo(Right, MiddleTop)'top right corner along right edge
	P.LineTo(Right, MiddleBottom)'bottom right corner along right edge
	P.LineTo(MiddleRight,MiddleBottom)'bottom right corner inside
	P.LineTo(MiddleRight, Bottom)'bottom right corner along bottom edge
	P.LineTo(MiddleLeft,Bottom)'bottom left corner along bottom edge
	P.LineTo(MiddleLeft,MiddleBottom)'bottom left corner inside
	P.LineTo(Left,MiddleBottom)'bottom left corner along left edge
	P.LineTo(Left, MiddleTop)'top left corner along left edge (start)
	
	BG.ClipPath(P)
	BG.DrawCircle(X,Y,Radius, LCAR.GetColor (InnerColorID, False, Alpha), True,0)
	BG.RemoveClip 
	
	BG.DrawLine(Left, MiddleTop, Right, MiddleTop, Colors.Black ,Border)
	BG.DrawLine(Left, MiddleBottom, Right, MiddleBottom, Colors.Black ,Border)
	BG.DrawLine(MiddleLeft, Top, MiddleLeft, Bottom, Colors.Black ,Border)
	BG.DrawLine(MiddleRight, Top, MiddleRight, Bottom, Colors.Black ,Border)
	
	BG.DrawRect(  LCAR.SetRect(X - Radius*0.5 - InnerRadius, MiddleTop, InnerRadius, InnerRadius*2), Colors.Black, True,0)'left
	temp=X - Radius*0.5 - InnerRadius+Border
	DrawTriangle(BG, temp+Border, MiddleTop+Border*2, InnerRadius - Border*4, InnerRadius*2 - Border*4, 2, Color)
	BG.DrawLine(temp+Border, MiddleBottom+Border*2  , temp+ InnerRadius - Border*4     , MiddleBottom+Border*2     , Colors.black,Border)'-
	
	BG.DrawRect(  LCAR.SetRect(X + Radius*0.5+1 , MiddleTop, InnerRadius, InnerRadius*2), Colors.Black, True,0)'right
	temp=X + Radius*0.5 +Border+1
	DrawTriangle(BG, temp+Border, MiddleTop+Border*2, InnerRadius - Border*4, InnerRadius*2 - Border*4, 3, Color)
	BG.DrawLine(temp+Border, MiddleTop-Border*2  , temp+ InnerRadius - Border*4     ,  MiddleTop-Border*2  , Colors.black,Border)'-
	
	BG.DrawRect(  LCAR.SetRect(MiddleLeft , Y - Radius*0.5 - InnerRadius , InnerRadius*2, InnerRadius), Colors.Black, True,0)'top
	temp=Y-InnerRadius*1.5
	BG.DrawLine(MiddleLeft,temp, MiddleRight, temp, Colors.black,Border)'|
	DrawTriangle(BG,MiddleLeft+Border*2, Y - Radius*0.5 - InnerRadius+Border*2, InnerRadius*2 - Border*4,InnerRadius - Border*4, 1, Color)
	
	BG.DrawRect(  LCAR.SetRect(MiddleLeft , Y + Radius*0.5+1 , InnerRadius*2, InnerRadius), Colors.Black, True,0)'bottom
	DrawTriangle(BG,MiddleLeft+Border*2, Y + Radius*0.5 +Border*2 +1, InnerRadius*2 - Border*4,InnerRadius - Border*4, 4, Color)
End Sub
Sub DrawTriangle(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Alignment As Int, Color As Int)
	Dim P As Path, Right As Int, Bottom As Int, MiddleX As Int, MiddleY As Int 	
	Select Case Alignment
		Case 1,4'horizontal,    width=height*2
			MiddleX=Height*2
			X=X+ (Width-MiddleX)/2
			Width= MiddleX
		Case Else'vertical,		height=width*2
			MiddleX=Width*2
			Y=Y+ (Height-MiddleX)/2
			Height= MiddleX
	End Select
	
	Right=X+Width-1
	Bottom=Y+Height-1
	MiddleX=X+(Width*0.5)-1
	MiddleY=Y+(Height*0.5)
	Select Case Alignment 
		Case 1'North
			P.Initialize(X, Bottom)
			P.LineTo(Right,Bottom)
			P.LineTo(MiddleX, Y)
			P.LineTo(X, Bottom)
		Case 2'west
			P.Initialize(Right,Y)
			P.Initialize(Right,Bottom)
			P.LineTo(X, MiddleY)
			P.LineTo(Right,Y)
		Case 3'east
			P.Initialize(X,Y)
			P.LineTo(X,Bottom)
			P.LineTo(Right, MiddleY)
			P.LineTo(X,Y)
		Case 4'south
			P.Initialize(X,Y)
			P.LineTo(MiddleX,Bottom)
			P.LineTo(Right,Y)
			P.LineTo(X,Y)
	End Select
	BG.clippath(P)
	If Color <> LCAR.LCAR_Clear Then
		BG.drawrect(LCAR.SetRect(X,Y,Width,Height), Color,True,0)
		BG.RemoveClip 
	End If
End Sub

Sub DrawCircleSegment(BG As Canvas, X As Int, Y As Int,StartRadius As Int, EndRadius As Int, StartAngle As Int, Degrees As Int, Color As Int, Stroke As Int, EndType As Int, RoundEndAngle As Int )
	Dim X1 As Int, X2 As Int, Y1 As Int, Y2 As Int, X3 As Int, Y3 As Int, P As Path,temp As Int,EndAngle As Int, RadiusDelta As Int,RadiusDelta2 As Int,temp2 As Point 
	EndAngle=Trig.CorrectAngle(StartAngle+Degrees-RoundEndAngle)
	StartAngle = Trig.CorrectAngle( StartAngle+RoundEndAngle)
	
	temp2=CacheAngles(0,StartAngle)
	X1=temp2.X + X
	Y1=temp2.Y + Y
	
	temp2=CacheAngles(0,EndAngle)
	X2=temp2.X + X
	Y2=temp2.Y + Y
	'X1=  Trig.findXYAngle(X,Y, EndRadius*2, StartAngle , True)
	'Y1= Trig.findXYAngle(X,Y, EndRadius*2, StartAngle, False)
	'X2=    Trig.findXYAngle(X,Y, EndRadius*2, EndAngle, True)
	'Y2=   Trig.findXYAngle(X,Y, EndRadius*2, EndAngle, False)
	
	If Degrees<360 Then
		P.Initialize(X, Y)'center/origin
		P.LineTo(X1,Y1)'start angle @ radius
		
		'P.Initialize(X1,Y1)'start angle @ radius
		'If StartRadius=0 Then
		'	P.LineTo(X,Y)'center/origin
		'Else
			'For temp = StartAngle To EndAngle' Step 10
			'	P.LineTo( Trig.findXYAngle(X,Y,StartRadius, temp, True), Trig.findXYAngle(X,Y,StartRadius, temp, False) )
			'Next
		'End If
		
		P.LineTo(X2,Y2)'end angle @ radius
		'P.LineTo(X1,Y1)'start angle @ radius
		P.LineTo(X,Y)'center/origin
		
		BG.ClipPath(P)
	End If
	
	temp=(EndRadius-StartRadius)
	'BG.DrawCircle(0,0, StartRadius + temp *0.5, Color, False, temp)
	BG.DrawCircle(X,Y, StartRadius + temp *0.5, Color, False, temp)
	
	'BG.DrawCircle(X,Y,EndRadius, Color, Stroke=0, Stroke)
	If Degrees<360 Then BG.RemoveClip 
	
	Select Case EndType 
		Case 1'curved
			RadiusDelta2= ( (EndRadius-StartRadius) /2 )
			RadiusDelta=StartRadius + RadiusDelta2
			BG.DrawCircle( Trig.findXYAngle(X,Y,RadiusDelta,StartAngle, True), Trig.findXYAngle(X,Y,RadiusDelta,StartAngle, False),RadiusDelta2,  Color, True, 0)			
			BG.DrawCircle( Trig.findXYAngle(X,Y,RadiusDelta,EndAngle, True), Trig.findXYAngle(X,Y,RadiusDelta,EndAngle, False),RadiusDelta2,  Color, True, 0)
		Case 2'lines
			DrawLine(BG, X,Y,  StartAngle, StartRadius, EndRadius, Color, Stroke)
			DrawLine(BG, X,Y, EndAngle, StartRadius, EndRadius, Color, Stroke)
	End Select
End Sub
Sub DrawLine(BG As Canvas, X As Int, Y As Int, Angle As Int, StartRadius As Int, EndRadius As Int, Color As Int, Stroke As Int)As Rect 
	Dim X1 As Int, Y1 As Int,X2 As Int, Y2 As Int,temp As Rect 
	If StartRadius=0 Then
		X1=X
		Y1=Y
	Else
		X1=Trig.findXYAngle(X,Y,StartRadius,Angle, True)
		Y1=Trig.findXYAngle(X,Y,StartRadius,Angle, False)
	End If
	X2=Trig.findXYAngle(X,Y,EndRadius,Angle, True)
	Y2=Trig.findXYAngle(X,Y,EndRadius,Angle, False)
	BG.DrawLine(X1, Y1, X2,Y2, Color, Stroke)
	
	temp.Initialize(X1,Y1,X2,Y2)
	Return temp
End Sub

Sub DrawAlert(BG As Canvas, X As Int, Y As Int, Radius As Int, StatusMode As Int, Stage As Int, Alpha As Int, TextSize As Int, Text As String, Status As String  )As Int
	Dim Color As Int , P As Path, OneThird As Double, Points(11) As Int, CLR As LCARColor  , temp As Int,Alpha2 As Int, Y2 As Int, Y3 As Int,X2 As Int,Angle As Int 
	Dim Width As Int,textsize2 As Int, CLR2 As ColorDrawable 
	OneThird=1/3
	If Not(LCARSeffects2.StarshipFont.IsInitialized ) Then LCARSeffects2.StarshipFont=Typeface.LoadFromAssets("federation.ttf")   
	'If Not(StarshipFont.IsInitialized ) Then StarshipFont= LCAR.LCARfont 
	
	If Stage<0 Then 
		Stage=Stage+Stage
	Else
		BG.drawrect(LCAR.SetRect(X-Radius,Y-Radius,Radius*2,Radius*2), Colors.Black, True,0)
	End If
	If StatusMode>0 Then
		CLR= LCAR.LCARcolors.Get(StatusMode)
		Color = LCAR.GetColor(StatusMode,False,Alpha)
		LCAR.ActivateAA(BG, True)
		If Status.Length=0 Then Status= "CONDITION: " & CLR.Name.ToUpperCase 
		
		Points(0)=Radius*0.25
		Points(1)=Radius*OneThird
		Points(2)=Radius*0.4
		Points(3)=Radius*0.5
		Points(4)=Radius*0.7
		Points(5)=Radius*0.18'for square
		Points(6)=Radius*0.03'for bar
		Points(7)=Radius*0.01'for bar whitespace
		Points(8)=Alpha/16'for alpha
		Points(9)=Radius*0.9
		Points(10)=Points(6) + Points(7)
		
		If LCAR.AntiAliasing Then
			Angle=Radius*1.224
			X2=Trig.findXYAngle(Points(3),Points(0), Angle,49,True)
			Y2=Trig.findXYAngle(Points(3), Points(0), Angle,49,False)
			
			P.Initialize(X + X2 +1, Y - Y2-1)
			P.LineTo(X - X2-1, Y - Y2-1)
			P.LineTo(X + X2+1, Y + Y2+1)
			P.LineTo(X - X2-1, Y + Y2+1)
			BG.ClipPath(P)
			
			BG.DrawLine(X + Points(3)+1,Y - Points(0)-1, X + Radius, Y - Points(4)    , Color, 2)'right up
			BG.DrawLine(X - Points(3)-1,Y - Points(0)-1, X - Radius, Y - Points(4)    , Color, 2)'left up
			BG.DrawLine(X + Points(3)+1,Y + Points(0)+1, X + Radius, Y + Points(4)    , Color, 2)'right down
			BG.DrawLine(X - Points(3)-1,Y + Points(0)+1, X - Radius, Y + Points(4)    , Color, 2)'left down
			
			BG.RemoveClip
		End If

		'top half
		P.Initialize(X + Points(3),Y - Points(0))'bottom right corner
		P.lineto(X + Radius, Y - Points(4) )'top right corner
		P.LineTo(X + Radius, Y - Radius)'top right corner of entire square
		
		'right square
		P.LineTo(X + Radius, Y-Points(5))'top right
		P.LineTo(X + Points(4), Y-Points(5))'top left
		P.LineTo(X + Points(4), Y+Points(5))'bottom left
		P.LineTo(X + Radius, Y+Points(5))'bottom right
		
		'bottom half
		P.lineto(X + Radius, Y + Points(4) )'bottom right corner
		P.lineto(X + Points(3),Y + Points(0))'top right corner
		P.lineto(X - Points(3),Y + Points(0))'top left corner
		P.lineto(X - Radius, Y + Points(4) )'bottom left corner
		P.lineto(X - Radius, Y + Radius )'bottom left corner of entire square			bottom half
		P.lineto(X - Points(2), Y + Radius)'middle bottom left corner 					middle bottom left
		P.lineto(X - Points(2), Y + Points(1))'middle top left corner					middle top left
		P.lineto(X + Points(2), Y + Points(1))'middle top right corner					middle top right
		P.lineto(X + Points(2), Y + Radius)'middle bottom right corner 					middle bottom right
		P.lineto(X + Radius, Y + Radius )'bottom right corner of entire square
		
		'top half
		P.LineTo(X + Radius, Y - Radius)'return to top right corner of entire square	top half
		P.lineto(X + Points(2), Y - Radius)'middle top right corner						middle top right
		P.lineto(X + Points(2), Y - Points(1))'middle bottom right corner				middle bottom right
		P.lineto(X - Points(2), Y - Points(1))'middle bottom left corner				middle bottom left
		P.lineto(X - Points(2), Y - Radius)'middle top left corner						middle top left
		P.LineTo(X - Radius, Y - Radius)'top left corner
		
		'left square
		P.LineTo(X - Radius, Y-Points(5))'top left
		P.LineTo(X - Points(4), Y-Points(5))'top right
		P.LineTo(X - Points(4), Y+Points(5))'bottom right
		P.LineTo(X - Radius, Y+Points(5))'bottom left
		
		'top half
		P.LineTo(X - Radius, Y - Radius)'return to top left corner
		P.lineto(X - Radius, Y - Points(4))'top left corner of top half
		P.lineto(X - Points(3),Y - Points(0))'bottom left corner of top half
		
		BG.clippath(P)
		BG.DrawCircle(X,Y,Radius, Color,True,1)
		BG.RemoveClip
		
		If Text.Length = 0 Then Text = "ALERT"
		If TextSize=0 Then  TextSize= GetTextHeight(BG,    Radius*0.2, Text, LCARSeffects2.StarshipFont,True)
		BG.DrawText(Text, X,Y, LCARSeffects2.StarshipFont, TextSize, Color, "CENTER")
		textsize2=TextSize*OneThird
		BG.DrawText(Status, X, Y+ BG.MeasureStringHeight(Status, LCARSeffects2.StarshipFont , textsize2)*2, LCARSeffects2.StarshipFont,  textsize2, Color, "CENTER")
		
		'stage 0=brightest is at topmost position
		Alpha2=Alpha
		Y2=Y-Points(9) + (Points(10)*(Stage-1))
		Y3=Y+Points(9) - (Points(10)*(Stage+1))+Points(7)
		X2=X - Points(2) + Points(7)
		Width=X + Points(2) - Points(7)  - X2
		
		For temp = 1 To 5
			If Stage >=0  Then
				Y3=Y3+ Points(10)
				If Alpha2>0 AND Y2<Y - Points(1)-Points(6) Then
					'Color= lcar.GetColor(StatusMode,True,alpha2)
					CLR2.Initialize(LCAR.GetColor(StatusMode,True,Alpha2), Points(6)*0.5)
					'bg.DrawRect(lcar.SetRect(x2,y2, width, points(6)), Color, True,0)
					'bg.DrawRect(lcar.SetRect(x2,y3, width, points(6)), Color, True,0)
					BG.DrawDrawable(CLR2, LCAR.SetRect(X2,Y2, Width, Points(6)))
					BG.DrawDrawable(CLR2, LCAR.SetRect(X2,Y3, Width, Points(6)))
					Alpha2=Alpha2-Points(8)
				End If
				Y2=Y2- Points(10)
			End If
			Stage=Stage-1
		Next
	
	End If
	
	LCAR.ActivateAA(BG, False)
	Return TextSize
End Sub






Sub MakeClipPath(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int)
	Dim P As Path 
	P.Initialize(X,Y)
	P.LineTo(X+Width,Y)
	P.LineTo(X+Width,Y+Height)
	P.LineTo(X,Y+Height)
	BG.ClipPath(P)
End Sub

Sub DrawShieldStatus(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Stage As Int,Stage2 As Int, ColorID As Int, Alpha As Int)
	Dim Center As Point ,temp As Int ,HorOval As Rect, VerOval As Rect, HalfHeight As Int, HalfWidth As Int 'MaxShieldStages
	ColorID=LCAR.GetColor(ColorID,False, 255)
	HalfHeight=Height*0.5
	HalfWidth=Width*0.5
	Center=Trig.SetPoint(X+HalfWidth,Y+HalfHeight)
	'LCAR.DrawRect(BG,X,Y,Width,Height, Colors.black,0)
	 
	temp=Height/MaxShieldStages*Stage'height of oval at this stage
	VerOval = LCAR.SetRect(X,Center.Y-(temp*0.5)  ,Width,  temp)
	temp=Width/MaxShieldStages*(MaxShieldStages-1-Stage)'width of oval at inverted stage
	HorOval = LCAR.SetRect(Center.X-(temp*0.5), Y, temp, Height)
	
	BG.DrawOval(LCAR.SetRect(X,Y,Width,Height), Colors.Black , True, 2)
	LCAR.ActivateAA(BG,True)
	BG.DrawOval(LCAR.SetRect(X,Y,Width,Height), ColorID, False, 2)
	BG.DrawOval(HorOval, ColorID, False, 2)
	BG.DrawOval(VerOval, ColorID, False, 2)
	DrawEnterpriseD(BG, Center.X, Center.Y, HalfHeight, 0, 0,0)
	
	MakeClipPath(BG,X,Y+ API.IIF(Stage2=0, 0,HalfHeight), Width, HalfHeight)
	BG.DrawOval(VerOval, ColorID, False, 2)
	BG.RemoveClip 
	
	MakeClipPath(BG,X+ API.IIF(Stage2=0, 0,HalfWidth),Y, HalfWidth, Height)
	BG.DrawOval(HorOval, ColorID, False, 2)
	BG.RemoveClip
	
	LCAR.ActivateAA(BG,False)
	If Alpha<255 Then LCAR.DrawRect(BG,X,Y,Width,Height, Colors.ARGB(255-Alpha,0,0,0),0)
End Sub

Sub DrawRandomDots(BG As Canvas,X As Int, Y As Int, Width As Int,Height As Int, Color As Int, Dots As Int)
	Dim temp As Int 
	If Width>0 AND Height>0 Then
		For temp = 1 To Dots
			BG.DrawPoint(Rnd(X,X+Width), Rnd(Y, Y+Height), Color)
		Next
	End If
End Sub
Sub DrawEnterpriseD(BG As Canvas,X As Int, Y As Int, Width As Int, Height As Int, AngleColor As Int, Mode As Int) As Rect 
	Dim  W2 As Int ,H2 As Int ,src As Rect,Height2 As Int,Width2 As Int  ,CenterX As Int, CenterY As Int ,Dest As Rect 
	'small asset = height=137 width=(50*2) 
	'large asset = height=563 width=(128*2)   LoadUniversalBMP
	Width2=Width
	Select Case Mode
		Case 0'top view, small asset, width=along Y axis of picture
			If Not(Enterprise.IsInitialized ) Then Enterprise.Initialize(File.DirAssets, "ent.gif")
			If LCAR.redalert Then
				src=LCAR.SetRect(0,50, Enterprise.Width, 50)
			Else
				src=LCAR.SetRect(0,0, Enterprise.Width, 50)
			End If
			Height = 137 * (Width/100)
			W2=Width*0.5
			H2=Height*0.5
			If AngleColor=0 Then
				BG.DrawBitmap(Enterprise, src, LCAR.SetRect(X-H2,Y-W2+1,Height,W2))
				BG.DrawBitmapflipped(Enterprise, src, LCAR.SetRect(X-H2,Y,Height,W2) ,True,False)
			End If
			Return Dest
		Case 1'side view, small asset
			'not available yet
			Return Dest
		Case 2'top view, large asset, use angle as color, width=along x axis of picture
			Height2 = 0.37102473498233215547703180212014 * Width'height of image/width of image * desired width
			If Height2>Height/2 Then 
				Height2=Height/2
				Width2 = Height2 * 2.6952380952380952380952380952381 'width/height
			End If
			src = LCAR.SetRect(0,128,566,210)
		Case 3'side view, large asset, use angle as color
			Height2 = 0.22380106571936056838365896980462*Width' 126/563
			If Height2>Height Then 
				Height2=Height
				Width = Height * 4.468253968253968253968253968254' 563/126
			End If
			src = LCAR.SetRect(1,1,563,126)
	End Select
	LCARSeffects2.LoadUniversalBMP(File.DirAssets , "starships2.png", LCAR.LCAR_NCC1701D )
	CenterX= X+ Width/2
	CenterY = Y+ Height/2
	W2=Width2*0.5
	H2=Height2*0.5
	'debug("DFHFDH X: " & X & " Y: " & Y & " WIDTH: " & Width & " HEIGHT: " & Height)
	If Mode=3 Then
		LCAR.DrawRect(BG,CenterX-W2,CenterY-H2 +2, Width2, Height2-3, AngleColor,0)
		Dest=LCAR.SetRect(CenterX-W2,CenterY-H2,Width2, Height2)
		BG.DrawBitmap(LCARSeffects2.CenterPlatform, src, Dest)
	Else
		Dest  = LCAR.SetRect(CenterX-W2,CenterY-Height2 +2, Width2, Height2*2-2)
		BG.DrawRect(Dest, AngleColor, True, 0)
		'LCAR.DrawRect(BG,CenterX-W2,CenterY-Height2 +2, Width2, Height2*2-2, AngleColor,0)
		BG.DrawBitmapflipped(LCARSeffects2.CenterPlatform, src, LCAR.SetRect(CenterX-W2,CenterY - Height2 +2, Width2, Height2), True,False)
		BG.DrawBitmap(LCARSeffects2.CenterPlatform, src, LCAR.SetRect(CenterX-W2,CenterY,Width2, Height2))
	End If
	Return Dest
End Sub