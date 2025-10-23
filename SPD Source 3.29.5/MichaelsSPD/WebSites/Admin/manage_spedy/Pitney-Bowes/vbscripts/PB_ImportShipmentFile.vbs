Option Explicit

Dim objArgs
Dim objNetwork, strDriveLetter, strRemotePath, strUser, strPassword, strProfile
Dim Name_Root, MappedPath, ConnStr, retCode, thisFileName
Dim tempDate, counter
Dim ErrMessage, strMessage
Dim StoreID, OrderID, OrderStatusID, ResultStatusID
Dim Shipment_CarrierTrackingNumber, Shipment_CarrierCode, Shipment_ServiceCode, Shipment_TotalShippingFee, Shipment_ShipDate
Dim Actual_Ship_Method

CONST ForReading = 1
CONST ForWriting = 2
CONST ForAppending = 8

Set objArgs		= Wscript.Arguments.Named
Set objNetwork	= CreateObject("WScript.Network")

ConnStr			= Replace(objArgs.Item("ConnStr"), "[WHITESPACE]", " ")
MappedPath		= objArgs.Item("MappedPath")
ErrMessage		= ""
tempDate		= Right(Year(Now()), 4) & Right("0" & Month(Now), 2) & Right("0" & Day(Now), 2) & Right("0" & Hour(Now), 2) & Right("0" & Minute(Now), 2) & Right("0" & Second(Now), 2)

if ConnStr = "" then
	ConnStr = "Provider=SQLOLEDB; Data Source=WEB5; Initial Catalog=DrugSourceInc_Store; User ID=sa; Password=rucrazy2;"
end if

if MappedPath = "" then
	MappedPath = "\\nova1\E$\drugsource_ftp"
end if

On Error Resume Next
strDriveLetter = "P:" 
strRemotePath = "\\nova1\E$\drugsource_ftp" 
strUser = "nova1\Administrator"
strPassword = "dontbl8"
strProfile = "False" ' means do not store in profile leave as false.
objNetwork.MapNetworkDrive strDriveLetter, strRemotePath, strProfile, strUser, strPassword 
if Err.number > 0 Or Len(ErrMessage) > 0 then
	ErrMessage = ErrMessage & " , ErrNum: " & Err.number & ", ErrDesc: " & Err.Description
	SendErrorMessage ErrMessage
	Err.Clear
end if
On Error GOTO 0

'* =========================================================================================================================
'* =========================================================================================================================
On Error Resume Next
ProcessOrderShipmentFiles MappedPath

if Err.number > 0 Or Len(ErrMessage) > 0 then
	ErrMessage = ErrMessage & " , ErrNum: " & Err.number & ", ErrDesc: " & Err.Description
	'SendErrorMessage ErrMessage
end if

Set objArgs = Nothing
Set objNetwork = Nothing

'Exit With Return Code
if Len(ErrMessage) <> 0 then
	WScript.Quit(1)
end if
'* =========================================================================================================================
'* =========================================================================================================================


Sub ProcessOrderShipmentFiles(p_SearchFolderPath)
	On Error Resume Next

	Dim objConn, objRec, SQLStr
	Dim objFSO, objFolder, objFile, BinaryStream
	Dim FileName, FilePath, FileSize, FileTextStream
	Dim retryAmount, retryTimeSec, retryCounter

	retryCounter = 0
	retryAmount = 35		'35 Retries
	retryTimeSec = 30000	'30 Sec Wait

	Set objFSO = CreateObject("Scripting.FileSystemObject")
	Set objConn = CreateObject("ADODB.Connection")
	Set objRec = CreateObject("ADODB.RecordSet")

	objConn.CommandTimeout = 1400
	objConn.Open ConnStr

	for each objFile in objFSO.GetFolder(p_SearchFolderPath).Files
		Do
			if objFSO.FileExists(objFile.Path) then

				Select Case findFileExtension(objFile.Name)
					Case "exp"
						'* ---------------------------------------------------------------------
						'* SAVE FILE TO DATABASE
						'* ---------------------------------------------------------------------
						FileName = objFile.Name
						FilePath = objFile.Path
						FileSize = objFile.Size
						
						Set BinaryStream = CreateObject("ADODB.Stream")
						BinaryStream.Type = 1 'adTypeBinary
						BinaryStream.Open
						BinaryStream.LoadFromFile FilePath

						SQLStr = "SELECT * FROM PitneyBowes_File WHERE File_Name = '0" & FileName & "' "
						objRec.Open SQLStr, objConn, 2, 3, 1 'adOpenDynamic, adLockOptimistic, adCmdText
						if objRec.EOF then objRec.AddNew					
							objRec("File_Name") = FileName
							objRec("File_Type") = findFileExtension(objFile.Name)
							objRec("File_Data") = BinaryStream.Read
							objRec("File_Size") = FileSize
							objRec("Date_Last_Modified") = CDate(Now())
						objRec.Update
						objRec.Close
						BinaryStream.Close
						Set BinaryStream = Nothing
						
						'* exp files are named <OrderID>.exp
						OrderID = Replace(objFile.ShortName, Mid(FileName, InStrRev(FileName, "."), Len(FileName)), "")
						OrderStatusID = 0
						'WScript.Echo("objFile.ShortName: " & objFile.ShortName)
						'WScript.Echo("OrderID: " & OrderID)
						
						'* ---------------------------------------------------------------------
						'* INQUIRE ABOUT ORDER
						'* ---------------------------------------------------------------------
						SQLStr = "SELECT COALESCE(Order_Status_ID, 0) As Order_Status_ID, COALESCE(Shopping_Store_ID, 0) As Shopping_Store_ID FROM Shopping_Order WHERE ID = '0" & OrderID & "' "
						objRec.Open SQLStr, objConn, 2, 3, 1 'adOpenDynamic, adLockOptimistic, adCmdText
						if not objRec.EOF then
							OrderStatusID = CLng(objRec("Order_Status_ID"))
							StoreID = CLng(objRec("Shopping_Store_ID"))
						else
							ErrMessage = "ProcessOrderShipmentFiles:: Order " & OrderID & " does not exist in the database."
						'	SendErrorMessage ErrMessage
						end if
						objRec.Close
						
						if OrderStatusID > 0 then
							'* --------------------------------
							'* Possible Order Statuses
							'* --------------------------------
							'*	1	New
							'*	2	Processing
							'*	3	Cancelled
							'*	4	Shipped
							'*	5	Complete
							'*	6	Card Declined
							'*	7	Order Error
							'* --------------------------------
							Select Case OrderStatusID
								Case 1
									'* Mark Order as Processing
									RunSQL "sp_shopping_order_updatestatus '0" & OrderID & "', 2, 0"
									
									'* Retrieve Tracking Number and other ship info from Order File
									'  Dim Shipment_CarrierTrackingNumber, _
									'	Shipment_CarrierCode, _
									'	Shipment_ServiceCode, _
									'	Shipment_TotalShippingFee, _
									'	Shipment_ShipDate
									FileTextStream = objFile.OpenAsTextStream(ForReading).ReadAll

									Shipment_CarrierTrackingNumber	= Mid(FileTextStream, 9, 25)
									Shipment_CarrierCode			= Mid(FileTextStream, 34, 5)
									Shipment_ServiceCode			= Mid(FileTextStream, 39, 5)
									Shipment_TotalShippingFee		= Mid(FileTextStream, 44, 6)
									Shipment_ShipDate				= Mid(FileTextStream, 50, 10)
									
									if Len(Trim(Shipment_TotalShippingFee)) > 0 then
										if IsNumeric(Shipment_TotalShippingFee) then
											Shipment_TotalShippingFee = CDbl(Shipment_TotalShippingFee)
										end if
									end if

									if Len(Trim(Shipment_ShipDate)) > 0 then
										if IsDate(Shipment_ShipDate) then
											Shipment_ShipDate = CDate(Shipment_ShipDate)
										end if
									end if
									
									'* Update database
									SQLStr = "SELECT * FROM Shopping_Order WHERE ID = '0" & OrderID & "' "
									objRec.Open SQLStr, objConn, 2, 3, 1 'adOpenDynamic, adLockOptimistic, adCmdText
									if not objRec.EOF then
										objRec("Actual_Ship_Method") = Trim(Shipment_CarrierCode) & " [" & Trim(Shipment_ServiceCode) & "]"
										objRec("Shipment_Tracking_Number") = Trim(Shipment_CarrierTrackingNumber)
										objRec("Date_Order_Shipped") = Shipment_ShipDate
										objRec("Ship_Notice_Sent_To_Customer") = 1
										objRec.UpdateBatch
									end if
									objRec.Close

									'* Send Order Ship Email
									SendOrderUpdateEmail StoreID, OrderID

									'* Mark Order as Shipped
									RunSQL "sp_shopping_order_updatestatus '0" & OrderID & "', 4, 0"

									'* Capture Funds
									if 1 = 1 then
										retCode = AuthorizeCC_AuthorizeNet(StoreID, OrderID, 1)
										if retCode <> 0 and retCode <> 3 and Err.number = 0 And Len(ErrMessage) = 0 then
											ErrMessage = "PRIOR_AUTH_CAPTURE Transaction for Order " & OrderID & " completed successfully."
										'	SendErrorMessage ErrMessage
										elseif retCode = 0 then
											ErrMessage = "PRIOR_AUTH_CAPTURE Transaction for Order " & OrderID & " could not be completed!"
										'	SendErrorMessage ErrMessage
										elseif retCode = 3 then
											ErrMessage = "PRIOR_AUTH_CAPTURE Transaction for Order " & OrderID & " returned an error from Authorize.net!"
										'	SendErrorMessage ErrMessage
										else    'Exit With Return Code
											ErrMessage = "PRIOR_AUTH_CAPTURE Transaction for Order " & OrderID & " returned a wscript error!"
											ErrMessage = ErrMessage & vbCrLf & vbCrLf & ErrMessage & " , ErrNum: " & Err.number & ", ErrDesc: " & Err.Description
										'	SendErrorMessage ErrMessage
										end if

										'* Mark Order As Complete
										RunSQL "sp_shopping_order_updatestatus '0" & OrderID & "', 5, 0"
									end if
									
									'* Remove File
									'WScript.Echo(objFile.Path)
									objFile.Delete(true)

								Case Else
									ErrMessage = "ProcessOrderShipmentFiles:: Order " & OrderID & " is not New?! [OrderStatusID: " & OrderStatusID & "]"
								'	SendErrorMessage ErrMessage
							End Select
						end if
					
					Case Else
					'else this is not the right kind of file.
				End Select

				Exit Do			
			elseif retryCounter >= retryAmount then
				ErrMessage = "ProcessOrderShipmentFiles:: The retry amount for the file processor failed."
				Set objFSO = Nothing
				Exit Sub
			end if
		
			WScript.Sleep retryTimeSec
			
			retryCounter = retryCounter + 1
		Loop
	next

	if objConn.Errors.Count < 1 and Err.number < 1 then

	else
		ErrMessage = "ProcessOrderShipmentFiles:: The file upload failed because of the following error:" & Err.number & " " & Err.Description
	end if

	if objRec.State <> 0 then 'adStateClosed then
		On Error Resume Next
		objRec.Close
	end if
	if objConn.State <> 0 then 'adStateClosed then
		On Error Resume Next
		objConn.Close
	end if
	Set objRec = Nothing
	Set objConn = Nothing

	Set objFile = Nothing
	Set objFolder = Nothing
	Set objFSO = Nothing
End Sub
	
Function RunSQL(ByVal p_strSQL)
	Dim cmd
	Set cmd = CreateObject("ADODB.Command")

	cmd.ActiveConnection  = ConnStr
	cmd.ActiveConnection.BeginTrans
	cmd.CommandText = p_strSQL
	cmd.CommandType = 1 'adCmdText
	cmd.CommandTimeout = 1400

	' Execute the query without returning a recordset
	' Specifying adExecuteNoRecords reduces overhead and improves performance
	cmd.Execute 'true , , adExecuteNoRecords
	cmd.ActiveConnection.CommitTrans

	if Err <> 0 then
		cmd.ActiveConnection.RollBackTrans
	end if

	' Disconnect the recordsets and cleanup  
	Set cmd.ActiveConnection = Nothing
	Set cmd = Nothing
End Function
	
Function LoadRSFromDB(p_strSQL)
	Dim rs, cmd
	Set rs = CreateObject("ADODB.Recordset")
	Set cmd = CreateObject("ADODB.Command")

	cmd.ActiveConnection  = ConnStr
	cmd.CommandText = p_strSQL
	cmd.CommandType = 1 'adCmdText
	cmd.Prepared = true
	cmd.CommandTimeout = 1400

	rs.CursorLocation = 3 'adUseClient
	rs.Open cmd, , 0, 1 'adOpenForwardOnly, adLockReadOnly

	if Err <> 0 then
		'Err.Raise  Err.Number, "ADOHelper: RunSQLReturnRS", Err.Description
	end if

	' Disconnect the recordsets and cleanup  
	Set rs.ActiveConnection = Nothing  
	Set cmd.ActiveConnection = Nothing
	Set cmd = Nothing
	Set LoadRSFromDB = rs
End Function

function findFileExtension(FileName)
	if Len(FileName) > 0 then
		if InStr(FileName, ".") > 0 then
			findFileExtension = Mid(FileName, InStrRev(FileName, "."), Len(FileName))
			findFileExtension = Replace(findFileExtension, ".", "")
		else
			findFileExtension = "???"
		end if
	end if
end function

Function SendErrorMessage(EmailMessage)
	Dim Email_To, Email_From, Email_Subject, Email_Body, Email_Server
	Dim SQLStr
	
	Email_To		= "drugsourcesupport@novalibra.com"
	Email_From		= "drugsourcesupport@novalibra.com"
	Email_Subject	= "Drug Source Pitney-Bowes Integration Script ERROR"
	Email_Body		= Replace(EmailMessage, "'", "''")
	Email_Server	= "192.168.1.9"
	
	SQLStr = "sp_SQLSMTPMail @vcTo='" & Email_To & "', @vcHTMLBody='" & Email_Body & "', @vcSubject='" & Email_Subject & "', @vcSender='" & Email_From & "', @vcFrom='" & Email_From & "', @vcSMTPServer='" & Email_Server & "'"
	RunSQL SQLStr
	
End Function

Function AuthorizeCC_AuthorizeNet(p_Store_ID, p_Order_ID, p_Requested_Action)	'As Integer
	AuthorizeCC_AuthorizeNet = 0
	
	Dim objAuthConn, objAuthRec, AuthSQLStr, i
	Dim xml, strStatus, strRetVal, arRetVal
	Dim x_login, x_tran_key, x_version, x_test_request, x_delim_data, x_delim_char, x_relay_response
	Dim x_first_name, x_last_name, x_company, x_address, x_city, x_state, x_zip, x_country, x_phone, x_fax
	Dim x_cust_id, x_invoice_num, x_description
	Dim x_ship_to_first_name, x_ship_to_last_name, x_ship_to_address, x_ship_to_city, x_ship_to_state, x_ship_to_zip, x_ship_to_country
	Dim x_amount, x_currency_code, x_method, x_type
	Dim x_card_num, x_exp_date, x_card_code, x_trans_id
	Dim x_email, x_email_customer, x_merchant_email
	Dim isTestMode, Store_Name
	
	Set objAuthConn = CreateObject("ADODB.Connection")
	Set objAuthRec = CreateObject("ADODB.RecordSet")
	
	isTestMode = true
	
	objAuthConn.Open ConnStr
	
	AuthSQLStr = "SELECT * FROM Shopping_Store WITH (NOLOCK) WHERE [ID] = '0" & p_Store_ID & "'"
	'WScript.Echo AuthSQLStr
	objAuthRec.Open AuthSQLStr, objAuthConn, 2, 3, 1 'adOpenDynamic, adLockOptimistic, adCmdText
	if not objAuthRec.EOF then
		x_login = SmartValues(objAuthRec("Gateway_UserID"), "CStr")
		x_tran_key = SmartValues(objAuthRec("Gateway_Password"), "CStr")
		isTestMode = CBool(SmartValues(objAuthRec("Test_Mode"), "CBool"))
		Store_Name = SmartValues(objAuthRec("Store_Name"), "CStr")
	else
		Exit Function
	end if
	objAuthRec.Close
	
	AuthSQLStr = "sp_shopping_order_details_by_orderID '0" & p_Order_ID & "'"
	'WScript.Echo AuthSQLStr
	objAuthRec.Open AuthSQLStr, objAuthConn, 2, 3, 1 'adOpenDynamic, adLockOptimistic, adCmdText
	if not objAuthRec.EOF then
		x_amount = SmartValues(objAuthRec("Order_GrandTotal"), "CStr")
	    x_trans_id = SmartValues(objAuthRec("Auth_Trans_ID"), "CStr")
	else
		WScript.Echo "No Order Details Found.  :("
		Exit Function
	end if
	objAuthRec.Close
	
	x_version = "3.1"
	x_test_request = CStr(isTestMode)
	x_delim_data = "true"
	x_delim_char = "|"
	x_relay_response = "false"
	x_currency_code = "USD"
	x_method = "CC"
	
	if IsNumeric(p_Requested_Action) then
	    p_Requested_Action = CLng(p_Requested_Action)
	    
	    Select Case p_Requested_Action
	        Case 1
	            x_type = "PRIOR_AUTH_CAPTURE"
	        Case 2
	            x_type = "CREDIT"
	        Case 3
	            x_type = "VOID"
			Case 4
				x_type = "AUTH_CAPTURE"
	    End Select
	else
	    Exit Function
	end if

	'**************************************************************
	' REQUEST STRING THAT WILL BE SUBMITTED BY WAY OF
	' THE HTTPS POST OPERATION
	'**************************************************************
	Dim vPostData

	vPostData = "x_login=" & x_login
	vPostData = vPostData & "&x_tran_key=" & x_tran_key
	vPostData = vPostData & "&x_version=" & x_version
	vPostData = vPostData & "&x_method=" & x_method
	vPostData = vPostData & "&x_test_request=" & x_test_request
	vPostData = vPostData & "&x_delim_data=" & x_delim_data
	vPostData = vPostData & "&x_delim_char=" & x_delim_char
	vPostData = vPostData & "&x_relay_response=" & x_relay_response
	vPostData = vPostData & "&x_amount=" & x_amount
	vPostData = vPostData & "&x_currency_code=" & x_currency_code
	vPostData = vPostData & "&x_type=" & x_type
	vPostData = vPostData & "&x_trans_id=" & x_trans_id

	'**************************************************************
	' SEND DATA VIA HTTPS POST TO AUTHORIZE.NET
	' USING XMLHTTP TO PERFORM THE POST OPERATION
	'**************************************************************
	Set xml = CreateObject("Microsoft.XMLHTTP")
	if isTestMode then
		' xml.open "POST", "https://test.authorize.net/gateway/transact.dll", false
		' CHANGED TO USE THE CERTIFICATION URL FOR LIVE ACCOUNT CREDENTIALS
		xml.open "POST", "https://certification.authorize.net/gateway/transact.dll", false
	else
		xml.open "POST", "https://secure.authorize.net/gateway/transact.dll", false
	end if

	'WScript.Echo vPostData
	xml.send vPostData
	strStatus = xml.Status
	strRetval = xml.responseText
	Set xml = nothing

	strRetVal = Trim(strRetVal)
	arRetVal = split(strRetVal, "|", -1)

	if UBound(arRetVal) < 7 then
		Exit Function
	else
        if IsNumeric(SmartValues(arRetVal(0), "CStr")) then
		    AuthorizeCC_AuthorizeNet = CLng(SmartValues(arRetVal(0), "CStr"))
        end if
		
		AuthSQLStr = "SELECT * FROM Shopping_Order WHERE [ID] = '0" & p_Order_ID & "'"
		objAuthRec.Open AuthSQLStr, objAuthConn, 2, 3, 1 'adOpenDynamic, adLockOptimistic, adCmdText
		if not objAuthRec.EOF then
			
			'objAuthRec("Auth_Response_ID") = SmartValues(arRetVal(0), "CStr")
			'objAuthRec("Auth_Response_String") = strRetVal
			'objAuthRec("Auth_Trans_ID") = SmartValues(arRetVal(6), "CStr")

			if CLng(SmartValues(arRetVal(0), "CStr")) = 2 then
				objAuthRec("Trans_Declined") = strRetVal

			elseif CLng(SmartValues(arRetVal(0), "CStr")) = 1 then
				Select Case p_Requested_Action
					Case 1
						objAuthRec("Funds_Captured") = 1
						objAuthRec("Funds_Refunded") = 0
						objAuthRec("Trans_Voided") = 0
					Case 2
						objAuthRec("Funds_Captured") = 0
						objAuthRec("Funds_Refunded") = 1
						objAuthRec("Trans_Voided") = 0
					Case 3
						objAuthRec("Funds_Captured") = 0
						objAuthRec("Funds_Refunded") = 0
						objAuthRec("Trans_Voided") = 1
					Case 4
						objAuthRec("Funds_Captured") = 1
						objAuthRec("Funds_Refunded") = 0
						objAuthRec("Trans_Voided") = 0
				End Select
			end if

			objAuthRec.UpdateBatch
		end if
		objAuthRec.Close	
	end if
	
	objAuthConn.Close
	Set objAuthRec = Nothing
	Set objAuthConn = Nothing
End Function

function SmartValues(Value, whatType)
    If Not IsNull(Value) And Trim(Value) <> "" Then
        Select Case whatType
            Case "CStr"
                SmartValues = CStr(Value)
            Case "CCur"
                SmartValues = CCur(Value)
            Case "CLng"
                SmartValues = CLng(Value)
            Case "CInt"
                SmartValues = CInt(Value)
            Case "CSng"
                SmartValues = CSng(Value)
            Case "CDbl"
                SmartValues = CDbl(Value)
            Case "CBool"
                SmartValues = CBool(Value)
            Case "CByte"
                SmartValues = CByte(Value)
            Case "CDate"
                If Value = "00/00/0000" Then
                    SmartValues = ""
                Else
                    SmartValues = CDate(Value)
                End If
            Case "FormatNumber"
                SmartValues = FormatNumber(Value,2,0,0,-1)
            Case "FormatCurrency"
                SmartValues = FormatCurrency(Value,2,0,0,-1)
			Case Else
                SmartValues = Value
        End Select
    Else
		if whatType = "FormatNumber" or whatType = "FormatCurrency" then
			Select Case whatType
				Case "FormatNumber"
					SmartValues = FormatNumber(0,2,0,0,-1)
				Case "FormatCurrency"
					SmartValues = FormatCurrency(0,2,0,0,-1)
			End Select
		else
			SmartValues = ""
        end if
    End If
End function

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
				strInput = Right(strInput, reqdLength)
			elseif LCase(Trim(padDir)) = "r" or LCase(Trim(padDir)) = "right" then
				strInput = Left(strInput, reqdLength)
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

Function SendOrderUpdateEmail(p_Store_ID, p_Order_ID)	'As Integer
	SendOrderUpdateEmail = 1
	
	Dim objConn, objRec, SQLStr, i
	Dim xml, strStatus, strRetVal, arRetVal
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
	Dim Mailer, BodyText
	
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

	Set objConn = CreateObject("ADODB.Connection")
	Set objRec = CreateObject("ADODB.RecordSet")
	
	isTestMode = true
	
	objConn.Open ConnStr
	
	SQLStr = "SELECT * FROM Shopping_Store WITH (NOLOCK) WHERE [ID] = '0" & p_Store_ID & "'"
	'WScript.Echo SQLStr
	objRec.Open SQLStr, objConn, 2, 3, 1 'adOpenDynamic, adLockOptimistic, adCmdText
	if not objRec.EOF then
		isTestMode = CBool(SmartValues(objRec("Test_Mode"), "CBool"))
		Store_Name = Replace(SmartValues(objRec("Store_Name"), "CStr"), ",", "")
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
	else
		Exit Function
	end if
	objRec.Close
	
	SQLStr = "sp_shopping_order_details_by_orderID '0" & p_Order_ID & "'"
	'WScript.Echo SQLStr
	objRec.Open SQLStr, objConn, 2, 3, 1 'adOpenDynamic, adLockOptimistic, adCmdText
	if not objRec.EOF then
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
	else
		WScript.Echo "No Order Details Found.  :("
		Exit Function
	end if
	objRec.Close
	
	Set Mailer			= CreateObject("SMTPsvg.Mailer")
	Mailer.RemoteHost	= "mail.novalibra.com"
	Mailer.UserName		= ""
	Mailer.Password		= ""
	Mailer.FromAddress	= Store_CC_Email
	Mailer.FromName		= Store_Name
'	Mailer.AddRecipient "Ken Wallace", "ken.wallace@novalibra.com"
	Mailer.AddRecipient Email_Address, Email_Address '	"Ken Wallace", "ken.wallace@novalibra.com"
	Mailer.AddCC Store_Name, Store_CC_Email
	Mailer.AddBCC "drugsourcesupport@novalibra.com", "drugsourcesupport@novalibra.com"
	Mailer.Subject		= "Important Order Update from " & Store_Name & " Order " & p_Order_ID

	BodyText = "Hello!" & vbCrLf & "We thought you'd like to know that your order has shipped. " & vbCrLf

	BodyText = BodyText & vbCrLf
	BodyText = BodyText & "Order Number: " & p_Order_ID & vbCrLf

	BodyText = BodyText & vbCrLf
	BodyText = BodyText & "Your Customer Information:" & vbCrLf
	if Len(First_Name) > 0 or Len(Last_Name) > 0 then
		if Len(First_Name) > 0 then BodyText = BodyText & vbTab & First_Name & " "
		if Len(Last_Name) > 0 then BodyText = BodyText & Last_Name
	end if
	BodyText = BodyText & vbCrLf	
	if Len(Email_Address) > 0 then BodyText = BodyText & vbTab & Email_Address & vbCrLf
	if Len(Organization) > 0 then BodyText = BodyText & vbTab & Organization & vbCrLf

	BodyText = BodyText & vbCrLf	
	BodyText = BodyText & "Shipped To:" & vbCrLf
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

	if Len(Trim(Ship_Method_Description)) > 0 then
		BodyText = BodyText & vbCrLf

		BodyText = BodyText & "Ship Method:" & vbCrLf
		BodyText = BodyText & vbTab & Ship_Method_Description & vbCrLf& vbCrLf	

		if Len(Date_Order_Shipped) > 0 then BodyText = BodyText & "Ship Date:" & vbCrLf
		if Len(Date_Order_Shipped) > 0 then BodyText = BodyText & vbTab & Date_Order_Shipped & vbCrLf & vbCrLf

		if Len(Shipment_Tracking_Number) > 0 then
			BodyText = BodyText & "Reference Number:" & vbCrLf
			BodyText = BodyText & vbTab & Shipment_Tracking_Number & vbCrLf
			BodyText = BodyText & vbCrLf
			if InStr(Ship_Method_Description, "UPS") > 0 then
				BodyText = BodyText & "You may be able to track this UPS shipment at UPS.com. Click the following link for more information:" & vbCrLf
				BodyText = BodyText & "http://wwwapps.ups.com/WebTracking/processInputRequest?tracknum=" & Shipment_Tracking_Number & vbCrLf
				BodyText = BodyText & vbCrLf
			else
				BodyText = BodyText & "You may be able to track this shipment. Click the following link for more information:" & vbCrLf
				BodyText = BodyText & "http://trkcnfrm1.smi.usps.com/PTSInternetWeb/InterLabelInquiry.do?strOrigTrackNum=" & Shipment_Tracking_Number & vbCrLf
				BodyText = BodyText & vbCrLf
			end if
		end if
	end if

	BodyText = BodyText & vbCrLf
	BodyText = BodyText & "Thank you for purchasing from " & Store_Name & vbCrLf
	BodyText = BodyText & Store_URL & vbCrLf
	BodyText = BodyText & vbCrLf & vbCrLf
	BodyText = BodyText & "This completes your order. " & vbCrLf & vbCrLf
	BodyText = BodyText & "Thank you! " & vbCrLf

	Mailer.BodyText = BodyText

	'Mailer.QMessage	= true
	Mailer.IgnoreMalformedAddress = true
	Mailer.IgnoreRecipientErrors = true
	
	Call Mailer.SendMail
	Set Mailer = Nothing

	Set objRec = Nothing
	Set objConn = Nothing
End Function
