<%@ LANGUAGE=VBSCRIPT%>
<%
'==============================================================================
' Author: Jeff Littlefield
'==============================================================================
Option Explicit
Response.Buffer = True
Response.Expires = -1441
%>
<!--#include file="./../../app_include/_globalInclude.asp"-->
<%
dim myFunction

myFunction = Request("f")

Select Case Ucase(myFunction)
    Case "GETUSERS"
        doGetUsers()
        
    Case "SAVEUSERS"
        doSaveUsers()
    
    Case Else
        response.Write("Invalid Data")
    
End Select
Response.End

'---------------------------------------------------
Sub doSaveUsers()
    Dim conn, SQLStr, connStr, cmd, deptID, groupID, workflowID, thisUserID
    Dim deptNum, privilegeName, strTemp

    Set conn = Server.CreateObject("ADODB.Connection")
    Set cmd = Server.CreateObject("ADODB.Command")

    connStr = Application.Value("connStr")
    conn.Open connStr

    Set cmd.ActiveConnection = conn

    deptID = Request.Form("hdnPrivID")
	groupID = Request.Form("hdnGroupID")
	workflowID = Request.Form("hdnWorkflowID")
    strTemp = Request.Form("hdnUserData")
    thisUserID = SmartValues(Session.Value("UserID"), "Integer")
  
	SQLStr = "usp_SPD_PrimaryApproval_SaveUsers2 "
	cmd.CommandText = SQLStr
	cmd.CommandType = adCmdStoredProc
	cmd.Parameters.Append cmd.CreateParameter("@WorkflowID", adInteger, adParamInput, , workflowID)
	cmd.Parameters.Append cmd.CreateParameter("@PrivilegeID", adInteger, adParamInput, , deptID)
	cmd.Parameters.Append cmd.CreateParameter("@GroupID", adInteger, adParamInput, , groupID)
	cmd.Parameters.Append cmd.CreateParameter("@UserID", adInteger, adParamInput, , strTemp)

    'SQLStr = "usp_SPD_PrimaryApproval_SaveUsers "
    'cmd.CommandText = SQLStr
    'cmd.CommandType = adCmdStoredProc
    'cmd.Parameters.Append cmd.CreateParameter("@SecurityPriviledgeID", adInteger, adParamInput,, deptID)
    'cmd.Parameters.Append cmd.CreateParameter("@RowDelimiter", adVarChar, adParamInput, 1, "|")
    'cmd.Parameters.Append cmd.CreateParameter("@FieldDelimiter", adVarChar, adParamInput, 1, "_")
    'cmd.Parameters.Append cmd.CreateParameter("@UpdateUserID", adInteger, adParamInput,, thisUserID)
    'cmd.Parameters.Append cmd.CreateParameter("@Records", adVarChar, adParamInput, len(strTemp)+1, strTemp)

    on error resume next
    cmd.Execute
    if err.number>0 then
        response.Write("0|Save Failed. " & err.Description)
    else
        response.Write("1|Save Successful")
    end if
   	if conn.State <> adStateClosed then
   		On Error Resume Next
		conn.Close
	end if
	Set rs = Nothing
	Set conn = Nothing
	on error goto 0
end Sub


Sub doGetUsers ()
    Dim objConn, objRec, objRec2, SQLStr, connStr, id, gid, wid, i
    Dim scopeID, strRemovePrivileges, NumNewDepartments
    Dim deptNum, privilegeName, strTemp, x, sGroups
    Set objConn = Server.CreateObject("ADODB.Connection")
    Set objRec = Server.CreateObject("ADODB.RecordSet")

    connStr = Application.Value("connStr")
    id = Request("id")
	gid = Request("gid")
	wid = Request("wid")
    SQLStr = "usp_SPD_PrimaryApproval_GetUsers2 @SecurityPrivilegeID = " & id & ", @SecurityGroupID = " & gid & ", @WorkflowID = " & wid
    objConn.Open connStr
    
    On Error Resume Next

    objRec.Open SQLStr, objConn, adOpenDynamic, adLockOptimistic
    if Err.number > 0 then
        response.Write("0|$|" & err.Description & "|$|0")
        objConn.Close
        set objConn = nothing
        exit sub
    end if
    on error goto 0
    
    i = 0 
    If Not objRec.EOF Then
        Response.Write("1|$|<div class='inner'><table border='0' cellspacing='0' cellpadding='2' id='tblDetails'>")
        Do While Not objRec.EOF 
            i = i + 1
            sGroups = trim(objRec("Groups"))
            if Right(sGroups,1) = "," then sGroups = left(sGroups,len(sGroups)-1)

			Response.Write("<tr valign='top' onMouseOver=""this.style.backgroundColor='lightyellow'"" onMouseOut=""this.style.backgroundColor='whitesmoke'"">")
			Response.Write("<td width='10%' align='center'><input type='radio' id='rBtnUser' name='rBtnUser' value='" & objRec("ID") & "' ")
			if CBool(objRec("PrimaryApproverFlag")) Then Response.Write("checked ")
			Response.Write("onclick='SD(" & objRec("ID") & ");' /></td>")
			Response.Write("<td width='20%' align='left'>" & objRec("Name") & "</td>")
			Response.Write("<td width='15%' align='left'>" & objRec("Organization") & "</td>")
            Response.Write("<td width='55%' align='left'>" & sGroups & "</td></tr>")

            'Response.Write("<tr valign='top' onMouseOver=""this.style.backgroundColor='lightyellow'"" onMouseOut=""this.style.backgroundColor='whitesmoke'"">") '#CCCCCC
            'Response.Write("<td width='10%' align='center'><input type='checkbox' id='chk" & cstr(i) & "' ")
            'if Cbool(objRec("PrimaryApproverFlag")) Then Response.Write("checked='checked' ")
            'Response.Write(" onclick='SD();' /><input type='hidden' id='hidchk" & cstr(i) & "' value='" & objRec("ID") &"' /></td><td width='20%' align='left'>")
            'Response.Write(objRec("Name") & "</td><td width='15%' align='left'>" & objRec("Organization") & "</td>")
            'Response.Write("<td width='55%' align='left'>" & sGroups & "</td></tr>")

            objRec.MoveNext
        loop
        Response.Write("</table></div>|$|" & cstr(i))
        
        '<th align="center" width="10%">Pri<br />Appr</th>
        '<th align="left" width="25%"><br />Name</th>
        '<th align="left" width="15%"><br />Organization</th>
        '<th align="left" width="50%"><br />Groups</th>

        objRec.close()
        set objRec = nothing
        objConn.Close
        set objConn = nothing
        
    Else
        Response.Write("1|$||$|0")
    End if
end Sub




%>
