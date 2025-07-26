<%@ LANGUAGE=VBSCRIPT%>
<%
'==============================================================================
' Author: Ken Wallace, Principal - Ken Wallace Design
'==============================================================================
Option Explicit
Response.Buffer = True
Response.Expires = -1441
%>
<!--#include file="./../../app_include/smartValues.asp"-->
<!--#include file="./../../app_include/checkQueryID.asp"-->
<!--#include file="./../../app_include/bo_classes.asp"-->
<!--#include file="./../../app_include/dal_classes.asp"-->
<!--#include file="./../../app_include/dal_cls_UtilityLibrary.asp"-->
<%
Dim objConn, objRec, SQLStr, connStr, i
Dim Order_ID, Order_CouponsRedeemed, Order_TaxCost, Order_ShippingCost, Order_HandlingFee, Order_GrandTotal

for i = 1 to Request.Form.Count
	Response.Write Request.Form.Key(i) & ": '" & Request.Form(i) & "'<br>" & vbCrLf
next

Set objConn = Server.CreateObject("ADODB.Connection")
Set objRec = Server.CreateObject("ADODB.RecordSet")

connStr = Application.Value("connStr")
objConn.Open connStr

Order_ID = checkQueryID(Trim(Request.Form("Order_ID")), 0)
Order_CouponsRedeemed = Trim(Request.Form("txt_Order_CouponsRedeemed"))
Order_TaxCost = Trim(Request.Form("txt_Order_TaxCost"))
Order_ShippingCost = Trim(Request.Form("txt_Order_ShippingCost"))
Order_HandlingFee = Trim(Request.Form("txt_Order_HandlingFee"))
Order_GrandTotal = Trim(Request.Form("txt_Order_GrandTotal"))

objConn.BeginTrans

SQLStr = "SELECT * FROM Shopping_Order WHERE [ID] = '0" & Order_ID & "'"
objRec.Open SQLStr, objConn, adOpenKeyset, adLockBatchOptimistic, adCmdText
if not objRec.EOF then

	objRec("Order_CouponsRedeemed") = Order_CouponsRedeemed
	objRec("Order_TaxCost") = Order_TaxCost
	objRec("Order_ShippingCost") = Order_ShippingCost
	objRec("Order_HandlingFee") = Order_HandlingFee
	objRec("Order_GrandTotal") = Order_GrandTotal

	objRec("Date_Last_Modified") = CDate(Now())
	objRec("Update_User_ID") = checkQueryID(Session.Value("UserID"), 0)
	objRec.UpdateBatch
end if
objRec.Close

if objConn.Errors.Count < 1 and Err.number < 1 then
	objConn.CommitTrans
	Session.Value("ORDER_SAVE_SUCCESS") = "1"
else
	objConn.RollbackTrans
	Session.Value("ORDER_SAVE_SUCCESS") = "0"
end if

Response.Redirect "./../order_details_info_summary.asp?oid=" & Order_ID
Response.End

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
