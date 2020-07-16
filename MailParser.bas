B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=StaticCode
Version=6.77
@EndOfDesignText@
'Code module
Sub Process_Globals
	Type MailThread(Subject As String, Messages As String, Date As Long, IsRead As Boolean,Attachments As Int, From As String)
	Type Message (FromField As String, ToField As String, CCField As String, BCCField As String, Subject As String, Body As String, ContentType As String, Attachments As List)
	Dim index As Int, boundary As String, multipart As Boolean, dir As String
	
	Dim TheInbox As Map ,Encryption As Boolean , TheKey() As Byte ,smssent As Boolean ,InboxNeedsSaving As Boolean ,TempMailBox As List 
End Sub
'Parses a raw mail message and returns a Message object
'Mail - The mail raw text
'AttachmentsDir - Attachments will be saved in this folder
Sub ParseMail (Mail As String, AttachmentsDir As String) As Message
	index = 0
	multipart = False
	boundary = ""
	Dim msg As Message
	Try
		msg.Initialize
		msg.Attachments.Initialize
		ParseHeaders(Mail, msg)
		If multipart = False Then
			ParseSimpleBody(Mail, msg)
		Else
			dir = AttachmentsDir
			ParseMultipartBody(Mail, msg)
		End If
	Catch
	End Try
	Return msg
End Sub
Sub ParseMultipartBody (Mail As String, Msg As Message)
	'find first boundary
	index = Mail.IndexOf2("--" & boundary, index)
	ReadNextLine(Mail)
	Dim headers As StringBuilder
	headers.Initialize
	Do While index < Mail.Length
		Dim line As String, nextPart As Int
		line = ReadNextLine(Mail)
		If line.Length > 0 Then
			headers.Append(line).Append(" ")
		Else If index < Mail.Length Then
			nextPart = Mail.IndexOf2("--" & boundary, index)
			If nextPart-4 > index Then
				HandlePart(headers.ToString, Mail.SubString2(index, nextPart-4), Msg)
			End If
			If nextPart = -1 Then Return
			index = nextPart
			ReadNextLine(Mail)
			headers.Initialize
		End If
	Loop
End Sub
Sub HandlePart(Headers As String, Body As String, Msg As Message)
	If Regex.Matcher2("Content-Transfer-Encoding:\s*base64", Regex.CASE_INSENSITIVE, Headers).Find Then
		'we are dealing with an attachment
		Dim filename As String, M As Matcher, su As StringUtils,out As OutputStream, data() As Byte
		M = Regex.Matcher2("filename=\s*q([^q]+)q".Replace("q", QUOTE), Regex.CASE_INSENSITIVE, Headers)
		If M.Find Then filename = M.Group(1) Else filename = "attachment" & (Msg.Attachments.Size + 1)
		out = File.OpenOutput(dir, filename, False)
		data = su.DecodeBase64(Body)
		'debug("file saved: "  & filename & " (" & data.Length & " bytes)")
		out.WriteBytes(data, 0, data.Length)
		out.Close
		Msg.Attachments.Add(filename)
	Else If Regex.Matcher2("Content-Type:\s*text/", Regex.CASE_INSENSITIVE, Headers).Find Then
		Msg.Body = Body
	End If
End Sub

Sub ParseSimpleBody (Mail As String, Msg As Message)
	Msg.Body = Mail.SubString(index)
End Sub

Sub ParseHeaders (Mail As String, Msg As Message)
	Dim line As String
	'debug("MAIL: " & Mail)
	line = ReadNextLine(Mail)
	Do While line.Length > 0
		Dim parts() As String,first As String, second As String
		parts = Regex.Split(":", line)
		If parts.Length>2 Then	parts(1)= API.Right(line, line.Length - (parts(0).Length +1) )
		If parts.Length >= 2 Then
			first = parts(0).ToLowerCase
			Select first
				Case "from":	Msg.FromField = parts(1)
				Case "to":		Msg.ToField = parts(1)
				Case "cc":		Msg.CCField = parts(1)
				Case "bcc":		Msg.BCCField = parts(1)
				Case "subject":	Msg.Subject = parts(1)
				Case "content-type"
					second =  parts(1).ToLowerCase
					Msg.ContentType = parts(1)
					If second.Contains("multipart/") Then
						multipart = True
						If FindBoundary(line) = False Then
							line = ReadNextLine(Mail)
							FindBoundary(line)
						End If
					End If
			End Select	
		End If
		line = ReadNextLine(Mail)
	Loop
End Sub

Sub FilterData(Data As String) As String 
	Dim IsUTF As Boolean, IsISO As Boolean,IsWIN As Boolean, EnChar As String', STR As StringUtils 'StringUtils.DecodeUrl
	'UniKey Partners With Kwikset' added to =?utf-8?Q?UniKey=20Partners=20With=20Kwikset?=
	'412 added to =?utf-8?B?R2FtZVN0b3AuY29tIE9yZGVyIENhbmNlbGxhdGlvbiAtIDQxMjExMjMxNjA3NzU4NjQ=?=
	'469 added to =?ISO-8859-1?Q?Re=3A_=23atheist_=23atheism_Via_=2BAtheist_=AE_?=
	'398 added to =?windows-1252?Q?WASDIO=99_=2D_The_PC_Game_Controller_for_Action_Games=2E?=
	
	Data=Data.Trim 
	IsUTF = Data.StartsWith("=?utf-8?")
	IsISO = Data.StartsWith("=?ISO-8859-1?")
	IsWIN = Data.StartsWith("=?windows-1252?")
	
	If IsUTF Then Data = API.Right(Data, Data.Length-8)
	If IsISO Then Data = API.Right(Data, Data.Length-13)
	If IsWIN Then Data = API.Right(Data, Data.Length-15)
	
	If IsUTF OR IsISO OR IsWIN Then
		EnChar= API.Left(Data,1)
		Data = API.Right(Data, Data.Length-2)
		Data = API.left(Data, Data.Length-2)
		Data = DecodeText(Data,IsUTF,IsISO,IsWIN, EnChar) 
		If Data.EndsWith("=") Then Data = API.left(Data, Data.Length-1)
	End If
	
	Return Data
End Sub

Sub DecodeText(Data As String, isUTF As Boolean,IsISO As Boolean,IsWIN As Boolean, EnChar As String) As String 
	Dim arrByte() As Byte , STR As StringUtils 
	If isUTF Then
		Select Case EnChar
			Case "Q"
				Data = Data.Replace("=20", " ")
			Case "B"
				arrByte = STR.DecodeBase64(Data)
				Data = BytesToString(arrByte, 0, arrByte.Length, "UTF-16")
		End Select
	Else If IsISO Then
		Select Case EnChar
			Case "Q"
				Data = ReplaceEquals(Data) 'Data.Replace("_", " ")
		End Select
	Else If IsWIN Then
		Select Case EnChar
			Case "Q"
				Data = ReplaceEquals(Data) ' 
		End Select
	End If
	Return Data.Trim 
End Sub
Sub ReplaceEquals(Data As String) As String
	Dim temp As Int ,tempstr2 As StringBuilder ,Chara As Int 
	Data = Data.Replace("_", " ")
	temp = API.Instr(Data, "=", 0)
	If temp>-1 Then
		tempstr2.Initialize 'ToDec
		Do While temp>-1 	
			Chara = API.ToDec( API.Mid(Data, temp+1,2) )  'debug("CHAR: " & Chara)
			tempstr2.Append( API.Left(Data,temp) & Chr( Chara)) 'debug("DATA: " & API.Left(Data,temp))
			Data=API.Right(Data, Data.Length - (temp +3) ) 'debug("NEW : " & API.Left(Data,temp))
			temp = API.Instr(Data, "=", 0)
		Loop
		Return tempstr2.ToString 
	End If
	Return Data
End Sub

Sub FindBoundary(line As String) As Boolean
	Dim M As Matcher
	M = Regex.Matcher2("boundary=\q([^q]+)\q".Replace("q", QUOTE), Regex.CASE_INSENSITIVE, line)
	If M.Find Then
		boundary = M.Group(1)
		Return True
	Else
		Return False
	End If
End Sub

Sub ReadNextLine (Mail As String)
	Dim sb As StringBuilder
	sb.Initialize
	Dim C As Char
	Do While index < Mail.Length
		C = Mail.CharAt(index)
		index = index + 1
		If C = Chr(13) OR C = Chr(10) Then
			If C = Chr(13) AND index < Mail.Length AND Mail.CharAt(index) = Chr(10) Then index = index + 1
			Exit 'break the loop
		End If
		sb.Append(C)
	Loop
	Return sb.ToString
End Sub

Sub DecodeQuotePrintable(q As String) As String
    Dim M As Matcher
    M = Regex.Matcher("=\?([^?]*)\?Q\?(.*)\?=$", q)
    If M.Find Then
        Dim charset As String
        Dim data As String
        charset = M.Group(1)
        data = M.Group(2)
        Dim bytes As List
        bytes.Initialize
        Dim i As Int
        Do While i < data.Length
            Dim C As String
            C = data.CharAt(i)
            If C = "_" Then
                bytes.AddAll(" ".GetBytes(charset))
            Else If C = "=" Then
                Dim hex As String
                hex = data.CharAt(i + 1) & data.CharAt(i + 2)
                i = i + 2
                bytes.Add(Bit.ParseInt(hex, 16))
            Else
                bytes.AddAll(C.GetBytes(charset))
            End If
            i = i + 1
        Loop
        Dim b(bytes.Size) As Byte
        For i = 0 To bytes.Size - 1
            b(i) = bytes.Get(i)
        Next
        Return BytesToString(b, 0, b.Length, charset)
    Else
        Return q
    End If
End Sub








Sub CheckEmail
	CallSubDelayed(STimer,"CheckEmail")
	SaveInboxMap
End Sub

Sub SaveQuickEmail(EmailTo As String, Subject As String, Body As String)As Boolean 
	If EmailTo.Length=0 Then
		If STimer.EmailAddress.Length=0 Then Return False
		EmailTo=STimer.EmailAddress
	End If
	
	'Dim tempstr As String 
	'tempstr = CODEC(Body, True)
	'Body = Body & "<P>" & tempstr & "<P>" & CODEC(tempstr,False)
	
	SaveOfflineEmail(EmailTo,"", "", Subject, Body, False, Array As String(""), -1, "")
End Sub

Sub EraseText(PhoneNumber As String)
	Dim tempstr As Map
	'PhoneNumber=API.FilterPhoneNumber(PhoneNumber)
	If File.Exists(EmailDir(False), STimer.CurrentText) Then
		tempstr = File.ReadMap(EmailDir(False), STimer.CurrentText)
		'AddMessageToLogs(PhoneNumber, tempstr.GetDefault("Body",""), "",-1, 0)
		API.AddMessageToLogs(PhoneNumber, Get(tempstr, tempstr.ContainsKey("Encrypted"), "Body") , "",-1, 0)
		File.Delete(EmailDir(False), STimer.CurrentText)
	End If
End Sub

Sub Put(eFile As Map, IsEncrypted As Boolean, Key As String, Value As Object)
	If Encryption AND IsEncrypted Then
		'debug("BEFORE: " &  Value)
		eFile.Put(Key, CODEC(Value, True, TheKey))
		'debug("AFTER: " & eFile.Get(Key))
		'debug("TEST:  " & Get(eFile, True, Key))
	Else
		eFile.Put(Key,Value)
	End If
End Sub
Sub Get(eFile As Map, IsEncrypted As Boolean, Key As String) As Object 
	Return GetDefault(eFile,IsEncrypted,Key,"")
End Sub
Sub GetDefault(eFile As Map, IsEncrypted As Boolean, Key As String, Default As Object) As Object 
	'debug("Contains key: " & (eFile.ContainsKey(Key)) & " IsEncrypted: " & IsEncrypted & " Encryption: " & Encryption)
	If eFile.ContainsKey(Key) Then
		If IsEncrypted Then 
			If Encryption Then
				'debug(eFile.Get(Key) & "=" & CODEC(eFile.Get(Key),  False,TheKey))
				Return CODEC(eFile.Get(Key), False,TheKey)
			End If
		Else
			Return eFile.Get(Key)
		End If
	End If
	Return Default
End Sub
Sub SaveOfflineEmail(Destination As String,CopyDestination As String, BlindDestination As String, Subject As String, Body As String, IsDeadMan As Boolean, Attachments As List, MessageID As Int, From As String)As String 
	Dim tempstr As Map ,temp As Int ,Filename As String ,Inbox As Boolean ,Attach As Int,Dest As String ,IsEncrypted As Boolean 
	Inbox=MessageID>-1
	'API.Debug("SaveOfflineEmail: " & Destination)
	If Not(Inbox) AND Not(Destination.Contains("@")) Then
		'Destination=API.FilterPhoneNumber(Destination)
		If File.Exists(EmailDir(False), Destination & ".map") Then
			tempstr = File.ReadMap(EmailDir(False), Destination & ".map")
		End If
	End If 
	If tempstr.IsInitialized Then
		IsEncrypted = tempstr.ContainsKey("Encrypted")
		Put(tempstr,IsEncrypted, "Body", GetDefault(tempstr,IsEncrypted, "Body", "")  & CRLF & Body)
		'tempstr.Put("Body", tempstr.GetDefault("Body", "") & CRLF & Body)
	Else
		tempstr.Initialize
		IsEncrypted=Encryption
		If IsEncrypted Then tempstr.Put("Encrypted", True)
		Put(tempstr,IsEncrypted, "To", Destination)' tempstr.Put("To", Destination)
		Put(tempstr,IsEncrypted, "CC", CopyDestination)'tempstr.Put("CC", CopyDestination)
		Put(tempstr,IsEncrypted, "BCC", BlindDestination)'tempstr.Put("BCC", BlindDestination)
		Put(tempstr,IsEncrypted, "Subject", Subject)'tempstr.Put("Subject", Subject)
		Put(tempstr,IsEncrypted, "Body", Body)'tempstr.Put("Body", Body)
	End If
	'File.Combine(EmailDir(True),"temp")
	For temp = 0 To Attachments.Size-1
		Filename=Attachments.Get(temp)
		If Inbox Then
			Dest=LCARSeffects.UniqueFilename(EmailDir(True), Filename, "")
			API.RenameFile(File.Combine(EmailDir(True),"temp"), Filename, EmailDir(True), Dest)
			Filename=Dest
		End If
		'debug("Attachment: " & Filename)
		If Filename.Length>0 Then 
			Put(tempstr,IsEncrypted,"Attachment" & temp, Filename)    'tempstr.Put("Attachment" & temp, Filename)
			Attach=Attach+1
		End If
	Next
	tempstr.Put("Attachments", Attach)
	If Inbox Then
		Put(tempstr,IsEncrypted,"From", From)'tempstr.Put("From", From)
		'debug("from: " & From & " subject: " & Subject & " ID: " & Main.StarshipID)
		If From.ToUpperCase.Contains(STimer.EmailAddress.ToUpperCase) AND Subject.Contains(Main.StarshipID) Then ProcessCMD(Subject, Body)
		File.MakeDir(LCAR.DirDefaultExternal, "inbox")
		Filename = MessageID & ".map"
		SaveInbox(MessageID, Subject,AppendAddresses(Destination,CopyDestination,BlindDestination), From, Attach)
	Else
		tempstr.Put("Deadman", IsDeadMan)
		File.MakeDir(LCAR.DirDefaultExternal, "outbox")
		If Destination.Contains("@") Then
			Filename= LCARSeffects.UniqueFilename(EmailDir(False), "email.map", "")
		Else
			Filename= LCARSeffects.UniqueFilename(EmailDir(False), Destination & ".map", "")
		End If
		STimer.NeedsChecking=True
		StartService(STimer)
	End If
	File.WriteMap(EmailDir(Inbox),Filename, tempstr)
	Return Filename
End Sub

Sub AppendAddresses(Source1 As String, Source2 As String, Source3 As String) As String 
	Dim tempstr As StringBuilder 
	tempstr.Initialize 
	If Source1.Length>0 Then tempstr.Append(Source1)
	If Source2.Length>0 Then tempstr.Append(API.IIF(tempstr.Length=0, "", ", ") & Source2)
	If Source3.Length>0 Then tempstr.Append(API.IIF(tempstr.Length=0, "", ", ") & Source3)
	Return tempstr.ToString 
End Sub

Sub InitInbox
	Dim Files As List ,tempEmail As Map,temp As Int ,Filename As String ,MessageID2 As String,IsEncrypted As Boolean
	If Not(TheInbox.IsInitialized) Then
		TheInbox.Initialize 
		If File.Exists(LCAR.DirDefaultExternal, "inbox") Then
			If File.Exists(EmailDir(True), "TOC.map") Then TheInbox = File.ReadMap(EmailDir(True), "TOC.map") 'uncomment
'			Log("LOADING")
'			For temp = 0 To TheInbox.Size-1
'				Log(TheInbox.GetKeyAt(temp) & " = " & TheInbox.GetValueAt(temp))
'			Next
'			Log("END LOADING")
			
			Files = File.ListFiles(EmailDir(True))'   File.Combine(LCAR.DirDefaultExternal, "inbox"))
			For temp = 0 To Files.Size-1
				Filename = Files.Get(temp)
				If Filename.EndsWith(".map") AND Not(Filename.EqualsIgnoreCase("TOC.map")) Then
					MessageID2 = API.Left(Filename, Filename.Length-4)
					If IsNumber(MessageID2) Then
						If EmailNeedsAddingToInboxMap(MessageID2) Then' Not(TheInbox.ContainsKey(MessageID2)) Then
							tempEmail = File.ReadMap(EmailDir(True), Filename)
							IsEncrypted = tempEmail.ContainsKey("Encrypted")
							If Not(IsEncrypted) AND Encryption Then EncryptKeys(tempEmail, Array As String("To", "CC", "BCC", "Subject", "Body" ))
							SaveInbox(MessageID2, Get(tempEmail,IsEncrypted, "Subject"),Get(tempEmail,IsEncrypted,"To"),  Get(tempEmail,IsEncrypted,"From"), tempEmail.GetDefault("Attachments", 0))
						Else If File.Size(EmailDir(True), Filename)=0 Then
							DeleteEmailFromThread(MessageID2)
						End If
					End If
				End If'
			Next
		End If
		TempMailBox = EnumThreads
	End If
End Sub

Sub PurgeInOutBox(Inbox As Boolean,Outbox As Boolean)
	If Inbox Then
		TheInbox.Initialize 
		API.Deltree(EmailDir(True), True)
	End If
	If Outbox Then API.Deltree(EmailDir(False), True)
End Sub


Sub SaveInbox(MessageID As Int, Subject As String,eTo As String, From As String, Attachments As Int)
	InitInbox
	TheInbox.Put(MessageID, Attachments)
	TheInbox.Put(MessageID & "S", Subject)
	TheInbox.Put(MessageID & "2", eTo)
	TheInbox.Put(MessageID & "@", From)
	InboxNeedsSaving=True
	AddMessageToThread(MessageID, Subject)
End Sub
Sub EncryptKeys(tempEmail As Map, Keys() As String)
	Dim temp As Int ,Count As Int, Key As String 
	For temp = 0 To Keys.Length-1
		Put(tempEmail,True, Keys(temp), Get(tempEmail,False, Keys(temp)))
	Next
	Count = tempEmail.GetDefault("Attachments", 0)
	For temp = 0 To Count-1
		Key = "Attachment" & temp
		Put(tempEmail,True, Key, Get(tempEmail,False, Key))
	Next
End Sub
Sub ProcessCMD(Subject As String, Body As String)As Boolean 
	Dim tempstr() As String ,temp As Int ,ReplyTo As String 
	If Subject.Contains("Re:") Then
		If Subject.Contains("SMS received from ") OR Subject.Contains("Missed call from ") Then
			temp=API.InstrRev(Subject, "(")
			If temp>-1 Then
				Subject = API.Right(Subject, Subject.Length - temp+1)
				ReplyTo=API.GetBetween(Subject, "(", ")")
			End If
		End If
	Else If Not(Subject.StartsWith("CMD")) Then
		Log("Not for this program")
		Return False'
	End If
	
	Body=API.StripHTML(Body)
	If ReplyTo.Length>0 Then
		Log("Sending reply to: " & ReplyTo & "'" & Body & "'")
		API.SendTextMessage(ReplyTo, Body, True)
	Else
		tempstr = Regex.Split(CRLF, Body) 'Regex.Split(CRLF, Body.Replace("<BR>", CRLF).Replace("<P>", CRLF))
		For temp = 0 To tempstr.Length-1
			Log("CMD " & temp & ": " & tempstr(temp))
		Next
	End If
	Return True
End Sub

Sub DownloadEmail(MessageID As Int) As Boolean  	
	If EmailNeedsDownloading(MessageID) Then
		'debug("Download messageID: " & MessageID)
		STimer.Incoming.DownloadMessage(MessageID,False)
		Return True
	End If
	'debug("Skipping messageID: " & MessageID)
End Sub
Sub SaveInlineEmail(MessageID As Int, EncodedMessage As String)As String 
	Dim S As Message 
	File.MakeDir(EmailDir(True),"temp")
	S = ParseMail(EncodedMessage, File.Combine(EmailDir(True),"temp") )
	SaveOfflineEmail(S.ToField, S.CCField, S.BCCField , S.Subject, S.Body, False, S.Attachments , MessageID,  S.FromField)
End Sub

Sub LoadOfflineEmail(Filename As String,Inbox As Boolean, AllData As Boolean) As Message 
	Dim S As Map,IsEncrypted As Boolean ,tempMessage As Message ,Attachments As Int ,temp As Int
	'Log(Filename)
	If Filename.EndsWith(".map") Then
		'debug("TEST1")
		S = File.ReadMap(EmailDir(Inbox), Filename)
		If S.Size>0 Then 
			'debug("TEST2")
			tempMessage.Initialize 
			tempMessage.Attachments.Initialize 
			IsEncrypted 				=	S.ContainsKey("Encrypted")
			tempMessage.Body			=	Get(S,IsEncrypted, "Body")
			If AllData Then
				tempMessage.ToField		=	ExtractList(Get(S, IsEncrypted, "To"),True)
				tempMessage.CCField		=	ExtractList(Get(S,IsEncrypted, "CC"),True)
				tempMessage.BCCField	=	ExtractList(Get(S,IsEncrypted, "BCC"),True)
				tempMessage.Subject		=	Get(S,IsEncrypted, "Subject")
				tempMessage.FromField	=	Get(S,IsEncrypted, "From")
				tempMessage.ContentType =	tempMessage.Body.Contains("<") AND tempMessage.Body.Contains(">")
			End If
			Attachments	         		=	S.GetDefault("Attachments", 0)
			For temp = 0 To Attachments-1
				tempMessage.Attachments.Add(Get(S,IsEncrypted, "Attachment" & temp))
			Next
		End If
	End If
	Return tempMessage
End Sub

Sub FilterEmailsOnly(Addresses As List) As List 
	Dim temp As Int, tempstr As String 
	For temp = 0 To Addresses.Size-1
		tempstr=Addresses.Get(temp)
		If tempstr.Contains("<") AND tempstr.Contains(">") Then Addresses.Set(temp, API.GetBetween(tempstr,"<",">"))
	Next
	Return Addresses
End Sub
Sub SendOfflineEmail(Filename As String, DeadMans As Boolean,AllowEmail As Boolean, AllowText As Boolean)As Int 
	Dim S As Map, temp As Int ,Count As Int,tempstr As String ,IsEncrypted As Boolean 
	If Filename.EndsWith(".map") Then
		S = File.ReadMap(EmailDir(False), Filename)
		If S.Size=0 Then 
			File.Delete(EmailDir(False), Filename)
			Return 0
		End If
		If S.Get("Deadman") AND Not(DeadMans) Then Return 0
		IsEncrypted = S.ContainsKey("Encrypted")
		tempstr = Get(S, IsEncrypted, "To")'  S.Get("To")
		'debug("IsEncrypted: " & IsEncrypted & " tempstr: " & tempstr
		If tempstr.Contains("@") Then
			If  API.IsConnected AND STimer.OutGoingIsInitialized AND AllowEmail Then
				STimer.OutGoing.To = FilterEmailsOnly(ExtractList(tempstr,True))
				STimer.OutGoing.CC = FilterEmailsOnly(ExtractList(Get(S,IsEncrypted, "CC"),True))'ExtractList(S.Get("CC"))
				STimer.OutGoing.BCC = FilterEmailsOnly(ExtractList(Get(S,IsEncrypted, "BCC"),True))'ExtractList(S.Get("BCC"))
				STimer.OutGoing.Subject=Get(S,IsEncrypted, "Subject")'S.Get("Subject")
				tempstr=Get(S,IsEncrypted, "Body")'S.Get("Body")
				STimer.OutGoing.HtmlBody = tempstr.Contains("<") AND tempstr.Contains(">") 'AND tempstr.Contains("</"))
				STimer.OutGoing.Body=tempstr
				For temp = 0 To S.Get("Attachments") -1
					tempstr=Get(S,IsEncrypted,"Attachment" & temp)'   S.GetDefault("Attachment" & temp, "")
					If tempstr.Length>0 Then STimer.OutGoing.AddAttachment (API.GetDir(tempstr), API.GetFile(tempstr))
				Next
				
'				Log("To:      " & STimer.OutGoing.To)
'				Log("CC:      " & STimer.OutGoing.CC)
'				Log("BCC:     " & STimer.OutGoing.BCC)
'				Log("Subject: " & STimer.OutGoing.Subject)
'				Log("Body:    " & STimer.OutGoing.Body)				
				
				STimer.OutGoing.Send 
				Return 1
			'Else
				'debug("IsConnected: " & IsConnected & " OutGoingIsInitialized: " & STimer.OutGoingIsInitialized & " AllowEmail: " & AllowEmail)
			End If
		Else If AllowText Then
			Count = S.Get("Attachments")
			For temp = 0 To Count -1
				tempstr=Get(S,IsEncrypted,"Attachment" & temp)' S.GetDefault("Attachment" & temp, "")
				If tempstr.Length>0 Then 
					If File.Exists(API.GetDir(tempstr), API.GetFile(tempstr)) Then
						API.SendPhotoMessage(Get(S,IsEncrypted, "To"), Get(S,IsEncrypted,"Body"), API.GetDir(tempstr),  API.GetFile(tempstr))
						'SendPhotoMessage(S.Get("To"), S.Get("Body"),GetDir(tempstr), GetFile(tempstr))
						Return 2
					End If
				End If
			Next
			tempstr=Get(S,IsEncrypted, "To")
			API.Debug("SENT TEXT TO: " & tempstr)
			API.SendTextMessage(tempstr, Get(S,IsEncrypted,"Body"),False)
			'SendTextMessage(S.Get("To"), S.Get("Body"),False)
			Return 2
		'Else 
			'debug("tempstr: " & tempstr & " AllowText: " & AllowText)
		End If
	End If
	Return 0
End Sub
Sub EmailDir(Inbox As Boolean) As String 
	Return File.Combine(LCAR.DirDefaultExternal,  API.IIF(Inbox, "inbox", "outbox"))
End Sub





Sub ExtractList(Text As String, Raw As Boolean ) As List
	Dim templist As List ,tempstr() As String,temp As Int 
	If Text.Length=0 Then
		templist.Initialize 
	Else If Text.Contains(",") Then
		If Raw Then
			templist.Initialize2(Regex.Split(",", Text) )
		Else
			templist.Initialize
			tempstr=Regex.Split(",", Text)
			For temp =0 To tempstr.Length-1
				templist.Add(tempstr(temp))
			Next
		End If
	Else
		templist.Initialize 
		templist.Add(Text)
	End If
	Return templist
End Sub
Sub ExtractText(tList As List) As String 
	Dim temp As Int, tempstr As StringBuilder 
	tempstr.Initialize 
	For temp = 0 To tList.Size-1
		If temp=0 Then 
			tempstr.Append(API.Trim(tList.Get(0)))
		Else
			tempstr.Append("," & API.Trim(tList.Get(temp)))
		End If
	Next
	Return tempstr.ToString 
End Sub
Sub GetEncryptionKey (isPublic As Boolean) As Object 
	Dim keys(8) As Byte, temp As Int,tempstr As String ,tempstr2() As String 
	If isPublic Then
		For temp = 0 To 7
			If temp < Main.StarshipID.Length-1 Then
				keys(temp) = Asc(API.Mid(Main.StarshipID, temp,1))
			Else
				keys(temp) = 0
			End If
		Next
	Else
		Encryption = False
		If Main.Settings.ContainsKey("Key") Then
			Encryption = True
			tempstr = Main.Settings.Get("Key")
			tempstr = CODEC(tempstr, False, GetEncryptionKey(True))
			tempstr2 = Regex.Split(",", tempstr)
			If tempstr2.Length = 8 Then
				keys = Array As Byte( tempstr2(0), tempstr2(1), tempstr2(2),tempstr2(3),tempstr2(4),tempstr2(5),tempstr2(6),tempstr2(7) )
				'For temp = 0 To 7
				'	keys(temp) = tempstr2(temp)
				'Next
			End If
		End If
	End If
	Return keys
End Sub

Sub CODEC(Text As String, Encrypt As Boolean, key() As Byte ) As String    'mode= 0/1 = encode/decode
    If Text = Null OR Text = "" Then Return ""
    Dim data(0) As Byte ,bytes(0) As Byte , Bconv As ByteConverter,Kg As KeyGenerator,C As Cipher, Diff As Int ,temp As Int 'key(0) As Byte,
    'key = Array As Byte(3, 2, 4, 4, 7, 7, 15, 8)   'change this for you

    C.Initialize("DES/ECB/NoPadding") ' just "DES" actually performs "DES/ECB/PKCS5Padding". 
    Kg.Initialize("DES")
    Kg.KeyFromBytes(key)
    If Encrypt Then    
        data = Bconv.StringToBytes(padString(Text), "UTF8")
		Diff=data.Length Mod 8
		If Diff =0 Then
        	data = C.Encrypt(data, Kg.key, False)
		Else
			Dim NewData( data.Length+ 8-Diff) As Byte ,BC As ByteConverter 
			'debug("Adding " & (8-Diff) & " digits to make " & data.Length & " into " & NewData.Length )
			BC.ArrayCopy(data,0,NewData,0, data.Length)
			data = C.Encrypt(NewData, Kg.key, False)
		End If
		Return Bconv.HexFromBytes(data)
    Else
        data = Bconv.HexToBytes(Text)
        bytes = C.Decrypt(data, Kg.key, False)
        Return Bconv.StringFromBytes(bytes,"UTF8").Trim
    End If
End Sub

Sub padString(source As String) As String
	Dim x As Int, padLength As Int,tempstr As StringBuilder 
	x = source.Length Mod 16
	If x >0 Then
		tempstr.Initialize 
		tempstr.Append(source)
		Do Until tempstr.Length Mod 16 = 0
		    tempstr.Append(" ")
		Loop
		Return tempstr.ToString 
	End If
	
'	padLength = 16 - x
'	If padLength>0 Then
'		tempstr.Initialize 
'		tempstr.Append(source)
'		For i = 0 To padLength - 1
'		    tempstr.Append(" ")
'		Next
'		Return tempstr.ToString 
'	End If
	Return source
End Sub





Sub SaveInboxMap
	'InboxNeedsSaving=False'comment out
	If InboxNeedsSaving Then
		File.WriteMap(EmailDir(True),"TOC.map",TheInbox)
		TempMailBox = EnumThreads
		InboxNeedsSaving=False
	End If
End Sub
Sub EmailNeedsAddingToInboxMap(MessageID As Int) As Boolean 
	InitInbox
	If Not(TheInbox.ContainsKey(MessageID)) Then Return True
End Sub
Sub EmailNeedsDownloading(MessageID As Int) As Boolean 
	If Not(File.Exists(EmailDir(True), MessageID & ".map")) Then Return EmailNeedsAddingToInboxMap(MessageID)
	Return False
End Sub
Sub FindProperSubject(Subject As String)As String 
	Dim temp As Int 
	For temp = 0 To TheInbox.Size-1
		If Subject.EqualsIgnoreCase( TheInbox.GetKeyAt(temp)) Then Return TheInbox.GetKeyAt(temp)
	Next
	Return ""
End Sub
Sub DeleteThread(Subject As String) As Boolean 
	Dim templist As List,temp As Int ,RET As Boolean ,tempstr As String 
	Subject=ThreadName(Subject)
	RET = TheInbox.ContainsKey(Subject)
	If Not( RET) Then 
		Subject=FindProperSubject(Subject)
		If Subject.Length>0 Then RET = TheInbox.ContainsKey(Subject)
	End If
	If RET Then
		tempstr= TheInbox.GetDefault(Subject,"")
		If tempstr.Trim.Length>0 Then
			templist = ExtractList(tempstr,True)
			For temp = 0 To templist.Size-1
				tempstr=templist.Get(temp)
				If IsNumber(tempstr) Then
					DeleteEmail(tempstr )
				Else
					Log("Delete failed: " & tempstr)
				End If
			Next
		End If
		InboxNeedsSaving=True
		TheInbox.Remove(Subject)
		
		TempInboxAction(Subject,-1)
		Return True
	End If
End Sub
Sub DeleteEmailFromThread(MessageID As Int)
	Dim Subject As String ,templist As List,temp As Int 
	Subject = ThreadName(TheInbox.Get(MessageID & "S"))
	DeleteEmail(MessageID)
	templist = ExtractList( TheInbox.Get(Subject),False)
	temp = templist.IndexOf(MessageID)
	If temp>-1 Then
		templist.RemoveAt(temp)
		TheInbox.Put(Subject, ExtractText(templist))
	End If
End Sub
Sub GetThread(MessageID As Int) As String 
	Dim tempEmail As Map,IsEncrypted As Boolean 
	tempEmail = File.ReadMap(EmailDir(True), MessageID & ".map")
	IsEncrypted = tempEmail.ContainsKey("Encrypted")
	Return ThreadName(Get(tempEmail,IsEncrypted, "Subject") )
End Sub
Sub DeleteEmail(MessageID As Int) 
	File.Delete(EmailDir(True), MessageID & ".map")
	TheInbox.Remove(MessageID & "S")
	TheInbox.Remove(MessageID & "@")
	TheInbox.Put(MessageID, "-1")
	InboxNeedsSaving=True
End Sub
Sub ThreadName(Subject As String) As String
	Dim temp As Boolean 
	temp=True
	Subject=Subject.Trim 
	Do While temp
		temp=False
		'debug(">" & Subject.ToLowerCase & "< THREADNAME")
		If Subject.ToLowerCase.StartsWith("re:") Then
			temp=True
			Subject = API.Right(Subject, Subject.Length-3).Trim 
			'debug(Subject & "< HAD RE " & temp)
		Else If Subject.ToLowerCase.StartsWith("fwd:") Then
			temp=True
			Subject = API.Right(Subject, Subject.Length-4).Trim 
			'debug(Subject & "< HAD FWD " & temp)
		Else If Subject.StartsWith("D:") Then
			temp=True
			Subject = API.Right(Subject, Subject.Length-2).Trim 
		End If
	Loop
	If IsNumber(Subject) Then Subject = "#" & Subject
	Return FilterData(Subject)
End Sub
Sub AddMessageToThread(MessageID As Int, Subject As String)
	Dim templist As List ,tempstr As String
	tempstr=ThreadName(Subject)
	If tempstr.Length>0 Then Subject=tempstr
	tempstr=""
	'debug(MessageID & " added to " & Subject)
	If TheInbox.ContainsKey(Subject) Then
		templist=ExtractList( TheInbox.Get(Subject),False)
		If templist.IndexOf(MessageID & "") = -1 Then 
			templist.Add(MessageID)
			tempstr = ExtractText(templist)
		End If
	Else
		tempstr=MessageID
	End If
	If tempstr.Length>0 Then 
		TheInbox.Put(Subject,tempstr)
		TheInbox.Put("D:" & Subject, DateTime.Now)
		InboxNeedsSaving=True
	End If
End Sub



Sub GetMessageDate(Subject As String) As Long 
	Dim templist As List, temp As Int , tempDate As Long ,CurrentDate As Long 
	If TheInbox.ContainsKey("D:" & Subject) Then
		Return TheInbox.Get("D:" & Subject)
	Else
		templist=ExtractList( TheInbox.Get(Subject),False)
		For temp = 0 To templist.Size-1
			tempDate = File.LastModified(EmailDir(True), templist.Get(temp) & ".map")
			If tempDate> CurrentDate Then CurrentDate = tempDate
		Next
		TheInbox.Put("D:" & Subject, CurrentDate)
		InboxNeedsSaving=True
		Return CurrentDate
	End If
End Sub










Sub ThreadAttachments(Subject As String) As Int 
	Dim templist As List, temp As Int,Attachments As Int ,temp2 As Int 
	templist=ExtractList( TheInbox.Get(Subject),False)
	For temp = 0 To templist.Size-1
		Try
			If IsNumber(templist.Get(temp)) Then
				temp2 = TheInbox.Get( templist.Get(temp))
				If temp2>-1 Then Attachments=Attachments+temp2
			End If
		Catch
		End Try
	Next
	Return Attachments
End Sub

Sub MessageIsRead(ID As Int) As Boolean
	Return TheInbox.ContainsKey(ID & "R")
End Sub
Sub MarkMessageAsRead(ID As Int,IsRead As Boolean)
	If IsRead Then
		TheInbox.Put(ID & "R", "")
	Else
		TheInbox.Remove(ID & "R")
	End If
	InboxNeedsSaving=True
End Sub

Sub ThreadIsRead(Subject As String) As Boolean 
	Dim templist As List, temp As Int
	templist=ExtractList( TheInbox.Get(Subject),False)
	For temp = 0 To templist.Size-1
		If Not( MessageIsRead( templist.Get(temp))) Then Return False
	Next
	Return True
End Sub

Sub MarkThreadAsRead(Subject As String,IsRead As Boolean)  As Boolean 
	Dim templist As List, temp As Int ,tempstr As String 
	tempstr=TheInbox.Get(FindProperSubject(Subject))
	templist=ExtractList(tempstr,False)
	For temp = 0 To templist.Size-1
		MarkMessageAsRead(templist.Get(temp),IsRead)
	Next
	TempInboxAction(Subject, API.IIF(IsRead, 1,0))
	Return templist.Size>0
End Sub

Sub GetMessageList(MessageIndex As Int) As String 
	Dim tempstr As String ,templist As List ,temp As Int ,CurrentMessage As Int,TempMessage As Int ,temp2 As Int ,NeedsSaving As Boolean 
	tempstr = TheInbox.GetValueAt(MessageIndex)
	'remove duplicates
	templist = ExtractList(tempstr, False)
	For temp = 0 To templist.Size-1 
		If temp < templist.Size Then
			CurrentMessage= templist.Get(temp)
			For temp2 = temp+1 To templist.Size-1 'To 0 Step -1
				TempMessage=templist.Get(temp2)
				'debug("Checking " & temp & "=" & CurrentMessage & ", " & temp2 & "=" & TempMessage)
				If CurrentMessage=TempMessage Then 
					templist.RemoveAt(temp2)
					NeedsSaving=True
					Exit
					'debug("Removed " & temp2 & " for being a duplicate")
				End If
			Next
		End If
	Next
	'redundancy check
	For temp = templist.Size-1 To 0 Step -1
		CurrentMessage= templist.Get(temp)
		If Not(File.Exists(EmailDir(True), CurrentMessage & ".map")) Then
			templist.RemoveAt(temp)
			NeedsSaving=True
		End If
	Next
	If NeedsSaving Then
		templist.Sort(False)
		tempstr= ExtractText(templist)
		'debug("After: " & tempstr)
		TheInbox.Put(TheInbox.GetKeyAt(MessageIndex),tempstr)
		InboxNeedsSaving = True
	End If
	Return tempstr
End Sub

Sub EnumFrom(Subject As String, isFrom As Boolean) As String
	Dim templist As List, temp As Int,temp2 As Int, tempstr As String,tempstr2 As String ,templist2 As List ,RET As Map ,EmailAddress As String, ContactName As String ,tempstr3 As StringBuilder 
	RET.Initialize 
	Subject=ThreadName(Subject)
	If Not(TheInbox.ContainsKey(Subject)) Then Subject=FindProperSubject(Subject)	
	templist=ExtractList( TheInbox.Get(Subject),False)
	For temp = 0 To templist.Size-1'enum messages
		tempstr = FilterData(TheInbox.Get(templist.Get(temp) & API.IIF(isFrom, "@","2")))
		templist2=ExtractList(tempstr,True)
		For temp2= 0 To templist2.Size-1'enum email addresses of a message
			EmailAddress=""
			ContactName=""
			tempstr2= templist2.Get(temp2)
			If tempstr2.Contains("<") Then
				EmailAddress= API.GetBetween(tempstr2, "<", ">").ToUpperCase 
				ContactName= API.RemoveFromQuotes(API.Left(tempstr2, API.Instr(tempstr2,"<",0)))
			Else
				EmailAddress=tempstr2.ToUpperCase 
			End If
			If RET.ContainsKey(EmailAddress) Then
				If ContactName.Length>0 Then
					tempstr2= RET.Get(EmailAddress)
					If tempstr2.Length=0 Then RET.Put(EmailAddress,ContactName)
				End If
			Else
				RET.Put(EmailAddress,ContactName)
			End If
		Next
	Next
	'TheInbox.Put(MessageID & "@", From)

	tempstr3.Initialize 
	For temp = 0 To RET.Size-1
		EmailAddress= RET.GetKeyAt(temp)
		ContactName=RET.GetValueAt(temp)
		If EmailAddress.Length=0 Then
			tempstr2= ContactName  & " <UNKNOWN>"
		Else If ContactName.Length=0 Then
			tempstr2="<" & EmailAddress & ">"
		Else
			tempstr2= ContactName & " <" & EmailAddress & ">"
		End If
		tempstr3.Append(API.IIF(temp=0,"",", ") & tempstr2)
	Next
	Return tempstr3.ToString.Trim
End Sub

Sub EnumThreads As List 
	Dim TheList As List, temp As Int, Subject As String ,Messages As String,MessagesToRemove As List',Date As Long'Type MailThread(Subject As String, Messages As String, Date As Long)
	TheList.Initialize 
	MessagesToRemove.Initialize 
	For temp = 0 To TheInbox.Size-1
		Subject= TheInbox.GetKeyAt(temp)
		If Not( IsNumber( Subject) ) AND Not(IsNumber(API.Left(Subject, Subject.Length-1))) Then
			If Not(Subject.StartsWith("D:")) Then
				'debug(TheInbox.GetKeyAt(temp) & "=" & TheInbox.GetValueAt(temp))
				Messages=GetMessageList(temp)
				If Messages.Length=0 Then 
					MessagesToRemove.Add(temp)
				Else
					TheList.Add(MakeThread(Subject,Messages,GetMessageDate(Subject),ThreadIsRead(Subject),ThreadAttachments(Subject),EnumFrom(Subject,True)))
				End If
			End If
		End If
	Next
	For temp = 0 To MessagesToRemove.Size-1
		DeleteThread( TheInbox.GetKeyAt(temp))
		InboxNeedsSaving = True
	Next
	TheList.SortType("Date", False)
	Return TheList
End Sub
Sub MakeThread(Subject As String, Messages As String, Date As Long, IsRead As Boolean,Attachments As Int,From As String) As MailThread 
	Dim temp As MailThread 
	temp.Initialize
	temp.Subject=Subject
	temp.Messages=Messages
	temp.Date=Date
	temp.IsRead = IsRead
	temp.Attachments=Attachments
	temp.From=From
	Return temp
End Sub

Sub TempInboxAction(Subject As String, Action As Int) As String 
	Dim temp As Int ,tempMessage As MailThread,tempEmail As Message, Messages As List,tempstr As StringBuilder
	If TempMailBox.IsInitialized Then
		For temp = 0 To TempMailBox.Size-1
			tempMessage=TempMailBox.Get(temp)
			If tempMessage.Subject.EqualsIgnoreCase(Subject) Then
				Select Case Action
					Case -1:TempMailBox.RemoveAt(temp)'Delete
					Case 0: tempMessage.IsRead=False 'mark unread
					Case 1: tempMessage.IsRead=True 'mark read	
					Case 2'read
						MarkThreadAsRead(tempMessage.Subject,True)
						Messages = ExtractList(tempMessage.Messages,True)
						Messages.Sort(False)
						tempstr.Initialize 
						For temp = 0 To Messages.Size-1
							tempEmail = LoadOfflineEmail(Messages.Get(temp) & ".map", True, False)
							If tempEmail.IsInitialized Then 
								tempstr.Append(tempEmail.Body & CRLF & API.IIF(temp< Messages.Size-1, "<HR> " & CRLF, ""))
								'Log(tempEmail.Body)
							End If
						Next
						If tempstr.Length=0 Then DeleteThread(tempMessage.Subject)
						Return tempstr.ToString.Replace("=20", " ").Replace("=AO", "").Replace("= ", " ")
				End Select
				Return "1"
			End If
		Next
	End If
	Return ""
End Sub