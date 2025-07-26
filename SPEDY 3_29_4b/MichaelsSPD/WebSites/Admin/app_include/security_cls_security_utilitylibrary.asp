<%
'==============================================================================
' CLASS: cls_Security_UtilityLibrary
' By ken.wallace
'==============================================================================
'
' This object holds global data access and conversion functions for the 
' other security classes.  Modify with care. KW
'
'==============================================================================
Class cls_Security_UtilityLibrary

	Public Function FixXMLDateTime(p_xmlDateStrIn, boolApplyUTCOffset)
		'XML passes us an ISO8601-formatted date value.
		'This fxn gets a VBScript-compatible Date from the ISO8601-formatted date value
		'by calling dateFromISO8601(sDate)
		Dim UTCOffset, objShellOut, strActiveTimeBiasRegKey
		strActiveTimeBiasRegKey = "HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\TimeZoneInformation\ActiveTimeBias" 

		p_xmlDateStrIn = SmartValues(p_xmlDateStrIn, "CStr")

		if CBool(boolApplyUTCOffset) then
			Set objShellOut = Server.CreateObject("WScript.Shell") 
			UTCOffset = objShellOut.RegRead(strActiveTimeBiasRegKey)	' <-- Delve into the server registry to find out what time offset to use
			UTCOffset = UTCOffset/60									' <-- The registry stores minutes, so divide by 60 to get offset hours
			'Response.Write "<p>UTCOffset = " & UTCOffset				' <-- Included for debugging

			FixXMLDateTime = dateFromISO8601(p_xmlDateStrIn, UTCOffset)	' <-- Add the UTC offset to the returned time to correct for time zone and/or Daylight Savings
		else
			FixXMLDateTime = dateFromISO8601(p_xmlDateStrIn, 0)			' <-- Use the time as-is, with no correction for time zone or Daylight Savings
		end if
	End Function

	Private Function dateFromISO8601(sDate, utcOffset)
		'XML passes us an ISO8601-formatted date value.
		'This fxn gets a VBScript-compatible Date from the ISO8601-formatted date value.
		
		Dim arParts, iMonth, iYear, iDay, iHour, iMinute, iSecond, dtD, s
		s = Replace(Replace(Replace(sDate,"-",":"),"T",":"),"Z","")
		arParts = Split(s,":")

		'CCYY:MM:DD:hh:mm:ss
		'0    1  2  3  4  5
				
		if UBound(arParts) < 5 then
			dateFromISO8601 = ""
		else
			iYear = CInt(arParts(0))
			iMonth = CInt(arParts(1))
			iDay = CInt(arParts(2))
			iHour = CInt(arParts(3))
			iMinute = CInt(arParts(4))
			iSecond = CInt(arParts(5))
				
			dtD = CDate(DateValue(DateSerial(iYear,iMonth,iDay)) & " " & _
						TimeValue(TimeSerial(iHour,iMinute,iSecond)))
					
			dateFromISO8601 = DateAdd("H", utcOffset, dtD)
		end if
	End Function

	Private Function dateToISO8601(dLocal, utcOffset)
		'XML uses an ISO8601-formatted date value.
		'This fxn gets an ISO8601-formatted date value from a VBScript-compatible date.
		Dim d
		' convert local time into UTC
		d = DateAdd("H",-1 * utcOffset,dLocal)

		' compose the date
		dateToISO8601 = Year(d) & "-" & Right("0" & Month(d),2) & "-" & Right("0" & Day(d),2) & "T" & _
			Right("0" & Hour(d),2) & ":" & Right("0" & Minute(d),2) & ":" & Right("0" & Second(d),2) & "Z"
	End Function

	Public Function loadXMLFromRS(p_strSQL, p_nodeName) ' Returns an MSXML2.DOMDocument
		Dim conn, SQLStr
		Dim cmd, stream, xmldoc

		Set conn = Server.CreateObject("ADODB.Connection")
		Set cmd = Server.CreateObject("ADODB.Command")
		Set stream = Server.CreateObject("ADODB.Stream")
		Set xmldoc = Server.CreateObject("MSXML2.FreeThreadedDOMDocument") 

		conn.Open Application.Value("connStr")
		stream.Open 

		SQLStr = CStr(p_strSQL)
		cmd.CommandType = adCmdText 
		cmd.CommandText = SQLStr
		cmd.ActiveConnection = conn

		cmd.Properties("Output Stream").Value = stream 
		cmd.Execute, , adExecuteStream 
		stream.Position = 0 

		'xmldoc.LoadXML("<?xml version='1.0'?><Root>" & stream.ReadText & "</Root>")
		xmldoc.LoadXML("<" & p_nodeName & ">" & stream.ReadText & "</" & p_nodeName & ">")
			
		if xmldoc.parseError.errorCode <> 0 then 
			Response.Write "Error loading XML: " & xmldoc.parseError.reason
			Set loadXMLFromRS = Nothing
		else
			'Response.Write "xmldoc.xml: " & xmldoc.xml
			Set loadXMLFromRS = xmldoc
		end if

		' Disconnect the recordsets and cleanup  
		Set cmd.ActiveConnection = Nothing
		Set cmd = Nothing
		Set conn = Nothing
		Set stream = Nothing
		Set xmldoc = Nothing
	End Function

	Public Function LoadRSFromDB(p_strSQL)
		Dim rs, cmd
		Set rs = Server.CreateObject("ADODB.Recordset")
		Set cmd = Server.CreateObject("ADODB.Command")

		cmd.ActiveConnection  = Application.Value("connStr")
		cmd.CommandText = p_strSQL
		cmd.CommandType = adCmdText
		cmd.Prepared = true

		rs.CursorLocation = adUseClient
		rs.Open cmd, , adOpenForwardOnly, adLockReadOnly

		if Err <> 0 then
			Err.Raise  Err.Number, "ADOHelper: RunSQLReturnRS", Err.Description
		end if

		' Disconnect the recordsets and cleanup  
		Set rs.ActiveConnection = Nothing  
		Set cmd.ActiveConnection = Nothing
		Set cmd = Nothing
		Set LoadRSFromDB = rs
	End Function

	Public Function RunSQL(ByVal p_strSQL)
		Dim cmd
		Set cmd = Server.CreateObject("ADODB.Command")

		cmd.ActiveConnection  = Application.Value("connStr")
		cmd.ActiveConnection.BeginTrans
		cmd.CommandText = p_strSQL
		cmd.CommandType = adCmdText

		' Execute the query without returning a recordset
		' Specifying adExecuteNoRecords reduces overhead and improves performance
		cmd.Execute true, , adExecuteNoRecords
		cmd.ActiveConnection.CommitTrans

		if Err <> 0 then
			cmd.ActiveConnection.RollBackTrans
			Err.Raise  Err.Number, "ADOHelper: RunSQL", Err.Description
		end if

		' Disconnect the recordsets and cleanup  
		Set cmd.ActiveConnection = Nothing
		Set cmd = Nothing
	End Function
End Class
%>