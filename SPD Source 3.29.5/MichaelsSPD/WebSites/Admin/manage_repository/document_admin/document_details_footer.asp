<%@ LANGUAGE=VBSCRIPT%>
<%
'==============================================================================
' Author: Ken Wallace, Principal - Ken Wallace Design
'==============================================================================
Option Explicit
Response.Buffer = True
Response.Expires = -1441
%>
<!--#include file="./../../app_include/_globalInclude.asp"-->
<%
Dim Security
Set Security = New cls_Security
Security.Initialize Session.Value("UserID"), "ADMIN.CONTENT.REPOSITORY.DOCUMENTS", 0

Dim boolIsNewDocument
Dim categoryID, topicID, chosenStatus
Dim objConn, objRec, SQLStr, connStr
Dim boolIsPublishedItemCopy

categoryID = Request("cid")
if IsNumeric(categoryID) then
	categoryID = CInt(categoryID)
else
	categoryID = 0
end if

topicID = Request("tid")
if IsNumeric(topicID) then
	topicID = CInt(topicID)
else
	topicID = 0
end if

boolIsNewDocument = false
if topicID = 0 then
	boolIsNewDocument = true
end if

boolIsPublishedItemCopy = Trim(Request("pub"))
if IsNumeric(boolIsPublishedItemCopy) then
	boolIsPublishedItemCopy = CBool(boolIsPublishedItemCopy)
else
	boolIsPublishedItemCopy = false
end if

Set objConn = Server.CreateObject("ADODB.Connection")
Set objRec = Server.CreateObject("ADODB.RecordSet")
connStr = Application.Value("connStr")
objConn.Open connStr

chosenStatus = 0
if not boolIsNewDocument then
	SQLStr = "SELECT Status_ID FROM Repository_Topic WHERE ID = " & topicID
	Set objRec = objConn.Execute(SQLStr)
	chosenStatus = objRec(0)
	objRec.Close
end if
%>
<html>
<head>
	<title>Move Item</title>
	<style type="text/css">

		A {text-decoration: none;}

	</style>
	<script language=javascript>

		function doCancel()
		{
		<% if boolIsNewDocument or boolIsPublishedItemCopy then%>
			if (confirm("Really discard this document?"))
			{
				parent.window.close();
			}
		<%else%>
			if (confirm("Really discard your changes?"))
			{
			//	doLockPrompt();
				parent.window.close();
			}
		<%end if%>
			parent.frames["calcFrame"].document.location = "document_details_toggle_lock.asp?tid=<%=topicID%>&lock=0";
		}

		function updateStatus()
		{
		<% if boolIsNewDocument or boolIsPublishedItemCopy then%>
			var chosenStatus = document.theForm.chosenStatus.value;
			parent.frames["body"].document.theForm.NewDocumentStatus.value = chosenStatus;
		<%else%>
			var chosenStatus = document.theForm.chosenStatus.value;
			parent.frames["calcFrame"].document.location = "document_details_statuschange.asp?tid=<%=topicID%>&chosenStatus=" + chosenStatus;
		//	reloadParentFrame();
		<%end if%>
		}
		
		function keepLocked()
		{
			switch (document.theForm.keeplocked.value)
			{
				case "3":
					if(confirm("You have chosen to publish this document\nto both the STAGING and LIVE websites.\n\nAre you really sure?"))
					{
						parent.frames["body"].document.theForm.keeplocked.value = document.theForm.keeplocked.value;
					}
					else
					{
						document.theForm.keeplocked.selectedIndex = 0;						
						parent.frames["body"].document.theForm.keeplocked.value = document.theForm.keeplocked.value;
					}
					break;
				default:
					parent.frames["body"].document.theForm.keeplocked.value = document.theForm.keeplocked.value;
			}
		}
		
				
		function doLockPrompt()
		{
			<%if not boolIsNewDocument and not boolIsPublishedItemCopy and 1 = 2 then%>
			var msg = "This document is currently locked for your exclusive\nuse.  Would you like to unlock this document?  ";
			msg = msg + "\n\nA document is automatically locked for exclusive use\nwhen it is edited.  ";
			msg = msg + "Other users cannot edit this\ndocument while it remains locked.";
			msg = msg + "\n";
			msg = msg + "\nClick 'OK' to UNLOCK this document";
			msg = msg + "\nClick 'Cancel' to leave document locked";

			if (confirm(msg))
			{
				parent.frames["calcFrame"].document.location = "document_details_toggle_lock.asp?tid=<%=topicID%>&lock=0";
			//	reloadParentFrame();
			}
			<%end if%>
		}
		
		function doCommit()
		{
		//	doLockPrompt();
			parent.frames['body'].saveChanges(); 
			parent.frames['body'].document.theForm.submit();
		}
		
		function saveOnly()
		{
			if (confirm("Really apply these changes?\n\nThis cannot be undone."))
			{
				parent.frames['body'].saveChanges();
				
				//modify the body forms target to go to the hidden frame and not close when finished
				parent.frames['body'].document.theForm.action = "document_details_work_noclose.asp";
				parent.frames['body'].document.theForm.target = "calcFrame";
				parent.frames['body'].document.theForm.submit();

				//put everything back the way we found it...
				parent.frames['body'].document.theForm.target = "body";
				parent.frames['body'].document.theForm.action = "document_details_work.asp";
				alert("Your changes have been saved.");
			}
			else
			{
				alert("Nothing was saved.");
			}
		}
		
		function reloadParentFrame()
		{
			//Set a reference to the Details frame in the Repository frameset...
			var myFrameSetRef = new Object(parent.window.opener.parent.parent.frames['DetailFrameWrapper'].frames['DetailFrame']);
	
			//If the user hasnt left the repository framset, then refresh the details screen, otherwise dont worry bout it...
			if (typeof(myFrameSetRef == 'object'))
			{
				myFrameSetRef.document.location.reload();
			}
		}

	</script>
</head>
<body bgcolor="cccccc" link=0000ff vlink=0000ff topmargin=0 leftmargin=0 marginheight=0 marginwidth=0>
<table width=100% cellpadding=0 cellspacing=0 border=0 align=center>
	<form name=theForm action="" method=POST>
	<tr><td colspan=3><img src="./../images/spacer.gif" height=3 width=1 border=0></td></tr>
	<tr>
		<td><img src="./../images/spacer.gif" height=1 width=5 border=0></td>
		<td>
			<table width=100% cellpadding=0 cellspacing=0 border=0>
				<tr>
					<td>
						<table cellpadding=0 cellspacing=0 border=0 align=center>
							<tr>
								<td>
								<%
								SQLStr = "SELECT * FROM Repository_Status WHERE Display = 1 ORDER BY SortOrder, Status_Name"
								objRec.Open SQLStr, objConn, adOpenKeyset, adLockReadOnly, adCmdText
								if not objRec.EOF then
								%>
									<select name="chosenStatus" onChange="javascript: void(0); updateStatus();" style="width: 180px;">
										<option value="0"<%if chosenStatus = 0 then Response.Write " SELECTED" end if%>>No Status Set</option>
									<%
									Do until objRec.EOF
									%>
										<option value="<%=objRec("ID")%>"<%if chosenStatus = objRec("ID") then Response.Write " SELECTED" end if%>><%=objRec("Status_Name")%></option>
									<%
										objRec.MoveNext
									Loop
									%>
									</select>
								<%
								end if
								objRec.Close
								%>
								</td>
							</tr>
						</table>
					</td>
					<td><img src="./../images/spacer.gif" height=1 width=5 border=0></td>
					<td bgcolor="#999999"><img src="./../images/spacer.gif" height=1 width=1 border=0></td>
					<td bgcolor="#ececec"><img src="./../images/spacer.gif" height=1 width=1 border=0></td>
					<td><img src="./../images/spacer.gif" height=1 width=1 border=0></td>
					<td width=100%><img src="./../images/spacer.gif" height=1 width=1 border=0></td>
					<td>
						<select name="keeplocked" onChange="javascript: void(0); keepLocked()" ID="keeplocked" style="width: 360px;">
							<option value="0">When I close, unlock this document.</option>
							<option value="1">Keep this document locked.</option>
							<%if Security.isRequestedPrivilegeAllowed("ADMIN.CONTENT.REPOSITORY.DOCUMENTS", "PUBLISH.STAGING") then%>
							<option value="2">Unlock and publish this document to the Staging website.</option>
							<%end if%>
							<%if Security.isRequestedPrivilegeAllowed("ADMIN.CONTENT.REPOSITORY.DOCUMENTS", "PUBLISH.LIVE") then%>
							<option value="3">Unlock and publish this document to the Live website.</option>
							<%end if%>
						</select>
					</td>
					<td><img src="./../images/spacer.gif" height=1 width=5 border=0></td>
					<td><input type=button name="btnCancel" value="Cancel" onClick="javascript: void(0); doCancel();"></td>
					<td><img src="./../images/spacer.gif" height=1 width=5 border=0></td>
					<!--
					<td><input type=button name="doSubmit1" value=" Save " onClick="javascript: void(0); saveOnly();"></td>
					<td><img src="./../images/spacer.gif" height=1 width=5 border=0></td>
					-->
					<td><input type=button name="doSubmit2" value=" Save & Close " onClick="javascript: void(0); doCommit();"></td>
				</tr>
			</table>
		</td>
		<td><img src="./../images/spacer.gif" height=1 width=5 border=0></td>
	</tr>
	<tr><td colspan=2><img src="../images/spacer.gif" height=5 border=0></td></tr>
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