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

Dim objConn, objRec, SQLStr, connStr, i
Dim rowID, orderID

rowID = request("rowID")
if len(rowID) = 0 then
	rowID = 0
end if

orderID = request("oid")
if len(orderID) = 0 then
	orderID = 0
end if

if rowID > 0  and orderID > 0 then
	Set objConn = Server.CreateObject("ADODB.Connection")
	Set objRec = Server.CreateObject("ADODB.RecordSet")

	connStr = Application.Value("connStr")
	objConn.Open connStr

	'Remove order item along with online course and btw registrations
	SQLStr = "EXEC sp_shopping_order_remove_order_item " & rowID
	objRec.Open SQLStr, objConn
	
	'Set objRec = objConn.Execute(SQLStr)
	
	'Update the shopping order
	SQLStr = "EXEC sp_shopping_order_update_totals " & orderID
	objRec.Open SQLStr, objConn 
	'Set objRec = objConn.Execute(SQLStr)
	
	Call DB_CleanUp
%>
<script language=javascript>
	alert('got here');
	top.frames['DetailFrameWrapper'].frames['DetailFrame']document.location.reload();
</script>
<%
end if

Response.Redirect "./../order_details_product_details_results_listview.asp?oid=" & orderID & "&sort=" & Request.QueryString("sort") & "&direction=" & Request.QueryString("direction")

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