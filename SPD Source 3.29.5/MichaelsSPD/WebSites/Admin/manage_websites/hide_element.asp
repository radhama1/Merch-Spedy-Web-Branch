<%@ LANGUAGE=VBSCRIPT%>
<%
'==============================================================================
' Author: Ken Wallace, Principal - Ken Wallace Design
'==============================================================================
Option Explicit
%>
<!--#include file="./../app_include/_globalInclude.asp"-->
<%
Response.Buffer = True
Response.Expires = -1441

Dim objConn, connStr
Dim objRec, objRec2, SQLStr
Dim elementID, intPromoDirection, boolPromoteChildren

elementID = Request("tid")
if IsNumeric(elementID) then
	elementID = CInt(elementID)
else
%>
<script language="javascript">
	parent.window.close();
</script>
<%
end if

intPromoDirection = Request("promoswitch")
if IsNumeric(intPromoDirection) then
	intPromoDirection = CInt(intPromoDirection)
else
	intPromoDirection = 0
end if

Set objConn = Server.CreateObject("ADODB.Connection")
Set objRec = Server.CreateObject("ADODB.RecordSet")
connStr = Application.Value("connStr")
objConn.Open connStr

Dim newNavString
SQLStr = "sp_websites_admin_climbladder " & elementID & ", " & CInt(Session.Value("websiteID")) & ", 1"
Set objRec = objConn.Execute(SQLStr)
if not objRec.EOF then
	if not IsNull(objRec(0)) then
		newNavString = Trim(objRec(0))
	end if
end if
objRec.Close

if Request.Form.Count > 0 then
	boolPromoteChildren = Request.Form("chkIncludeChildren")
	
	if IsNumeric(boolPromoteChildren) then
		boolPromoteChildren = CBool(boolPromoteChildren)
	else
		boolPromoteChildren = false
	end if
	
	promoteTree elementID, true
%>
<script language="javascript">
	var myFrameSetRef = new Object(parent.window.opener.parent.parent.frames['DetailFrameWrapper'].frames['DetailFrame']);
	if (typeof(myFrameSetRef == 'object'))
	{
		myFrameSetRef.document.location = "./website_details.asp?open=<%=newNavString%>";
	}
	
	//we're all done, so leave...
//	parent.window.close();
</script>
<%
end if


Function promoteTree(byval thisID, byval boolIsTopLevel)
	''''''''''''''''''''''
	' Declare our Objects and Variables here
	'''''''''''''''''''''
	Dim thisObjRec, thisObjRec2
	Set thisObjRec = Server.CreateObject("ADODB.RecordSet")
	Set thisObjRec2 = Server.CreateObject("ADODB.RecordSet")

	if boolIsTopLevel then
	'	SQLStr = "UPDATE Website_Element_Data SET DisplayInSearchResults = 0 WHERE Element_ID = " & CInt(thisObjRec("Element_ID"))
		Response.Write SQLStr
		Set thisObjRec = objConn.Execute(SQLStr)
		thisObjRec.Close
	end if

'	if boolPromoteChildren then
		SQLStr = "sp_websites_return_website_contents " & Session.Value("websiteID") & ", " & thisID
		thisObjRec.Open SQLStr, objConn, adOpenStatic, adLockReadOnly, adCmdText
			
		if not thisObjRec.EOF then
			Do Until thisObjRec.EOF
	
				SQLStr = "UPDATE Website_Element_Data SET DisplayInSearchResults = 0 WHERE Element_ID = " & CInt(thisObjRec("Element_ID"))
				Set thisObjRec2 = objConn.Execute(SQLStr)

				if boolPromoteChildren and CBool(thisObjRec("boolHasChildren")) then
					Dim newID
					newID = CInt(thisObjRec("Element_ID"))
					Call promoteTree(newID, false)
				end if
				
				thisObjRec.MoveNext
			Loop
		end if
		thisObjRec.Close
'	end if

	Set thisObjRec = nothing
	Set thisObjRec2 = nothing
End Function



%>
<html>
<head>
	<title>Hide From Search Results</title>
</head>
<body bgcolor="cccccc" topmargin=5 leftmargin=5 marginheight=5 marginwidth=5>

<form name="theForm" action="hide_element.asp" method=POST>
<table width=100% cellpadding=0 cellspacing=0 border=0>
	<tr>
		<td>
			<font style="font-family:Arial, Helvetica;font-size:16px;color:#000000">
			<b>Hide From Search Results</b>
			</font>
		</td>
	</tr>
	<tr>
		<td>
			<font style="font-family:Arial, Helvetica;font-size:12px;color:#000000">
			This action will remove the selected item from the Search Results.
			</font>
		</td>
	</tr>
	<tr><td><img src="./images/spacer.gif" height=10 width=1></td></tr>
	<tr>
		<td align=right>
			<table width=100% cellpadding=0 cellspacing=0 border=0>
				<tr>
					<td><input type=checkbox name="chkIncludeChildren" value="1"></td>
					<td><img src="./../images/spacer.gif" height=1 width=5 border=0></td>
					<td nowrap>
						<font style="font-family:Arial, Helvetica;font-size:12px;color:#000000">
						<a href="javascript: void(0); document.theForm.chkIncludeChildren.click();" style="color:#000000;text-decoration:none;">Hide all child elements</a>
						</font>
					</td>
					<td width=100%><img src="./../images/spacer.gif" height=1 width=5 border=0></td>
				</tr>
			</table>
		</td>
	</tr>
	<tr><td><img src="./images/spacer.gif" height=10 width=1></td></tr>
	<tr>
		<td align=right>
			<table width=100% cellpadding=0 cellspacing=0 border=0>
				<tr>
					<td><input type=button name="btnCancel" value="Cancel" onClick="javascript: void(0); parent.window.close();"></td>
					<td width=100%><img src="./../images/spacer.gif" height=1 width=5 border=0></td>
					<td align=right><input type=submit name="btnCommit" value="    OK    "></td>
				</tr>
			</table>
		</td>
	</tr>
</table>
<input type=hidden name="tid" value="<%=Request("tid")%>">
</form>

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