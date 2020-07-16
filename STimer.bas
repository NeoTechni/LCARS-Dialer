B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Service
Version=6.77
@EndOfDesignText@
#Region Module Attributes
	#StartAtBoot: True
#End Region

'Service module
Sub Process_Globals
	'These global variables will be declared once when the application starts.
	'These variables can be accessed from all modules.

	Type LCARtimer(Duration As Int, ID As Int, Name As String, Index As Int)
	Dim TimerList As List, timersrunning As Boolean , Infinite As Int, Increment As Int , MaxPeriod As Int ,TurnedOff As Long,TimerTicks As Int,DoNotDisturb As Boolean  '
	Increment=1000
	Infinite=-999
	TimerList.Initialize 
	
	'LCAR.CheckLoopingSound
	
	Dim PE As PhoneEvents, AC As AnswerCall, tPhoneId As PhoneId, SMSs As SmsInterceptor ,AnswerCalls As Boolean,CurrentPhoneState As Int ,DidAnswer As Boolean, isOnSpeaker As Boolean, ResponseWas As Boolean  
		
	Dim OutGoing As SMTP,Incoming As POP3 ,OutGoingIsInitialized As Boolean,IncomingIsInitialized As Boolean, EmailAddress As String, ForwardSMS As Boolean, ForwardMissedCalls As Boolean 
	Dim CurrentEmail As String ,SendDeadMans As Boolean , LastChecked As Double ,MaxMessages,MaxMessageSize As Int ,NeedsChecking As Boolean=True ,CurrentText As String ,IncomingCall As Boolean '=True
	Dim InboxQueue As List ,AllowedCountry As String ,OutgoingNumber As String ,TimerMain As Timer ,TimerSub As String ,TimerDelay As Int,CWPhone As String 
	
	Dim ProximityEnabled As Boolean ,OldBrightness As Float,StartedTalking As Long,BCR As BroadCastReceiver,LastSPKR As Long ,HeadsetIsPluggedIn As Boolean, FwdPebble As Boolean 
	Dim IncomingNumberC As String 
	
	Dim MissedCalls As List, NewSMSs As List, NewEmails As List ,IsChecking As Boolean 
	MissedCalls.Initialize:NewSMSs.Initialize:NewEmails.Initialize
	
	Dim HTTPJobs As List
End Sub


Sub FindJob(JobName As String) As Int
	Dim temp As Int , tempJob As HttpJob
	If HTTPJobs.IsInitialized Then
		For temp = 0 To HTTPJobs.Size - 1
			tempJob = HTTPJobs.Get(temp)
			If tempJob.JobName.EqualsIgnoreCase(JobName) Then Return temp
		Next
	Else
		HTTPJobs.Initialize
	End If
	Return -1
End Sub

Sub PostString(JobName As String, URL As String) As String
	Dim tempJob As HttpJob = DownloadFile(JobName, "")
	Return tempJob.PostString(API.GetSide2(URL, "?", True), API.GetSide2(URL, "?", False) )
End Sub
Sub DownloadFile(JobName As String, URL As String) As HttpJob
	Dim JobID As Int = FindJob(JobName), tempJob As HttpJob
	If JobID=-1 Then
		tempJob.Initialize(JobName, "STimer")
		HTTPJobs.Add(tempJob)
	Else
		tempJob=HTTPJobs.Get(JobID)
	End If
	If URL.Length>0 Then tempJob.Download(URL)
	Return tempJob
End Sub

Sub JobDone (Job As HttpJob)
	Dim Filename As String = API.GetURLfilename(Job.URL)
	Log("Job complete: " & Job.JobName & " (" & Job.URL & ")")
	Select Case Job.JobName
			
		Case Else:'"System", "WebPage"
			CallSub2(Main, "JobDone", Job)
	End Select
	If Not(Job.Success) Then
		Log("JOB FAILED: " & Job.ErrorMessage)
		Log(Job.URL)
	End If
	Job.release
End Sub








Sub BroadcastReceiver_OnReceive(Action As String, i As Object)
	Dim I2 As Intent = i 
  	'debug("BCR: " & Action & " " & LastSPKR & " " & DateTime.Now & " " & I2.ExtrasToString )
	HeadsetIsPluggedIn=I2.GetExtra("state") = 1'headset plugged in 
	If HeadsetIsPluggedIn And DateTime.Now > LastSPKR+DateTime.TicksPerSecond  Then 
		isOnSpeaker = False
		Try
			If Not(IsPaused(Main)) And Main.CurrentSection = 1 And API.ListSize(LCAR.LCARlists)>LCAR.ButtonList Then
				If LCAR.GetListItemCount(LCAR.ButtonList)>2 Then LCAR.LCAR_SetListitemText(LCAR.ButtonList, 2, "SPKR OFF", "")
			End If
		Catch
		End Try
	End If
End Sub








Sub PE_TextToSpeechFinish (Intent As Intent)
	'debug("STARTED: " & DateTime.GetSecond(StartedTalking) & " ENDED: " & DateTime.GetSecond(DateTime.Now) & " " & Main.SpeakText)
	'If DateTime.Now>StartedTalking+500 Then
		Main.SpeakText=""
	'Else
		'CallSubDelayed2(Main,"Speak", Main.SpeakText)
	'End If
End Sub

Sub CheckEmail
	MailParser.InitInbox 
	SendOfflineEmails(SendDeadMans)
	If API.IsConnected Then 
		If IncomingIsInitialized Then 
			Log("Check email")
			If Not(IsChecking) Then
				Incoming.ListMessages 
				IsChecking = True
			End If
		Else
			Log("POP3 not initialized")
			API.LoadEmailSettings(Main.Settings)
		End If
		LastChecked=DateTime.Now 
		NeedsChecking=False
	End If
End Sub




Sub SendOfflineEmails(DeadMans As Boolean) As Boolean 
	Dim Files As List ,temp As Int ,tempstr As String ,AllowEmail As Boolean 
	AllowEmail = API.IsConnected AND OutGoingIsInitialized 
	If File.Exists(LCAR.DirDefaultExternal, "outbox") Then
		Files = File.ListFiles(MailParser.EmailDir(False))
		'debug("SENDING OFFLINE MESSAGES: " & Files.Size)
		For temp = 0 To Files.Size-1
			tempstr=Files.Get(temp)
			Select Case MailParser.SendOfflineEmail(tempstr,SendDeadMans,CurrentEmail.Length=0 AND AllowEmail, CurrentText.Length=0)' =1 Then Return True
				Case 1:CurrentEmail=tempstr'email sent
				Case 2:CurrentText=tempstr'text sent	
			End Select
			If CurrentEmail.Length >0 AND CurrentText.Length>0 Then temp = Files.Size 
		Next 
		If CurrentEmail.Length>0 Then Log("CurrentEmail: " & CurrentEmail)
		If CurrentText.Length>0 Then Log("CurrentText: " & CurrentText)
	End If
	'CurrentEmail=""
End Sub


Sub SendEmail(Destination As List, BlindCCs As List, Subject As String, Body As String, Attachments As List)
	Dim temp As Int ,tempstr As String 
	OutGoing.To = Destination
	OutGoing.BCC = BlindCCs
	OutGoing.Subject=Subject
	If Body.Contains("<") AND Body.Contains(">") AND Body.Contains("</") Then
		OutGoing.HtmlBody=Body
	Else
		OutGoing.Body=Body
	End If
	For temp = 0 To Attachments.Size-1
		tempstr=Attachments.Get(temp)
		OutGoing.AddAttachment (API.GetDir(tempstr), API.GetFile(tempstr))
	Next
	OutGoing.Send 
End Sub

Sub OutGoing_MessageSent(Success As Boolean)
	'debug("OutGoing_MessageSent: " & Success)
	If Success Then
		File.Delete(MailParser.EmailDir(False), CurrentEmail)
		CurrentEmail=""
		CheckEmail'SendOfflineEmails(SendDeadMans)
	Else
		CurrentEmail=""
		Toast(LastException.Message)
	End If
End Sub

Sub Toast(Text As String)
	Log("TOAST: " & Text)
	If LCAR.ScreenIsOn Then
		LCAR.ToastMessage(LCARSeffects2.TempCanvas, Text.ToUpperCase ,4)
	'Else
		
	End If
End Sub

Sub GetNextEmail As Boolean  
	Dim Done As Boolean 
	If InboxQueue.IsInitialized AND API.IsConnected Then 
		If InboxQueue.Size>0 Then	
			'debug("Downloading messageID: " & InboxQueue.Get(0))
			Do While Not(Done)
				If InboxQueue.Size=0 Then
					Done=True
					MailParser.SaveInboxMap
				Else
					Done = MailParser.DownloadEmail(InboxQueue.Get(0))
					Log("Checking email: " & InboxQueue.Get(0) & " " & Done)
					If Not(Done) Then InboxQueue.RemoveAt(0)
				End If
			Loop
			Return True
		End If
	End If
End Sub
Sub Incoming_DownloadCompleted (Success As Boolean, MessageId As Int, Message As String)
	If Success Then
		Log("Email: " & MessageId & " downloaded")
		If InboxQueue.Size>0 Then InboxQueue.RemoveAt(0)
		MailParser.SaveInlineEmail(MessageId, Message)
		GetNextEmail
	Else
		'TOAST: java.lang.RuntimeException: Error listing messages: 
		Toast("I.D. ERROR: (" & MessageId & ") " & LastException.Message)
	End If
End Sub
Sub Incoming_ListCompleted (Success As Boolean, Messages As Map)
	Dim temp As Int ,MaxM As Int 
	IsChecking=False
	If Success Then
		If Not(InboxQueue.IsInitialized ) Then InboxQueue.Initialize 
		MaxM=Max(0,Messages.Size-1-MaxMessages)
		'debug(Messages.Size & " total messages. Download Message indexes from: " & ( Messages.Size -1) & " to " & MaxM )
		For temp = Messages.Size -1 To MaxM Step -1' For temp = 0 To MaxM -1
			If Messages.GetValueAt(temp) < MaxMessageSize OR MaxMessageSize =0 Then
				'API.DownloadEmail(Messages.GetKeyAt(temp))
				InboxQueue.Add(Messages.GetKeyAt(temp))
			End If
		Next 
		Log(Messages.Size & " emails to check")
		GetNextEmail
	Else
		Log(LastException.Message)
		If LastException.Message.Trim.EqualsIgnoreCase("JAVA.LANG.RUNTIMEEXCEPTION: POP3 SHOULD FIRST BE INITIALIZED.") Then
			IncomingIsInitialized = False
			API.LoadEmailSettings(Main.Settings)
			Toast("POP3 refuses to Initialize")
		Else If LastException.Message.Contains("Error listing messages") Then
			IncomingIsInitialized = False 
			Toast("Your host has disabled email downloading")
		Else
			Toast("I.L. ERROR: " & LastException.Message)
		End If
	End If
End Sub
Sub PE_SmsSentStatus (Success As Boolean, ErrorMessage As String, PhoneNumber As String, Intent As Intent)
	'ErrorMessage - One of the following values: GENERIC_FAILURE, NO_SERVICE, RADIO_OFF, NULL_PDU or OK
	Dim tempstr As List,ErrorCode As Int: tempstr.Initialize2(Array As String("OK", "GENERIC_FAILURE", "NO_SERVICE", "RADIO_OFF", "NULL_PDU"))
	ErrorCode=tempstr.IndexOf(ErrorMessage)
	'debug(ErrorCode & " = " & PhoneNumber)
	CWPhone=PhoneNumber
	LCAR.PushEvent(LCAR.LCAR_SMS, API.RemoveAllExceptNumbers(PhoneNumber),ErrorCode , 0,0,0,0, LCAR.Event_Down)
	'debug("SmsSentStatus to " & PhoneNumber & " " & Success & " " & ErrorMessage & " - " & Intent.ExtrasToString) ExtrasToString is just the phone number
	If ErrorCode=0 Then 
		MailParser.EraseText(PhoneNumber) 'Else Log("errorcode: " & ErrorCode)
		CurrentText=""
		CheckEmail
	End If
	CurrentEmail=""
End Sub
Sub SendMissedCall(PhoneNumber As String)
	Dim tempcontact As Contact,tempstr As String 
	If PhoneNumber.Length>0 Then
	'If ForwardMissedCalls AND EmailAddress.Contains("@") Then 
		tempcontact = API.GetContactByPhoneNumber(PhoneNumber)'API.FilterPhoneNumber(
		If Not(tempcontact.DisplayName = Null) Then
			tempstr = API.GetPhoneLabel(tempcontact.Id, PhoneNumber)
			If tempstr.Length>0 Then tempstr = "from " & tempstr & " "
		End If
		tempstr="Missed call from " & API.ContactName(tempcontact) & " (" & PhoneNumber & ") " & tempstr & Main.StarshipID
		MissedCalls.Add(API.ContactName(tempcontact) & " (" & PhoneNumber & ") " & tempstr)
		API.UpdateNotification
		Log(EmailAddress & " " & tempstr)
		If ForwardMissedCalls AND EmailAddress.Contains("@") Then MailParser.SaveQuickEmail(EmailAddress, tempstr , "You missed a call at " & API.now &  Warning)
		API.SendPebble("MISSED A CALL", tempstr)
	'End If
	Else
		Log("SendMissedCall: ERROR! MISSING PHONE NUMBER!")
	End If
	API.GotoSleep
End Sub
Sub Warning As String
	Dim tempstr As StringBuilder
	tempstr.Initialize 
	tempstr.Append("<BR>You can reply to this email, and the next time the LCARS Dialer checks your email it will send the reply for you")
	If DoNotDisturb Then tempstr.Append("<BR>Do not disturb mode is currently on. All calls will be blocked unless whitelisted")
	If Not(EmailAddress.ToLowerCase.EndsWith("@gmail.com")) Then tempstr.Append("<BR>You are not using Gmail, it won't know how to remove this quoted email from the reply. If you'd like to help me support your email client, please email me at technisbetas@gmail.com. Otherwise do not reply with a quote of this email")
	Return tempstr
End Sub









Sub ForceAwake
	API.SetScreenBrightness(-1)
	LCAR.LCAR_ScreenEnabled=True
	ProximityEnabled=False
End Sub


Sub Service_Create
	'debug(tPhoneId.GetDeviceId)
	API.GotoSleep
	PE.InitializeWithPhoneState("PE",tPhoneId)
	SMSs.Initialize("SMS")
	API.GetUserName(0)
	AC.Initialize("AnswerCall")
	If Main.LastLoaded=0 Then API.LoadSettings(Null, False)
	 
	'CheckEmail
	StartServiceAt( "", DateTime.Now+1000,True)
	
	If TimerDelay=0 Then TimerDelay= 1000
	TimerMain.Initialize("TimerMain", TimerDelay)
	
	'Proximity.Initialize(Proximity.TYPE_PROXIMITY)
	'ProximityState(False)

	
	BCR.Initialize("BroadcastReceiver")
	BCR.addAction("android.intent.action.HEADSET_PLUG")
	BCR.SetPriority(2147483647)
    BCR.registerReceiver("" ) 
End Sub

Sub ProximityState(State As Boolean ,FromWhat As String )
	'API.ProximityState(State, FromWhat)
End Sub

Sub SMS_MessageReceived (From As String, Body As String) As Boolean
	Dim tempContact As Contact 
	tempContact = API.GetContactByPhoneNumber(From)
	'From=API.FilterPhoneNumber(From)
	Toast("SMS RECEIVED FROM " & API.ContactName(tempContact) & " (" & From & ")" & ": " & Body)
	If ForwardSMS AND EmailAddress.Contains("@") Then MailParser.SaveQuickEmail(EmailAddress, "SMS received from " & API.ContactName(tempContact) & " (" & From & ") " & Main.StarshipID, Body & "<BR>Recieved at: " & API.Now & Warning)
End Sub
Sub PE_SmsDelivered (PhoneNumber As String, Intent As Intent)
	'debug("SmsDelivered to " & PhoneNumber & " - " & Intent.ExtrasToString)
End Sub

Sub GotoSleep
	API.StopTimer(0, "GotoSleep")
	API.NewTimer("TurnOff",1,5)
	ProximityEnabled=False
	API.GotoSleep
	ForceAwake
	'If IsPaused(Main) Then Main.CanClose=False
	Main.CanClose=True
	CallSub(Main, "GotoSleep")
End Sub

Sub Broadcast(Action As String, Value As Object)
	API.Broadcast(Action, Value)
End Sub

Sub PE_ScreenOn (Intent As Intent)
	If CurrentPhoneState = 1 AND AnswerCalls Then
		If (DateTime.Now - TurnedOff) > (DateTime.TicksPerSecond * 5) Then
			Broadcast("State", API.IIFIndex(CurrentPhoneState, Array As String("IDLE", "OFFHOOK", "RINGING")))
			TimerSub = "ShowUFPlogo"
			TimerMain_Tick
		End If
	End If
End Sub

Sub PE_PhoneStateChanged(State As String, IncomingNumber As String, Intent As Intent)
	'IDLE, OFFHOOK, RINGING. 				OFFHOOK means that there is a call or that the phone is dialing.
	Dim tempstr As String
	Log("PhoneState ResponseWas=" & ResponseWas & " Incoming=" & IncomingCall & " DidAnswer=" & DidAnswer & " State=" & State & ", IncomingNumber=" & tempstr & " Intent=" & Intent.ExtrasToString)
	CurrentPhoneState=API.GetIndex(State.ToUpperCase, Array As String("IDLE", "OFFHOOK", "RINGING") )'LCAR_PhoneState
	tempstr=API.RemoveAllExceptNumbers(IncomingNumber)
	If Not(IsNumber(tempstr)) Then tempstr=API.FilterPhoneNumber( Main.CONTACTINFO)
	If Not(IsNumber(tempstr)) Then tempstr = "-1"
	TurnedOff=0
	Broadcast("State", State)
	
	If AnswerCalls  Then
		LCAR.PushEvent(LCAR.LCAR_PhoneState, tempstr, CurrentPhoneState, 0,0,0,0, LCAR.Event_Down)
				
		Select Case CurrentPhoneState' State.ToUpperCase 
			Case 0'"IDLE" (not on a call)
				API.StopTimer(0, "PE_PhoneStateChanged: idle")
				Main.CurrentTime =0
				If IncomingCall Then	
					If DidAnswer Then 'either accepted or declined the call
						If ResponseWas Then
							Main.CanClose=True
							CallSubDelayed(Main, "showmodeselect")
							Return
						Else
							CallSubDelayed(Main, "declinedcall")
						End If
						'API.GotoSleep
						GotoSleep
					Else'call not answered
						SendMissedCall(IncomingNumberC)
						GotoSleep
					End If
					IncomingCall=False
				Else
					Log("OUTGOING CALL TO " & OutgoingNumber & " IS IDLE (HUNG UP/DECLINED)")
					GotoSleep
				End If
				isOnSpeaker=False
				ForceAwake
				ProximityState(False,"hung up")
				'LCAR.NukeQueue(LCAR.AnswerScreen)
			
			Case 1'OFFHOOK	answer phone (on a call) or place a call
				DidAnswer=True
				ResponseWas=True
				ProximityEnabled=True
				TimerMain.Enabled=False
				isOnSpeaker = False
				API.NewTimer("Main", 0, Infinite )
				If IncomingCall Then 
					ShowAnswerScreen(True)
					'CallSubDelayed(Main,"showufplogo") 'ShowUFPlogo
				Else
					Main.CurrentTime =DateTime.Now 
					Log("OUTGOING CALL " & OutgoingNumber & " IS OFFHOOK (ANSWERED)")
					ShowAnswerScreen(False)
				End If
				ProximityState(True, "New call")

				
			Case 2'"RINGING" (getting a call)
				IncomingCall=IncomingNumber.Length>0
				If IncomingCall Then IncomingNumberC = IncomingNumber
				DidAnswer=False
				ResponseWas=False
				isOnSpeaker=False
				ProximityEnabled=True
				Main.CurrentTime = 0 
				If IncomingCall Then
					If API.IsCountryBlocked(IncomingNumber, AllowedCountry)  Then
						API.KillCall 
						AC.HookUpPhone
						Log("(Country blocked)")
						SendMissedCall(IncomingNumber)
					Else
					'	Log("This country is blocked")
					'End If
						Main.CONTACTINFO=IncomingNumber
						AC.LetPhoneRing(200)
						
						If API.IgnoreNew Then 
							If API.GetContactByPhoneNumber(IncomingNumber).DisplayName = Null Then Return
						End If
					
						API.WakeUp
						StartActivity(Main)
						ShowAnswerScreen(True)
					End If
				Else
					Log("OUTGOING CALL " & OutgoingNumber & " IS RINGING")
					Main.CONTACTINFO=OutgoingNumber
					ShowAnswerScreen(True)
				End If
				
		End Select
		'debug("Incoming=" & IncomingCall)
	Else
		Select Case CurrentPhoneState' State.ToUpperCase 
			Case 0'"IDLE" (not on a call)
				If IncomingCall AND Not(DidAnswer) Then SendMissedCall(IncomingNumber)
				ProximityEnabled=False
				'LCAR.NukeQueue(LCAR.AnswerScreen)
			
			Case 1'OFFHOOK	answer phone (on a call) or place a call
				If IncomingCall Then 
					DidAnswer=True
					ResponseWas=True
				End If
				
			Case 2'RINGING
				IncomingCall=IncomingNumber.Length>0
				DidAnswer=False
				ResponseWas=False
		End Select
	End If
End Sub

Sub ShowAnswerScreen(IsIncomingCall As Boolean)
	Main.CanClose =False
	TimerSub = "answerscreen"
	TimerTicks=0
	If IsIncomingCall Then
		TimerMain.Interval=200
	Else	
		'TimerSub= "showufplogo"
		TimerMain.Interval=500
	End If
	TimerMain.Enabled=True
	LCAR.PushEvent(LCAR.AnswerScreen, 0,0,   0,0,0,0,   LCAR.Event_Down)
	'TimerMain_Tick
	'Dim PM As PackageManager , tempintent As Intent 
	'tempintent = PM.GetApplicationIntent("com.omnicorp.lcarui.dialer")
	'If tempintent.IsInitialized Then
	'	StartActivity(tempintent)
	'Else
'		StartActivity(Main)
	'End If
'	CallSubDelayed(Main, "answerscreen")
End Sub



Sub TimerMain_Tick
	'If TimerSub.EqualsIgnoreCase("answerscreen") Then
	'If CurrentPhoneState=2 Then
		Main.CanClose =False
		If IsPaused(Main) OR TimerTicks=0 OR Not(LCAR.ScreenIsOn) Then StartActivity(Main)
		If TimerTicks=0 Then CallSubDelayed(Main, TimerSub)
		LCAR.PushEvent(LCAR.AnswerScreen, 0,0,   0,0,0,0,   LCAR.Event_Down)
		TimerTicks=TimerTicks+1
	If CurrentPhoneState<>2 Then 'DidAnswer OR 
		TimerMain.Enabled=False
		TimerSub = ""
		TimerTicks=0
	End If
End Sub

Sub HandleTimerWhilePaused(tempTimer As LCARtimer)
	'debug(tempTimer)
	Select Case tempTimer.ID 
		Case 0
			'CallSubDelayed2(Main, "TimerIncrement" , tempTimer)
			'API.WakeUp
		Case 1
			If tempTimer.Duration=0 Then API.GotoSleep 
		Case 2
			If tempTimer.Duration=0 AND IsPaused(Main) Then API.DeleteSMScache(True)
	End Select
End Sub

'Sub BroadcastReceiver_OnReceive (Action As String)
'    Log(Action)
'    'can only abort when sendOrderedbroadcast is called.
'    'Broadcast.AbortBroadcast
'End Sub

Sub SendPebbleAlert(StartingIntent As Intent)
	'PEBBLE: Bundle[{messageType=PEBBLE_ALERT, sender=LCARSUI, notificationData=[{"body":"01:00 REMAINING","title":"LCARS TIMER"}]}]
	'Body: "LCARS TIMER"}]
	'Title: "01:00 REMAINING (LCARSUI)
	
	Dim Title As String, Body As String, tempstr() As String, temp As Int ,tempstr2 As String 
	If FwdPebble AND EmailAddress.Contains("@") Then 
		tempstr = Regex.Split( API.vbQuote & "," &  API.vbQuote, StartingIntent.GetExtra("notificationData"))
		For temp = 0 To tempstr.Length-1
			tempstr2 = API.GetSide(tempstr(temp), ":" & API.vbQuote, False,False)
			If API.Right(tempstr2, 3) = API.vbQuote & "}]" Then tempstr2 = API.Left(tempstr2, tempstr2.length -3)
			If API.Left(tempstr2,1) = API.vbQuote Then tempstr2 = API.Right(tempstr2, tempstr2.length-1)
			
			If tempstr(temp).Contains("title") Then Title = tempstr2 & " (" & StartingIntent.GetExtra("sender") & ")" Else Body = tempstr2
		Next
		MailParser.SaveQuickEmail(EmailAddress, Title , Body)
	End If
	API.GotoSleep
End Sub

Sub Service_Start (StartingIntent As Intent)
	Dim temp As Int , temp2 As LCARtimer ,IsScreenOn As Boolean ,Value As Object 
	


	'debug(StartingIntent.Action & CRLF & StartingIntent.ExtrasToString )
	If StartingIntent.Action ="android.intent.action.NEW_OUTGOING_CALL" Then
		'debug(StartingIntent.ExtrasToString)
		'Bundle[{android.phone.extra.ALREADY_CALLED=False, android.intent.extra.PHONE_NUMBER=9053150196, android.phone.extra.ORIGINAL_URI=tel:9053150196}]
		IncomingCall=False
		OutgoingNumber = StartingIntent.GetExtra("android.intent.extra.PHONE_NUMBER")
		'debug("OutgoingNumber: " & OutgoingNumber)
	Else If StartingIntent.Action = "android.intent.action.HEADSET_PLUG" Then'android.intent.action.HEADSET_PLUG
		Log("Headset plugged in" )
	Else If StartingIntent.Action = "com.omnicorp.dialer" Then 
		Value=StartingIntent.GetExtra("Value")
		Select Case StartingIntent.GetExtra("Action")
			Case "Suppress": TurnedOff = DateTime.Now + (DateTime.TicksPerSecond * Value)
			Case "DND"
				DoNotDisturb = Value
				Broadcast("Toast", "DO NOT DISTURB MODE IS " & API.IIF(Value, "ON","OFF"))
				API.SendPebble("DND MODE", "DO NOT DISTURB MODE IS " & API.IIF(Value, "ON","OFF"))
			Case Else
				Log("Unhandled action: " & StartingIntent.GetExtra("Action") & " Value: " & Value) 
		End Select
	Else If StartingIntent.Action="com.getpebble.action.SEND_NOTIFICATION" Then
		SendPebbleAlert(StartingIntent)
	End If
	
	If True Then
		timersrunning=False
		For temp =  TimerList.Size-1 To 0 Step -1
			temp2 = TimerList.Get(temp)
			If temp2.Duration > Infinite Then temp2.Duration=temp2.Duration-1
			temp2.Index = temp
			
			'If Not(LCAR.ScreenIsOn ) AND temp2.Duration=0 Then
				'HandleTimerWhilePaused(temp2)
			'Else
				HandleTimerWhilePaused(temp2)
				CallSub2(Main, "TimerIncrement" , temp2)
			'End If
			
			If temp2.Duration >0 OR temp2.Duration = Infinite Then
				'Log(temp2.ID & " Timer: " & temp2.Name  & " " & temp2.Duration )
				timersrunning=True 
			Else
				TimerList.RemoveAt(temp)
			End If
		Next
		
		IsScreenOn=API.IsScreenOn AND Not(IsPaused(Main)) AND LCAR.GUIcreated
		
			'Log("Timers are NOT running")
		If MaxPeriod = 0 Then MaxPeriod = 15
		temp = Increment*60*MaxPeriod'increment = ticks per second
		'NeedsChecking=True
		If DateTime.Now - LastChecked >= temp OR NeedsChecking Then CheckEmail
		
		If timersrunning Then
			StartServiceAt( "",DateTime.Now+ Increment,True)
		Else
			StartServiceAt( "",DateTime.Now+ temp,True)
		End If 
	End If
End Sub

Sub Service_Destroy
	'Proximity.StopListening 
	TimerList.Clear 
	API.GotoSleep
	MailParser.SaveInboxMap
	API.SendPebbleConnected(False)
End Sub

