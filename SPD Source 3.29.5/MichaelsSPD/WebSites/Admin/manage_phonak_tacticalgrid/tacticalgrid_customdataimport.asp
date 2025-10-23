<%@ LANGUAGE=VBSCRIPT%>
<%
'==============================================================================
' Author: Ken Wallace
'==============================================================================
Option Explicit
Response.Buffer = True
Response.Expires = -1441
%>
<!--#include file="./../app_include/_globalInclude.asp" -->
<%
Dim objConn, objRec, SQLStr, connStr

Set objConn = Server.CreateObject("ADODB.Connection")
Set objRec = Server.CreateObject("ADODB.RecordSet")
connStr = Application.Value("connStr")
objConn.Open connStr

Function UpdateableTables_getTables(boolIncludeDefaultFirstOption, p_defaultFirstOptionValue, p_defaultFirstOptionText)

	Dim SQLStr, utils, rs
	Dim m_optionsList

	Set utils = New cls_UtilityLibrary
	
	SQLStr = "SELECT t.* FROM Phonak_Updateable_Table t WHERE t.Allow_Update = 1 AND t.Application_ID = 1 AND (SELECT COUNT(*) FROM Phonak_Updateable_Table_Column c WHERE c.Table_ID = t.ID AND c.Allow_Update = 1) > 0 ORDER BY t.Table_Name"
	Set rs = utils.LoadRSFromDB(SQLStr)
	
	boolIncludeDefaultFirstOption = CBool(boolIncludeDefaultFirstOption)

	m_optionsList = "["
	if boolIncludeDefaultFirstOption then m_optionsList = m_optionsList & "[""" & p_defaultFirstOptionValue & """,""" & p_defaultFirstOptionText & """],"
	if rs.recordcount > 0 then
		Do Until rs.EOF
			m_optionsList = m_optionsList & "[""" & SmartValues(rs("ID"), "CStr") & """,""" & Replace(SmartValues(rs("Table_Name"), "CStr"), "'", "\'") & """],"
			rs.MoveNext
		Loop
	end if
	if Right(m_optionsList, 1) = "," then m_optionsList = Left(m_optionsList, Len(m_optionsList)-1)
	m_optionsList = m_optionsList & "]"
	
	if m_optionsList = "[]" then m_optionsList = ""
	
	Set rs = Nothing
	Set utils = Nothing
	
	UpdateableTables_getTables = m_optionsList

End Function

Function UpdateableTables_getTableColumns(boolIncludeDefaultFirstOption, p_defaultFirstOptionValue, p_defaultFirstOptionText)

	Dim SQLStr, utils, rs, rs1
	Dim m_strOut, m_optionsList
	Dim m_Table_ID, m_Table_Name

	Set utils = New cls_UtilityLibrary
	
	SQLStr = "SELECT * FROM Phonak_Updateable_Table WHERE Allow_Update = 1 AND Application_ID = 1 ORDER BY Table_Name"
	Set rs = utils.LoadRSFromDB(SQLStr)

	if rs.recordcount > 0 then
		Do Until rs.EOF
		
			m_Table_ID = SmartValues(rs("ID"), "CStr")
			m_Table_Name = SmartValues(rs("Table_Name"), "CStr")
			
			SQLStr = "SELECT COALESCE(Display_Name, Column_Name) As Column_Name, ID FROM Phonak_Updateable_Table_Column WHERE Allow_Update = 1 AND Table_ID = '0" & m_Table_ID & "' ORDER BY Ordinal_Position, Column_Name"
			Set rs1 = utils.LoadRSFromDB(SQLStr)
			
			boolIncludeDefaultFirstOption = CBool(boolIncludeDefaultFirstOption)

			m_optionsList = "["
			if boolIncludeDefaultFirstOption then m_optionsList = m_optionsList & "[""" & p_defaultFirstOptionValue & """,""" & p_defaultFirstOptionText & """],"
			if rs1.recordcount > 0 then
				Do Until rs1.EOF
					m_optionsList = m_optionsList & "[""" & SmartValues(rs1("ID"), "CStr") & """,""" & Replace(SmartValues(rs1("Column_Name"), "CStr"), "'", "\'") & """],"
					rs1.MoveNext
				Loop
			end if
			if Right(m_optionsList, 1) = "," then m_optionsList = Left(m_optionsList, Len(m_optionsList)-1)
			m_optionsList = m_optionsList & "]"
			
			if m_optionsList = "[]" then m_optionsList = ""

			m_strOut = m_strOut & "var mtable = new UpdateableTable(""" & m_Table_ID & """, """ & m_Table_Name & """);" & vbCrLf & vbTab & vbTab & vbTab
			if Len(m_optionsList) > 0 then m_strOut = m_strOut & "mtable.columns = " & m_optionsList & ";" & vbCrLf & vbTab & vbTab & vbTab
			m_strOut = m_strOut & "UpdateableTables.push(""" & m_Table_ID & """);" & vbCrLf & vbTab & vbTab & vbTab
			m_strOut = m_strOut & "UpdateableTables[""" & m_Table_ID & """] = mtable;" & vbCrLf & vbTab & vbTab & vbTab
			m_strOut = m_strOut & "mtable = null;" & vbCrLf & vbCrLf & vbTab & vbTab & vbTab
			
			rs.MoveNext
		Loop
	end if
	
	Set rs1 = Nothing
	Set rs = Nothing
	Set utils = Nothing
	
	UpdateableTables_getTableColumns = m_strOut

End Function


Dim UpdateableTablesList, UpdateableTablesColumnsInitStr
UpdateableTablesList = UpdateableTables_getTables(true, "0", "")
UpdateableTablesColumnsInitStr = UpdateableTables_getTableColumns(true, "0", "")
%>
<html>
<head>
	<title></title>
	<script language="javascript" src="./../app_include/prototype/prototype.js"></script>
	<script language="javascript" src="./../app_include/evaluator.js"></script>
	<style type="text/css">
		<!--#include file="./../app_include/global.css"-->
		/*@import url('./../app_include/global.css');*/

		.bodyText{line-height: 14px;}

		A {text-decoration: underline; color:#000;}
		A:HOVER {text-decoration: underline; color: #00f;}
		
		.subheaderText
		{
			font-family: Georgia; 
			font-size: 22px; 
			line-height: 26px; 
			font-weight: normal;
			color: #333;
		}
		
		.messageHeader
		{
			font-family: Georgia; 
			font-size: 22px; 
			line-height: 26px; 
			font-weight: normal;
			color: #333;
		}

	</style>
	<script language=javascript>

		// ########################################################################################
		// ########################################################################################
		//
		// Create Objects
		//
		// ########################################################################################
		// ########################################################################################

		//Create a "Table" object, which can store metadata about each updateable table...
		var UpdateableTable = function( 
								table_id, 
								table_name
							)
		{
			this.table_id = table_id;
			this.table_name = table_name;
			this.columns = new Array();
			this.inspect = function()
			{
				var strOut = "";
				var obj = this;
				for (var i in obj)
				{
					if (typeof(obj[i]) != "object" && typeof(obj[i]) != "function")
					{
						strOut += "Table." + i + ": " + obj[i] + "\n"
					}
				}
				return strOut;
			}
		}
		
		//Create an array which can store a collection of tables
		var UpdateableTables = new Array();
		

		// ########################################################################################
		// ########################################################################################
		//
		// Utility Functions
		//
		// ########################################################################################
		// ########################################################################################

		function populateDropDown(selObj, arOptions)
		{
			selObj.options.length = 0;
			for (var index = 0, len = arOptions.length; index < len; ++index) 
			{   
				var myOptions = arOptions[index];
				var myOptionValue = myOptions[0];
				var myOptionText = myOptions[1];
				var newItemPosition = selObj.options.length;
				selObj.options[newItemPosition] = new Option(myOptionText, myOptionValue);
			} 
		}

		function selectDropDownOptionbyText(selObj, desiredText)
		{
			for (i = 0; i < selObj.options.length; i++)
			{
				if (selObj.options[i].text == desiredText)
				{
					selObj.options[i].selected = true;
				}
			}
		}
		
		function selectDropDownOptionbyValue(selObj, desiredValue)
		{
			for (i = 0; i < selObj.options.length; i++)
			{
				if (selObj.options[i].value == desiredValue)
				{
					selObj.options[i].selected = true;
				}
			}
		}

		function selectMultipleDropDownOptionbyValue(selObj, desiredValueArray)
		{
			for (i = 0; i < selObj.options.length; i++)
			{
				for (j = 0; j < desiredValueArray.length; j++)
				{
					if (selObj.options[i].value == desiredValueArray[j])
					{
						selObj.options[i].selected = true;
					}
				}
			}
		}

		// ########################################################################################
		// ########################################################################################
		//
		// Page Event Handlers
		//
		// ########################################################################################
		// ########################################################################################
		
		function initPage()
		{
			populateDropDown($("selTable"), <%=UpdateableTablesList%>);

			<%=UpdateableTablesColumnsInitStr%>
		}
		
		function selectionChange(selObj)
		{
			switch(selObj.id)
			{
				case "selTable":
					if (Number(selObj.value) > 0)
					{
						Element.show('columnChooserDiv');
						populateDropDown($("selColumn"),  UpdateableTables["" + selObj.value].columns);
					}
					else
					{
						document.theForm.reset();
						Element.hide('columnChooserDiv');
						Element.hide('fileUploaderDiv');
						Element.hide('formControlsDiv')
					}
					break;

				case "selColumn":
					if (Number(selObj.value) > 0)
					{
						Element.show('fileUploaderDiv');
					}
					else
					{
						var oldtableval = $('selTable').value;
						document.theForm.reset();
						selectDropDownOptionbyValue($('selTable'), oldtableval);
						Element.hide('fileUploaderDiv');
						Element.hide('formControlsDiv')
					}
					break;

				case "selectedFileName":
					if (selObj.value != "")
					{
						$('btnCommit').disabled = false;
						Element.show('formControlsDiv')
					}
					else
					{
						document.theForm.reset();
						$('btnCommit').disabled = true;
						Element.hide('formControlsDiv')
					}
					break;
			}
		
		}
		
		function outputCurrentCSV()
		{
			if (document.theForm.selTable.value == "") return false;
			if (document.theForm.selColumn.value == "") return false;
			
			launchNewWin("tacticalgrid_customdataimport_outputcsv.asp?selTable=" + document.theForm.selTable.value + "&selColumn=" + document.theForm.selColumn.value, "CSVOut", 500, 500);
		}
		
		function launchNewWin(myLoc, myName, myWidth, myHeight)
		{
				var myFeatures = "directories=no,dependent=yes,width=" + myWidth + ",height=" + myHeight + ",hotkeys=no,location=no,menubar=no,resizable=yes,screenX=100,screenY=100,scrollbars=yes,titlebar=no,toolbar=no,status=no";
				var newWin = window.open(myLoc, myName, myFeatures);
		}
	</script>
</head>
<body bgcolor="cccccc" topmargin=0 leftmargin=0 marginheight=0 marginwidth=0 onload="initPage();">

<div class="bodyText" style="margin: 20px;">
	<form name="theForm" action="tacticalgrid_customdataimport_work.asp" method="POST" enctype="multipart/form-data" style="padding:0; margin:0;">
			
	<div id="formContainerDiv" class="" style="width:400px; padding: 0px;">
		<%if Len(Trim(Session.Value("TACTICALGRID_CUSTOMDATAIMPORT_MESSAGE"))) > 0 then%>
		<div id="messageDiv" class="bodyText" style="background: #ffc; padding: 10px; margin-bottom: 20px;">
		<%=Session.Value("TACTICALGRID_CUSTOMDATAIMPORT_MESSAGE")%>	
		</div>
		<%
		end if
		Session.Value("TACTICALGRID_CUSTOMDATAIMPORT_MESSAGE") = ""
		%>
		<div id="tableChooserDiv" class="" style="">
			<div id="selTableLabelDiv" class="subheaderText" style="">1. Choose a Table</div>
			<div id="selTableSublabelDiv" class="" style="">Select the table you'd like to modify from those available in the list below</div>
			<div id="selTableDiv" class="" style="margin-top: 10px;">
				<select id="selTable" name="selTable" onchange="selectionChange(this);" style="width: 400px;">
					<option value="0"></option>
				</select>
			</div>
		</div>
		<div id="columnChooserDiv" class="" style="display: none; margin-top: 20px;">
			<div id="selColumnLabelDiv" class="subheaderText" style="">2. Choose a Column</div>
			<div id="selColumnSublabelDiv" class="" style="">Select the column you'd like to modify from the list below</div>
			<div id="selColumnDiv" class="" style="margin-top: 10px;">
				<select id="selColumn" name="selColumn" onchange="selectionChange(this);" style="width: 400px;">
					<option value="0"></option>
				</select>
			</div>
		</div>
		<div id="fileUploaderDiv" class="" style="display: none; margin-top: 20px;">
			<div id="filenameLabelDiv" class="subheaderText" style="">3. Upload a CSV File</div>
			<div id="filenameSublabelDiv" class="" style="">Using the Browse button, choose the CSV file you wish to upload.</div>
			<div id="filenameDiv" class="" style="margin-top: 10px;">
				<input type="file" size=50 maxlength=1024 id="selectedFileName" name="selectedFileName" value="" style="width: 400px;" onchange="selectionChange(this);">
			</div>
			<div id="samplefileDiv" class="" style="color: #333; font-size: 10px; margin-top: 2px;">Need a <a href="sample.csv" id="sampleCSV">sample CSV file</a>?&nbsp;&nbsp;Or, <a href="" onclick="outputCurrentCSV(); return false;">download the current data</a> in this column.</div>
		</div>
		<div id="formControlsDiv" class="" style="display: none; margin-top: 30px;">
			<table width=100% cellpadding=0 cellspacing=0 border=0 ID="Table1">
				<tr>
					<td width=100%><img src="./../images/spacer.gif" height=1 width=5 border=0></td>
					<td><input type=reset name="btnCancel" value="Cancel" id="btnCancel"></td>
					<td><img src="./../images/spacer.gif" height=1 width=5 border=0></td>
					<td align=right><input type=submit name="btnCommit" value=" Submit " id="btnCommit"></td>
				</tr>
			</table>
		</div>
	</div>

	</form>
</div>

<script language="javascript">
//	printEvaluator();
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

%>