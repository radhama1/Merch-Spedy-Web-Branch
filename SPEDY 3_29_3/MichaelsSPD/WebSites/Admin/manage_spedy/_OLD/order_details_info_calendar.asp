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
Dim f, today, m, y, d, i, firstday, daysinmonth, thismonth, SCRIPT
Dim cellDisplayClass, textDisplayClass
Dim strOut, beginStatus, endStatus, updateUserName

Dim Order_ID
Order_ID = CInt(checkQueryID(Request("oid"), 0))

SCRIPT = request.servervariables("script_name")
f = request("f")
today = date()

m = request("m")
y = request("y")

if m = "" and Session.Value("ORDER_DETAILS_ACTIVITYCALENDAR_SELECTEDMONTH") = "" then 
	m = Month(today)
elseif m = "" and Session.Value("ORDER_DETAILS_ACTIVITYCALENDAR_SELECTEDMONTH") <> "" then
	m = Month(Session.Value("ORDER_DETAILS_ACTIVITYCALENDAR_SELECTEDMONTH"))
end if

if y = "" and Session.Value("ORDER_DETAILS_ACTIVITYCALENDAR_SELECTEDMONTH") = "" then 
	y = Year(today)
elseif y = "" and Session.Value("ORDER_DETAILS_ACTIVITYCALENDAR_SELECTEDMONTH") <> "" then
	y = Year(Session.Value("ORDER_DETAILS_ACTIVITYCALENDAR_SELECTEDMONTH"))
end if

thismonth = dateserial(y, m, 1)

Session.Value("ORDER_DETAILS_ACTIVITYCALENDAR_SELECTEDMONTH") = thismonth

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

		.calendarTable
		{
			background-color: #fff;
			border-right: 1px solid #ccc;
		}
		.calendarRow TD
		{
			height: 20%;
		}

		.calendarHeader
		{
			font-family: Arial, Helvetica, Sans-Serif;
			font-size: 11px;
			font-weight: bold;
			color: #000;
			background-color: #cccccc;
		}
		
		.currentDateLabel
		{
			font-family: Arial, Helvetica, Sans-Serif;
			font-size: 16px;
			font-weight: bold;
			color: #000;
			background-color: #cccccc;
		}

		.calendarWeekdayHeaders
		{
			font-family: Arial, Helvetica, Sans-Serif;
			font-size: 11px;
			font-weight: bold;
			line-height: 14px;
			color: #fff;
			background-color: #999;
			text-align: center;
		}

		.calendarDayToday
		{
			font-family: Arial, Helvetica, Sans-Serif;
			font-size: 11px;
			color: #000;
			background-color: #ffd;
			border-left: 1px solid #ccc;
			border-bottom: 1px solid #ccc;
		}

		.calendarDay
		{
			font-family: Arial, Helvetica, Sans-Serif;
			font-size: 11px;
			color: #000;
			background-color: #fff;
			border-left: 1px solid #ccc;
			border-bottom: 1px solid #ccc;
		}
		.calendarDayWeekend
		{
			font-family: Arial, Helvetica, Sans-Serif;
			font-size: 11px;
			color: #000;
			background-color: #e6e6e6;
			border-left: 1px solid #ccc;
			border-bottom: 1px solid #ccc;
		}
		
		.calendarDayDisabled
		{
			color: #fff;
			background-color: #ececec;
			border-left: 1px solid #ccc;
			border-bottom: 1px solid #ccc;
		}
		
		.dateString
		{
			float: right;
			text-align: right;
			width: 25px;
			height: 20px;
			padding-top: 2px;
			padding-right: 5px;
			border-left: 1px solid #ccc;
			border-bottom: 1px solid #ccc;
			background-color: #fff;
		}
		.dateStringToday
		{
			float: right;
			text-align: right;
			width: 25px;
			height: 20px;
			padding-top: 2px;
			padding-right: 5px;
			border-left: 1px solid #999;
			border-bottom: 1px solid #999;
			background-color: #ff9;
		}
		
		.dateEvents
		{
			font-family: Verdana, Arial, Helvetica, Sans-Serif;
			font-size: 9px;
			padding: 2px;
			float: left;
		}
		.dateEvent
		{
			width: 100%;
			float: left;
			padding-bottom: 4px;
			margin-bottom: 2px;
			/* border-top: 1px solid #d9d9ca; */
			/* background: #f4f4e3; */
		}
		.dateEventBullet
		{
			font-family: Verdana, Arial, Helvetica, Sans-Serif;
			font-size: 9px;
			margin-top: 2px;
			margin-left: 1px;
			margin-right: 2px;
			float: left;
		}
		.dateEventText
		{
			font-family: Verdana, Arial, Helvetica, Sans-Serif;
			font-size: 9px;
			float: left;
			text-align: left;
		}
		
	</style>
	<script type="text/javascript" language="javascript">
		function movePrev()
		{
			document.location = "<%= SCRIPT %>?m=<%= month(dateadd("m", -1, thismonth)) %>&y=<%= year(dateadd("m", -1, thismonth)) %>&oid=<%=Order_ID%>";
		}
		function moveNext()
		{
			document.location = "<%= SCRIPT %>?m=<%= month(dateadd("m", 1, thismonth)) %>&y=<%= year(dateadd("m", 1, thismonth)) %>&oid=<%=Order_ID%>";
		}
	</script>
</head>
<body bgcolor="ffffff" topmargin=0 leftmargin=0 marginheight=0 marginwidth=0>

<table width=100% height=100% cellpadding=0 cellspacing=0 border=0>
	<tr>
		<td valign=top>
			<table width="100%" border="0" cellspacing="0" cellpadding="0" class="calendarTable">
				<tr>
					<td colspan=7>
						<table width=100% border="0" cellspacing="0" cellpadding="0" class="calendarHeader">
							<tr>
								<td><img src="./images/spacer.gif" height=1 width=10></td>
								<td class="currentDateLabel"><b><%= monthname(m) %>,&nbsp;<%= y %></b></td>
								<td width=100%><img src="./images/spacer.gif" height=1 width=20></td>
								<form name="theDatePickerForm" action="<%= SCRIPT %>" method=GET>
								<td><nobr><a href="javascript:movePrev();"><img name="prev" src="./../app_images/paging/btn_vcr_prev.gif" border=0 alt="Jump to the previous page"></a><img src="./../app_images/spacer.gif" height=2 width=5></td>
								<td>
									<select name="m" onChange="document.theDatePickerForm.submit()" style="font-size:11px; padding: 0px; margin: 0px;">
										<%
										for i = 1 to 12
										%>
										<option value="<%=i%>"<%if i = Month(thismonth) then Response.Write " SELECTED" end if%>><%=MonthName(i)%>
										<%
										next
										%>
									</select>
								</td>
								<td>
									<select name="y" onChange="document.theDatePickerForm.submit()" style="font-size:11px; padding: 0px; margin: 0px;">
										<%for i = (Year(Now) - 2) to (Year(Now) + 2)%>
										<option value="<%=i%>"<%if i = Year(thismonth) then Response.Write " SELECTED"%>><%=i%>
										<%next%>
									</select>
								</td>
								<td><nobr><img src="./../app_images/spacer.gif" height=2 width=5><a href="javascript:moveNext();"><img name="next" src="./../app_images/paging/btn_vcr_next.gif" border=0 alt="Jump to the next page"></a></td>
								<td><img src="./images/spacer.gif" height=1 width=10></td>
								<input type="hidden" name="oid" value="<%=Order_ID%>">
								</form>
							</tr>
						</table>
					</td>
				</tr>
				<tr class="calendarWeekdayHeaders">
					<td width="12%"><b>Sunday</b></td>
					<td width="15%"><b>Monday</b></td>
					<td width="15%"><b>Tuesday</b></td>
					<td width="15%"><b>Wednesday</b></td>
					<td width="15%"><b>Thursday</b></td>
					<td width="15%"><b>Friday</b></td>
					<td width="13%"><b>Saturday</b></td>
				</tr>
			</table>
		</td>
	</tr>
	<tr>
		<td valign=top height="100%">
			<table width="100%" height="100%" border="0" cellspacing="0" cellpadding="0" class="calendarTable">
				<tr class="calendarRow">
				<%
					daysinmonth = datepart("d", dateadd("d", -1, month(dateadd("m", 1, thismonth)) & "/1/" & y))
					firstday = Weekday(thismonth)

					for i = 1 to 42
						d = i - firstday + 1
						if (i >= firstday and d <= daysinmonth) then
							if (today = dateserial(y, m, d)) then
								cellDisplayClass = "calendarDayToday"
								textDisplayClass = "dateStringToday"
							else
								cellDisplayClass = "calendarDay"
								textDisplayClass = "dateString"
							end if
							
							if UCase(Left(WeekdayName(Weekday(dateserial(y, m, d), 1), false, 1), 1)) = "S" then
								cellDisplayClass = "calendarDayWeekend"
							end if
					%>
					<td align="center" valign=top class="<%=cellDisplayClass%>">
						<div class="<%=textDisplayClass%>"><a href="javascript:void(0);"><%=d%></a></div>
						<div class="dateEvents">
						
							<%
							strOut = ""
							SQLStr = "sp_shopping_order_statushistory_by_orderID " & Order_ID & ", '" & CDate(DateSerial(y, m, d)) & "', 0, 0"
							'Response.Write SQLStr
							objRec.Open SQLStr, objConn, adOpenForwardOnly, adLockReadOnly, adCmdText
							if not objRec.EOF then
							
								Do Until objRec.EOF
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
									<div class="dateEvent"><div class="dateEventBullet"><img src="./../app_images/gotolink.gif"></div><div class="dateEventText"><%=strOut%></div></div>
									<%
									objRec.MoveNext
								Loop
							
							end if
							objRec.Close
							%>
						
						</div>
					</td>
					<%
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
				<tr bgcolor=cccccc>
					<td width="12%"><img src="./images/spacer.gif" height=1 width=1></td>
					<td width="15%"><img src="./images/spacer.gif" height=1 width=1></td>
					<td width="15%"><img src="./images/spacer.gif" height=1 width=1></td>
					<td width="15%"><img src="./images/spacer.gif" height=1 width=1></td>
					<td width="15%"><img src="./images/spacer.gif" height=1 width=1></td>
					<td width="15%"><img src="./images/spacer.gif" height=1 width=1></td>
					<td width="13%"><img src="./images/spacer.gif" height=1 width=1></td>
				</tr>
			</table>
		</td>
	</tr>
</table>

<script language="javascript">
<!--
	parent.frames["CalendarContextFrame"].document.location = "./order_details_info_calendar_context.asp?oid=<%=Request("oid")%>";
//-->
</script>

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