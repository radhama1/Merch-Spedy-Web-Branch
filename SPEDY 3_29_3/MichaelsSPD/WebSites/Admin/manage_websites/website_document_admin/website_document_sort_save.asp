<%@ LANGUAGE=VBSCRIPT%>
<%
'==============================================================================
' Author: Ken Wallace, Principal - Ken Wallace Design
'==============================================================================
Option Explicit
Response.Buffer = True
Response.Expires = -1441
%>
<!--#include file="../../app_include/smartValues.asp"-->
<%
Dim objConn, objRec, SQLStr, connStr, i
Dim parentCategoryID, sortedItems, arSortedItems, thisItem

Set objConn = Server.CreateObject("ADODB.Connection")
Set objRec = Server.CreateObject("ADODB.RecordSet")

connStr = Application.Value("connStr")
objConn.Open connStr

parentCategoryID = Trim(Request.Form("pcid"))
if IsNumeric(parentCategoryID) then
	parentCategoryID = CInt(parentCategoryID)
else
	parentCategoryID = 0
end if

sortedItems = Trim(Request.Form("sortedList"))
if Len(sortedItems) > 0 then
	sortedItems = CStr(sortedItems)
else
	sortedItems = ""
end if
Response.Write "sortedItems: " & sortedItems & "<br>" & vbCrLf
arSortedItems = Split(sortedItems, ",")

objConn.BeginTrans

i = 0
for each thisItem in arSortedItems
	if IsNumeric(thisItem) then
		if thisItem > 0 then
			SQLStr = "SELECT SortOrder FROM Website_Element_Data WHERE [ID] = '0" & thisItem & "'"
			objRec.Open SQLStr, objConn, adOpenKeyset, adLockBatchOptimistic, adCmdText
			if not objRec.EOF then
				objRec("SortOrder") = Right("00000" & i, 5)
				objRec.UpdateBatch
				i = i + 1
			end if
			objRec.Close
		end if
	end if
next

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
