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
		#MailingLabel {padding: 10px; font-family: Courier; clip: auto; overflow: auto;}
		#fld2, #fld6, #fld8 {width: 136px; margin-right: 0px;}


		#fld12_label, #fld13_label, #fld14_label, #fld15_label, #fld16_label
		{
			border: 0px;
			margin: 0px;
			width: 60%;
			float: left;
		}

		.fldPriceCurrencySymbol
		{
			text-align: left;
			float: left;
			padding-right: 2px;
			color: #666;
		}
		.fldPrice
		{
			width: 100%;
			text-align: right;
			padding-right: 2px;
		}

		#fld12, #fld13, #fld14, #fld15, #fld16
		{
			width: 100%;
			clear: none;
			margin: 0px;
			margin-top: 0px;
			margin-right: 2px;
			border-top: 1px solid #999;
			margin-bottom: 3px;
		}
		#fld12 { margin-bottom: 4px; border-top: 0px;}
		#fld16 { border-top: 2px solid #000; margin-bottom: 2px;}
		#fld16, #fld16_label, #fld16_currencysymbol { color: #000;}
		#Order_GrandTotal {background-color: #fff;}

		#fld17, #fld18, #fld19, #fld20, #fld21
		{
			width: 100%;
			clear: none;
			margin: 0px;
			margin-top: 0px;
			margin-right: 0px;
			margin-bottom: 4px;
		}
		#fld17_label, #fld18_label, #fld19_label, #fld20_label, #fld21_label
		{
			border: 0px;
			margin: 0px;
			width: 50%;
			float: left;
		}
		#Card_FullName, #Card_Type_ID, #Card_Number_Unencrypted, #Card_SecurityCode_Unencrypted, #Card_Expires
		{
			width: 50%;
			background-color: #fff;
			text-align: right;
			padding-right: 2px;
			float: left;
		}
		
	</style>
	<script type="text/javascript" language="javascript">
	</script>
</head>
<body bgcolor="cccccc" topmargin=0 leftmargin=0 marginheight=0 marginwidth=0>

<%
SQLStr = "sp_shopping_order_details_by_orderID " & Order_ID
'Response.Write SQLStr
objRec.Open SQLStr, objConn, adOpenStatic, adLockReadOnly, adCmdText
if not objRec.EOF then
	if 1 = 2 then
%>
<div id="col1" class="fldColumn">
	<div id="billingAddressMail" class="fldGroup">
		<div class="fldGroupLabel">Billing&nbsp;Label</div>
		<div id="fld0" class="fld">
			<div id="MailingLabel" class="bodyText fldText">
				<%=SmartValues(objRec("BILLTO_First_Name"), "CStr") & "&nbsp;" & SmartValues(objRec("BILLTO_Last_Name"), "CStr")%><br>
				<%=SmartValues(objRec("BILLTO_Address_Line1"), "CStr") & "<br>" & vbCrLf & SmartValues(objRec("BILLTO_Address_Line2"), "CStr")%><br>
				<%=SmartValues(objRec("BILLTO_Address_City"), "CStr") & ",&nbsp;" & SmartValues(objRec("BILLTO_Address_State"), "CStr") & "&nbsp;" & SmartValues(objRec("BILLTO_Address_PostalCode"), "CStr")%>
				<%if SmartValues(objRec("BILLTO_Address_Country"), "CStr") <> "US" then Response.Write vbCrLf & "<br>" & SmartValues(objRec("BILLTO_Address_Country"), "CStr") & vbCrLf end if%>
			</div>
		</div>
	</div>
	<div id="shippingAddressMail" class="fldGroup">
		<div class="fldGroupLabel">Shipping&nbsp;Label</div>
		<div id="fld0" class="fld">
			<div id="MailingLabel" class="bodyText fldText">
				<%=SmartValues(objRec("SHIPTO_First_Name"), "CStr") & "&nbsp;" & SmartValues(objRec("SHIPTO_Last_Name"), "CStr")%><br>
				<%=SmartValues(objRec("SHIPTO_Address_Line1"), "CStr") & "<br>" & vbCrLf & SmartValues(objRec("SHIPTO_Address_Line2"), "CStr")%><br>
				<%=SmartValues(objRec("SHIPTO_Address_City"), "CStr") & ",&nbsp;" & SmartValues(objRec("SHIPTO_Address_State"), "CStr") & "&nbsp;" & SmartValues(objRec("SHIPTO_Address_PostalCode"), "CStr")%>
				<%if SmartValues(objRec("SHIPTO_Address_Country"), "CStr") <> "US" then Response.Write vbCrLf & "<br>" & SmartValues(objRec("SHIPTO_Address_Country"), "CStr") & vbCrLf end if%>
			</div>
		</div>
	</div>
</div>
<div id="col2" class="fldColumn">
	<div id="billingAmount" class="fldGroup">
		<div class="fldGroupLabel">Order&nbsp;Amount</div>
		<div id="fld12" class="fld"><div id="fld12_label" class="fldLabel">Subtotal</div><div id="Order_CouponsRedeemed" class="bodyText fldPrice"><div id="fld12_currencysymbol" class="fldPriceCurrencySymbol">$</div><%=SmartValues(objRec("Order_Subtotal"), "FormatNumber")%></div></div>
		<div id="fld13" class="fld"><div id="fld13_label" class="fldLabel">Coupons</div><div id="Order_CouponsRedeemed" class="bodyText fldPrice"><div id="fld13_currencysymbol" class="fldPriceCurrencySymbol">$</div><%=SmartValues(objRec("Order_CouponsRedeemed"), "FormatNumber")%></div></div>
		<div id="fld14" class="fld"><div id="fld14_label" class="fldLabel">Tax</div><div id="Order_TaxCost" class="bodyText fldPrice"><div id="fld14_currencysymbol" class="fldPriceCurrencySymbol">$</div><%=SmartValues(objRec("Order_TaxCost"), "FormatNumber")%></div></div>
		<div id="fld15" class="fld"><div id="fld15_label" class="fldLabel">Shipping</div><div id="Order_ShippingCost" class="bodyText fldPrice"><div id="fld15_currencysymbol" class="fldPriceCurrencySymbol">$</div><%=SmartValues(objRec("Order_ShippingCost"), "FormatNumber")%></div></div>
		<div id="fld16" class="fld"><div id="fld16_label" class="fldLabel">Grand&nbsp;Total</div><div id="Order_GrandTotal" class="bodyText fldPrice"><div id="fld16_currencysymbol" class="fldPriceCurrencySymbol">$</div><%=SmartValues(objRec("Order_GrandTotal"), "FormatNumber")%></div></div>
	</div>

	<div id="billingAccount" class="fldGroup">
		<div class="fldGroupLabel">Payment&nbsp;Information</div>
		<div id="fld17" class="fld"><div id="fld17_label" class="fldLabel">Name&nbsp;on&nbsp;Card</div><div id="Card_FullName" class="bodyText fldText"><%=SmartValues(objRec("Card_FullName"), "CStr")%></div></div>
		<div id="fld18" class="fld"><div id="fld18_label" class="fldLabel">Card&nbsp;Type</div><div id="Card_Type_ID" class="bodyText fldText"><%=SmartValues(objRec("Card_Type_Name"), "CStr")%></div></div>
		<div id="fld19" class="fld"><div id="fld19_label" class="fldLabel">Card&nbsp;Number</div><div id="Card_Number_Unencrypted" class="bodyText fldText"><%=SmartValues(objRec("Card_Number_Unencrypted"), "CStr")%></div></div>
		<div id="fld20" class="fld"><div id="fld20_label" class="fldLabel">Card&nbsp;Security&nbsp;Code</div><div id="Card_SecurityCode_Unencrypted" class="bodyText fldText"><%=SmartValues(objRec("Card_SecurityCode_Unencrypted"), "CStr")%></div></div>
		<div id="fld21" class="fld"><div id="fld21_label" class="fldLabel">Expiration&nbsp;Date</div><div id="Card_Expires" class="bodyText fldText"><%=SmartValues(objRec("Card_Expires_Month"), "CStr")%>/<%=SmartValues(objRec("Card_Expires_Year"), "CStr")%></div></div>
	</div>
</div>
<%
	end if
%>
<div id="col1" class="fldColumn">
	<div id="billingAddress" class="fldGroup">
		<div class="fldGroupLabel">Billing&nbsp;Information</div>
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
		<div id="fld11" class="fld"><div class="fldLabel">Notes:</div><div id="BILLTO_Shopping_Customer_Details_Notes" class="bodyText fldText"><%=SmartValues(objRec("BILLTO_Shopping_Customer_Details_Notes"), "CStr")%></div></div>
	</div>

	<div id="billingAddressMail" class="fldGroup">
		<div class="fldGroupLabel">Billing&nbsp;Label</div>
		<div id="fld0" class="fld">
			<div id="MailingLabel" class="bodyText fldText">
				<%=SmartValues(objRec("BILLTO_First_Name"), "CStr") & "&nbsp;" & SmartValues(objRec("BILLTO_Last_Name"), "CStr")%><br>
				<%=SmartValues(objRec("BILLTO_Address_Line1"), "CStr") & "<br>" & vbCrLf & SmartValues(objRec("BILLTO_Address_Line2"), "CStr")%><br>
				<%=SmartValues(objRec("BILLTO_Address_City"), "CStr") & ",&nbsp;" & SmartValues(objRec("BILLTO_Address_State"), "CStr") & "&nbsp;" & SmartValues(objRec("BILLTO_Address_PostalCode"), "CStr")%>
				<%if SmartValues(objRec("BILLTO_Address_Country"), "CStr") <> "US" then Response.Write vbCrLf & "<br>" & SmartValues(objRec("BILLTO_Address_Country"), "CStr") & vbCrLf end if%>
			</div>
		</div>
	</div>
</div>

<div id="col2" class="fldColumn">
	<div id="billingAmount" class="fldGroup">
		<div class="fldGroupLabel">Order&nbsp;Amount</div>
		<div id="fld12" class="fld"><div id="fld12_label" class="fldLabel">Subtotal</div><div id="Order_CouponsRedeemed" class="bodyText fldPrice"><div id="fld12_currencysymbol" class="fldPriceCurrencySymbol">$</div><%=SmartValues(objRec("Order_Subtotal"), "FormatNumber")%></div></div>
		<div id="fld13" class="fld"><div id="fld13_label" class="fldLabel">Coupons</div><div id="Order_CouponsRedeemed" class="bodyText fldPrice"><div id="fld13_currencysymbol" class="fldPriceCurrencySymbol">$</div><%=SmartValues(objRec("Order_CouponsRedeemed"), "FormatNumber")%></div></div>
		<div id="fld14" class="fld"><div id="fld14_label" class="fldLabel">Tax</div><div id="Order_TaxCost" class="bodyText fldPrice"><div id="fld14_currencysymbol" class="fldPriceCurrencySymbol">$</div><%=SmartValues(objRec("Order_TaxCost"), "FormatNumber")%></div></div>
		<div id="fld15" class="fld"><div id="fld15_label" class="fldLabel">Shipping</div><div id="Order_ShippingCost" class="bodyText fldPrice"><div id="fld15_currencysymbol" class="fldPriceCurrencySymbol">$</div><%=SmartValues(objRec("Order_ShippingCost"), "FormatNumber")%></div></div>
		<div id="fld16" class="fld"><div id="fld16_label" class="fldLabel">Grand&nbsp;Total</div><div id="Order_GrandTotal" class="bodyText fldPrice"><div id="fld16_currencysymbol" class="fldPriceCurrencySymbol">$</div><%=SmartValues(objRec("Order_GrandTotal"), "FormatNumber")%></div></div>
	</div>

	<div id="billingAccount" class="fldGroup">
		<div class="fldGroupLabel">Payment&nbsp;Information</div>
		<div id="fld17" class="fld"><div id="fld17_label" class="fldLabel">Name&nbsp;on&nbsp;Card</div><div id="Card_FullName" class="bodyText fldText"><%=SmartValues(objRec("Card_FullName"), "CStr")%></div></div>
		<div id="fld18" class="fld"><div id="fld18_label" class="fldLabel">Card&nbsp;Type</div><div id="Card_Type_ID" class="bodyText fldText"><%=SmartValues(objRec("Card_Type_Name"), "CStr")%></div></div>
		<div id="fld19" class="fld"><div id="fld19_label" class="fldLabel">Card&nbsp;Number</div><div id="Card_Number_Unencrypted" class="bodyText fldText"><%=SmartValues(objRec("Card_Number_Unencrypted"), "CStr")%></div></div>
		<div id="fld20" class="fld"><div id="fld20_label" class="fldLabel">Card&nbsp;Security&nbsp;Code</div><div id="Card_SecurityCode_Unencrypted" class="bodyText fldText"><%=SmartValues(objRec("Card_SecurityCode_Unencrypted"), "CStr")%></div></div>
		<div id="fld21" class="fld"><div id="fld21_label" class="fldLabel">Expiration&nbsp;Date</div><div id="Card_Expires" class="bodyText fldText"><%=SmartValues(objRec("Card_Expires_Month"), "CStr")%>/<%=SmartValues(objRec("Card_Expires_Year"), "CStr")%></div></div>
	</div>
</div>

<div id="col3" class="fldColumn">
	<div id="shippingAddress" class="fldGroup">
		<div class="fldGroupLabel">Shipping&nbsp;Information</div>
		<div id="fld1" class="fld"><div class="fldLabel">Last&nbsp;Name</div><div id="SHIPTO_Last_Name" class="bodyText fldText"><%=SmartValues(objRec("SHIPTO_Last_Name"), "CStr")%></div></div>
		<div id="fld2" class="fld"><div class="fldLabel">First&nbsp;Name</div><div id="SHIPTO_First_Name" class="bodyText fldText"><%=SmartValues(objRec("SHIPTO_First_Name"), "CStr")%></div></div>
		<div id="fld3" class="fld"><div class="fldLabel">Address&nbsp;Line 1</div><div id="SHIPTO_Address_Line1" class="bodyText fldText"><%=SmartValues(objRec("SHIPTO_Address_Line1"), "CStr")%></div></div>
		<div id="fld4" class="fld"><div class="fldLabel">Address&nbsp;Line 2</div><div id="SHIPTO_Address_Line2" class="bodyText fldText"><%=SmartValues(objRec("SHIPTO_Address_Line2"), "CStr")%></div></div>
		<div id="fld5" class="fld"><div class="fldLabel">City</div><div id="SHIPTO_Address_City" class="bodyText fldText"><%=SmartValues(objRec("SHIPTO_Address_City"), "CStr")%></div></div>
		<div id="fld6" class="fld"><div class="fldLabel">State</div><div id="SHIPTO_Address_State" class="bodyText fldText"><%=SmartValues(objRec("SHIPTO_Address_State"), "CStr")%></div></div>
		<div id="fld7" class="fld"><div class="fldLabel">Country</div><div id="SHIPTO_Address_Country" class="bodyText fldText"><%=SmartValues(objRec("SHIPTO_Address_Country"), "CStr")%></div></div>
		<div id="fld8" class="fld"><div class="fldLabel">Postal&nbsp;Code</div><div id="SHIPTO_Address_PostalCode" class="bodyText fldText"><%=SmartValues(objRec("SHIPTO_Address_PostalCode"), "CStr")%></div></div>
		<div id="fld9" class="fld"><div class="fldLabel">Phone</div><div id="SHIPTO_Phone" class="bodyText fldText"><%=SmartValues(objRec("SHIPTO_Phone"), "CStr")%>&nbsp;<%=SmartValues(objRec("SHIPTO_Phone_Ext"), "CStr")%></div></div>
		<div id="fld10" class="fld"><div class="fldLabel">Fax</div><div id="SHIPTO_Fax" class="bodyText fldText"><%=SmartValues(objRec("SHIPTO_Fax"), "CStr")%></div></div>
		<div id="fld11" class="fld"><div class="fldLabel">Notes:</div><div id="SHIPTO_Shopping_Customer_Details_Notes" class="bodyText fldText"><%=SmartValues(objRec("SHIPTO_Shopping_Customer_Details_Notes"), "CStr")%></div></div>
	</div>

	<div id="shippingAddressMail" class="fldGroup">
		<div class="fldGroupLabel">Shipping&nbsp;Label</div>
		<div id="fld0" class="fld">
			<div id="MailingLabel" class="bodyText fldText">
				<%=SmartValues(objRec("SHIPTO_First_Name"), "CStr") & "&nbsp;" & SmartValues(objRec("SHIPTO_Last_Name"), "CStr")%><br>
				<%=SmartValues(objRec("SHIPTO_Address_Line1"), "CStr") & "<br>" & vbCrLf & SmartValues(objRec("SHIPTO_Address_Line2"), "CStr")%><br>
				<%=SmartValues(objRec("SHIPTO_Address_City"), "CStr") & ",&nbsp;" & SmartValues(objRec("SHIPTO_Address_State"), "CStr") & "&nbsp;" & SmartValues(objRec("SHIPTO_Address_PostalCode"), "CStr")%>
				<%if SmartValues(objRec("SHIPTO_Address_Country"), "CStr") <> "US" then Response.Write vbCrLf & "<br>" & SmartValues(objRec("SHIPTO_Address_Country"), "CStr") & vbCrLf end if%>
			</div>
		</div>
	</div>
</div>
<%
	'    --Shopping_Order
	'    a.[ID],
	'    a.[ID] As Order_ID,
	'    a.Shopping_Customer_ID,
	'    a.Order_Status_ID,
	'    a.Order_Subtotal,
	'    a.Order_CouponsRedeemed,
	'    a.Order_TaxCost,
	'    a.Order_ShippingCost,
	'    a.Order_GrandTotal,
	'    a.Card_FullName,
	'    a.Card_Type_ID,
	'    dbo.udf_s_Crypto_DecryptString(a.Card_Number_Encrypted, COALESCE(dbo.udf_s_FormatGUID(b.[GUID]), @tempGUID)) As Card_Number_Unencrypted,
	'    a.Card_Number_LastFour_Unencrypted,
	'    dbo.udf_s_Crypto_DecryptString(a.Card_SecurityCode_Encrypted, COALESCE(dbo.udf_s_FormatGUID(b.[GUID]), @tempGUID)) As Card_SecurityCode_Unencrypted,
	'    a.Card_Expires_Month,
	'    a.Card_Expires_Year,
	'    a.BILLTO_Last_Name,
	'    a.BILLTO_First_Name,
	'    a.BILLTO_Address_Line1,
	'    a.BILLTO_Address_Line2,
	'    a.BILLTO_Address_City,
	'    a.BILLTO_Address_State,
	'    a.BILLTO_Address_Country,
	'    a.BILLTO_Address_PostalCode,
	'    a.BILLTO_Phone,
	'    a.BILLTO_Phone_Ext,
	'    a.BILLTO_Fax,
	'    a.BILLTO_Shopping_Customer_Details_Notes,
	'    a.SHIPTO_Last_Name,
	'    a.SHIPTO_First_Name,
	'    a.SHIPTO_Address_Line1,
	'    a.SHIPTO_Address_Line2,
	'    a.SHIPTO_Address_City,
	'    a.SHIPTO_Address_State,
	'    a.SHIPTO_Address_Country,
	'    a.SHIPTO_Address_PostalCode,
	'    a.SHIPTO_Phone,
	'    a.SHIPTO_Phone_Ext,
	'    a.SHIPTO_Fax,
	'    a.SHIPTO_Shopping_Customer_Details_Notes,
	'    a.Date_Created,
	'    a.Date_Last_Modified,
	'    --Shopping_Customer
	'    b.Email_Address As Shopping_Customer_Email_Address,
	'    b.Last_Name As Shopping_Customer_Last_Name,
	'    b.First_Name As Shopping_Customer_First_Name,
	'    b.Organization As Shopping_Customer_Organization,
	'    b.Gender As Shopping_Customer_Gender,
	'    --Shopping_Order_Status
	'    c.Status_Name As Order_Status_Name,
	'    --Shopping_Card_Types
	'    d.Credit_Card_Name As Card_Type_Name
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