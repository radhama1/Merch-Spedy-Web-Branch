<%@ LANGUAGE=VBSCRIPT%>
<%
'==============================================================================
' Author: Ken Wallace, Principal - Ken Wallace Design
'==============================================================================
Option Explicit
Response.Buffer = True
Response.Expires = -1441
%>
<!--#include file="../../app_include/smartValues.asp"-->
<%
Dim objConn, objRec, SQLStr, connStr, i
Dim productID, boolIsNew, parentCategoryID
Dim Display_Name, Display_Summary_Short, Display_Summary_Long, Keywords, isEnabled
Dim LargeImgFileName, ThumbImgFileName, LineartFileName, MSDS_FileName
Dim Manufacturer_ID, Supplier_ID, Mfg_Model_Number, Mfg_MSRP, SKU
Dim Manufacturer_Name, Supplier_Name
Dim SELL_UOM_ID, SELL_QtyPerUOM, SELL_QtyMultiplierPerUOM, SELL_PricePerUOM
Dim RECV_UOM_ID, RECV_QtyPerUOM, RECV_QtyMultiplierPerUOM, RECV_PricePerUOM
Dim Discontinued_Flag, Product_Type
Dim UOM_Abbreviation, UOM_Long_Name, UOM_Base_Number, UOM_Multiplier
Dim Taxable, SalePrice_Enabled, QtySalePrice_Enabled
Dim SalePrice_Message_Enabled, QtySalePrice_Message_Enabled
Dim SalePrice_Message, QtySalePrice_Message
Dim Inventory_QtyOnHand, Inventory_LowStockThreshold, Inventory_OutOfStockLimit
Dim Shipping_Length, Shipping_Width, Shipping_Height, Shipping_Weight, Shipping_HandlingFee, Shipping_CustomFeesEnabled
Dim txtStartDate, txtStartTime, txtEndDate, txtEndTime, boolUseSchedule, boolUseStartDate, boolUseEndDate
Dim Sale_Price, Sale_Type, Sale_StartDate, Sale_EndDate		
Dim QtySale_Price, QtySale_Type, QtySale_MinQty, QtySale_MaxQty, QtySale_StartDate, QtySale_EndDate
Dim Shipping_Price, Shipping_Type, Shipping_MinQty, Shipping_MaxQty, Shipping_StartDate, Shipping_EndDate

for i = 1 to Request.Form.Count
	Response.Write Request.Form.Key(i) & ": '" & Request.Form(i) & "'<br>" & vbCrLf
next

Set objConn = Server.CreateObject("ADODB.Connection")
Set objRec = Server.CreateObject("ADODB.RecordSet")

connStr = Application.Value("connStr")
objConn.Open connStr

productID = Trim(Request.Form("pid"))
if IsNumeric(productID) then
	productID = CInt(productID)
else
	productID = 0
end if

parentCategoryID = Request("pcid")
if IsNumeric(parentCategoryID) then
	parentCategoryID = CInt(parentCategoryID)
else
	parentCategoryID = 0
end if

boolIsNew = CBool(Request.Form("boolIsNew"))
if boolIsNew and productID = 0 then
	boolIsNew = true
else
	boolIsNew = false
end if

Display_Name = Trim(Request.Form("Display_Name"))
Display_Summary_Short = Trim(Request.Form("Display_Summary_Short"))
Display_Summary_Long = Trim(Request.Form("Display_Summary_Long"))
Keywords = Trim(Request.Form("Keywords"))
ThumbImgFileName = Trim(Request.Form("ThumbImgFileName"))
LargeImgFileName = Trim(Request.Form("LargeImgFileName"))
LineartFileName = Trim(Request.Form("LineartFileName"))
MSDS_FileName = Trim(Request.Form("MSDS_FileName"))
Manufacturer_ID = Trim(Request.Form("Manufacturer_ID"))
Supplier_ID = Trim(Request.Form("Supplier_ID"))
Mfg_Model_Number = Trim(Request.Form("Mfg_Model_Number"))
Mfg_MSRP = Trim(Request.Form("Mfg_MSRP"))
SKU = Trim(Request.Form("SKU"))
SELL_UOM_ID = Trim(Request.Form("SELL_UOM_ID"))
SELL_QtyPerUOM = Trim(Request.Form("SELL_QtyPerUOM"))
SELL_QtyMultiplierPerUOM = Trim(Request.Form("SELL_QtyMultiplierPerUOM"))
SELL_PricePerUOM = Trim(Request.Form("SELL_PricePerUOM"))
RECV_UOM_ID = Trim(Request.Form("RECV_UOM_ID"))
RECV_QtyPerUOM = Trim(Request.Form("RECV_QtyPerUOM"))
RECV_QtyMultiplierPerUOM = Trim(Request.Form("RECV_QtyMultiplierPerUOM"))
RECV_PricePerUOM = Trim(Request.Form("RECV_PricePerUOM"))
Discontinued_Flag = Trim(Request.Form("Discontinued_Flag"))
Product_Type = Trim(Request.Form("Product_Type"))
Taxable = Trim(Request.Form("Taxable"))
SalePrice_Enabled = Trim(Request.Form("SalePrice_Enabled"))
SalePrice_Message_Enabled = Trim(Request.Form("SalePrice_Message_Enabled"))
SalePrice_Message = Trim(Request.Form("SalePrice_Message"))
QtySalePrice_Enabled = Trim(Request.Form("QtySalePrice_Enabled"))
QtySalePrice_Message_Enabled = Trim(Request.Form("QtySalePrice_Message_Enabled"))
QtySalePrice_Message = Trim(Request.Form("QtySalePrice_Message"))
Inventory_QtyOnHand = Trim(Request.Form("Inventory_QtyOnHand"))
Inventory_LowStockThreshold = Trim(Request.Form("Inventory_LowStockThreshold"))
Inventory_OutOfStockLimit = Trim(Request.Form("Inventory_OutOfStockLimit"))
Shipping_Length = Trim(Request.Form("Shipping_Length"))
Shipping_Width = Trim(Request.Form("Shipping_Width"))
Shipping_Height = Trim(Request.Form("Shipping_Height"))
Shipping_Weight = Trim(Request.Form("Shipping_Weight"))
Shipping_HandlingFee = Trim(Request.Form("Shipping_HandlingFee"))
Shipping_CustomFeesEnabled = Trim(Request.Form("Shipping_CustomFeesEnabled"))

'Schedule
txtStartDate = Trim(Request.Form("txtStartDate"))
txtStartTime = Trim(Request.Form("txtStartTime"))
txtEndDate = Trim(Request.Form("txtEndDate"))
txtEndTime = Trim(Request.Form("txtEndTime"))

boolUseSchedule = CBool(Request.Form("boolUseSchedule"))
boolUseStartDate = CBool(Request.Form("boolUseStartDate"))
boolUseEndDate = CBool(Request.Form("boolUseEndDate"))

objConn.BeginTrans

if boolIsNew then
	objRec.Open "Product_Heading", objConn, adOpenKeyset, adLockOptimistic, adCmdTable
	objRec.AddNew

	if Len(Display_Name) > 0 then
		objRec("Display_Name") = SmartValues(Display_Name, "CStr")
	else
		objRec("Display_Name") = "UNTITLED PRODUCT"
	end if
	if Len(Display_Summary_Short) > 0 then
		objRec("Display_Summary_Short") = SmartValues(Display_Summary_Short, "CStr")
	end if
	if Len(Display_Summary_Long) > 0 then
		objRec("Display_Summary_Long") = SmartValues(Display_Summary_Long, "CStr")
	end if
	if Len(Keywords) > 0 then
		objRec("Keywords") = SmartValues(Keywords, "CStr")
	end if
	if Len(SKU) > 0 then
		objRec("SKU") = SmartValues(SKU, "CStr")
	end if
	if Len(Product_Type) > 0 then
		objRec("Product_Type") = SmartValues(Product_Type, "CStr")
	end if
	if Len(LargeImgFileName) > 0 then
		objRec("Large_Img_FileName") = SmartValues(LargeImgFileName, "CStr")
	end if
	if Len(ThumbImgFileName) > 0 then
		objRec("Thumb_Img_FileName") = SmartValues(ThumbImgFileName, "CStr")
	end if
	if Len(LineartFileName) > 0 then
		objRec("LineArt_Img_FileName") = SmartValues(LineartFileName, "CStr")
	end if
	if Len(MSDS_FileName) > 0 then
		objRec("MSDS_FileName") = SmartValues(MSDS_FileName, "CStr")
	end if
	if Len(Manufacturer_ID) > 0 then
		objRec("Manufacturer_ID") = SmartValues(Manufacturer_ID, "CInt")
	end if
	if Len(Supplier_ID) > 0 then
		objRec("Supplier_ID") = SmartValues(Supplier_ID, "CInt")
	end if
	if Len(Mfg_Model_Number) > 0 then
		objRec("Mfg_Model_Number") = SmartValues(Mfg_Model_Number, "CStr")
	end if
	if Len(Mfg_MSRP) > 0 then
		objRec("Mfg_MSRP") = SmartValues(Mfg_MSRP, "CCur")
	end if
	if Len(SELL_UOM_ID) > 0 then
		objRec("SELL_UOM_ID") = SmartValues(SELL_UOM_ID, "CInt")
	end if
	if Len(SELL_QtyPerUOM) > 0 then
		objRec("SELL_QtyPerUOM") = SmartValues(SELL_QtyPerUOM, "CInt")
	end if
	if Len(SELL_QtyMultiplierPerUOM) > 0 then
		objRec("SELL_QtyMultiplierPerUOM") = SmartValues(SELL_QtyMultiplierPerUOM, "CStr")
	end if
	if Len(SELL_PricePerUOM) > 0 then
		objRec("SELL_PricePerUOM") = SmartValues(SELL_PricePerUOM, "CCur")
	end if
	if Len(RECV_UOM_ID) > 0 then
		objRec("RECV_UOM_ID") = SmartValues(RECV_UOM_ID, "CInt")
	end if
	if Len(RECV_QtyPerUOM) > 0 then
		objRec("RECV_QtyPerUOM") = SmartValues(RECV_QtyPerUOM, "CInt")
	end if
	if Len(RECV_QtyMultiplierPerUOM) > 0 then
		objRec("RECV_QtyMultiplierPerUOM") = SmartValues(RECV_QtyMultiplierPerUOM, "CInt")
	end if
	if Len(RECV_PricePerUOM) > 0 then
		objRec("RECV_PricePerUOM") = SmartValues(RECV_PricePerUOM, "CCur")
	end if
	if Len(Taxable) > 0 then
		objRec("Taxable") = 1
	end if
	if Len(SalePrice_Enabled) > 0 then
		objRec("SalePrice_Enabled") = 1
	end if
	if Len(SalePrice_Message_Enabled) > 0 then
		objRec("SalePrice_Message_Enabled") = 1
	end if
	if Len(SalePrice_Message) > 0 then
		objRec("SalePrice_Message") = SmartValues(SalePrice_Message, "CStr")
	end if
	if Len(QtySalePrice_Enabled) > 0 then
		objRec("QtySalePrice_Enabled") = 1
	end if
	if Len(QtySalePrice_Message_Enabled) > 0 then
		objRec("QtySalePrice_Message_Enabled") = 1
	end if
	if Len(QtySalePrice_Message) > 0 then
		objRec("QtySalePrice_Message") = SmartValues(QtySalePrice_Message, "CStr")
	end if
	if Len(Inventory_QtyOnHand) > 0 then
		objRec("Inventory_QtyOnHand") = SmartValues(Inventory_QtyOnHand, "CInt")
	end if
	if Len(Inventory_LowStockThreshold) > 0 then
		objRec("Inventory_LowStockThreshold") = SmartValues(Inventory_LowStockThreshold, "CInt")
	end if
	if Len(Inventory_OutOfStockLimit) > 0 then
		objRec("Inventory_OutOfStockLimit") = SmartValues(Inventory_OutOfStockLimit, "CInt")
	end if
	if Len(Shipping_Length) > 0 then
		objRec("Shipping_Length") = SmartValues(Shipping_Length, "CDbl")
	end if
	if Len(Shipping_Width) > 0 then
		objRec("Shipping_Width") = SmartValues(Shipping_Width, "CDbl")
	end if
	if Len(Shipping_Height) > 0 then
		objRec("Shipping_Height") = SmartValues(Shipping_Height, "CDbl")
	end if
	if Len(Shipping_Weight) > 0 then
		objRec("Shipping_Weight") = SmartValues(Shipping_Weight, "CDbl")
	end if
	if Len(Shipping_HandlingFee) > 0 then
		objRec("Shipping_HandlingFee") = SmartValues(Shipping_HandlingFee, "CCur")
	end if
	if Len(Shipping_CustomFeesEnabled) > 0 then
		objRec("Shipping_CustomFeesEnabled") = 1
	end if

	if boolUseSchedule then
		if boolUseStartDate then
			if Len(txtStartDate) > 0 and IsDate(txtStartDate) then
				objRec("Start_Date") = CDate(txtStartDate & " " & txtStartTime)
			else
				objRec("Start_Date") = Null
			end if
		else
			objRec("Start_Date") = Null
		end if
		if boolUseEndDate then
			if Len(txtEndDate) > 0 and IsDate(txtEndDate) then
				objRec("End_Date") = CDate(txtEndDate & " " & txtEndTime)
			else
				objRec("End_Date") = Null
			end if
		else
			objRec("End_Date") = Null
		end if
	else
		objRec("Start_Date") = Null
		objRec("End_Date") = Null
	end if

	objRec.Update
	objRec.Close

	SQLStr = "SELECT @@IDENTITY FROM Product_Heading"
	Set objRec = objConn.Execute(SQLStr)
	productID = CInt(objRec(0))
	objRec.Close

	if productID > 0 then
		'- - - - - - - - - - - - - - - 
		'Assign product to parent category
		'- - - - - - - - - - - - - - - 	
		SQLStr = "INSERT INTO Product_Heading_Category (Heading_ID, Category_ID) VALUES (" & productID & ", " & parentCategoryID &")"
		Set objRec = objConn.Execute(SQLStr)
		
		'- - - - - - - - - - - - - - - 
		'Delete prices and start fresh
		'- - - - - - - - - - - - - - - 	
		SQLStr = "DELETE FROM Product_Price WHERE Product_Heading_ID = " & productID & " AND Price_Type IN (1, 2, 3, 4, 5)"
		Set objRec = objConn.Execute(SQLStr)

		'- - - - - - - - - - - - - - - 
		'Save Regular Price, MSRP, and Cost
		'- - - - - - - - - - - - - - - 	
		if IsNumeric(SELL_PricePerUOM) and Len(Trim(SELL_PricePerUOM)) > 0 then
			if SELL_PricePerUOM > 0 then
				SQLStr = "INSERT INTO Product_Price (Product_Heading_ID, Price_Type, Price) VALUES (" & productID & ", 1, " & SELL_PricePerUOM & ")"
				Set objRec = objConn.Execute(SQLStr)
			end if
		end if
		if IsNumeric(Mfg_MSRP) and Len(Trim(Mfg_MSRP)) > 0 then
			if Mfg_MSRP > 0 then
				SQLStr = "INSERT INTO Product_Price (Product_Heading_ID, Price_Type, Price) VALUES (" & productID & ", 2, " & Mfg_MSRP & ")"
				Set objRec = objConn.Execute(SQLStr)
			end if
		end if
		if IsNumeric(RECV_PricePerUOM) and Len(Trim(RECV_PricePerUOM)) > 0 then
			if RECV_PricePerUOM > 0 then
				SQLStr = "INSERT INTO Product_Price (Product_Heading_ID, Price_Type, Price) VALUES (" & productID & ", 5, " & RECV_PricePerUOM & ")"
				Set objRec = objConn.Execute(SQLStr)
			end if
		end if

		'- - - - - - - - - - - - - - - 
		'Check for Sale prices
		'- - - - - - - - - - - - - - - 	
		for i = 0 to 5000
			if Len(Trim(Request.Form("fld_salePrice_" & i))) > 0 then
				Sale_Price = Trim(Request.Form("fld_salePrice_" & i))
				
				if IsNumeric(Sale_Price) then
					if Sale_Price > 0 then

						Sale_Type = Trim(Request.Form("fld_saleType_" & i)) '[["1", "Fixed Price"], ["2", "Dollar Discount"], ["3", "Percent Discount"]];

						Sale_StartDate = Trim(Request.Form("fld_saleStartDate_" & i))
						if Len(Sale_StartDate) > 0 and IsDate(Sale_StartDate) then
							Sale_StartDate = "'" & CDate(Sale_StartDate) & "'"
						else
							Sale_StartDate = "NULL"
						end if

						Sale_EndDate = Trim(Request.Form("fld_saleEndDate_" & i))				
						if Len(Sale_EndDate) > 0 and IsDate(Sale_EndDate) then
							Sale_EndDate = "'" & CDate(Sale_EndDate) & "'"
						else
							Sale_EndDate = "NULL"
						end if

						Select Case Sale_Type
							Case "1" 'Fixed Price
								SQLStr = "INSERT INTO Product_Price (Product_Heading_ID, Price_Type, Price, Start_Date, End_Date) VALUES (" & productID & ", 3, " & Sale_Price & ", " & Sale_StartDate & ", " & Sale_EndDate & ")"
								Set objRec = objConn.Execute(SQLStr)
							Case "2" 'Dollar Discount
								SQLStr = "INSERT INTO Product_Price (Product_Heading_ID, Price_Type, Price_Discount, Start_Date, End_Date) VALUES (" & productID & ", 3, " & Sale_Price & ", " & Sale_StartDate & ", " & Sale_EndDate & ")"
								Set objRec = objConn.Execute(SQLStr)
							Case "3" 'Percent Discount
								SQLStr = "INSERT INTO Product_Price (Product_Heading_ID, Price_Type, Percent_Discount, Start_Date, End_Date) VALUES (" & productID & ", 3, " & Sale_Price & ", " & Sale_StartDate & ", " & Sale_EndDate & ")"
								Set objRec = objConn.Execute(SQLStr)
						End Select
						Response.Write "SQLStr: '" & SQLStr & "'<br>" & vbCrLf

					end if
				end if
				
			end if
		next

		'- - - - - - - - - - - - - - - 
		'Check for Quantity Discount prices
		'- - - - - - - - - - - - - - - 
		for i = 0 to 5000
			if Len(Trim(Request.Form("fld_qtysalePrice_" & i))) > 0 then
				QtySale_Price = Trim(Request.Form("fld_qtysalePrice_" & i))

				if IsNumeric(QtySale_Price) then
					if QtySale_Price > 0 then

						QtySale_Type = Trim(Request.Form("fld_qtysaleType_" & i)) '[["1", "Fixed Price"], ["2", "Dollar Discount"], ["3", "Percent Discount"]];
						QtySale_MinQty = Trim(Request.Form("fld_qtysaleMinRange_" & i))
						QtySale_MaxQty = Trim(Request.Form("fld_qtysaleMaxRange_" & i))				

						QtySale_StartDate = Trim(Request.Form("fld_qtysaleStartDate_" & i))
						if Len(QtySale_StartDate) > 0 and IsDate(QtySale_StartDate) then
							QtySale_StartDate = "'" & CDate(QtySale_StartDate) & "'"
						else
							QtySale_StartDate = "NULL"
						end if

						QtySale_EndDate = Trim(Request.Form("fld_qtysaleEndDate_" & i))				
						if Len(QtySale_EndDate) > 0 and IsDate(QtySale_EndDate) then
							QtySale_EndDate = "'" & CDate(QtySale_EndDate) & "'"
						else
							QtySale_EndDate = "NULL"
						end if

						Select Case QtySale_Type
							Case "1" 'Fixed Price
								SQLStr = "INSERT INTO Product_Price (Product_Heading_ID, Price_Type, Price, Min_Qty, Max_Qty, Start_Date, End_Date) VALUES (" & productID & ", 4, " & QtySale_Price & ", '" & QtySale_MinQty & "', '" & QtySale_MaxQty & "', " & QtySale_StartDate & ", " & QtySale_EndDate & ")"
								Set objRec = objConn.Execute(SQLStr)
							Case "2" 'Dollar Discount
								SQLStr = "INSERT INTO Product_Price (Product_Heading_ID, Price_Type, Price_Discount, Min_Qty, Max_Qty, Start_Date, End_Date) VALUES (" & productID & ", 4, " & QtySale_Price & ", '" & QtySale_MinQty & "', '" & QtySale_MaxQty & "', " & QtySale_StartDate & ", " & QtySale_EndDate & ")"
								Set objRec = objConn.Execute(SQLStr)
							Case "3" 'Percent Discount
								SQLStr = "INSERT INTO Product_Price (Product_Heading_ID, Price_Type, Percent_Discount, Min_Qty, Max_Qty, Start_Date, End_Date) VALUES (" & productID & ", 4, " & QtySale_Price & ", '" & QtySale_MinQty & "', '" & QtySale_MaxQty & "', " & QtySale_StartDate & ", " & QtySale_EndDate & ")"
								Set objRec = objConn.Execute(SQLStr)
						End Select
						Response.Write "SQLStr: '" & SQLStr & "'<br>" & vbCrLf
					
					end if
				end if
					
			end if
		next

	end if
else
	SQLStr = "SELECT * FROM Product_Heading WHERE [ID] = " & productID
	objRec.Open SQLStr, objConn, adOpenKeyset, adLockBatchOptimistic, adCmdText
	if not objRec.EOF then

		if Len(Display_Name) > 0 then
			objRec("Display_Name") = SmartValues(Display_Name, "CStr")
		else
			objRec("Display_Name") = "UNTITLED PRODUCT"
		end if
		if Len(Display_Summary_Short) > 0 then
			objRec("Display_Summary_Short") = SmartValues(Display_Summary_Short, "CStr")
		else
			objRec("Display_Summary_Short") = Null
		end if
		if Len(Display_Summary_Long) > 0 then
			objRec("Display_Summary_Long") = SmartValues(Display_Summary_Long, "CStr")
		else
			objRec("Display_Summary_Long") = Null
		end if
		if Len(Keywords) > 0 then
			objRec("Keywords") = SmartValues(Keywords, "CStr")
		else
			objRec("Keywords") = Null
		end if
		if Len(SKU) > 0 then
			objRec("SKU") = SmartValues(SKU, "CStr")
		else
			objRec("SKU") = Null
		end if
		if Len(Product_Type) > 0 then
			objRec("Product_Type") = SmartValues(Product_Type, "CStr")
		end if
		if Len(LargeImgFileName) > 0 then
			objRec("Large_Img_FileName") = SmartValues(LargeImgFileName, "CStr")
		else
			objRec("Large_Img_FileName") = Null
		end if
		if Len(ThumbImgFileName) > 0 then
			objRec("Thumb_Img_FileName") = SmartValues(ThumbImgFileName, "CStr")
		else
			objRec("Thumb_Img_FileName") = Null
		end if
		if Len(LineartFileName) > 0 then
			objRec("LineArt_Img_FileName") = SmartValues(LineartFileName, "CStr")
		else
			objRec("LineArt_Img_FileName") = Null
		end if
		if Len(MSDS_FileName) > 0 then
			objRec("MSDS_FileName") = SmartValues(MSDS_FileName, "CStr")
		else
			objRec("MSDS_FileName") = Null
		end if
		if Len(Manufacturer_ID) > 0 then
			objRec("Manufacturer_ID") = SmartValues(Manufacturer_ID, "CInt")
		else
			objRec("Manufacturer_ID") = 0
		end if
		if Len(Supplier_ID) > 0 then
			objRec("Supplier_ID") = SmartValues(Supplier_ID, "CInt")
		else
			objRec("Supplier_ID") = 0
		end if
		if Len(Mfg_Model_Number) > 0 then
			objRec("Mfg_Model_Number") = SmartValues(Mfg_Model_Number, "CStr")
		else
			objRec("Mfg_Model_Number") = Null
		end if
		if Len(Mfg_MSRP) > 0 then
			objRec("Mfg_MSRP") = SmartValues(Mfg_MSRP, "CStr")
		else
			objRec("Mfg_MSRP") = Null
		end if
		if Len(SELL_UOM_ID) > 0 then
			objRec("SELL_UOM_ID") = SmartValues(SELL_UOM_ID, "CInt")
		else
			objRec("SELL_UOM_ID") = 0
		end if
		if Len(SELL_QtyPerUOM) > 0 then
			objRec("SELL_QtyPerUOM") = SmartValues(SELL_QtyPerUOM, "CInt")
		else
			objRec("SELL_QtyPerUOM") = 1
		end if
		if Len(SELL_QtyMultiplierPerUOM) > 0 then
			objRec("SELL_QtyMultiplierPerUOM") = SmartValues(SELL_QtyMultiplierPerUOM, "CInt")
		else
			objRec("SELL_QtyMultiplierPerUOM") = 1
		end if
		if Len(SELL_PricePerUOM) > 0 then
			objRec("SELL_PricePerUOM") = SmartValues(SELL_PricePerUOM, "CCur")
		else
			objRec("SELL_PricePerUOM") = Null
		end if
		if Len(RECV_UOM_ID) > 0 then
			objRec("RECV_UOM_ID") = SmartValues(RECV_UOM_ID, "CInt")
		else
			objRec("RECV_UOM_ID") = 0
		end if
		if Len(RECV_QtyPerUOM) > 0 then
			objRec("RECV_QtyPerUOM") = SmartValues(RECV_QtyPerUOM, "CInt")
		else
			objRec("RECV_QtyPerUOM") = 1
		end if
		if Len(RECV_QtyMultiplierPerUOM) > 0 then
			objRec("RECV_QtyMultiplierPerUOM") = SmartValues(RECV_QtyMultiplierPerUOM, "CInt")
		else
			objRec("RECV_QtyMultiplierPerUOM") = 1
		end if
		if Len(RECV_PricePerUOM) > 0 then
			objRec("RECV_PricePerUOM") = SmartValues(RECV_PricePerUOM, "CCur")
		else
			objRec("RECV_PricePerUOM") = Null
		end if
		if Len(Taxable) > 0 then
			objRec("Taxable") = 1
		else
			objRec("Taxable") = 0
		end if
		if Len(SalePrice_Enabled) > 0 then
			objRec("SalePrice_Enabled") = 1
		else
			objRec("SalePrice_Enabled") = 0
		end if
		if Len(SalePrice_Message_Enabled) > 0 then
			objRec("SalePrice_Message_Enabled") = 1
		else
			objRec("SalePrice_Message_Enabled") = 0
		end if
		if Len(SalePrice_Message) > 0 then
			objRec("SalePrice_Message") = SmartValues(SalePrice_Message, "CStr")
		else
			objRec("SalePrice_Message") = Null
		end if
		if Len(QtySalePrice_Enabled) > 0 then
			objRec("QtySalePrice_Enabled") = 1
		else
			objRec("QtySalePrice_Enabled") = 0
		end if
		if Len(QtySalePrice_Message_Enabled) > 0 then
			objRec("QtySalePrice_Message_Enabled") = 1
		else
			objRec("QtySalePrice_Message_Enabled") = 0
		end if
		if Len(QtySalePrice_Message) > 0 then
			objRec("QtySalePrice_Message") = SmartValues(QtySalePrice_Message, "CStr")
		else
			objRec("QtySalePrice_Message") = Null
		end if
		if Len(Inventory_QtyOnHand) > 0 then
			objRec("Inventory_QtyOnHand") = SmartValues(Inventory_QtyOnHand, "CInt")
		else
			objRec("Inventory_QtyOnHand") = Null
		end if
		if Len(Inventory_LowStockThreshold) > 0 then
			objRec("Inventory_LowStockThreshold") = SmartValues(Inventory_LowStockThreshold, "CInt")
		else
			objRec("Inventory_LowStockThreshold") = Null
		end if
		if Len(Inventory_OutOfStockLimit) > 0 then
			objRec("Inventory_OutOfStockLimit") = SmartValues(Inventory_OutOfStockLimit, "CInt")
		else
			objRec("Inventory_OutOfStockLimit") = Null
		end if
		if Len(Shipping_Length) > 0 then
			objRec("Shipping_Length") = SmartValues(Shipping_Length, "CDbl")
		else
			objRec("Shipping_Length") = Null
		end if
		if Len(Shipping_Width) > 0 then
			objRec("Shipping_Width") = SmartValues(Shipping_Width, "CDbl")
		else
			objRec("Shipping_Width") = Null
		end if
		if Len(Shipping_Height) > 0 then
			objRec("Shipping_Height") = SmartValues(Shipping_Height, "CDbl")
		else
			objRec("Shipping_Height") = Null
		end if
		if Len(Shipping_Weight) > 0 then
			objRec("Shipping_Weight") = SmartValues(Shipping_Weight, "CDbl")
		else
			objRec("Shipping_Weight") = Null
		end if
		if Len(Shipping_HandlingFee) > 0 then
			objRec("Shipping_HandlingFee") = SmartValues(Shipping_HandlingFee, "CCur")
		else
			objRec("Shipping_HandlingFee") = Null
		end if
		if Len(Shipping_CustomFeesEnabled) > 0 then
			objRec("Shipping_CustomFeesEnabled") = 1
		else
			objRec("Shipping_CustomFeesEnabled") = 0
		end if

		if boolUseSchedule then
			if boolUseStartDate then
				if Len(txtStartDate) > 0 and IsDate(txtStartDate) then
					objRec("Start_Date") = CDate(txtStartDate & " " & txtStartTime)
				else
					objRec("Start_Date") = Null
				end if
			else
				objRec("Start_Date") = Null
			end if
			if boolUseEndDate then
				if Len(txtEndDate) > 0 and IsDate(txtEndDate) then
					objRec("End_Date") = CDate(txtEndDate & " " & txtEndTime)
				else
					objRec("End_Date") = Null
				end if
			else
				objRec("End_Date") = Null
			end if
		else
			objRec("Start_Date") = Null
			objRec("End_Date") = Null
		end if

		objRec("Date_Last_Modified") = CDate(Now())
		objRec.UpdateBatch
	end if
	objRec.Close

	if productID > 0 then
		'- - - - - - - - - - - - - - - 
		'Delete prices and start fresh
		'- - - - - - - - - - - - - - - 	
		SQLStr = "DELETE FROM Product_Price WHERE Product_Heading_ID = " & productID & " AND Price_Type IN (1, 2, 3, 4, 5)"
		Set objRec = objConn.Execute(SQLStr)

		'- - - - - - - - - - - - - - - 
		'Save Regular Price, MSRP, and Cost
		'- - - - - - - - - - - - - - - 	
		if IsNumeric(SELL_PricePerUOM) and Len(Trim(SELL_PricePerUOM)) > 0 then
			if SELL_PricePerUOM > 0 then
				SQLStr = "INSERT INTO Product_Price (Product_Heading_ID, Price_Type, Price) VALUES (" & productID & ", 1, " & SELL_PricePerUOM & ")"
				Set objRec = objConn.Execute(SQLStr)
				Response.Write "SQLStr: '" & SQLStr & "'<br>" & vbCrLf
			end if
		end if
		if IsNumeric(Mfg_MSRP) and Len(Trim(Mfg_MSRP)) > 0 then
			if Mfg_MSRP > 0 then
				SQLStr = "INSERT INTO Product_Price (Product_Heading_ID, Price_Type, Price) VALUES (" & productID & ", 2, " & Mfg_MSRP & ")"
				Set objRec = objConn.Execute(SQLStr)
				Response.Write "SQLStr: '" & SQLStr & "'<br>" & vbCrLf
			end if
		end if
		if IsNumeric(RECV_PricePerUOM) and Len(Trim(RECV_PricePerUOM)) > 0 then
			if RECV_PricePerUOM > 0 then
				SQLStr = "INSERT INTO Product_Price (Product_Heading_ID, Price_Type, Price) VALUES (" & productID & ", 5, " & RECV_PricePerUOM & ")"
				Set objRec = objConn.Execute(SQLStr)
				Response.Write "SQLStr: '" & SQLStr & "'<br>" & vbCrLf
			end if
		end if

		for i = 0 to 5000
			if Len(Trim(Request.Form("fld_salePrice_" & i))) > 0 then
				Sale_Price = Trim(Request.Form("fld_salePrice_" & i))
				
				if IsNumeric(Sale_Price) then
					if Sale_Price > 0 then

						Sale_Type = Trim(Request.Form("fld_saleType_" & i)) '[["1", "Fixed Price"], ["2", "Dollar Discount"], ["3", "Percent Discount"]];

						Sale_StartDate = Trim(Request.Form("fld_saleStartDate_" & i))
						if Len(Sale_StartDate) > 0 and IsDate(Sale_StartDate) then
							Sale_StartDate = "'" & CDate(Sale_StartDate) & "'"
						else
							Sale_StartDate = "NULL"
						end if

						Sale_EndDate = Trim(Request.Form("fld_saleEndDate_" & i))				
						if Len(Sale_EndDate) > 0 and IsDate(Sale_EndDate) then
							Sale_EndDate = "'" & CDate(Sale_EndDate) & "'"
						else
							Sale_EndDate = "NULL"
						end if

						Select Case Sale_Type
							Case "1" 'Fixed Price
								SQLStr = "INSERT INTO Product_Price (Product_Heading_ID, Price_Type, Price, Start_Date, End_Date) VALUES (" & productID & ", 3, " & Sale_Price & ", " & Sale_StartDate & ", " & Sale_EndDate & ")"
								Set objRec = objConn.Execute(SQLStr)
							Case "2" 'Dollar Discount
								SQLStr = "INSERT INTO Product_Price (Product_Heading_ID, Price_Type, Price_Discount, Start_Date, End_Date) VALUES (" & productID & ", 3, " & Sale_Price & ", " & Sale_StartDate & ", " & Sale_EndDate & ")"
								Set objRec = objConn.Execute(SQLStr)
							Case "3" 'Percent Discount
								SQLStr = "INSERT INTO Product_Price (Product_Heading_ID, Price_Type, Percent_Discount, Start_Date, End_Date) VALUES (" & productID & ", 3, " & Sale_Price & ", " & Sale_StartDate & ", " & Sale_EndDate & ")"
								Set objRec = objConn.Execute(SQLStr)
						End Select
						Response.Write "SQLStr: '" & SQLStr & "'<br>" & vbCrLf

					end if
				end if
				
			end if
		next

		'- - - - - - - - - - - - - - - 
		'Check for Quantity Discount prices
		'- - - - - - - - - - - - - - - 
		for i = 0 to 5000
			if Len(Trim(Request.Form("fld_qtysalePrice_" & i))) > 0 then
				QtySale_Price = Trim(Request.Form("fld_qtysalePrice_" & i))
				
				if IsNumeric(QtySale_Price) then
					if QtySale_Price > 0 then

						QtySale_Type = Trim(Request.Form("fld_qtysaleSaleType_" & i)) '[["1", "Fixed Price"], ["2", "Dollar Discount"], ["3", "Percent Discount"]];
						QtySale_MinQty = Trim(Request.Form("fld_qtysaleMinRange_" & i))
						QtySale_MaxQty = Trim(Request.Form("fld_qtysaleMaxRange_" & i))				

						QtySale_StartDate = Trim(Request.Form("fld_qtysaleStartDate_" & i))
						if Len(QtySale_StartDate) > 0 and IsDate(QtySale_StartDate) then
							QtySale_StartDate = "'" & CDate(QtySale_StartDate) & "'"
						else
							QtySale_StartDate = "NULL"
						end if

						QtySale_EndDate = Trim(Request.Form("fld_qtysaleEndDate_" & i))				
						if Len(QtySale_EndDate) > 0 and IsDate(QtySale_EndDate) then
							QtySale_EndDate = "'" & CDate(QtySale_EndDate) & "'"
						else
							QtySale_EndDate = "NULL"
						end if

						Select Case QtySale_Type
							Case "1" 'Fixed Price
								SQLStr = "INSERT INTO Product_Price (Product_Heading_ID, Price_Type, Price, Min_Qty, Max_Qty, Start_Date, End_Date) VALUES (" & productID & ", 4, " & QtySale_Price & ", '" & QtySale_MinQty & "', '" & QtySale_MaxQty & "', " & QtySale_StartDate & ", " & QtySale_EndDate & ")"
								Set objRec = objConn.Execute(SQLStr)
							Case "2" 'Dollar Discount
								SQLStr = "INSERT INTO Product_Price (Product_Heading_ID, Price_Type, Price_Discount, Min_Qty, Max_Qty, Start_Date, End_Date) VALUES (" & productID & ", 4, " & QtySale_Price & ", '" & QtySale_MinQty & "', '" & QtySale_MaxQty & "', " & QtySale_StartDate & ", " & QtySale_EndDate & ")"
								Set objRec = objConn.Execute(SQLStr)
							Case "3" 'Percent Discount
								SQLStr = "INSERT INTO Product_Price (Product_Heading_ID, Price_Type, Percent_Discount, Min_Qty, Max_Qty, Start_Date, End_Date) VALUES (" & productID & ", 4, " & QtySale_Price & ", '" & QtySale_MinQty & "', '" & QtySale_MaxQty & "', " & QtySale_StartDate & ", " & QtySale_EndDate & ")"
								Set objRec = objConn.Execute(SQLStr)
						End Select
						Response.Write "SQLStr: '" & SQLStr & "'<br>" & vbCrLf
					
					end if
				end if
					
			end if
		next

	end if

end if

if objConn.Errors.Count < 1 and Err.number < 1 then
	objConn.CommitTrans
	Session.Value("PRODUCT_SAVE_SUCCESS") = "1"
else
	objConn.RollbackTrans
	Session.Value("PRODUCT_SAVE_SUCCESS") = "0"
end if

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

if CBool(Session.Value("PRODUCT_SAVE_SUCCESS")) then
%>
<script language="javascript">
	parent.frames["header"].document.location = "./../../app_include/blank_cccccc.html";
	parent.frames["controls"].document.location = "./../../app_include/blank_cccccc.html";
	parent.frames["body"].document.location = "product_details_work_finish.asp";
</script>
<%
else
%>
Errors Occurred.  Please Try Again. Or...<br>
<a href="javascript:self.close();">Click to close</a>
<%
end if

Session.Value("PRODUCT_SAVE_SUCCESS") = ""
%>
