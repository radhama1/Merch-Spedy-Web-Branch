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
<!--#include file="../../app_include/findNeedleInHayStack.asp"-->
<!--#include file="../../app_include/returnDataWithGetRows.asp"-->
<%
Dim productID, boolIsNew, parentCategoryID
Dim objConn, objRec, SQLStr, connStr, i, strRows
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

Dim allowedRoles, allowedGroups, allowedUsers
Dim arAllowedRoles, arAllowedGroups, arAllowedUsers
Dim role, group, user

Dim rowCounter, curIteration
Dim arDetailsDataRows, dictDetailsDataCols
Dim arScheduleDataRows, dictScheduleDataCols

Dim txtStartDate, txtStartTime, txtEndDate, txtEndTime
Dim boolUseSchedule, boolUseStartDate, boolUseEndDate

Set dictDetailsDataCols		= Server.CreateObject("Scripting.Dictionary")
Set dictScheduleDataCols	= Server.CreateObject("Scripting.Dictionary")

productID = Request("pid")
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

Set objConn = Server.CreateObject("ADODB.Connection")
Set objRec = Server.CreateObject("ADODB.RecordSet")
connStr = Application.Value("connStr")
objConn.Open connStr

if productID = 0 then
	boolIsNew = true
else
	boolIsNew = false
	Call returnDataWithGetRows(connStr, "sp_product_heading_by_headingID " & productID, arDetailsDataRows, dictDetailsDataCols)
	Call returnDataWithGetRows(connStr, "SELECT Start_Date, End_Date FROM Product_Heading WHERE [ID] = " & productID, arScheduleDataRows, dictScheduleDataCols)
end if
%>
<html>
<head>
	<title><%if boolIsNew then%>Add Product<%else%>Edit Product<%end if%></title>
	<style type="text/css">
	<!--
		A {text-decoration: none; cursor: hand;}
		A:HOVER {text-decoration: underline; cursor: hand;}
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
			font-family: Arial, Verdana, Geneva, Helvetica;
			font-size: 12px;
		}
		
		TEXTAREA {font-family: Arial, Verdana, Geneva, Helvetica; font-size: 12px;}
	//-->
	</style>
	<script language=javascript type="text/javascript" src="./../../app_include/ediTable_v1.0.js"></script>
	<link rel="stylesheet" type="text/css" href="./../../app_include/ediTable.css">
	<script language=javascript>
	<!--
		var isMac = (navigator.appVersion.indexOf("Mac")!=-1) ? true : false;

		function initTabs(thisTabName)
		{
			clickMenu(thisTabName);
		}
	
		function clickMenu(tabName)
		{
			clearMenus();

			switch (tabName)
			{
				case "descriptionTab":
					workspace_description.style.display = "";
					break;

				case "priceTab":
					workspace_price.style.display = "";
					break;
				
				case "inventoryTab":
					workspace_inventory.style.display = "";
					break;
				
				case "shippingTab":
					workspace_shipping.style.display = "";
					break;
				
				case "scheduleTab":
					workspace_schedule.style.display = "";
					break;
				
				default:
					clearMenus();
					break;
			}
		}
		
		function clearMenus()
		{
			workspace_description.style.display = "none";
			workspace_price.style.display = "none";
			workspace_inventory.style.display = "none";
			workspace_shipping.style.display = "none";
			workspace_schedule.style.display = "none";
		}
				
		//called when the Calendar icon is clicked
		function dateWin(field)
		{ 
			hwnd = window.open('../../app_include/popup_calendar.asp?f=' + escape(field), 'winCalendar', 'width=150,height=150,top=400,left=400,toolbar=0,location=0,directories=0,status=0,menuBar=0,scrollBars=0,resizable=0');
			hwnd.focus();
		}
		
		function openFileChooserWindow(srcField)
		{
			chooserWin = window.open("./../product_filemgr/browsefiles.asp?fld=" + srcField, "chooserWin_" + srcField, "width=710,height=570,toolbar=0,location=0,directories=0,status=1,menuBar=0,scrollBars=0,resizable=0");
			chooserWin.focus();
		}

		function openUOMChooserWindow(srcField)
		{
			chooseUOMWin = window.open("./product_choose_uom.asp?fld=" + srcField, "chooseUOMWin_" + srcField, "width=500,height=500,toolbar=0,location=0,directories=0,status=1,menuBar=0,scrollBars=0,resizable=1");
			chooseUOMWin.focus();
		}
		
		function toggleCustomMessage(textField)
		{
			if (!typeof(textField) == "object") return false;
			switch (textField.disabled)
			{
				case true:
					textField.style.backgroundColor = "#fff";
					textField.disabled = false;
					break;
				case false:
					textField.style.backgroundColor = "#ccc";
					textField.disabled = true;
					break;
			}
		}
	//-->
	</script>
</head>
<body bgcolor="cccccc" topmargin=0 leftmargin=0 marginheight=0 marginwidth=0>
<table width=100% cellpadding=0 cellspacing=0 border=0>
	<form name="theForm" action="product_details_work.asp" method="POST">
	<tr bgcolor="cccccc"><td colspan=2><img src="../images/spacer.gif" height=5 border=0></td></tr>
	<tr bgcolor="cccccc">
		<td><img src="../images/spacer.gif" height=400 width=1 border=0></td>
		<td width=100% valign=top>
			<%
			'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			'DESCRIPTION EDITING TAB
			'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			if dictDetailsDataCols("ColCount") > 0 and dictDetailsDataCols("RecordCount") > 0 then
				Display_Name = SmartValues(arDetailsDataRows(dictDetailsDataCols("Display_Name"), 0), "CStr")
				Display_Summary_Short = SmartValues(arDetailsDataRows(dictDetailsDataCols("Display_Summary_Short"), 0), "CStr")
				Display_Summary_Long = SmartValues(arDetailsDataRows(dictDetailsDataCols("Display_Summary_Long"), 0), "CStr")
				Keywords = SmartValues(arDetailsDataRows(dictDetailsDataCols("Keywords"), 0), "CStr")
				SKU = SmartValues(arDetailsDataRows(dictDetailsDataCols("SKU"), 0), "CStr")
				Product_Type = SmartValues(arDetailsDataRows(dictDetailsDataCols("Product_Type"), 0), "CInt")
				ThumbImgFileName = SmartValues(arDetailsDataRows(dictDetailsDataCols("Thumb_Img_FileName"), 0), "CStr")
				LargeImgFileName = SmartValues(arDetailsDataRows(dictDetailsDataCols("Large_Img_FileName"), 0), "CStr")
				LineartFileName = SmartValues(arDetailsDataRows(dictDetailsDataCols("LineArt_Img_FileName"), 0), "CStr")
				MSDS_FileName = SmartValues(arDetailsDataRows(dictDetailsDataCols("MSDS_FileName"), 0), "CStr")
				Discontinued_Flag = SmartValues(arDetailsDataRows(dictDetailsDataCols("Discontinued_Flag"), 0), "CStr")
				SKU = SmartValues(arDetailsDataRows(dictDetailsDataCols("SKU"), 0), "CStr")
				Mfg_Model_Number = SmartValues(arDetailsDataRows(dictDetailsDataCols("Mfg_Model_Number"), 0), "CStr")
				Manufacturer_ID = SmartValues(arDetailsDataRows(dictDetailsDataCols("Manufacturer_ID"), 0), "CInt")
				Manufacturer_Name = SmartValues(arDetailsDataRows(dictDetailsDataCols("Manufacturer_Name"), 0), "CStr")
				Supplier_ID = SmartValues(arDetailsDataRows(dictDetailsDataCols("Supplier_ID"), 0), "CInt")
				Supplier_Name = SmartValues(arDetailsDataRows(dictDetailsDataCols("Supplier_Name"), 0), "CStr")
			end if
			%>
			<div id="workspace_description" name="workspace_description" style="display:none">
				<table width=100% cellpadding=0 cellspacing=0 border=0>
					<tr>
						<td><img src="../images/spacer.gif" height=1 width=10 border=0></td>
						<td nowrap=true valign=top>
							<table cellpadding=0 cellspacing=0 border=0>
								<tr>
									<td colspan=2>
										<font style="font-family:Arial, Helvetica;font-size:12px;color:#000000">
										<b>Product Name</b>
										</font>
									</td>
								</tr>
								<tr><td colspan=2><input type="text" size=50 maxlength=500 name="Display_Name" value="<%=Display_Name%>" AutoComplete="off"></td></tr>
								<tr><td colspan=2><img src="./images/spacer.gif" height=5 width=1 border=0></td></tr>
								<tr>
									<td colspan=2>
										<font style="font-family:Arial, Helvetica;font-size:12px;color:#000000">
										<b>Product SKU</b>
										</font>
									</td>
								</tr>
								<tr><td colspan=2><input type="text" size=50 maxlength=500 name="SKU" value="<%=SKU%>" AutoComplete="off"></td></tr>
								<tr><td colspan=2><img src="./images/spacer.gif" height=5 width=1 border=0></td></tr>
								<tr>
									<td colspan=2>
										<font style="font-family:Arial, Helvetica;font-size:12px;color:#000000">
										<b>Manufacturer Model Number</b>
										</font>
									</td>
								</tr>
								<tr><td colspan=2><input type="text" size=50 maxlength=500 name="Mfg_Model_Number" value="<%=Mfg_Model_Number%>" AutoComplete="off"></td></tr>
								<tr><td colspan=2><img src="./images/spacer.gif" height=5 width=1 border=0></td></tr>
								<tr>
									<td colspan=2>
										<font style="font-family:Arial, Helvetica;font-size:12px;color:#000000">
										<b>Manufacturer</b>
										</font>
									</td>
								</tr>
								<tr>
									<td colspan=2>
										<select name="Manufacturer_ID" style="width: 323px;">
										<%
										SQLStr = "sp_product_manufacturers_returnall"
										objRec.Open SQLStr, objConn, adOpenKeyset, adLockBatchOptimistic, adCmdText
										if not objRec.EOF then
										%>
											<option value="0">
										<%
											Do Until objRec.EOF
										%>
											<option value="<%=objRec("ID")%>"<%if Manufacturer_ID = objRec("ID") then Response.Write " SELECTED"%>><%=objRec("File_As")%> (<%=objRec("ID")%>)
										<%
												objRec.MoveNext
											Loop
										else
										%>
											<option value="0">
											<option value="0" style="color: #999;">No Manufacturers Configured
										<%
										end if
										objRec.Close
										%>
										</select>
									</td>
								</tr>
								<tr><td colspan=2><img src="./images/spacer.gif" height=5 width=1 border=0></td></tr>
								<tr>
									<td colspan=2>
										<font style="font-family:Arial, Helvetica;font-size:12px;color:#000000">
										<b>Supplier</b>
										</font>
									</td>
								</tr>
								<tr>
									<td colspan=2>
										<select name="Supplier_ID" style="width: 323px;">
										<%
										SQLStr = "sp_product_suppliers_returnall"
										objRec.Open SQLStr, objConn, adOpenKeyset, adLockBatchOptimistic, adCmdText
										if not objRec.EOF then
										%>
											<option value="0">
										<%
											Do Until objRec.EOF
										%>
											<option value="<%=objRec("ID")%>"<%if Supplier_ID = objRec("ID") then Response.Write " SELECTED"%>><%=objRec("File_As")%> (<%=objRec("ID")%>)
										<%
												objRec.MoveNext
											Loop
										else
										%>
											<option value="0">
											<option value="0" style="color: #999;">No Suppliers Configured
										<%
										end if
										objRec.Close
										%>
										</select>
									</td>
								</tr>
								<tr><td colspan=2><img src="./images/spacer.gif" height=5 width=1 border=0></td></tr>
								<tr>
									<td>
										<font style="font-family:Arial, Helvetica;font-size:12px;color:#000000">
										<b>Small/Thumbnail Image Filename</b>
										</font>
									</td>
									<td align=right valign=bottom>
										<font style="font-family:Arial, Helvetica;font-size:9px;color:#000000">
										<a href="javascript:openFileChooserWindow('ThumbImgFileName'); void(0);">browse</a>
										</font>
									</td>
								</tr>
								<tr><td colspan=2><input type="text" size=50 maxlength=500 name="ThumbImgFileName" value="<%=ThumbImgFileName%>" AutoComplete="off"></td></tr>
								<tr><td colspan=2><img src="./images/spacer.gif" height=5 width=1 border=0></td></tr>
								<tr>
									<td>
										<font style="font-family:Arial, Helvetica;font-size:12px;color:#000000">
										<b>Large Image Filename</b>
										</font>
									</td>
									<td align=right valign=bottom>
										<font style="font-family:Arial, Helvetica;font-size:9px;color:#000000">
										<a href="javascript:openFileChooserWindow('LargeImgFileName'); void(0);">browse</a>
										</font>
									</td>
								</tr>
								<tr><td colspan=2><input type="text" size=50 maxlength=500 name="LargeImgFileName" value="<%=LargeImgFileName%>" AutoComplete="off"></td></tr>
								<tr><td colspan=2><img src="./images/spacer.gif" height=5 width=1 border=0></td></tr>
								<tr>
									<td>
										<font style="font-family:Arial, Helvetica;font-size:12px;color:#000000">
										<b>Lineart Filename</b>
										</font>
									</td>
									<td align=right valign=bottom>
										<font style="font-family:Arial, Helvetica;font-size:9px;color:#000000">
										<a href="javascript:openFileChooserWindow('LineartFileName'); void(0);">browse</a>
										</font>
									</td>
								</tr>
								<tr><td colspan=2><input type="text" size=50 maxlength=500 name="LineartFileName" value="<%=LineartFileName%>" AutoComplete="off"></td></tr>
								<tr><td colspan=2><img src="./images/spacer.gif" height=5 width=1 border=0></td></tr>
								<tr>
									<td>
										<font style="font-family:Arial, Helvetica;font-size:12px;color:#000000">
										<b>MSDS Filename</b>
										</font>
									</td>
									<td align=right valign=bottom>
										<font style="font-family:Arial, Helvetica;font-size:9px;color:#000000">
										<a href="javascript:openFileChooserWindow('MSDS_FileName'); void(0);">browse</a>
										</font>
									</td>
								</tr>
								<tr><td colspan=2><input type="text" size=50 maxlength=500 name="MSDS_FileName" value="<%=MSDS_FileName%>" AutoComplete="off"></td></tr>
							</table>
						</td>
						<td><img src="../images/spacer.gif" height=1 width=10 border=0></td>
						<td nowrap=true valign=top>
							<table cellpadding=0 cellspacing=0 border=0>
								<tr>
									<td>
										<font style="font-family:Arial, Helvetica;font-size:12px;color:#000000">
										<b>Product Type</b>
										</font>
									</td>
									<td align=right valign=bottom>
									<!--
										<font style="font-family:Arial, Helvetica;font-size:9px;color:#000000">
										<a href="javascript: void(0);">add</a>
										</font>
									-->
									</td>
								</tr>
								<tr>
									<td colspan=2>
										<select name="Product_Type" id="Product_Type" style="width: 320px;">
											<option value="1"<%if Product_Type = 1 then Response.Write " SELECTED"%>>Product
											<option value="2"<%if Product_Type = 2 then Response.Write " SELECTED"%>>Electronic Download
											<option value="3"<%if Product_Type = 3 then Response.Write " SELECTED"%>>Service
											<option value="4"<%if Product_Type = 4 then Response.Write " SELECTED"%>>Subscription
											<option value="0"<%if Product_Type = 0 then Response.Write " SELECTED"%>>Other
										</select>
									</td>
								</tr>
								<tr><td colspan=2><img src="./images/spacer.gif" height=7 width=1 border=0></td></tr>
								<tr>
									<td colspan=2>
										<font style="font-family:Arial, Verdana, Geneva, Helvetica;font-size:12px;color:#000000">
										<b>Summary/Short Description</b>
										</font>
									</td>
								</tr>
								<tr><td colspan=2><textarea wrap="virtual" name="Display_Summary_Short" rows=2 cols=37 style="height: 40px; width: 320px;"><%=Display_Summary_Short%></textarea></td></tr>
								<tr><td colspan=2><img src="./images/spacer.gif" height=5 width=1 border=0></td></tr>
								<tr>
									<td colspan=2>
										<font style="font-family:Arial, Verdana, Geneva, Helvetica;font-size:12px;color:#000000">
										<b>Long Description</b>
										</font>
									</td>
								</tr>
								<tr><td colspan=2><textarea wrap="virtual" name="Display_Summary_Long" rows=10 cols=37 style="height: 200px; width: 320px;"><%=Display_Summary_Long%></textarea></td></tr>
								<tr><td colspan=2><img src="./images/spacer.gif" height=7 width=1 border=0></td></tr>
								<tr>
									<td colspan=2>
										<font style="font-family:Arial, Verdana, Geneva, Helvetica;font-size:12px;color:#000000">
										<b>Keywords</b>
										</font>
									</td>
								</tr>
								<tr><td colspan=2><textarea wrap="virtual" name="Keywords" rows=2 cols=37 style="height: 40px; width: 320px;"><%=Keywords%></textarea></td></tr>
							</table>
						</td>
						<td width=100%><img src="../images/spacer.gif" height=1 width=10 border=0></td>
					</tr>
					<tr><td><img src="../images/spacer.gif" height=20 width=1 border=0></td></tr>
				</table>
			</div>
			<%
			'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			'PRICE TAB
			'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			if dictDetailsDataCols("ColCount") > 0 and dictDetailsDataCols("RecordCount") > 0 then
				SELL_UOM_ID = SmartValues(arDetailsDataRows(dictDetailsDataCols("SELL_UOM_ID"), 0), "CInt")
				SELL_QtyPerUOM = SmartValues(arDetailsDataRows(dictDetailsDataCols("SELL_QtyPerUOM"), 0), "CInt")
				SELL_QtyMultiplierPerUOM = SmartValues(arDetailsDataRows(dictDetailsDataCols("SELL_QtyMultiplierPerUOM"), 0), "CInt")
				SELL_PricePerUOM = SmartValues(arDetailsDataRows(dictDetailsDataCols("Regular_Price"), 0), "CCur")
				Mfg_MSRP = SmartValues(arDetailsDataRows(dictDetailsDataCols("MSRP"), 0), "CCur")
				UOM_Abbreviation = SmartValues(arDetailsDataRows(dictDetailsDataCols("UOM_Abbreviation"), 0), "CStr")
				UOM_Long_Name = SmartValues(arDetailsDataRows(dictDetailsDataCols("UOM_Long_Name"), 0), "CStr")
				UOM_Base_Number = SmartValues(arDetailsDataRows(dictDetailsDataCols("UOM_Base_Number"), 0), "CInt")
				UOM_Multiplier = SmartValues(arDetailsDataRows(dictDetailsDataCols("UOM_Multiplier"), 0), "CInt")
				Taxable = SmartValues(arDetailsDataRows(dictDetailsDataCols("Taxable"), 0), "CBool")
				SalePrice_Enabled = SmartValues(arDetailsDataRows(dictDetailsDataCols("SalePrice_Enabled"), 0), "CBool")
				SalePrice_Message_Enabled = SmartValues(arDetailsDataRows(dictDetailsDataCols("SalePrice_Message_Enabled"), 0), "CBool")
				SalePrice_Message = SmartValues(arDetailsDataRows(dictDetailsDataCols("SalePrice_Message"), 0), "CStr")
				QtySalePrice_Enabled = SmartValues(arDetailsDataRows(dictDetailsDataCols("QtySalePrice_Enabled"), 0), "CBool")
				QtySalePrice_Message_Enabled = SmartValues(arDetailsDataRows(dictDetailsDataCols("QtySalePrice_Message_Enabled"), 0), "CBool")
				QtySalePrice_Message = SmartValues(arDetailsDataRows(dictDetailsDataCols("QtySalePrice_Message"), 0), "CStr")
			end if
			%>
			<div id="workspace_price" name="workspace_price" style="display:none">
				<table width=100% cellpadding=0 cellspacing=0 border=0>
					<tr>
						<td><img src="../images/spacer.gif" height=1 width=10 border=0></td>
						<td valign=top>
							<table cellpadding=0 cellspacing=0 border=0>
								<tr>
									<td valign=top>
										<table cellpadding=0 cellspacing=0 border=0>
											<tr>
												<td valign=top>
													<table cellpadding=0 cellspacing=0 border=0>
														<tr>
															<td colspan=3>
																<font style="font-family:Arial, Helvetica;font-size:14px;color:#666">
																<b>Product Price</b>
																</font>
															</td>
														</tr>
														<tr>
															<td nowrap>
																<font style="font-family:Arial, Helvetica;font-size: 12px;color:#000000">
																<b>Regular Price</b>
																</font>
															</td>
															<td><img src="../images/spacer.gif" height=1 width=10 border=0></td>
															<td><input type="text" name="SELL_PricePerUOM" value="<%=SELL_PricePerUOM%>" style="width: 50px; text-align: right;" size=12 maxlength=12 AutoComplete="off"></td>
														</tr>
														<tr>
															<td nowrap>
																<font style="font-family:Arial, Helvetica;font-size: 12px;color:#000000">
																<b>UOM</b>
																</font>
															</td>
															<td><img src="../images/spacer.gif" height=1 width=10 border=0></td>
															<td nowrap>
																<input type=hidden name="SELL_UOM_ID" value="<%=SELL_UOM_ID%>"> 
																<input type="text" name="SELL_UOM_ID_Text" value="Each" style="width: 50px;" size=10 maxlength=300 AutoComplete="off" disabled>&nbsp;
																<font style="font-family:Arial, Helvetica;font-size:9px;color:#000000">
																<a href="javascript: openUOMChooserWindow('SELL_UOM_ID'); void(0);">change</a>
																</font>
															</td>
														</tr>
														<tr>
															<td colspan=3>
																<table border=0 cellpadding=0 cellspacing=0 width=100%>
																	<tr>
																		<td valign=top><input type=checkbox value="1" id="Taxable" name="Taxable"<%if Taxable then Response.Write " CHECKED"%> style="border: 0px; padding: 0px; margin: 0px;"></td>
																		<td><img src="../images/spacer.gif" height=1 width=5 border=0></td>
																		<td width=100% nowrap>
																			<font style="font-family:Arial, Helvetica;font-size: 12px;color:#000000">
																			<label for="Taxable"><b>This item is Taxable</b></label>
																			</font>
																		</td>
																	</tr>
																</table>
															</td>
														</tr>
													</table>
												</td>
												<td><img src="../images/spacer.gif" height=1 width=20 border=0></td>
												<td bgcolor="999999"><img src="../images/spacer.gif" height=1 width=1 border=0></td>
												<td bgcolor="ececec"><img src="../images/spacer.gif" height=1 width=1 border=0></td>
												<td><img src="../images/spacer.gif" height=1 width=20 border=0></td>
												<td valign=top>
													<table cellpadding=0 cellspacing=0 border=0>
														<tr>
															<td colspan=3>
																<font style="font-family:Arial, Helvetica;font-size:14px;color:#666">
																<b>Price Details</b>
																</font>
															</td>
														</tr>
														<tr>
															<td nowrap>
																<font style="font-family:Arial, Helvetica;font-size: 12px;color:#000000">
																<b>MSRP</b>
																</font>
															</td>
															<td><img src="../images/spacer.gif" height=1 width=10 border=0></td>
															<td><input type="text" name="Mfg_MSRP" value="<%=Mfg_MSRP%>" style="width: 50px; text-align: right;" size=10 maxlength=12 AutoComplete="off"></td>
														</tr>
														<tr>
															<td nowrap>
																<font style="font-family:Arial, Helvetica;font-size: 12px;color:#000000">
																<b>Qty Per Unit</b>
																</font>
															</td>
															<td><img src="../images/spacer.gif" height=1 width=10 border=0></td>
															<td><input type="text" name="SELL_QtyPerUOM" value="<%=SELL_QtyPerUOM%>" style="width: 50px; text-align: right;" size=10 maxlength=12 AutoComplete="off"></td>
														</tr>
														<tr>
															<td nowrap>
																<font style="font-family:Arial, Helvetica;font-size: 12px;color:#000000">
																<b>Qty Multiplier</b>
																</font>
															</td>
															<td><img src="../images/spacer.gif" height=1 width=10 border=0></td>
															<td><input type="text" name="SELL_QtyMultiplierPerUOM" value="<%=SELL_QtyMultiplierPerUOM%>" style="width: 50px; text-align: right;" size=10 maxlength=12 AutoComplete="off"></td>
														</tr>
													</table>
												</td>
											</tr>
										</table>
									</td>
								</tr>
								<tr><td><img src="../images/spacer.gif" height=10 width=1 border=0></td></tr>
								<tr><td bgcolor="999999"><img src="../images/spacer.gif" height=1 width=1 border=0></td></tr>
								<tr><td bgcolor="ececec"><img src="../images/spacer.gif" height=1 width=1 border=0></td></tr>
								<tr><td><img src="../images/spacer.gif" height=5 width=1 border=0></td></tr>
								<tr>
									<td valign=top>
										<table cellpadding=0 cellspacing=0 border=0>
											<tr>
												<td>
													<font style="font-family:Arial, Helvetica;font-size:14px;color:#666">
													<b>Sale Pricing</b>
													</font>
												</td>
											</tr>
											<tr>
												<td>
													<table border=0 cellpadding=0 cellspacing=0>
														<tr>
															<td valign=top>
																<table border=0 cellpadding=0 cellspacing=0>
																	<tr>
																		<td><input type=checkbox value="1"<%if SalePrice_Enabled then Response.Write " CHECKED"%> id="SalePrice_Enabled" name="SalePrice_Enabled" style="border: 0px; padding: 0px; margin: 0px;"></td>
																		<td><img src="../images/spacer.gif" height=1 width=5 border=0></td>
																		<td width=100% nowrap>
																			<font style="font-family:Arial, Helvetica;font-size: 12px;color:#000000">
																			<label for="SalePrice_Enabled">Enable Sale Pricing</label>
																			</font>
																		</td>
																	</tr>
																	<tr>
																		<td><input type=checkbox value="1"<%if SalePrice_Message_Enabled then Response.Write " CHECKED"%> onClick="toggleCustomMessage(SalePrice_Message);" id="SalePrice_Message_Enabled" name="SalePrice_Message_Enabled" style="border: 0px; padding: 0px; margin: 0px;"></td>
																		<td><img src="../images/spacer.gif" height=1 width=5 border=0></td>
																		<td width=100% nowrap>
																			<font style="font-family:Arial, Helvetica;font-size: 12px;color:#000000">
																			<label for="SalePrice_Message_Enabled">Use Custom Message</label>
																			</font>
																		</td>
																	</tr>
																</table>
															</td>
															<td valign=top>
																<table border=0 cellpadding=0 cellspacing=0>
																	<tr>
																		<td>
																			<font style="font-family:Arial, Helvetica;font-size:12px;color:#000000">
																			Custom Message
																			</font>
																		</td>
																	</tr>
																	<tr><td><input type="text" size=30 maxlength=500 name="SalePrice_Message" value="<%=SalePrice_Message%>"<%if not SalePrice_Message_Enabled then%> style="background-color:#ccc;" DISABLED<%end if%> AutoComplete="off"></td></tr>
																</table>
															</td>
														</tr>
														<tr>
															<td><img src="../images/spacer.gif" height=1 width=250 border=0></td>
															<td><img src="../images/spacer.gif" height=1 width=5 border=0></td>
														</tr>
													</table>
												</td>
											</tr>
											<tr>
												<td>
													<div style="margin-top : 5px;" id="ediTableContainer1"><!-- Placeholder for table --></div>
													<%
													strRows = ""
													SQLStr = "sp_shopping_sales_listCustomPrices " & productID
													Response.Write "<!--" & SQLStr & "-->" & vbCrLf
													objRec.Open SQLStr, objConn, adOpenKeyset, adLockBatchOptimistic, adCmdText
													if not objRec.EOF then
														Do Until objRec.EOF
															strRows = strRows & "[""" & objRec("Price") & """, """ & objRec("SaleType") & """, """ & objRec("Start_Date") & """, """ & objRec("End_Date") & """]"
															objRec.MoveNext
															if not objRec.EOF then
																strRows = strRows & ", "
															end if
														Loop
													end if
													objRec.Close
													strRows = "[" & strRows & "]"
													%>
													<script type="text/javascript" language="javascript">
														var salepricingTable = new ediTable();
														salepricingTable.border = 0;
														salepricingTable.cellpadding = 2;
														salepricingTable.cellspacing = 0;
														salepricingTable.width = 0;
														salepricingTable.editBehavior.allowAdd = true;
														salepricingTable.editBehavior.allowDelete = true;
														salepricingTable.editBehavior.removeBtn_vAlign = "top";
														salepricingTable.editBehavior.validateEntries = true;
														salepricingTable.className = "ediTable_table";
														salepricingTable.headClassName = "ediTable_head";
														salepricingTable.rowClassName = "ediTable_row";
														salepricingTable.rowAltClassName = "ediTable_rowAlt";
														salepricingTable.footClassName = "ediTable_foot";

														var newCol = salepricingTable.addColumn("salePrice");
														newCol.label = "Sale&nbsp;Price";
														newCol.editCell_styleStr = "width: 60px;";
														newCol.datatype = "number";
														newCol.datatype_ext = "fixed";
														newCol.datatype_ext_value = "3";
														newCol.editCell_maxLength = "8";
														newCol.align = "right";

														var newCol = salepricingTable.addColumn("saleType");
														newCol.label = "Type";
														newCol.datatype = "select";
														newCol.editCell_select_options = [["1", "Fixed Price"], ["2", "Dollar Discount"], ["3", "Percent Discount"]];
														newCol.editCell_select_defaultOption = 0;
														newCol.editCell_styleStr = "width: 100px; height: 16px; font-family: Verdana; font-size: 9px;"

														var newCol = salepricingTable.addColumn("saleStartDate");
														newCol.label = "Start&nbsp;Date";
														newCol.datatype = "date";

														var newCol = salepricingTable.addColumn("saleEndDate");
														newCol.label = "End&nbsp;Date";
														newCol.datatype = "date";
														
														salepricingTable.Rows = <%=strRows%>;

														salepricingTable.write(ediTableContainer1);
													</script>
													<style type="text/css">

													</style>
												</td>
											</tr>
										</table>
									</td>
								</tr>
								<tr><td><img src="../images/spacer.gif" height=10 width=1 border=0></td></tr>
								<tr><td bgcolor="999999"><img src="../images/spacer.gif" height=1 width=1 border=0></td></tr>
								<tr><td bgcolor="ececec"><img src="../images/spacer.gif" height=1 width=1 border=0></td></tr>
								<tr><td><img src="../images/spacer.gif" height=5 width=1 border=0></td></tr>
								<tr>
									<td valign=top>
										<table cellpadding=0 cellspacing=0 border=0>
											<tr>
												<td>
													<font style="font-family:Arial, Helvetica;font-size:14px;color:#666">
													<b>Quantity Discount Pricing</b>
													</font>
												</td>
											</tr>
											<tr>
												<td>
													<table border=0 cellpadding=0 cellspacing=0>
														<tr>
															<td valign=top>
																<table border=0 cellpadding=0 cellspacing=0>
																	<tr>
																		<td><input type=checkbox value="1"<%if QtySalePrice_Enabled then Response.Write " CHECKED"%> id="QtySalePrice_Enabled" name="QtySalePrice_Enabled" style="border: 0px; padding: 0px; margin: 0px;"></td>
																		<td><img src="../images/spacer.gif" height=1 width=5 border=0></td>
																		<td width=100% nowrap>
																			<font style="font-family:Arial, Helvetica;font-size: 12px;color:#000000">
																			<label for="QtySalePrice_Enabled">Enable Quantity Discount Pricing</label>
																			</font>
																		</td>
																	</tr>
																	<tr>
																		<td><input type=checkbox value="1"<%if QtySalePrice_Message_Enabled then Response.Write " CHECKED"%> onClick="toggleCustomMessage(QtySalePrice_Message);" id="QtySalePrice_Message_Enabled" name="QtySalePrice_Message_Enabled" style="border: 0px; padding: 0px; margin: 0px;"></td>
																		<td><img src="../images/spacer.gif" height=1 width=5 border=0></td>
																		<td width=100% nowrap>
																			<font style="font-family:Arial, Helvetica;font-size: 12px;color:#000000">
																			<label for="QtySalePrice_Message_Enabled">Use Custom Message</label>
																			</font>
																		</td>
																	</tr>
																</table>
															</td>
															<td valign=top>
																<table border=0 cellpadding=0 cellspacing=0>
																	<tr>
																		<td>
																			<font style="font-family:Arial, Helvetica;font-size:12px;color:#000000">
																			Custom Message
																			</font>
																		</td>
																	</tr>
																	<tr><td><input type="text" size=30 maxlength=500 name="QtySalePrice_Message" value="<%=QtySalePrice_Message%>"<%if not QtySalePrice_Message_Enabled then%> style="background-color:#ccc;" DISABLED<%end if%> AutoComplete="off"></td></tr>
																</table>
															</td>
														</tr>
														<tr>
															<td><img src="../images/spacer.gif" height=1 width=250 border=0></td>
															<td><img src="../images/spacer.gif" height=1 width=5 border=0></td>
														</tr>
													</table>
												</td>
											</tr>
											<tr>
												<td>
													<div style="margin-top : 5px;" id="ediTableContainer2"><!-- Placeholder for table --></div>
													<%
													strRows = ""
													SQLStr = "sp_shopping_quantitydiscounts_listCustomPrices " & productID
													Response.Write "<!--" & SQLStr & "-->" & vbCrLf
													objRec.Open SQLStr, objConn, adOpenKeyset, adLockBatchOptimistic, adCmdText
													if not objRec.EOF then
														Do Until objRec.EOF
															strRows = strRows & "[""" & objRec("Price") & """, """ & objRec("SaleType") & """, """ & objRec("Min_Qty") & """, """ & objRec("Max_Qty") & """, """ & objRec("Start_Date") & """, """ & objRec("End_Date") & """]"
															objRec.MoveNext
															if not objRec.EOF then
																strRows = strRows & ", "
															end if
														Loop
													end if
													objRec.Close
													strRows = "[" & strRows & "]"
													%>
													<script type="text/javascript" language="javascript">
														var qtypricingTable = new ediTable();
														qtypricingTable.border = 0;
														qtypricingTable.cellpadding = 2;
														qtypricingTable.cellspacing = 0;
														qtypricingTable.width = 0;
														qtypricingTable.editBehavior.allowAdd = true;
														qtypricingTable.editBehavior.allowDelete = true;
														qtypricingTable.editBehavior.removeBtn_vAlign = "top";
														qtypricingTable.editBehavior.validateEntries = true;
														qtypricingTable.className = "ediTable_table";
														qtypricingTable.headClassName = "ediTable_head";
														qtypricingTable.rowClassName = "ediTable_row";
														qtypricingTable.rowAltClassName = "ediTable_rowAlt";
														qtypricingTable.footClassName = "ediTable_foot";

														var newCol = qtypricingTable.addColumn("qtysalePrice");
														newCol.label = "Price";
														newCol.editCell_styleStr = "width: 60px;";
														newCol.datatype = "number";
														newCol.datatype_ext = "fixed";
														newCol.datatype_ext_value = "3";
														newCol.editCell_maxLength = "8";
														newCol.align = "right";

														var newCol = qtypricingTable.addColumn("qtysaleSaleType");
														newCol.label = "Type";
														newCol.datatype = "select";
														newCol.editCell_select_options = [["1", "Fixed Price"], ["2", "Dollar Discount"], ["3", "Percent Discount"]];
														newCol.editCell_select_defaultOption = 2;
														newCol.editCell_styleStr = "width: 100px; height: 16px; font-family: Verdana; font-size: 9px;"

														var newCol = qtypricingTable.addColumn("qtysaleMinRange");
														newCol.label = "Min";
														newCol.editCell_styleStr = "width: 30px;";
														newCol.datatype = "number";
														newCol.datatype_ext = "fixed";
														newCol.datatype_ext_value = "0";
														newCol.editCell_maxLength = "8";
														newCol.align = "right";

														var newCol = qtypricingTable.addColumn("qtysaleMaxRange");
														newCol.label = "Max";
														newCol.editCell_styleStr = "width: 30px;";
														newCol.datatype = "number";
														newCol.datatype_ext = "fixed";
														newCol.datatype_ext_value = "0";
														newCol.editCell_maxLength = "8";
														newCol.align = "right";

														var newCol = qtypricingTable.addColumn("qtysaleStartDate");
														newCol.label = "Start&nbsp;Date";
														newCol.datatype = "date";

														var newCol = qtypricingTable.addColumn("qtysaleEndDate");
														newCol.label = "End&nbsp;Date";
														newCol.datatype = "date";

														qtypricingTable.Rows = <%=strRows%>;

														qtypricingTable.write(ediTableContainer2);
													</script>
													<style type="text/css">
													
													</style>
												</td>
											</tr>
										</table>
									</td>
								</tr>
							</table>
						</td>
						<td><img src="../images/spacer.gif" height=1 width=10 border=0></td>
					</tr>
				</table>
			</div>
			<%
			'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			'INVENTORY TAB
			'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			if dictDetailsDataCols("ColCount") > 0 and dictDetailsDataCols("RecordCount") > 0 then
				RECV_UOM_ID = SmartValues(arDetailsDataRows(dictDetailsDataCols("RECV_UOM_ID"), 0), "CInt")
				RECV_QtyPerUOM = SmartValues(arDetailsDataRows(dictDetailsDataCols("RECV_QtyPerUOM"), 0), "CInt")
				RECV_QtyMultiplierPerUOM = SmartValues(arDetailsDataRows(dictDetailsDataCols("RECV_QtyMultiplierPerUOM"), 0), "CInt")
				RECV_PricePerUOM = SmartValues(arDetailsDataRows(dictDetailsDataCols("Cost"), 0), "CCur")
				UOM_Abbreviation = SmartValues(arDetailsDataRows(dictDetailsDataCols("UOM_Abbreviation"), 0), "CStr")
				UOM_Long_Name = SmartValues(arDetailsDataRows(dictDetailsDataCols("UOM_Long_Name"), 0), "CStr")
				UOM_Base_Number = SmartValues(arDetailsDataRows(dictDetailsDataCols("UOM_Base_Number"), 0), "CInt")
				UOM_Multiplier = SmartValues(arDetailsDataRows(dictDetailsDataCols("UOM_Multiplier"), 0), "CInt")
			end if
			%>
			<div id="workspace_inventory" name="workspace_inventory" style="display:none">
				<table width=100% cellpadding=0 cellspacing=0 border=0>
					<tr>
						<td><img src="../images/spacer.gif" height=1 width=10 border=0></td>
						<td valign=top>
							<table cellpadding=0 cellspacing=0 border=0>
								<tr>
									<td valign=top>
										<table cellpadding=0 cellspacing=0 border=0>
											<tr>
												<td valign=top>
													<table cellpadding=1 cellspacing=1 border=0>
														<tr>
															<td colspan=3>
																<font style="font-family:Arial, Helvetica;font-size:14px;color:#666">
																<b>Inventory Costs</b>
																</font>
															</td>
														</tr>
														<tr>
															<td nowrap>
																<font style="font-family:Arial, Helvetica;font-size: 12px;color:#000000">
																<b>Cost</b>
																</font>
															</td>
															<td><img src="../images/spacer.gif" height=1 width=10 border=0></td>
															<td><input type="text" name="RECV_PricePerUOM" value="<%=RECV_PricePerUOM%>" style="width: 50px; text-align: right;" size=12 maxlength=12 AutoComplete="off"></td>
														</tr>
														<tr>
															<td nowrap>
																<font style="font-family:Arial, Helvetica;font-size: 12px;color:#000000">
																<b>UOM</b>
																</font>
															</td>
															<td><img src="../images/spacer.gif" height=1 width=10 border=0></td>
															<td nowrap>
																<input type=hidden name="RECV_UOM_ID" value="<%=RECV_UOM_ID%>"> 
																<input type="text" name="RECV_UOM_Text" value="Each" style="width: 50px;" size=10 maxlength=300 AutoComplete="off" disabled>&nbsp;
																<font style="font-family:Arial, Helvetica;font-size:9px;color:#000000">
																<a href="javascript: void(0);">change</a>
																</font>
															</td>
														</tr>
														<tr>
															<td nowrap>
																<font style="font-family:Arial, Helvetica;font-size: 12px;color:#000000">
																<b>Qty Per Unit</b>
																</font>
															</td>
															<td><img src="../images/spacer.gif" height=1 width=10 border=0></td>
															<td><input type="text" name="RECV_QtyPerUOM" value="<%=RECV_QtyPerUOM%>" style="width: 50px; text-align: right;" size=10 maxlength=12 AutoComplete="off"></td>
														</tr>
														<tr>
															<td nowrap>
																<font style="font-family:Arial, Helvetica;font-size: 12px;color:#000000">
																<b>Qty Multiplier</b>
																</font>
															</td>
															<td><img src="../images/spacer.gif" height=1 width=10 border=0></td>
															<td><input type="text" name="RECV_QtyMultiplierPerUOM" value="<%=RECV_QtyMultiplierPerUOM%>" style="width: 50px; text-align: right;" size=10 maxlength=12 AutoComplete="off"></td>
														</tr>
													</table>
												</td>
												<td><img src="../images/spacer.gif" height=1 width=20 border=0></td>
												<td bgcolor="999999"><img src="../images/spacer.gif" height=1 width=1 border=0></td>
												<td bgcolor="ececec"><img src="../images/spacer.gif" height=1 width=1 border=0></td>
												<td><img src="../images/spacer.gif" height=1 width=20 border=0></td>
												<td valign=top>
													<table cellpadding=1 cellspacing=1 border=0>
														<tr>
															<td colspan=3>
																<font style="font-family:Arial, Helvetica;font-size:14px;color:#666">
																<b>Inventory Levels</b>
																</font>
															</td>
														</tr>
														<tr>
															<td nowrap>
																<font style="font-family:Arial, Helvetica;font-size: 12px;color:#000000">
																<b>Quantity on Hand</b>
																</font>
															</td>
															<td><img src="../images/spacer.gif" height=1 width=10 border=0></td>
															<td><input type="text" name="Inventory_QtyOnHand" value="" style="width: 50px; text-align: right;" size=12 maxlength=12 AutoComplete="off"></td>
														</tr>
														<tr>
															<td nowrap>
																<font style="font-family:Arial, Helvetica;font-size: 12px;color:#000000">
																<b>Low Stock Threshold</b>
																</font>
															</td>
															<td><img src="../images/spacer.gif" height=1 width=10 border=0></td>
															<td><input type="text" name="Inventory_LowStockThreshold" value="" style="width: 50px; text-align: right;" size=12 maxlength=12 AutoComplete="off"></td>
														</tr>
														<tr>
															<td nowrap>
																<font style="font-family:Arial, Helvetica;font-size: 12px;color:#000000">
																<b>Out of Stock Limit</b>
																</font>
															</td>
															<td><img src="../images/spacer.gif" height=1 width=10 border=0></td>
															<td><input type="text" name="Inventory_OutofStockLimit" value="" style="width: 50px; text-align: right;" size=12 maxlength=12 AutoComplete="off"></td>
														</tr>
													</table>
												</td>
											</tr>
										</table>
									</td>
								</tr>
							</table>
						</td>
						<td width=100%><img src="../images/spacer.gif" height=1 width=20 border=0></td>
					</tr>
					<tr><td><img src="../images/spacer.gif" height=20 width=1 border=0></td></tr>
				</table>
			</div>
			<%
			'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			'SHIPPING TAB
			'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			if dictDetailsDataCols("ColCount") > 0 and dictDetailsDataCols("RecordCount") > 0 then
			end if
			%>
			<div id="workspace_shipping" name="workspace_shipping" style="display:none">
				<table width=100% cellpadding=0 cellspacing=0 border=0>
					<tr>
						<td><img src="../images/spacer.gif" height=1 width=10 border=0></td>
						<td valign=top>
							<table cellpadding=0 cellspacing=0 border=0>
								<tr>
									<td valign=top>
										<table cellpadding=0 cellspacing=0 border=0>
											<tr>
												<td valign=top>
													<table cellpadding=1 cellspacing=1 border=0>
														<tr>
															<td colspan=3 nowrap>
																<font style="font-family:Arial, Helvetica;font-size:14px;color:#666">
																<b>Package Dimensions</b>
																</font>
															</td>
														</tr>
														<tr>
															<td nowrap>
																<font style="font-family:Arial, Helvetica;font-size: 12px;color:#000000">
																<b>Length</b>
																</font>
															</td>
															<td><img src="../images/spacer.gif" height=1 width=10 border=0></td>
															<td><input type="text" name="Shipping_Length" value="" style="width: 50px; text-align: right;" size=12 maxlength=12 AutoComplete="off"></td>
														</tr>
														<tr>
															<td nowrap>
																<font style="font-family:Arial, Helvetica;font-size: 12px;color:#000000">
																<b>Width</b>
																</font>
															</td>
															<td><img src="../images/spacer.gif" height=1 width=10 border=0></td>
															<td><input type="text" name="Shipping_Width" value="" style="width: 50px; text-align: right;" size=10 maxlength=12 AutoComplete="off"></td>
														</tr>
														<tr>
															<td nowrap>
																<font style="font-family:Arial, Helvetica;font-size: 12px;color:#000000">
																<b>Height</b>
																</font>
															</td>
															<td><img src="../images/spacer.gif" height=1 width=10 border=0></td>
															<td><input type="text" name="Shipping_Height" value="" style="width: 50px; text-align: right;" size=10 maxlength=12 AutoComplete="off"></td>
														</tr>
														<tr>
															<td nowrap>
																<font style="font-family:Arial, Helvetica;font-size: 12px;color:#000000">
																<b>Weight</b>
																</font>
															</td>
															<td><img src="../images/spacer.gif" height=1 width=10 border=0></td>
															<td><input type="text" name="Shipping_Weight" value="" style="width: 50px; text-align: right;" size=10 maxlength=12 AutoComplete="off"></td>
														</tr>
													</table>
												</td>
											</tr>
										</table>
									</td>
								</tr>
							<%if 1 = 2 then%>
								<tr><td><img src="../images/spacer.gif" height=10 width=1 border=0></td></tr>
								<tr><td bgcolor="999999"><img src="../images/spacer.gif" height=1 width=1 border=0></td></tr>
								<tr><td bgcolor="ececec"><img src="../images/spacer.gif" height=1 width=1 border=0></td></tr>
								<tr><td><img src="../images/spacer.gif" height=5 width=1 border=0></td></tr>
								<tr>
									<td valign=top>
										<table cellpadding=0 cellspacing=0 border=0>
											<tr>
												<td>
													<font style="font-family:Arial, Helvetica;font-size:14px;color:#666">
													<b>Shipping & Handling Fees</b>
													</font>
												</td>
											</tr>
											<tr>
												<td>
													<table border=0 cellpadding=0 cellspacing=0>
														<tr>
															<td><input type=checkbox value="1" id="Shipping_CustomFeesEnabled" name="Shipping_CustomFeesEnabled" style="border: 0px; padding: 0px; margin: 0px;"></td>
															<td><img src="../images/spacer.gif" height=1 width=5 border=0></td>
															<td width=100% nowrap>
																<font style="font-family:Arial, Helvetica;font-size: 12px;color:#000000">
																<label for="shippingIsEnabled">Enable Custom Shipping & Handling Fees</label>
																</font>
															</td>
														</tr>
													</table>
												</td>
											</tr>
											<tr>
												<td>
													<div style="margin-top : 5px;" id="ediTableContainer3"><!-- Placeholder for table --></div>
													<script type="text/javascript" language="javascript">
														var shippingTable = new ediTable();
														shippingTable.border = 0;
														shippingTable.cellpadding = 2;
														shippingTable.cellspacing = 0;
														shippingTable.width = 0;
														shippingTable.editBehavior.allowAdd = true;
														shippingTable.editBehavior.allowDelete = true;
														shippingTable.editBehavior.removeBtn_vAlign = "top";
														shippingTable.editBehavior.validateEntries = true;
														shippingTable.className = "ediTable_table";
														shippingTable.headClassName = "ediTable_head";
														shippingTable.rowClassName = "ediTable_row";
														shippingTable.rowAltClassName = "ediTable_rowAlt";
														shippingTable.footClassName = "ediTable_foot";

														var newCol = shippingTable.addColumn("shippingPrice");
														newCol.label = "Sale&nbsp;Price";
														newCol.editCell_styleStr = "width: 60px;";
														newCol.datatype = "number";
														newCol.datatype_ext = "fixed";
														newCol.datatype_ext_value = "3";
														newCol.editCell_maxLength = "8";
														newCol.align = "right";

														var newCol = shippingTable.addColumn("shippingSaleType");
														newCol.label = "Type";
														newCol.datatype = "select";
														newCol.editCell_select_options = [["1", "Fixed Price"], ["2", "Dollar Discount"], ["3", "Percent Discount"]];
														newCol.editCell_select_defaultOption = 0;
														newCol.editCell_styleStr = "width: 100px; height: 16px; font-family: Verdana; font-size: 9px;"

														var newCol = shippingTable.addColumn("shippingMinRange");
														newCol.label = "Min";
														newCol.editCell_styleStr = "width: 40px;";
														newCol.datatype = "number";
														newCol.datatype_ext = "fixed";
														newCol.datatype_ext_value = "0";
														newCol.editCell_maxLength = "8";
														newCol.align = "right";

														var newCol = shippingTable.addColumn("shippingMaxRange");
														newCol.label = "Max";
														newCol.editCell_styleStr = "width: 40px;";
														newCol.datatype = "number";
														newCol.datatype_ext = "fixed";
														newCol.datatype_ext_value = "0";
														newCol.editCell_maxLength = "8";
														newCol.align = "right";

														var newCol = shippingTable.addColumn("shippingStartDate");
														newCol.label = "Start&nbsp;Date";
														newCol.datatype = "date";

														var newCol = shippingTable.addColumn("shippingEndDate");
														newCol.label = "End&nbsp;Date";
														newCol.datatype = "date";

														shippingTable.write(ediTableContainer3);
													</script>
													<style type="text/css">

													</style>
												</td>
											</tr>
										</table>
									</td>
								</tr>
								<tr><td><img src="../images/spacer.gif" height=10 width=1 border=0></td></tr>
								<%end if%>
							</table>
						</td>
						<td width=100%><img src="../images/spacer.gif" height=1 width=20 border=0></td>
					</tr>
					<tr><td><img src="../images/spacer.gif" height=20 width=1 border=0></td></tr>
				</table>
			</div>
			<%
			'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			'LIFESPAN EDITING TAB
			'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			if dictScheduleDataCols("ColCount") > 0 and dictScheduleDataCols("RecordCount") > 0 then
				boolUseSchedule = false
				if not IsNull(arScheduleDataRows(dictScheduleDataCols("Start_Date"), 0)) and IsDate(arScheduleDataRows(dictScheduleDataCols("Start_Date"), 0)) then
					txtStartDate = FormatDateTime(CDate(arScheduleDataRows(dictScheduleDataCols("Start_Date"), 0)), vbShortDate)
					txtStartTime = FormatDateTime(CDate(arScheduleDataRows(dictScheduleDataCols("Start_Date"), 0)), vbShortTime)
					boolUseStartDate = true
					boolUseSchedule = true
				end if
				if not IsNull(arScheduleDataRows(dictScheduleDataCols("End_Date"), 0)) and IsDate(arScheduleDataRows(dictScheduleDataCols("End_Date"), 0)) then
					txtEndDate = FormatDateTime(CDate(arScheduleDataRows(dictScheduleDataCols("End_Date"), 0)), vbShortDate)
					txtEndTime = FormatDateTime(CDate(arScheduleDataRows(dictScheduleDataCols("End_Date"), 0)), vbShortTime)
					boolUseEndDate = true
					boolUseSchedule = true
				end if
			else
				boolUseSchedule = false
				boolUseStartDate = false
				boolUseEndDate = false
			end if
			%>
			<div id="workspace_schedule" name="workspace_schedule" style="display:none">
				<table width=100% cellpadding=0 cellspacing=0 border=0>
					<tr>
						<td><img src="../images/spacer.gif" height=1 width=20 border=0></td>
						<td align=top>
							<table width=100% cellpadding=0 cellspacing=0 border=0>
								<tr>
									<td>
										<font style="font-family:Arial, Helvetica;font-size:12px;color:#000000">
										The following settings determine when this product is available.
										</font>
									</td>
								</tr>
								<tr><td><img src="./images/spacer.gif" height=20 width=1 border=0></td></tr>
								<tr>
									<td>
										<table cellpadding=0 cellspacing=0 border=0>
											<tr>
												<td><input type=radio value="0" name="boolUseSchedule"<%if not boolUseSchedule then Response.Write " CHECKED" end if%>></td>
												<td nowrap=true>
													<font style="font-family:Arial, Verdana, Geneva, Helvetica;font-size:12px;color:#000000">
													<span style="cursor:hand" onClick="document.theForm.boolUseSchedule[0].checked=true;">This product is always available.</span>
													</font>
												</td>
											</tr>
											<tr>
												<td><input type=radio value="1" name="boolUseSchedule"<%if boolUseSchedule then Response.Write " CHECKED" end if%>></td>
												<td nowrap=true>
													<font style="font-family:Arial, Verdana, Geneva, Helvetica;font-size:12px;color:#000000">
													<span style="cursor:hand" onClick="document.theForm.boolUseSchedule[1].checked=true;">Product availability is determined by this schedule.</span>
													</font>
												</td>
											</tr>
										</table>
									</td>
								</tr>
								<tr><td><img src="./images/spacer.gif" height=10 width=1 border=0></td></tr>
								<tr>
									<td>
										<table cellpadding=0 cellspacing=0 border=0>
											<tr>
												<td><img src="../images/spacer.gif" height=1 width=40 border=0></td>
												<td nowrap=true width=100%>
													<div id="editScheduleOneTime">
														<table cellpadding=0 cellspacing=0 border=0>
															<tr>
																<td>
																	<font style="font-family:Arial, Helvetica;font-size:12px;color:#333333">
																	<b>Start Date</b>
																	</font>
																</td>
															</tr>
															<tr>
																<td>
																	<table cellpadding=0 cellspacing=0 border=0>
																		<tr>
																			<td><input type=radio value="0" name="boolUseStartDate"<%if not boolUseStartDate then Response.Write " CHECKED" end if%>></td>
																			<td nowrap=true>
																				<font style="font-family:Arial, Verdana, Geneva, Helvetica;font-size:12px;color:#000000">
																				<span style="cursor:hand" onClick="document.theForm.boolUseStartDate[0].checked=true;">This product is available immediately after it is saved.</span>
																				</font>
																			</td>
																		</tr>
																		<tr>
																			<td><input type=radio value="1" name="boolUseStartDate"<%if boolUseStartDate then Response.Write " CHECKED" end if%> onClick="document.theForm.boolUseSchedule[1].checked=true;"></td>
																			<td nowrap=true>
																				<font style="font-family:Arial, Verdana, Geneva, Helvetica;font-size:12px;color:#000000">
																				<span style="cursor:hand" onClick="document.theForm.boolUseSchedule[1].checked=true; document.theForm.boolUseStartDate[1].checked=true;">This product will be available on the following date:</span>
																				</font>
																			</td>
																		</tr>
																	</table>
																</td>
															</tr>
															<tr><td><img src="./images/spacer.gif" height=5 width=1 border=0></td></tr>
															<tr>
																<td nowrap=true>
																	<table cellpadding=0 cellspacing=0 border=0>
																		<tr>
																			<td><img src="../images/spacer.gif" height=1 width=40 border=0></td>
																			<td nowrap=true>
																				<input type=text name="txtStartDate" value="<%=txtStartDate%>" size=10 maxlength=10 onFocus="document.theForm.boolUseStartDate[1].checked=true;" AutoComplete="off">
																				<select name="txtStartTime" onFocus="document.theForm.boolUseStartDate[1].checked=true;">
																					<%for i = 0 to 23%>
																					<option value="<%=FormatDateTime(i & ":00", vbLongTime)%>"<%if FormatDateTime(txtStartTime, vbLongTime) = FormatDateTime(i & ":00", vbLongTime) then Response.Write " SELECTED"%>><%=FormatDateTime(i & ":00", vbLongTime)%>
																					<option value="<%=FormatDateTime(i & ":15", vbLongTime)%>"<%if FormatDateTime(txtStartTime, vbLongTime) = FormatDateTime(i & ":15", vbLongTime) then Response.Write " SELECTED"%>><%=FormatDateTime(i & ":15", vbLongTime)%>
																					<option value="<%=FormatDateTime(i & ":30", vbLongTime)%>"<%if FormatDateTime(txtStartTime, vbLongTime) = FormatDateTime(i & ":30", vbLongTime) then Response.Write " SELECTED"%>><%=FormatDateTime(i & ":30", vbLongTime)%>
																					<option value="<%=FormatDateTime(i & ":45", vbLongTime)%>"<%if FormatDateTime(txtStartTime, vbLongTime) = FormatDateTime(i & ":45", vbLongTime) then Response.Write " SELECTED"%>><%=FormatDateTime(i & ":45", vbLongTime)%>
																					<%next%>
																				</select>
																				<a href="javascript:document.theForm.boolUseSchedule[1].checked=true; document.theForm.boolUseStartDate[1].checked=true;dateWin('txtStartDate');"><img src="../../app_images/mini_calendar.gif" border=0 alt="Click here to select your date from a calendar"></a>
																			</td>
																		</tr>
																		<tr>
																			<td></td>
																			<td nowrap=true>
																				<font style="font-family:Arial,Helvetica;font-size:10px;color:#666666">
																				(MM/DD/YY)
																				</font>
																			</td>
																		</tr>
																	</table>
																</td>
															</tr>
															<tr><td><img src="./images/spacer.gif" height=10 width=1 border=0></td></tr>
															<tr>
																<td>
																	<font style="font-family:Arial, Helvetica;font-size:12px;color:#333333">
																	<b>End Date</b>
																	</font>
																</td>
															</tr>
															<tr>
																<td>
																	<table cellpadding=0 cellspacing=0 border=0>
																		<tr>
																			<td><input type=radio value="0" name="boolUseEndDate"<%if not boolUseEndDate then Response.Write " CHECKED" end if%>></td>
																			<td nowrap=true>
																				<font style="font-family:Arial, Verdana, Geneva, Helvetica;font-size:12px;color:#000000">
																				<span style="cursor:hand" onClick="document.theForm.boolUseEndDate[0].checked=true;">This product never expires.</span>
																				</font>
																			</td>
																		</tr>
																		<tr>
																			<td><input type=radio value="1" name="boolUseEndDate"<%if boolUseEndDate then Response.Write " CHECKED" end if%> onClick="document.theForm.boolUseSchedule[1].checked=true;"></td>
																			<td nowrap=true>
																				<font style="font-family:Arial, Verdana, Geneva, Helvetica;font-size:12px;color:#000000">
																				<span style="cursor:hand" onClick="document.theForm.boolUseSchedule[1].checked=true; document.theForm.boolUseEndDate[1].checked=true;">This product will end on the following date:</span>
																				</font>
																			</td>
																		</tr>
																	</table>
																</td>
															</tr>
															<tr><td><img src="./images/spacer.gif" height=5 width=1 border=0></td></tr>
															<tr>
																<td nowrap=true>
																	<table cellpadding=0 cellspacing=0 border=0>
																		<tr>
																			<td><img src="../images/spacer.gif" height=1 width=40 border=0></td>
																			<td nowrap=true>
																				<input type=text name="txtEndDate" value="<%=txtEndDate%>" size=10 maxlength=10 onFocus="document.theForm.boolUseEndDate[1].checked=true;" AutoComplete="off">
																				<select name="txtEndTime" onFocus="document.theForm.boolUseEndDate[1].checked=true;">
																					<%for i = 0 to 23%>
																					<option value="<%=FormatDateTime(i & ":00", vbLongTime)%>"<%if FormatDateTime(txtEndTime, vbLongTime) = FormatDateTime(i & ":00", vbLongTime) then Response.Write " SELECTED"%>><%=FormatDateTime(i & ":00", vbLongTime)%>
																					<option value="<%=FormatDateTime(i & ":15", vbLongTime)%>"<%if FormatDateTime(txtEndTime, vbLongTime) = FormatDateTime(i & ":15", vbLongTime) then Response.Write " SELECTED"%>><%=FormatDateTime(i & ":15", vbLongTime)%>
																					<option value="<%=FormatDateTime(i & ":30", vbLongTime)%>"<%if FormatDateTime(txtEndTime, vbLongTime) = FormatDateTime(i & ":30", vbLongTime) then Response.Write " SELECTED"%>><%=FormatDateTime(i & ":30", vbLongTime)%>
																					<option value="<%=FormatDateTime(i & ":45", vbLongTime)%>"<%if FormatDateTime(txtEndTime, vbLongTime) = FormatDateTime(i & ":45", vbLongTime) then Response.Write " SELECTED"%>><%=FormatDateTime(i & ":45", vbLongTime)%>
																					<%next%>
																				</select>
																				<a href="javascript:document.theForm.boolUseSchedule[1].checked=true; document.theForm.boolUseEndDate[1].checked=true;dateWin('txtEndDate');"><img src="../../app_images/mini_calendar.gif" border=0 alt="Click here to select your date from a calendar"></a>
																			</td>
																		</tr>
																		<tr>
																			<td></td>
																			<td nowrap=true>
																				<font style="font-family:Arial,Helvetica;font-size:10px;color:#666666">
																				(MM/DD/YY)
																				</font>
																			</td>
																		</tr>
																	</table>
																</td>
															</tr>
														</table>
													</div>
												</td>
											</tr>
										</table>
									</td>
								</tr>
							</table>
						</td>
						<td><img src="../images/spacer.gif" height=1 width=20 border=0></td>
					</tr>
				</table>
			</div>
		</td>
	</tr>
	<input type=hidden name="pid" value="<%=productID%>">
	<input type=hidden name="pcid" value="<%=parentCategoryID%>">
	<input type=hidden name="boolIsNew" value="<%=boolIsNew%>">

	</form>
</table>
<script language="javascript">
	<!--
		parent.frames["header"].document.location = "product_details_header.asp?pid=<%=productID%>";
		parent.frames["controls"].document.location = "product_details_footer.asp?pid=<%=productID%>";
	//-->
</script>

</body>
</html>

<%
Call DB_CleanUp
Sub DB_CleanUp
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

Set arDetailsDataRows = Nothing
Set dictDetailsDataCols = Nothing

Set arScheduleDataRows = Nothing
Set dictScheduleDataCols = Nothing
%>