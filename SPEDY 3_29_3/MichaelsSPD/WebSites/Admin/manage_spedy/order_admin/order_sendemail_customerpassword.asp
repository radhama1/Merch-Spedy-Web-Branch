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
Dim Shopping_Customer_ID, Shopping_Customer_Password
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

	if Len(Email_Address) > 0 then
		SQLStr = "SELECT * FROM Shopping_Customer WHERE Email_Address = '" & Email_Address & "'"
		'Response.Write SQLStr
		objRec.Open SQLStr, objConn, adOpenStatic, adLockReadOnly, adCmdText
		if not objRec.EOF then
			Shopping_Customer_Password = SmartValues(objRec("Password"), "CStr")
		end if
		objRec.Close
	end if

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

		'On Error Resume Next
		Call SendMail("Valued Customer", Email_Address)
		Call SendMail("drugsourcesupport@novalibra.com", "drugsourcesupport@novalibra.com")
		Call SendMail("Ken Wallace", "ken.wallace@novalibra.com")
		On Error GOTO 0

		if Err.number = 0 then
			SUCCESSFLAG = true
		end if
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
	<div style="margin-top: 20px;"><input type="button" name="btnClose" value="Okay, Close this Window." onclick="self.close();" ID="Button1"></div>
<%else%>
	<div style="font-size: 18px; font-weight: bold;">Sorry. :(</div>
	<div>No email has been sent.</div>
	<div style="margin-top: 20px;"><input type="button" name="btnClose" value="Okay, Close this Window." onclick="self.close();" ID="Button2"></div>
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
	Mailer.FromName		= Store_Name & " Password Reminder"
	Mailer.AddRecipient locRecipName, locRecipAddr
	
	Mailer.Subject		= Store_Name & " Password Reminder"
	BodyText = "Greetings " & First_Name & "," & vbCrLf
	BodyText = BodyText & "Here is your username and password:" & vbCrLf & vbCrLf

	BodyText = BodyText & Space(4) & "Username:  " & Email_Address & vbCrLf
	BodyText = BodyText & Space(4) & "Password:  " & Shopping_Customer_Password & vbCrLf & vbCrLf

	BodyText = BodyText & vbCrLf	
	BodyText = BodyText & "Customer Information:" & vbCrLf
	if Len(First_Name) > 0 or Len(Last_Name) > 0 then
		if Len(First_Name) > 0 then BodyText = BodyText & vbTab & First_Name & " "
		if Len(Last_Name) > 0 then BodyText = BodyText & Last_Name
	end if
	BodyText = BodyText & vbCrLf	
	if Len(Email_Address) > 0 then BodyText = BodyText & vbTab & Email_Address & vbCrLf
	if Len(Organization) > 0 then BodyText = BodyText & vbTab & Organization & vbCrLf

	BodyText = BodyText & vbCrLf & vbCrLf
	BodyText = BodyText & "..........................................................." & vbCrLf
	BodyText = BodyText & "If you need further assistance, please contact us: " & vbCrLf & vbCrLf
	BodyText = BodyText & vbTab & Store_CC_Email & vbCrLf & vbCrLf
	BodyText = BodyText & vbTab & Store_Contact_Name & vbCrLf
	BodyText = BodyText & vbTab & Store_Address_Line1 & vbCrLf
	if Len(Store_Address_Line2) > 0 then BodyText = BodyText & vbTab & Store_Address_Line2 & vbCrLf
	BodyText = BodyText & vbTab & Store_City & ", " & Store_State & " " & Store_PostalCode & vbCrLf
	BodyText = BodyText & vbTab & Store_Country & vbCrLf
	if Len(Store_Contact_Phone1) > 0 then BodyText = BodyText & vbTab & "Phone: " & Store_Contact_Phone1 & vbCrLf
	if Len(Store_Contact_Fax1) > 0 then BodyText = BodyText & vbTab & "Fax: " & Store_Contact_Fax1 & vbCrLf

	BodyText = BodyText & vbCrLf & vbCrLf
	BodyText = BodyText & "Please return to " & Store_URL & " " & vbCrLf & "to manage your account. " & vbCrLf & vbCrLf
	BodyText = BodyText & "Thank you! " & vbCrLf

	Mailer.BodyText = BodyText

	Mailer.QMessage	= true
	Mailer.IgnoreMalformedAddress = true
	Mailer.IgnoreRecipientErrors = true
	
	Call Mailer.SendMail
	Set Mailer = Nothing

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