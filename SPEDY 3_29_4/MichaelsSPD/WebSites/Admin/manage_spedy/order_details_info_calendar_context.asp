<%@ LANGUAGE=VBSCRIPT%>
<%
Option Explicit
Response.Buffer = True
Response.Expires = -1441
%>
<!--#include file="./../app_include/stripHTML.asp"-->
<!--#include file="./../app_include/SmartValues.asp"-->
<!--#include file="./../app_include/checkQueryID.asp"-->
<%
Dim objConn, objRec, SQLStr, connStr
Dim f, today, m, y, d, i, firstday, daysinmonth, thismonth, SCRIPT, globalmonth
Dim cellDisplayClass, textDisplayClass
Dim strOut, beginStatus, endStatus, updateUserName

Dim Order_ID
Order_ID = CInt(checkQueryID(Request("oid"), 0))

SCRIPT = request.servervariables("script_name")
today = date()

m = Month(Session.Value("ORDER_DETAILS_ACTIVITYCALENDAR_SELECTEDMONTH"))
y = Year(Session.Value("ORDER_DETAILS_ACTIVITYCALENDAR_SELECTEDMONTH"))
globalmonth = dateserial(y, m, 1)

Set objConn = Server.CreateObject("ADODB.Connection")
Set objRec = Server.CreateObject("ADODB.RecordSet")

connStr = Application.Value("connStr")
objConn.Open connStr
%>
<html>
<head>
	<title></title>
	<style type="text/css">
		A {text-decoration: none; color: #000000; cursor: hand;}
		A:HOVER {text-decoration: underline; color: #0000ff; cursor: hand;}
		BODY
		{
			scrollbar-face-color: "#cccccc"; 
			scrollbar-highlight-color: "#ffffff"; 
			scrollbar-shadow: "#999999";
			scrollbar-3dlight-color: "#cccccc"; 
			scrollbar-arrow-color: "#000000";
			scrollbar-track-color: "#ececec";
			scrollbar-darkshadow-color: "#000000";
			cursor: default;
		}

		INPUT * {font-family:Arial, Helvetica; font-size:12px; color:#000;}
		SELECT {font-family:Arial, Helvetica; font-size:12px; color:#000;}
		TEXTAREA {font-family:Arial, Helvetica; font-size:12px; color:#000;}

		#calendarsTable
		{
			margin-top: 20px;
			padding-left: 10px;
			padding-right: 10px;
		}
		
		.calendarTable
		{
			margin-bottom:10px;
		}

		.calendarTablePast
		{
			background-color: #ececec;
		}

		.calendarTablePresent
		{
			background-color: #fff;
		}

		.calendarTableFuture
		{
			background-color: #ececec;
		}

		.calendarRow TD
		{
		}

		.calendarHeader
		{
			font-family: Arial, Helvetica, Sans-Serif;
			font-size: 9px;
			color: #000;
		}
		
		.currentDateLabel
		{
			font-family: Arial, Helvetica, Sans-Serif;
			font-size: 11px;
			line-height: 13px;
			color: #666;
			background-color: #ccc;
		}

		.calendarWeekdayHeaders TD
		{
			font-family: Arial, Helvetica, Sans-Serif;
			font-size: 9px;
			text-align: center;
			color: #fff;
			background-color: #999;
		}

		.calendarDayToday
		{
			font-family: Verdana, Arial, Helvetica, Sans-Serif;
			font-size: 9px;
			color: #000;
		}

		.calendarDay
		{
			font-family: Verdana, Arial, Helvetica, Sans-Serif;
			font-size: 9px;
			color: #000;
		}
		.calendarDayWeekend
		{
			font-family: Verdana, Arial, Helvetica, Sans-Serif;
			font-size: 9px;
			color: #000;
		}
		
		.calendarDayDisabled
		{
		}
		
		.dateString
		{
			padding: 3px;
			margin: 1px;
		}
		.dateStringToday
		{
			padding: 2px;
			border: 1px solid #ccc;
			background-color: #ffd;
		}
		
		.eventPresent
		{
			color: #fff;
			background-color: #AFC7D2;
			text-decoration: none;
		}
	</style>
	<script type="text/javascript" language="javascript">
	</script>
</head>
<body bgcolor="cccccc" topmargin=0 leftmargin=0 marginheight=0 marginwidth=0>

<table width=100% cellpadding=0 cellspacing=0 border=0 id="calendarsTable">
	<%
	thismonth = DateAdd("m", -1, globalmonth)
	m = Month(thismonth)
	y = Year(thismonth)
	%>
	<tr>
		<td class="currentDateLabel"><%= monthname(m) %>,&nbsp;<%= y %></td>
	</tr>
	<tr>
		<td valign=top>
			<table width="100%" border="0" cellspacing="0" cellpadding="0" class="calendarTable calendarTablePast">
				<tr class="calendarWeekdayHeaders">
					<td width="12%">Su</td>
					<td width="15%">M</td>
					<td width="15%">T</td>
					<td width="15%">W</td>
					<td width="15%">Th</td>
					<td width="15%">F</td>
					<td width="13%">S</td>
				</tr>
				<tr class="calendarRow">
				<%
					daysinmonth = datepart("d", dateadd("d", -1, month(dateadd("m", 1, thismonth)) & "/1/" & y))
					firstday = Weekday(thismonth)

					for i = 1 to 42
						d = i - firstday + 1
						cellDisplayClass = "calendarDay"
						textDisplayClass = "dateString"
						if (i >= firstday and d <= daysinmonth) then
							if (today = dateserial(y, m, d)) then
								cellDisplayClass = cellDisplayClass & " calendarDayToday"
								textDisplayClass = textDisplayClass & " dateStringToday"
							end if
							
							if UCase(Left(WeekdayName(Weekday(dateserial(y, m, d), 1), false, 1), 1)) = "S" then
								cellDisplayClass = "calendarDayWeekend"
							end if
							
							SQLStr = "sp_shopping_order_statushistory_by_orderID " & Order_ID & ", '" & CDate(DateSerial(y, m, d)) & "', 0, 0"
							objRec.Open SQLStr, objConn, adOpenForwardOnly, adLockReadOnly, adCmdText
							if not objRec.EOF then
								textDisplayClass = textDisplayClass & " eventPresent"

								strOut = ""
								beginStatus = SmartValues(objRec("Status_Name_BEFOREUPDATE"), "CStr")
								endStatus = SmartValues(objRec("Status_Name_AFTERUPDATE"), "CStr")
								updateUserName = SmartValues(objRec("Update_UserName"), "CStr")
						
								if Len(beginStatus) > 0 and beginStatus <> "NA" then
									strOut = "Status Changed from " & beginStatus
									if Len(endStatus) > 0 and endStatus <> "NA" then
										strOut = strOut & " to " & endStatus
									end if
									if Len(updateUserName) > 0 and updateUserName <> "NA" then
										strOut = strOut & " by " & updateUserName
									end if
								else
									strOut = "Order " & Order_ID & " Created"
								end if
					%>
					<td align="center" valign=top class="<%=cellDisplayClass%>">
						<div class="<%=textDisplayClass%>"><a href="order_details_info_calendar.asp?m=<%=m%>&y=<%=y%>&oid=<%=Request("oid")%>" target="CurrentCalendarFrame" title="<%=strOut%>" class="eventPresent"><%=d%></a></div>
					</td>
					<%
							else
					%>
					<td align="center" valign=top class="<%=cellDisplayClass%>">
						<div class="<%=textDisplayClass%>"><%=d%></div>
					</td>
					<%
							end if
							objRec.Close
						else
					%>
					<td align="center" valign=top class="calendarDayDisabled">&nbsp;</td>
					<%
						end if
						if i < 36 then
							if (i mod 7 = 0) then response.write "</tr><tr class=""calendarRow"">"
						end if
					next
				%>
				</tr>
			</table>
		</td>
	</tr>
	<%
	thismonth = DateAdd("m", 0, globalmonth)
	m = Month(thismonth)
	y = Year(thismonth)
	%>
	<tr>
		<td class="currentDateLabel"><%= monthname(m) %>,&nbsp;<%= y %></td>
	</tr>
	<tr>
		<td valign=top>
			<table width="100%" border="0" cellspacing="0" cellpadding="0" class="calendarTable calendarTablePresent">
				<tr class="calendarWeekdayHeaders">
					<td width="12%">Su</td>
					<td width="15%">M</td>
					<td width="15%">T</td>
					<td width="15%">W</td>
					<td width="15%">Th</td>
					<td width="15%">F</td>
					<td width="13%">S</td>
				</tr>
				<tr class="calendarRow">
				<%
					daysinmonth = datepart("d", dateadd("d", -1, month(dateadd("m", 1, thismonth)) & "/1/" & y))
					firstday = Weekday(thismonth)

					for i = 1 to 42
						d = i - firstday + 1
						cellDisplayClass = "calendarDay"
						textDisplayClass = "dateString"
						if (i >= firstday and d <= daysinmonth) then
							if (today = dateserial(y, m, d)) then
								cellDisplayClass = cellDisplayClass & " calendarDayToday"
								textDisplayClass = textDisplayClass & " dateStringToday"
							end if
							
							if UCase(Left(WeekdayName(Weekday(dateserial(y, m, d), 1), false, 1), 1)) = "S" then
								cellDisplayClass = "calendarDayWeekend"
							end if
							
							SQLStr = "sp_shopping_order_statushistory_by_orderID " & Order_ID & ", '" & CDate(DateSerial(y, m, d)) & "', 0, 0"
							objRec.Open SQLStr, objConn, adOpenForwardOnly, adLockReadOnly, adCmdText
							if not objRec.EOF then
								textDisplayClass = textDisplayClass & " eventPresent"

								strOut = ""
								beginStatus = SmartValues(objRec("Status_Name_BEFOREUPDATE"), "CStr")
								endStatus = SmartValues(objRec("Status_Name_AFTERUPDATE"), "CStr")
								updateUserName = SmartValues(objRec("Update_UserName"), "CStr")
						
								if Len(beginStatus) > 0 and beginStatus <> "NA" then
									strOut = "Status Changed from " & beginStatus
									if Len(endStatus) > 0 and endStatus <> "NA" then
										strOut = strOut & " to " & endStatus
									end if
									if Len(updateUserName) > 0 and updateUserName <> "NA" then
										strOut = strOut & " by " & updateUserName
									end if
								else
									strOut = "Order " & Order_ID & " Created"
								end if
					%>
					<td align="center" valign=top class="<%=cellDisplayClass%>">
						<div class="<%=textDisplayClass%>"><a href="order_details_info_calendar.asp?m=<%=m%>&y=<%=y%>&oid=<%=Request("oid")%>" target="CurrentCalendarFrame" title="<%=strOut%>" class="eventPresent"><%=d%></a></div>
					</td>
					<%
							else
					%>
					<td align="center" valign=top class="<%=cellDisplayClass%>">
						<div class="<%=textDisplayClass%>"><%=d%></div>
					</td>
					<%
							end if
							objRec.Close
						else
					%>
					<td align="center" valign=top class="calendarDayDisabled">&nbsp;</td>
					<%
						end if
						if i < 36 then
							if (i mod 7 = 0) then response.write "</tr><tr class=""calendarRow"">"
						end if
					next
				%>
				</tr>
			</table>
		</td>
	</tr>
	<%
	thismonth = DateAdd("m", 1, globalmonth)
	m = Month(thismonth)
	y = Year(thismonth)
	%>
	<tr>
		<td class="currentDateLabel"><%= monthname(m) %>,&nbsp;<%= y %></td>
	</tr>
	<tr>
		<td valign=top>
			<table width="100%" border="0" cellspacing="0" cellpadding="0" class="calendarTable calendarTableFuture">
				<tr class="calendarWeekdayHeaders">
					<td width="12%">Su</td>
					<td width="15%">M</td>
					<td width="15%">T</td>
					<td width="15%">W</td>
					<td width="15%">Th</td>
					<td width="15%">F</td>
					<td width="13%">S</td>
				</tr>
				<tr class="calendarRow">
				<%
					daysinmonth = datepart("d", dateadd("d", -1, month(dateadd("m", 1, thismonth)) & "/1/" & y))
					firstday = Weekday(thismonth)

					for i = 1 to 42
						d = i - firstday + 1
						cellDisplayClass = "calendarDay"
						textDisplayClass = "dateString"
						if (i >= firstday and d <= daysinmonth) then
							if (today = dateserial(y, m, d)) then
								cellDisplayClass = cellDisplayClass & " calendarDayToday"
								textDisplayClass = textDisplayClass & " dateStringToday"
							end if
							
							if UCase(Left(WeekdayName(Weekday(dateserial(y, m, d), 1), false, 1), 1)) = "S" then
								cellDisplayClass = "calendarDayWeekend"
							end if
							
							SQLStr = "sp_shopping_order_statushistory_by_orderID " & Order_ID & ", '" & CDate(DateSerial(y, m, d)) & "', 0, 0"
							objRec.Open SQLStr, objConn, adOpenForwardOnly, adLockReadOnly, adCmdText
							if not objRec.EOF then
								textDisplayClass = textDisplayClass & " eventPresent"

								strOut = ""
								beginStatus = SmartValues(objRec("Status_Name_BEFOREUPDATE"), "CStr")
								endStatus = SmartValues(objRec("Status_Name_AFTERUPDATE"), "CStr")
								updateUserName = SmartValues(objRec("Update_UserName"), "CStr")
						
								if Len(beginStatus) > 0 and beginStatus <> "NA" then
									strOut = "Status Changed from " & beginStatus
									if Len(endStatus) > 0 and endStatus <> "NA" then
										strOut = strOut & " to " & endStatus
									end if
									if Len(updateUserName) > 0 and updateUserName <> "NA" then
										strOut = strOut & " by " & updateUserName
									end if
								else
									strOut = "Order " & Order_ID & " Created"
								end if
					%>
					<td align="center" valign=top class="<%=cellDisplayClass%>">
						<div class="<%=textDisplayClass%>"><a href="order_details_info_calendar.asp?m=<%=m%>&y=<%=y%>&oid=<%=Request("oid")%>" target="CurrentCalendarFrame" title="<%=strOut%>" class="eventPresent"><%=d%></a></div>
					</td>
					<%
							else
					%>
					<td align="center" valign=top class="<%=cellDisplayClass%>">
						<div class="<%=textDisplayClass%>"><%=d%></div>
					</td>
					<%
							end if
							objRec.Close
						else
					%>
					<td align="center" valign=top class="calendarDayDisabled">&nbsp;</td>
					<%
						end if
						if i < 36 then
							if (i mod 7 = 0) then response.write "</tr><tr class=""calendarRow"">"
						end if
					next
				%>
				</tr>
			</table>
		</td>
	</tr>
</table>

</body>
</html>
<%
Call DB_CleanUp
Sub DB_CleanUp
	'---- ObjectStateEnum Values ----
'	Const adStateClosed = &H00000000
'	Const adStateOpen = &H00000001
'	Const adStateConnecting = &H00000002
'	Const adStateExecuting = &H00000004
'	Const adStateFetching = &H00000008

	if objRec.State <> adStateClosed then
		On Error Resume Next
		objRec.Close
	end if
	if objConn.State <> adStateClosed then
		On Error Resume Next
		objConn.Close
	end if
	Set objRec = Nothing
	Set objConn = Nothing
End Sub

%>