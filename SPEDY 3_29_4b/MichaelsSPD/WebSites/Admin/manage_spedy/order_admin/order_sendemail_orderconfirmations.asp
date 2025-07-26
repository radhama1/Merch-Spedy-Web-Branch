<%@ LANGUAGE=VBSCRIPT%>
<%
Option Explicit
Response.Buffer = True
Response.Expires = -1441
%>
<!--#include file="./../../app_include/_globalInclude.asp"-->
<%
Dim objConn, objRec, SQLStr, connStr, i
Dim SUCCESSFLAG
Dim Order_ID, Store_ID, Requested_Action, Order_Date
Dim isTestMode, Store_Name, Store_URL, Store_CC_Email
Dim Store_Contact_Name
Dim Store_Contact_Phone1
Dim Store_Contact_Phone2
Dim Store_Contact_Fax1
Dim Store_Contact_Fax2
Dim Store_Address_Line1
Dim Store_Address_Line2
Dim Store_City
Dim Store_State
Dim Store_PostalCode
Dim Store_Country
Dim First_Name, Last_Name
Dim Email_Address, Organization
Dim BILLTO_First_Name, BILLTO_Last_Name
Dim BILLTO_Address_Line1, BILLTO_Address_Line2, BILLTO_Address_City, BILLTO_Address_State, BILLTO_Address_PostalCode, BILLTO_Address_Country, BILLTO_Phone, BILLTO_Phone_Ext, BILLTO_Fax, BILLTO_Shopping_Customer_Details_Notes
Dim SHIPTO_First_Name, SHIPTO_Last_Name
Dim SHIPTO_Address_Line1, SHIPTO_Address_Line2, SHIPTO_Address_City, SHIPTO_Address_State, SHIPTO_Address_PostalCode, SHIPTO_Address_Country, SHIPTO_Phone, SHIPTO_Phone_Ext, SHIPTO_Fax, SHIPTO_Shopping_Customer_Details_Notes
Dim Order_Subtotal, Order_CouponsRedeemed, Order_TaxCost, Order_ShippingMethod, Order_ShippingCost, Order_HandlingFee, Order_GiftCardsApplied, Order_GrandTotal, Order_TotRewardValue
Dim Card_FullName, Card_Number_LastFour_Unencrypted, Card_Expires_Month, Card_Expires_Year
Dim Shopping_Customer_ID
Dim Order_Status_ID
Dim Funds_Captured
Dim Funds_Refunded
Dim Trans_Voided
Dim Trans_Declined
Dim Ship_Method_Description
Dim Ship_Method_Code
Dim Date_Order_Shipped
Dim Shipment_Tracking_Number
Dim Actual_Ship_Method
Dim Tot_Quantity_Requested
Dim Tot_Quantity_Shipped

SUCCESSFLAG = false
Order_ID = checkQueryID(Request("oid"), 0)
Requested_Action = checkQueryID(Request("a"), 0)

Set objConn = Server.CreateObject("ADODB.Connection")
Set objRec = Server.CreateObject("ADODB.RecordSet")
connStr = Application.Value("connStr")
objConn.Open connStr

if Order_ID > 0 then

	SQLStr = "sp_shopping_order_details_by_orderID '0" & Order_ID & "'"
	'Response.Write SQLStr
	objRec.Open SQLStr, objConn, adOpenStatic, adLockReadOnly, adCmdText
	if not objRec.EOF then
		Store_ID = SmartValues(objRec("Shopping_Store_ID"), "CLng")
		Order_Date = SmartValues(objRec("Date_Created"), "CDate")
		First_Name = SmartValues(objRec("Shopping_Customer_First_Name"), "CStr")
		Last_Name = SmartValues(objRec("Shopping_Customer_Last_Name"), "CStr")
		Email_Address = SmartValues(objRec("Shopping_Customer_Email_Address"), "CStr")
		Organization = SmartValues(objRec("Shopping_Customer_Organization"), "CStr")
		BILLTO_First_Name = SmartValues(objRec("BILLTO_First_Name"), "CStr")
		BILLTO_Last_Name = SmartValues(objRec("BILLTO_Last_Name"), "CStr")
		BILLTO_Address_Line1 = SmartValues(objRec("BILLTO_Address_Line1"), "CStr")
		BILLTO_Address_Line2 = SmartValues(objRec("BILLTO_Address_Line2"), "CStr")
		BILLTO_Address_City = SmartValues(objRec("BILLTO_Address_City"), "CStr")
		BILLTO_Address_State = SmartValues(objRec("BILLTO_Address_State"), "CStr")
		BILLTO_Address_PostalCode = SmartValues(objRec("BILLTO_Address_PostalCode"), "CStr")
		BILLTO_Address_Country = SmartValues(objRec("BILLTO_Address_Country"), "CStr")
		BILLTO_Phone = SmartValues(objRec("BILLTO_Phone"), "CStr")
		BILLTO_Fax = SmartValues(objRec("BILLTO_Fax"), "CStr")
		BILLTO_Shopping_Customer_Details_Notes = SmartValues(objRec("BILLTO_Shopping_Customer_Details_Notes"), "CStr")
		SHIPTO_First_Name = SmartValues(objRec("SHIPTO_First_Name"), "CStr")
		SHIPTO_Last_Name = SmartValues(objRec("SHIPTO_Last_Name"), "CStr")
		SHIPTO_Address_Line1 = SmartValues(objRec("SHIPTO_Address_Line1"), "CStr")
		SHIPTO_Address_Line2 = SmartValues(objRec("SHIPTO_Address_Line2"), "CStr")
		SHIPTO_Address_City = SmartValues(objRec("SHIPTO_Address_City"), "CStr")
		SHIPTO_Address_State = SmartValues(objRec("SHIPTO_Address_State"), "CStr")
		SHIPTO_Address_PostalCode = SmartValues(objRec("SHIPTO_Address_PostalCode"), "CStr")
		SHIPTO_Address_Country = SmartValues(objRec("SHIPTO_Address_Country"), "CStr")
		SHIPTO_Phone = SmartValues(objRec("SHIPTO_Phone"), "CStr")
		SHIPTO_Fax = SmartValues(objRec("SHIPTO_Fax"), "CStr")
		SHIPTO_Shopping_Customer_Details_Notes = SmartValues(objRec("SHIPTO_Shopping_Customer_Details_Notes"), "CStr")
		Order_Subtotal = SmartValues(objRec("Order_Subtotal"), "CDbl")
		Order_CouponsRedeemed = SmartValues(objRec("Order_CouponsRedeemed"), "CDbl")
		Order_TaxCost = SmartValues(objRec("Order_TaxCost"), "CDbl")
		Order_ShippingMethod = SmartValues(objRec("Ship_Method_Description"), "CStr")
		Order_ShippingCost = SmartValues(objRec("Order_ShippingCost"), "CDbl")
		Order_HandlingFee = SmartValues(objRec("Order_HandlingFee"), "CDbl")
		Order_GiftCardsApplied = SmartValues(objRec("Order_GiftCardsApplied"), "CDbl")
		Order_GrandTotal = SmartValues(objRec("Order_GrandTotal"), "CDbl")
		Order_TotRewardValue = SmartValues(objRec("Order_TotRewardValue"), "CDbl")
		Card_FullName = SmartValues(objRec("Card_FullName"), "CStr")
		Card_Number_LastFour_Unencrypted = SmartValues(objRec("Card_Number_LastFour_Unencrypted"), "CStr")
		Card_Expires_Month = SmartValues(objRec("Card_Expires_Month"), "CStr")
		Card_Expires_Year = SmartValues(objRec("Card_Expires_Year"), "CStr")
		Shopping_Customer_ID = SmartValues(objRec("Shopping_Customer_ID"), "CLng")
		Order_Status_ID = SmartValues(objRec("Order_Status_ID"), "CLng")
		Funds_Captured = SmartValues(objRec("Funds_Captured"), "CBool")
		Funds_Refunded = SmartValues(objRec("Funds_Refunded"), "CBool")
		Trans_Voided = SmartValues(objRec("Trans_Voided"), "CBool")
		Trans_Declined = SmartValues(objRec("Trans_Declined"), "CBool")
		Ship_Method_Description = SmartValues(objRec("Ship_Method_Description"), "CStr")
		Ship_Method_Code = SmartValues(objRec("Ship_Method_Code"), "CStr")
		Date_Order_Shipped = SmartValues(objRec("Date_Order_Shipped"), "CStr")
		Shipment_Tracking_Number = SmartValues(objRec("Shipment_Tracking_Number"), "CStr")
		Actual_Ship_Method = SmartValues(objRec("Actual_Ship_Method"), "CStr")
		Tot_Quantity_Requested = SmartValues(objRec("Tot_Quantity_Requested"), "CLng")
		Tot_Quantity_Shipped = SmartValues(objRec("Tot_Quantity_Shipped"), "CLng")
	end if
	objRec.Close

	if Store_ID > 0 then
		SQLStr = "SELECT * FROM Shopping_Store WHERE ID = '0" & Store_ID & "'"
		'Response.Write SQLStr
		objRec.Open SQLStr, objConn, adOpenStatic, adLockReadOnly, adCmdText
		if not objRec.EOF then
			isTestMode = SmartValues(objRec("Test_Mode"), "CBool")
			Store_Name = SmartValues(objRec("Store_Name"), "CStr")
			Store_URL = SmartValues(objRec("Store_URL"), "CStr")
			Store_CC_Email = SmartValues(objRec("Store_CC_Email"), "CStr")
			Store_Contact_Name = SmartValues(objRec("Store_Contact_Name"), "CStr")
			Store_Contact_Phone1 = SmartValues(objRec("Store_Contact_Phone1"), "CStr")
			Store_Contact_Phone2 = SmartValues(objRec("Store_Contact_Phone2"), "CStr")
			Store_Contact_Fax1 = SmartValues(objRec("Store_Contact_Fax1"), "CStr")
			Store_Contact_Fax2 = SmartValues(objRec("Store_Contact_Fax2"), "CStr")
			Store_Address_Line1 = SmartValues(objRec("Store_Address_Line1"), "CStr")
			Store_Address_Line2 = SmartValues(objRec("Store_Address_Line2"), "CStr")
			Store_City = SmartValues(objRec("Store_City"), "CStr")
			Store_State = SmartValues(objRec("Store_State"), "CStr")
			Store_PostalCode = SmartValues(objRec("Store_PostalCode"), "CStr")
			Store_Country = SmartValues(objRec("Store_Country"), "CStr")
		end if
		objRec.Close

		Select Case Requested_Action
			Case 1 'Send order confirmation email to customer
				if not isTestMode then 
					Call SendMail("Valued Customer", Email_Address)
				end if
				Call SendMail("drugsourcesupport@novalibra.com", "drugsourcesupport@novalibra.com")
				'Call SendMail("Ken Wallace", "ken.wallace@novalibra.com")
				SUCCESSFLAG = true

			Case 2 'Send order confirmation email to admin
				Call SendMail(Store_CC_Email, Store_CC_Email)
				Call SendMail("drugsourcesupport@novalibra.com", "drugsourcesupport@novalibra.com")
				'Call SendMail("Ken Wallace", "ken.wallace@novalibra.com")
				SUCCESSFLAG = true

			Case 3 'Send html-formatted order confirmation email to admin
				Call SendMailHTML(Store_CC_Email, Store_CC_Email)
				Call SendMailHTML("drugsourcesupport@novalibra.com", "drugsourcesupport@novalibra.com")
				'Call SendMailHTML("Ken Wallace", "ken.wallace@novalibra.com")
				SUCCESSFLAG = true

		End Select
	end if
end if 
%>
<html>
<head>
	<title>Send Email</title>
	<style type="text/css">
		BODY * 
		{
			font-size: 11px; 
			font-family: Arial, Verdana;
		}
	</style>
</head>
<body bgcolor="cccccc" topmargin=10 leftmargin=10 marginheight=10 marginwidth=10>

<div style="margin-top: 20px; text-align: center;">
<% if SUCCESSFLAG = true then%>
	<div style="font-size: 18px; font-weight: bold;">Success!</div>
	<div>Your email has been sent.</div>
	<div style="margin-top: 20px;"><input type="button" name="btnClose" value="Okay, Close this Window." onclick="self.close();"></div>
<%else%>
	<div style="font-size: 18px; font-weight: bold;">Sorry. :(</div>
	<div>No email has been sent.</div>
	<div style="margin-top: 20px;"><input type="button" name="btnClose" value="Okay, Close this Window." onclick="self.close();" ID="Button1"></div>
<%end if%>
</div>

</body>
</html>
<%
Call DB_CleanUp

Sub SendMail(locRecipName, locRecipAddr)
	Dim Mailer, BodyText
	Set Mailer			= Server.CreateObject("SMTPsvg.Mailer")

	Mailer.RemoteHost	= Application.Value("SMTP_SERVER_URL")
	Mailer.UserName		= Application.Value("SMTP_USERNAME")
	Mailer.Password		= Application.Value("SMTP_PASSWORD")

	Mailer.FromAddress	= Store_CC_Email
	Mailer.FromName		= Store_Name & " Order Confirmation"
	Mailer.AddRecipient locRecipName, locRecipAddr
	
	Mailer.Subject		= Store_Name & " Order Confirmation - Order " & Order_ID
	BodyText			= "The following order was submitted to " & Store_Name & " on " & FormatDateTime(Order_Date, vbShortDate) & vbCrLf

	BodyText = BodyText & vbCrLf	
	BodyText = BodyText & "Customer Information:" & vbCrLf
	if Len(First_Name) > 0 or Len(Last_Name) > 0 then
		if Len(First_Name) > 0 then BodyText = BodyText & vbTab & First_Name & " "
		if Len(Last_Name) > 0 then BodyText = BodyText & Last_Name
	end if
	BodyText = BodyText & vbCrLf	
	if Len(Email_Address) > 0 then BodyText = BodyText & vbTab & Email_Address & vbCrLf
	if Len(Organization) > 0 then BodyText = BodyText & vbTab & Organization & vbCrLf

	BodyText = BodyText & vbCrLf	
	BodyText = BodyText & "Bill To:" & vbCrLf
	if Len(BILLTO_First_Name) > 0 or Len(BILLTO_Last_Name) > 0 then
		if Len(BILLTO_First_Name) > 0 then BodyText = BodyText & vbTab & BILLTO_First_Name & " "
		if Len(BILLTO_Last_Name) > 0 then BodyText = BodyText & BILLTO_Last_Name
	end if
	BodyText = BodyText & vbCrLf	
	if Len(BILLTO_Address_Line1) > 0 then BodyText = BodyText & vbTab & BILLTO_Address_Line1 & vbCrLf
	if Len(BILLTO_Address_Line2) > 0 then BodyText = BodyText & vbTab & BILLTO_Address_Line2 & vbCrLf
	if Len(BILLTO_Address_City) > 0 then BodyText = BodyText & vbTab & BILLTO_Address_City
	if Len(BILLTO_Address_City) > 0 and Len(BILLTO_Address_State) > 0 then BodyText = BodyText & ", "
	if Len(BILLTO_Address_State) > 0 then BodyText = BodyText & BILLTO_Address_State & " "
	if Len(BILLTO_Address_PostalCode) > 0 then BodyText = BodyText & BILLTO_Address_PostalCode & vbCrLf
	if Len(BILLTO_Address_Country) > 0 then BodyText = BodyText & vbTab & BILLTO_Address_Country & vbCrLf
	if Len(BILLTO_Phone) > 0 then BodyText = BodyText & vbTab & BILLTO_Phone & " " & BILLTO_Phone_Ext & vbCrLf
	if Len(BILLTO_Fax) > 0 then BodyText = BodyText & vbTab & BILLTO_Fax & vbCrLf
	if Len(BILLTO_Shopping_Customer_Details_Notes) > 0 then BodyText = BodyText & vbTab & BILLTO_Shopping_Customer_Details_Notes & vbCrLf

	BodyText = BodyText & vbCrLf	
	BodyText = BodyText & "Ship To:" & vbCrLf
	if Len(SHIPTO_First_Name) > 0 or Len(SHIPTO_Last_Name) > 0 then
		if Len(SHIPTO_First_Name) > 0 then BodyText = BodyText & vbTab & SHIPTO_First_Name & " "
		if Len(SHIPTO_Last_Name) > 0 then BodyText = BodyText & SHIPTO_Last_Name
	end if
	BodyText = BodyText & vbCrLf	
	if Len(SHIPTO_Address_Line1) > 0 then BodyText = BodyText & vbTab & SHIPTO_Address_Line1 & vbCrLf
	if Len(SHIPTO_Address_Line2) > 0 then BodyText = BodyText & vbTab & SHIPTO_Address_Line2 & vbCrLf
	if Len(SHIPTO_Address_City) > 0 then BodyText = BodyText & vbTab & SHIPTO_Address_City
	if Len(SHIPTO_Address_City) > 0 and Len(SHIPTO_Address_State) > 0 then BodyText = BodyText & ", "
	if Len(SHIPTO_Address_State) > 0 then BodyText = BodyText & SHIPTO_Address_State & " "
	if Len(SHIPTO_Address_PostalCode) > 0 then BodyText = BodyText & SHIPTO_Address_PostalCode & vbCrLf
	if Len(SHIPTO_Address_Country) > 0 then BodyText = BodyText & vbTab & SHIPTO_Address_Country & vbCrLf
	if Len(SHIPTO_Phone) > 0 then BodyText = BodyText & vbTab & SHIPTO_Phone & " " & SHIPTO_Phone_Ext & vbCrLf
	if Len(SHIPTO_Fax) > 0 then BodyText = BodyText & vbTab & SHIPTO_Fax & vbCrLf
	if Len(SHIPTO_Shopping_Customer_Details_Notes) > 0 then BodyText = BodyText & vbTab & SHIPTO_Shopping_Customer_Details_Notes & vbCrLf

	if Len(Trim(Order_ShippingMethod)) > 0 then
		BodyText = BodyText & vbCrLf	
		BodyText = BodyText & "Ship Method:" & vbCrLf
		BodyText = BodyText & vbTab & Order_ShippingMethod & vbCrLf
		BodyText = BodyText & vbCrLf	
	end if

	SQLStr = "SELECT Display_Name, PricePerUOM, Quantity_Requested, (PricePerUOM * Quantity_Requested) As AmtOwing, " & _
			" COALESCE(ISBN13, ISBN10, SKU, UPC) As Primary_Item_Number " & _
			" FROM Shopping_Order_Items WHERE Shopping_Order_ID = '0" & Order_ID & "' ORDER BY Display_Name, PricePerUOM, Quantity_Requested, [ID]"
	'Response.Write SQLStr
	objRec.Open SQLStr, objConn, adOpenForwardOnly, adLockReadOnly, adCmdText
	if not objRec.EOF then
		BodyText = BodyText & Replace(Space(68), " ", "*") & vbCrLf
		BodyText = BodyText & "Items in Order #" & Order_ID & ":" & vbCrLf
		BodyText = BodyText & Replace(Space(68), " ", "-") & vbCrLf
		BodyText = BodyText & PadMe("Item Description", 40, " ", "r") & "  " & PadMe("Price", 8, " ", "l") & "  " & PadMe("Qty", 4, " ", "l") & "  " & PadMe("Ext Price", 10, " ", "l") & vbCrLf
		BodyText = BodyText & Replace(Space(68), " ", "-") & vbCrLf
		Do Until objRec.EOF
			BodyText = BodyText & vbCrLf
			BodyText = BodyText & PadMe(Left(objRec("Display_Name"), 40), 40, " ", "r") & "  " & PadMe(FormatNumber(objRec("PricePerUOM"), 2, -1, 0, 0), 8, " ", "l") & "  " & PadMe(objRec("Quantity_Requested"), 4, " ", "l") & "  " & PadMe(FormatNumber(objRec("AmtOwing"), 2, -1, 0, 0), 10, " ", "l") & vbCrLf
			BodyText = BodyText & "    " & Left(objRec("Primary_Item_Number"), 40) & vbCrLf
			objRec.MoveNext
		Loop
		BodyText = BodyText & vbCrLf
		BodyText = BodyText & Replace(Space(68), " ", "-") & vbCrLf
	end if
	objRec.Close

	SQLStr = "SELECT * FROM Shopping_Order WHERE [ID] = '0" & Order_ID & "'"
	'Response.Write SQLStr
	objRec.Open SQLStr, objConn, adOpenForwardOnly, adLockReadOnly, adCmdText
	if not objRec.EOF then

		BodyText = BodyText & PadMe("Subtotal", 56, " ", "l") & "  " & PadMe(FormatNumber(objRec("Order_Subtotal"), 2, -1, 0, 0), 10, " ", "l") & vbCrLf
		if Len(Trim(objRec("Order_CouponsRedeemed"))) > 0 and IsNumeric(objRec("Order_CouponsRedeemed")) then
			if CDbl(objRec("Order_CouponsRedeemed")) > 0 then
				BodyText = BodyText & PadMe("Coupons", 56, " ", "l") & "  " & PadMe(FormatNumber((objRec("Order_CouponsRedeemed") * -1), 2, -1, 0, 0), 10, " ", "l") & vbCrLf
			end if
		end if
		BodyText = BodyText & PadMe("Tax", 56, " ", "l") & "  " & PadMe(FormatNumber(objRec("Order_TaxCost"), 2, -1, 0, 0), 10, " ", "l") & vbCrLf
		BodyText = BodyText & PadMe("Shipping", 56, " ", "l") & "  " & PadMe(FormatNumber(objRec("Order_ShippingCost"), 2, -1, 0, 0), 10, " ", "l") & vbCrLf
		BodyText = BodyText & PadMe("Handling", 56, " ", "l") & "  " & PadMe(FormatNumber(objRec("Order_HandlingFee"), 2, -1, 0, 0), 10, " ", "l") & vbCrLf
	'	if Len(Trim(objRec("Order_GiftCardsApplied"))) > 0 and IsNumeric(objRec("Order_GiftCardsApplied")) then
	'		if CDbl(objRec("Order_GiftCardsApplied")) > 0 then
	'			BodyText = BodyText & PadMe("Gift Cards Redeemed", 56, " ", "l") & "  " & PadMe(FormatNumber((objRec("Order_GiftCardsApplied") * -1), 2, -1, 0, 0), 10, " ", "l") & vbCrLf
	'		end if
	'	end if
		BodyText = BodyText & PadMe("Grand Total", 56, " ", "l") & "  " & PadMe(FormatNumber(objRec("Order_GrandTotal"), 2, -1, 0, 0), 10, " ", "l") & vbCrLf
		BodyText = BodyText & vbCrLf & vbCrLf

		if CDbl(objRec("Order_GrandTotal")) >= 0.01 then
			if SmartValues(objRec("Is_FSA_Card"), "CBool") = True then
				BodyText = BodyText & vbCrLf	
				BodyText = BodyText & "Payment Information:" & vbCrLf
				BodyText = BodyText & vbTab & "Name on Card: " & Card_FullName & vbCrLf
				BodyText = BodyText & vbTab & "Card Number: XXXX-XXXX-XXXX-" & Card_Number_LastFour_Unencrypted & vbCrLf
				BodyText = BodyText & vbTab & "Expires: " & Card_Expires_Month & "/" & Card_Expires_Year & vbCrLf
			else
				BodyText = BodyText & vbCrLf	
				BodyText = BodyText & "Payment Information:" & vbCrLf
				BodyText = BodyText & vbTab & "Name on Card: " & Card_FullName & vbCrLf
				BodyText = BodyText & vbTab & "Card Number: XXXX-XXXX-XXXX-" & Card_Number_LastFour_Unencrypted & vbCrLf
				BodyText = BodyText & vbTab & "Expires: " & Card_Expires_Month & "/" & Card_Expires_Year & vbCrLf
			end if
		end if

	end if
	objRec.Close

	BodyText = BodyText & vbCrLf & vbCrLf
	BodyText = BodyText & "Please return to " & Store_URL & vbCrLf
	BodyText = BodyText & "to check the status of your order. " & vbCrLf & vbCrLf
	BodyText = BodyText & "Thank you! " & vbCrLf

	Mailer.BodyText = BodyText

	Mailer.QMessage	= true
	Mailer.IgnoreMalformedAddress = true
	Mailer.IgnoreRecipientErrors = true
	
	Call Mailer.SendMail
	Set Mailer = Nothing

End Sub

Sub SendMailHTML(locRecipName, locRecipAddr)

	Dim Mailer, BodyText
	Set Mailer			= Server.CreateObject("SMTPsvg.Mailer")

	Mailer.RemoteHost	= Application.Value("SMTP_SERVER_URL")
	Mailer.UserName		= Application.Value("SMTP_USERNAME")
	Mailer.Password		= Application.Value("SMTP_PASSWORD")

	Mailer.FromAddress	= Store_CC_Email
	Mailer.FromName		= Store_Name & " Order Picking Slip"
	Mailer.AddRecipient locRecipName, locRecipAddr
	
	Dim imageUrl
	imageUrl = Application.Value("AdminToolURL")

	Mailer.Subject		= Store_Name & " Order Picking Slip - Order " & Order_ID
	
	BodyText = "<!DOCTYPE html PUBLIC ""-//W3C//DTD XHTML 1.0 Transitional//EN"" ""http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"">" & vbCrLf & _
		"<html xmlns=""http://www.w3.org/1999/xhtml"" >" & vbCrLf & _
		"<head>" & vbCrLf & _
		"	<title>" & Store_Name & " Order Picking Slip - Order " & Order_ID & "</title>" & vbCrLf & _
		"	<style type=""text/css"">" & vbCrLf & _
		"		BODY {font-size: 11px; font-family: Arial, Verdana;}" & vbCrLf & _
		"	</style>" & vbCrLf & _
		"</head>" & vbCrLf & _
		"<body>" & vbCrLf

	BodyText = BodyText & "<p>The following order was submitted to " & Store_Name & "</p>" & vbCrLf

	BodyText = BodyText & vbCrLf & "<p>"
	BodyText = BodyText & "<strong>Customer Information:</strong>"
	if Len(First_Name) > 0 or Len(Last_Name) > 0 then
		if Len(First_Name) > 0 then BodyText = BodyText & "<br />&nbsp;&nbsp;&nbsp;&nbsp;" & First_Name & " "
		if Len(Last_Name) > 0 then BodyText = BodyText & Last_Name
	end if
	
	BodyText = BodyText & vbCrLf
	if Len(Email_Address) > 0 then BodyText = BodyText & "<br />&nbsp;&nbsp;&nbsp;&nbsp;" & Email_Address & vbCrLf
	if Len(Organization) > 0 then BodyText = BodyText & "<br />&nbsp;&nbsp;&nbsp;&nbsp;" & Organization & vbCrLf
	BodyText = BodyText & "</p>"
	
	
	BodyText = BodyText & vbCrLf & "<p>"
	BodyText = BodyText & "<table border=""0"" cellpadding=""0"" cellspacing=""0"">" & vbCrLf
	BodyText = BodyText & "<tr><td>" & vbCrLf
	BodyText = BodyText & "<strong>Bill To:</strong>" & vbCrLf
	if Len(BILLTO_First_Name) > 0 or Len(BILLTO_Last_Name) > 0 then
		if Len(BILLTO_First_Name) > 0 then BodyText = BodyText & "<br />&nbsp;&nbsp;&nbsp;&nbsp;" & BILLTO_First_Name & " "
		if Len(BILLTO_Last_Name) > 0 then BodyText = BodyText & BILLTO_Last_Name
	end if
	BodyText = BodyText & vbCrLf	
	if Len(BILLTO_Address_Line1) > 0 then BodyText = BodyText & "<br />&nbsp;&nbsp;&nbsp;&nbsp;" & BILLTO_Address_Line1 & vbCrLf
	if Len(BILLTO_Address_Line2) > 0 then BodyText = BodyText & "<br />&nbsp;&nbsp;&nbsp;&nbsp;" & BILLTO_Address_Line2 & vbCrLf
	if Len(BILLTO_Address_City) > 0 then BodyText = BodyText & "<br />&nbsp;&nbsp;&nbsp;&nbsp;" & BILLTO_Address_City
	if Len(BILLTO_Address_City) > 0 and Len(BILLTO_Address_State) > 0 then BodyText = BodyText & ", "
	if Len(BILLTO_Address_State) > 0 then BodyText = BodyText & BILLTO_Address_State & " "
	if Len(BILLTO_Address_PostalCode) > 0 then BodyText = BodyText & BILLTO_Address_PostalCode & vbCrLf
	if Len(BILLTO_Address_Country) > 0 then BodyText = BodyText & "<br />&nbsp;&nbsp;&nbsp;&nbsp;" & BILLTO_Address_Country & vbCrLf
	if Len(BILLTO_Phone) > 0 then BodyText = BodyText & "<br />&nbsp;&nbsp;&nbsp;&nbsp;" & BILLTO_Phone & " " & BILLTO_Phone_Ext & vbCrLf
	if Len(BILLTO_Fax) > 0 then BodyText = BodyText & "<br />&nbsp;&nbsp;&nbsp;&nbsp;" & BILLTO_Fax & vbCrLf
	if Len(BILLTO_Shopping_Customer_Details_Notes) > 0 then BodyText = BodyText & "<br />&nbsp;&nbsp;&nbsp;&nbsp;" & BILLTO_Shopping_Customer_Details_Notes & vbCrLf
	
	BodyText = BodyText & "</td><td width=""50"">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td><td>" & vbCrLf
		
	BodyText = BodyText & "<strong>Ship To:</strong>" & vbCrLf
	if Len(SHIPTO_First_Name) > 0 or Len(SHIPTO_Last_Name) > 0 then
		if Len(SHIPTO_First_Name) > 0 then BodyText = BodyText & "<br />&nbsp;&nbsp;&nbsp;&nbsp;" & SHIPTO_First_Name & " "
		if Len(SHIPTO_Last_Name) > 0 then BodyText = BodyText & SHIPTO_Last_Name
	end if
	BodyText = BodyText & vbCrLf	
	if Len(SHIPTO_Address_Line1) > 0 then BodyText = BodyText & "<br />&nbsp;&nbsp;&nbsp;&nbsp;" & SHIPTO_Address_Line1 & vbCrLf
	if Len(SHIPTO_Address_Line2) > 0 then BodyText = BodyText & "<br />&nbsp;&nbsp;&nbsp;&nbsp;" & SHIPTO_Address_Line2 & vbCrLf
	if Len(SHIPTO_Address_City) > 0 then BodyText = BodyText & "<br />&nbsp;&nbsp;&nbsp;&nbsp;" & SHIPTO_Address_City
	if Len(SHIPTO_Address_City) > 0 and Len(SHIPTO_Address_State) > 0 then BodyText = BodyText & ", "
	if Len(SHIPTO_Address_State) > 0 then BodyText = BodyText & SHIPTO_Address_State & " "
	if Len(SHIPTO_Address_PostalCode) > 0 then BodyText = BodyText & SHIPTO_Address_PostalCode & vbCrLf
	if Len(SHIPTO_Address_Country) > 0 then BodyText = BodyText & "<br />&nbsp;&nbsp;&nbsp;&nbsp;" & SHIPTO_Address_Country & vbCrLf
	if Len(SHIPTO_Phone) > 0 then BodyText = BodyText & "<br />&nbsp;&nbsp;&nbsp;&nbsp;" & SHIPTO_Phone & " " & SHIPTO_Phone_Ext & vbCrLf
	if Len(SHIPTO_Fax) > 0 then BodyText = BodyText & "<br />&nbsp;&nbsp;&nbsp;&nbsp;" & SHIPTO_Fax & vbCrLf
	if Len(SHIPTO_Shopping_Customer_Details_Notes) > 0 then BodyText = BodyText & "<br />&nbsp;&nbsp;&nbsp;&nbsp;" & SHIPTO_Shopping_Customer_Details_Notes & vbCrLf
	BodyText = BodyText & "</td></tr>" & vbCrLf
	BodyText = BodyText & "</table>" & vbCrLf
	BodyText = BodyText & "</p>"

	if Len(Trim(Order_ShippingMethod)) > 0 then
		BodyText = BodyText & vbCrLf & "<p>"
		BodyText = BodyText & "<strong>Ship Method:</strong>" & vbCrLf
		BodyText = BodyText & "<br />&nbsp;&nbsp;&nbsp;&nbsp;" & Order_ShippingMethod & vbCrLf
		BodyText = BodyText & vbCrLf & "</p>" & vbCrLf
	end if
	
	BodyText = BodyText & "<table border=""1"" cellpadding=""5"" cellspacing=""0"">" & vbCrLf
	
	'Response.Write "Order ID " & i & ": " & Order_ID & "<br>"
	SQLStr = "SELECT Display_Name, PricePerUOM, Quantity_Requested, (PricePerUOM * Quantity_Requested) As AmtOwing, " & _
			" ISNULL(UPC, '') As Primary_Item_Number " & _
			" FROM Shopping_Order_Items WHERE Shopping_Order_ID = '0" & Order_ID & "' ORDER BY Display_Name, PricePerUOM, Quantity_Requested, [ID]"
	'Response.Write SQLStr
	objRec.Open SQLStr, objConn, adOpenForwardOnly, adLockReadOnly, adCmdText
	if not objRec.EOF then
		BodyText = BodyText & vbCrLf & vbCrLf
		
		BodyText = BodyText & "<tr><td colspan=""3"">" & vbCrLf
		BodyText = BodyText & "Items in Order #" & Order_ID & ":" & vbCrLf
		BodyText = BodyText & "</td><td colspan=""2"" align=""right"">" & vbCrLf
		BodyText = BodyText & "<img src=""" & imageUrl & "barcode.aspx?Text=" & "*" & Order_ID & "*" & "&Font=" & Server.URLEncode("Free 3 of 9") & "&FontSize=72&FontColor=000000&BackColor=FFFFFF"" border=""0"" alt=""" & Order_ID & """ width=""100"" />"
		BodyText = BodyText & "<br />" & Order_ID & vbCrLf
		BodyText = BodyText & "</td></tr>" & vbCrLf
		
		BodyText = BodyText & "<tr>" & vbCrLf
		BodyText = BodyText & "<td align=""center""><b>Item</b></td>" & vbCrLf
		BodyText = BodyText & "<td align=""center""><b>Description</b></td>" & vbCrLf
		BodyText = BodyText & "<td align=""center""><b>Price</b></td>" & vbCrLf
		BodyText = BodyText & "<td align=""center""><b>Qty</b></td>" & vbCrLf
		BodyText = BodyText & "<td align=""center""><b>Ext Price</b></td>" & vbCrLf
		BodyText = BodyText & "</tr>" & vbCrLf

		Do Until objRec.EOF
			BodyText = BodyText & "<tr>" & vbCrLf
			BodyText = BodyText & "<td align=""left"">"
			if objRec("Primary_Item_Number") <> "" then
				BodyText = BodyText & "<img src=""" & imageUrl & "barcode.aspx?Text=" & "*" & objRec("Primary_Item_Number") & "*" & "&Font=" & Server.URLEncode("Free 3 of 9") & "&FontSize=72&FontColor=000000&BackColor=FFFFFF"" border=""0"" alt=""" & objRec("Primary_Item_Number") & """ width=""200"" />" & _
					"<br />" & _
					objRec("Primary_Item_Number") & ""
			end if
			BodyText = BodyText & "&nbsp;</td>" & vbCrLf
			BodyText = BodyText & "<td align=""left"">" & Left(objRec("Display_Name"), 40) & "&nbsp;</td>" & vbCrLf
			BodyText = BodyText & "<td align=""right"">&nbsp;" & FormatNumber(objRec("PricePerUOM"), 2, -1, 0, 0) & "</td>" & vbCrLf
			BodyText = BodyText & "<td align=""right"">&nbsp;" & objRec("Quantity_Requested") & "</td>" & vbCrLf
			BodyText = BodyText & "<td align=""right"">&nbsp;" & FormatNumber(objRec("AmtOwing"), 2, -1, 0, 0) & "</td>" & vbCrLf
			BodyText = BodyText & "</tr>" & vbCrLf
			objRec.MoveNext
		Loop
		BodyText = BodyText & vbCrLf
	end if
	objRec.Close

	SQLStr = "SELECT * FROM Shopping_Order WHERE [ID] = '0" & Order_ID & "'"
	'Response.Write SQLStr
	objRec.Open SQLStr, objConn, adOpenForwardOnly, adLockReadOnly, adCmdText
	if not objRec.EOF then

		BodyText = BodyText & "<tr><td colspan=""5"" align=""right"">" & vbCrLf
		BodyText = BodyText & "Subtotal:  " & FormatNumber(objRec("Order_Subtotal"), 2, -1, 0, 0) & "<br />" & vbCrLf
		if Len(Trim(objRec("Order_CouponsRedeemed"))) > 0 and IsNumeric(objRec("Order_CouponsRedeemed")) then
			if CDbl(objRec("Order_CouponsRedeemed")) > 0 then
				BodyText = BodyText & "Coupons:  " & FormatNumber((objRec("Order_CouponsRedeemed") * -1), 2, -1, 0, 0) & "<br />" & vbCrLf
			end if
		end if
		BodyText = BodyText & "Tax:  " & FormatNumber(objRec("Order_TaxCost"), 2, -1, 0, 0) & "<br />" & vbCrLf
		BodyText = BodyText & "Shipping:  " & FormatNumber(objRec("Order_ShippingCost"), 2, -1, 0, 0) & "<br />" & vbCrLf
		BodyText = BodyText & "Handling:  " & FormatNumber(objRec("Order_HandlingFee"), 2, -1, 0, 0) & "<br />" & vbCrLf
	'	if Len(Trim(objRec("Order_GiftCardsApplied"))) > 0 and IsNumeric(objRec("Order_GiftCardsApplied")) then
	'		if CDbl(objRec("Order_GiftCardsApplied")) > 0 then
	'			BodyText = BodyText & PadMe("Gift Cards Redeemed", 56, " ", "l") & "  " & PadMe(FormatNumber((objRec("Order_GiftCardsApplied") * -1), 2, -1, 0, 0), 10, " ", "l") & vbCrLf
	'		end if
	'	end if
		BodyText = BodyText & "<strong>" & "Grand Total:  " & FormatNumber(objRec("Order_GrandTotal"), 2, -1, 0, 0) & "</strong>" & vbCrLf
		BodyText = BodyText & "</tr>" & vbCrLf

		if CDbl(objRec("Order_GrandTotal")) >= 0.01 then
			if SmartValues(objRec("Is_FSA_Card"), "CBool") = True then
				BodyText = BodyText & "<tr><td colspan=""5"" align=""left"">" & vbCrLf
				BodyText = BodyText & "<strong>Payment Information</strong>:<br>" & vbCrLf
				BodyText = BodyText & "<br />&nbsp;&nbsp;&nbsp;&nbsp;" & "Name on Card: " & Card_FullName & vbCrLf
				BodyText = BodyText & "<br />&nbsp;&nbsp;&nbsp;&nbsp;" & "Card Number: XXXX-XXXX-XXXX-" & Card_Number_LastFour_Unencrypted & vbCrLf
				BodyText = BodyText & "<br />&nbsp;&nbsp;&nbsp;&nbsp;" & "Expires: " & Card_Expires_Month & "/" & Card_Expires_Year & vbCrLf
				BodyText = BodyText & "</tr>" & vbCrLf
			else
				BodyText = BodyText & "<tr><td colspan=""5"" align=""left"">" & vbCrLf
				BodyText = BodyText & "<strong>Payment Information</strong>:<br>" & vbCrLf
				BodyText = BodyText & "<br />&nbsp;&nbsp;&nbsp;&nbsp;" & "Name on Card: " & Card_FullName & vbCrLf
				BodyText = BodyText & "<br />&nbsp;&nbsp;&nbsp;&nbsp;" & "Card Number: XXXX-XXXX-XXXX-" & Card_Number_LastFour_Unencrypted & vbCrLf
				BodyText = BodyText & "<br />&nbsp;&nbsp;&nbsp;&nbsp;" & "Expires: " & Card_Expires_Month & "/" & Card_Expires_Year & vbCrLf
				BodyText = BodyText & "</tr>" & vbCrLf
			end if
		end if

	end if
	objRec.Close
	BodyText = BodyText & "</table><br />" & vbCrLf

	BodyText = BodyText & vbCrLf & vbCrLf
	BodyText = BodyText & "<p>Please return to " & Store_URL & "<br />" & vbCrLf
	BodyText = BodyText & "to check the status of your order. </p>" & vbCrLf & vbCrLf
	BodyText = BodyText & "<p>Thank you! </p>" & vbCrLf
	
	BodyText = BodyText & vbCrLf & "<br/>"
	
	BodyText = BodyText & GetInvoiceHTML()
	
	BodyText = BodyText & vbCrLf & _
	"</body>" & vbCrLf & _
	"</html>" & vbCrLf
	
	Mailer.ContentType = "text/html"
	Mailer.BodyText = BodyText

	Mailer.QMessage	= true
	Mailer.IgnoreMalformedAddress = true
	Mailer.IgnoreRecipientErrors = true
	
	Call Mailer.SendMail
	Set Mailer = Nothing

End Sub

Function GetInvoiceHTML()
	Dim imageUrl, pageBreak, BodyText

	imageUrl = Application.Value("AdminToolURL")
	
	pageBreak = vbCrLf & "<div style='page-break-before:always'>&nbsp;</div>" & vbCrLf
	
	BodyText = ""

	' *******************
	' ***** INVOICE *****
	' *******************
	BodyText = BodyText & "<br /><br />" & pageBreak & _
	"<table width=""700"" border=""0"" cellspacing=""0"" cellpadding=""0"">" & vbCrLf & _
	"  <tr>" & vbCrLf & _
	"	<td style=""width: 10px;"">&nbsp;</td>" & vbCrLf & _
	"	<td>" & vbCrLf & _
	"	  <table width=""600"" border=""0"" cellspacing=""0"" cellpadding=""0"">" & vbCrLf & _
	"		<tr>" & vbCrLf & _
	"		  <td colspan=""2"">&nbsp;</td>" & vbCrLf & _
	"		</tr>" & vbCrLf & _
	"		<tr>" & vbCrLf & _
	"		  <td width=""50%"" valign=""top""><h2>Invoice</h2>" & vbCrLf
	
	BodyText = BodyText & "<p>" & Store_Contact_Name & "<br />" & vbCrLf
	BodyText = BodyText & "" & Store_Address_Line1 & "<br />" & vbCrLf
	if Len(Store_Address_Line2) > 0 then BodyText = BodyText & "" & Store_Address_Line2 & "<br />" & vbCrLf
	BodyText = BodyText & "" & Store_City & ", " & Store_State & " " & Store_PostalCode & "<br />" & vbCrLf
	BodyText = BodyText & "" & Store_Country & "<br />" & vbCrLf
	if Len(Store_Contact_Phone1) > 0 then BodyText = BodyText & "Phone: " & Store_Contact_Phone1 & "<br />" & vbCrLf
	if Len(Store_Contact_Fax1) > 0 then BodyText = BodyText & "Fax: " & Store_Contact_Fax1 & "<br />" & vbCrLf

	BodyText = BodyText & "		  </p></td>" & vbCrLf & _
	"		  <td width=""50%"" align=""right"" valign=""top"">"
	BodyText = BodyText & "<img src=""" & imageUrl & "barcode.aspx?Text=" & "*" & Order_ID & "*" & "&Font=" & Server.URLEncode("Free 3 of 9") & "&FontSize=72&FontColor=000000&BackColor=FFFFFF"" border=""0"" alt=""" & Order_ID & """ width=""100"" />"
	BodyText = BodyText & "<br />" & vbCrLf & _
	"		  " & Order_ID & "&nbsp;</td>" & vbCrLf & _
	"		</tr>" & vbCrLf & _
	"		<tr>" & vbCrLf & _
	"		  <td colspan=""2"">&nbsp;</td>" & vbCrLf & _
	"		</tr>" & vbCrLf & _
	"		<tr>" & vbCrLf & _
	"		  <td colspan=""2""><strong>Order Date:</strong>&nbsp; " & FormatDateTime(Order_Date, vbShortDate) & "</td>" & vbCrLf & _
	"		</tr>" & vbCrLf & _
	"		<tr>" & vbCrLf & _
	"		  <td colspan=""2"">&nbsp;</td>" & vbCrLf & _
	"		</tr>" & vbCrLf & _
	"		<tr>" & vbCrLf & _
	"		  <td width=""50%"" valign=""top""><p><strong>Bill To:</strong></p>" & vbCrLf & _
	"		  <p>"
	
	if Len(BILLTO_First_Name) > 0 or Len(BILLTO_Last_Name) > 0 then
		if Len(BILLTO_First_Name) > 0 then BodyText = BodyText & BILLTO_First_Name & " "
		if Len(BILLTO_Last_Name) > 0 then BodyText = BodyText & BILLTO_Last_Name
	end if
	BodyText = BodyText & vbCrLf	
	if Len(BILLTO_Address_Line1) > 0 then BodyText = BodyText & "<br />" & BILLTO_Address_Line1 & vbCrLf
	if Len(BILLTO_Address_Line2) > 0 then BodyText = BodyText & "<br />" & BILLTO_Address_Line2 & vbCrLf
	if Len(BILLTO_Address_City) > 0 then BodyText = BodyText & "<br />" & BILLTO_Address_City
	if Len(BILLTO_Address_City) > 0 and Len(BILLTO_Address_State) > 0 then BodyText = BodyText & ", "
	if Len(BILLTO_Address_State) > 0 then BodyText = BodyText & BILLTO_Address_State & " "
	if Len(BILLTO_Address_PostalCode) > 0 then BodyText = BodyText & BILLTO_Address_PostalCode & vbCrLf
	if Len(BILLTO_Address_Country) > 0 then BodyText = BodyText & "<br />" & BILLTO_Address_Country & vbCrLf
	
	BodyText = BodyText & _
	"		  </p></td>" & vbCrLf & _
	"		  <td width=""50%"" valign=""top""><p><strong>Ship To:</strong></p>" & vbCrLf & _
	"			<p>"
	if Len(SHIPTO_First_Name) > 0 or Len(SHIPTO_Last_Name) > 0 then
		if Len(SHIPTO_First_Name) > 0 then BodyText = BodyText & SHIPTO_First_Name & " "
		if Len(SHIPTO_Last_Name) > 0 then BodyText = BodyText & SHIPTO_Last_Name
	end if
	BodyText = BodyText & vbCrLf	
	if Len(SHIPTO_Address_Line1) > 0 then BodyText = BodyText & "<br />" & SHIPTO_Address_Line1 & vbCrLf
	if Len(SHIPTO_Address_Line2) > 0 then BodyText = BodyText & "<br />" & SHIPTO_Address_Line2 & vbCrLf
	if Len(SHIPTO_Address_City) > 0 then BodyText = BodyText & "<br />" & SHIPTO_Address_City
	if Len(SHIPTO_Address_City) > 0 and Len(SHIPTO_Address_State) > 0 then BodyText = BodyText & ", "
	if Len(SHIPTO_Address_State) > 0 then BodyText = BodyText & SHIPTO_Address_State & " "
	if Len(SHIPTO_Address_PostalCode) > 0 then BodyText = BodyText & SHIPTO_Address_PostalCode & vbCrLf
	if Len(SHIPTO_Address_Country) > 0 then BodyText = BodyText & "<br />" & SHIPTO_Address_Country & vbCrLf
	
	BodyText = BodyText & _
	"		  </p></td>" & vbCrLf & _
	"		</tr>" & vbCrLf & _
	"		<tr>" & vbCrLf & _
	"		  <td colspan=""2"">&nbsp;</td>" & vbCrLf & _
	"		</tr>" & vbCrLf & _
	"		<tr>" & vbCrLf & _
	"		  <td colspan=""2""><table width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""3"" style=""border-color: #999999;"">" & vbCrLf & _
	"			<tr>" & vbCrLf & _
	"			  <td align=""left"" valign=""top""><strong>ID</strong></td>" & vbCrLf & _
	"			  <td align=""left"" valign=""top""><strong>Product Name</strong></td>" & vbCrLf & _
	"			  <td align=""right"" valign=""top""><strong>Quantity</strong></td>" & vbCrLf & _
	"			  <td align=""right"" valign=""top""><strong>Unit Price</strong></td>" & vbCrLf & _
	"			  <td align=""right"" valign=""top""><strong>Discount</strong></td>" & vbCrLf & _
	"			  <td align=""right"" valign=""top""><strong>Line Total</strong></td>" & vbCrLf & _
	"			</tr>" & vbCrLf
	
	'Response.Write "Order ID " & i & ": " & Order_ID & "<br>"
	SQLStr = "SELECT Display_Name, PricePerUOM, Quantity_Requested, (PricePerUOM * Quantity_Requested) As AmtOwing, " & _
			" ISNULL(UPC, '') As Primary_Item_Number " & _
			" FROM Shopping_Order_Items WHERE Shopping_Order_ID = '0" & Order_ID & "' ORDER BY Display_Name, PricePerUOM, Quantity_Requested, [ID]"
	'Response.Write SQLStr
	objRec.Open SQLStr, objConn, adOpenForwardOnly, adLockReadOnly, adCmdText
	if not objRec.EOF then
		Do Until objRec.EOF
	BodyText = BodyText & _
	"			<tr>" & vbCrLf & _
	"			  <td align=""left"" valign=""top"">" & objRec("Primary_Item_Number") & "&nbsp;</td>" & vbCrLf & _
	"			  <td align=""left"" valign=""top"">" & Left(objRec("Display_Name"), 40) & "&nbsp;</td>" & vbCrLf & _
	"			  <td align=""right"" valign=""top"">" & objRec("Quantity_Requested") & "</td>" & vbCrLf & _
	"			  <td align=""right"" valign=""top"">" & FormatNumber(objRec("PricePerUOM"), 2, -1, 0, 0) & "</td>" & vbCrLf & _
	"			  <td align=""right"" valign=""top"">0.00%</td>" & vbCrLf & _
	"			  <td align=""right"" valign=""top"">" & FormatNumber(objRec("AmtOwing"), 2, -1, 0, 0) & "</td>" & vbCrLf & _
	"			</tr>" & vbCrLf
			objRec.MoveNext
		Loop
	end if
	objRec.Close
	
	BodyText = BodyText & _
	"		  </table></td>" & vbCrLf & _
	"		</tr>" & vbCrLf & _
	"		<tr>" & vbCrLf & _
	"		  <td colspan=""2"">&nbsp;</td>" & vbCrLf & _
	"		</tr>" & vbCrLf
	
	SQLStr = "SELECT * FROM Shopping_Order WHERE [ID] = '0" & Order_ID & "'"
	'Response.Write SQLStr
	objRec.Open SQLStr, objConn, adOpenForwardOnly, adLockReadOnly, adCmdText
	if not objRec.EOF then
	
	BodyText = BodyText & _
	"		<tr>" & vbCrLf & _
	"		  <td colspan=""2"" align=""right""><table width=""400"" border=""0"" cellspacing=""0"" cellpadding=""1"">" & vbCrLf & _
	"			<tr>" & vbCrLf & _
	"			  <td><strong>Subtotal</strong></td>" & vbCrLf & _
	"			  <td rowspan=""6"">&nbsp;</td>" & vbCrLf & _
	"			  <td align=""right""><strong>" & FormatCurrency(objRec("Order_Subtotal"), 2, -1, 0, 0) & "</strong></td>" & vbCrLf & _
	"			</tr>" & vbCrLf & _
	"			<tr>" & vbCrLf & _
	"			  <td><strong>Shipping</strong></td>" & vbCrLf & _
	"			  <td align=""right""><strong>" & FormatCurrency(objRec("Order_ShippingCost"), 2, -1, 0, 0) & "</strong></td>" & vbCrLf & _
	"			</tr>" & vbCrLf & _
	"			<tr>" & vbCrLf & _
	"			  <td><strong>Sales Tax</strong></td>" & vbCrLf & _
	"			  <td align=""right""><strong>" & FormatCurrency(objRec("Order_TaxCost"), 2, -1, 0, 0) & "</strong></td>" & vbCrLf & _
	"			</tr>" & vbCrLf & _
	"			<tr>" & vbCrLf & _
	"			  <td><strong>Order Total</strong></td>" & vbCrLf & _
	"			  <td align=""right""><strong>" & FormatCurrency(objRec("Order_GrandTotal"), 2, -1, 0, 0) & "</strong></td>" & vbCrLf & _
	"			</tr>" & vbCrLf
	
	if CDbl(objRec("Order_GrandTotal")) >= 0.01 then
		if SmartValues(objRec("Is_FSA_Card"), "CBool") = True then
			BodyText = BodyText & _
			"			<tr>" & vbCrLf & _
			"			  <td valign=""top""><strong>Payment on Credit Card <br />XXXX-XXXX-XXXX-" & Card_Number_LastFour_Unencrypted & "</strong></td>" & vbCrLf & _
			"			  <td align=""right"" valign=""bottom""><strong>" & FormatCurrency(objRec("Order_GrandTotal"), 2, -1, 0, 0) & "</strong></td>" & vbCrLf & _
			"			</tr>" & vbCrLf
		else
			BodyText = BodyText & _
			"			<tr>" & vbCrLf & _
			"			  <td valign=""top""><strong>Payment on Credit Card <br />XXXX-XXXX-XXXX-" & Card_Number_LastFour_Unencrypted & "</strong></td>" & vbCrLf & _
			"			  <td align=""right"" valign=""bottom""><strong>" & FormatCurrency(objRec("Order_GrandTotal"), 2, -1, 0, 0) & "</strong></td>" & vbCrLf & _
			"			</tr>" & vbCrLf
		end if
	else
		BodyText = BodyText & _
		"			<tr>" & vbCrLf & _
		"			  <td colspan=""2"" valign=""top""></td>" & vbCrLf & _
		"			</tr>" & vbCrLf
	end if
	
	BodyText = BodyText & _
	"			<tr>" & vbCrLf & _
	"			  <td><strong>Total Due</strong></td>" & vbCrLf & _
	"			  <td align=""right""><strong>" & FormatCurrency(0, 2, -1, 0, 0) & "</strong></td>" & vbCrLf & _
	"			</tr>" & vbCrLf & _
	"		  </table></td>" & vbCrLf & _
	"		</tr>" & vbCrLf & _
	"		<tr>" & vbCrLf & _
	"		  <td width=""50%"">&nbsp;</td>" & vbCrLf & _
	"		  <td width=""50%"">&nbsp;</td>" & vbCrLf & _
	"		</tr>" & vbCrLf & _
	"	  </table>" & vbCrLf & _
	"	</td>" & vbCrLf & _
	"	<td style=""width: 10px;"">&nbsp;</td>" & vbCrLf & _
	"  </tr>" & vbCrLf & _
	"</table>" & vbCrLf & _
	"<br /><br />" & vbCrLf
	
	end if
	objRec.Close
	
	GetInvoiceHTML = BodyText
	
End Function

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