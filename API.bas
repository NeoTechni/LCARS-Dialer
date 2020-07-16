B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=StaticCode
Version=6.77
@EndOfDesignText@
'Google weather API: http://www.google.com/ig/api?weather=L8L%206V6
'IP http://api.hostip.info/get_html.php
'http://ipinfodb.com/ip_locator.php?ip=70.52.165.17

'Code module
'Subs in this code module will be accessible from all modules.
Sub Process_Globals
	'These global variables will be declared once when the application starts.
	'These variables can be accessed from all modules.
	Dim dURL As String ,Title As String ,FileLoaded As String ,BaseHref As String , aHREF As String ,phone1 As Phone
	
	Type HTMLvalue(Key As String, Value As String)
	Type HTMLtag(Level As Int, TagName As String, Node As String, Values As List)
	
	Type APIKeyboard(Text As String, SelStart As Int, SelLength As Int, Shift As Boolean,CapsLock As Boolean  )
	Type IPaddress( Octets(4) As Int , Port As Int, SelectedOctet As Int )
	
	Dim debugMode As Boolean, HasChecked As Boolean , ascA As Int, ascZ As Int: ascA = Asc("A"): ascZ= Asc("Z")
	
	Dim BUTTON_A As Int, BUTTON_B As Int, BUTTON_C As Int, BUTTON_X As Int, BUTTON_Y As Int, BUTTON_Z As Int, BUTTON_L1 As Int, BUTTON_R1 As Int, BUTTON_L2 As Int, BUTTON_R2 As Int
	Dim BUTTON_SELECT As Int, BUTTON_START As Int, BUTTON_MODE As Int, BUTTON_L3 As Int, BUTTON_R3 As Int ':BUTTON_MODE=316:BUTTON_L3=317:BUTTON_R3=318
	'BUTTON_A= 304 :BUTTON_B=305:BUTTON_C=306:BUTTON_X = 307:BUTTON_Y=308:BUTTON_Z=309:BUTTON_L1 =310:BUTTON_R1=311:BUTTON_L2=312:BUTTON_R2=313:BUTTON_SELECT=314:BUTTON_START=315
	BUTTON_A=96: BUTTON_B=97:BUTTON_C=98:BUTTON_X=99:BUTTON_Y=100:BUTTON_Z=101:BUTTON_L1=102:BUTTON_R1=103:BUTTON_L2=104:BUTTON_R2=105:BUTTON_L3=106:BUTTON_R3=107
	BUTTON_START=108:BUTTON_SELECT=109:BUTTON_MODE=110
	    
	Dim DIRECTORY_MUSIC As Int, DIRECTORY_PICTURES As Int, DIRECTORY_RINGTONES As Int, DIRECTORY_ALARMS  As Int,DIRECTORY_DCIM  As Int,DIRECTORY_DOWNLOADS As Int,DIRECTORY_MOVIES  As Int, DIRECTORY_NOTIFICATIONS  As Int,  DIRECTORY_PODCASTS As Int
	DIRECTORY_MUSIC=7:DIRECTORY_RINGTONES=1:DIRECTORY_ALARMS=2:DIRECTORY_DCIM=4:DIRECTORY_DOWNLOADS=5:DIRECTORY_MOVIES=6:DIRECTORY_NOTIFICATIONS=3:DIRECTORY_PODCASTS=8
	
	Dim YourName As String ,UnreadThreads As Int , vbQuote As String = Chr(34)'PhoneNumbers As Map ,
	
	Dim DebugStr As StringBuilder,UsePebble As Boolean 
	
	Private cr As ContentResolver, dataUri As Uri
	Public phoneTypes As List, mailTypes As List 'for phone number label lookup

	Type Country(Name As String, Code As Int)
	Dim Countries As List ,AltMethod As Boolean ',ProxyInit As Boolean
	
	Dim CU As ContactsUtils ,IgnoreNew As Boolean , BlockLollipop As Int = 21
End Sub


Sub SetMargin(Target As Object, Value As Int)
	Dim refl As Reflector, args(4) As Object, types(4) As String
    refl.Target = Target
    args(0) = Value    ' left
    args(1) = Value    ' top
    args(2) = Value    ' right
    args(3) = Value    ' bottom
    types(0) = "java.lang.int"
    types(1) = "java.lang.int"
    types(2) = "java.lang.int"
    types(3) = "java.lang.int"
    refl.RunMethod4("setPadding", args, types)    
End Sub
Sub ProximityState(Enabled As Boolean, FromWhat As String) 
	'CallSub3(Main, "ProximityState", Enabled, FromWhat)
End Sub

Sub DeleteSMScache(Delete As Boolean) As Boolean 
	Dim Dir As String = File.Combine(LCAR.DirDefaultExternal, "HTML"), Filename As String = "sms.html"
	If File.Exists(Dir,Filename) Then 
		If Delete Then' File.Delete(Dir,Filename)
			MakeHTML2("SMS LOG DELETED FOR YOUR PROTECTION. PLEASE RELOAD IT IF YOU WANT TO VIEW IT AGAIN", Dir,Filename)
		End If
		Return True
	End If
End Sub

Sub SendPebbleConnected(State As Boolean)
	Dim P As Phone, I As Intent 
	If Not(State) And Not(STimer.FwdPebble) Then Return
	I.Initialize("com.getpebble.action.PEBBLE_" & IIF(State, "", "DIS") & "CONNECTED", "")
	I.PutExtra("address", "00-B0-D0-86-BB-F7")
	P.SendBroadcastIntent(I)
End Sub

Sub Broadcast(Action As String, Value As Object)
	Dim P As Phone, I As Intent 
	I.Initialize("com.omnicorp.lcarui", "")
	I.PutExtra("Action", Action)
	I.PutExtra("Value", Value)
	P.SendBroadcastIntent(I)
End Sub

Sub SetScreenBrightness(Value As Float)
	'debug("SetScreenBrightness: " & Value)
	CallSub2(Main, "ScreenBrightness", Value)
	'debug(GetScreenBrightness)
	'phone1.SetScreenBrightness(Value)
End Sub
Sub GetScreenBrightness As Float
	Return phone1.GetSettings("screen_brightness")/255
End Sub

Sub Deltree(Directory As String, Recursive As Boolean)
	Dim temp As Int, Files As List ,Size As Int 
	Try
		Files = File.ListFiles(Directory)
		Size=Files.Size
		For temp = 0 To Files.Size-1 'To 0 Step -1
			If File.IsDirectory(Directory, Files.Get(temp)) Then
				If Recursive Then 
					Deltree(File.Combine(Directory, Files.Get(temp)), True)
					Size=Size-1
				End If
			Else
				File.Delete(Directory, Files.Get(temp))
				Size=Size-1
			End If
		Next	
		If Size=0 Then File.Delete(GetDir(Directory), GetFile(Directory))
	Catch
	End Try
End Sub

Sub SetupCountries
	If Not(Countries.IsInitialized) Then
		Countries.Initialize 
		MakeCountry("American Samoa", 1684)
		MakeCountry("Anguilla", 1264)
		MakeCountry("Antigua and Barbuda", 1268)
		MakeCountry("Bahamas", 1242)
		MakeCountry("Barbados", 1246)
		MakeCountry("Bermuda", 1441)
		MakeCountry("British Virgin Islands", 1284)
		MakeCountry("Cayman Islands", 1345)
		MakeCountry("Dominica", 1767)
		MakeCountry("Dominican Republic", 1809)
		MakeCountry("Grenada", 1473)
		MakeCountry("Guam", 1671)
		MakeCountry("Jamaica", 1876)
		MakeCountry("Montserrat", 1664)
		MakeCountry("Northern Mariana Islands", 1670)
		MakeCountry("Saint Kitts and Nevis", 1869)
		MakeCountry("Saint Lucia", 1758)
		MakeCountry("Saint Martin", 1599)
		MakeCountry("Saint Vincent and the Grenadines", 1784)
		MakeCountry("Trinidad and Tobago", 1868)
		MakeCountry("Turks and Caicos Islands", 1649)
		MakeCountry("US Virgin Islands", 1340)
		'MakeCountry("North America", 1)
	End If
End Sub
Sub MakeCountry(Name As String, Code As Int)
	Dim temp As Country 
	temp.Initialize 
	temp.Name=Name
	temp.Code=Code
	Countries.Add(temp)
End Sub
Sub GetCountry(PhoneNumber As String) As Int 
	Dim temp As Int ,tempcountry As Country,tempstr As String 
	If Left(PhoneNumber,1)="+" Then
		SetupCountries
		PhoneNumber = Right(PhoneNumber, PhoneNumber.Length-1)
		For temp = 0 To Countries.Size-1
			tempcountry= Countries.Get(temp)
			tempstr=tempcountry.Code
			If PhoneNumber.Length>=tempstr.Length Then
				If Left(PhoneNumber, tempstr.Length) = tempstr Then Return temp
			End If
		Next
	End If
	Return -1
End Sub
Sub IsCountryBlocked(PhoneNumber As String, AllowedCountry As String) As Boolean 
	Dim temp As Int, tempcountry As Country
	If Left(PhoneNumber,1)="+" AND AllowedCountry <> "0" AND AllowedCountry.Length>0 AND AllowedCountry <> "-1" Then
		If AllowedCountry = "1" Then
			If GetCountry(PhoneNumber)>-1 Then		Return True
			If Mid(PhoneNumber,1,1) <> "1" Then		Return True
		Else 
			PhoneNumber = Left( Right(PhoneNumber, PhoneNumber.Length-1), AllowedCountry.Length)
			If PhoneNumber <> AllowedCountry Then	Return True
		End If
	End If
	Return False
End Sub

Sub DebugLog(Text As String)As Boolean 
	If debugMode Then
		Dim Output As OutputStream = File.OpenOutput(LCAR.DirDefaultExternal, "log.txt", True), ST As ByteConverter 
		Log("DEBUG: " & Text)
		Text= DateTime.Time(DateTime.Now) & ": " &  Text & CRLF
		Output.WriteBytes( ST.StringToBytes(Text, "UTF8"), 0, Text.Length)
		Output.Close
	End If
End Sub


Sub IsScreenLocked As Boolean
	Dim r As Reflector
	r.Target = r.GetContext
	r.Target = r.RunMethod2("getSystemService", "keyguard", "java.lang.String")
	Return r.RunMethod("inKeyguardRestrictedInputMode")
End Sub
Sub IsScreenOn As Boolean
    Dim r As Reflector
    r.Target = r.GetContext
    r.Target = r.RunMethod2("getSystemService", "power", "java.lang.String")
    Return r.RunMethod("isScreenOn")
End Sub
Sub WakeUp
	Dim temp As Boolean = IsScreenOn
	Log("Is screen on? " & temp)
	If Not(temp) Then
		Dim P As PhoneWakeState
	    P.ReleaseKeepAlive
	    P.KeepAlive(True)
	End If
    'p.PartialLock
    'StartActivity(Main) ' start the activity
	'SetShowWhenLocked(True)
	'debug("Screen should be on")
End Sub
Sub GotoSleep
	Dim P As PhoneWakeState
	'SetShowWhenLocked(False)
	If Not(IsInIDE) Then
		P.ReleaseKeepAlive 
		P.ReleasePartialLock
		ProximityState(False,"Gotosleep")
	End If
	'STimer.ProximityEnabled=False
	'debug("Screen should be off")
End Sub
Sub SetShowWhenLocked(State As Boolean)
	'CallSubDelayed2(Main, "setshowwhenlocked", State)
End Sub
Sub Now As String 
	Return DateTime.Date(DateTime.Now) & " " & DateTime.Time(DateTime.Now)
End Sub

Sub ContactName(tempcontact As Contact)As String 
	If tempcontact.DisplayName = Null Then
		Return "Unknown Caller" 
	Else
		Return tempcontact.DisplayName 
	End If
End Sub


Sub LoadSettings(BG As Canvas, Save As Boolean) As Boolean 
	Dim tempdate As Long ,temp As Boolean 
	If Not(Save) Then 
		'API.Debug("Loading settings")
	
		LCAR.SetupLCARcolors(Null)
		
'		Settings.Initialize
'		If File.ExternalReadable = True Then
'			If File.Exists(File.DirInternal, "settings.ini") Then Settings = File.ReadMap (File.DirInternal , "settings.ini") 
'		End If
		'Msgbox(File.DirRootExternal, "This is where error.txt will be")
		'Debug("SD card directory=" & LCAR.DirDefaultExternal)

		If LCAR.DirDefaultExternal.Length=0 Then 
			Log("DIR WAS EMPTY")
			Return False
		End If
		'API.Debug("DirDefaultExternal succeeded")		
		Main.Settings = LoadMap(LCAR.DirDefaultExternal, "settings.ini")'LastLoaded=DateTime.Now 
		'API.Debug("Settings load succeeded")
		'Debug("Settings loaded=" & Settings.IsInitialized)
		
		If Not(Main.Settings.IsInitialized ) Then 
			Log("SETTINGS MISSING")
			Return False
		End If
		
		If File.Exists(File.DirInternal, "settings.ini") Then
			Main.Settings2 = LoadMap(File.DirInternal, "settings.ini")
		Else
			Main.Settings2.Initialize 
		End If
		'API.Debug("settings 2 loaded")
'		tempdate= Settings.Getdefault("FirstRun", 0)
'		tempdate = (DateTime.Now - tempdate) / DateTime.TicksPerMinute 
'		If Not (tempdate>15) Then Return False
	End If
	'lcarseffects.ClearGPScoordinates(Settings)
	'DOS=1

	'API.Debug("first group of settings")
	LCAR.AntiAliasing = HandleSetting("AntiAliasing",LCAR.AntiAliasing,True, Save)
	LCAR.Volume(HandleSetting("Volume",  LCAR.cVol, 100, Save), False)
	LCAR.SmoothScrolling= HandleSetting("SmoothScrolling", LCAR.SmoothScrolling, False, Save)
	'LCAR.Mute = HandleSetting("Mute",LCAR.Mute,False, Save)
	Main.BackToQuit= True'HandleSetting("BackToQuit",BackToQuit,False, Save)
	LCAR.Zoom = HandleSetting("Zoom", LCAR.Zoom,1,Save)
	LCAR.LOD = HandleSetting("LOD",LCAR.LOD, True, Save)
	Main.Keytones=HandleSetting("Keytones", Main.Keytones, True,Save)
	Main.KeyToneIndex=HandleSetting("KeyToneIndex",Main.KeyToneIndex, 1,Save)
	'lcarseffects.NAVSTARS = HandleSetting("NAVSTARS",lcarseffects.NAVSTARS, False, Save)
	LCAR.SmallScreen =  HandleSetting("SmallScreen", LCAR.SmallScreen, False, Save)
	Main.SpeakName = Main.Settings.GetDefault("SpeakName", False)
	LCAR.CrazyRez = HandleSetting("HIRES", LCAR.CrazyRez, 0,Save)
	Main.CallsAnswered = HandleSetting("AnswerMade", Main.CallsAnswered, 0, Save)
	Main.AutoTurnOff = HandleSetting("AutoTurnOff", Main.AutoTurnOff, 60, Save)
	
	If Not(IsPackageInstalled("com.getpebble.android")) Then 
		SendPebbleConnected(True)
		STimer.FwdPebble = Main.Settings.GetDefault("FwdPebble", False)
	End If
	
	'API.Debug("second group of settings")
	BaseHref = HandleSetting("BaseHREF", BaseHref, "http://en.memory-alpha.org/", Save)
	Main.Screenshots=False'HandleSetting("Screenshots", Screenshots, True, Save)
	'LCAR.SmoothScrolling= False' HandleSetting("SmoothScrolling", LCAR.SmoothScrolling, False, Save)
	'api.Title = HandleSetting("Title", api.Title, "", Save)
	
	'API.Debug("third group")
	LCAR.HasHardwareKeyboard= HandleSetting("HasHardwareKeyboard",LCAR.HasHardwareKeyboard,False, Save)
	LCAR.Fontfactor=HandleSetting("Fontfactor",LCAR.Fontfactor, 50, Save)

	'LCAR.RumbleEnabled=HandleSetting("Rumble",LCAR.RumbleEnabled, True, Save)
	LCAR.RumbleUnit = HandleSetting("RumbleUnit", LCAR.RumbleUnit,  IIF(HandleSetting("Rumble",True, True, False), 75,0)   , Save)

	LCAR.LessRandom= HandleSetting("LessRandom", LCAR.LessRandom, False, Save)
	UsePebble= HandleSetting("UsePebble", UsePebble, False, Save) 
	
	Main.LastVersion= HandleSetting("LastVersion", Main.LastVersion, "", Save) 
	IgnoreNew = HandleSetting("IgnoreNew", IgnoreNew, False, Save) 
	'if not save then HasShown=HandleSetting("HasShown", HasShown, False, false)
	

	'API.Debug("fourth group")
	'debugMode= HandleSetting("debugMode", debugMode, False, Save) 
	Main.Password= HandleSetting("Password", Main.Password,  "", Save)
	Main.Starshipname= HandleSetting("Starshipname", Main.Starshipname,  "UNNAMED", Save)
	Main.StarshipID = HandleSetting("StarshipID", Main.StarshipID,  "", Save)
	Main.UID=HandleSetting("UID",Main.UID, "",Save)
	If Main.UID.Length=0 Then 
		Main.UID=GetUniqueKey(True)
		Main.Settings.Put("UID", Main.UID)
	End If
	YourName=HandleSetting("YourName", YourName, "UNNAMED", Save)
	STimer.AnswerCalls = Main.Settings.GetDefault("AnswerCalls", False)
	If APIlevel >= BlockLollipop And BlockLollipop>0 Then STimer.AnswerCalls = False
	
	STimer.AllowedCountry = Main.Settings.GetDefault("BlockCountry", "0")
	AltMethod = Main.Settings.GetDefault("AltMethod", False)
	
	If Save Then 
		If Main.Settings2.IsInitialized Then File.WriteMap(File.DirInternal, "settings.ini", Main.Settings2)
	Else
		'API.Debug("fifth group")
		STimer.MaxPeriod = Main.Settings.GetDefault("EMAILperiod", 15)
		'If Not(STimer.IncomingIsInitialized) OR Not(STimer.OutGoingIsInitialized ) Then 
		temp=LoadEmailSettings(Main.settings)
		If BG <> Null And LCAR.ScreenIsOn Then
			If Not(temp) Then LCAR.ToastMessage(BG, "YOUR EMAIL IS NOT SET UP", 2)
		'API.Title = "PRESS SEARCH BUTTON OR TOP LEFT LCARS TO BEGIN"
		End If
		LCAR.LoadLCARSize(BG)
		Main.LastLoaded=DateTime.Now 
	End If
	'API.Debug("done")
	Return True
End Sub
Sub PasswordText(Text As String, Character As String, MaxLen As Int) As String 
	Dim temp As Int , tempstr As StringBuilder ,Length As Int 
	tempstr.Initialize 
	If MaxLen>0 And MaxLen< Text.Length Then Length = MaxLen Else Length = Text.Length 
	For temp = 1 To Length
		tempstr.Append(Character)
	Next
	Return tempstr.ToString 
End Sub
Sub InitOutGoing(TheServer As String, Port As Int, Username As String, YourPassword As String, SenderName As String, UseSSL As Boolean)As Boolean 
	Dim ret As Boolean 
	If TheServer.EqualsIgnoreCase("gmail") Then
		TheServer = "smtp.gmail.com"
		If Not(Username.Contains("@")) Then Username= Username & "@gmail.com"
		Port=465
		InitIncoming("pop.gmail.com", 995,Username,YourPassword,True)
		ret = True
	End If
	STimer.OutGoing.Initialize(TheServer, Port, Username, YourPassword, "OutGoing")
	STimer.OutGoing.UseSSL = TheServer.EqualsIgnoreCase("smtp.gmail.com") OR  UseSSL
	STimer.OutGoing.Sender = SenderName 
	STimer.OutGoingIsInitialized=True
	'Msgbox( TheServer & CRLF & Port & CRLF & Username & CRLF & YourPassword & CRLF & SenderName, "server,port,user,pass,name")
	
	LCAR.ToastMessage(LCARSeffects2.TempCanvas, "SMTP: " & TheServer & ":" & Port & IIF(UseSSL, "+SSL","") & CRLF & "USERNAME: " & Username & CRLF & "PASSWORD: " & PasswordText(YourPassword,"*",0),3)
	Return ret 
End Sub
Sub InitIncoming(TheServer As String, Port As Int, Username As String, YourPassword As String,UseSSL As Boolean )
	If TheServer.EqualsIgnoreCase("gmail") Then
		TheServer = "pop.gmail.com"
		If Not(Username.Contains("@")) Then Username= Username & "@gmail.com"
		Port=995
	End If	
	STimer.Incoming.Initialize(TheServer, Port, Username, YourPassword, "Incoming")
	STimer.Incoming.UseSSL =TheServer.EqualsIgnoreCase("pop.gmail.com") OR UseSSL
	STimer.IncomingIsInitialized=True
	
	'ZRLHPFVRMHPGHOIL
	'Log(IIF(STimer.Incoming.UseSSL, "SSL ", "") & "POP: " & TheServer & CRLF & ":" & Port & CRLF & "USERNAME: " & Username & CRLF & "PASSWORD: " & YourPassword)
	LCAR.ToastMessage(LCARSeffects2.TempCanvas, "POP: " & TheServer & ":" & Port & IIF(UseSSL, "+SSL","")  & CRLF & "USERNAME: " & Username & CRLF & "PASSWORD: " & PasswordText(YourPassword,"*",0),3)
	'Msgbox( TheServer & CRLF & Port & CRLF & Username & CRLF & YourPassword, "server,port,user,pass")
End Sub
Sub LoadEmailSettings(Settings As Map) As Boolean 
	Dim username As String ,Password As String 
	STimer.ForwardMissedCalls = Settings.GetDefault("EMAILmissed",False)
	STimer.ForwardSMS = Settings.GetDefault("EMAILsms",False)
	STimer.MaxMessages = Settings.GetDefault("EMAILmessages",15)
	STimer.MaxPeriod =Settings.GetDefault("EMAILperiod",15)
	STimer.MaxMessageSize = Settings.GetDefault("EMAILsize",100) * 1024
	MailParser.TheKey = MailParser.GetEncryptionKey(False)	
	
	username = Settings.GetDefault("EMAILaddress", "")
	
	If Not(username.Contains("@")) AND username.Length>0 Then username= username & "@gmail.com"
	STimer.EmailAddress = username
	STimer.NeedsChecking=True
	If Settings.ContainsKey("EMAILuser") AND Settings.ContainsKey("EMAILencrypted") Then
		username=Settings.GetDefault("EMAILuser","gmail")
		Password= MailParser.CODEC(Settings.Get("EMAILencrypted"), False, MailParser.GetEncryptionKey(False))
		If Not(username.Contains("@")) Then 
			username = username & "@gmail.com"
			STimer.EmailAddress=username
		End If
		If Not(InitOutGoing( Settings.GetDefault("SMTPserver","gmail"), Settings.GetDefault("SMTPport", 465),username,  Password, GetUserName(0), Settings.GetDefault("EMAILssl", False) )) Then
			InitIncoming(Settings.GetDefault("POP3server","gmail"), Settings.GetDefault("POP3port", 995),username, Password, Settings.GetDefault("EMAILssl", False) )
		End If	
		If STimer.EmailAddress.Length=0 Then STimer.EmailAddress=username
		Return True
	End If
End Sub
Sub HandleSetting(VariableName As String, CurrentValue As Object , DefaultValue As Object, Save As Boolean )As Object
	Dim tempstr As String 
	If Save Then
		Main.Settings.Put(VariableName, CurrentValue)
		Return CurrentValue
	Else
		tempstr=Main.Settings.GetDefault(VariableName,DefaultValue)
		Select Case tempstr.ToLowerCase 
			Case "":Return DefaultValue
			Case "true": Return True
			Case "false": Return False
			Case Else: Return tempstr
		End Select
	End If
End Sub 




















Sub GetBmpFromDrawable(D As Object) As Bitmap 
    Dim bmp As Bitmap 
    bmp.InitializeMutable(48dip,48dip)
    Dim cnv As Canvas 
    Dim dr As Rect 
    dr.Initialize(0,0,48dip,48dip)
    cnv.Initialize2(bmp)
    cnv.DrawDrawable(D,dr)
    Return cnv.Bitmap 
End Sub

Sub GetPhoneVolume As Int 
	Dim P As Phone
	Select Case P.GetRingerMode
		Case P.RINGER_NORMAL:  Return P.GetVolume( P.VOLUME_RING )
		Case P.RINGER_SILENT:  Return 0
		Case P.RINGER_VIBRATE: Return -1
	End Select
End Sub

Sub GetMonth(Month As Int, LongForm As Boolean) As String 
	Dim text() As String = Array As String("JANUARY", "FEBRUARY", "MARCH", "APRIL", "MAY", "JUNE", "JULY", "AUGUST", "SEPTEMBER", "OCTOBER", "NOVEMBER", "DECEMBER")
	If LongForm Then 
		Return text(Month)
	Else
		Return Left(text(Month),3)
	End If
End Sub

Sub GetDuration(Seconds As Int) As String 
	Dim tempstr As StringBuilder ,temp As Long 
	tempstr.Initialize 
	Seconds = DurTest(Seconds, tempstr, 3600, "HRS")
	Seconds = DurTest(Seconds, tempstr, 60, "MIN")
	Seconds = DurTest(Seconds, tempstr, 1, "SEC")
	If tempstr.Length=0 Then Return "0 SEC"
	Return tempstr.ToString 
End Sub
Sub DurTest(TimeDate As Long, tempstr As StringBuilder, Ticks As Int, Text As String) As Int
	Dim temp As Int 
	If TimeDate>= Ticks Then
		temp = Floor(TimeDate/Ticks)
		'Log(temp)
		TimeDate = TimeDate Mod Ticks
		If temp = 1 Then Text = Text.Replace("S","")
		tempstr.Append(IIF(tempstr.Length=0, "", ", ") & temp & " " & Text)
	End If
	Return TimeDate
End Sub

Sub HowLongAgo(TimeDate As Long) As String 
	Dim Diff As Long,Text As String 
	Diff = DateTime.Now - TimeDate
	If Diff < DateTime.TicksPerMinute Then
		Return "<1 MIN AGO"
	Else If Diff < DateTime.TicksPerHour Then
		Diff = Floor(Diff / DateTime.TicksPerMinute)
		Text = "MIN"
	Else If Diff < DateTime.TicksPerDay Then
		Diff =  Floor(Diff / DateTime.TicksPerHour)
		Text= "HRS"
	Else If Diff< DateTime.TicksPerDay * 7 Then
		Diff = Floor(Diff / DateTime.TicksPerDay)
		Text = "DAYS"
	Else If Diff< (DateTime.TicksPerDay * 30) Then
		Diff = Floor(Diff / (DateTime.TicksPerDay*7))
		Text = "WKS"
	Else If Diff < (DateTime.TicksPerDay * 365) Then
		Diff = Floor(Diff / (DateTime.TicksPerDay*30))
		Text= "MTHS"
	Else
		Diff = Floor(Diff / (DateTime.TicksPerDay*365)) 
		Text = "YRS"
	End If
	If Diff= 1 Then Text = Text.Replace("S", "")
	Return Diff & " " & Text & " AGO"
End Sub

'Form: 0=Full name, 1=Initials + Last name, 2= Last name, -1=clearcache
Sub GetUserName(Form As Int) As String 
	Dim pid As PhoneId, tempContact As Contact , text() As String, tempstr As StringBuilder ,temp As Int 
	'If Form=-1 OR Not(PhoneNumbers.IsInitialized) Then PhoneNumbers.Initialize  
	'If YourName.Length=0 OR Form=-1 OR PhoneNumbers.Size=0 Then 
		Try
			'debug("YOUR PHONE NUMBER: " & pid.GetLine1Number)
			'tempContact=EnumContacts(pid.GetLine1Number,True).Get(0) 
			'tempContact=GetContactByPhoneNumber(pid.GetLine1Number)
			'If tempContact <> Null Then 
			'debug("FULL: " & tempContact)
			'YourName=tempContact.DisplayName 
			If YourName.Length=0 Then tempContact=GetContactByPhoneNumber(pid.GetLine1Number)
			'debug("FAST: " & tempContact)
			If Not(tempContact.DisplayName=Null) AND YourName.Length=0 Then
				YourName=tempContact.DisplayName 
			End If
		Catch
			Return ""
		End Try
	'End If
	If Form=0 OR Not(YourName.Contains(" ")) Then
		Return YourName
	Else
		text = Regex.Split(" ", YourName)
		If Form = 2 Then
			Return text(text.Length-1)
		Else
			tempstr.Initialize 
			For temp = 0 To text.Length-2
				tempstr.Append( Left(text(temp),1).ToUpperCase & ". ")
			Next
			tempstr.Append( Left(text(text.Length-1), 1).ToUpperCase & Right(text(text.Length-1), text(text.Length-1).Length -1).ToLowerCase )
			Return tempstr.ToString 
		End If
	End If
End Sub
Sub GetContactByPhoneNumber(PhoneNumber As String) As Contact 
	Dim ContactList As List , tempContact As Contact,tempContact2 As Contact, tempstr As String , NeedsInit As Boolean ,temp As String, temp2 As Int,tempMap As Map ,CON As Contacts2,ContactExtract As Technis 
'	If Not(PhoneNumbers.IsInitialized) Then
'		NeedsInit =True
'		PhoneNumbers.Initialize 
'	Else If PhoneNumbers.Size=0 Then
'		NeedsInit =True
'	End If
'	If NeedsInit Then
'		Log("GENERATING CACHE")
'		ContactList= EnumContacts("",True) 
'		For temp = 0 To ContactList.Size-1
'			tempContact = ContactList.Get(temp)
'			If Not(tempContact.DisplayName.EqualsIgnoreCase("MiPhone")) Then
'				tempMap=tempContact.GetPhones 
'				For temp2 = 0 To tempMap.Size-1
'					tempstr=FilterPhoneNumber(tempMap.GetKeyAt(temp2))
'					If PhoneNumbers.ContainsKey(tempstr) Then
'						If Not( tempContact.PhoneNumber.EqualsIgnoreCase(tempContact.DisplayName)) Then
'							PhoneNumbers.Put(tempstr, tempContact.Id)
'							Log("DUPE " & tempContact)
'						End If
'					Else
'						PhoneNumbers.Put(tempstr, tempContact.Id)
'					End If
'				Next
'			End If
'		Next
'	End If
	'tempstr=FilterPhoneNumber(PhoneNumber)
	'temp=PhoneNumbers.GetDefault(tempstr,-1)
	'Msgbox(PhoneNumber,"TEST1")
	Try
		temp= ContactExtract.GetContactIDbyPhone(PhoneNumber) 'MUST BE UNCOMMENTED
		If temp.Length>0 Then 
			tempContact2 = CON.GetById(temp,True,True)
		Else
			PhoneNumber=CU.CleanPhone(PhoneNumber)
			If Not(CU.IsInitialized) Then CU.Initialize 
			InitPhoneTypes
			
			For Each c As Contact In CU.EnumContacts
				If HasPhoneNumber(c, PhoneNumber) Then Return c
			Next
		End If
	Catch
		
	End Try
	Return tempContact2
	
	'ContactList = EnumContacts(tempstr,True)
	'If ContactList.Size>0 Then tempContact = ContactList.Get(0)
	'Return tempContact
End Sub
Sub HasPhoneNumber(C As Contact, PhoneNumber As String) As Boolean 
	Dim temp As Int , tempstr As String , IsMatch As Boolean 
	For temp = 0 To C.GetPhones.Size -1 
		tempstr = CU.CleanPhone(C.GetPhones.GetKeyAt(temp))
		IsMatch=PhoneNumber.EndsWith(tempstr) OR tempstr.EndsWith(PhoneNumber)
		'Log(C.DisplayName & " - " &  PhoneNumber & " - " & tempstr & " - " & IsMatch)
		If IsMatch Then Return True
	Next
End Sub







'Action: 0=down, 1=up
Sub MakeKeyEvent(Action As Int, KeyCode As Int) As Object 
	Dim ke As JavaObject
	ke.InitializeNewInstance("android.view.KeyEvent", Array As Object(Action,  KeyCode))   
	Return ke
End Sub
'ie: keycodes.KEYCODE_MEDIA_FAST_FORWARD 
Sub SendMediaButton(TheButton As Int)
	'method 3
	Dim Data As Intent, P As Phone,Command As String 
	Data.Initialize("android.intent.action.MEDIA_BUTTON", "")
	Data.PutExtra("android.intent.extra.KEY_EVENT",MakeKeyEvent(0, TheButton))'needs to be passed as a keyevent, not an Int. 1 is up
'	sendOrderedBroadcast(Data, "")
	P.SendBroadcastIntent(Data)
	
	Data.Initialize("android.intent.action.MEDIA_BUTTON", "")
	Data.PutExtra("android.intent.extra.KEY_EVENT",MakeKeyEvent(1, TheButton))'needs to be passed as a keyevent, not an Int. 1 is up
'	sendOrderedBroadcast(Data, "")
	P.SendBroadcastIntent(Data)
End Sub
Sub ForceMain
	StartActivity(Main)
End Sub

Sub FilterPhoneNumber(Number As String) As String 
	Dim Digits As Int '93,54,61,43,32,55,95,56,86,61,57,53,45,20,33,49,30,36,91,62,98,44,39,81,60,52,31,64,47,9251,63,48,40,65,27,82,34,94,46,41,66,90,44,39,58,84
	If Left(Number,1)= "+" Then
		Number=RemoveAllExceptNumbers(Number) 'Number= Right(Number, Number.Length-1)
		Digits=3
		Select Case Left(Number,4)
			Case 1242,1246,1264,1268,1284,1340,1345,1441,1473,1671,1684,1767,1809 :Digits=4
			Case Else
				Select Case Left(Number,1)
					Case 1, 7: Digits=1
					Case Else
						Select Case Left(Number,2)
							Case 93,54,61,43,32,55,95,56,86,61,57,53,45,20,33,49,30,36,91,62,98,44,39,81,60,52,31,64,47,9251,63,48,40,65,27,82,34,94,46,41,66,90,44,39,58,84:Digits=2
						End Select
'						Select Case Left(Number,4)
'							Case 213,220,224,226,229,233,235,236,237,238,240,241,242,243,244,245,251,253,256,257,260,263,267,269,291,297,298,299:Digits=3
'							Case 350,351,353,354,355,357,358,359,372,374,375,376,380,385,387:Digits=3
'							Case 420,421:Digits=3
'							Case 500,501,502,503,504,506,509,591,592,593,598:Digits=3
'							Case 670,672,673,678,679,681,682,689,690:Digits=3
'							Case 852,855,880,886:Digits=3
'							Case 964,966,967,970,971,972,973,975,994,995,998:Digits=3		
'						End Select
				End Select
		End Select
		Number= Right(Number, Number.Length-Digits)
	End If
	Return RemoveAllExceptNumbers(Number)
End Sub

Sub KillCall'AddPermission("android.permission.CALL_PHONE")
    Dim r As Reflector
    r.Target = r.GetContext
    Dim TelephonyManager, TelephonyInterface As Object
    TelephonyManager = r.RunMethod2("getSystemService", "phone", "java.lang.String")
    r.Target = TelephonyManager
    TelephonyInterface = r.RunMethod("getITelephony")
    r.Target = TelephonyInterface
    r.RunMethod("endCall")
End Sub

Sub SendCall(PhoneNumber As String) As Boolean 
	Dim P As PhoneCalls, tempintent As Intent 
	If PhoneNumber.Length>0 Then 
		'STimer.IncomingCall=False
		STimer.DidAnswer=False
		STimer.ResponseWas=False
		tempintent = P.Call(PhoneNumber.Replace("#","%23"))
		If Not(tempintent=Null) Then
			StartActivity(tempintent)
			Return True
		End If
	End If
End Sub

Sub SendPhotoMessage(PhoneNumber As String, Message As String, Dir As String, Filename As String)
	Dim iIntent As Intent 
	iIntent.Initialize("android.intent.action.SEND_MSG", "")
	iIntent.setType("vnd.android-dir/mms-sms")
	iIntent.PutExtra("android.intent.extra.STREAM", CreateUri("file://" & File.Combine(Dir, Filename)))
	iIntent.PutExtra("sms_body", Message)
	iIntent.PutExtra("address", PhoneNumber)
	iIntent.SetType("image/png")
	AddMessageToLogs(PhoneNumber, Message, File.Combine(Dir, Filename),-1,0 )
	StartActivity(iIntent)
End Sub
Sub CreateUri(Uri As String) As Object
    Dim r As Reflector
    Return r.RunStaticMethod("android.net.Uri", "parse", Array As Object(Uri), Array As String("java.lang.String"))          
End Sub

Sub SendTextMessage(PhoneNumber As String, Message As String,AddToLogs As Boolean )As Boolean 
	Dim SmsManager As PhoneSms ,r As Reflector, parts As Object, temp As Int 
	If PhoneNumber.Length>0 Then
		If AddToLogs Then
			MailParser.SaveOfflineEmail(PhoneNumber, "","", "", Message, False, Array As String(""), -1, "")
		Else
			Try
				Debug("SendTextMessage: " & PhoneNumber & " Message: " & Message)
				'If Not (smssent) Then
					'smssent = True
					If Message.Length <= 160 Then 
						SmsManager.Send(PhoneNumber, Message)
					Else
				    	r.Target = r.RunStaticMethod("android.telephony.SmsManager", "getDefault", Null, Null)
				    	parts = r.RunMethod2("divideMessage", Message, "java.lang.String")
						r.RunMethod4("sendMultipartTextMessage", Array As Object(PhoneNumber, Null, parts, Null, Null), Array As String("java.lang.String", "java.lang.String", "java.util.ArrayList", "java.util.ArrayList", "java.util.ArrayList"))
					End If
					'If AddToLogs Then AddMessageToLogs(PhoneNumber, Message, "",-1, 0)
					Return True
				
				'End If
			Catch
			End Try
		End If
	End If
End Sub
Sub AddMessageToLogs(PhoneNumber As String, Message As String, Filename As String, ThreadID As Int, Status As Int)
    Dim r As Reflector
    r.Target = r.CreateObject("android.content.ContentValues")
    r.RunMethod3("put", "address", "java.lang.String", PhoneNumber, "java.lang.String")
    r.RunMethod3("put", "body", "java.lang.String", Message, "java.lang.String")
	'r.RunMethod3("put", "thread_id", "java.lang.String", thread_id, "java.lang.Integer")
	'r.RunMethod3("put", "status", "java.lang.String", status, "java.lang.Integer")
    Dim ContentValues As Object = r.Target
    r.Target = r.GetContext
    r.Target = r.RunMethod("getContentResolver")
    r.RunMethod4("insert", Array As Object(r.RunStaticMethod("android.net.Uri", "parse", Array As Object("content://sms/sent"), Array As String("java.lang.String")), ContentValues), Array As String("android.net.Uri", "android.content.ContentValues"))
End Sub

Sub FindContactID(ID As Int, ContactList As List) As Int
	Dim temp As Int, tempContact As Contact
	For temp = 0 To ContactList.Size-1
		tempContact= ContactList.Get(temp)
		If tempContact.ID=ID Then Return temp
	Next
	Return -1
End Sub
Sub GetContactByID(ID As Int) As Contact 
	Dim CON As Contacts2
	Return CON.GetById(ID,True,True) 
End Sub

'Name: * = favorites, [text]* = name must start with [text], # = starts with a number, [number] = find by phone number, [number]+[any other symbol] = find by id number
Sub EnumContacts2(Name As String) As List 'returns a list of type Contact
	Dim Names As List, temp As Int, c As cuContact , theContacts As List 
	If Not(CU.IsInitialized) Then CU.Initialize 
	InitPhoneTypes
	If Name.Length= 0 Then'all
		Names = CU.FindAllContacts(True)
	Else If Name = "*" Then'* = favorites
		Names = CU.FindContactsByStarred(True)
	Else If Name = "#" Then'# = starts with a number
		Names = CU.FindAllContacts(True)
		For temp = Names.Size-1 To 0 Step -1
			c = Names.Get(temp)
			If Not(IsNumber(Left(c.DisplayName,1))) Then Names.RemoveAt(temp)
		Next
	Else If Name.EndsWith("*") Then '[text]* = name must start with [text]
		Name = Left(Name , Name.Length-1).ToLowerCase 
		Names = CU.FindContactsByName(Name, False,True)
		For temp = Names.Size-1 To 0 Step -1
			c = Names.Get(temp)
			If Not(c.DisplayName.ToLowerCase.StartsWith(Name)) Then Names.RemoveAt(temp)
		Next
	Else If IsNumber(Name) Then'[number] = find by phone number
		Names = CU.FindContactsByPhone(Name, False, True)
	Else If IsNumber(RemoveAllExceptNumbers(Name)) Then'[number]+[any other symbol] = find by id number
		Name = RemoveAllExceptNumbers(Name)
		Names = CU.FindAllContacts(True)
		For temp = Names.Size-1 To 0 Step -1
			c = Names.Get(temp)
			If c.Id <> Name Then Names.RemoveAt(temp)
		Next
	End If
	
	theContacts.Initialize 
	For Each c As cuContact In Names' IDtoContact
		theContacts.Add( CU.IDtoContact(c.Id,c.DisplayName))
	Next
	Return theContacts 
End Sub

'Name: * = favorites, [text]* = name must start with [text], # = starts with a number, [number] = find by phone number, [number]+[any other symbol] = find by id number
Sub EnumContacts(Name As String, HasNames As Boolean) As List 'returns a list of type Contact
	Return EnumContacts2(Name)
	
	Dim CON As Contacts2 ,tempContact As Contact, Names As List, Special As Int,DoRemove As Boolean  
	Dim temp As Int, temp2 As Int, tempContact As Contact , tempMap As Map,tempstr As String 
	If Name.Length =0 OR Name = "*" OR Name = "#" OR IsNumber(Name) Then
		Names = CON.GetAll(True,False)
		Select Case Name
			Case "*": Special = 1'get favorites
			Case "#": Special = 3'get names starting with number
			Case Else:If IsNumber(Name) Then  Special = 4'get by phone number	
		End Select
	Else If IsNumber(RemoveAllExceptNumbers(Name)) Then'get by id number
		Names.Initialize
		tempContact = CON.GetById(Name,True,True)
		If tempContact<> Null Then Names.Add(tempContact)
		Return Names
	Else If Name.Contains("@") AND Name.Contains(".") Then'get by email address
		Names = CON.FindByMail(Name,False,True,True)
	Else'get by name
		If Right(Name,1)= "*" Then'get names starting with text
			Special=2
			Name = Left(Name, Name.Length-1).ToUpperCase 
		End If
		Names = CON.FindByName(Name,False, True,True)
	End If
	If Names<>Null AND Names.IsInitialized Then 
		If Special>0 OR HasNames Then
			For temp = Names.Size-1 To 0 Step -1
				tempContact= Names.Get(temp)
				DoRemove=False
				If HasNames Then
					If tempContact.DisplayName.Contains("@") Then 
						DoRemove =True
					Else If tempContact.DisplayName.EqualsIgnoreCase("DISQUS") Then
						DoRemove =True
					Else If  tempContact.DisplayName.Contains(", (Google+)") Then
						DoRemove =True
					Else If tempContact.DisplayName.Trim.Length=0 Then
						DoRemove =True
					End If
				End If
				If Not(DoRemove) Then
					Select Case Special
						Case 1'favorites only
							If Not(tempContact.Starred) Then DoRemove=True
						Case 2'starts with name text
							If Not(tempContact.Name.ToUpperCase.StartsWith(Name)) Then DoRemove=True
						Case 3'starts with a number
							If Not(IsNumber( Left(tempContact.Name,1)))   Then DoRemove=True
						Case 4'search by phone number
							DoRemove=True
							tempMap=tempContact.GetPhones
							For temp2 = 0 To tempMap.Size-1
								tempstr=RemoveAllExceptNumbers(tempMap.GetKeyAt(temp2))
								If tempstr = Right(Name, tempstr.Length) Then
									DoRemove=False
									temp2=tempMap.Size
								End If
							Next
					End Select	
				End If
				
				If DoRemove Then Names.RemoveAt(temp) 
			Next
		End If
		
		'debug
'		For temp = 0 To Names.Size-1
'			tempContact= Names.Get(temp)
'			tempMap= tempContact.GetEmails 
'			
'			'If tempContact.PhoneNumber.Length>0 Then Log(tempContact.DisplayName & " " & tempContact.PhoneNumber )
'			tempMap=tempContact.GetPhones  
'			If tempMap.Size>0 Then
'				'debug(tempContact)
'				Log(tempContact.DisplayName & " " & tempMap)
'			
'				EnumCallLogs(20,tempMap)
'				EnumSMSmessages(tempContact.Id)
'			End If
'		Next
	End If
	If Names=Null Then 
		Names.Initialize 
	'Else
		'Names.SortType("DisplayName", True)
	End If
	Return Names
End Sub

Sub Backup(DoCalls As Boolean,Dir As String, Filename As String)As String 
	Dim Calls As List, CallLog As CallLog,temp As Int , c As CallItem, OUT As TextWriter ,TD As String ,SmsMessages1 As SmsMessages,theSms As Sms,tempContact As Contact
	If Filename.Length =0 Then Filename = IIF(DoCalls, "Call logs ", "SMS logs ") & DateTime.Date(DateTime.Now) & " " & DateTime.Time(DateTime.Now) & ".html"
	Filename=Filename.Replace("/", "-").Replace(":", "")
	TD="</TD><TD>"
	OUT.Initialize(File.OpenOutput(Dir,Filename,False))
	OUT.WriteLine("<TABLE BORDER=2 CELLPADDING=2 CELLSPACING=2>")
	If DoCalls Then
		OUT.WriteLine("	<TR><TH>Name</TH><TH>Number</TH><TH>Date</TH><TH>Duration</TH><TH>Type</TH></TR>")
		Calls = CallLog.GetAll(0)
		For temp = 0 To Calls.Size - 1 'To 0 Step -1
			c = Calls.Get(temp)
			OUT.Write("	<TR><TD>" & c.CachedName & TD & c.Number & TD & DateTime.Date(c.Date) & " " & DateTime.Time(c.Date) & TD & GetTime(c.Duration) & TD)
			Select Case c.CallType 
				Case c.TYPE_INCOMING: 	OUT.WriteLine("Incoming</TD></TR>")
				Case c.TYPE_MISSED: 	OUT.WriteLine("Missed</TD></TR>")
				Case c.TYPE_OUTGOING :	OUT.WriteLine("Outgoing</TD></TR>")
			End Select
		Next
	Else
		Calls = SmsMessages1.GetAll
		OUT.WriteLine("	<TR><TH>Name</TH><TH>Number</TH><TH>Date</TH><TH>Read</TH><TH>Type</TH></TR>")
		For temp = 0 To Calls.Size-1
			theSms = Calls.Get(temp)
			tempContact = GetContactByPhoneNumber(theSms.Address)
			If tempContact.DisplayName = Null Then
				OUT.Write("	<TR><TD>Unknown")
			Else
				OUT.Write("	<TR><TD>" & tempContact.DisplayName)
			End If
			OUT.Write(TD & theSms.Address & TD & DateTime.Time(theSms.Date) & TD & GetTime(theSms.Date) & TD & IIF(theSms.Read, "Yes", "No") & TD)
			Select Case (theSms.Type)
				Case SmsMessages1.TYPE_DRAFT: 	OUT.WriteLine("Draft</TD></TR>")
				Case SmsMessages1.TYPE_FAILED: 	OUT.WriteLine("Failed</TD></TR>")
				Case SmsMessages1.TYPE_INBOX: 	OUT.WriteLine("Inbox</TD></TR>")
				Case SmsMessages1.TYPE_OUTBOX: 	OUT.WriteLine("Outbox</TD></TR>")
				Case SmsMessages1.TYPE_QUEUED: 	OUT.WriteLine("Queued</TD></TR>")
				Case SmsMessages1.TYPE_SENT: 	OUT.WriteLine("Sent</TD></TR>")
				Case SmsMessages1.TYPE_UNKNOWN: OUT.WriteLine("Unknown</TD></TR>")
			End Select
			OUT.WriteLine("	<TR><TD colspan=5>" & theSms.Body & "</TD></TR>")
		Next
	End If
	OUT.WriteLine("</TABLE>")
	OUT.Close 
	Return File.Combine(Dir,Filename)
End Sub
'Zero = all

'Sub DeleteCallLogs
'	Dim Calls As List, CallLog As CallLog,temp As Int , c As CallItem, reg As MyFirstLib
'	Calls = CallLog.GetAll(0)
'	For temp = Calls.Size-1 To 0 Step -1
'		c = Calls.Get(temp)
'		reg.DeleteCallLogs(c.Number)
'	Next
'End Sub
Sub EnumCallLogs(Quantity As Int, Phones As Map) As List 
	Dim Calls As List, CallLog As CallLog,temp As Int, temp2 As Int,Found As Boolean ,tempstr As String , c As CallItem
	
	If Phones.IsInitialized Then'filter by contact info
		Calls = CallLog.GetAll(Quantity)
		For temp = 0 To Calls.Size - 1 'To 0 Step -1
			Found=False
			If temp<Calls.Size Then
				If Not(Quantity>0 AND temp>=Quantity) Then
					c = Calls.Get(temp)
					tempstr=FilterPhoneNumber(c.Number)
					For temp2 = 0 To Phones.Size-1
						If FilterPhoneNumber(Phones.GetKeyAt(temp2)) = tempstr Then 
							Found=True
							temp2=Phones.Size 
						End If
					Next
				End If
				If Not(Found) Then 
					Calls.RemoveAt(temp)
					temp=temp-1
				End If
			End If
		Next
	Else
		Calls = CallLog.GetAll(Quantity)
	End If
	
	'debug
'	For temp = 0 To Calls.Size - 1
'	    Dim c As CallItem, callType, name As String
'	    c = Calls.Get(temp)
'	    Select c.callType
'	        Case c.TYPE_INCOMING:	callType = "Incoming"
'	        Case c.TYPE_MISSED:		callType = "Missed"
'	        Case c.TYPE_OUTGOING:	callType = "Outgoing"
'	    End Select
'	    name = c.CachedName
'	    If name.Length = 0 Then name = "N/A"
'	    Log("Number=" & c.Number & ", Name=" & name & ", Type=" & callType & ", Date=" & DateTime.Date(c.Date))
'	Next 
	If Not(Calls.IsInitialized) Then Calls.Initialize
	Return Calls
End Sub

'-1 = all unread
Sub EnumSMSmessages(PersonID As Int, Delete As Boolean) As List 
	Dim SmsMessages1 As SmsMessages, List1 As List
	If PersonID=-1 Then
		List1 = SmsMessages1.GetUnreadMessages 
	Else
		List1 = SmsMessages1.GetByPersonId(PersonID)
		If List1.Size=0 Then
			Dim  tempContact As Contact ,CON As Contacts2, tempMap As Map, temp As Int, temp2 As Int ,theSms As Sms, Include As Boolean ,tempstr As String
			'List1 = SmsMessages1.GetAll 
			List1 =SmsMessages1.GetBetweenDates(DateTime.Now - DateTime.TicksPerDay*60, DateTime.Now)
			tempMap.Initialize 
			'tempContact = CON.GetById(PersonID,False,False)
			'tempMap = tempContact.GetPhones
			For temp = List1.Size - 1 To 0 Step -1 
				theSms = List1.Get(temp)
				tempstr=FilterPhoneNumber(theSms.Address )
				If tempMap.ContainsKey(tempstr)  Then
					Include=tempMap.Get(tempstr)
				Else
					Include=True
					tempContact=GetContactByPhoneNumber(theSms.Address)
					If tempContact=Null Then
						Include=False
					Else If Not(tempContact.Id  = PersonID) Then 
						Include=False
					End If
					tempMap.Put(tempstr,Include)
				End If
				'tempstr=FilterPhoneNumber(theSms.Address)
				'For temp2 = 0 To tempMap.Size-1
				'	If tempstr = FilterPhoneNumber(tempMap.GetKeyAt(temp2)) Then
				'		Include=True
				'		temp2=tempMap.Size
				'	End If
				'Next

				If Not(Include) Then 
					List1.RemoveAt(temp)
				Else If Delete Then
					SmsMessages1.DeleteSMS(theSms.Id)
				Else
					MarkSmsAsRead(theSms.Id)
				End If
			Next
		End If
	End If
	List1.SortType("Date", False)
	'List1.SortType("Id",True)
	
	'debug
'	Log(List1.Size & " messages found for person " & PersonID)
'	For i = 0 To List1.Size - 1
'	    theSms = List1.Get(i)'Type: 1=to you, 2=from you
'	    Log(theSms)
'	Next 

'	
	Return List1
End Sub

Sub DeleteSMSlogs(ID As Int, IsPerson As Boolean)
	If IsPerson Then
		EnumSMSmessages(ID,True)
	Else
		EnumSMSmessagesByThread(ID,True)
	End If
End Sub

Sub GetContactByThreadID(ThreadID As Int) As Contact 
	Dim SmsMessages1 As SmsMessages, List1 As List,tempContact As Contact,theSms As Sms
	List1 = SmsMessages1.GetByThreadId(ThreadID)
	'Msgbox(List1,"GetContactByThreadID")
	If List1.Size>0 Then
		theSms=  List1.Get(0)
		tempContact= GetContactByPhoneNumber(theSms.Address)
	End If
	'Msgbox(tempContact,"tempContact")
	Return tempContact
End Sub
Sub EnumSMSmessagesByThread(ThreadID As Int,Delete As Boolean) As List
	Dim SmsMessages1 As SmsMessages, List1 As List,temp As Int ,theSms As Sms, List2 As List ,tempMap As Map,temp2 As Int
	If ThreadID=-1 Then'enum threads
		List1.Initialize 
		tempMap.Initialize 
		'debug("Getting SMS messages")
		List2 = SmsMessages1.GetAll
		
		For temp = List2.Size - 1 To 0 Step -1 
			theSms = List2.Get(temp)
			If Delete Then
				SmsMessages1.DeleteSMS(theSms.Id)
			Else
				If List1.IndexOf(theSms.ThreadID)=-1 Then List1.Add(theSms.ThreadID)
				If Not(theSms.Read) Then tempMap.Put(theSms.ThreadID, False)
			End If
		Next
		If Delete Then Return List1
		
		List1.Sort(True)
		'debug("Sorting by unread")
		'put unread threads at the top
		For temp = List1.Size-1 To 1 Step -1
			temp2= List1.Get(temp)
			If Not(tempMap.GetDefault(temp2, True)) Then
				List1.RemoveAt(temp)
				List1.InsertAt(0, temp2)
				temp=temp+1
			End If
		Next
		UnreadThreads = tempMap.Size 
	Else
		List1 = SmsMessages1.GetByThreadId(ThreadID)
		For temp = List1.Size - 1 To 0 Step -1 
			theSms = List1.Get(temp)
			If Delete Then SmsMessages1.DeleteSMS(theSms.Id) Else MarkSmsAsRead(theSms.Id)
		Next
		If Not(Delete) Then List1.SortType("Date", False)
	End If
	
	'Msgbox(List1, "THREADS")
	Return List1 
	
End Sub
Sub MarkSmsAsRead(messageId As Long)
	Dim u As Uri, cr As ContentResolver, crsr As Cursor
	cr.Initialize("cr")
	u.Parse("content://sms/")
	crsr = cr.Query(u, Array As String("_id"), "_id = ?", Array As String(messageId), "")
	If crsr.RowCount > 0 Then      
		crsr.Position = 0
		Dim cv As ContentValues
		cv.Initialize
		cv.PutBoolean("read", True)
		cr.Update(u, cv, "_id = " & messageId,Null)
	End If
	crsr.Close
End Sub
Sub AddressOfThread(ThreadID As Int) As String 
	Dim SmsMessages1 As SmsMessages, List1 As List,theSms As Sms
	List1 = SmsMessages1.GetByThreadId(ThreadID)
	If List1.Size>0 Then
		theSms= List1.Get(0)
		Return theSms.Address'FilterPhoneNumber(theSms.Address)
	End If
	Return ""
End Sub

Sub ClearCallLogs
	Dim CON As ContentResolver, r As Reflector, CONTENT_URI As Object
	CON.Initialize("")
	r.Target = r.GetContext
	r.Target = r.RunMethod("getContentResolver")
	CONTENT_URI = r.GetStaticField("android.provider.CallLog$Calls", "CONTENT_URI")'content://call_log/calls
	CON.Delete(CONTENT_URI, "DURATION >= 0",Null)
	'r.RunMethod4("delete", Array As Object(CONTENT_URI, Null, Null), Array As String("android.net.Uri", "java.lang.String", "[Ljava.lang.String;"))
End Sub


Sub RemoveAllExceptNumbers(Text As String) As String
	Dim tempstr As StringBuilder ,temp As Int ,Chars As String
	tempstr.Initialize 
	For temp = 0 To Text.Length-1 
		Chars=Mid(Text,temp,1)
		If IsNumber(Chars) Then tempstr.Append(Chars)
	Next
	Return tempstr.ToString 
End Sub

Sub RemoveFromQuotes(Text As String) As String
	Text=Text.Trim 
	If Left(Text,1)= vbQuote Then Text = Right(Text, Text.Length-1)
	If Right(Text,1)=vbQuote Then Text = Left(Text, Text.Length-1)
	Return Text
End Sub








Sub IsPackageInstalled(PackageName As String)
	Dim PM As PackageManager , temp As Int =-1
 	Try
 		temp = PM.GetVersionCode(PackageName)
	Catch
		temp=-1
	End Try
	Return temp>-1
End Sub



Sub ListSize(tList As List) As Int
	If tList.IsInitialized Then Return tList.Size
	Return 0
End Sub 

Sub Model(ID As Int) As String 
	Dim P As Phone 
	If P.Manufacturer.EqualsIgnoreCase("samsung") Then
		If ID>0 And P.Model.StartsWith("GT-") Then Return "GALAXY"
	End If
	Select Case ID
		Case 0: Return P.Manufacturer 
		Case 1: Return P.Model
		Case 2: Return P.Product 
	End Select
End Sub
Sub SetRingtone(RingType As Int, Uri As String) As Boolean 
	Dim RING As RingtoneManager 
	If Uri.Length>0 Then
		Select Case RingType 
			Case DIRECTORY_ALARMS:			RingType = RING.TYPE_ALARM 
			Case DIRECTORY_RINGTONES:		RingType = RING.TYPE_RINGTONE 
			Case DIRECTORY_NOTIFICATIONS:	RingType = RING.TYPE_NOTIFICATION 
			Case Else: Return False
		End Select
		Try
			RING.SetDefault(RingType, Uri) 
			Return True
		Catch
			Return False
		End Try
	End If
End Sub
Sub GetSystemDir(Dir As Int) As String 
	Dim tempstr As String 
	Select Case Dir
		Case DIRECTORY_PICTURES:		tempstr= "Pictures"
		Case DIRECTORY_MUSIC:			tempstr= "Music"
		Case DIRECTORY_RINGTONES:		tempstr= "Ringtones"
		Case DIRECTORY_ALARMS:			tempstr= "Alarms"
		Case DIRECTORY_DCIM:			tempstr= "DCIM"
		Case DIRECTORY_DOWNLOADS:		tempstr= "Download"
		Case DIRECTORY_MOVIES:			tempstr= "Movies"
		Case DIRECTORY_NOTIFICATIONS:	tempstr= "Notifications"
		Case DIRECTORY_PODCASTS:		tempstr= "Podcasts"
		Case Else: 						Return ""
	End Select 
	If File.exists(File.Combine(File.DirRootExternal, "media"), tempstr.ToLowerCase) Then
		Return File.Combine(File.Combine(File.DirRootExternal, "media"), tempstr.ToLowerCase)
	Else If File.Exists(File.DirRootExternal, tempstr) Then
		Return File.Combine(File.DirRootExternal, tempstr)
	Else If File.Exists(File.DirRootExternal, tempstr.ToLowerCase) Then
		Return File.Combine(File.DirRootExternal, tempstr.ToLowerCase)
	End If
	Return ""
End Sub

Sub Debug(Text As String)
	Return
'	Dim temp As BClipboard 
'	If DebugStr.IsInitialized Then
'		DebugStr.Append(CRLF & Text)
'	Else
'		DebugStr.Initialize 
'		DebugStr.Append(Text)
'	End If
'	temp.clrText 
'	temp.setText(DebugStr.ToString)

	Dim tempstr As TextWriter  
	tempstr.Initialize( File.OpenOutput(File.DirRootExternal,"error.txt",True) )
	tempstr.WriteLine(Text)
	tempstr.Close 
End Sub

Sub LoadMap(Dir As String, Filename As String) As Map 
	If Dir.Length>0 Then
		If File.Exists(Dir, Filename) Then Return File.ReadMap( Dir, Filename) 
	End If
End Sub


Sub RenameFile(SrcDir As String, SrcFilename As String, DestDir As String, DestFilename As String) As Boolean
    Dim R As Reflector, NewObj As Object, New As String , Old As String ', Ph As Phone, Q As String: Q=Chr(34)
	If SrcFilename=Null OR DestFilename=Null OR SrcDir=Null OR DestDir=Null Then Return False
	If File.Exists(SrcDir,SrcFilename) AND Not(File.Exists(DestDir,DestFilename)) Then    
		'Return Ph.Shell("mv " & Q & File.Combine(SrcDir,SrcFilename) & Q &  " "  & Q &  File.Combine(DestDir,DestFilename)  & Q, Null, Null, Null) = 0
		New=File.Combine(DestDir,DestFilename)
		Old=File.Combine(SrcDir,SrcFilename)
		If Not(New = Old) Then
    		NewObj=R.CreateObject2("java.io.File",Array As Object(New),Array As String("java.lang.String"))
    		R.Target=R.CreateObject2("java.io.File",Array As Object(Old),Array As String("java.lang.String"))
    		Return R.RunMethod4("renameTo",Array As Object(NewObj),Array As String("java.io.File"))
		End If
	End If
	Return False
End Sub

Sub LimitTextWidth(BG As Canvas, Text As String,  theTypeface As Typeface, TextSize As Int, Width As Int, AppendString As String) As String 
	Dim temp As Int 
	If Text.Length>0 Then
		temp = BG.MeasureStringWidth(Text, theTypeface,TextSize)
		If temp> Width Then
			Do While temp > Width AND Text.Length>0
				Text= Left(Text, Text.Length-1)
				temp = BG.MeasureStringWidth(Text & AppendString, theTypeface,TextSize)
			Loop
			Return Text & AppendString
		End If
	End If
	Return Text
End Sub
Sub DrawText(BG As Canvas,Text As String , X As Int, Y As Int, theTypeface As Typeface, TextSize As Int, Color As Int, Align As Int)
	Dim Alignment As String 
	Select Case Align
		Case 0,1:Alignment="LEFT"
		Case 2:Alignment="CENTER"
		Case 3:Alignment="RIGHT"
	End Select
	BG.DrawText(Text,X,Y+ BG.MeasureStringHeight(Text,theTypeface,TextSize) *0.5,theTypeface,TextSize,Color, Alignment)
End Sub

Sub Plural(Value As Int, Singular As String, Pluralized As String) As String 
	If Value=1 Then Return Singular Else Return Pluralized
End Sub

Sub Move(OBJ As View, ACT As Activity, X As Int, Y As Int, Width As Int, Height As Int)
	Try
	If Not(OBJ = Null) AND Not(ACT = Null) Then
		If X<0 Then
			OBJ.Left = ACT.Width-X
		Else
			OBJ.Left=X
		End If
		If Y<0 Then
			OBJ.top = ACT.Width-Y
		Else
			OBJ.top=Y
		End If
		If Width<1 Then
			OBJ.Width = ACT.Width-OBJ.Left +Width
		Else
			OBJ.Width=Width
		End If
		If Height<1 Then
			OBJ.Height = ACT.Height-OBJ.top +Height
		Else
			OBJ.Height=Height
		End If
	End If
	Catch
	End Try
End Sub

Sub GetTextHeight(BG As Canvas, DesiredHeight As Int, Text As String, theTypeface As Typeface ) As Int 
	Dim temp As Int,CurrentHeight As Int 
	If theTypeface.IsInitialized Then
		Do Until temp >=  Abs(DesiredHeight)
			CurrentHeight=CurrentHeight+1
			If DesiredHeight>0 Then
				temp = BG.MeasureStringHeight(Text, theTypeface, CurrentHeight)
			Else
				temp = BG.MeasureStringWidth(Text, theTypeface, CurrentHeight)
			End If
		Loop
		If temp>=Abs(DesiredHeight) Then CurrentHeight=CurrentHeight-1
	End If
	Return CurrentHeight
End Sub

Sub GetDevicePhysicalSize As Float
    Dim lv As LayoutValues
    lv = GetDeviceLayoutValues
    Return Sqrt(Power(lv.Height / lv.Scale / 160, 2) + Power(lv.Width / lv.Scale / 160, 2))
End Sub

Sub GetUniqueKey(Mac As Boolean ) As String 
	If Mac Then
		Dim myWifi As ABWifi
		myWifi.ABLoadWifi
		Return myWifi.ABGetCurrentWifiInfo().MacAddress
	Else
	    Dim R As Reflector
	    R.Target = R.RunStaticMethod("java.util.UUID", "randomUUID", Null, Null)
	    Return R.RunMethod("toString")
	End If
End Sub

Sub PadtoLength(Text As String, LeftSide As Boolean , Length As Int, PadChar As String ) As String 
	Dim temp As Int,tempstr As StringBuilder 
	If PadChar.Length=0 OR PadChar.Length>1 Then PadChar = " "
	If Text.Length<Length Then
		tempstr.Initialize 
		For temp = Text.Length+1 To Length
			tempstr.Append(PadChar)
		Next
		If LeftSide Then
			Return tempstr.ToString & Text
		Else
			Return Text & tempstr.ToString 
		End If
	Else
		Return Text
	End If
End Sub

Sub IsBetween(Lower As Int, Higher As Int, Value As Int) As Boolean 
	Return Value >=Lower AND Value<=Higher
End Sub

Sub IsEven(Value As Int) As Boolean 
	Return (Value Mod 2)=0 
End Sub

Sub IsMyDevice(Mark As Boolean ) As Boolean 
	Dim NeoTechni As String:NeoTechni = "NeoTechni.txt"
	If Mark Then File.WriteString(File.DirRootExternal, NeoTechni, NeoTechni)
	Return File.Exists(File.DirRootExternal , NeoTechni)
End Sub

Sub IsInIDE As Boolean 
	If Not(HasChecked) Then 
		Dim R As Reflector
		debugMode = R.GetStaticField("anywheresoftware.b4a.BA", "debugMode")
		HasChecked =True
	End If
	Return debugMode
End Sub 



Sub Limit(Value As Int, Lower As Int, Upper As Int) As Int
	Return Max(Min(Upper,Value), Lower)
End Sub

Sub IIFIndex(Index As Int, Values As List) As String 
	If Index<Values.Size AND Index>-1 Then Return Values.Get(Index)
	Return ""
End Sub
Sub GetIndex(Text As String, Values As List) As Int 
	Return Values.IndexOf(Text)
End Sub

Sub IIF(Value As Boolean , IfTrue, IfFalse)
	If Value Then 
		Return IfTrue 
	Else 
		Return IfFalse
	End If
End Sub

Sub ParseCommand(Text As String) As List
	Dim temp As List ,tempstr As String ,temp2 As Int 
	temp.Initialize 
	Do Until Text.Length =0
		temp2=GrabWord(Text)
		tempstr= Left(Text,temp2)
		Select Case Left(tempstr,1)
			Case "'",Chr(34)
				temp.Add(Mid(tempstr, 1, tempstr.Length-2))
			Case Else
				temp.Add(tempstr)
		End Select
		
		Text=Right(Text, Text.Length-temp2).Trim 
	Loop
	Return temp
End Sub

Sub GrabAWord(Text As String) As String 
	Dim temp As Int 
	temp=GrabWord(Text)
	Return Left(Text,temp)
End Sub

Sub GrabWord(Text As String) As Int
	Dim Char1 As String,temp As Int   
	Char1= Left(Text,1)
	Select Case Char1
		Case " ": Return 0
		Case "'",Chr(34)
			Return Instr(Text, Char1, 1)+1
		Case Else
			temp = Instr(Text, " ", 1)
			If temp=-1 Then 
				Return Text.Length
			Else 
				Return temp
			End If
	End Select
End Sub

Sub ParseIP(IP As String ) As IPaddress 
	Dim octets() As String ,temp As IPaddress ,tempstr2() As String ,temp2 As Int 
	octets= Regex.Split("\.", IP)
	temp.Initialize 
	If octets.Length >= 4 Then 
		For temp2 = 0 To 2 
			If octets(temp2).Length = 0 OR Not(IsNumber(octets(temp2))) Then octets(temp2) = 0
			temp.octets(temp2)= Max(0, Min(255, octets(temp2)))
		Next
		If octets(3).Contains(":") Then
			tempstr2=Regex.Split(":", octets(3))
			If IsNumber(tempstr2(0)) AND IsNumber(tempstr2(1)) Then
				temp.octets(3)=Max(0, Min(255, tempstr2(0)))'tempstr2(0)
				temp.Port = Max(0,tempstr2(1).Trim )
			End If
		Else
			If IsNumber(temp.octets(3)) Then temp.octets(3)= Max(0, Min(255, octets(3)))' temp.octets(3)=octets(3)
		End If
	End If
	Return temp
End Sub
Sub GetIP(IP As IPaddress, IncludePort As Boolean) As String
	Dim tempstr As String 
	tempstr = IP.Octets(0) & "." & IP.Octets(1) & "." & IP.Octets(2) & "." & IP.Octets(3) 
	If IncludePort Then tempstr= tempstr & ":" & IP.Port 
	Return tempstr
End Sub
Sub GetOctet(IP As IPaddress) As String 
	If IP.SelectedOctet=4 Then
		Return IP.Port 
	Else 
		Return IP.Octets(IP.SelectedOctet)
	End If
End Sub
Sub SetOctet(IP As IPaddress, Octet As Int, Value As Int) As IPaddress 
	If Octet=4 Then
		IP.Port=Value
	Else
		If Value<0 Or Value>255 Then Value=0
		IP.Octets(Octet)=Value
	End If
	Return IP
End Sub
Sub GetSide2(Text As String, Delimeter As String, isLeft As Boolean) As String
	Dim Start As Int = Instr(Text, Delimeter, 0)
	If Start > -1 Then
		If isLeft Then Return Left(Text, Start)
		Return Right(Text, Text.Length - Start -1)
	End If
End Sub
Sub GetURLfilename(URL As String) As String
	'https://sites.google.com/site/vkwidgetskins/apks/classes.dex?attredirects=0&d=1
	URL = Right(URL, URL.Length - URL.LastIndexOf("/") - 1)
	If URL.Contains("?") Then URL = Left(URL, URL.IndexOf("?"))
	Return URL
End Sub
Sub DownloadURL(URL As String) 
	'?useskin=wikiamobile  en.memory-alpha.org
	Dim temp As Int 
	LCAR.forceshow(18,True)
	LCAR.LCAR_SetElementText( 18, "LOADING", "")
	aHREF=""
	temp = URL.IndexOf("#")
	If temp>0 Then
		If URL.Contains("?") Then
			aHREF= "#" & GetBetween(URL, "#", "?") & "?"
			URL=URL.Replace(aHREF, "")
		Else
			aHREF=Right(URL, URL.Length-temp)
			URL = Left(URL, temp)
		End If
	End If
	If Not (URL.ToLowerCase.StartsWith("http://")) Then URL = "http://" & URL
	'If  URL.ToLowerCase.StartsWith("http://memory-alpha.org/") Or  URL.ToLowerCase.StartsWith("http://en.memory-alpha.org/") Then' url = url & "?useskin=wikiamobile"
	'	If Not(URL.Contains("?")) Then URL=URL & "?" Else  URL=URL & "&"
	'	URL=URL & "useskin=wikiamobile"
	'End If
	dURL=URL
	CallSub3(STimer, "DownloadFile", "WebPage", URL)
	'HttpUtils.download("WebPage", URL)
End Sub
'Sub Searchfor(Content As String ) As String 
'	Dim temp As String 
'	temp="http://en.memory-alpha.org/wiki/index.php?title=Special:Search&search=" & Content
'	DownloadURL(temp)
'	Return temp
'End Sub

Sub GetBaseURL(URL As String) As String
	Dim temp As Int
	temp = URL.IndexOf2("/",8)
	If temp=-1 Then
		Return URL
	Else
		Return Left(URL,temp)
	End If
End Sub


Sub MakeHTMLColor(LCARcolorID As Int) As String 
	Dim temp As LCARColor 
	temp=LCAR.LCARcolors.Get(LCARcolorID)
	Return "#" & Hex(temp.nR) & Hex(temp.nG) & Hex(temp.nB)
End Sub 


Sub Hex(Number As Int) As String 
	Dim temp As Int
	temp = Floor(Number / 16)
	Return ToHex(temp) & ToHex(Number - temp*16)
End Sub
Sub ToHex(Number As Int) As String 
	If Number < 10 Then 
		Return Number 
	Else
		Return Chr(Number-10+ Asc("A"))
	End If
End Sub
Sub ToDec(Hexadecimal As String) As Int
	Dim Multiplier As Int = 1, CurrentChar As String, CurrentCharValue As Int ,TotalValue As Int 
	Do Until Hexadecimal.Length=0
		CurrentChar=Right(Hexadecimal,1).ToUpperCase
		Hexadecimal=Left(Hexadecimal,Hexadecimal.Length-1)
		If IsNumber(CurrentChar) Then
			CurrentCharValue=CurrentChar
		Else
			CurrentCharValue = 10 + Asc(CurrentChar)-Asc("A")
		End If
		TotalValue=TotalValue+ (CurrentCharValue*Multiplier)
		Multiplier=Multiplier*16
	Loop
	Return TotalValue
End Sub

Sub MakeErrrorPage(URL As String, Error As String )As String 
	Return "<IMG SRC='file:///android_asset/data.png'><P><H1>WEB PAGE NOT AVAILABLE</H1><P>THE WEB PAGE AT <A HREF='" & URL & "'><FONT COLOR=#FF0000>" & URL.ToUpperCase & "</FONT></A> MIGHT BE TEMPORARILY DOWN OR IT MAY HAVE BEEN MOVED PERMANENTLY TO A NEW WEB ADDRESS.<p><B>HERE ARE SOME SUGGESTIONS</B><P><UL><LI>CHECK TO MAKE SURE YOUR DEVICE HAS A SIGNAL AND DATA CONNECTION</LI><LI>RELOAD THIS WEB PAGE LATER</LI><LI>VIEW A CACHED COPY OF THE WEB PAGE FROM GOOGLE</LI></UL><P>" & Error.ToUpperCase
End Sub


Sub GetDir(Filename As String) As String
	Return GetSide(Filename, "/", True,False)
End Sub
Sub GetFile(Filename As String) As String
	Return GetSide(Filename, "/", False,False)
End Sub

Sub GetSide(Text As String, Delimeter As String, LeftSide As Boolean,DoRightSide As Boolean  ) As String 
	Dim temp As Int
	If Text.Contains(Delimeter) Then
		temp=Text.LastIndexOf(Delimeter)
		If LeftSide Then
			Return Left(Text,temp)
		Else
			Return Right(Text, Text.Length-temp-1)
		End If
	Else
		If LeftSide OR DoRightSide Then Return Text
	End If
End Sub

Sub ScrollTo(Section As Int)As String 
	Dim filename As String 
	filename= FileLoaded'"file://" & LCAR.DirDefaultExternal & "/HTML/index.html" 
	'If section>-1 Then filename = filename & "#NID" & section
	If filename.Length=0  Then MakeHTML("PRESS THE SEARCH BUTTON OR THE TOP LEFT SQUARE LCARS ELEMENT TO BEGIN")'Not( File.Exists(LCAR.DirDefaultExternal,  "HTML/index.html" ))
	Return filename
End Sub

Sub MakeHTML(Body As String) As String
	Dim Dir As String =LCAR.DirDefaultExternal
	File.MakeDir(Dir,"HTML")
	Dir= File.Combine(Dir, "HTML")
	FileLoaded=LCARSeffects.UniqueFilename(Dir,  "index.html", "#")
	FileLoaded = MakeHTML2(Body, Dir, FileLoaded)
	Return FileLoaded
End Sub
Sub MakeHTML2(Body As String, Dir As String, Filename As String)As String 
	Dim FontName As String, FontFile As String, textColor As String, bgcolor As String  ,HTMLcode As StringBuilder ,tempstr As String 
	'dir= File.DirInternalCache 
	FontFile = "lcars.ttf"
	FontName= "LCARS"
	textColor= MakeHTMLColor(LCAR.LCAR_Orange)' "#800080"'LCAR_Orange
	bgcolor = "#000000"
	
	tempstr= "{display: block; width: 100%; COLOR: #000000; text-decoration: none;}" & CRLF
	
	HTMLcode.Initialize 
	HTMLcode.Append( "<html><head><style Type='text/css'>" )
	HTMLcode.Append( CRLF & "@font-face { font-family: " & FontName & ";	src: url('file:///android_asset/" & FontFile & "')" & CRLF & "; }" )
	'htmlcode=htmlcode & CRLF & ".image{	border-style:outset; border-color: " & textColor & "; border-width:2px; }"
	HTMLcode.Append( CRLF & "a:link " & tempstr & "a:visited " & tempstr & "a:hover " & tempstr & "a:active " & tempstr)
	HTMLcode.Append( "body {" & CRLF & "	background-color : " & bgcolor & ";" & CRLF & "	COLOR: " & textColor & ";" &  CRLF & "	font-family: " & FontName & ";" & CRLF & "	font-size: " & LCAR.Fontsize & "px;" & CRLF & "	text-align: justify;}")
	HTMLcode.Append( CRLF & "</style></head><meta name=viewport content='width=1200'><meta http-equiv='Content-Type' content='text/html; charset=utf-8' /><body>")
	HTMLcode.Append(Body & "</BODY></HTML>" )
	
	File.WriteString(Dir, Filename, HTMLcode.ToString) 
	Return "file://" & File.Combine(Dir, Filename) 'dir & "/HTML/index.html" 
End Sub

Sub MakeTag(Dest As List, Level As Int, TagName As String, Node As String)As HTMLtag 
	Dim temp As HTMLtag 
	temp.Initialize
	temp.Level=Level
	temp.TagName=TagName
	temp.Node=Node
	Return temp
End Sub
Sub MakeValue(Key As String, Value As String) As HTMLvalue 
	Dim temp As HTMLvalue 
	temp.Initialize
	temp.Key=Key
	temp.Value = Value
	Return temp
End Sub

Sub MakeLCARbutton(ColorID As Int, HTMLCode As String ) As String
	Dim Color As String ,Extension As String 
	If LCAR.AntiAliasing Then Extension = ".png" Else Extension = ".gif"
	Color=MakeHTMLColor(ColorID)
	If HTMLCode.ToLowerCase.Contains("<img") Then
		Return HTMLCode.Replace("<img ", "<img border=2 ")
	Else
		Return "<TABLE WIDTH=100% HEIGHT=" & (LCAR.ItemHeight+4) & " BORDER=0 CELLSPACING=0 CELLPADDING=0><TR><TD HEIGHT=" & LCAR.ItemHeight & " WIDTH=" & LCAR.lcarcorner.Width & " BACKGROUND='file:///android_asset/" & LCAR.LoadedFilename & Extension & "' BGCOLOR=" & Color & "></TD><TD WIDTH=4 BGCOLOR=" & Color & "></TD><TD WIDTH=4 BGCOLOR=BLACK></TD><TD WIDTH=4 BGCOLOR=" & Color & "><TD BGCOLOR=" & Color & "> " & HTMLCode & "</TD></TR><TR><TD HEIGHT=4 COLSPAN=5 BGCOLOR=BLACK></TR></TABLE>"
	End If
End Sub

Sub ParseTag(Tag As String) As List 
	Dim templist As List
	templist.Initialize 
	
	Return templist
End Sub

Sub GetBetween(Text As String, Start As String, Finish As String) As String 
	Dim temp As Int,temp2 As Int
	temp=Text.IndexOf(Start)
	If temp>-1 Then
		temp2=Text.IndexOf2(Finish, temp+ Start.Length  +1)
		Return Mid(Text, temp+Start.Length,temp2-temp-Start.Length)
	End If
End Sub

Sub ParseHTML(HTMLCode As String, URL As String)As String 
	Dim temp As Int,temp2 As Int, htag As String  ,Name As String ,temp3 As String, Node As String ', BaseHREF
	Dim IO As TextWriter ,tempstr As String  ', tempstr As StringBuilder
	IO.Initialize( File.OpenOutput(File.DirInternalCache, "temp.html", False) )
	
	'tempstr="THIS IS A TEST OF THE LCARS WEB SYSTEM"
	Title=""
	BaseHref=""
	
	'tempstr.Initialize 
	
	temp=HTMLCode.IndexOf("[START]")
	If temp>-1 Then
		Title=GetBetween(HTMLCode, "<title>", " - Techni's Controller and Peripheral Museum</title>").ToUpperCase '"ABOUT LCARS UI" '<title>ABOUT LCARS UI -
		temp2=HTMLCode.IndexOf2("[END]", temp)
		HTMLCode=Mid(HTMLCode, temp+7,temp2-temp-7).ToUpperCase'
	End If
	temp=0
	
	Do Until temp >= HTMLCode.Length OR temp<0 'OR tempstr.Length > MaxStringBuilderLength
		tempstr=""
		'debug(temp & "/" & HTMLCode.Length)
		If Mid(HTMLCode, temp,1) = "<" Then
			temp2=HTMLCode.IndexOf2(">", temp+1)
			htag=Mid(HTMLCode, temp,temp2-temp+1)
			temp=temp2+1
			
			'debug("HTML: " & htag)
			'debug("TAG: " & GetTagName(htag))
			
			Name=GetTagName(htag)
			Select Case Name.ToLowerCase 
				Case "a", "script", "title", "h1", "h2", "h3", "header","footer","style"
					'If Not( name.EqualsIgnoreCase("a") AND htag.Contains(" name=") ) Then
						temp3 = HTMLCode.IndexOf2("</" & Name, temp2)
						Node=Mid(HTMLCode, temp2+1,temp3-temp2-1).Replace("&quot;", "'").Trim 
						temp2=HTMLCode.IndexOf2(">", temp3+1)
						temp=temp2+1
						'debug("NODE2:" & Node)
					'End If
			End Select
			
			Select Case Name.ToLowerCase.Replace("/", "")
				Case "base": BaseHref=htag
				Case "title": 	Title= Node
				Case "img"
					'removed broken images
					tempstr = CRLF & htag 
				Case "h1", "h2", "h3", "h4"
					'tempstr= tempstr & htag & node & "</" & name & ">"
					tempstr = CRLF & htag & Node & "</" & Name & ">"
				Case "a"':		tempstr= tempstr & MakeLCARbutton(lcar.LCAR_Orange, node)
					If htag.Contains("#") Then'basehref
						
					End If
					If Node.Length>0 Then
						If Not (Node.ToLowerCase.Contains("img")) Then Node=Node.ToUpperCase 
						Node=MakeLCARbutton(LCAR.LCAR_Orange, htag & Node & "</A>")
					End If
					Node=Node.Replace(" href=" & Chr(34) & "#", " href=" & Chr(34) & ScrollTo(0) & "#")
					'tempstr= tempstr & node
					tempstr = CRLF & Node
				Case "meta", "link", "!--", "script", "style", "body", "div", "span", "nav" , "input", "form", "ul", "li", "header","section","footer"  'ignore these tags
				Case Else
					'tempstr = tempstr & htag 
					tempstr = CRLF & htag
			End Select
			
		Else
			temp2=HTMLCode.IndexOf2("<", temp+1)
			If temp2>-1 Then
				htag=Mid(HTMLCode, temp,temp2-temp).Trim
			Else
				temp2=HTMLCode.Length 
				htag=Right(HTMLCode, temp2-temp).Trim 
			End If
			temp=temp2
			Select Case htag
				Case CRLF, "" 
				Case Else 
					'debug("NODE: " & htag)
					If CountAlphaNumericCharacters(htag) >0 Then 'tempstr=tempstr & CRLF & htag.Replace("•", "-")
						If Main.AprilFools Then
							tempstr = CRLF & ReorganizeText(htag.Replace("•", "-"))
						Else
							tempstr = CRLF & htag.Replace("•", "-")
						End If
					End If
			End Select
		End If
		
		If tempstr.Length>0 Then IO.Write(tempstr)
	Loop
	IO.Close 
	
	If BaseHref.Length=0 AND URL.Length>0 Then
		BaseHref=Left(URL, URL.LastIndexOf("/")+1)
		Node="<BASE HREF='" & BaseHref & "'>"
	End If
	
	Return Node & File.ReadString(File.DirInternalCache, "temp.html" )' tempstr.ToString 
	'htmlcode.IndexOf2(
End Sub

Sub GetTag(HTML As String, Tag As String) As String 
	Return GetBetween(HTML, " " &  Tag  & "=" & vbQuote, vbQuote)
End Sub
Sub EnumAHREFs(HTMLCode As String)As List 
	Dim temp As Int,temp2 As Int, htag As String  ,Name As String ,temp3 As String, Node As String
	Dim tempstr As String ,HREFS As List  ', tempstr As StringBuilder
	HREFS.Initialize 
	Do Until temp >= HTMLCode.Length OR temp<0 'OR tempstr.Length > MaxStringBuilderLength
		tempstr=""
		'debug(temp & "/" & HTMLCode.Length)
		If Mid(HTMLCode, temp,1) = "<" Then
			temp2=HTMLCode.IndexOf2(">", temp+1)
			htag=Mid(HTMLCode, temp,temp2-temp+1)
			temp=temp2+1
			Name=GetTagName(htag)
			Select Case Name.ToLowerCase 
				Case "a"', "script", "title", "h1", "h2", "h3", "header","footer","style"
					'If Not( name.EqualsIgnoreCase("a") AND htag.Contains(" name=") ) Then
						temp3 = HTMLCode.IndexOf2("</" & Name, temp2)
						Node=Mid(HTMLCode, temp2+1,temp3-temp2-1).Replace("&quot;", "'").Trim 
						temp2=HTMLCode.IndexOf2(">", temp3+1)
						temp=temp2+1
						'debug("NODE2:" & Node)
					'End If
			End Select
			
			Select Case Name.ToLowerCase.Replace("/", "")
				Case "a"':		tempstr= tempstr & MakeLCARbutton(lcar.LCAR_Orange, node)
					'debug("HTML: " & htag)
					'debug("TAG: " & GetTagName(htag))
					HREFS.Add( htag )
			End Select
			
		Else
			temp2=HTMLCode.IndexOf2("<", temp+1)
			If temp2>-1 Then
				htag=Mid(HTMLCode, temp,temp2-temp).Trim
			Else
				temp2=HTMLCode.Length 
				htag=Right(HTMLCode, temp2-temp).Trim 
			End If
			temp=temp2
		End If
	Loop

	Return HREFS
	'htmlcode.IndexOf2(
End Sub


Sub ReorganizeText(Text As String) As String 
	Dim tempstr() As String , tempstr2 As StringBuilder , temp As Int 
	tempstr = Regex.Split(" ", Text)
	tempstr2.Initialize 
	For temp = 0 To tempstr.Length -1
		tempstr2.Append( ReorganizeWord( tempstr(temp).ToUpperCase )  & " ")
	Next
	Return tempstr2.ToString 
End Sub
Sub ReorganizeWord(Text As String) As String 
	Dim temp As Int , tempstr As String , Word As List ,temp2 As Int , LastChars As String , Length As Int 
	If Text.Length>4 AND Not(IsNumber(Text)) Then
		LastChars= Right(Text,1) 
		Length=1
		Do While Asc(Left(LastChars,1)) < ascA AND  Asc(Left(LastChars,1)) > ascZ
			Length=Length+1
			LastChars= Right(Text,Length)
		Loop
		Text=Left(Text, Text.Length-Length)
		
		'Msgbox(Text, LastChars)
		Word.Initialize 
		For temp = 1 To Text.Length- 1
			'debug("Adding: " & Mid(Text, temp,1))
			Word.Add( Mid(Text, temp,1) )
		Next
		
		
		tempstr= Left(Text,1)
		For temp = 1 To Text.Length- 1
			temp2 = Rnd(0, Word.Size)
			tempstr = tempstr & Word.Get(temp2)
			Word.RemoveAt(temp2)
		Next
		Return tempstr & LastChars'Right(Text, 1)
	Else
		Return Text
	End If
End Sub 

Sub GetTagName(content As String) As String
    Dim temp As Long, temp2 As Long
    temp = Instr(content, " ",0)
    temp2 = Instr(content, ">",0)
    If temp > 0 AND temp < temp2 Then temp2 = temp
    Return Mid(content, 1, temp2 - 1)
End Sub

Sub CountAlphaNumericCharacters(Text As String)As Int
	Dim temp As Int, Count As Int,Character As Int 
	For temp = 0 To Text.Length-1
		Character=Asc(Mid(Text,temp,1).ToLowerCase )
		If ( Character >= Asc("a") AND Character <= Asc("z") ) OR ( Character >= Asc("0") AND Character <= Asc("9")) Then Count=Count+1
	Next
	Return Count
End Sub



'returns -1 if not found
Sub Instr(Text As String, TextToFind As String, Start As Int) As Int
	Return Text.IndexOf2(TextToFind,Start)
End Sub
Sub InstrRev(Text As String, TextToFind As String) As Int
	Return Text.LastIndexOf(TextToFind)
End Sub
Sub Instr2(Text As String, Start As Int, TextsToFind As List) As Int 
	Dim temp As Int, temp2 As Int, temp3 As Int
	temp2=Text.Length 
	For temp = 0 To TextsToFind.Size -1
		temp3 = Instr(Text, TextsToFind.Get(temp), Start)
		If temp3<temp2 AND temp3>-1 Then temp2=temp3
	Next
	Return temp2
End Sub

Sub isWIFI_enabled As Boolean 
	Dim P As Phone 
	Return  P.GetSettings ("wifi_on") = 1
End Sub
Sub IsConnected As Boolean 
	Dim P As Phone,server As ServerSocket'Add a reference to the network library  'Check status: DISCONNECTED 0
	Try
	    server.Initialize(0, "")
		'debug("mobile data state: " & P.GetDataState & " wifi_on: " & P.GetSettings("wifi_on") & " server ip: " & server.GetMyIP & CRLF &  "wifi ip: " & server.GetMyWifiIP)
	    If server.GetMyIP = "127.0.0.1" Then Return False  'this is the local host address
		If Not(P.GetDataState.EqualsIgnoreCase("CONNECTED")) AND server.GetMyWifiIP = "127.0.0.1" Then Return False
	    Return True
	Catch
		Return False
	End Try
End Sub
Sub IsConnectedOld As Boolean 
	Dim server As ServerSocket 'Add a reference to the network library
	Try
	    server.Initialize(0, "")
	    If server.GetMyIP = "127.0.0.1" Then Return False  'this is the local host address
	    Return True
	Catch
		Return False
	End Try
End Sub
Sub StrReverse(Text As String) As String 
	Dim tempstr As StringBuilder,temp As Int
	tempstr.Initialize 
	For temp = Text.Length-1 To 0 Step -1
		tempstr.Append( Text.CharAt(temp) )
	Next
	Return tempstr.ToString 
End Sub
Sub Left(Text As String, Length As Long)As String 
	If Text.Length>0 AND Length>0 Then
		'If Length>Text.Length Then Length=Text.Length 
		Return Text.SubString2(0, Min(Text.Length,Length))
	End If
	Return ""
End Sub

Sub Right(Text As String, Length As Long) As String
	If Text.Length>0 AND Length>0 Then
		'If Length>Text.Length Then Length=Text.Length 
		Return Text.SubString(Text.Length-Min(Text.Length,Length))
	End If
	Return ""
End Sub
Sub Mid(Text As String, Start As Int, Length As Int) As String 
	If Length>0 AND Start>-1 AND Start< Text.Length Then Return Text.SubString2(Start,Start+Length)
End Sub

Sub IsTimerRunning(ID As Int) As Int
	Dim temp As Int, tTimer As LCARtimer 
	For temp = STimer.TimerList.Size-1 To 0 Step -1
		tTimer=STimer.TimerList.Get(temp)
		If tTimer.ID =ID Then  Return tTimer.Duration 
	Next
	Return -2
End Sub
Sub FindTimer(ID As Int) As Int
	Dim temp As Int, tTimer As LCARtimer 
	For temp = STimer.TimerList.Size-1 To 0 Step -1
		tTimer=STimer.TimerList.Get(temp)
		If tTimer.ID =ID Then  Return temp
	Next
	Return -1
End Sub

Sub NewTimer(Name As String,ID As Int, Duration As Int )As Int 
	Dim temp As LCARtimer ,temp2 As Int 
	temp2=IsTimerRunning(ID)
	If temp2 = -2 Then
		temp.Initialize 
		temp.Name = Name
		temp.ID = ID
		temp.Duration =Duration
		STimer.timerlist.Add(temp)
		temp2=STimer.timerlist.Size-1
	Else 
		temp2=FindTimer(ID)
		If temp2>-1 Then
			temp = STimer.TimerList.Get(temp2)
			temp.Duration =Duration
		End If
	End If
	StartService(STimer)
	Return temp2
End Sub

Sub StopTimer(ID As Int, Reason As String ) As Boolean 
	Dim temp As Int, tTimer As LCARtimer 
	For temp = STimer.TimerList.Size-1 To 0 Step -1
		tTimer=STimer.TimerList.Get(temp)
		If tTimer.ID =ID Then 
			STimer.TimerList.RemoveAt(temp)
			Log("Stopped timer " & ID & " Reason: " & Reason)
			Return True
		End If
	Next
	'Log("Timer " & ID  & " not found!")
End Sub

Sub GetTimer(Name As String ) As String 
	Dim temp As Int, temp2 As LCARtimer 
	For temp = 0 To STimer.TimerList.Size-1
		temp2= STimer.TimerList.Get(temp)
		If temp2.Name.EqualsIgnoreCase(Name) AND temp2.Duration >-1 Then 
			Return GetTime( temp2.Duration)
		End If
	Next
End Sub

Sub GetTime(Seconds As Int) As String 
	Dim Hour As Int, Minute As Int :Hour=3600: Minute=60
	Dim Hours As Int, Minutes As Int , Time As String 
	
	Hours = Floor(Seconds / Hour)
	Seconds = Seconds - (Hours*Hour)
	If Hours>0 Then Time = Hours & ":"
	
	Minutes = Floor(Seconds / Minute)
	Seconds = Seconds - (Minutes*Minute)
	Time=Time & ForceLength(Minutes, 2, "0",False) & ":" & ForceLength(Seconds, 2, "0",False)
	Return Time
End Sub

Sub Containsword(Text() As String , TextToFind As String) As Boolean 
	Dim temp As Int, tempstr() As String ,temp2 As Int , Found As Boolean ,Start As Int
	tempstr = Regex.Split(" ", TextToFind.ToLowerCase)
	For temp2 = 0 To tempstr.Length-1
		Found=False
		For temp = Start To Text.Length -1
			If Text(temp) = tempstr(temp2) Then 
				Found = True
				Start=temp+1
				temp=Text.Length 
			End If
		Next
		If Not(Found) Then Return False
	Next	
	Return True
End Sub

Sub IsTime(Text As String) As Boolean 
	'00:00 00:00:00
	Dim ret As Boolean 
	If Text.Length = 5 OR Text.Length=8 Then
		If IsNumber(Left(Text,2)) AND IsNumber(Right(Text,2)) AND Mid(Text, 2, 1) = ":" Then
			If Text.Length = 8 Then
				ret = IsNumber(Mid(Text,3,2)) AND Mid(Text,5,1) = ":" 
			Else
				ret=True 
			End If
		End If
	End If
	Return ret
End Sub
Sub ParseTime(Time As String) As Int 
	Dim Multiplier As Int , Value As Int , Total As Int 
	Do Until Time.Length = 0 
		Value = Right(Time,2)
		Time = Left(Time , Time.Length - 2)
		If Time.Length>0 Then
			If Right(Time, 1) = ":" Then 
				Time = Left(Time , Time.Length - 1)
			End If
		End If
		Total = Total + Value * IIFIndex(Multiplier, Array As Int(1, 60, 3600))
		Multiplier=Multiplier+1
	Loop
	Return Total
End Sub

Sub ForceLength(Text As String, Length As Int, Character As String, AtEnd As Boolean  )As String 
	Dim temp As Int 
	For temp = Text.Length +1 To Length
	'Do Until text.Length=>length
		If AtEnd Then Text=Text & Character Else Text = Character & Text
	'Loop
	Next
	Return Text
End Sub




Sub MakeKB(Text As String, SelStart As Int, SelLength As Int, Shift As Boolean, CapsLock As Boolean ) As APIKeyboard 
	Dim temp As APIKeyboard 
	temp.Initialize 
	temp.Text=Text
	temp.SelLength =SelLength
	temp.SelStart=SelStart
	temp.Shift = Shift
	temp.CapsLock=CapsLock
	Return temp
End Sub

Sub HandleDirection(KB As APIKeyboard, Direction As Int) As APIKeyboard
	If KB.Shift Then
		KB.SelLength=KB.SelLength+Direction
		If KB.SelLength<0 Then
			If KB.SelStart + KB.SelLength <0 Then KB.SelLength =-KB.SelStart 
		Else If KB.SelLength>0 Then
			If KB.SelStart + KB.SelLength > =KB.Text.Length Then KB.SelLength = KB.Text.Length - KB.SelStart 
		End If
	Else
		KB.SelLength=0
		KB.SelStart = KB.SelStart + Direction
		If KB.SelStart<0 Then KB.SelStart=0
		If KB.SelStart>=KB.Text.Length Then KB.SelStart=KB.Text.Length
	End If
	
	Return KB
End Sub

Sub SelectAll(ElementID As Int) 
	Dim element As LCARelement 
	element=LCAR.LCARelements.Get(ElementID)
	element.LWidth=0
	element.RWidth = element.Text.Length 
	LCAR.LCARelements.Set(ElementID,element)
End Sub

Sub HandleKeyboard(KB As APIKeyboard,KeyCode As Int  ) As APIKeyboard 
	'Msgbox(KeyCode, KeyCodes.KEYCODE_DPAD_LEFT)
	Dim Temp As Boolean ,tempstr As String 
	Select Case KeyCode
		Case -98,-99 'copy, cut
			If KB.SelLength=0 Then
				Log("Copy: " & KB.Text)
				Clipboard(0, KB.Text)
				If KeyCode=-99 Then KB=MakeKB("", 0,0, KB.Shift,LCAR.KBCaps)
			Else
				Log("Copy: " & GetSelText(KB))
				Clipboard(0, GetSelText(KB))
				If KeyCode=-99 Then KB=SetSelText(KB, "", False)
			End If
	
		Case KeyCodes.KEYCODE_SHIFT_LEFT, KeyCodes.KEYCODE_SHIFT_RIGHT: KB.Shift=Not(KB.Shift)
		Case KeyCodes.KEYCODE_DPAD_LEFT:  KB= HandleDirection(KB, -1)
		Case KeyCodes.KEYCODE_DPAD_RIGHT: KB= HandleDirection(KB, 1)
		Case KeyCodes.KEYCODE_SPACE: KB=SetSelText(KB, " ",False)
		Case KeyCodes.KEYCODE_DEL,KeyCodes.KEYCODE_UNKNOWN
			'temp = (KB.SelLength=0)
			KB=SetSelText(KB, KeyCode,True) 'backspace,Delete
			'If temp Then KB= HandleDirection(KB, -1)
		Case -9'clear
			KB = MakeKB("",0,0,False, True)
		Case Else'  "*",  "(",   ")"
			Temp= (KeyCode>28 AND KeyCode< 55) 'A-Z
			'If temp=False Then temp = (KeyCode>= Asc("a") AND KeyCode<= Asc("z"))'a-z
			If Temp = False Then Temp = (KeyCode >6 AND KeyCode <17)'1-0
			If Temp = False Then Temp = KeyCode<0 '!,$,%,&,|
			If Temp=False Then'symbols
				Select Case KeyCode
					Case KeyCodes.KEYCODE_PERIOD, KeyCodes.KEYCODE_AT ,KeyCodes.KEYCODE_BACKSLASH, KeyCodes.KEYCODE_MINUS, KeyCodes.KEYCODE_POUND:		Temp=True
					Case KeyCodes.KEYCODE_EQUALS, KeyCodes.KEYCODE_COMMA, KeyCodes.KEYCODE_POWER , KeyCodes.KEYCODE_APOSTROPHE , KeyCodes.KEYCODE_STAR:	Temp=True
					Case KeyCodes.KEYCODE_LEFT_BRACKET , KeyCodes.KEYCODE_RIGHT_BRACKET , KeyCodes.KEYCODE_PLUS, KeyCodes.KEYCODE_SLASH :				Temp=True	
					Case KeyCodes.KEYCODE_SEMICOLON: Temp=True
				End Select
			End If
			If Temp Then 'A to Z OR 0 to 9
				tempstr = GetChar( GetKeyCode(KeyCode, True,KB.shift),KB.shift)
				If KB.CapsLock Then tempstr = tempstr.ToUpperCase Else tempstr = tempstr.ToLowerCase  
				KB=SetSelText(KB, tempstr , False)
				KB.Shift=False
			'Else
				'debug("CODE: " & KeyCode & ", CHAR: " & GetKeyCode(KeyCode,True,KB.shift))
			End If
	End Select
	Return KB
End Sub


Sub GetChar(Text As String, Shift As Boolean ) As String 
	If Shift Then 
		Return Text.ToUpperCase 
	Else
		Return Text.ToLowerCase 
	End If
End Sub

Sub GetSelText(KB As APIKeyboard) As String
    If Abs(KB.SelLength) = KB.Text.Length  Then
        Return KB.Text
    Else
        If KB.SelLength > 0 Then
            Return Mid(KB.Text, KB.SelStart, KB.SelLength)
        Else If KB.SelLength < 0 Then
            Return Mid(KB.Text, KB.SelStart + KB.SelLength, Abs(KB.SelLength))
        End If
    End If
End Sub
Sub SetSelText(KB As APIKeyboard, Key As String, KeyCode As Boolean ) As APIKeyboard 
    Dim LSide As Long, RSide As Long, L As String, R As String
    If KB.SelLength > 0 Then
        LSide = KB.SelStart
        RSide = KB.Text.Length - KB.SelStart - KB.SelLength
        KB.SelStart = KB.SelStart + Key.Length 
    Else If KB.SelLength < 0 Then
        LSide = KB.SelStart + KB.SelLength
        RSide = KB.Text.Length - KB.SelStart
        KB.SelStart = LSide + Key.Length
    Else'if kb.sellength=0 then
        LSide = KB.SelStart
        RSide = KB.Text.Length - KB.SelStart
        KB.SelStart = KB.SelStart + Key.Length
    End If
    If LSide > 0 Then L = Left(KB.Text, LSide)
    If RSide > 0 Then R = Right(KB.Text, RSide)
	
	If KeyCode Then
		Select Case Key
			Case KeyCodes.KEYCODE_DEL'backspace
				If KB.SelLength = 0 AND L.Length>0 Then
					L= Left(L, L.Length-1)
					KB.SelStart=KB.SelStart-3
				Else
					KB.SelStart=LSide
				End If
				KB.Text = L & R
			Case KeyCodes.KEYCODE_UNKNOWN'delete
				If KB.SelLength = 0 AND R.Length>0 Then
					R=Right(R,R.Length-1)
					KB.SelStart=KB.SelStart-1
				Else
					KB.SelStart=LSide
				End If
				KB.Text = L & R
		End Select
		
	Else
		KB.Text = L & Key & R
	End If
	
    KB.SelLength = 0
	Return KB
End Sub

Sub GetKeyCode(Letter As String, GetCharacter As Boolean,Shift As Boolean  ) As String
	Dim ret As String 
	
	ret= ConvertKeyCode(ret, Letter, "0", KeyCodes.KEYCODE_0, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "1", KeyCodes.KEYCODE_1, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "2", KeyCodes.KEYCODE_2, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "3", KeyCodes.KEYCODE_3, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "4", KeyCodes.KEYCODE_4, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "5", KeyCodes.KEYCODE_5, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "6", KeyCodes.KEYCODE_6, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "7", KeyCodes.KEYCODE_7, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "8", KeyCodes.KEYCODE_8, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "9", KeyCodes.KEYCODE_9, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "\", KeyCodes.KEYCODE_SLASH, GetCharacter)

	ret= ConvertKeyCode(ret, Letter, "!", -1, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "$", -2, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "%", -3, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "&", -4, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "|", -5, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "?", -6, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "<", -7, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, ">", -8, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "CLR", -9, GetCharacter)

	ret= ConvertKeyCode(ret, Letter, "{", -10, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "}", -11, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "•", -12, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "Ω", -13, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "π", -14, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "_", -15, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, ":", -16, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "[", -17, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "]", -18, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "~", -19, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "`", -20, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, """", -21, GetCharacter)
	
	ret= ConvertKeyCode(ret, Letter, "CAPS", -96, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "INS", -97, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "COPY", -98, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "CUT", -99, GetCharacter)

	ret= ConvertKeyCode(ret, Letter, "A", KeyCodes.KEYCODE_A, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "ALT", KeyCodes.KEYCODE_ALT_LEFT, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "ALTR", KeyCodes.KEYCODE_ALT_RIGHT, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "'", KeyCodes.KEYCODE_APOSTROPHE, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "@", KeyCodes.KEYCODE_AT, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "B", KeyCodes.KEYCODE_B, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "BACK", KeyCodes.KEYCODE_BACK, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "/", KeyCodes.KEYCODE_BACKSLASH, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "C", KeyCodes.KEYCODE_C, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "CALL", KeyCodes.KEYCODE_CALL, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "CAMERA", KeyCodes.KEYCODE_CAMERA, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "CLEAR", KeyCodes.KEYCODE_CLEAR, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, ",", KeyCodes.KEYCODE_COMMA, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "D", KeyCodes.KEYCODE_D, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "BKSP", KeyCodes.KEYCODE_DEL, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "CENTER", KeyCodes.KEYCODE_DPAD_CENTER, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "DOWN", KeyCodes.KEYCODE_DPAD_DOWN, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "<ı", KeyCodes.KEYCODE_DPAD_LEFT, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "ı>", KeyCodes.KEYCODE_DPAD_RIGHT, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "UP", KeyCodes.KEYCODE_DPAD_UP, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "E", KeyCodes.KEYCODE_E, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "ENDCALL", KeyCodes.KEYCODE_ENDCALL, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "ENTER", KeyCodes.KEYCODE_ENTER, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "ENVELOPE", KeyCodes.KEYCODE_ENVELOPE, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "=", KeyCodes.KEYCODE_EQUALS, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "EXPLORER", KeyCodes.KEYCODE_EXPLORER, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "F", KeyCodes.KEYCODE_F, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "FOCUS", KeyCodes.KEYCODE_FOCUS, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "G", KeyCodes.KEYCODE_G, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "GRAVE", KeyCodes.KEYCODE_GRAVE, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "H", KeyCodes.KEYCODE_H, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "HEADSET", KeyCodes.KEYCODE_HEADSETHOOK, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "HOME", KeyCodes.KEYCODE_HOME, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "I", KeyCodes.KEYCODE_I, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "J", KeyCodes.KEYCODE_J, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "K", KeyCodes.KEYCODE_K, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "L", KeyCodes.KEYCODE_L, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "(", KeyCodes.KEYCODE_LEFT_BRACKET, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "M", KeyCodes.KEYCODE_M, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "FORWARD", KeyCodes.KEYCODE_MEDIA_FAST_FORWARD, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "NEXT", KeyCodes.KEYCODE_MEDIA_NEXT, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "PLAY", KeyCodes.KEYCODE_MEDIA_PLAY_PAUSE, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "PREVIOUS", KeyCodes.KEYCODE_MEDIA_PREVIOUS, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "REWIND", KeyCodes.KEYCODE_MEDIA_REWIND, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "STOP", KeyCodes.KEYCODE_MEDIA_STOP, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "MENU", KeyCodes.KEYCODE_MENU, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "-", KeyCodes.KEYCODE_MINUS, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "MUTE", KeyCodes.KEYCODE_MUTE, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "N", KeyCodes.KEYCODE_N, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "NOTIFICATION", KeyCodes.KEYCODE_NOTIFICATION, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "NUM", KeyCodes.KEYCODE_NUM, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "O", KeyCodes.KEYCODE_O, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "P", KeyCodes.KEYCODE_P, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, ".", KeyCodes.KEYCODE_PERIOD, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "+", KeyCodes.KEYCODE_PLUS, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "#", KeyCodes.KEYCODE_POUND, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "^", KeyCodes.KEYCODE_POWER, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "Q", KeyCodes.KEYCODE_Q, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "R", KeyCodes.KEYCODE_R, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, ")", KeyCodes.KEYCODE_RIGHT_BRACKET, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "S", KeyCodes.KEYCODE_S, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "SEARCH", KeyCodes.KEYCODE_SEARCH, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, ";", KeyCodes.KEYCODE_SEMICOLON, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "SHIFT", KeyCodes.KEYCODE_SHIFT_LEFT, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "SHIFTR", KeyCodes.KEYCODE_SHIFT_RIGHT, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "SOFT", KeyCodes.KEYCODE_SOFT_LEFT, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "SOFTR", KeyCodes.KEYCODE_SOFT_RIGHT, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "SPACE", KeyCodes.KEYCODE_SPACE, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "*", KeyCodes.KEYCODE_STAR, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "SYM", KeyCodes.KEYCODE_SYM, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "T", KeyCodes.KEYCODE_T, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "	", KeyCodes.KEYCODE_TAB, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "U", KeyCodes.KEYCODE_U, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "DEL", KeyCodes.KEYCODE_UNKNOWN, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "V", KeyCodes.KEYCODE_V, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "VOLDOWN", KeyCodes.KEYCODE_VOLUME_DOWN, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "VOLUP", KeyCodes.KEYCODE_VOLUME_UP, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "W", KeyCodes.KEYCODE_W, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "X", KeyCodes.KEYCODE_X, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "Y", KeyCodes.KEYCODE_Y, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "Z", KeyCodes.KEYCODE_Z, GetCharacter)
	
	ret= ConvertKeyCode(ret, Letter, "A BTN", BUTTON_A, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "B BTN", BUTTON_B, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "C BTN", BUTTON_C, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "X BTN", BUTTON_X, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "Y BTN", BUTTON_Y, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "Z BTN", BUTTON_Z, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "L1", BUTTON_L1, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "L2", BUTTON_L2, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "L3", BUTTON_L3, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "R1", BUTTON_R1, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "R2", BUTTON_R2, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "R3", BUTTON_R3, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "START", BUTTON_START, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "SELECT", BUTTON_SELECT, GetCharacter)
	ret= ConvertKeyCode(ret, Letter, "MODE", BUTTON_MODE, GetCharacter)
	
	If ret.Length =0 Then
		If Letter = "PST" Then'ret= ConvertKeyCode(ret, Letter, "PST", -12, GetCharacter)
			If GetCharacter Then 
				ret = Clipboard(1,"")
			Else
				ret=-100
			End If
		Else If Not(GetCharacter) Then 
			ret = -999
		End If
	End If
	Return ret
End Sub
Sub ConvertKeyCode(ret As String, Check As String, Letter As String, KeyCode As Int, GetCharacter As Boolean) As String 
	If ret.Length=0 Then
		If GetCharacter Then
			If Check = KeyCode Then Return Letter
		Else
			If Check.EqualsIgnoreCase(Letter) Then Return KeyCode
		End If
	End If
	Return ret
End Sub


Sub InputMethodSelector
	Dim Obj1 As Reflector
	Obj1.Target = Obj1.GetContext
	Obj1.Target = Obj1.RunMethod2("getSystemService", "input_method", "java.lang.String")
	Obj1.RunMethod("showInputMethodPicker")
End Sub
Sub APIlevel As Int 
	Dim r As Reflector
	Return r.GetStaticField("android.os.Build$VERSION", "SDK_INT")
End Sub
Sub LWPselector As Boolean 
	Dim Intent1 As Intent
	Try
		Intent1.Initialize(Intent1.ACTION_MAIN, "")
		If APIlevel<15 Then
			Intent1.SetComponent("com.android.wallpaper.livepicker/.LiveWallpaperListActivity")
		Else
			Intent1.SetComponent("com.android.wallpaper.livepicker/.LiveWallpaperActivity")'this will work for android 4.0.4
		End If
		StartActivity(Intent1)
		Return True
	Catch
		Return False
	End Try
End Sub


Sub Thumbsize(PicWidth As Int, PicHeight As Int, thumbwidth As Int, thumbheight As Int, ForceFit As Boolean, ForceFull As Boolean)As Point 
	Dim temp As Point 
	temp.X=PicWidth
	temp.Y=PicHeight

    If ForceFit Then
        If temp.Y < thumbheight Then
            temp.X = temp.X * thumbheight / temp.Y
            temp.Y = thumbheight
        End If
    End If
    If temp.X > thumbwidth Then
        temp.Y = temp.Y / (temp.X / thumbwidth)
        temp.X = thumbwidth
    End If
    If temp.Y > thumbheight Then
        temp.X = temp.X / (temp.Y / thumbheight)
        temp.Y = temp.Y / (temp.Y / thumbheight)
    End If
    If ForceFull Then
        If temp.X < thumbwidth Then
            temp.Y = temp.Y * (thumbwidth / temp.X)
            temp.X = thumbwidth
        End If
        If temp.Y < thumbheight Then
            temp.X = temp.X * (thumbheight / temp.Y)
            temp.Y = temp.Y * (thumbheight / temp.Y)
        End If
    End If
	Return temp
End Sub





Sub TextWrap(BG As Canvas, Font As Typeface, TextSize As Int, Text As String, MaxWidth As Int ) As String
	Dim tempstr() As String,temp As Int , WidthofWord As Int ,WidthofLine As Int , tempstr2 As StringBuilder ,WidthofSpace As Int 
	If TextWidthAtHeight(BG,Font,Text,TextSize) <= MaxWidth Then
		Return Text
	Else
		If Text.Contains(CRLF) Then
			tempstr = Regex.Split(CRLF, Text.Trim)
			tempstr2.Initialize
			For temp = 0 To tempstr.Length-1
				If tempstr(temp).Trim.Length>0 Then
					tempstr2.Append( TextWrap(BG, Font, TextSize, tempstr(temp), MaxWidth))
					If temp < tempstr.Length-1 Then tempstr2.Append(CRLF)
				End If
			Next
		Else
			tempstr = Regex.Split(" ", Text)'(\b[^\s]+\b)
			tempstr2.Initialize
			WidthofSpace=TextWidthAtHeight(BG,Font, " ", TextSize)
			For temp = 0 To tempstr.Length-1
				WidthofWord=TextWidthAtHeight(BG,Font, tempstr(temp), TextSize)
				If WidthofLine + WidthofWord > MaxWidth Then 
					tempstr2.Append (" " & CRLF)
					If WidthofWord>WidthofLine Then
						tempstr2.Append(SplitWord(BG,Font, TextSize, tempstr(temp),MaxWidth) & " " & CRLF)
						WidthofLine=0
					Else
						tempstr2.Append(tempstr(temp) & " ")
						WidthofLine=WidthofWord + WidthofSpace
					End If
				Else
					tempstr2.Append(tempstr(temp) & " ")
					WidthofLine=WidthofLine+WidthofWord + WidthofSpace
				End If
			Next
		End If
		Return tempstr2.ToString.Replace(CRLF & CRLF, CRLF)
	End If
End Sub
Sub SplitWord(BG As Canvas, Font As Typeface, TextSize As Int, Text As String, MaxWidth As Int ) As String
	Dim temp As Int, tempstr As StringBuilder , WidthofLine As Int ,WidthofChar As Int ,tempstr2 As String ,WidthofDash As Int
	tempstr.Initialize 
	WidthofDash=TextWidthAtHeight(BG,Font,"-",TextSize)
	WidthofLine=WidthofDash
	For temp = 0 To Text.Length-1
		tempstr2=Mid(Text,temp,1)
		WidthofChar = TextWidthAtHeight(BG,Font,tempstr2,TextSize)
		If WidthofLine+WidthofChar>MaxWidth Then 
			tempstr.Append("- " & CRLF & tempstr2 )
			WidthofLine=WidthofDash
		Else
			tempstr.Append(tempstr2)
		End If
		WidthofLine=WidthofLine+WidthofChar
	Next
	Return tempstr.ToString 
End Sub

Sub TextHeightAtHeight(BG As Canvas, Font As Typeface, Text As String, theFontSize As Int)As Int 
	Dim tempstr() As String ,Height As Int,temp As Int, CRLFspace As Int 
	CRLFspace=15
	If Text<>Null Then
		If Text.Contains(CRLF) Then
			tempstr = Regex.Split(CRLF,Text)
			For temp = 0 To tempstr.Length -1
				Height=Height+BG.MeasureStringHeight(tempstr(temp),Font,theFontSize)+CRLFspace
			Next
			Return Height-CRLFspace
		Else
			Return BG.MeasureStringHeight(Text,Font,theFontSize)
		End If
	End If
End Sub
Sub TextWidthAtHeight(BG As Canvas,Font As Typeface, Text As String, Height As Int) As Int
	Dim tempstr() As String ,Width As Int,temp As Int ,temp2 As Int
	If Text<>Null Then
		If Text.Contains(CRLF) Then
			tempstr = Regex.Split(CRLF,Text)
			For temp = 0 To tempstr.Length -1
				temp2=BG.MeasureStringWidth(tempstr(temp),Font,Height)
				If temp2>Width Then Width=temp2
			Next
			Return Width
		Else
			Return BG.MeasureStringWidth(Text,Font,Height)
		End If
	End If
End Sub

Sub CountInstances(Text As String, Substring As String) As Int
	Return Regex.Split(Substring, Text).Length 
End Sub

Sub KillAllExceptNumbers(Text As String) As Int
	Dim tempstr As String, temp As Int , Letter As String 
	For temp = 0 To Text.Length-1 
		Letter= Mid(Text, temp,1)
		Select Case Letter
			Case "0","1","2","3","4","5","6","7","8","9"
				tempstr=tempstr & Letter
		End Select
	Next
	If IsNumber(tempstr) Then
		Return tempstr
	Else
		Return 0
	End If
End Sub

Sub GetRotation As Int
	Dim r As Reflector
	r.Target = r.GetActivity
	r.Target = r.RunMethod("getWindowManager")
	r.Target = r.RunMethod("getDefaultDisplay")
	Return r.RunMethod("getRotation")
End Sub


'Wav header =9*4+4*2 = 80 bytes
Sub ReadAllBytes(folder As String , filename As String ) As Byte()
    Try 
        Dim In As InputStream
        In = File.OpenInput(folder,filename)
        Dim out As OutputStream
        out.InitializeToBytesArray(1)
        File.Copy2(In, out)

        Dim data() As Byte
        data = out.ToBytesArray
        
        out.Close
        In.Close 
        out.Flush
        
        Return data 
    Catch 
        Return Null 
    End Try 
End Sub

'Sub MediaButton
'	Long eventtime = SystemClock.uptimeMillis();
'
'  Intent downIntent = new Intent(Intent.ACTION_MEDIA_BUTTON, Null);
'  KeyEvent downEvent = new KeyEvent(eventtime, eventtime,
'KeyEvent.ACTION_DOWN, KeyEvent.KEYCODE_MEDIA_PLAY_PAUSE, 0);
'  downIntent.putExtra(Intent.EXTRA_KEY_EVENT, downEvent);
'  sendOrderedBroadcast(downIntent, Null);
'
'  Intent upIntent = new Intent(Intent.ACTION_MEDIA_BUTTON, Null);
'  KeyEvent upEvent = new KeyEvent(eventtime, eventtime,
'KeyEvent.ACTION_UP, KeyEvent.KEYCODE_MEDIA_PLAY_PAUSE, 0);
'  upIntent.putExtra(Intent.EXTRA_KEY_EVENT, upEvent);
'  sendOrderedBroadcast(upIntent, Null); 
'End Sub


Sub LogBytes(RecData() As Byte)
	Dim tempstr As StringBuilder ,temp As Int ,temp2 As Int 
	tempstr.Initialize 
	tempstr.Append( "Bytes:"  )
	For temp = 0 To RecData.Length-1 Step 2
		'temp2 =RecData(temp) Normalize(RecData(temp))
		'If temp2<0 Then temp2 = 127 - temp2
		
		temp2 = Combine(RecData(temp+1), RecData(temp))
		tempstr.Append( " " & temp2 )
	Next
	Log(tempstr.ToString)
End Sub
Sub Normalize(Data As Byte) As Int
	If Data<0 Then
		Return 127 - Data
	Else
		Return Data
	End If
End Sub
Sub Combine(Byte1 As Byte, Byte2 As Byte) As Int
	Dim temp As Int 
	'Return Normalize(Byte2) + (Normalize(Byte1)*256)
	'Return Normalize(Byte2) + Bit.ShiftLeft(Normalize(Byte1),8)  '*256)
	
	Return Bit.OR( Byte2 , Bit.ShiftLeft(Byte1,8)) *0.5 '*256)
End Sub





Sub HSLtoRGB(Hue As Int, Saturation As Int, Luminance As Int, Alpha As Int ) As Int 
   Dim temp3(3) As Double , Red As Int, Green As Int, Blue As Int ,temp1 As Double, temp2 As Double ,n As Int 
   Dim pHue As Double, pSat As Double, pLum As Double , pRed As Double, pGreen As Double, pBlue As Double 
   
   pHue = Min(239, Hue) / 239
   pSat = Min(239, Saturation) / 239
   pLum = Min(239, Luminance) / 239

   If pSat = 0 Then
      pRed = pLum
      pGreen = pLum
      pBlue = pLum
   Else
      If pLum < 0.5 Then
         temp2 = pLum * (1 + pSat)
      Else
         temp2 = pLum + pSat - pLum * pSat
      End If
      temp1 = 2 * pLum - temp2
   
      temp3(0) = pHue + 1 / 3
      temp3(1) = pHue
      temp3(2) = pHue - 1 / 3
      
      For n = 0 To 2
         If temp3(n) < 0 Then temp3(n) = temp3(n) + 1
         If temp3(n) > 1 Then temp3(n) = temp3(n) - 1
      
         If 6 * temp3(n) < 1 Then
            temp3(n) = temp1 + (temp2 - temp1) * 6 * temp3(n)
         Else
            If 2 * temp3(n) < 1 Then
               temp3(n) = temp2
            Else
               If 3 * temp3(n) < 2 Then
                  temp3(n) = temp1 + (temp2 - temp1) * ((2 / 3) - temp3(n)) * 6
               Else
                  temp3(n) = temp1
                End If
             End If
          End If
       Next 

       pRed = temp3(0)
       pGreen = temp3(1)
       pBlue = temp3(2)
    End If

    Red = pRed * 255
    Green = pGreen * 255
    Blue = pBlue * 255

	Return Colors.ARGB(Alpha, Red,Green,Blue)
End Sub


Sub uCase(Text As String)As String 
	Return Text.ToUpperCase 
End Sub
Sub lCase(Text As String) As String 
	Return Text.ToLowerCase 
End Sub
Sub Trim(Text As String) As String 
	Return Text.Trim 
End Sub
Sub Replace(Text As String, TextToReplace As String, ReplaceWith As String) As String 
	Return Text.Replace(TextToReplace,ReplaceWith)
End Sub


'0=copy 1=paste 2=return if has text
Sub Clipboard(Op As Int, Text As String) As String 
	Dim Temp As BClipboard 
	Select Case Op
		Case 0'copy
			Temp.clrText 
			Temp.settext(Text)
		Case 1: Return Temp.getText'paste
		Case 2: Return Temp.hasText'return if has text
	End Select
End Sub


Sub SendPebble(Header As String, Body As String)
	If UsePebble Then SendAlertToPebble("LCARSUI", Header,Body)
End Sub

Sub SendAlertToPebble(ThisAppsName As String, Header As String, Body As String)
	Dim I As Intent,P As Phone, JSON As String ' , JSON As JSONGenerator , M As Map , alist As List
	I.Initialize("com.getpebble.action.SEND_NOTIFICATION", "")
	'SendAlertToPebble: [{"body":"TEST","title":"LCARS"}]
	'alist.Initialize
	'M.Initialize 
	'M.put("title", Header)
	'M.put("body", Body)
	'alist.Add(M)
	'JSON.Initialize2(alist)
	
	Body=Body.Replace(vbQuote, "\" & vbQuote)
	Body=Body.Replace("\", "\\")
	Body=Body.Replace("/", "\/")
	Body=Body.Replace(CRLF, "\n")'\r
	
	JSON = "[{""body"":""" & Body & """,""title"":""" & Header & """}]"
		
	I.putExtra("messageType", "PEBBLE_ALERT")
	I.putExtra("sender", ThisAppsName)
	I.putExtra("notificationData", JSON )
	'debug("SendAlertToPebble: " & JSON.ToString)
	P.SendBroadcastIntent(I)
End Sub



Sub StripHTML(Text As String) As String
	Dim temp As Int ,temp2 As Int 
	Do While temp>-1 'remove GMAIL quote	<div class=3D"gmail_quote"> to <br>
		temp = Instr(Text, "<div class=3D" & vbQuote & "gmail_quote" & vbQuote & ">", 0)
		If temp =-1 Then temp = Instr(Text, "<div class=" & vbQuote & "gmail_quote" & vbQuote & ">",0)
		If temp >-1 Then'is gmail
			temp2 = Instr(Text, "</blockquote></div>", temp)
			If temp2=-1 Then
				temp=-1
			Else
				Text = Left(Text, temp) & Right(Text, Text.Length - (temp2+19))
			End If
		End If
	Loop
	Text = Text.Replace("<br>", CRLF).Replace("<p>", CRLF)
	temp=0
	Do While temp>-1'remove all HTML
		temp = Instr(Text, "<", 0)
		If temp>-1 Then
			temp2=Instr(Text,">", temp)
			If temp2=-1 Then
				temp=-1
			Else
				Text = Left(Text, temp) & Right(Text, Text.Length - (temp2+1))
			End If
		End If
	Loop	
	Do While Instr(Text, CRLF & CRLF,0)>-1 'remove double new lines
		Text=Text.Replace(CRLF & CRLF, CRLF)
	Loop
	Return Text.Trim'.Replace(STimer.ReplyWarning, "").Trim
End Sub

Sub RegexReplace(Pattern As String, Text As String, Replacement As String) As String
    Dim m As Matcher
    m = Regex.Matcher(Pattern, Text)
    Dim r As Reflector
    r.Target = m
    Return r.RunMethod2("replaceAll", Replacement, "java.lang.String")
End Sub












Sub InitPhoneTypes
	If Not(phoneTypes.IsInitialized) Then
		mailTypes.Initialize
		mailTypes.Add("custom")
		mailTypes.Add("home")
		mailTypes.Add("work")
		mailTypes.Add("other")
		mailTypes.Add("mobile")
		
		phoneTypes.Initialize
		phoneTypes.Add("custom")
		phoneTypes.Add("home")
		phoneTypes.Add("mobile")
		phoneTypes.Add("work")
		phoneTypes.Add("fax_work")
		phoneTypes.Add("fax_home")
		phoneTypes.Add("pager")
		phoneTypes.Add("other")
		phoneTypes.Add("callback")
		phoneTypes.Add("car")
		phoneTypes.Add("company_main")
		phoneTypes.Add("isdn")
		phoneTypes.Add("main")
		phoneTypes.Add("other_fax")
		phoneTypes.Add("radio")
		phoneTypes.Add("telex")
		phoneTypes.Add("tty_tdd")
		phoneTypes.Add("work_mobile")
		phoneTypes.Add("work_pager")
		phoneTypes.Add("assistant")
		phoneTypes.Add("mms")
		
		dataUri.Parse("content://com.android.contacts/data")
		'contactUri.Parse("content://com.android.contacts/contacts")
		'rawContactUri.Parse("content://com.android.contacts/raw_contacts")
		cr.Initialize("cr")
	End If
End Sub


'Returns a List with cuPhone items (a single contact's phone numbers)
Public Sub GetPhones(id As Long) As List
	Dim res As List
	InitPhoneTypes
	res.Initialize
	For Each obj() As Object In GetData("vnd.android.cursor.item/phone_v2", Array As String("data1", "data2", "data3"), id, Null)
		Dim p As HTMLvalue
		p.Initialize
		p.key = obj(0)'phone number
		p.value = phoneTypes.Get(obj(1))
		If obj(1) = "0" Then p.value = obj(2) 'custom
		res.Add(p)
	Next
	Return res
End Sub
Private Sub GetData(Mime As String, DataColumns() As String, Id As Long, Blobs() As Boolean) As List
	Dim crsr As Cursor = cr.Query(dataUri, DataColumns, "mimetype = ? AND contact_id = ?", Array As String(Mime, Id), ""),  res As List
	res.Initialize
	For i = 0 To crsr.RowCount - 1
		crsr.Position = i
		Dim row(DataColumns.Length) As Object
		For c = 0 To DataColumns.Length - 1
			If Blobs <> Null AND Blobs(c) = True Then
				row(c) = crsr.GetBlob2(c)
			Else
				row(c) = crsr.GetString2(c)
			End If
		Next
		res.Add(row)
	Next
	crsr.Close
	Return res
End Sub

Sub GetPhoneLabel2(PhoneNumber As String) As String 
	Return GetPhoneLabel( GetContactByPhoneNumber(PhoneNumber).Id, PhoneNumber)
End Sub
Sub GetPhoneLabel(ContactID As Int, PhoneNumber As String) As String 
	Try
		Dim Numbers As List = GetPhones(ContactID), temp As Int ,tempkey As HTMLvalue ,tempstr As String 
		PhoneNumber = RemoveAllExceptNumbers(PhoneNumber)
		For temp = 0 To Numbers.Size-1
			tempkey=Numbers.Get(temp)
			tempstr=RemoveAllExceptNumbers(tempkey.Key)
			If tempstr.EndsWith(PhoneNumber) OR PhoneNumber.EndsWith(tempstr) Then Return tempkey.Value 
		Next
	Catch
	End Try
	Return ""
End Sub













Sub BroadcastToLauncher(Action As String, Value As Object)
	Dim P As Phone, I As Intent 
	I.Initialize("com.omnicorp.launcher", "")
	I.PutExtra("Action", Action)
	I.PutExtra("Value", Value)
	P.SendBroadcastIntent(I)
End Sub
Sub BroadcastToLauncher2(Action As String, Value As Object, Value2Name As String, Value2Value As Object)
	Dim P As Phone, I As Intent 
	I.Initialize("com.omnicorp.launcher", "")
	I.PutExtra("Action", Action)
	I.PutExtra("Value", Value)
	I.PutExtra(Value2Name, Value2Value)
	P.SendBroadcastIntent(I)
End Sub
Sub BroadcastToLauncher3(Action As String, Value As Object, Value2Name As String, Value2Value As Object, Value3Name As String, Value3Value As Object)
	Dim P As Phone, I As Intent 
	I.Initialize("com.omnicorp.launcher", "")
	I.PutExtra("Action", Action)
	I.PutExtra("Value", Value)
	I.PutExtra(Value2Name, Value2Value)
	I.PutExtra(Value3Name, Value3Value)
	P.SendBroadcastIntent(I)
End Sub

Sub UpdateNotification

End Sub




Sub StartDialer
	Dim i As Intent
	i.Initialize(i.ACTION_VIEW, "tel:")'
	StartActivity(i)
End Sub