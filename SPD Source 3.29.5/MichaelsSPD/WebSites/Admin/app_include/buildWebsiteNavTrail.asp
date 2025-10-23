<%
'==============================================================================
' Author: Ken Wallace, Principal - Ken Wallace Design
'==============================================================================

Dim objNavTrailRec, objNavTrailConn, NavTrailSQLStr
Dim zElementID
Dim zStrNavTrail, zWebsiteName
Dim zStrFamilyList, zArFamilyList

Session.Value("websiteID") = 2

Function buildWebsiteNavTrail(zElementID)
	Set objNavTrailConn = Server.CreateObject("ADODB.Connection")
	Set objNavTrailRec = Server.CreateObject("ADODB.RecordSet")
	objNavTrailConn.Open Application.Value("connStr")

	buildWebsiteNavTrail = public_buildNavTrail(zElementID)

	Call zDB_CleanUp
End Function

Function public_buildNavTrail(zElementID)
	if IsNumeric(zElementID) then
		zElementID = CInt(zElementID)
	else
		Exit Function
	end if

	NavTrailSQLStr = "sp_websites_admin_climbladder " & zElementID & ", " & Session.Value("websiteID") & ", 1"
	Set objNavTrailRec = objNavTrailConn.Execute(NavTrailSQLStr)
	if not objNavTrailRec.EOF then
		if not IsNull(objNavTrailRec(0)) then
			zStrFamilyList = objNavTrailRec(0)
		end if
	end if
	objNavTrailRec.Close
	zArFamilyList = Split(zStrFamilyList, ",")

	NavTrailSQLStr = "SELECT COALESCE(Website_Name, 'Website') FROM Website WHERE [ID] = " & Session.Value("websiteID")
	Set objNavTrailRec = objNavTrailConn.Execute(NavTrailSQLStr)
	if not objNavTrailRec.EOF then
		zWebsiteName = objNavTrailRec(0)
	else
		zWebsiteName = "Website"
	end if
	objNavTrailRec.Close

	zStrNavTrail = Trim(zWebsiteName & "&gt;" & local_buildNavTrail(0))
	if Right(zStrNavTrail, 4) = "&gt;" then
		zStrNavTrail = Left(zStrNavTrail, Len(zStrNavTrail) - 4)
	end if
	
	public_buildNavTrail = zStrNavTrail
End Function

function local_buildNavTrail(myEntityID)
	Dim bElementID, bElementTitle
	Dim tempNavTrail, objNavTrailRec2
	Set objNavTrailRec2 = Server.CreateObject("ADODB.RecordSet")

	NavTrailSQLStr = "sp_websites_return_website_contents " & Session.Value("websiteID") & ", " & myEntityID
	objNavTrailRec2.Open NavTrailSQLStr, objNavTrailConn, adOpenStatic, adLockReadOnly, adCmdText
	if not objNavTrailRec2.EOF then
		Do Until objNavTrailRec2.EOF
			bElementID = CInt(objNavTrailRec2("Element_ID"))
			bElementTitle = objNavTrailRec2("Element_FullTitle")

			if CBool(findNeedleInHayStack(zArFamilyList, bElementID, "true")) then
				if zElementID = bElementID then
					tempNavTrail = bElementTitle
				else
					tempNavTrail = bElementTitle & "&gt;" & local_buildNavTrail(bElementID)
				end if
			end if
			objNavTrailRec2.MoveNext
		Loop					
	end if
	objNavTrailRec2.Close
	Set objNavTrailRec2 = Nothing

	local_buildNavTrail = tempNavTrail
end function


Sub zDB_CleanUp
	'---- ObjectStateEnum Values ----
'	Const adStateClosed = &H00000000
'	Const adStateOpen = &H00000001
'	Const adStateConnecting = &H00000002
'	Const adStateExecuting = &H00000004
'	Const adStateFetching = &H00000008

	if objNavTrailRec.State <> adStateClosed then
		On Error Resume Next
		objNavTrailRec.Close
	end if
	if objNavTrailConn.State <> adStateClosed then
		On Error Resume Next
		objNavTrailConn.Close
	end if
	Set objNavTrailRec = Nothing
	Set objNavTrailConn = Nothing
End Sub

%>