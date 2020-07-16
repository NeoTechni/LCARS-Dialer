B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=StaticCode
Version=6.77
@EndOfDesignText@
'1:28 autodestruct is offline

'cache xy speeds for angles

'Code module
'Subs in this code module will be accessible from all modules.
Sub Process_Globals
	'These global variables will be declared once when the application starts.
	'These variables can be accessed from all modules.
	
	'Universal buffer stuff
	Dim CenterPlatformID As Int, CenterPlatform As Bitmap ,WasInit As Boolean,UNIFILE As String 

	'graph stuff
	Type Graph(ID As Int, Points As List, MaxPoints As Int, CurrentPoint As Int, IsClearing As Boolean,IsClean As Boolean, ExpandWhenFull As Int, BracketX As Int)
	Dim GraphList As List 
	GraphList.Initialize 
	
	'Omegastuff
	Dim CachedOmega As Rect ,TopTextWidth As Int, OmegaNeedsInit As Boolean 
	Dim StarshipFont As Typeface
	
	'Random number stuff
	Type NumLin(Lines As Int, RedAlert As Int, RandomizeFullList As Int )
	Type NumCol(Digits As Int, Align As Int, ColorID As Int)
	Type NumLis(Columns As List, Values As List, ColorID As Int, Age As Int, ID As Int, TotalWidth As Int)
	Dim Numbers As List, LineList As List ,NumSection As Int ,LastSecond As Int,RandomizeFullList As Boolean 
	
	'Adv. Drawing stuff
	'Dim mMatrix As ABMatrix, mPaint As ABPaint, mCamera As ABCamera,isAdvInit As Boolean 
	Dim AMBIENT_LIGHT As Int: 		AMBIENT_LIGHT = 55		'Ambient light intensity
    Dim DIFFUSE_LIGHT As Int: 		DIFFUSE_LIGHT = 200		'Diffuse light intensity
    Dim SPECULAR_LIGHT As Float: 	SPECULAR_LIGHT = 70		'Specular light intensity
    Dim SHININESS As Float: 		SHININESS = 200			'Shininess constant
    Dim MAX_INTENSITY As Int: 		MAX_INTENSITY = 255		'The Max intensity of the light'0xFF

End Sub

Sub TempCanvas As Canvas
	Dim BG As Canvas 
	If Not(CenterPlatform.IsInitialized) Then CenterPlatform.InitializeMutable(1,1)
	BG.Initialize2(CenterPlatform)
	Return BG
End Sub
Sub InitUniversalBMP(Width As Int, Height As Int, ElementType As Int) As Canvas 
	Dim BG As Canvas, NeedsInit As Boolean 
	WasInit=False
	If Not(CenterPlatform.IsInitialized ) Or CenterPlatformID <> ElementType Then 
		NeedsInit=True
	Else If CenterPlatform.Height<>Height Or CenterPlatform.Width <> Width Then
		NeedsInit=True
	End If
	If NeedsInit Then 
		CenterPlatform.InitializeMutable(Width,Height)
		CenterPlatformID = ElementType
		WasInit=True
		UNIFILE=""
	End If
	BG.Initialize2(CenterPlatform)
	Return BG
End Sub
Sub LoadUniversalBMP(Dir As String, Filename As String, ElementType As Int) As Boolean  
	Dim tempstr As String 
	If Filename.length >0 Then
		tempstr=File.Combine(Dir,Filename)
		If Not(CenterPlatform.IsInitialized ) OR CenterPlatformID <> ElementType OR tempstr <> UNIFILE Then 
			If File.Exists(Dir,Filename) Then
				Try
					'If CenterPlatform.IsInitialized then BitMap.recycle
					CenterPlatform.Initialize(Dir,Filename)
					CenterPlatformID = ElementType
					WasInit=True
					UNIFILE=tempstr
					Return True
				Catch
					Return False
				End Try
			End If
		End If
		Return True
	End If
End Sub









Sub ClearRandomNumbers
	LineList.Initialize 
	NumSection=0
	Numbers.Initialize 
End Sub
Sub InitRandomNumbers(ElementType As Int, IncrementalUpdates As Boolean) As Boolean 
	If ElementType <> NumSection Then 
		ClearRandomNumbers
		NumSection=ElementType
		RandomizeFullList = IncrementalUpdates
		LastSecond= DateTime.GetSecond( DateTime.Now )
		Return True 
	End If
	Return False
End Sub
Sub SetColRowColorID(Row As Int, Col As Int, ColorID As Int)
	Dim Rows As NumLis, Cols As NumCol 
	Rows = Numbers.Get(Row) 
	Cols = Rows.Columns.Get(Col)
	Cols.ColorID=ColorID
End Sub
'Digits (-number has no padding), align (1=left -1=right)
Sub AddRowsOfNumbers(ID As Int,Rows As Int, ColorID As Int, Data As List)
	Dim temp As Int
	For temp = 1 To Rows
		AddRowOfNumbers(ID, ColorID,Data)
	Next
End Sub
Sub FindFirstLine(ID As Int,Index As Int) As NumLis
	Dim temp As Int , Row As NumLis, LineIndex As Int  
	For temp = 0 To Numbers.Size-1
		Row= Numbers.Get(temp)
		If Row.ID = ID Then 
			If Index=LineIndex Then
				Return Row
			Else
				LineIndex=LineIndex+1
			End If
		End If
	Next
End Sub
Sub DuplicateFirstLines(ID As Int, Count As Int)
	Dim temp As Int, Row As NumLis 
	Row = FindFirstLine(ID,0)
	For temp = 1 To Count
		DuplicateFirstLine(Row)
	Next
End Sub
Sub DuplicateFirstLine(Src As NumLis)
	Dim Row As NumLis , temp As Int 
	Row.Initialize 
	Row.id = Src.ID 
	Row.Columns.Initialize 
	Row.ColorID = Src.ColorID 
	For temp = 0 To Src.Columns.Size-1
		Row.Columns.Add( Src.Columns.Get(temp) )
	Next
	RandomizeRow(Row)
	AddLine(Src.ID )
	Numbers.Add(Row)
End Sub

Sub DrawNumberBlock(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, ColorID As Int, ID As Int, ElementType As Int, Text As String )
	Dim Font As Typeface , MaxSize As Int 
	Font = LCAR.LCARfont 'Else Font = StarshipFont 
	If InitRandomNumbers(ElementType, True) Then 
		MaxSize = Max(LCAR.ScaleHeight,LCAR.ScaleWidth) 
		MakeRowOfRandomNumbers(BG, Font, LCAR.Fontsize, MaxSize, ID, ColorID)
	End If
	LCAR.DrawRect(BG,X,Y,Width+1,Height,Colors.black, 0)
	If DrawRandomNumbers(BG,X,Y, Font,  LCAR.Fontsize, Width, Height, ID ) =0 Then ClearRandomNumbers
	If Text.Length >0 Then LCAR.DrawText(BG, X+Width+1, Y+2, Text, ColorID, 3,False,255,-1)
End Sub

Sub MakeRowOfRandomNumbers(BG As Canvas, Font As Typeface, FontSize As Int, Width As Int, ID As Int, ColorID As Int)
	Dim CharWidth As Int ,TotalWidth As Int, CurrentWidth As Int , Row As NumLis ,Col As NumCol ,Digits As Int, Align As Int 
	CharWidth = BG.MeasureStringWidth("0", Font,FontSize)
	Row.Initialize 
	Row.ID = ID 
	Row.Columns.Initialize 
	Row.ColorID = ColorID 
	Row.TotalWidth=Width
	Do Until TotalWidth>=Width
		Digits = Rnd(1,8) 
		If Rnd(0,2)=0 Then Digits = -Digits
		Align= Rnd(-1,1)
		CurrentWidth=(Abs(Digits)+2)*CharWidth
		Row.Columns.Add(AddColOfNumbers(Digits,Align))
		TotalWidth=TotalWidth+CurrentWidth
	Loop
	RandomizeRow(Row)
	AddLine(ID)
	Numbers.Add(Row)
End Sub

'Digits (-number has no padding), align (1=left -1=right)
Sub AddRowOfNumbers(ID As Int, ColorID As Int, Data As List)As Int 
	Dim Row As NumLis,temp As Int '10^digits
	Row.Initialize 
	Row.ID = ID
	Row.Columns.Initialize 
	For temp = 0 To Data.Size-1 Step 2
		Row.Columns.Add ( AddColOfNumbers(Data.Get(temp), Data.Get(temp+1) ) )
	Next
	Row.ColorID=ColorID
	RandomizeRow(Row)
	AddLine(ID)
	Numbers.Add(Row)
	Return Numbers.Size-1
End Sub
Sub AddColOfNumbers(Digits As Int, Align As Int)As NumCol
	Dim temp As NumCol
	temp.Initialize 
	temp.Digits=Digits
	temp.Align=Align
	Return temp
End Sub
Sub IncrementNumbers As Boolean 
	Dim temp As Int , Line As NumLin,Row As NumLin ,Cols As NumLis ,temp2 As Int 
	If Numbers.IsInitialized Then
		'debug( DateTime.GetSecond( DateTime.Now )    & " "  & LastSecond & "   " &  Numbers.Size )
		If DateTime.GetSecond( DateTime.Now ) <> LastSecond OR Numbers.Size=0 Then
			LastSecond= DateTime.GetSecond( DateTime.Now )
			If Not(RandomizeFullList) Then
				For temp = 0 To Numbers.Size-1
					RandomizeRow( Numbers.Get(temp) )
				Next
			Else
				For temp = 0 To LineList.Size-1
					Row = LineList.Get(temp)
					Cols = FindFirstLine(temp, Row.RandomizeFullList)
					RandomizeRow(Cols)
					For temp2 = 0 To Row.Lines-1
						If temp2 <> Row.RandomizeFullList Then
							Cols = FindFirstLine(temp, temp2)
							AgeRow(Cols)
						End If
					Next
					Row.RandomizeFullList = (Row.RandomizeFullList+1) Mod Row.Lines 
				Next
			End If
			If LCAR.RedAlert Then
				For temp = 0 To LineList.Size-1
					Line = LineList.Get(temp)
					Line.RedAlert = (Line.RedAlert+1)  Mod Line.Lines 
				Next
			End If
			Return True
		End If
	End If
	Return False
End Sub
Sub RandomizeRow(Row As NumLis)
	Dim temp As Int, Col As NumCol  
	If Not(Row = Null ) Then
		Row.Values.Initialize 
		Row.Age=0
		For temp = 0 To Row.Columns.Size-1
			Col = Row.Columns.Get(temp)
			Row.Values.Add(RandomNumber(Abs(Col.Digits),Col.Digits>0))
		Next
	End If
End Sub
Sub AgeRow(Row As NumLis)
	Row.Age = Row.Age+1
End Sub
Sub DrawRandomNumbers(BG As Canvas, X As Int, Y As Int,Font As Typeface, FontSize As Int, MaxWidth As Int, MaxHeight As Int, ID As Int ) As Int
	Dim temp As Int, LineSize As Int , CharWidth As Int ,Height As Int,FirstLine As Int, Src As NumLis, Curr As NumLis , Line As NumLin , CurrLin As Int, LineIndex As Int,RedAlert As Boolean , DoBG As Boolean,Drawn As Boolean 
	LineSize=BG.MeasureStringHeight("1234567890", Font, FontSize)+2
	If ID<0 Then 
		DoBG=True 
		Y=Y+LineSize-1
		ID=Abs(ID)
	End If
	CharWidth = BG.MeasureStringWidth("0", Font,FontSize)
	CurrLin=-1
	
	For temp = 0 To Numbers.Size-1
		Curr = Numbers.Get(temp)
		'debug("Checking row: " & temp & " for ID " &  ID & ", it was " &  Curr.ID)
		If Curr.ID = ID Then
			'debug("Drawing row " & temp)
			If LCAR.RedAlert Then
				If CurrLin<> ID Then Line = LineList.Get(ID)
				RedAlert = Line.RedAlert = LineIndex
			End If
			DrawRow(BG, X,Y, Font,FontSize,CharWidth, Curr, ID ,MaxWidth, RedAlert,DoBG,LineSize)
			Drawn=True
			Y=Y+LineSize
			If MaxHeight>0 Then 
				If Not(Src.IsInitialized ) Then Src =Numbers.Get(temp)
				Height=Height+LineSize
				If Height>MaxHeight Then Exit
			End If
			LineIndex=LineIndex+1
		End If
	Next
	
	If MaxHeight>0 AND Height+LineSize<=MaxHeight AND Src.IsInitialized Then'add more
		CharWidth=0
		For temp = Height To  MaxHeight Step LineSize
			Height=Height+LineSize
			If Height< MaxHeight Then
				DuplicateFirstLine(Src)
				CharWidth=CharWidth+1
			End If
		Next
	End If
	
	If Drawn Then 
		Return LineSize
	Else
		Return 0
	End If
End Sub
Sub DrawRow(BG As Canvas, X As Int, Y As Int, Font As Typeface, FontSize As Int, CharWidth As Int, Row As NumLis, ID As Int, MaxWidth As Int ,RedAlert As Boolean ,DoBackGround As Boolean,LineHeight As Int )
	Dim temp As Int , Col As NumCol,Text As String  ,Color As Int ,Width As Int,State As Boolean 
	If Row.ID = ID Then
		If MaxWidth>0 Then MaxWidth=MaxWidth+X
		For temp = 0 To Row.Columns.size-1
			Col = Row.Columns.Get(temp)
			Text = Row.Values.Get(temp)
			Width = Abs(Col.Digits) * (CharWidth+2)
			If LCAR.RedAlert Then 
				Color = LCAR.LCAR_RedAlert 
			Else 
				Color = API.IIF(Col.ColorID =0, Row.ColorID,Col.ColorID)
			End If
			'debug("Col " & temp & " = " & Text & " - " & Color)
			
			If RedAlert Then 
				State= True
			Else
				State= (Row.age<2) AND RandomizeFullList
			End If
			Color = LCAR.GetColor(Color, State, 255)
			If DoBackGround Then LCAR.DrawRect(BG, X,Y-LineHeight ,Width-2,LineHeight+2, Colors.black , 0)
			If Col.Align=-1 Then'right align
				BG.DrawText(Text, X+Width,Y,Font, FontSize, Color, "RIGHT")
			Else'left align
				BG.DrawText(Text, X,Y,Font, FontSize, Color, "LEFT")
			End If
			X=X+Width+CharWidth
			
			If X>= MaxWidth AND MaxWidth>0 Then temp=Row.Columns.size
		Next
		Return True
	End If
	Return False
End Sub
Sub AddLine(ID As Int)
	Dim Line As NumLin 
	If ID< LineList.Size Then
		Line = LineList.Get(ID)
		Line.Lines = Line.Lines+1
	Else
		Line.Initialize 
		Line.Lines=1
		LineList.Add(Line)
	End If
	'debug("ID: " & ID & " has " & Line.Lines )
End Sub







Sub InitAdvDrawingStuff
'	If Not(isAdvInit) Then
'		mMatrix.Initialize 
'		mPaint.Initialize
'		mPaint.SetAntiAlias(LCAR.AntiAliasing)
'	    mPaint.SetFilterBitmap(LCAR.AntiAliasing)
'		isAdvInit=True
'	End If
End Sub
Sub DrawTrapezoid(myBG As Canvas, BMP As Bitmap ,SRC As Rect , X As Int, Y As Int, TopWidth As Int, BottomWidth As Int, Height As Int, Alpha As Int)
	Dim BottomLeft As Int 
	'lcar.ExDraw.save2(BG, lcar.ExDraw.MATRIX_SAVE_FLAG)
'	If TopWidth=0 Then TopWidth=BottomWidth
'	If BottomWidth=0 Then BottomWidth=TopWidth
'	If BottomWidth> TopWidth Then X = X + (BottomWidth-TopWidth)/2
'	BottomLeft = X+ TopWidth/2 - BottomWidth/2
'	If SRC=Null Then SRC.Initialize(0,0, BMP.Width, BMP.Height)
'	'mPaint.SetAlpha(Alpha)
'	mMatrix.setPolyToPoly( Array As Float(SRC.Left,SRC.Top,  SRC.Right,SRC.Top,   SRC.Right, SRC.Bottom,        SRC.Left,SRC.Bottom), 0,  Array As Float( X,Y, X+TopWidth,Y, BottomLeft+BottomWidth, Y+Height, BottomLeft, Y+Height   ), 0,4)
'	LCAR.ExDraw.drawBitmap4(myBG, BMP,  mMatrix, mPaint)
	'call LCAR.ExDraw.restore(BG) before Activity.Invalidate 
End Sub
'Sub DrawBMP(myBG As Canvas, BMP As Bitmap, SrcX As Int, SrcY As Int, SrcWidth As Int, SrcHeight As Int, X As Int, Y As Int, Width As Int, Height As Int, Alpha As Int, FlipX As Boolean, FlipY As Boolean)
'	Dim Dest() As Float ,Right As Int, Bottom As Int
'	LCAR.ExDraw.save2(myBG, LCAR.ExDraw.MATRIX_SAVE_FLAG)
'	If SrcWidth=0 Then SrcWidth = BMP.Width 
'	If SrcHeight=0 Then SrcHeight=BMP.Height 
'	'mPaint.SetAlpha(Alpha)
'	Right=X+Width
'	Bottom=Y+Height
'	If FlipX AND FlipY Then
'	
'	Else If FlipX Then
'		
'	Else If FlipY Then
'		Dest=Array As Float(X,Bottom, Right,Bottom, X,Y,   Right,Y)
'	Else
'		Dest=Array As Float( X,Y, 	Right,Y, 		Right, Bottom, 		X,Bottom )
'	End If
'	mMatrix.setPolyToPoly( Array As Float(SrcX,SrcY,         SrcX+SrcWidth, SrcY,      SrcX+SrcWidth,SrcY+SrcHeight,	SrcX,SrcY+SrcHeight), 0, Dest, 0,4)
'	LCAR.ExDraw.drawBitmap4(myBG, BMP,  mMatrix, mPaint)
'	LCAR.ExDraw.restore(myBG)
'End Sub
Sub SetupShine(RotationX As Float)
	Dim cosRotation As Double,  intensity As Int, highlightIntensity As Int, light As Int,  highlight As Int

	cosRotation = Cos(Trig.PI * RotationX / 180)
	intensity = Min(MAX_INTENSITY, AMBIENT_LIGHT + (DIFFUSE_LIGHT * cosRotation))
	highlightIntensity = Min(MAX_INTENSITY, SPECULAR_LIGHT * Power(cosRotation,SHININESS))	
	light = Colors.rgb(intensity, intensity, intensity)
	highlight = Colors.rgb(highlightIntensity, highlightIntensity, highlightIntensity)
'    mPaint.SetLightingColorFilter(light, highlight)   
End Sub











Sub IsWithin(X As Int, Y As Int, RCT As Rect) As Boolean 
	If X >= RCT.Left Then
		If X <= RCT.Right Then
			If Y >= RCT.Top Then
				If Y <= RCT.Bottom 	Then
					Return True
				End If
			End If
		End If
	End If
End Sub















Sub CopyPlistToPath(Plist As List, P As Path, BG As Canvas, Color As Int,Stroke As Int, DoDraw As Boolean, DoDrawAll As Boolean  ) As Rect 
	Dim Count As Int, temp As Point, temp2 As Point , dest As Rect 
	Dim Left As Int, Right As Int, Top As Int, Bottom As Int 
	Left=-1
	Top = -1
	
	temp = Plist.Get(0)
	P.Initialize(temp.X, temp.Y)
	If DoDraw Then LCAR.ActivateAA(BG, True)
	For Count = 1 To Plist.Size-1
		temp2 = Plist.Get(Count)
		
		If temp2.X< Left OR Left=-1 Then Left = temp2.X 
		If temp2.X> Right Then Right = temp2.X 
		If temp2.y< Top OR Top = -1 Then Top = temp2.y 
		If temp2.y> Bottom Then Bottom = temp2.y 
		
		P.LineTo(temp2.X, temp2.Y)
		If DoDraw  Then
			If (temp.x <> temp2.X AND temp.Y <> temp2.Y) OR DoDrawAll Then
				BG.DrawLine(temp.x,temp.y, temp2.X,temp2.Y, Color, Stroke)
			End If
			temp.x=temp2.X
			temp.y=temp2.Y 
		End If
	Next
	If DoDraw Then BG.ClipPath(P)
	
	dest.Initialize(Left,Top,Right,Bottom)
	Return dest
End Sub

Sub MakePoint(P As List, X As Int, Y As Int)As Point 
	Dim temp As Point 
	If Not (P.IsInitialized ) Then P.Initialize
	temp=Trig.SetPoint(X,Y)
	P.Add( temp )
	Return temp
End Sub
Sub RandomENT As String 
	Return RandomNumber(2,True) & "-" & RandomNumber(3,True)
End Sub






Sub DrawLegacyButton(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Color As Int, Text As String, Align As Int)
	Dim temp As ColorDrawable ,CornerRadius As Int,UseOtherFont As Boolean ,WhiteSpace As Int 
	If Align<0 Then 
		CornerRadius=Abs(Align)
	Else
		CornerRadius=10
	End If
	If Width<0 Then
		Width=Abs(Width)
		UseOtherFont=True
		CornerRadius=Height/2
	End If
	If Color <> Colors.Transparent Then
		temp.Initialize(Color, CornerRadius)
	'LCAR.ActivateAA(BG,True)
		BG.DrawDrawable(temp, LCAR.SetRect(X,Y,Width,Height))
	End If
	'LCAR.DrawTextbox(BG, Text, LCAR.LCAR_Black, X+CornerRadius,Y+CornerRadius, Width-CornerRadius*2,Height-CornerRadius*2, Align)
	If Text.Length>0 Then 	
		WhiteSpace= API.IIF( Height < LCAR.Fontsize*2 + 30 , 5  ,15)
		'If UseOtherFont Then
			LCAR.DrawTextbox(BG, Text, LCAR.LCAR_Black, X+CornerRadius/2,Y+WhiteSpace, Width-CornerRadius,Height-(WhiteSpace*2), Align)
		'Else
			'LCAR.DrawLegacyText(BG, X+CornerRadius,Y+CornerRadius, Width-CornerRadius*2,Height-CornerRadius*2, Text, 15, Colors.Black, Align)
		'End If
	End If
	'LCAR.ActivateAA(BG,False)
End Sub




Sub UnusedGraphID As Int
	Dim temp As Int
	Do While FindGraph(temp)>-1
		temp=temp+1
	Loop
	Return temp
End Sub
Sub CountUnusedPoints(GraphID As Int) As Int
	Dim temp As Graph ,temp2 As Int 
	temp = GraphList.Get(GraphID)
	For temp2 = 0 To temp.Points.Size-1
		If temp.Points.Get(temp2) >0 Then Return temp2-1
	Next
End Sub
Sub AddBlankPoints(GraphID As Int, Points As Int)
	Dim temp As Graph ,temp2 As Int 
	If Points>0 Then
		temp = GraphList.Get(GraphID)
		For temp2 = 1 To Points
			AddPoint(GraphID,0)
		Next
	End If
End Sub
Sub RemovePoints(GraphID As Int, Points As Int)
	Dim temp As Graph ,temp2 As Int 
	temp = GraphList.Get(GraphID)
	For temp2 = Points-1 To 0 Step -1
		temp.Points.RemoveAt(temp2)
	Next
	temp.IsClean=False
	temp.CurrentPoint = Max(0 , temp.CurrentPoint - Points)
End Sub
Sub FindGraph(ID As Int) As Int
	Dim temp As Graph ,temp2 As Int 
	For temp2 = 0 To GraphList.Size-1
		temp= GraphList.Get(temp2)
		If temp.ID = ID Then Return temp2
	Next
	Return -1
End Sub

Sub isGraphClean(GraphID As Int) As Boolean 
	Dim temp As Graph 
	temp = GraphList.Get(GraphID)
	Return temp.IsClean 
End Sub
Sub GetGraph(GraphID As Int) As Graph 
	Return GraphList.Get(GraphID)
End Sub
Sub ClearGraph(GraphID As Int)
	Dim temp As Graph ,temp2 As Int 
	temp = GraphList.Get(GraphID)
	temp.IsClean=False
	temp.IsClearing =False
	temp.CurrentPoint=0
	temp.Points.Initialize 
End Sub
Sub AddGraph(ID As Int, MaxPoints As Int, ExpandWhenFull As Boolean ) As Int
	Dim temp As Graph 
	temp.Initialize 
	If ExpandWhenFull Then temp.ExpandWhenFull=MaxPoints
	temp.MaxPoints=MaxPoints
	temp.ID =ID 
	temp.Points.Initialize 
	GraphList.Add(temp)
	Return GraphList.Size-1
End Sub






Sub AddPoints(GraphID As Int, RecData() As Byte) As Boolean 
	Dim temp As Graph ,temp2 As Int ,temp3 As Int,temp4 As Int
	temp = GraphList.Get(GraphID)
	If Not(temp.IsClearing) Then
		temp.IsClearing=True
		temp2= RecData.Length /2
		temp4=0 'temp.CurrentPoint
		If temp.IsClean  OR temp.Points.Size <> temp2 Then'only update if it's been drawn already (vsync!)
			temp.Points.Initialize  
			For temp2 = 0 To RecData.Length -1 Step 2'RemoveRepeatedPoints(RecData)
				temp3 = API.Combine(RecData(temp2+1), RecData(temp2))
				
				If Abs(temp3)> temp4 Then
					temp4 = Abs(temp3)
					temp.ExpandWhenFull= temp2'location of maximum point
					'If temp4>temp.CurrentPoint Then temp.CurrentPoint=temp4 'highest point value
				End If
				temp.Points.Add(temp3)
				'debug("Added: " & temp3 & " of " & temp.CurrentPoint)
			Next
			If temp4>temp.CurrentPoint Then 
				temp.CurrentPoint=temp4 'highest point value
			'Else If temp4<temp.CurrentPoint Then 
			'	temp.CurrentPoint = LCAR.Increment(temp.CurrentPoint, 1000, temp4)
			End If
			
			'debug("Max this cycle=" & temp4 & " all cycles=" & temp.CurrentPoint) 
			'temp.CurrentPoint=temp4 'highest point value
			'temp.CurrentPoint= Max(temp4,temp.CurrentPoint)
			temp.IsClean=False
		End If
		temp.IsClearing=False
		Return True
	End If
End Sub

Sub Get2toTheN(Value As Int) As Int
	Dim temp As Int ,temp2 As Int 
	temp = 1
	Do Until temp > Value
		temp2=temp
		temp=temp*2
	Loop
	Return temp2
End Sub





'Sub RemoveRepeatedPoints(RecData() As Byte) As Int'didnt work
'	Dim temp As Int , Count As Int , Current As Int , First As Int 
'	First = API.Combine(RecData(1), RecData(0))
'	For temp =2 To RecData.Length -1 Step 2
'		Current = API.Combine(RecData(temp+1), RecData(temp))
'		If Current = First Then
'			Count=Count+1
'		Else
'			Return Count
'		End If
'	Next
'End Sub

Sub RemoveGraph(GraphID As Int)
	If GraphID>-1 AND GraphID< GraphList.Size Then  GraphList.RemoveAt(GraphID)
End Sub
Sub AddPoint(GraphID As Int, Value As Int)
	Dim temp As Graph ,temp2 As Double 
	temp = GraphList.Get(GraphID)
	If temp.CurrentPoint = temp.MaxPoints  Then
		If temp.ExpandWhenFull>0 Then
			temp.MaxPoints = temp.MaxPoints+temp.ExpandWhenFull
			temp.CurrentPoint=temp.CurrentPoint+1
		Else
			temp.CurrentPoint=0
		End If
	Else
		temp.CurrentPoint=temp.CurrentPoint+1
	End If
	temp2=Value*0.01
	If temp.CurrentPoint < temp.Points.Size Then
		temp.Points.Set(temp.CurrentPoint, temp2)
	Else
		temp.Points.Add(temp2)
	End If
	temp.IsClean=False
End Sub
Sub IncrementGraph(GraphID As Int, Style As Int)
	Dim temp As Graph 
	If Style = 4 Then
		temp = GraphList.Get(GraphID)
		If temp.BracketX <> temp.ExpandWhenFull Then
			temp.BracketX = LCAR.Increment(temp.BracketX, 25, temp.ExpandWhenFull)
		End If
	End If
End Sub
Sub DrawGraph(GraphID As Int, BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, ColorID As Int, GraphColor As Int, Alpha As Int, Style As Int, Cols As Int, Rows As Int)
	Dim  tempGraph As Graph ,PointWidth As Int , PrevPoint As Double ,CurrPoint As Double , temp As Int, temp2 As Int, currX As Int, Color As Int,X2 As Int,X3 As Int, isclean As Boolean  ',P As Path 
	tempGraph = GraphList.Get(GraphID)
	'If Style=4 Then
	'	PointWidth= Width / tempGraph.Points.Size
	'Else
		PointWidth= Width / tempGraph.MaxPoints 
	'End If
	LCAR.ActivateAA(BG,True)
	isclean=True
	currX=X
	If ColorID>-1 Then Color=LCAR.GetColor(ColorID, False,Alpha)
	LCARSeffects.MakeClipPath(BG,X-1,Y-1,Width+1,Height)
	'P.Initialize(X-1,Y-1)
	'P.LineTo(X+Width,Y-1)
	'P.LineTo(X+Width,Y+Height)
	'P.LineTo(X-1,Y+Height)
	'BG.ClipPath(P)
	
	Select Case Style
		Case 0 '/\ relative to center, 1 up and 1 down 
			If tempGraph.Points.Size>0 Then
				PrevPoint=tempGraph.Points.Get(0)
				For temp = 1 To tempGraph.Points.Size-1
					CurrPoint=tempGraph.Points.Get(temp)
					DrawPoint(BG, currX,Y, PointWidth, Height,Style, GraphColor, 1, PrevPoint,CurrPoint)
					currX=currX+PointWidth
					PrevPoint=CurrPoint
				Next
			End If
		Case 1,-1'/  relative to bottom
			PrevPoint=0
			'GraphColor=Colors.White 
			For temp = 0 To tempGraph.Points.Size-1
				CurrPoint=tempGraph.Points.Get(temp)
				DrawPoint(BG, currX,Y, PointWidth, Height,Style, GraphColor, 1, PrevPoint,CurrPoint)
				currX=currX+PointWidth
				PrevPoint=CurrPoint
			Next
			
		Case 2'|  bars
			For temp = 0 To tempGraph.Points.Size-1
				CurrPoint=tempGraph.Points.Get(temp)
				DrawPoint(BG, currX,Y, PointWidth, Height,Style, GraphColor, 1, PrevPoint,CurrPoint)
				currX=currX+PointWidth
			Next
			
		Case 3'circular
			DrawCircularGraph(BG, X+Width/2, Y+Width/2, Min(Width,Height)/2, 	tempGraph, GraphColor, Color, Cols, Rows)
		
		Case 4,5'frequency and spectrograph 		
			'.Currentpoint = max amplitude
			'.ExpandWhenFull = position of max amplitude
			'.IsClearing = locked. transferring data or drawing
			'.MaxPoints = tweened position of the brackets
			
			CurrPoint=2
			LCAR.DrawRect(BG,X-1,Y-1,Width+1,Height+1,Colors.Black,0)
			'If Style = 4 Then
				temp = API.IIF(LCAR.SmallScreen , 50,100)
				Width=Width-temp
				currX=currX+temp
			'Else 
			'	GraphColor = LCAR.GetColor(LCAR.LCAR_Orange, False, Alpha)
			'End If
			
			If tempGraph.MaxPoints=0 Then
				PointWidth = (tempGraph.Points.Size / Width) * CurrPoint
			Else
				PointWidth = tempGraph.Points.Size / tempGraph.MaxPoints
			End If
			'If (tempGraph.IsClearing) Then
			'	isclean=False
			'Else
				tempGraph.IsClearing=True
				Try
					If Style=4 Then tempGraph.BracketX = LCAR.Increment(tempGraph.BracketX, PointWidth*5, tempGraph.ExpandWhenFull)
					For temp = 0 To tempGraph.Points.Size-1 Step PointWidth
						PrevPoint=0
						For temp2 = temp To temp+PointWidth
							If temp2 < tempGraph.Points.Size Then
								PrevPoint = PrevPoint + tempGraph.Points.Get(temp2)
							Else
								PointWidth=PointWidth-1
							End If
							If temp2 = tempGraph.BracketX Then 	X3 = X2
						Next
						
						'debug(currX & " = " & PrevPoint & " " & PointWidth & " " & tempGraph.CurrentPoint)
						
						PrevPoint = (PrevPoint / PointWidth) / tempGraph.CurrentPoint
						If PrevPoint > tempGraph.CurrentPoint Then 
							tempGraph.CurrentPoint= PrevPoint
							PrevPoint=1
						End If
						'If Style=4 Then
							If LCAR.RedAlert Then
								GraphColor =GetRedColor(X2, Width)
							Else
								GraphColor = API.HSLtoRGB(X2/Width*239, 127,127,255)'currX/Width*239
							End If
						'End If
						
						DrawPoint(BG,currX,Y,1, Height,   Style, GraphColor, 1, 0, PrevPoint)
						currX=currX+CurrPoint
						X2=X2+CurrPoint
					Next
				Catch
					isclean = False
				End Try
				tempGraph.IsClearing=False
			'End If
			'If Style=4 Then
				temp = API.IIF(LCAR.SmallScreen , 50,100)
				DrawBox2(BG, X, temp, Y, Width, Height, Color, 60, 40, 2, X3)
			'End If
			
		
		Case Else
			LCAR.DrawUnknownElement(BG,X,Y,Width,Height, ColorID, False, Alpha, "UNKNOWN CHART TYPE")
	End Select
	LCAR.ActivateAA(BG,False)
	
	If Style<3 AND ColorID>-1 Then 
		DrawCursor(BG,X,Y,Width,Height, Colors.White, PointWidth,2, tempGraph.MaxPoints *0.2,tempGraph.CurrentPoint)
		DrawBox(BG,X,Y,Width,Height,  Color, Cols,Rows,2,1)
	End If
	BG.RemoveClip 
	
	tempGraph.isclean=isclean
End Sub

Sub DrawCircularGraph(BG As Canvas, X As Int, Y As Int, Radius As Int, tempGraph As Graph, GraphColor As Int, BoxColor As Int, Cols As Int, Rows As Int)
	Dim DegreeWidth As Double , temp As Int , CurrValue As Double, NextValue As Double ,Inc As Double, Angle As Double , CurrCoord As Point, CurrPoint As Int, PrevCoord As Point 
	If tempGraph.Points.Size >1 Then
		DegreeWidth = 360 / tempGraph.Points.Size 
		CurrValue = Radius * tempGraph.Points.Get(0)
		Angle = DegreeWidth
		For temp = 0 To 359'curved method
			If temp>= Angle AND CurrPoint+1<tempGraph.Points.Size Then 
				CurrPoint=CurrPoint+1
				NextValue = Radius * tempGraph.Points.Get(  CurrPoint )
				Inc = (NextValue - CurrValue) / DegreeWidth
				Angle = Angle+DegreeWidth
				
				'debug(CurrPoint & "@" & temp & " up until " & Angle & " the desired radius will be " & NextValue & " incrementing from " & CurrValue & " by " & Inc)
			End If
			CurrCoord = Trig.FindAnglePoint(X,Y, CurrValue, temp)
			If temp>0 Then BG.DrawLine(PrevCoord.X,PrevCoord.Y, CurrCoord.X,CurrCoord.Y, GraphColor, 1)
			PrevCoord = Trig.SetPoint( CurrCoord.X, CurrCoord.Y)
			'debug("Angle: " & temp & " Radius " & CurrValue)
			CurrValue = CurrValue+Inc' LCAR.Increment(CurrValue, Inc, NextValue)
		Next
		
		
'		For temp = 0 To tempGraph.Points.Size - 1 'linear method
'			CurrValue = Radius * tempGraph.Points.Get(temp)
'			CurrCoord = Trig.FindAnglePoint(X,Y, CurrValue, Angle)
'			If temp>0 Then
'				BG.DrawLine(PrevCoord.X,PrevCoord.Y, CurrCoord.X,CurrCoord.Y, GraphColor, 1)
'			End If
'			PrevCoord = Trig.SetPoint( CurrCoord.X, CurrCoord.Y)
'			Angle=Angle+ DegreeWidth
'		Next 
	End If
	DrawRadar(BG,X,Y,Radius,BoxColor,Cols,Rows)
End Sub

Sub DrawRadar(BG As Canvas, X As Int, Y As Int, Radius As Int, Color As Int, Cols As Int, Rows As Int)
	Dim DegreeWidth As Double , temp As Int, CurrCoord As Point, Angle As Double
	If Cols>1 Then
		DegreeWidth = 360 / Cols 
		Angle=0
		For temp = 1 To Cols
			CurrCoord = Trig.FindAnglePoint(X,Y, Radius, Angle)
			BG.DrawLine(X, Y,  CurrCoord.X,CurrCoord.Y, Color, 1)
			Angle=Angle+DegreeWidth
		Next
	End If
	If Rows>1 Then
		DegreeWidth= Radius/ Rows
		Angle=0
		For temp = 1 To Rows-1
			Angle=Angle+DegreeWidth
			BG.DrawCircle(X,Y,Angle,Color, False,1)
		Next
	End If
	BG.DrawCircle(X,Y,Radius-1,Color, False,2)
End Sub

Sub GetRedColor(X As Int, Width As Int) As Int 
	Width=Width/2
	If X< Width Then
		Return Colors.RGB(  64 + X/Width*192    ,0,0)
	Else
		X=X-Width
		X= X/Width*255 
		Return Colors.RGB(255, X,X)
	End If
End Sub
Sub DrawPoint(BG As Canvas, X As Int, Y As Int, PointWidth As Int, Height As Int, Style As Int, Color As Int, Stroke As Int, PrevValue As Double, NewValue As Double )
	Dim X2 As Int,X3 As Int, Y2 As Int, Y3 As Int, HalfHeight As Int  
	HalfHeight=Height*0.5
	PointWidth=Max(2, PointWidth)
	Select Case Style
		Case 0'/\ relative to center, 1 up and 1 down
			X2=X+PointWidth*0.5
			Y2=GetPoint(Y,HalfHeight,Height,PrevValue, True,False)    'Y + HalfHeight + ( HalfHeight * (1-PrevValue))
			Y3=GetPoint(Y,HalfHeight,Height,NewValue, True,True)' HalfHeight * (1-NewValue)
			BG.DrawLine(X,Y2,X2,Y3, Color, Stroke)
			X3=X+PointWidth
			Y2=GetPoint(Y,HalfHeight,Height,NewValue, True,False)'Y+HalfHeight + Y3
			BG.DrawLine(X2,Y3,X3, Y2  , Color, Stroke)
		Case 1,-1'/  relative to bottom
			X2=X+PointWidth
			Y2=Y + Height*(1-PrevValue)  'Y + Height - Height*PrevValue
			Y3=Y + Height*(1-NewValue)  '  Y + Height - Height*NewValue
			BG.DrawLine(X,Y2,X2,Y3, Color, Stroke)
		Case 2'|  bars
			Y3= Height* NewValue*2
			Y2= Y+ HalfHeight - (Y3*0.5)
			BG.DrawRect( LCAR.SetRect(X, Y2, PointWidth-1, Y3), Color, True,0)
			
			
		Case 4'lines, relative to center
			Y3= Height* NewValue
			If Y3>Height Then 
				Y3=Height 
			Else If Y3<-Height Then 
				Y3=-Height
			End If
			Y2= Y+ HalfHeight - (Y3*0.5)
			BG.DrawLine(X, Y2,  X, Y2+Y3,  Color,2)
			
			
		Case 5'lines relative to center
			NewValue=NewValue*100
			Y3= Height* Abs(NewValue)
			If NewValue>0 Then
				Y2= Y+ HalfHeight - (Y3*0.5)
			Else
				Y2= Y+ HalfHeight
			End If
			BG.DrawLine(X, Y2,  X, Y2+Y3,  Color,2)
			
			'Y2= Y+ Height
			'HalfHeight= Height* NewValue*50
			'Y3= Y2 - HalfHeight
			'BG.DrawLine(X, Y3,  X, Y2,  Color,2)
	End Select
End Sub
Sub GetPoint(Y As Int, HalfHeight As Int, Height As Int, Value As Double , RelativeToCenter As Boolean , AboveCenter As Boolean ) As Int 
	Dim temp As Int 
	If RelativeToCenter Then
		temp = Y+HalfHeight
		If AboveCenter Then
			Return temp - (HalfHeight*Value)
		Else
			Return temp + (HalfHeight*Value)
		End If
	Else
		Return Y+ (Height*(1-Value))
	End If
End Sub

Sub DrawCursor(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Color As Int, PointWidth As Int, PointsGradient As Int,PointsBlack As Int, StartPoint As Int)
	Dim X2 As Int, Width2 As Int 

	X2=X+(StartPoint-PointsGradient)*PointWidth
	Width2=PointWidth*PointsGradient
	LCAR.DrawGradient(BG, Colors.ARGB(0,0,0,0), Color, 6,  X2, Y, Width2,Height, 0,0)
	X2=X2+Width2-2
	Width2=PointWidth*PointsBlack
	BG.DrawRect(LCAR.SetRect(X2,Y,Width2,Height), Colors.Black, True,0)
End Sub

Sub DrawBox(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Color As Int, Cols As Int, Rows As Int, OuterStroke As Int, InnerStroke As Int)
	Dim temp As Int ,temp2 As Int
	If OuterStroke>0 Then BG.DrawRect( LCAR.SetRect(X,Y,Width,Height), Color, False,OuterStroke)
	If Rows>0 Then 
		temp2=Height/Rows
		For temp = Y+temp2 To Y+Height-temp2 Step temp2
			BG.DrawLine(X, temp, X+Width, temp, Color,InnerStroke)
		Next
	End If
	If Cols>0 Then
		temp2=Width/Cols
		For temp = X+temp2 To X+Width-temp2 Step temp2
			BG.DrawLine(temp, Y, temp, Y+Height, Color, InnerStroke)
		Next
	End If
End Sub

Sub DrawBox2(BG As Canvas, X As Int, BarWidth As Int, Y As Int, Width As Int, Height As Int, Color As Int, ColWidth As Int, RowHeight As Int, Stroke As Int, BracketX As Int)
	Dim temp As Int ,temp2 As Int,temp3 As Int , Orange As Int, X2 As Int,BitWidth As Int, BitHeight As Int , Value As Int, Cols As Int , Purple As Int ,Rows As Int , Text As String, RowHeight2 As Int,TextHeight As Int
	BitHeight = LCAR.Fontsize
	RowHeight2=RowHeight+3
	Orange=LCAR.GetColor(LCAR.LCAR_Orange,False,255)
	Purple=LCAR.GetColor(LCAR.LCAR_DarkPurple, False,255)
		
	Cols=Width/ColWidth
	If Cols>0 Then
		'ColWidth=Width/Cols
		BitWidth = ColWidth *0.2
		X2=X+Width+BarWidth-Stroke
		Value=Cols*20
		For temp =  Cols To 1 Step -1
			
			If temp = Cols OR temp = Cols-1 Then 
				Color = Colors.Red 
			Else If temp> Cols-5 Then Then
				Color = Orange
			Else
				Color =Colors.White 
			End If
			
			LCAR.DrawRect(BG, X2-BitWidth, Y, BitWidth,BitHeight, Color,0)
			BG.DrawLine(X2, Y, X2, Y+Height, Color, Stroke)
			LCAR.DrawRect(BG, X2-BitWidth, Y+Height-BitWidth, BitWidth,BitWidth, Color,0)
			If TextHeight=0 Then TextHeight = BG.MeasureStringHeight(Value,LCAR.LCARfont, LCAR.Fontsize)
			BG.DrawText(Value, X2-BitWidth, Y-2+ TextHeight, LCAR.LCARfont, LCAR.Fontsize, Color, "RIGHT")
			
			Value=Value-20
			X2=X2-ColWidth
		Next
	End If
	
	X2=Y+Height/2
	Cols=X2
	
	Width=X+Width+BarWidth'is now the right coordinate
	DrawGraphBar(BG,X,X2,BarWidth,Width, RowHeight, Purple,LCAR.LCAR_DarkPurple, GetGraphText(0))
	Rows=Floor( (Height/2) / (RowHeight+2))
	
	For temp = 1 To Rows
		Text= GetGraphText(temp)
		Cols=Cols-RowHeight2
		X2=X2+ RowHeight2
		
		DrawGraphBar(BG, X,X2,BarWidth,Width,RowHeight, Orange,LCAR.LCAR_Orange, Text)
		If temp< Rows-1 Then
			DrawGraphBar(BG, X,Cols,BarWidth,Width,RowHeight, Orange, LCAR.LCAR_Orange, Text)
		Else
			X2=X2+RowHeight-1
			LCAR.DrawRect(BG,X,X2, BarWidth, RowHeight, Orange ,0)
			RowHeight=RowHeight+ (Cols-Y)
			DrawGraphBar(BG, X,Y,BarWidth,BarWidth,RowHeight, LCAR.GetColor(LCAR.LCAR_Red,False,255), LCAR.LCAR_Red , Text)
			Exit
		End If
	Next	
	'draw the brackets
	RowHeight2 = RowHeight2/4
	BracketX = Min(Max(X+BarWidth + ColWidth/2 + RowHeight2,  BracketX - ColWidth/2), Width - ColWidth/2 - RowHeight2)
	BG.RemoveClip 
	
	'draw text
	X2=X+BarWidth
	LCAR.DrawRect(BG, X2,Y- TextHeight-4, Width-X2+2, TextHeight+4 , Colors.black, 0)
	Text="FREQUENCY ARTIFACT"
	X2 = LCAR.TextWidth(BG, Text)
	If BracketX+X2>Width Then
		X2=Width
		temp=3
		'LCAR.DrawText(BG, Width, Y- TextHeight, "FREQUENCY ARTIFACT", LCAR.LCAR_Orange, 3, False, 255,0)
	Else
		X2=BracketX
		temp=1
		'LCAR.DrawText(BG, BracketX, Y- TextHeight, "FREQUENCY ARTIFACT", LCAR.LCAR_Orange, 1, False, 255,0)
	End If
	LCAR.DrawText(BG, X2, Y- TextHeight-4, Text, LCAR.LCAR_Orange, temp, False, 255,0)
	
	
	
	X2=Y+Height-BitHeight-RowHeight2
	Y=Y+(RowHeight2*1.5)+TextHeight+2
	
	LCARSeffects.DrawCircleSegment(BG, BracketX, Y, RowHeight2, RowHeight2*2,  270,90,  Orange, 0,0,0)
	LCARSeffects.DrawCircleSegment(BG, BracketX+ColWidth, Y, RowHeight2, RowHeight2*2,  0,90,  Orange, 0,0,0)
	temp=Y- RowHeight2*1.5 
	BG.DrawLine(BracketX, temp, BracketX+ColWidth, temp, Orange, RowHeight2)'middle top
	temp = Y + Height*.20
	temp3 = X2 - Height*.20
	temp2=BracketX - RowHeight2*1.5 
	BG.DrawLine(temp2, Y, temp2, temp, Orange, RowHeight2)'top left
	BG.DrawLine(temp2, X2, temp2, temp3, Orange, RowHeight2)'bottom left
	
	temp2=BracketX+ColWidth + RowHeight2*1.5 
	BG.DrawLine(temp2, Y, temp2, temp, Orange, RowHeight2)'top right
	BG.DrawLine(temp2, X2, temp2, temp3, Orange, RowHeight2)'bottom right
	
	LCARSeffects.DrawCircleSegment(BG, BracketX, X2, RowHeight2, RowHeight2*2,  180,90,  Orange, 0,0,0)
	LCARSeffects.DrawCircleSegment(BG, BracketX+ColWidth, X2, RowHeight2, RowHeight2*2,  90,90,  Orange, 0,0,0)
	temp=X2+RowHeight2*1.5
	BG.DrawLine(BracketX, temp, BracketX+ColWidth, temp, Orange, RowHeight2)'middle bottom
End Sub
Sub GetGraphText(Row As Int) As String 
	Return API.PadtoLength(Row,True,2,"0") & "-" & API.PadtoLength( Power(2, Row), True, 3, "0")
End Sub
Sub DrawGraphBar(BG As Canvas, X As Int, Y As Int, BarWidth As Int, Right As Int, Height As Int, Color As Int, ColorID, Text As String )
	BG.DrawLine(X, Y, Right, Y,Color,2)
	LCAR.DrawLCARbutton(BG, X,Y, BarWidth, Height, ColorID,False, Text, "", 0,0,False, 0, 9, -1, 255,False)
	'LCAR.DrawRect(BG, X ,Y, BarWidth, Height, Color,0)
End Sub








Sub DrawBitmap(BG As Canvas, BMP As Bitmap, SrcX As Int, SrcY As Int, DestX As Int, DestY As Int, Width As Int, Height As Int, FlipX As Boolean, FlipY As Boolean)
	If Width>0 AND Height>0 Then
		If FlipX OR FlipY Then
			BG.DrawBitmapFlipped(BMP, LCAR.SetRect(SrcX,SrcY,Width,Height), LCAR.SetRect(DestX,DestY,Width,Height) ,FlipY,FlipX)
		Else
			BG.DrawBitmap(BMP, LCAR.SetRect(SrcX,SrcY,Width,Height), LCAR.SetRect(DestX,DestY,Width,Height))
		End If
	End If
End Sub
Sub ScaleBitmap(BG As Canvas, BMP As Bitmap, SrcX As Int, SrcY As Int, SrcWidth As Int, SrcHeight As Int, DestX As Int, DestY As Int, DestWidth As Int, DestHeight As Int, FlipX As Boolean, FlipY As Boolean) As Point 
	Dim NewSize As Point, CenterY As Boolean ,CenterX As Boolean 
	If DestWidth=0 Then
		DestWidth=SrcWidth
		CenterX =True
	Else If DestHeight = 0 Then 
		DestHeight = SrcHeight
		CenterY=True
	End If
	NewSize=API.Thumbsize(SrcWidth,SrcHeight, DestWidth,DestHeight, False,False)
	If CenterY Then  DestHeight=0 
	If CenterX Then  DestWidth=0
	BG.DrawBitmapFlipped(BMP, LCAR.SetRect(SrcX,SrcY,SrcWidth,SrcHeight), LCAR.SetRect(DestX+DestWidth/2-NewSize.X/2, DestY+DestHeight/2-NewSize.Y/2, NewSize.X,NewSize.Y)  ,FlipY,FlipX)
	Return NewSize
End Sub
Sub TileBitmap(BG As Canvas, BMP As Bitmap, SrcX As Int, SrcY As Int, SrcWidth As Int, SrcHeight As Int, DestX As Int, DestY As Int, DestWidth As Int, DestHeight As Int, FlipX As Boolean, FlipY As Boolean) 
	Dim temp As Int ,Finish As Int
	If DestHeight=0 Then
		Finish=DestX+DestWidth-1
		For temp = DestX To Finish Step SrcWidth-1
			If temp + SrcWidth > Finish Then SrcWidth = Finish-temp
			DrawBitmap(BG, BMP, SrcX,SrcY, temp,DestY, SrcWidth,SrcHeight, FlipX,FlipY)
		Next
	Else If DestWidth=0 Then
		Finish=DestY+DestHeight-1
		For temp=DestY To Finish Step SrcHeight-1
			If temp + SrcHeight > Finish Then SrcHeight = Finish-temp
			DrawBitmap(BG, BMP, SrcX,SrcY, DestX,temp, SrcWidth,SrcHeight, FlipX,FlipY)
		Next
	End If
End Sub



Sub DrawStatic(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, CellWidth As Int, CellHeight As Int, MaxRed As Int)
	Dim temp As Int, temp2 As Int ,Grey As Int ,Red As Int ,Color As Int 
	For temp2 = Y To Y+Height Step CellHeight
		For temp = X To X+Width Step CellWidth
			If MaxRed>0 Then Red = Rnd(0, MaxRed)
			Grey = Rnd(0, 256)
			If Red<Grey Then Red=Grey 
			Color = Colors.RGB(Red, Grey,Grey)			
			LCAR.DrawRect(BG, temp,temp2, CellWidth,CellHeight, Color, 0)
		Next
	Next
End Sub
	
Sub DrawNumberLine(BG As Canvas, X As Int, Y As Int, Width As Int, Height As Int, Stroke As Int, Color As Int, GoLeft As Boolean, Widths As List, NumberIDs As List , ObjectHeight As Int)
	Dim temp As Int ,Width2 As Int, UseThick As Boolean ,ThickStroke As Int,Size As Int  ,NumberIndex As Int, Y2 As Int,MaxHeight As Int 
	ThickStroke=Stroke*2
	If Height=0 Then 
		Y=Y-Stroke
	Else
		LCAR.DrawRect(BG,X,Y, Stroke, Height, Color, 0)
		Y=Y+Height-1
	End If
	If GoLeft Then X= X-Width+Stroke+1
	LCAR.DrawRect(BG,X,Y, Width-1, Stroke , Color, 0)
	Y2=Y+ThickStroke+Stroke+3
	If ObjectHeight>0 Then MaxHeight = ObjectHeight-Y2
	For temp = 0 To Widths.Size-1
		Width2= Widths.Get(temp)
		If Width2<0 Then Width2 = Width2 * -0.01 * Width'percent
		Width2= Min(Width2, Width-Size)
		'If Size+Width2>Width Then Width2 = Width-Size
		If UseThick  Then 
			LCAR.DrawRect(BG,X,Y, Width2,  ThickStroke  , Color, 0)
			If NumberIDs.Size>0 Then
				If NumberIndex< NumberIDs.Size Then DrawRandomNumbers(BG, X,Y2, LCAR.LCARfont, 10,Width, MaxHeight, NumberIDs.Get(NumberIndex))
				NumberIndex=NumberIndex+1
			End If
		End If
		X=X+Width2'-1
		Size=Size+Width2
		UseThick=Not(UseThick)
	Next
End Sub



Sub DrawTextButton(BG As Canvas, X As Int, Y As Int, Width As Int, LColorID As Int, MColorID As Int, RColorID As Int,Alpha As Int, State As Boolean, Text As String, TColorID As Int, TState As Boolean, LeftSide As Boolean, IsMoving As Boolean )As Int 
	Dim temp As Int,temp2 As Int,textwidth As Int
	temp=3'whitespace
	LCAR.CheckNumbersize(BG)
	LCAR.DrawLCARbutton(BG,X,Y, LCAR.MinWidth, LCAR.ItemHeight,  LColorID, State, "", "", LCAR.MinWidth,0,False,-1,0,-1,Alpha, IsMoving)
	LCAR.DrawLCARbutton(BG,X+LCAR.MinWidth+temp,Y, Width- (LCAR.MinWidth+temp)*2, LCAR.ItemHeight, MColorID, State, "","", 0,0,False,0,0,-1,Alpha, IsMoving)
	LCAR.DrawLCARbutton(BG,X+Width-LCAR.MinWidth,Y,  LCAR.MinWidth, LCAR.ItemHeight, RColorID, State, "", "", 0,LCAR.MinWidth,True,-1,0,-1,Alpha,IsMoving)
	
	textwidth = BG.MeasureStringWidth(Text, LCAR.LCARfont, LCAR.NumberTextSize)
	If LeftSide Then
		temp=X+LCAR.MinWidth
		temp2=9
	Else
		temp=X+Width-LCAR.MinWidth-textwidth-temp*2
		temp2=3
	End If
	LCAR.DrawRect(BG, temp,Y,textwidth+temp2,  LCAR.ItemHeight, Colors.Black,0)
	LCAR.DrawLCARtextbox(BG, temp+3,Y, 0, LCAR.NumberTextSize, 0,0, Text, TColorID , 0, 0,   TState, False,-5,Alpha)
	
	Return textwidth
End Sub



Sub RandomNumber(Digits As Int, Pad As Boolean ) As String
	Dim tempstr As String 
	tempstr= Rnd(0, Power(10, Digits))
	If Pad Then
		Do Until tempstr.Length= Digits
			tempstr = "0" & tempstr
		Loop
	End If
	Return tempstr
End Sub








