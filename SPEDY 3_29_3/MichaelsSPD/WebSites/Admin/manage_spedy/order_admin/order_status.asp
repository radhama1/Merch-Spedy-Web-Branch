<%@ LANGUAGE=VBSCRIPT%>
<%
Option Explicit
Response.Buffer = True
Response.Expires = -1441
%>
<!--#include file="./../../app_include/SmartValues.asp"-->
<!--#include file="./../../app_include/checkQueryID.asp"-->
<!--#include file="./../../app_include/bo_classes.asp"-->
<!--#include file="./../../app_include/dal_classes.asp"-->
<!--#include file="./../../app_include/dal_cls_UtilityLibrary.asp"-->
<!--#include file="./../../app_include/AuthorizeCC_AuthorizeNet.asp"-->
<%
Dim objConn, objRec, SQLStr, connStr, objCmd, objParam
Dim Order_ID, currentStatus
Dim gatewayResult, newStatus, summaryString

Dim ActivityLog, ActivityType, ActivityReferenceType
Dim lastIdentity

Set objConn = Server.CreateObject("ADODB.Connection")
Set objRec = Server.CreateObject("ADODB.RecordSet")
Set objCmd = Server.CreateObject("ADODB.Command")
connStr = Application.Value("connStr")
objConn.Open connStr

Order_ID = checkQueryID(Request("oid"), 0)

if Request.Form.Count > 0 and len(Request("chosenStatus")) > 0 then
	newStatus = CInt(checkQueryID(Request("chosenStatus"), 1))
	Response.Write "newStatus: " & newStatus & "<br>"
	gatewayResult = 1
	if newStatus = 3 then
		gatewayResult = AuthorizeCC_AuthorizeNet(Order_ID, "VOID")
	elseif newstatus = 5 then
		gatewayResult = AuthorizeCC_AuthorizeNet(Order_ID, "PRIOR_AUTH_CAPTURE")
	end if
	summaryString = "Status changed to " & newStatus & " for order " & Order_ID
	if newStatus = 3 or newStatus = 5 then
		if gatewayResult <> 1 then
			summaryString = summaryString & " -- GATEWAY ERROR: " & AuthorizeCC_AuthorizeNet_Response
		ELSE
			summaryString = summaryString & " -- GATEWAY SUCCESS: " & AuthorizeCC_AuthorizeNet_Response
		end if
	end if
	Response.Write "summaryString: " & summaryString & "<br>"
	
	SQLStr = "sp_shopping_order_updatestatus " & Order_ID & ", " & CInt(checkQueryID(Request("chosenStatus"), 1)) & ", " & CInt(checkQueryID(Session.Value("UserID"), 0))
	Response.Write SQLStr & "<br>"
	Set objRec = objConn.Execute(SQLStr)

	Call DB_CleanUp
	
	' activity objects
	Set ActivityLog				= New cls_ActivityLog
	Set ActivityType			= New cls_ActivityType
	Set ActivityReferenceType	= New cls_ActivityReferenceType		
	' save activity
	ActivityLog.Activity_User_ID = Session.Value("UserID")
	ActivityLog.Reference_Type = ActivityReferenceType.Order_Status
	ActivityLog.Reference_ID = Order_ID
	ActivityLog.Activity_Type = ActivityType.Create_ID
	ActivityLog.Activity_Summary = summaryString
	ActivityLog.Save
	' clean up activity objects
	Set ActivityLog				= Nothing
	Set ActivityType			= Nothing
	Set ActivityReferenceType	= Nothing
	
	Response.Redirect "order_status_result.asp"
	Response.End

else

	SQLStr = "SELECT Order_Status_ID FROM Shopping_Order WHERE ID = " & Order_ID
	objRec.Open SQLStr, objConn, adOpenKeyset, adLockOptimistic, adCmdText
	Set objRec = objConn.Execute(SQLStr)
	if not objRec.EOF then
		if IsNumeric(objRec(0)) then
			currentStatus = CInt(objRec(0))
		else
			currentStatus = 0
		end if
	end if
	objRec.Close

end if

%>
<html>
<head>
	<title>Modify Order Status</title>
<script language="javascript" type="text/javascript" src="../../app_include/global.js"></script>
<script language="javascript" type="text/javascript">
<!--
function checkForm()
{
	var val, displaytext, msg;
	var obj = MM_findObj("chosenStatus");
	if (!isElementSelected(obj))
	{
		alert('Please select a new status.');
		return false;
	}
	else
	{
		val = obj.options[obj.selectedIndex].value;
		displaytext = obj.options[obj.selectedIndex].text;
		if(val=="3" || val=="5" || val=="6" || val=="7")
		{
			msg = 'Changing the order status to "' + displaytext + '" cannot be undone.  Proceed?';
			if(!confirm(msg))
				return false;
		}
	}
	return true;
}

function isElementSelected(element)
{
	var s = new String();
	s = element.options[element.selectedIndex].value;
	if(element.selectedIndex == -1 || s == null || s.length == 0)
		return false;
	else
		return true;
}
//-->
</script>
</head>
<body bgcolor="cccccc" topmargin=10 leftmargin=10 marginheight=10 marginwidth=10 onLoad="document.theForm.chosenStatus.focus()">

<table cellpadding=0 cellspacing=0 border=0 style="width: 100%;">
	<form id="theForm" name="theForm" action="order_status.asp" method="POST" onsubmit="return checkForm();">
	<tr>
		<td colspan=2>
			<font style="font-family:Arial, Verdana, Geneva, Helvetica;font-size:11px;color:#000000">
			<%if currentStatus = 3 or currentStatus = 5 or currentStatus = 6 or currentStatus = 7 then%>
			<b>Current Status</b>
			<%else%>
			<b>Choose a New Status</b>
			<%end if%>
			</font>
		</td>
	</tr>
	<tr>
		<td colspan=2>
		<%
		if currentStatus = 3 or currentStatus = 5 or currentStatus = 6 or currentStatus = 7 then
			Response.Write "The order status is set to &quot;"
			SQLStr = "select Status_Name from Shopping_Order_Status where [ID] = " & currentStatus
			objRec.Open SQLStr, objConn, adOpenForwardOnly, adLockReadOnly
			if not objRec.EOF then
				Response.Write objRec("Status_Name")
			else
				select case currentStatus
					case 3
						Response.Write "Cancelled"
					case 5
						Response.Write "Complete"
					case 6
						Response.Write "Card Declined"
					case 7
						Response.Write "Order Error"
				end select
			end if
			objRec.Close
			Response.Write "&quot;, and cannot be changed."
		else
		
		SQLStr = "SELECT * FROM Shopping_Order_Status WHERE Display = 1 ORDER BY SortOrder, Status_Name"
		objRec.Open SQLStr, objConn, adOpenKeyset, adLockReadOnly, adCmdText
		if not objRec.EOF then
			
		%>
			<select id="chosenStatus" name="chosenStatus" style="width: 260px;">
				<option value="">-- Select --</option>
			<%
			Do until objRec.EOF
			%>
				<option value="<%=objRec("ID")%>"<%if currentStatus = CInt(objRec("ID")) then Response.Write " SELECTED"%>><%=objRec("Status_Name")%></option>
			<%
				objRec.MoveNext
			Loop
			%>
			</select>
		<%
		end if
		objRec.Close
		
		end if
		%>
		</td>
	</tr>
	<tr><td colspan=2><img src="../images/spacer.gif" height=20 width=1 border=0></td></tr>
	<tr>
		<td colspan=2 align=right>
			<%if currentStatus = 3 or currentStatus = 5 or currentStatus = 6 or currentStatus = 7 then%>
			<table cellpadding=0 cellspacing=0 border=0>
				<tr width="100%">
					<td><input type=button name="doSubmit" value=" Close " onClick="self.close();"></td>
					<td width=100%><img src="../images/spacer.gif" height=1 width=5 border=0></td>
					<td>&nbsp;</td>
				</tr>
			</table>
			<%else%>
			<table cellpadding=0 cellspacing=0 border=0>
				<tr width="100%">
					<td><input type=button name="doSubmit" value=" Cancel " onClick="self.close();"></td>
					<td width=100%><img src="../images/spacer.gif" height=1 width=5 border=0></td>
					<td><input type=submit name="doSubmit" value=" Save "></td>
				</tr>
			</table>
			<%end if%>
		</td>
	</tr>
	<input type="hidden" name="oid" value="<%=Order_ID%>">
	</form>
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