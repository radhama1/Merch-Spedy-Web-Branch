<%@ LANGUAGE=VBSCRIPT%>
<%
'==============================================================================
' Author: Ken Wallace, Principal - Ken Wallace Design
'==============================================================================
Option Explicit
%>
<!--#include file="./../../app_include/_globalInclude.asp"-->
<%
Response.Buffer = True
Response.Expires = -1441

Dim objRec, objConn, SQLStr, connStr
Dim thisElementID, thisElementType
Dim strNavTrail, websiteName

Set objConn = Server.CreateObject("ADODB.Connection")
Set objRec = Server.CreateObject("ADODB.RecordSet")
connStr = Application.Value("connStr")
objConn.Open connStr

thisElementType = Trim(Request("itemType"))

thisElementID = Request("itemID")
if IsNumeric(thisElementID) then
	thisElementID = CInt(thisElementID)
else
	thisElementID = 0
end if

Dim strFamilyList, arFamilyList

SQLStr = "sp_websites_admin_climbladder " & thisElementID & ", " & Session.Value("websiteID") & ", 1"
Set objRec = objConn.Execute(SQLStr)
if not objRec.EOF then
	if not IsNull(objRec(0)) then
		strFamilyList = objRec(0)
	end if
end if
objRec.Close
arFamilyList = Split(strFamilyList, ",")

SQLStr = "SELECT COALESCE(Website_Name, 'Website') FROM Website WHERE [ID] = " & Session.Value("websiteID")
Set objRec = objConn.Execute(SQLStr)
if not objRec.EOF then
	websiteName = objRec(0)
else
	websiteName = "Website"
end if
objRec.Close

function buildNavTrail(myEntityID)
	Dim bElementID, bElementTitle
	Dim tempNavTrail, objRec2
	Set objRec2 = Server.CreateObject("ADODB.RecordSet")

	SQLStr = "sp_websites_return_website_contents " & Session.Value("websiteID") & ", " & myEntityID
	objRec2.Open SQLStr, objConn, adOpenStatic, adLockReadOnly, adCmdText
	if not objRec2.EOF then
		Do Until objRec2.EOF
			bElementID = CInt(objRec2("Element_ID"))
			bElementTitle = objRec2("Element_FullTitle")

			if CBool(findNeedleInHayStack(arFamilyList, bElementID, "true")) then
				if thisElementID = bElementID then
					tempNavTrail = bElementTitle
				else
					tempNavTrail = bElementTitle & "&gt;" & buildNavTrail(bElementID)
				end if
			end if
			objRec2.MoveNext
		Loop					
	end if
	objRec2.Close
	Set objRec2 = Nothing

	buildNavTrail = tempNavTrail
end function

strNavTrail = Trim(websiteName & "&gt;" & buildNavTrail(0))
if Right(strNavTrail, 4) = "&gt;" then
	strNavTrail = Left(strNavTrail, Len(strNavTrail) - 4)
end if
%>
<html>
<head>
	<title>Select Documents</title>
	<style type="text/css">
	<!--
		A {text-decoration: none;}
	//-->
	</style>
	<script language=javascript>
	<!--
		window.defaultStatus = "Select Documents"
	//-->
	</script>
</head>
<body bgcolor="cccccc" link=0000ff vlink=0000ff topmargin=0 leftmargin=0 marginheight=0 marginwidth=0>
<table width=100% cellpadding=0 cellspacing=0 border=0 align=center>
	<tr>
		<td><img src="./../images/spacer.gif" height=1 width=5 border=0></td>
		<td>
			<table width=100% cellpadding=0 cellspacing=0 border=0>
				<tr>
					<td>
						<font style="font-family:Arial, Helvetica;font-size:12px;color:#000000">
						<b>Select Documents</b>
						</font>
					</td>
				</tr>
				<tr>
					<td>
						<font style="font-family:Arial, Helvetica;font-size:11px;color:#000000">
						Destination: <b style="color:#666666"><%=Replace(strNavTrail, "&gt;", "&nbsp;&gt;&nbsp;")%></b>
						</font>
					</td>
				</tr>
			</table>
		</td>
		<td><img src="./../images/spacer.gif" height=1 width=5 border=0></td>
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