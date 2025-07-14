<%@ LANGUAGE=VBSCRIPT%> 
<%
'==============================================================================
' Author: Ken Wallace, Principal - Ken Wallace Design
'==============================================================================
Option Explicit
Response.Buffer = True
Response.Expires = -1441
%>
<!--#include file="./../app_include/_globalInclude.asp"-->
<%

Dim objConn, objRec, SQLStr, connStr, i, z, y, j, k
Dim arDataRows, dictDataCols
Dim rowCounter, curIteration, numFound
Dim Type_ID, Type_Name
Dim UserDefinedField_ID, UserDefinedField_Settings_ID, isDefault
Dim Data_Label, Data_Value_Text, Data_Value_Date, Data_Value_Number, Data_Value_Money, Data_Value_Boolean, SortOrder, Date_Created
Dim defaultSelectOptions, defaultSelectOptions_thisRow, numSelectOtions
Dim ThisField_Selected_Field_Ordinal, ThisField_Selected_Field_Type, ThisField_Selected_Field_Size
Dim ThisField_Selected_Field_MaxLength, ThisField_Selected_Field_ClassName, ThisField_Selected_Field_StyleString
Dim ThisField_Selected_Field_Label, ThisField_Selected_Field_HelpText
Dim ThisField_Selected_AllowNullData, ThisField_Selected_UseDefaultValueWhenBlank, ThisField_Selected_UseDefaultValueWhenValidationFails
Dim ThisField_Selected_Date_Last_Modified, ThisField_Selected_Date_Created
Dim ThisField_Selected_Field_DefaultValue
Dim strFieldDefaultsAtOnLoad, arFieldDefaultsAtOnLoad

Set objConn = Server.CreateObject("ADODB.Connection")
Set objRec = Server.CreateObject("ADODB.RecordSet")
Set dictDataCols = Server.CreateObject("Scripting.Dictionary")

connStr = Application.Value("connStr")
objConn.Open connStr

SQLStr = "SELECT * FROM Repository_UserDefinedField_Type ORDER BY SortOrder, [Type_Name], [ID]"
Call returnDataWithGetRows(connStr, SQLStr, arDataRows, dictDataCols)

if Request.Form.Count > 0 then
'	for z = 1 to Request.Form.Count
'		Response.Write Request.Form.Key(z) & ": '" & Request.Form(z) & "'<br>" & vbCrLf
'	next

	objConn.BeginTrans
	for i = 1 to 5

		UserDefinedField_Settings_ID = 0
		ThisField_Selected_Field_Type = SmartValues(Trim(Request.Form("field" & i & "_Type")), "CLng")
		
		if ThisField_Selected_Field_Type = 0 then
		
			SQLStr = "DELETE Repository_UserDefinedField_CandidateData FROM Repository_UserDefinedField_CandidateData a " & _
					" INNER JOIN Repository_UserDefinedField_Settings b ON b.[ID] = a.UserDefinedField_Settings_ID " & _
					" WHERE b.Field_Ordinal = '0" & i & "' "
			Set objRec = objConn.Execute(SQLStr)

			SQLStr = "DELETE FROM Repository_UserDefinedField_Settings WHERE Field_Ordinal = '0" & i & "'"
			Set objRec = objConn.Execute(SQLStr)
		
		elseif ThisField_Selected_Field_Type > 0 then

			SQLStr = "SELECT TOP 1 a.[ID] As UserDefinedField_Settings_ID, a.* " & _
					" FROM Repository_UserDefinedField_Settings a " & _
					" WHERE a.Field_Ordinal = '0" & i & "' ORDER BY Date_Created "
			objRec.Open SQLStr, objConn, adOpenDynamic, adLockBatchOptimistic, adCmdText
			if objRec.EOF then
				objRec.AddNew
			else
				UserDefinedField_Settings_ID = checkQueryID(objRec("UserDefinedField_Settings_ID"), 0)
			end if

			ThisField_Selected_Field_Ordinal = i
			ThisField_Selected_Field_ClassName = SmartValues(Trim(Request.Form("field" & i & "_ClassName")), "CStr")
			ThisField_Selected_Field_StyleString = SmartValues(Trim(Request.Form("field" & i & "_StyleString")), "CStr")
			ThisField_Selected_Field_Label = SmartValues(Trim(Request.Form("field" & i & "_Label")), "CStr")
			ThisField_Selected_Date_Last_Modified = CDate(Now)
					
			objRec("Field_Ordinal") = ThisField_Selected_Field_Ordinal
			objRec("Field_Type") = ThisField_Selected_Field_Type
			objRec("Field_ClassName") = ThisField_Selected_Field_ClassName
			objRec("Field_StyleString") = ThisField_Selected_Field_StyleString
			objRec("Field_Label") = ThisField_Selected_Field_Label
			objRec("Date_Last_Modified") = CDate(Now)
			
			objRec.UpdateBatch
			objRec.Close

			if UserDefinedField_Settings_ID = 0 then
				SQLStr = "SELECT TOP 1 a.[ID] As UserDefinedField_Settings_ID, a.* " & _
						" FROM Repository_UserDefinedField_Settings a " & _
						" WHERE a.Field_Ordinal = '0" & i & "' ORDER BY Date_Created "
				Set objRec = objConn.Execute(SQLStr)
				if not objRec.EOF then
					UserDefinedField_Settings_ID = checkQueryID(objRec("UserDefinedField_Settings_ID"), 0)
				end if
				objRec.Close
			end if
			
			if UserDefinedField_Settings_ID > 0 then
				SQLStr = "DELETE FROM Repository_UserDefinedField_CandidateData WHERE UserDefinedField_Settings_ID = '0" & UserDefinedField_Settings_ID & "'"
				Set objRec = objConn.Execute(SQLStr)

				if ThisField_Selected_Field_Type <> 6 and ThisField_Selected_Field_Type <> 7 then

					SQLStr = "SELECT * FROM Repository_UserDefinedField_CandidateData WHERE UserDefinedField_Settings_ID = '0" & UserDefinedField_Settings_ID & "'"
					objRec.Open SQLStr, objConn, adOpenDynamic, adLockBatchOptimistic, adCmdText
					if objRec.EOF then
						objRec.AddNew
					
						ThisField_Selected_Field_DefaultValue = SmartValues(Trim(Request.Form("field" & i & "_DefaultValue")), "CStr")
						objRec("UserDefinedField_Settings_ID") = UserDefinedField_Settings_ID
						
						Select Case ThisField_Selected_Field_Type

							Case 1 ' Text
								objRec("isDefault") = 1
								ThisField_Selected_Field_DefaultValue = SmartValues(ThisField_Selected_Field_DefaultValue, "CStr")
								if Len(ThisField_Selected_Field_DefaultValue) > 0 then 
									objRec("Data_Value_Text") = ThisField_Selected_Field_DefaultValue
								end if

							Case 2 ' Date/Time
								objRec("isDefault") = 1
								ThisField_Selected_Field_DefaultValue = SmartValues(ThisField_Selected_Field_DefaultValue, "CDate") 
								if Len(ThisField_Selected_Field_DefaultValue) > 0 and IsDate(ThisField_Selected_Field_DefaultValue) then
									objRec("Data_Value_Date") = ThisField_Selected_Field_DefaultValue
								end if

							Case 3 ' Number
								objRec("isDefault") = 1
								ThisField_Selected_Field_DefaultValue = SmartValues(ThisField_Selected_Field_DefaultValue, "CDbl") 
								if Len(ThisField_Selected_Field_DefaultValue) > 0 and IsNumeric(ThisField_Selected_Field_DefaultValue) then 
									objRec("Data_Value_Number") = ThisField_Selected_Field_DefaultValue
								end if

							Case 4 ' Money
								objRec("isDefault") = 1
								ThisField_Selected_Field_DefaultValue = SmartValues(ThisField_Selected_Field_DefaultValue, "CDbl") 
								if Len(ThisField_Selected_Field_DefaultValue) > 0 and IsNumeric(ThisField_Selected_Field_DefaultValue) then 
									objRec("Data_Value_Money") = ThisField_Selected_Field_DefaultValue
								end if

							Case 5 ' Boolean
								objRec("isDefault") = 1
								ThisField_Selected_Field_DefaultValue = SmartValues(ThisField_Selected_Field_DefaultValue, "CBool")
								if Len(ThisField_Selected_Field_DefaultValue) > 0 then 
									objRec("Data_Value_Boolean") = ThisField_Selected_Field_DefaultValue
								end if

						End Select
						
						objRec.UpdateBatch
					end if
					objRec.Close

				elseif ThisField_Selected_Field_Type = 6 or ThisField_Selected_Field_Type = 7 then
				
					numSelectOtions = SmartValues(Request("totNumRows_field" & i & "_selectoptions"), "CInt")
					for y = 0 to numSelectOtions - 1
						if Len(Request("field" & i & "_selectoptions_fld_Data_Value_Number_" & y)) > 0 then
							objRec.Open "Repository_UserDefinedField_CandidateData", objConn, adOpenDynamic, adLockBatchOptimistic, adCmdTable
							objRec.AddNew
						
							objRec("UserDefinedField_Settings_ID") = UserDefinedField_Settings_ID
							objRec("Data_Value_Number") = checkQueryID(Trim(Request("field" & i & "_selectoptions_fld_Data_Value_Number_" & y)), 0) 
							objRec("Data_Label") = Left(SmartValues(Trim(Request("field" & i & "_selectoptions_fld_Data_Label_" & y)), "CStr"), 2000)
							objRec("isDefault") = SmartValues(Request("field" & i & "_selectoptions_fld_IsDefault_" & y), "CBool")
							
							if Len(Replace(Trim(SmartValues(Request("field" & i & "_selectoptions_fld_SortOrder_" & y), "CStr")), "&nbsp;", "")) > 0 then
								objRec("SortOrder") = Replace(Trim(SmartValues(Request("field" & i & "_selectoptions_fld_SortOrder_" & y), "CStr")), "&nbsp", "")
							end if
							
							objRec.UpdateBatch
							objRec.Close					
						end if
					next

				end if
			end if

		end if

	next
	
	objConn.CommitTrans
end if
%>
<html>
<head>
	<title></title>
	<style type="text/css">
		@import url('./../app_include/global.css');
		.bodyText{line-height: 14px;}
		A {text-decoration: underline; color:#000;}
		A:HOVER {text-decoration: underline; color: #00f;}
		.childcatlist {white-space: nowrap; vertical-align: top; border-bottom: 1px solid #ececec;}
		.childcatlistheader {color: #999; vertical-align: bottom; border-bottom: 1px solid #ccc;}
		.right {text-align: right;}

		div.dropmarker
		{
			width: 100%;
			border-top: 1px dashed #c00;
			margin-top: -3px;
			margin-left: -5px;
			z-index: 1000;
			overflow: hidden;
		}

		.listDivContainer
		{
			width: 100%; 
		}
		
		.CustomDataFieldNumberMarker
		{
			font-family: Garamond, Times, Georgia;
			font-weight: bold;
			font-size: 32px;
			line-height: 36px;
			color: #666;
		}

	</style>
	<link rel="stylesheet" type="text/css" href="./../app_include/ediTable.css">
	<script language=javascript type="text/javascript" src="./../app_include/ediTable_v1.1.js"></script>
	<script language=javascript>

		function launchNewWin(myLoc, myName, myWidth, myHeight)
		{
			var myFeatures = "directories=no,dependent=yes,width=" + myWidth + ",height=" + myHeight + ",hotkeys=no,location=no,menubar=no,resizable=yes,screenX=100,screenY=100,scrollbars=yes,titlebar=no,toolbar=no,status=no";
			var newWin = window.open(myLoc, myName, myFeatures);
		}
	
		function go(selectedID)
		{
			var targetFrameReference = parent.parent.frames["CatalogDetailFrameset"];
			syncTOC(selectedID, 'catalog');
			targetFrameReference.document.location = "catalog_detail_frm.asp?catalogid=" + selectedID + "&chapterid=0&sectionid=0";
		}
		

	</script>
</head>
<body bgcolor="cccccc" topmargin=0 leftmargin=0 marginheight=0 marginwidth=0>

<form name="theForm" action="content_settings.asp" method="post" id="theForm" style="margin: 0; padding: 0;">
<div class="bodyText" style="width:100%; margin: 20px; margin-top: 10px;">
	<div class="bodyText headerText" style="margin-bottom: 5px;">Custom Document Data Fields</div>
	<div class="bodyText" style="margin-bottom: 10px;">Define custom document data fields users will see in the document edit screen.</div>

	<div>
		<table cellpadding="0" cellspacing="0" border="0">
			<tr>
				<td class="bodyText">	
				</td>
				<td><img src="./images/spacer.gif" width=10 height=1></td>
				<td class="bodyText">
				</td>
				<td><img src="./images/spacer.gif" width=5 height=1></td>
				<td class="bodyText">
				</td>
			</tr>
			<tr><td colspan=7><img src="./images/spacer.gif" width=1 height=5></td></tr>
			<tr bgcolor="999999"><td colspan=7><img src="./images/spacer.gif" width=1 height=1></td></tr>
			<tr bgcolor="ececec"><td colspan=7><img src="./images/spacer.gif" width=1 height=1></td></tr>
			<tr><td colspan=7><img src="./images/spacer.gif" width=1 height=5></td></tr>
			<%
			
			for i = 1 to 5
				defaultSelectOptions = ""

				SQLStr = "SELECT a.[ID] As UserDefinedField_ID, a.UserDefinedField_Settings_ID, a.isDefault, a.Data_Label, Replace(a.Data_Label, '''', '\''') As Data_Label_Padded, a.Data_Value_Text, a.Data_Value_Date, a.Data_Value_Number, a.Data_Value_Money, a.Data_Value_Boolean, NULLIF(a.SortOrder, 'ALPHA') As SortOrder, a.Date_Created " & _
						" FROM Repository_UserDefinedField_CandidateData a " & _
						" INNER JOIN Repository_UserDefinedField_Settings b ON b.[ID] = a.UserDefinedField_Settings_ID " & _
						" WHERE b.Field_Ordinal = '0" & i & "' " & _
						" ORDER BY COALESCE(RIGHT('00000' + CONVERT(varchar(5), a.SortOrder), 5), 'ALPHA'), a.Data_Label, a.Data_Value_Number, a.Date_Created"
				objRec.Open SQLStr, objConn, adOpenForwardOnly, adLockReadOnly, adCmdText
				if not objRec.EOF then
					defaultSelectOptions = ", ["
					Do Until objRec.EOF
						defaultSelectOptions_thisRow = ""
						
						UserDefinedField_ID = SmartValues(objRec("UserDefinedField_ID"), "CLng")
						UserDefinedField_Settings_ID = SmartValues(objRec("UserDefinedField_Settings_ID"), "CLng")
						isDefault = SmartValues(objRec("isDefault"), "CBool")
						Data_Label = SmartValues(objRec("Data_Label"), "CStr")
						Data_Value_Text = SmartValues(objRec("Data_Value_Text"), "CStr")
						Data_Value_Date = SmartValues(objRec("Data_Value_Date"), "CDate")
						Data_Value_Number = SmartValues(objRec("Data_Value_Number"), "CDbl")
						Data_Value_Money = SmartValues(objRec("Data_Value_Money"), "CLng")
						Data_Value_Boolean = SmartValues(objRec("Data_Value_Boolean"), "CBool")
						SortOrder = SmartValues(objRec("SortOrder"), "CStr")
						Date_Created = SmartValues(objRec("Date_Created"), "CDate")
						
						if Len(Trim(defaultSelectOptions)) > 3 then defaultSelectOptions = defaultSelectOptions & ","
						defaultSelectOptions_thisRow = defaultSelectOptions_thisRow & "'" & SmartValues(objRec("Data_Value_Number"), "CLng") & "',"
						defaultSelectOptions_thisRow = defaultSelectOptions_thisRow & "'" & SmartValues(objRec("Data_Label_Padded"), "CStr") & "',"
						defaultSelectOptions_thisRow = defaultSelectOptions_thisRow & "'" & SmartValues(objRec("isDefault"), "CBool") & "',"
						defaultSelectOptions_thisRow = defaultSelectOptions_thisRow & "'" & SmartValues(objRec("SortOrder"), "CStr") & "'"
						defaultSelectOptions = defaultSelectOptions & "[" & defaultSelectOptions_thisRow & "]"
												
						objRec.MoveNext
					Loop
					defaultSelectOptions = defaultSelectOptions & "]"
				end if
				objRec.Close

				ThisField_Selected_Field_Ordinal = 0
				ThisField_Selected_Field_Type = 0
				ThisField_Selected_Field_Size = 0
				ThisField_Selected_Field_MaxLength = 500
				ThisField_Selected_Field_ClassName = ""
				ThisField_Selected_Field_StyleString = ""
				ThisField_Selected_Field_Label = ""
				ThisField_Selected_Field_HelpText = ""
				ThisField_Selected_AllowNullData = true
				ThisField_Selected_UseDefaultValueWhenBlank = false
				ThisField_Selected_UseDefaultValueWhenValidationFails = false
				ThisField_Selected_Date_Last_Modified = ""
				ThisField_Selected_Date_Created = ""
				ThisField_Selected_Field_DefaultValue = ""

				SQLStr = "SELECT a.*, " & _
						"   b.Data_Value_Text As DefaultValue_Text, " & _
						"   b.Data_Value_Date As DefaultValue_Date, " & _
						"   b.Data_Value_Number As DefaultValue_Number, " & _
						"   b.Data_Value_Money As DefaultValue_Money, " & _
						"   b.Data_Value_Boolean As DefaultValue_Boolean " & _
						" FROM Repository_UserDefinedField_Settings a " & _
						" LEFT OUTER JOIN Repository_UserDefinedField_CandidateData b ON b.UserDefinedField_Settings_ID = a.[ID] AND b.isDefault = 1 " & _
						" WHERE Field_Ordinal = '0" & i & "'"
				
				objRec.Open SQLStr, objConn, adOpenForwardOnly, adLockReadOnly, adCmdText
				if not objRec.EOF then
					Do Until objRec.EOF
						
						ThisField_Selected_Field_Ordinal = SmartValues(objRec("Field_Ordinal"), "CLng")
						ThisField_Selected_Field_Type = SmartValues(objRec("Field_Type"), "CLng")
						ThisField_Selected_Field_Size = SmartValues(objRec("Field_Size"), "CLng")
						ThisField_Selected_Field_MaxLength = SmartValues(objRec("Field_MaxLength"), "CLng")
						ThisField_Selected_Field_ClassName = SmartValues(objRec("Field_ClassName"), "CStr")
						ThisField_Selected_Field_StyleString = SmartValues(objRec("Field_StyleString"), "CStr")
						ThisField_Selected_Field_Label = SmartValues(objRec("Field_Label"), "CStr")
						ThisField_Selected_Field_HelpText = SmartValues(objRec("Field_HelpText"), "CStr")
						ThisField_Selected_AllowNullData = SmartValues(objRec("AllowNullData"), "CBool")
						ThisField_Selected_UseDefaultValueWhenBlank = SmartValues(objRec("UseDefaultValueWhenBlank"), "CBool")
						ThisField_Selected_UseDefaultValueWhenValidationFails = SmartValues(objRec("UseDefaultValueWhenValidationFails"), "CBool")
						ThisField_Selected_Date_Last_Modified = SmartValues(objRec("Date_Last_Modified"), "CDate")
						ThisField_Selected_Date_Created = SmartValues(objRec("Date_Created"), "CDate")
						
						Select Case ThisField_Selected_Field_Type

							Case 1 ' Text
								ThisField_Selected_Field_DefaultValue = SmartValues(objRec("DefaultValue_Text"), "CStr")

							Case 2 ' Date/Time
								ThisField_Selected_Field_DefaultValue = SmartValues(objRec("DefaultValue_Date"), "CDate") 

							Case 3 ' Number
								ThisField_Selected_Field_DefaultValue = SmartValues(objRec("DefaultValue_Number"), "CDbl") 

							Case 4 ' Money
								ThisField_Selected_Field_DefaultValue = SmartValues(objRec("DefaultValue_Money"), "CDbl") 

							Case 5 ' Boolean
								ThisField_Selected_Field_DefaultValue = SmartValues(objRec("DefaultValue_Boolean"), "CBool")

						End Select

						objRec.MoveNext
					Loop
				end if
				objRec.Close

				if Len(Trim(strFieldDefaultsAtOnLoad)) > 0 then
					strFieldDefaultsAtOnLoad = strFieldDefaultsAtOnLoad & "~!@"
				end if
				strFieldDefaultsAtOnLoad = strFieldDefaultsAtOnLoad & defaultSelectOptions
			%>
			<tr>
				<td class="bodyText CustomDataFieldNumberMarker" style="text-align: left; vertical-align: top;">	
					<%=i%>
				</td>
				<td></td>
				<td class="bodyText" style="text-align: left; vertical-align: top;">
					
					<table cellpadding="0" cellspacing="2" border="0">
						<tr>
							<td class="bodyText">	
								Field&nbsp;Type:&nbsp;
							</td>
							<td class="bodyText">
								<select name="field<%=i%>_Type" style="width: 250px;" onchange="watchTypeChange(this, '<%=i%>'<%=defaultSelectOptions%>);" id="field<%=i%>_Type">
									<option value="0">~ This field is not in use ~</option>
									<%
									rowCounter = 0
									if dictDataCols("ColCount") > 0 and dictDataCols("RecordCount") > 0 then
										for rowCounter = 0 to dictDataCols("RecordCount") - 1
											Type_ID = SmartValues(arDataRows(dictDataCols("ID"), rowCounter), "CLng")
											Type_Name = Server.HTMLEncode(SmartValues(arDataRows(dictDataCols("Type_Name"), rowCounter), "CStr"))
									%>
									<option value="<%=Type_ID%>"<%if ThisField_Selected_Field_Type = Type_ID then Response.Write " SELECTED"%>><%=Type_Name%></option>
									<%
										Next
									end if
									%>
								</select>
							</td>
						</tr>
						<tr>
							<td class="bodyText" style="width: 80px;">	
								Field&nbsp;Label:&nbsp;
							</td>
							<td class="bodyText">	
								<input type="text" name="field<%=i%>_Label" value="<%=ThisField_Selected_Field_Label%>" maxlength="500" class="bodyText" style="width: 250px;">
							</td>
						</tr>
						<tr id="DefaultValueRow<%=i%>" style="display: none;">
							<td class="bodyText">	
								Default&nbsp;Value:&nbsp;
							</td>
							<td class="bodyText">	
								<input type="text" name="field<%=i%>_DefaultValue" value="<%=ThisField_Selected_Field_DefaultValue%>" maxlength="500" class="bodyText" style="width: 250px;">
							</td>
						</tr>
					</table>

				</td>
				<td></td>
				<td class="bodyText" style="text-align: left; vertical-align: top;">

					<table cellpadding="0" cellspacing="2" border="0">
						<tr>
							<td class="bodyText">	
								CSS&nbsp;Class:&nbsp;
							</td>
							<td class="bodyText">	
								<input type="text" name="field<%=i%>_ClassName" value="<%=ThisField_Selected_Field_ClassName%>" maxlength="500" class="bodyText" style="width: 250px;">
							</td>
						</tr>
						<tr>
							<td class="bodyText">	
								CSS&nbsp;Style:&nbsp;
							</td>
							<td class="bodyText">	
								<input type="text" name="field<%=i%>_StyleString" value="<%=ThisField_Selected_Field_StyleString%>" maxlength="500" class="bodyText" style="width: 250px;">
							</td>
						</tr>
					</table>

				</td>
			</tr>
			<tr id="SelectOptionTableRow<%=i%>" style="display: none;">
				<td></td>
				<td></td>
				<td colspan=5 class="bodyText">
					<div class="bodyText" style="margin-top: 10px; margin-left: 10px; margin-bottom: 10px;">
						<div style="width: 600px;">
							Using the table below, configure the display text and corresponding values to be shown for this Select List.  
							NOTE: Values will be displayed alphabetically, first by sequence number, then display text, then value.
						</div>
						<div style="margin-top: 5px;" id="SelectOptionTableDiv<%=i%>"><!-- Placeholder for table --></div>
					</div>
				</td>
			</tr>
			<tr><td colspan=7><img src="./images/spacer.gif" width=1 height=5></td></tr>
			<tr bgcolor="999999"><td colspan=7><img src="./i mages/spacer.gif" width=1 height=1></td></tr>
			<tr bgcolor="ececec"><td colspan=7><img src="./images/spacer.gif" width=1 height=1></td></tr>
			<tr><td colspan=7><img src="./images/spacer.gif" width=1 height=5></td></tr>
			<%
			next
			%>
			<tr>
				<td colspan=7>
					<div style="margin-top: 5px;" id="controls" style="width:100%; white-space: nowrap; text-align: right;">
						<input type="reset" id="btnCancel" name="btnCancel" value=" Cancel " style="margin-right: 5px;">
						<input type="submit" id="btnSubmit" name="btnSubmit" value=" Save Changes ">
					</div>
				</td>
			</tr>
		</table>

	</div>

</div>
</form>

<%
arFieldDefaultsAtOnLoad = Split(strFieldDefaultsAtOnLoad, "~!@")
%>

<script type="text/javascript" language="javascript">
	<%
	for i = 1 to 5
		if UBound(arFieldDefaultsAtOnLoad) > 0 then
		%>
	watchTypeChange(document.theForm.field<%=i%>_Type, '<%=i%>'<%=arFieldDefaultsAtOnLoad(i-1)%>);
		<%
		else
		%>
	watchTypeChange(document.theForm.field<%=i%>_Type, '<%=i%>');
		<%
		end if
	next
	%>

	function watchTypeChange(selObj, whichObj, arDefaultRows)
	{
		if (isNaN(selObj.value)) return false;
		if (isNaN(whichObj)) return false;
		
		whichObj = Number(whichObj);
				
		switch (Number(selObj.value))
		{
			case 0:
				document.getElementById("DefaultValueRow" + whichObj).style.display = "none";
				document.getElementById("SelectOptionTableRow" + whichObj).style.display = "none";
				break;

			case 6:
				document.getElementById("DefaultValueRow" + whichObj).style.display = "none";
				document.getElementById("SelectOptionTableRow" + whichObj).style.display = "";
				if (!document.getElementById("field" + whichObj + "_selectoptions")) writeSelectOptionTable("field" + whichObj + "_selectoptions", document.getElementById("SelectOptionTableDiv" + whichObj), arDefaultRows);
				break;

			case 7:
				document.getElementById("DefaultValueRow" + whichObj).style.display = "none";
				document.getElementById("SelectOptionTableRow" + whichObj).style.display = "";
				if (!document.getElementById("field" + whichObj + "_selectoptions")) writeSelectOptionTable("field" + whichObj + "_selectoptions", document.getElementById("SelectOptionTableDiv" + whichObj), arDefaultRows);
				break;

			default:
				document.getElementById("DefaultValueRow" + whichObj).style.display = "";
				document.getElementById("SelectOptionTableRow" + whichObj).style.display = "none";
				break;
		}
	}

	function writeSelectOptionTable(newTableID, targetDivID, arDefaultRows)
	{
		var customDataTable = new ediTable(newTableID);
		customDataTable.border = 0;
		customDataTable.cellpadding = 2;
		customDataTable.cellspacing = 0;
		customDataTable.width = 0;
		customDataTable.editBehavior.allowAdd = true;
		customDataTable.editBehavior.allowDelete = true;
		customDataTable.editBehavior.removeBtn_vAlign = "top";
		customDataTable.editBehavior.validateEntries = true;
		customDataTable.className = "ediTable_table";
		customDataTable.headClassName = "ediTable_head";
		customDataTable.rowClassName = "ediTable_row";
		customDataTable.rowAltClassName = "ediTable_rowAlt";
		customDataTable.footClassName = "ediTable_foot";

		var newCol = customDataTable.addColumn("Data_Value_Number");
		newCol.label = "Values";
		newCol.editCell_styleStr = "width: 60px;";
		newCol.datatype = "number";
		newCol.editCell_maxLength = "8";
		newCol.align = "right";

		var newCol = customDataTable.addColumn("Data_Label");
		newCol.label = "Display&nbsp;Text";
		newCol.editCell_styleStr = "width: 400px;";
		newCol.datatype = "string";
		newCol.editCell_defaultValue = "";
		newCol.editCell_maxLength = "100";
		newCol.align = "left";

		var newCol = customDataTable.addColumn("IsDefault");
		newCol.label = "Default";
		newCol.datatype = "boolean";
		newCol.datatype_ext = "defaultChecked";
		newCol.datatype_ext_value = false;
		newCol.defaultValue = "True";
		newCol.align = "";

		var newCol = customDataTable.addColumn("SortOrder");
		newCol.label = "Sequence";
		newCol.editCell_styleStr = "width: 60px;";
		newCol.datatype = "number";
		newCol.editCell_maxLength = "4";
		newCol.align = "right";

		if (arDefaultRows) customDataTable.Rows = arDefaultRows;
		customDataTable.write(targetDivID);
	}

</script>

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
Set dictDataCols = Nothing
%>