<%@ LANGUAGE=VBSCRIPT%>
<%
'==============================================================================
' Author: Oscar Treto
'==============================================================================
Option Explicit
Response.Buffer = True
Response.Expires = -1441
%>
<!--#include file="../../app_include/smartValues.asp"-->
<!--#include file="../../app_include/checkQueryID.asp"-->
<!--#include file="../../app_include/padMe.asp"-->
<%
Dim objConn, objRec, objRec2, SQLStr, connStr, x
Dim scopeID, strRemovePrivileges, NumNewDepartments
Dim deptNum, privilegeName

Set objConn = Server.CreateObject("ADODB.Connection")
Set objRec = Server.CreateObject("ADODB.RecordSet")
Set objRec2 = Server.CreateObject("ADODB.RecordSet")

connStr = Application.Value("connStr")
objConn.Open connStr

scopeID = checkQueryID(Request.Form("ScopeID"), 0)
strRemovePrivileges = Replace(Replace(Trim(SmartValues(Request.Form("strRemovePrivileges"), "CStr")), "'", ""), ";", "")

'Remove Any Privileges Requested
If Len(strRemovePrivileges) > 0 Then
	
	SQLStr = "Delete From Security_Privilege_Object Where Privilege_ID In (" & strRemovePrivileges & ")"
	objConn.Execute(SQLStr)
	
	SQLStr = "Delete From Security_Privilege Where ID In (" & strRemovePrivileges & ")"
	objConn.Execute(SQLStr)
	
End If

'Loop Through Departments And Update
SQLStr = "Select * From Security_Privilege Where Scope_ID = " & scopeID
objRec.Open SQLStr, objConn, adOpenDynamic, adLockOptimistic

If Not objRec.EOF Then
	Do Until objRec.EOF

		privilegeName = Trim(SmartValues(Request.Form(objRec("ID") & "_Name"), "CStr"))
		If Len(privilegeName) > 0 Then objRec("Privilege_Name") = SmartValues(privilegeName, "CStr") End If
		objRec("Date_Last_Modified") = Now()
		
		objRec.Update
		objRec.MoveNext
	Loop
End If
objRec.Close()

'Add New Departments
NumNewDepartments = checkQueryID(Request.Form("NumNewDepartments"), 0)
If NumNewDepartments > 0 Then
	
	objRec.Open "Select * From Security_Privilege Where 1=2", objConn, adOpenDynamic, adLockOptimistic
	
	For x=1 To NumNewDepartments
		
		'Get New Values
		deptNum = checkQueryID(Request.Form("new_" & x & "_Num"), 0)
		privilegeName = UCase(Trim(SmartValues(Request.Form("new_" & x & "_Name"), "CStr")))
		
		'Check For Existing Dept Num
		objRec2.Open "Select 1 As Num_Existing From Security_Privilege Where Scope_ID = " & scopeID & " And Constant = 'SPD.DEPT." & deptNum & "'", objConn, adOpenForwardOnly, adLockReadOnly
		If objRec2.EOF Then
		
			objRec.AddNew	
			
			objRec("Scope_ID") = scopeID
			objRec("Privilege_Name") = deptNum & " - " & privilegeName
			objRec("Privilege_ShortName") = "DEPT" & padMe(deptNum, 3, "0", "left")
			objRec("Privilege_Summary") = "Can View Department " & deptNum & ": " & privilegeName
			objRec("Constant") = "SPD.DEPT." & deptNum
			objRec("SortOrder") = padMe(deptNum, 5, "0", "left")
			
			objRec.Update()
			
		End If
		objRec2.Close()
		
	Next
	
	objRec.Close()
	
End If

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
	if objRec2.State <> adStateClosed then
		On Error Resume Next
		objRec2.Close
	end if
	if objConn.State <> adStateClosed then
		On Error Resume Next
		objConn.Close
	end if
	Set objRec = Nothing
	Set objRec2 = Nothing
	Set objConn = Nothing
End Sub

%>
<script language="javascript">
	parent.frames["header"].document.location = "./../../app_include/blank_cccccc.html";
	parent.frames["controls"].document.location = "./../../app_include/blank_cccccc.html";
	parent.frames["body"].document.location = "security_department_details_work_finish.asp";
</script>
