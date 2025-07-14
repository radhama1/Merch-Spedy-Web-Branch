<%@ page language="VB" autoeventwireup="false" aspcompat="true" %>
<%@ Register Src="~/CORALControls/pageheader.ascx" TagName="pageheader" TagPrefix="uclayout" %>
<!--#INCLUDE FILE="include/adovbs.inc"-->
<html xmlns="http://www.w3.org/1999/xhtml" >
<head id="Head1" runat="server">
	<meta http-equiv="X-UA-Compatible" content="IE=EmulateIE10" />
	<title>Item Data Management</title>
	<link rel="stylesheet" href="css/styles.css" type="text/css" />
	<script type="text/javascript" language="javascript" src="include/global.js?v=<%=ConfigurationManager.AppSettings("AppVersion")%>"></script>
</head>
<body>
<%
dim batch_id, action, batch_type
dim objConn, objRS, objRS1, objRS2, connStr, items_per_page, sort_order, asc_desc, cur_page, usprice
dim strSQL, row_count, item_type_attribute, stage_id, notes, skugroup, canadaprice, ongrid, item_header_id
dim isPriceMatch="yes", base2price,testprice,high2price,high3price,smalmrktprice, high1price, base3price
dim low1price,low2price, manhattanprice
dim User_ID,initial_stage_id, current_stage_id
dim itemid, fineline_dept_id, workflow_exception
dim xmlhttp , DataToSend, vendor_number, vendor_name, batch_type_id, current_owner, current_owner_email, inner_html
dim e_mailbody, e_mailsubject, vcSender, vcFrom, vcTo, vcCC, vcBcc, vcSubject, vcHTMLBody, vcSMTPServer
dim cDSNOptions="'2'", bAuthenticate = 0, vcSMTPAuth_UserName, vcSMTPAuth_UserPassword, vcAttachments
dim bAutoGenerateTextBody=1

batch_type=cint(request.form("batch_type"))
batch_id=request.form("batch_id")
action=request.form("action")
notes=request.form("notes")
stage_id=request.form("stage")

if action="" then
	response.redirect("default.aspx")
end if

connStr = "Provider=sqloledb;" & ConfigurationManager.ConnectionStrings("AppConnection").ConnectionString & ";"
objConn = Server.CreateObject("ADODB.Connection")
objRS = Server.CreateObject("ADODB.RecordSet")
objRS1 = Server.CreateObject("ADODB.RecordSet")
objRS2 = Server.CreateObject("ADODB.RecordSet")
objConn.Open(connStr)

if batch_type=1 then
	strSQL = "select * from SPD_Item_Headers where batch_id=" & batch_id
	objRS.Open(strSQL, objConn, adOpenDynamic, adLockOptimistic, adCmdText)
	if not objRS.eof then
		item_type_attribute=objRS("item_type_attribute").value
		item_header_id=objRS("id").value
		itemid = objRS("ID").value
    else
        item_header_id=0
        itemid = 0
	end if
	if isdbnull(item_type_attribute) then
		item_type_attribute=""
	end if
	objRS.close

else
	strSQL = "select * from SPD_Import_Items where batch_id=" & batch_id
	objRS.Open(strSQL, objConn, adOpenDynamic, adLockOptimistic, adCmdText)
	if not objRS.eof then
		item_type_attribute=objRS("itemtypeattribute").value
		itemid = objRS("ID").value
		if isdbnull(item_type_attribute) then
			item_type_attribute=""
		end if
	else
	    itemid = 0
	end if
	objRS.close
end if

strSQL = "select * from spd_batch where id=" & batch_id
objRS.Open(strSQL, objConn, adOpenDynamic, adLockOptimistic, adCmdText)
if not objRS.eof then
	stage_id=cint(objRS("workflow_stage_id").value)
	initial_stage_id=cint(objRS("workflow_stage_id").value)
end if
objRS.close

if action="disapprove" and notes="" then
'get the disapproval notes%>
	<div id="sitediv">
		<div id="bodydiv">
			<div id="header">
				<uclayout:pageheader ID="headerControl" RefreshOnUpload="false" runat="server" />
			</div>
			<div id="content">
				<div id="shadowtop"></div>
				<div id="main">
					<div class="spacer"></div>
					<FORM METHOD=POST name="disapprove_form" ACTION="item_action.aspx">
					<INPUT TYPE="hidden" name="batch_type" value="<%=request.form("batch_type")%>">
					<INPUT TYPE="hidden" name="batch_id" value="<%=request.form("batch_id")%>">
					<INPUT TYPE="hidden" name="action" value="<%=request.form("action")%>">
					<BR>&nbsp;<B>Reason for Disapproval:</B><BR>
					&nbsp;<TEXTAREA NAME="notes" ROWS="4" COLS="80"></TEXTAREA><BR>
					<BR>&nbsp;<B>Send disapproval to: </B>
					<select name="stage">
					<option value="">Previous User</option>
					<%
					connStr = "Provider=sqloledb;;" & ConfigurationManager.ConnectionStrings("AppConnection").ConnectionString & ";"
					objConn = Server.CreateObject("ADODB.Connection")
					objConn.Open(connStr)
					objRS = Server.CreateObject("ADODB.RecordSet")
					objRS1 = Server.CreateObject("ADODB.RecordSet")

					strSQL = "select * from SPD_Workflow_Stage where id<10 and id<" & stage_id & " and ltrim(rtrim(stage_name)) != 'CM/CD' order by sequence"
					objRS.Open(strSQL, objConn)
					while not objRS.eof
						if 1=0 then
							response.write("<option value='" & objRS("id").value & "' selected>" & objRS("stage_name").value & "</option>")
						else
							response.write("<option value='" & objRS("id").value & "'>" & objRS("stage_name").value & "</option>")
						end if
						objRS.MoveNext
					end while
					objRS.close
					%>
					</select><br/>
					<br/>&nbsp;<input type="submit" value="disapprove"/>
					</FORM><br/><br/>
					</div>
				</div>
			</div>
		</div>
	
<%
else
'process the action
	strSQL = "select * from SPD_Batch where id=" & batch_id
	objRS.Open(strSQL, objConn, adOpenDynamic, adLockOptimistic, adCmdText)
	if not objRS.eof then
	'get the current stage
		stage_id=cint(objRS("workflow_stage_id").value)
		'dont allow approval of stages beyond dbc or standard processing of buyer stage or pricing mgr. stage
		if action="approve" and stage_id<11 and stage_id<>4 and stage_id<>5 and stage_id<>6 then
			'if its a domestic add/change batch and maa/ab stage, skip over the import mgr. stage
			'if batch_type=1 and stage_id=2 then
			'	objRS("workflow_stage_id").value=stage_id+2
			'else
			'LP change- promote Import, domestic to the  to next stage, handle domestic stage 2 and import stage 3 below
			if (batch_type=2) and (stage_id=1 or stage_id=2 or stage_id=7 or stage_id=8 or stage_id=9 or stage_id=10) then
				objRS("workflow_stage_id").value=stage_id+1
			elseif 	(batch_type=1) and (stage_id=1 or stage_id=7 or stage_id=8 or stage_id=9 or stage_id=10) then
			    objRS("workflow_stage_id").value=stage_id+1
			end if
			objRS("modified_user").value=session("UserID")
			objRS("date_modified").value=now()
			if stage_id<>10 then objRS("is_valid").value=-1
			objRS.update
			if stage_id<>10 then
			    if objRS("batch_type_id").value <> 2 AndAlso Not itemid Is Nothing then
			        strSQL = "update spd_item_headers set is_valid = -1 where [ID] = " & itemid
			        objRS2.Open(strSQL, objConn, adOpenDynamic, adLockOptimistic, adCmdText)
			        strSQL = "update spd_items set is_valid = -1 where item_header_id=" & itemid
			        objRS2.Open(strSQL, objConn, adOpenDynamic, adLockOptimistic, adCmdText)
			    elseif objRS("batch_type_id").value = 2 AndAlso Not itemid Is Nothing then
			        strSQL = "update spd_import_items set is_valid = -1 where [ID] = " & itemid & " or [Parent_ID] = " & itemid
			        objRS2.Open(strSQL, objConn, adOpenDynamic, adLockOptimistic, adCmdText)
			    end if
			end if
		end if

		'handle special cases for pricing mgr.
		if action="approve" and stage_id=5 then
		'if item is seasonal, go straight to the tax manger stage
			objRS("modified_user").value=session("UserID")
			
			objRS("date_modified").value=now()
			objRS("is_valid").value=-1
			if item_type_attribute = "S" then
				objRS("workflow_stage_id").value=9
			'otherwise go to next stage
			else
				objRS("workflow_stage_id").value=7
			end if
			objRS.update
			if objRS("batch_type_id").value <> 2 AndAlso Not itemid Is Nothing then
			    strSQL = "update spd_item_headers set is_valid = -1 where [ID] = " & itemid
			    objRS2.Open(strSQL, objConn, adOpenDynamic, adLockOptimistic, adCmdText)
			    strSQL = "update spd_items set is_valid = -1 where item_header_id = " & itemid
			    objRS2.Open(strSQL, objConn, adOpenDynamic, adLockOptimistic, adCmdText)
			elseif objRS("batch_type_id").value = 2 AndAlso Not itemid Is Nothing then
			    strSQL = "update spd_import_items set is_valid = -1 where [ID] = " & itemid & " or [Parent_ID] = " & itemid
			    objRS2.Open(strSQL, objConn, adOpenDynamic, adLockOptimistic, adCmdText)
			end if
		end if

		'handle special cases for gm/dm
		if action="approve" and stage_id=6 then
		'if item is seasonal, go straight to the tax manger stage
			objRS("modified_user").value=session("UserID")
			objRS("date_modified").value=now()
			objRS("is_valid").value=-1
			objRS("workflow_stage_id").value=5
			objRS.update
			if objRS("batch_type_id").value <> 2 AndAlso Not itemid Is Nothing then
			    strSQL = "update spd_item_headers set is_valid = -1 where [ID] = " & itemid
			    objRS2.Open(strSQL, objConn, adOpenDynamic, adLockOptimistic, adCmdText)
			    strSQL = "update spd_items set is_valid = -1 where item_header_id = " & itemid
			    objRS2.Open(strSQL, objConn, adOpenDynamic, adLockOptimistic, adCmdText)
			elseif objRS("batch_type_id").value = 2 AndAlso Not itemid Is Nothing then
			    strSQL = "update spd_import_items set is_valid = -1 where [ID] = " & itemid & " or [Parent_ID] = " & itemid
			    objRS2.Open(strSQL, objConn, adOpenDynamic, adLockOptimistic, adCmdText)
			end if
		end if

		'handle special cases for buyer stage
		'if action="approve" and stage_id=4 then
		'handle domestic stage 2 and import stage 3 LP Sept 2009, stage 4 is retired
		if action="approve" and ((stage_id=3 and batch_type=2) or (stage_id=2 and batch_type=1)) then
			'if item has canada price not on grid, go to vp/dmm(5)
			'is it import
			if objRS("batch_type_id").value=2 'import item
			' yes, get skugroup and SellingCostCanada from SPD_Import_Items
				strSQL = "select * from SPD_Import_Items where batch_id=" & objRS("id").value
				objRS1.Open(strSQL, objConn, adOpenDynamic, adLockOptimistic, adCmdText)
				'LP new code - change Order 14, Sept-Oct 2009
				ongrid="yes"
				while not objRS1.eof and ongrid="yes" and isPriceMatch="yes"
					skugroup=objRS1("skugroup").value
					canadaprice=objRS1("RDCanada").value
					usprice=objRS1("RDBase").value
					base2price=objRS1("RDCentral").value
					testprice=objRS1("RDTest").value
					high2price=objRS1("RD0Thru9").value
					high3price=objRS1("RDCalifornia").value
					smalmrktprice=objRS1("RDVillageCraft").value
					high1price=objRS1("Retail9").value
					base3price=objRS1("Retail10").value
					low1price=objRS1("Retail11").value
					low2price=objRS1("Retail12").value
					manhattanprice=objRS1("Retail13").value
				
				'objRS1.close
				    if not isdbnull(usprice) then
				        if isdbnull(base2price) or isdbnull(testprice) or isdbnull(high2price) or isdbnull(high3price) or isdbnull(smalmrktprice) or isdbnull(high1price) or isdbnull(base3price) or isdbnull(low1price) or isdbnull(low2price) or isdbnull(manhattanprice) then 
				            isPriceMatch="no"
				        end if
				        if isPriceMatch <>"no" then
				            if base2price <> usprice then
				                isPriceMatch="no"
				             elseif  testprice <> usprice then
				                isPriceMatch="no" 
				             elseif high2price <> usprice then
				                isPriceMatch="no"
				             elseif high3price <> usprice then
				                isPriceMatch="no"
				             elseif smalmrktprice <> usprice then
				                isPriceMatch="no"
				             elseif high1price <> usprice then
				                isPriceMatch="no"
				            elseif base3price <> usprice then
				                isPriceMatch="no"
				            elseif low1price <> usprice then
				                isPriceMatch="no"    
				            elseif low2price <> usprice then
				                isPriceMatch="no"
				            elseif manhattanprice <> usprice then
				                isPriceMatch="no"        
				            end if             
				        end if      
				    end if    
				    if isdbnull(skugroup) then
					    skugroup=""
				    end if
			        ' is skugroup="US AND CANADA"
				    if instr(skugroup,"CANADA")=0 then
			        '  no, ongrid=yes
					    ongrid="yes"
				    else
			        '  yes, is SellingCostCanada in canretail in SPD_Price_Grid
				        if not isnumeric(canadaprice) then
					        canadaprice=0
				        end if
				        if not isnumeric(usprice) then
					        usprice=0
				        end if
				        strSQL = "select * from SPD_Price_Point where diff_zone_id=5 and diff_retail=" & canadaprice & " and base_retail=" & usprice
				        objRS2.Open(strSQL, objConn, adOpenDynamic, adLockOptimistic, adCmdText)
				        if not objRS2.eof then
			                '   yes, ongrid=yes
					        ongrid="yes"
				        else
			        '   no, ongrid=no
					        ongrid="no"
				        end if
				        objRS2.close
				    end if     
				    
				    objRS1.movenext
				end while
				
				objRS1.close
				
			else
				ongrid="yes"
			'is it domestic
			' yes, get sku_group from SPD_Item_Headers
				strSQL = "select * from SPD_Item_Headers where batch_id=" & objRS("id").value
				objRS1.Open(strSQL, objConn, adOpenDynamic, adLockOptimistic, adCmdText)
				if not objRS1.eof then
					skugroup=objRS1("sku_group").value
					item_header_id=objRS1("id").value
				end if
				objRS1.close
				if isdbnull(skugroup) then
					skugroup=""
				end if
			' is skugroup="US AND CANADA"
				'if instr(skugroup,"CANADA")=0 then
			'  no, ongrid=yes
				'	ongrid="yes"
				'end if
				'  yes, are all Canada_Cost in SPD_Items in canretail in SPD_Price_Grid
				'   yes, ongrid=yes
				'   no, ongrid=no
				'LP Change Order 14, logic is changed a bit, cause need to evaluate all Prices
				'strSQL = "select * from SPD_Items where not Canada_Retail is null and item_header_id=" & cstr(item_header_id)
				strSQL = "select * from SPD_Items where item_header_id=" & cstr(item_header_id)
				objRS1.Open(strSQL, objConn, adOpenDynamic, adLockOptimistic, adCmdText)
				while not objRS1.eof and ongrid="yes" and isPriceMatch="yes"
				    canadaprice=objRS1("Canada_Retail").value
				    usprice=objRS1("Base_Retail").value
				    if isdbnull(canadaprice) then canadaprice=0
				    ' FJL Feb 02, 2010 - Check USPrice for null as well
				    if isdbnull(usprice) then usprice=0
					'LP SQl changed, but same point
					if ongrid = "yes" and instr(skugroup,"CANADA")<> 0 then
					    strSQL = "select * from SPD_Price_Point where diff_zone_id=5 and diff_retail=" & canadaprice & " and base_retail=" & usprice
					    objRS2.Open(strSQL, objConn, adOpenDynamic, adLockOptimistic, adCmdText)
					    if objRS2.eof then
						    ongrid="no"
					    end if
					    objRS2.close
					end if    
					
					base2price=objRS1("Central_Retail").value
				    testprice=objRS1("Test_Retail").value
				    high2price=objRS1("Zero_Nine_Retail").value
				    high3price=objRS1("California_Retail").value
				    smalmrktprice=objRS1("Village_Craft_Retail").value
				    high1price=objRS1("Retail9").value
				    base3price=objRS1("Retail10").value
				    low1price=objRS1("Retail11").value
				    low2price=objRS1("Retail12").value
				    manhattanprice=objRS1("Retail13").value
				    if not isdbnull(usprice) then
			            if isdbnull(base2price) or isdbnull(testprice) or isdbnull(high2price) or isdbnull(high3price) or isdbnull(smalmrktprice) or isdbnull(high1price) or isdbnull(base3price) or isdbnull(low1price) or isdbnull(low2price) or isdbnull(manhattanprice) then 
			                isPriceMatch="no"
			             end if
			             if isPriceMatch <>"no" then
			                 if base2price <> usprice then
			                    isPriceMatch="no"
			                 elseif  testprice <> usprice then
			                    isPriceMatch="no" 
			                 elseif high2price <> usprice then
			                    isPriceMatch="no"
			                 elseif high3price <> usprice then
			                    isPriceMatch="no"
			                 elseif smalmrktprice <> usprice then
			                    isPriceMatch="no"
			                 elseif high1price <> usprice then
			                    isPriceMatch="no"
			                 elseif base3price <> usprice then
			                    isPriceMatch="no"
			                 elseif low1price <> usprice then
			                    isPriceMatch="no"    
			                 elseif low2price <> usprice then
			                    isPriceMatch="no"
			                 elseif manhattanprice <> usprice then
			                    isPriceMatch="no"        
			                 end if             
			            end if   
			        end if    
					objRS1.movenext
				end while
				objRS1.close
				
			end if
			'LP Sept 2009 added isPriceMatch="no" if any of retails do not match bas-go to Price manager
			if ongrid="no" or isPriceMatch="no" then
					objRS("workflow_stage_id").value=5
			else
			'if item is seasonal, go straight to the tax manger stage
				if item_type_attribute = "S" then
					objRS("workflow_stage_id").value=9
				'otherwise go to next stage
				else
					objRS("workflow_stage_id").value=7
				end if
			end if
			objRS("modified_user").value=session("UserID")
			objRS("date_modified").value=now()
			objRS("is_valid").value=-1
			objRS.update
			if objRS("batch_type_id").value <> 2 then
			    strSQL = "update spd_item_headers set is_valid = -1 where [ID] = " & itemid
			    objRS2.Open(strSQL, objConn, adOpenDynamic, adLockOptimistic, adCmdText)
			    strSQL = "update spd_items set is_valid = -1 where item_header_id = " & itemid
			    objRS2.Open(strSQL, objConn, adOpenDynamic, adLockOptimistic, adCmdText)
			elseif objRS("batch_type_id").value = 2 then
			    strSQL = "update spd_import_items set is_valid = -1 where [ID] = " & itemid & " or [Parent_ID] = " & itemid
			    objRS2.Open(strSQL, objConn, adOpenDynamic, adLockOptimistic, adCmdText)
			end if
		end if
		'user has overridden default disapproval stage
		if action="disapprove" and request.form("stage")<>"" then
			objRS("workflow_stage_id").value=cint(request.form("stage"))
			objRS("modified_user").value=session("UserID")
			objRS("date_modified").value=now()
			objRS("is_valid").value=-1
			objRS.update
			if objRS("batch_type_id").value <> 2 AndAlso Not itemid Is Nothing then
			    strSQL = "update spd_item_headers set is_valid = -1 where [ID] = " & itemid
			    objRS2.Open(strSQL, objConn, adOpenDynamic, adLockOptimistic, adCmdText)
			    strSQL = "update spd_items set is_valid = -1 where item_header_id = " & itemid
			    objRS2.Open(strSQL, objConn, adOpenDynamic, adLockOptimistic, adCmdText)
			elseif objRS("batch_type_id").value = 2 AndAlso Not itemid Is Nothing then
			    strSQL = "update spd_import_items set is_valid = -1 where [ID] = " & itemid & " or [Parent_ID] = " & itemid
			    objRS2.Open(strSQL, objConn, adOpenDynamic, adLockOptimistic, adCmdText)
			end if
		end if

		'dont allow dissapproval at first or last stages and handle stage 9 specially
		if action="disapprove" and request.form("stage")="" and stage_id<>1 and stage_id<11 and stage_id<>9 and stage_id<>7  and stage_id<>5 then
			'if its an import batch and we're at the buyer stage, skip over the import manager
			'if batch_type=1 and stage_id=4 then
				objRS("workflow_stage_id").value=stage_id-1
			'else
			'	objRS("workflow_stage_id").value=stage_id-1
			'end if
			objRS("modified_user").value=session("UserID")
			objRS("date_modified").value=now()
			objRS("is_valid").value=-1
			objRS.update
			if objRS("batch_type_id").value <> 2 AndAlso Not itemid Is Nothing then
			    strSQL = "update spd_item_headers set is_valid = -1 where [ID] = " & itemid
			    objRS2.Open(strSQL, objConn, adOpenDynamic, adLockOptimistic, adCmdText)
			    strSQL = "update spd_items set is_valid = -1 where item_header_id = " & itemid
			    objRS2.Open(strSQL, objConn, adOpenDynamic, adLockOptimistic, adCmdText)
			elseif objRS("batch_type_id").value = 2 AndAlso Not itemid Is Nothing then
			    strSQL = "update spd_import_items set is_valid = -1 where [ID] = " & itemid & " or [Parent_ID] = " & itemid
			    objRS2.Open(strSQL, objConn, adOpenDynamic, adLockOptimistic, adCmdText)
			end if
		end if
		if action="disapprove" and request.form("stage")="" and stage_id=9 then
			'if we're at the tax manager stage and its a seasonal batch, go all the way back to buyer stage LP bayer stage is no longer present
			if item_type_attribute = "S" and batch_type=1 then
				objRS("workflow_stage_id").value=stage_id-7 'domestic goes to Caa/CMA? LP
			elseif item_type_attribute = "S" and batch_type=2 'import goes to Import Manager	
			    objRS("workflow_stage_id").value=stage_id-6
			else
				objRS("workflow_stage_id").value=stage_id-1
			end if
			objRS("modified_user").value=session("UserID")
			objRS("date_modified").value=now()
			objRS("is_valid").value=-1
			objRS.update
			if objRS("batch_type_id").value <> 2 AndAlso Not itemid Is Nothing then
			    strSQL = "update spd_item_headers set is_valid = -1 where [ID] = " & itemid
			    objRS2.Open(strSQL, objConn, adOpenDynamic, adLockOptimistic, adCmdText)
			    strSQL = "update spd_items set is_valid = -1 where item_header_id = " & itemid
			    objRS2.Open(strSQL, objConn, adOpenDynamic, adLockOptimistic, adCmdText)
			elseif objRS("batch_type_id").value = 2 AndAlso Not itemid Is Nothing then
			    strSQL = "update spd_import_items set is_valid = -1 where [ID] = " & itemid & " or [Parent_ID] = " & itemid
			    objRS2.Open(strSQL, objConn, adOpenDynamic, adLockOptimistic, adCmdText)
			end if
		end if
		if action="disapprove" and request.form("stage")="" and stage_id=7 then
			'if we're at the tax manager stage and its a seasonal batch, go all the way back to buyer stage LP bayers stage is no longer there!
			if batch_type=1 then 
			    objRS("workflow_stage_id").value=2
			else
			    'import
			    objRS("workflow_stage_id").value=3
			end if    
			objRS("modified_user").value=session("UserID")
			objRS("date_modified").value=now()
			objRS("is_valid").value=-1
			objRS.update
			if objRS("batch_type_id").value <> 2 AndAlso Not itemid Is Nothing then
			    strSQL = "update spd_item_headers set is_valid = -1 where [ID] = " & itemid
			    objRS2.Open(strSQL, objConn, adOpenDynamic, adLockOptimistic, adCmdText)
			    strSQL = "update spd_items set is_valid = -1 where item_header_id = " & itemid
			    objRS2.Open(strSQL, objConn, adOpenDynamic, adLockOptimistic, adCmdText)
			elseif objRS("batch_type_id").value = 2 AndAlso Not itemid Is Nothing then
			    strSQL = "update spd_import_items set is_valid = -1 where [ID] = " & itemid & " or [Parent_ID] = " & itemid
			    objRS2.Open(strSQL, objConn, adOpenDynamic, adLockOptimistic, adCmdText)
			end if
		end if
		if action="disapprove" and request.form("stage")="" and stage_id=5 then
			'if we're at the price manager stage go to the GM/DM stage
			objRS("workflow_stage_id").value=6
			objRS("modified_user").value=session("UserID")
			objRS("date_modified").value=now()
			objRS("is_valid").value=-1
			objRS.update
			if objRS("batch_type_id").value <> 2 AndAlso Not itemid Is Nothing then
			    strSQL = "update spd_item_headers set is_valid = -1 where [ID] = " & itemid
			    objRS2.Open(strSQL, objConn, adOpenDynamic, adLockOptimistic, adCmdText)
			    strSQL = "update spd_items set is_valid = -1 where item_header_id = " & itemid
			    objRS2.Open(strSQL, objConn, adOpenDynamic, adLockOptimistic, adCmdText)
			elseif objRS("batch_type_id").value = 2 AndAlso Not itemid Is Nothing then
			    strSQL = "update spd_import_items set is_valid = -1 where [ID] = " & itemid & " or [Parent_ID] = " & itemid
			    objRS2.Open(strSQL, objConn, adOpenDynamic, adLockOptimistic, adCmdText)
			end if
		end if
		if action="disapprove" and request.form("stage")="" and stage_id=6 then
			'if we're at the GM/DM stage go to the CA/CAA stage
			objRS("workflow_stage_id").value=2
			objRS("modified_user").value=session("UserID")
			objRS("date_modified").value=now()
			objRS("is_valid").value=-1
			objRS.update
			if objRS("batch_type_id").value <> 2 AndAlso Not itemid Is Nothing then
			    strSQL = "update spd_item_headers set is_valid = -1 where [ID] = " & itemid
			    objRS2.Open(strSQL, objConn, adOpenDynamic, adLockOptimistic, adCmdText)
			    strSQL = "update spd_items set is_valid = -1 where item_header_id = " & itemid
			    objRS2.Open(strSQL, objConn, adOpenDynamic, adLockOptimistic, adCmdText)
			elseif objRS("batch_type_id").value = 2 AndAlso Not itemid Is Nothing then
			    strSQL = "update spd_import_items set is_valid = -1 where [ID] = " & itemid & " or [Parent_ID] = " & itemid
			    objRS2.Open(strSQL, objConn, adOpenDynamic, adLockOptimistic, adCmdText)
			end if
		end if
'are we removing a batch
		if action="remove" then
			objRS("enabled").value=0
			objRS("modified_user").value=session("UserID")
			objRS("date_modified").value=now()
			objRS("is_valid").value=-1
			objRS.update
			if objRS("batch_type_id").value <> 2 AndAlso not itemid is Nothing then
			    strSQL = "update spd_item_headers set is_valid = -1 where [ID] = " & itemid
			    objRS2.Open(strSQL, objConn, adOpenDynamic, adLockOptimistic, adCmdText)
			    strSQL = "update spd_items set is_valid = -1 where item_header_id = " & itemid
			    objRS2.Open(strSQL, objConn, adOpenDynamic, adLockOptimistic, adCmdText)
			elseif objRS("batch_type_id").value = 2 AndAlso not itemid is Nothing then
			    strSQL = "update spd_import_items set is_valid = -1 where [ID] = " & itemid & " or [Parent_ID] = " & itemid
			    objRS2.Open(strSQL, objConn, adOpenDynamic, adLockOptimistic, adCmdText)
			end if
		end if
	end if
	objRS.close
	if action<>"" then
		'store the action history
		strSQL = "select top 1 * from SPD_Batch_History where id=" & batch_id
		objRS.Open(strSQL, objConn, adOpenDynamic, adLockOptimistic, adCmdText)
			objRS.addnew
			objRS("spd_batch_id").value=batch_id
			objRS("workflow_stage_id").value=stage_id
			objRS("action").value=action
			objRS("modified_user").value=session("UserID")
			objRS("notes").value=notes
			objRS.update
		objRS.close

		'don't send email for cm/cd (buyer stage id 4)
		strSQL = "select * from spd_batch where id=" & batch_id
		objRS.Open(strSQL, objConn, adOpenDynamic, adLockOptimistic, adCmdText)
		if not objRS.eof then
			current_stage_id=cint(objRS("workflow_stage_id").value)
			if isdbnull(objRS("fineline_dept_id").value) then
			    fineline_dept_id=0
			else
			    fineline_dept_id=cint(objRS("fineline_dept_id").value)
			end if
		end if
		objRS.close
		'check to see if there is a workflow exception
		strSQL = "select * from spd_workflow_exception where dept=" & fineline_dept_id & " and from_stage_id=" & initial_stage_id & " and to_stage_id=" & current_stage_id & " and enabled=1"
		objRS.Open(strSQL, objConn, adOpenDynamic, adLockOptimistic, adCmdText)
		if not objRS.eof then
			workflow_exception=true
		else
			workflow_exception=false
		end if
		objRS.close

		'send the email
		if action<>"remove" and current_stage_id<>4 and not workflow_exception then
			'get the next person responsible for this batch

			strSQL = "SELECT batch_dom.is_valid, batch_dom.id, batch_dom.vendor_name, coalesce(batch_dom.vendor_number, '') as vendor_number, batch_dom.id as batch_id, coalesce(spd_item_headers.id, '') as header_id, batch_dom.batch_type_id, batch_dom.workflow_stage_id, "
			strSQL = strSQL & "coalesce(department_num, '') as dept_id, batch_dom.date_created, batch_dom.created_user, batch_dom.date_modified, batch_dom.modified_user, batch_type_desc, stage_name, "
			strSQL = strSQL & "coalesce((select first_name+' '+last_name from security_user where id=batch_dom.created_user), 'Test User') as created_user_name, "
			strSQL = strSQL & "coalesce((select first_name+' '+last_name from security_user where id=batch_dom.modified_user), 'Test User') as modified_user_name, "
			strSQL = strSQL & "coalesce((select top 1 coalesce(first_name, '')+' '+coalesce(last_name, '')+coalesce(' (x'+office_location+')', '') from security_user, security_user_privilege, security_privilege where security_user.id=security_user_privilege.[user_id] and security_user_privilege.privilege_id=security_privilege.id and constant='SPD.DEPT.'+cast(department_num as varchar) and batch_dom.workflow_stage_id in (select cast(sortorder as int) from security_group, security_user_group where security_user.id=[user_id] and group_id=security_group.id)), '') as current_owner, "
			strSQL = strSQL & "coalesce((select top 1 email_address from security_user, security_user_privilege, security_privilege where security_user.id=security_user_privilege.[user_id] and security_user_privilege.privilege_id=security_privilege.id and constant='SPD.DEPT.'+cast(department_num as varchar) and batch_dom.workflow_stage_id in (select cast(sortorder as int) from security_group, security_user_group where security_user.id=[user_id] and group_id=security_group.id)), '') as current_owner_email, "
			strSQL = strSQL & "coalesce((select dept_name from SPD_Fineline_Dept where dept=department_num), 'Invalid Dept.') as dept_name "
			strSQL = strSQL & "from SPD_Workflow_Stage, SPD_batch_types, "
			strSQL = strSQL & "SPD_Batch batch_dom left join spd_item_headers on batch_dom.id=spd_item_headers.batch_id and batch_dom.enabled=1 "
			strSQL = strSQL & "where ((batch_dom.workflow_stage_id=SPD_Workflow_Stage.id and batch_dom.batch_type_id=batch_type)) "
			strSQL = strSQL & "and batch_dom.id=" & batch_id
			objRS.Open(strSQL, objConn, adOpenDynamic, adLockOptimistic, adCmdText)
			if not objRs.eof then
				vendor_number=objRS("vendor_number").value
				vendor_name=objRS("vendor_name").value
				'lp****************** prod issue fix, handling single quote in vendor name Nov 2009
				if instr(vendor_name,"'") > 0 then 
				      vendor_Name = Left(vendor_Name, InStr(vendor_Name, "'")) & "'" & Mid(vendor_Name, InStr(vendor_Name, "'") + 1, Len(vendor_Name) - InStr(vendor_Name, "'"))
				'*******************LP************************ 
				end if
				batch_type_id=objRS("batch_type_id").value
				current_owner=objRS("current_owner").value
				current_owner_email=objRS("current_owner_email").value
			else
				current_owner_email="tom@novalibra.com"
			end if
			objRS.close

			'get a full list of people responsible for this batch
			strSQL = "select * "
			strSQL = strSQL & "from security_user, security_user_privilege, security_privilege "
			strSQL = strSQL & "where security_user.id=security_user_privilege.[user_id] "
			strSQL = strSQL & "and security_user_privilege.privilege_id=security_privilege.id "
			strSQL = strSQL & "and constant='SPD.DEPT.'+cast(" & fineline_dept_id & " as varchar) "
			strSQL = strSQL & "and " & current_stage_id
			strSQL = strSQL & " in (select cast(sortorder as int) from security_group, security_user_group where security_user.id=[user_id] and group_id=security_group.id)"
			objRS.Open(strSQL, objConn, adOpenDynamic, adLockOptimistic, adCmdText)
				'response.write(strSQL & "<BR>")
			while not objRs.eof
				current_owner_email=objRS("email_address").value
				current_owner=objRS("first_name").value & " " & objRS("last_name").value
				'response.write(current_owner_email & " " & current_owner & "<BR>")
'if 1=0 then
				
				'****************lp alternative way of sending e-mail- Oct 2009 calling SQLSMTPMAIl stored procedure per Ken Wallace
				if len(vcTo) = 0 then
                    vcTo = "'" & current_owner & " <" & current_owner_email & ">;"  
                else
                    vcTo = vcTo & " " & current_owner & " <" & current_owner_email & ">;"
                end if 
                'if len(vcTo) = 0 then
                 '   vcTo = "'" & current_owner_email & ";"
                'else
                 '   vcTo = vcTo & " " & current_owner_email & ";"
                'end if   
				objRs.movenext
			end while
			objRS.close
			if len(vcTo) > 0 then
			     vcTo = vcTo & "'"
			else
			    vcTo = "'DATAFLOW@michaels.com'"
			end if 
			if instr(notes,"'") > 0 then 
			    notes = Replace(notes, "'", "''")  
				     '*******************LP fix Nov 2009************************ 
			end if       
		    if action="disapprove" then
		        e_mailsubject = "'SPEDY user " & session("First_Name") & " " & session("Last_Name") & " has disapproved items for " & vendor_name & " Log ID# " & batch_id & "'"
		        e_mailbody = "'SPEDY user " & session("First_Name") & " " & session("Last_Name") & " has disapproved items for " & vendor_name & " Log ID# " & batch_id & " for the following reason:<BR><BR> " & notes & "<BR><BR>" & session("First_Name") & " " & session("Last_Name") & " can be contacted at " & session("Email_Address") & "<BR><BR>Please <a href=''http://10.4.10.146''>log on to SPEDY</a> and review ASAP.'" 
	        else
		        e_mailsubject = "'SPEDY user " & session("First_Name") & " " & session("Last_Name") & " has approved items for " & vendor_name & " Log ID# " & batch_id & "'"
		        e_mailbody = "'SPEDY user " & session("First_Name") & " " & session("Last_Name") & " has approved items for " & vendor_name & " Log ID# " & batch_id  & ".<BR><BR> " & session("First_Name") & " " & session("Last_Name") & " can be contacted at " & session("Email_Address") & "<BR><BR>Please <a href=''http://10.4.10.146''>log on to SPEDY</a> and review ASAP.'"
	        end if
	        vcSender = "'DATAFLOW@michaels.com'" '" & session("Email_Address") & "'"
			vcFrom = "'Michaels DataFlow' " '"'" & session("Email_Address") & "'"
			
			vcCC = "'tom@novalibra.com; DATAFLOW@michaels.com'"
			vcBCC = "'leon.popilov@novalibra.com'"
			vcHTMLBody = e_mailbody
			if request.servervariables("HTTP_HOST") = "michaels.novalibra.com" or instr(request.servervariables("HTTP_HOST"),"localhost:")<> 0 then
			    e_mailsubject = "'SPEDY System Test Message, Please Disregard! '" & e_mailsubject
			    vcSMTPServer = "'192.168.1.9'"
			else
			    vcSMTPServer = "'mail.michaels.com'"
			end if   
			vcSubject = e_mailsubject 
			strSQL = "EXEC sp_SQLSMTPMail " & vcSender & ", " & vcFrom & ",'', " & vcTo & ", " & vcCC & ", " & vcBCC
			strSQL = strSQL & ", " & vcSubject & ",'', " & vcHTMLBody & ", " & bAutoGenerateTextBody & ",''," & "null" & ",'2',0,'2'," & vcSMTPServer
			strSQL = strSQL & ",'25','30',''," & bAuthenticate
			'implement different text body if logic is approve or disapprove
            objRS2.Open(strSQL, objConn, adOpenDynamic, adLockOptimistic, adCmdText)
								  
				'*************************************************************LP 
'response.end
		end if
	end if
		
	'handle special cases for moving to stage 11
	if action="approve" and stage_id=10 then
	    strSQL = "EXEC sp_SPD_Batch_PublishMQMessage_ByBatchID " & batch_id
	    objRS2.Open(strSQL, objConn, adOpenDynamic, adLockOptimistic, adCmdText)
	    'objRS2.Close()
	end if

	'get the current stage to determine if it the buyer stage we currently skip
	strSQL = "select * from spd_batch where id=" & batch_id
	objRS.Open(strSQL, objConn, adOpenDynamic, adLockOptimistic, adCmdText)
	if not objRS.eof then
		current_stage_id=cint(objRS("workflow_stage_id").value)
	end if
	objRS.close
	'check to see if there is a workflow exception
	if (IsDBNull(fineline_dept_id) orelse fineline_dept_id.ToString() = String.Empty) or (IsDBNull(initial_stage_id) orelse initial_stage_id.ToString() = String.Empty) or (IsDBNull(current_stage_id) orelse current_stage_id.ToString() = String.Empty) then
	    workflow_exception=false
	else
	    strSQL = "select * from spd_workflow_exception where dept=" & fineline_dept_id & " and from_stage_id=" & initial_stage_id & " and to_stage_id=" & current_stage_id & " and enabled=1"
	    objRS.Open(strSQL, objConn, adOpenDynamic, adLockOptimistic, adCmdText)
	    if not objRS.eof then
		    workflow_exception=true
	    else
		    workflow_exception=false
	    end if
	    objRS.close
	end if
	objRS2 = nothing
	objRS1 = nothing
	objRS = nothing
	objConn = nothing
	'skip over the cm/cd (buyer stage id 4)
	if current_stage_id=4 or workflow_exception then
		response.redirect("skip_buyer.aspx?batch_type=" & request.form("batch_type") & "&batch_id=" & request.form("batch_id") & "&action=" & request.form("action") & "&notes=" & server.urlencode(request.form("notes")) & "&stage=" & request.form("stage") )
	else
		response.redirect("default.aspx")
	end if

end if
%>
</body>
</html>
