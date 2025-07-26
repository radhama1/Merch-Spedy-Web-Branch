<%@ LANGUAGE=VBSCRIPT%>
<%
Option Explicit
Response.Buffer = True
Response.Expires = -1441
%>
<!--#include file="./../app_include/SmartValues.asp"-->
<!--#include file="./../app_include/checkQueryID.asp"-->
<%
Dim objConn, objRec, SQLStr, connStr
Dim Order_ID, currentStatus

Order_ID = checkQueryID(Request("oid"), 0)

Set objConn = Server.CreateObject("ADODB.Connection")
Set objRec = Server.CreateObject("ADODB.RecordSet")

connStr = Application.Value("connStr")
objConn.Open connStr
%>
<html>
<head>
	<title></title>
	<style type="text/css">
		A {text-decoration: none; color: #000000; cursor: hand;}
		A:HOVER {text-decoration: none; color: #000000; cursor: hand;}
		BODY
		{
			scrollbar-face-color: "#cccccc"; 
			scrollbar-highlight-color: "#ffffff"; 
			scrollbar-shadow: "#999999";
			scrollbar-3dlight-color: "#cccccc"; 
			scrollbar-arrow-color: "#000000";
			scrollbar-track-color: "#ececec";
			scrollbar-darkshadow-color: "#000000";
			cursor: default;
			padding: 10px;
		}

		INPUT * {font-family:Arial, Helvetica; font-size:12px; color:#000;}
		SELECT {font-family:Arial, Helvetica; font-size:12px; color:#000;}
		TEXTAREA {font-family:Arial, Helvetica; font-size:12px; color:#000;}

		.headerText
		{
			font-family: Arial, Helvetica, Sans-Serif;
			font-size: 18px;
			color: #999;
		}

		.subheaderText
		{
			font-family: Arial, Helvetica, Sans-Serif;
			font-size: 14px;
			color: #666;
		}

		.bodyText
		{
			font-family: Arial, Helvetica, Sans-Serif;
			font-size: 11px;
			color: #000;
		}
		
		.fldColumn
		{
			width: 310px;
			float: left;
		}

		.fldGroup
		{
			width: 300px;
			float: left;
			margin-right: 10px;
			margin-bottom: 10px;
			padding: 10px;
			border: 1px solid #000;
			background-color: #ececec;
			filter:progid:DXImageTransform.Microsoft.Shadow(color='#666666', Direction=120, Strength=3);
		}
		
		#billingAddressMail
		{
			clear:left;
		}
		
		
		.fldGroupLabel
		{
			font-family: Arial, Helvetica, Sans-Serif;
			font-size: 13px;
			color: #000;
			font-weight: bold;
			margin-bottom: 5px;
		}

		.fld
		{
			clear: left;
			margin-bottom: 4px;
		}
		
		.fldLabel
		{
			font-family: Arial, Helvetica, Sans-Serif;
			font-size: 11px;
			color: #666;
		}
		
		.fldText
		{
			float: left;
			width: 100%;
			background-color: #fff;
			padding-left: 2px;
			cursor: text;
		}
		
		#fld1, #fld2, #fld5, #fld6, #fld7, #fld8 {width: 138px; float: left; border: 0px; clear: none; margin-right: 4px;}
		#fld41, #fld42, #fld45, #fld46, #fld47, #fld48 {width: 138px; float: left; border: 0px; clear: none; margin-right: 4px;}
		#billingMailingLabel, #shippingMailingLabel {padding: 10px; font-family: Courier; clip: auto; overflow: auto;}
		#fld2, #fld6, #fld8 {width: 136px; margin-right: 0px;}
		#fld42, #fld46, #fld48 {width: 136px; margin-right: 0px;}

		.fldPriceCurrencySymbol
		{
			text-align: left;
			float: left;
			padding-right: 2px;
			color: #666;
		}

		.left_label
		{
			border: 0px;
			margin: 0px;
			width: 50%;
			float: left;
		}
		.right_value
		{
			width: 50%;
			background-color: #fff;
			text-align: right;
			padding-right: 2px;
			float: left;
		}
		
		.fld_ordertotals
		{
			border-top: 1px solid #999;
		}

		.fld_ordergrandtotal
		{
			border-top: 2px solid #000;
			color: #000;
			font-weight: bold;
		}
	</style>
	<script type="text/javascript" language="javascript">
		function updateGrandTotal()
		{
			var m_Order_SubTotal = new Number();
			var m_Order_CouponsRedeemed = new Number();
			var m_Order_TaxCost = new Number();
			var m_Order_ShippingCost = new Number();
			var m_Order_HandlingFee = new Number();
			var m_Order_GrandTotal = new Number();
			var m_New_Order_GrandTotal = new Number();
			
			if(!isNaN($("txt_Order_Subtotal").value)) m_Order_SubTotal = parseFloat($("txt_Order_Subtotal").value);
			if(!isNaN($("txt_Order_CouponsRedeemed").value)) m_Order_CouponsRedeemed = parseFloat($("txt_Order_CouponsRedeemed").value);
			if(!isNaN($("txt_Order_TaxCost").value)) m_Order_TaxCost = parseFloat($("txt_Order_TaxCost").value);
			if(!isNaN($("txt_Order_ShippingCost").value)) m_Order_ShippingCost = parseFloat($("txt_Order_ShippingCost").value);
			if(!isNaN($("txt_Order_HandlingFee").value)) m_Order_HandlingFee = parseFloat($("txt_Order_HandlingFee").value);
			if(!isNaN($("txt_Order_GrandTotal").value)) m_Order_GrandTotal = parseFloat($("txt_Order_GrandTotal").value);
			
			m_New_Order_GrandTotal = 0;
			m_New_Order_GrandTotal = m_New_Order_GrandTotal + m_Order_SubTotal;
			m_New_Order_GrandTotal = m_New_Order_GrandTotal - m_Order_CouponsRedeemed;
			m_New_Order_GrandTotal = m_New_Order_GrandTotal + m_Order_TaxCost;
			m_New_Order_GrandTotal = m_New_Order_GrandTotal + m_Order_ShippingCost;
			m_New_Order_GrandTotal = m_New_Order_GrandTotal + m_Order_HandlingFee;
			
			m_Order_CouponsRedeemed = m_Order_CouponsRedeemed.toFixed(2);
			m_Order_TaxCost = m_Order_TaxCost.toFixed(2);
			m_Order_ShippingCost = m_Order_ShippingCost.toFixed(2);
			m_Order_HandlingFee = m_Order_HandlingFee.toFixed(2);
			m_New_Order_GrandTotal = m_New_Order_GrandTotal.toFixed(2);

			$("txt_Order_CouponsRedeemed").value = m_Order_CouponsRedeemed.toString();
			$("txt_Order_TaxCost").value = m_Order_TaxCost.toString();
			$("txt_Order_ShippingCost").value = m_Order_ShippingCost.toString();
			$("txt_Order_HandlingFee").value = m_Order_HandlingFee.toString();
			$("txt_Order_GrandTotal").value = m_New_Order_GrandTotal.toString();
		}
	</script>
	<script language="javascript" src="./../app_include/prototype/prototype.js"></script>
	<script language="javascript" src="./../app_include/prototype/scriptaculous.js"></script>
	<script language="javascript" src="./../app_include/evaluator.js"></script>
</head>
<body bgcolor="cccccc" topmargin=0 leftmargin=0 marginheight=0 marginwidth=0>

<%
SQLStr = "sp_shopping_order_details_by_orderID " & Order_ID
'Response.Write SQLStr
objRec.Open SQLStr, objConn, adOpenStatic, adLockReadOnly, adCmdText
if not objRec.EOF then
%>
<form name="theForm" method="post" action="./order_admin/order_edit_save.asp" style="padding: 0; margin: 0;">
<div id="col2" class="fldColumn">
	<div id="billingAmount" class="fldGroup">
		<table border="0" cellpadding="0" cellpadding="0" width="100%" style="padding: 0px; margin: -3px;" ID="Table1">
			<tr>
				<td><div class="fldGroupLabel">Order&nbsp;Amount&nbsp;&nbsp;</div></td>
				<td align="right"><div class="bodyText"><a href="order_details_info_summary.asp?oid=<%=Order_ID%>" style="text-decoration: underline; color: #00f;">Cancel</a></div></td>
			</tr>
		</table>
		<div id="fld12" class="fld fld_ordertotals"><div id="fld12_label" class="fldLabel left_label">Subtotal</div><div id="Order_SubTotal" class="bodyText fldText right_value"><span id="fld12_currencysymbol" class="fldPriceCurrencySymbol">$</span><input type="text" id="txt_Order_Subtotal" name="txt_Order_Subtotal" value="<%=SmartValues(objRec("Order_Subtotal"), "FormatNumber")%>" class="bodyText" style="width: 120px; text-align: right; height: 14px; line-height: 14px; padding: 0; margin: 0; color: #000; background: #ececec; border:0;" readonly></div></div>
		<div id="fld13" class="fld fld_ordertotals"><div id="fld13_label" class="fldLabel left_label">Coupons</div><div id="Order_CouponsRedeemed" class="bodyText fldText right_value"><span id="fld13_currencysymbol" class="fldPriceCurrencySymbol">$</span><input type="text" id="txt_Order_CouponsRedeemed" name="txt_Order_CouponsRedeemed" value="<%=SmartValues(objRec("Order_CouponsRedeemed"), "FormatNumber")%>" onblur="updateGrandTotal();" class="bodyText" style="width: 120px; text-align: right; height: 14px; line-height: 10px; padding: 0; margin: 0; color: #000;"></div></div>
		<div id="fld14" class="fld fld_ordertotals"><div id="fld14_label" class="fldLabel left_label">Tax</div><div id="Order_TaxCost" class="bodyText fldText right_value"><span id="fld14_currencysymbol" class="fldPriceCurrencySymbol">$</span><input type="text" id="txt_Order_TaxCost" name="txt_Order_TaxCost" value="<%=SmartValues(objRec("Order_TaxCost"), "FormatNumber")%>" onblur="updateGrandTotal();" class="bodyText" style="width: 120px; text-align: right; height: 14px; line-height: 10px; padding: 0; margin: 0; color: #000;"></div></div>
		<div id="fld15" class="fld fld_ordertotals"><div id="fld15_label" class="fldLabel left_label">Shipping</div><div id="Order_ShippingCost" class="bodyText fldText right_value"><span id="fld15_currencysymbol" class="fldPriceCurrencySymbol">$</span><input type="text" id="txt_Order_ShippingCost" name="txt_Order_ShippingCost" value="<%=SmartValues(objRec("Order_ShippingCost"), "FormatNumber")%>" onblur="updateGrandTotal();" class="bodyText" style="width: 120px; text-align: right; height: 14px; line-height: 10px; padding: 0; margin: 0; color: #000;"></div></div>
		<div id="fld116" class="fld fld_ordertotals"><div id="fld116_label" class="fldLabel left_label">Handling</div><div id="Order_HandlingFee" class="bodyText fldText right_value"><span id="fld116_currencysymbol" class="fldPriceCurrencySymbol">$</span><input type="text" id="txt_Order_HandlingFee" name="txt_Order_HandlingFee" value="<%=SmartValues(objRec("Order_HandlingFee"), "FormatNumber")%>" onblur="updateGrandTotal();" class="bodyText" style="width: 120px; text-align: right; height: 14px; line-height: 10px; padding: 0; margin: 0; color: #000;"></div></div>
		<div id="fld16" class="fld fld_ordergrandtotal"><div id="fld16_label" class="fldLabel left_label">Grand&nbsp;Total</div><div id="Order_GrandTotal" class="bodyText fldText right_value"><span id="fld16_currencysymbol" class="fldPriceCurrencySymbol">$</span><input type="text" id="txt_Order_GrandTotal" name="txt_Order_GrandTotal" value="<%=SmartValues(objRec("Order_GrandTotal"), "FormatNumber")%>" class="bodyText" style="font-weight: bold; width: 120px; text-align: right; height: 14px; line-height: 14px; padding: 0; margin: 0; color: #000; background: #ececec; border:0;" readonly></div></div>
		<table border="0" cellpadding="0" cellpadding="0" width="100%"><tr><td><input type="reset" value="Reset" id="btnCancel" name="btnCancel"></td><td align="right"><input type="submit" value="Save Changes" id="btnsubmit" name="btnsubmit" onclick="this.value='Please wait.'; this.disabled=true; document.theForm.submit();"></td></tr></table>
		<input type="hidden" id="Order_ID" name="Order_ID" value="<%=Order_ID%>">
	</div>

	<div id="billingDetails" class="fldGroup">
		<div class="fldGroupLabel">Payment&nbsp;Information</div>
		<div id="fld17" class="fld"><div id="fld17_label" class="fldLabel left_label">Name&nbsp;on&nbsp;Card</div><div id="Card_FullName" class="bodyText fldText right_value"><%=SmartValues(objRec("Card_FullName"), "CStr")%></div></div>
		<div id="fld18" class="fld"><div id="fld18_label" class="fldLabel left_label">Card&nbsp;Type</div><div id="Card_Type_ID" class="bodyText fldText right_value"><%=SmartValues(objRec("Card_Type_Name"), "CStr")%></div></div>
		<div id="fld19" class="fld"><div id="fld19_label" class="fldLabel left_label">Card&nbsp;Number</div><div id="Card_Number_Unencrypted" class="bodyText fldText right_value"><%=SmartValues(objRec("Card_Number_Unencrypted"), "CStr")%></div></div>
		<div id="fld20" class="fld"><div id="fld20_label" class="fldLabel left_label">Card&nbsp;Security&nbsp;Code</div><div id="Card_SecurityCode_Unencrypted" class="bodyText fldText right_value"><%=SmartValues(objRec("Card_SecurityCode_Unencrypted"), "CStr")%></div></div>
		<div id="fld21" class="fld"><div id="fld21_label" class="fldLabel left_label">Expiration&nbsp;Date</div><div id="Card_Expires" class="bodyText fldText right_value"><%=SmartValues(objRec("Card_Expires_Month"), "CStr")%>/<%=SmartValues(objRec("Card_Expires_Year"), "CStr")%></div></div>
		<div class="fldGroupLabel" style="margin-top: 10px;">Payment&nbsp;Authorization</div>
		<div id="fld200" class="fld"><div id="fld200_label" class="fldLabel left_label">Authorization&nbsp;Code</div><div id="Auth_Trans_ID" class="bodyText fldText right_value"><a href="" onclick="alert('Full text of Authorization Response is included below:\n\n<%=Server.HTMLEncode(SmartValues(objRec("Auth_Response_String"), "CStr"))%>'); return false;" style="text-decoration: none;"><%=SmartValues(objRec("Auth_Trans_ID"), "CStr")%></a></div></div>
	</div>

	<div id="shippingDetails" class="fldGroup">
		<div class="fldGroupLabel">Shipping&nbsp;Method</div>
		<div class="bodyText fldText"><%=SmartValues(objRec("Ship_Method_Description"), "CStr")%></div>
	</div>
	<%if 1 = 2 then%>
	<div id="rewardvalueDetails" class="fldGroup" style="display: none;">
		<div class="fldGroupLabel">Reward&nbsp;Value</div>
		<div id="fld201" class="fld"><div id="fld201_label" class="fldLabel left_label">Reward&nbsp;Value&nbsp;Earned</div><div id="Order_TotRewardValue" class="bodyText fldText right_value"><%=SmartValues(objRec("Order_TotRewardValue"), "CStr")%></div></div>
	</div>
	<%end if%>
</div>

<div id="col1" class="fldColumn">
	<div id="billingAddressMail" class="fldGroup">
		<div class="fldGroupLabel">Billing&nbsp;Label</div>
		<div id="fld0" class="fld">
			<div id="billingMailingLabel" class="MailingLabel bodyText fldText">
				<%=SmartValues(objRec("BILLTO_First_Name"), "CStr") & "&nbsp;" & SmartValues(objRec("BILLTO_Last_Name"), "CStr")%><br>
				<%=SmartValues(objRec("BILLTO_Address_Line1"), "CStr")%><br>
				<%if Len(Trim(SmartValues(objRec("BILLTO_Address_Line2"), "CStr"))) > 0 then%><%=vbCrLf & SmartValues(objRec("BILLTO_Address_Line2"), "CStr") & "<br>"%><%end if%>
				<%=SmartValues(objRec("BILLTO_Address_City"), "CStr") & ",&nbsp;" & SmartValues(objRec("BILLTO_Address_State"), "CStr") & "&nbsp;" & SmartValues(objRec("BILLTO_Address_PostalCode"), "CStr")%>
				<%if SmartValues(objRec("BILLTO_Address_Country"), "CStr") <> "US" then Response.Write vbCrLf & "<br>" & SmartValues(objRec("BILLTO_Address_Country"), "CStr") & vbCrLf end if%>
			</div>
		</div>
	</div>
	<div id="billingAddress" class="fldGroup">
		<div class="fldGroupLabel">Billing&nbsp;Address</div>
		<div id="fld1" class="fld"><div class="fldLabel">Last&nbsp;Name</div><div id="BILLTO_Last_Name" class="bodyText fldText"><%=SmartValues(objRec("BILLTO_Last_Name"), "CStr")%></div></div>
		<div id="fld2" class="fld"><div class="fldLabel">First&nbsp;Name</div><div id="BILLTO_First_Name" class="bodyText fldText"><%=SmartValues(objRec("BILLTO_First_Name"), "CStr")%></div></div>
		<div id="fld3" class="fld"><div class="fldLabel">Address&nbsp;Line 1</div><div id="BILLTO_Address_Line1" class="bodyText fldText"><%=SmartValues(objRec("BILLTO_Address_Line1"), "CStr")%></div></div>
		<div id="fld4" class="fld"><div class="fldLabel">Address&nbsp;Line 2</div><div id="BILLTO_Address_Line2" class="bodyText fldText"><%=SmartValues(objRec("BILLTO_Address_Line2"), "CStr")%></div></div>
		<div id="fld5" class="fld"><div class="fldLabel">City</div><div id="BILLTO_Address_City" class="bodyText fldText"><%=SmartValues(objRec("BILLTO_Address_City"), "CStr")%></div></div>
		<div id="fld6" class="fld"><div class="fldLabel">State</div><div id="BILLTO_Address_State" class="bodyText fldText"><%=SmartValues(objRec("BILLTO_Address_State"), "CStr")%></div></div>
		<div id="fld7" class="fld"><div class="fldLabel">Country</div><div id="BILLTO_Address_Country" class="bodyText fldText"><%=SmartValues(objRec("BILLTO_Address_Country"), "CStr")%></div></div>
		<div id="fld8" class="fld"><div class="fldLabel">Postal&nbsp;Code</div><div id="BILLTO_Address_PostalCode" class="bodyText fldText"><%=SmartValues(objRec("BILLTO_Address_PostalCode"), "CStr")%></div></div>
		<div id="fld9" class="fld"><div class="fldLabel">Phone</div><div id="BILLTO_Phone" class="bodyText fldText"><%=SmartValues(objRec("BILLTO_Phone"), "CStr")%>&nbsp;<%=SmartValues(objRec("BILLTO_Phone_Ext"), "CStr")%></div></div>
		<div id="fld10" class="fld"><div class="fldLabel">Fax</div><div id="BILLTO_Fax" class="bodyText fldText"><%=SmartValues(objRec("BILLTO_Fax"), "CStr")%></div></div>
		<div id="fld11" class="fld"><div class="fldLabel">Notes:</div><div id="BILLTO_Shopping_Customer_Details_Notes" class="bodyText fldText" style="height: 120px;"><%=SmartValues(objRec("BILLTO_Shopping_Customer_Details_Notes"), "CStr")%></div></div>
	</div>
</div>

<div id="col3" class="fldColumn">
	<div id="shippingAddressMail" class="fldGroup">
		<div class="fldGroupLabel">Shipping&nbsp;Label</div>
		<div id="fld40" class="fld">
			<div id="shippingMailingLabel" class="MailingLabel bodyText fldText">
				<%=SmartValues(objRec("SHIPTO_First_Name"), "CStr") & "&nbsp;" & SmartValues(objRec("SHIPTO_Last_Name"), "CStr")%><br>
				<%=SmartValues(objRec("SHIPTO_Address_Line1"), "CStr")%><br>
				<%if Len(Trim(SmartValues(objRec("SHIPTO_Address_Line2"), "CStr"))) > 0 then%><%=vbCrLf & SmartValues(objRec("SHIPTO_Address_Line2"), "CStr") & "<br>"%><%end if%>
				<%=SmartValues(objRec("SHIPTO_Address_City"), "CStr") & ",&nbsp;" & SmartValues(objRec("SHIPTO_Address_State"), "CStr") & "&nbsp;" & SmartValues(objRec("SHIPTO_Address_PostalCode"), "CStr")%>
				<%if SmartValues(objRec("SHIPTO_Address_Country"), "CStr") <> "US" then Response.Write vbCrLf & "<br>" & SmartValues(objRec("SHIPTO_Address_Country"), "CStr") & vbCrLf end if%>
			</div>
		</div>
	</div>
	<div id="shippingAddress" class="fldGroup">
		<div class="fldGroupLabel">Shipping&nbsp;Address</div>
		<div id="fld41" class="fld"><div class="fldLabel">Last&nbsp;Name</div><div id="SHIPTO_Last_Name" class="bodyText fldText"><%=SmartValues(objRec("SHIPTO_Last_Name"), "CStr")%></div></div>
		<div id="fld42" class="fld"><div class="fldLabel">First&nbsp;Name</div><div id="SHIPTO_First_Name" class="bodyText fldText"><%=SmartValues(objRec("SHIPTO_First_Name"), "CStr")%></div></div>
		<div id="fld43" class="fld"><div class="fldLabel">Address&nbsp;Line 1</div><div id="SHIPTO_Address_Line1" class="bodyText fldText"><%=SmartValues(objRec("SHIPTO_Address_Line1"), "CStr")%></div></div>
		<div id="fld44" class="fld"><div class="fldLabel">Address&nbsp;Line 2</div><div id="SHIPTO_Address_Line2" class="bodyText fldText"><%=SmartValues(objRec("SHIPTO_Address_Line2"), "CStr")%></div></div>
		<div id="fld45" class="fld"><div class="fldLabel">City</div><div id="SHIPTO_Address_City" class="bodyText fldText"><%=SmartValues(objRec("SHIPTO_Address_City"), "CStr")%></div></div>
		<div id="fld46" class="fld"><div class="fldLabel">State</div><div id="SHIPTO_Address_State" class="bodyText fldText"><%=SmartValues(objRec("SHIPTO_Address_State"), "CStr")%></div></div>
		<div id="fld47" class="fld"><div class="fldLabel">Country</div><div id="SHIPTO_Address_Country" class="bodyText fldText"><%=SmartValues(objRec("SHIPTO_Address_Country"), "CStr")%></div></div>
		<div id="fld48" class="fld"><div class="fldLabel">Postal&nbsp;Code</div><div id="SHIPTO_Address_PostalCode" class="bodyText fldText"><%=SmartValues(objRec("SHIPTO_Address_PostalCode"), "CStr")%></div></div>
		<div id="fld49" class="fld"><div class="fldLabel">Phone</div><div id="SHIPTO_Phone" class="bodyText fldText"><%=SmartValues(objRec("SHIPTO_Phone"), "CStr")%>&nbsp;<%=SmartValues(objRec("SHIPTO_Phone_Ext"), "CStr")%></div></div>
		<div id="fld50" class="fld"><div class="fldLabel">Fax</div><div id="SHIPTO_Fax" class="bodyText fldText"><%=SmartValues(objRec("SHIPTO_Fax"), "CStr")%></div></div>
		<div id="fld51" class="fld"><div class="fldLabel">Notes:</div><div id="SHIPTO_Shopping_Customer_Details_Notes" class="bodyText fldText" style="height: 120px;"><%=SmartValues(objRec("SHIPTO_Shopping_Customer_Details_Notes"), "CStr")%></div></div>
	</div>
</div>
</form>

<%
end if
objRec.Close
%>


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