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

Dim objConn, objRec, objRec2, SQLStr, connStr, i, reservedPos, newPos
Dim taxID, questionID, thisParentCatID, parentQuestionID, sortQuestionID
Dim moveDirection, moveReference
Dim reserveSet
Dim ActivityLog, ActivityType, ActivityReferenceType, rs, utils
Dim taxQuestion

taxQuestion = ""
taxID = checkQueryID(Request("tid"), 0)
questionID = checkQueryID(Request("qid"), 0)
sortQuestionID = checkQueryID(Request("sortid"), 0)
parentQuestionID = checkQueryID(Request("newParentID"), 0)

moveDirection = LCase(Trim(Request.Form("moveDirection")))
moveReference = Request.Form("moveReference")
if Trim(moveDirection) = "" then
	if not IsNumeric(moveReference) then
		Response.Redirect Trim(Request.ServerVariables("HTTP_REFERER"))
	else
		moveDirection = "above"
	end if
else
	if not IsNumeric(moveReference) then
		moveReference = questionID
	else
		moveReference = CInt(moveReference)
	end if
end if

'	Response.Write "moveDirection: " & moveDirection & "<br>" & vbCrLf
'	Response.Write "moveReference: " & moveReference & "<br>" & vbCrLf
'	Response.Write "questionID: " & questionID & "<br>" & vbCrLf
'	Response.Write "sortQuestionID: " & sortQuestionID & "<br>" & vbCrLf
'	Response.Write "parentQuestionID: " & parentQuestionID & "<br>" & vbCrLf & "<br>" & vbCrLf & "<br>" & vbCrLf

Set objConn = Server.CreateObject("ADODB.Connection")
Set objRec = Server.CreateObject("ADODB.RecordSet")
Set objRec2 = Server.CreateObject("ADODB.RecordSet")

connStr = Application.Value("connStr")
objConn.Open connStr
objConn.CommandTimeout = 99999

objConn.BeginTrans

if moveDirection = "within" then
	'==============================================================================
	'If I'm nesting the source element beneath some target element,
	'set the source element's Parent_Element_ID to the target element's ID.
	'==============================================================================
	SQLStr = "UPDATE SPD_Tax_Question SET " &_
			" Parent_Tax_Question_ID = '0" & moveReference & "', " &_
			" SortOrder = 'ALPHA', " &_
			" Date_Last_Modified = '" & CDate(Now()) & "' " &_
			" WHERE Parent_Tax_Question_ID = '0" & parentQuestionID & "' AND [ID] = '0" & sortQuestionID & "' "
	'Response.Write SQLStr	
	Set objRec = objConn.Execute(SQLStr)

else
	'==============================================================================
	'If I'm moving the source element above or below some target element...
	'==============================================================================
	i = 1
	reservedPos = 0
	newPos = 0
	reserveSet = false

	'==============================================================================
	' Iterate through everything BUT the selected file, updating positions...
	'==============================================================================
'	SQLStr = "SELECT [Element_ID], [Parent_Element_ID], [Repository_Topic_Details_ID], [Element_ShortTitle], SortOrder " &_
'			" FROM Website_Element_Data c " &_
'			" WHERE c.Parent_Element_ID = '0" & parentQuestionID & "' AND c.Element_ID <> '0" & sortQuestionID & "' " &_
'			" GROUP BY [Element_ID], [Parent_Element_ID], [Repository_Topic_Details_ID], [Element_ShortTitle], SortOrder " &_
'			" ORDER BY c.SortOrder, c.Element_ID "

	SQLStr = "SELECT c.[ID] As Question_ID, c.[Parent_Tax_Question_ID], c.SortOrder " &_
			" FROM SPD_Tax_Question c " &_
			" WHERE c.Tax_UDA_ID = '0" & taxID & "' AND c.Parent_Tax_Question_ID = '0" & parentQuestionID & "' AND c.[ID] <> '0" & sortQuestionID & "' " &_
			" ORDER BY c.SortOrder, c.[ID] "
	Response.Write SQLStr & "<br>" & vbCrLf & "<br>" & vbCrLf
	objRec.Open SQLStr, objConn, adOpenDynamic, adLockBatchOptimistic, adCmdText
	if not objRec.EOF then
		Do Until objRec.EOF
			
			if CInt(objRec("Question_ID")) = CInt(moveReference) then
				Select Case moveDirection
					Case "above"
						reservedPos = i		' we are giving the current position to the source element
						newPos = i + 1		' we are moving the target element to the position AFTER the current position
						reserveSet = true
					Case "below"
						reservedPos = i + 1	' we are giving the source element the position AFTER the current position
						newPos = i			' we are leaving the target element in the current position
						reserveSet = true
				End Select
			else
				if reserveSet = true then
					Select Case moveDirection
						Case "above"
							newPos = i + 1
						Case "below"
							newPos = i
					End Select
				else
					newPos = i
				end if
			end if

			SQLStr = "UPDATE SPD_Tax_Question SET " &_
					" Parent_Tax_Question_ID = '0" & parentQuestionID & "', " &_
					" SortOrder = '" & padMe(newPos, 5, 0, "left") & "', " &_
					" Date_Last_Modified = '" & CDate(Now()) & "' " &_
					"WHERE [ID] = '0" & objRec("Question_ID") & "' "
			Response.Write SQLStr & "<br>" & vbCrLf	
			Set objRec2 = objConn.Execute(SQLStr)

			objRec.MoveNext
			i = i + 1
		Loop
	end if
	objRec.Close
	
	'==============================================================================
	' Now give the reserved space to our item.
	'==============================================================================
	SQLStr = "UPDATE SPD_Tax_Question SET " &_
			" Parent_Tax_Question_ID = '0" & parentQuestionID & "', " &_
			" SortOrder = '" & padMe(reservedPos, 5, 0, "left") & "', " &_
			" Date_Last_Modified = '" & CDate(Now()) & "' " &_
			" WHERE Tax_UDA_ID = '0" & taxID & "' AND [ID] = '0" & sortQuestionID & "' "
	Response.Write "<br>" & vbCrLf & SQLStr & "<br>" & vbCrLf	
	Set objRec = objConn.Execute(SQLStr)

end if

if objConn.Errors.Count < 1 and Err.number < 1 then
	objConn.CommitTrans
	
	Set ActivityLog				= New cls_ActivityLog
	Set ActivityType			= New cls_ActivityType
	Set ActivityReferenceType	= New cls_ActivityReferenceType
	Set utils					= New cls_UtilityLibrary
	
	'Get the Element_ShortTitle for auditing purposes
	SQLStr = "Select Top 1 Tax_Question From SPD_Tax_Question Where [ID] = " & sortQuestionID
	Set rs = utils.LoadRSFromDB(SQLStr)
	
	if Not rs.EOF then
		taxQuestion = SmartValues(rs("Tax_Question"), "CStr")
	end if
	
	rs.Close
	Set rs = Nothing

	ActivityLog.Activity_Type = ActivityType.Move_ID
	ActivityLog.Activity_Summary = "Moved Question " & taxQuestion
	ActivityLog.Reference_Type = ActivityReferenceType.SPEDY_Tax_Question
	ActivityLog.Reference_ID = sortQuestionID	
	ActivityLog.Save

	Set utils					= Nothing
	Set ActivityLog				= Nothing
	Set ActivityType			= Nothing
	Set ActivityReferenceType	= Nothing
else
	objConn.RollbackTrans
end if

'	Dim newNavString
'	SQLStr = "sp_websites_admin_climbladder " & sortQuestionID & ", " & CInt(Session.Value("websiteID")) & ", 1"
'	Set objRec = objConn.Execute(SQLStr)
'	if not objRec.EOF then
'		if not IsNull(objRec(0)) then
'			newNavString = Trim(objRec(0))
'		end if
'	end if
'	objRec.Close


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


function padMe(strInput, reqdLength, padChar, padDir)
'--------------------------------------------------
'Pad a value for fixed field style-output. -KW 01/16/01
'--------------------------------------------------
'strInput		- the string to be padded.
'reqdLength		- the desired length of the final string.
'padChar		- the character with which to pad the string.
'padDir			- which side (l or r, left or right) to throw the padding onto.
'--------------------------------------------------
	if padChar <> "" and Trim(padDir) <> "" and IsNumeric(reqdLength) and Trim(strInput) <> "" then
		if len(strInput) > reqdLength then
			if LCase(Trim(padDir)) = "l" or LCase(Trim(padDir)) = "left" then
				strInput = Left(strInput, reqdLength)
			elseif LCase(Trim(padDir)) = "r" or LCase(Trim(padDir)) = "right" then
				strInput = Right(strInput, reqdLength)
			else
				strInput = Left(strInput, reqdLength)
			end if
		end if
		do until len(strInput) = reqdLength
			if LCase(Trim(padDir)) = "l" or LCase(Trim(padDir)) = "left" then
				strInput = padChar & strInput
			elseif LCase(Trim(padDir)) = "r" or LCase(Trim(padDir)) = "right" then
				strInput = strInput & padChar
			else
				strInput = strInput
			end if
		loop
	else
		strInput = strInput
	end if
	padMe = strInput
end function 
%>
<script language="javascript">
	//Set a reference to the Details frame in the Repository frameset...
	var myFrameSetRef = new Object(parent.window.opener.parent.frames['DetailFrame']);
	
	//If the user hasnt left the repository framset, then refresh the details screen, otherwise dont worry bout it...
	if (typeof(myFrameSetRef == 'object'))
	{
		myFrameSetRef.document.location.reload();
	}
	
	//we're all done, so leave...
	parent.window.close();
</script>
