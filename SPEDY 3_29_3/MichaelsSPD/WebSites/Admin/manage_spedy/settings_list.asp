<%@ LANGUAGE=VBSCRIPT%>
<%
Option Explicit
Response.Buffer = True
Response.Expires = -1441 
%>
<!--#include file="./../app_include/SmartValues.asp"-->
<!--#include file="./../app_include/returnDataWithGetRows.asp"-->
<!--#include file="./../app_include/checkQueryID.asp"-->
<!--#include file="./../app_include/_globalInclude.asp"-->
<%
Dim arRecRows, dictRecCols
Dim rowCounter, curIteration, displayCount', numFound
Dim SQLStr, connStr
Dim strToolTip

Dim taskStr, separatorStr
Dim Setting_ID, Setting_Type

Set dictRecCols	= Server.CreateObject("Scripting.Dictionary")
connStr = Application.Value("connStr")
SQLStr = "SPD_Settings_GetAll"
Call returnDataWithGetRows(connStr, SQLStr, arRecRows, dictRecCols)


%>
<html>
<head>
	<title>View All Content</title>
	
	<script language="javascript">
	
		preloadImgs();
		function preloadImgs()
		{
			if (document.images)
			{		
			    
				taskIcon_ImgOn = new Image(16, 16);
				taskIcon_ImgOff = new Image(16, 16);

				taskIcon_ImgOn.src = "./../app_images/tasks_icon_on.gif";
				taskIcon_ImgOff.src = "./../app_images/tasks_icon_off.gif";
				
			}
		}
		
		function hTaskBtn(imgName, boolOn)
		{
			if (document.images) 
			{
				if (boolOn)
				{
					document.images[imgName].src = taskIcon_ImgOn.src;
				}
				else
				{
					document.images[imgName].src = taskIcon_ImgOff.src;
				}
			}
		}
		
		function resizeFrame(newSizeFramesetArgs, what, where)
		{
			if (what == "")
				return false;
			if (newSizeFramesetArgs == "")
				return false;
			
			var parentDoc = new Object();
			if (where)
			{
				parentDoc = where;
			}
			else
			{
				alert(parentDoc + " does not exist!")
			}
			
			if (parentDoc)
			{
				parentDoc.document.getElementById(what).rows = newSizeFramesetArgs;
			}
			else
			{
				alert(parentDoc + " does not exist!")
			}
		}
		
		function closeDetailsFrame()
		{
			resizeFrame('*,0', 'MainCustomFieldRecordListFrame', parent.parent.frames);
			boolFrameClosed = true;
		}
		
		function submitForm(){
			//TODO: Add validation?
			
			document.theForm.submit();
		}

	</script>
</head>
<body bgcolor="ffffff" link="000000" vlink="000000" topmargin=0 leftmargin=0 rightmargin=0 marginheight=0 marginwidth=0 style="overflow-y: hidden" >

<form name="theForm" action="settings_list_work.asp" method="POST">
<table width="100%" cellpadding=0 cellspacing=0 border=0>
	<tr>
		<td width="100%">
			<%
			rowCounter = 0
			Dim isPurgeSetting
			isPurgeSetting = False
			
			if dictRecCols("ColCount") > 0 and dictRecCols("RecordCount") > 0 then
			%>
			<div style="margin-top: 30px; margin-left: 30px;height: 100%;">
				<h3>Purge Settings</h3>
				<table cellpadding=1 cellspacing=1 border=0>
			<%
				for rowCounter = 0 to dictRecCols("RecordCount") - 1
					if rowCounter >= dictRecCols("RecordCount") then exit for
					
					Setting_ID = SmartValues(arRecRows(dictRecCols("ID"), rowCounter), "CInt")
					Setting_Type = SmartValues(arRecRows(dictRecCols("Setting_Type"), rowCounter), "CInt")
					If Setting_Type = 1 Then
						isPurgeSetting = True
			%>
				<tr>
					<td valign="middle" nowrap><font style="font-family:Arial, Helvetica;font-size:11px;"><%=SmartValues(arRecRows(dictRecCols("Name"), rowCounter), "CStr")%>:</font>
					<td style="width: 20px">&nbsp;</td>
					<td><input type="text" id="txtValue_<%=Setting_ID%>" name="txtValue_<%=Setting_ID%>" value="<%=SmartValues(arRecRows(dictRecCols("Value"), rowCounter), "CStr")%>" size="100"/></td>
				</tr>
			<%
					End If
				Next
				
				If Not isPurgeSetting Then
					%>
				<tr>
					<td>No purge Settings exist.</td>
				</tr>
					<%
				End If				
			%>
				</table>
			</div>
			
			<div style="position: absolute;bottom: 10px; height: 40px; margin-top: 40px;">
				<input id="btnSave" type="Button" value="Save" style="margin-left: 20px" onclick="submitForm();"/>
			</div>
			<%
			else
			%>
				<div style="margin-left: 20px;margin-top: 20px;">
				No settings exist.  Please populate the Settings table with data.
				</div>
			<%
			end if
			%>
		</td>
	</tr>
</table>
</form>
</body>
</html>
<%
Set dictRecCols = Nothing
%>