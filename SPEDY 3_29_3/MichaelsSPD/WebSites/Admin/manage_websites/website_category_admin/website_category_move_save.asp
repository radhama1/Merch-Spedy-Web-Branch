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

Dim objConn, objRec, SQLStr, connStr
Dim categoryID, targetID

categoryID = Request.Form("categoryID")
if IsNumeric(categoryID) then
	categoryID = CInt(categoryID)
else
	Response.Redirect Trim(Request.ServerVariables("HTTP_REFERER"))
end if

targetID = Request.Form("targetID")
if IsNumeric(targetID) then
	targetID = CInt(targetID)
else
	targetID = 0
end if

if CInt(categoryID) = CInt(targetID) then
	Response.Redirect Trim(Request.ServerVariables("HTTP_REFERER"))
end if

Set objConn = Server.CreateObject("ADODB.Connection")
Set objRec = Server.CreateObject("ADODB.RecordSet")

connStr = Application.Value("connStr")
objConn.Open connStr

objConn.BeginTrans

SQLStr = "UPDATE Website_Category SET Parent_Category_ID = " & targetID & " WHERE Website_ID = " & Session.Value("websiteID") & " AND ID = " & categoryID
Set objRec = objConn.Execute(SQLStr)

if objConn.Errors.Count < 1 and Err.number < 1 then
	objConn.CommitTrans
else
	objConn.RollbackTrans
end if

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
<script language="javascript">
	//Set a reference to the Details frame in the Repository frameset...
	var myFrameSetRef = new Object(parent.window.opener.parent.parent.frames['DetailFrameWrapper'].frames['DetailFrame']);
	
	//If the user hasnt left the repository framset, then refresh the details screen, otherwise dont worry bout it...
	if (typeof(myFrameSetRef == 'object'))
	{
		myFrameSetRef.document.location.reload();
	}
	
	//we're all done, so leave...
	parent.window.close();
</script>
