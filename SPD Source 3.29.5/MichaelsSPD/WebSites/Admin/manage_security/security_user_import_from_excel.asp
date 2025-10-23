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
<html>
<head>
	<title></title>
	<script language="javascript" src="./../app_include/prototype/prototype.js"></script>
	<script language="javascript" src="./../app_include/evaluator.js"></script>
	<style type="text/css">
		<!--#include file="./../app_include/global.css"-->

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
		
		.invalidDepts th {
			text-align: left;
			font-size: 16px; 
			line-height: 26px; 
			color: #333;
			font-weight: bold;
			white-space: nowrap;
			border-bottom: solid #000 2px;
			padding: 3px 5px 3px 3px;
		}
		.invalidDepts td {
			font-size: 12px;
			color: #333;
			padding: 3px 3px 2px 3px;
			border-bottom: solid #000 1px;
		}

	</style>
	<script language="javascript">
		function DoUnload() {
		
			//Set a reference to the Details frame in the frameset...
			var myFrameSetRef = new Object(window.opener.parent.frames['WorkspaceFrame'].frames['PagingNavFrame']);			

			//If the user hasnt left the framset, then refresh the details screen, otherwise dont worry bout it...
			if (typeof(myFrameSetRef == 'object'))
			{
				myFrameSetRef.changePageSize();
			}
		}
	</script>

</head>
<body bgcolor="cccccc" topmargin=0 leftmargin=0 marginheight=0 marginwidth=0 <%If checkQueryID(Session.Value("SECURITYUSER_CUSTOMDATAIMPORT_SUCCESS"), 0) = 1 Then%> onunload="DoUnload();"<%End If%>>

<div class="bodyText" style="margin: 20px;">
	<form name="theForm" action="security_user_import_from_excel_work.asp" method="POST" enctype="multipart/form-data" style="padding:0; margin:0;">
			
	<div id="formContainerDiv" class="" style="width:400px; padding: 0px;">
		<%
		If Len(Trim(Session.Value("SECURITYUSER_CUSTOMDATAIMPORT_MESSAGE"))) > 0 Then%>
		<div id="messageDiv" class="bodyText" style="background: #ffc; padding: 10px; margin-bottom: 20px;">
			<%=Session.Value("SECURITYUSER_CUSTOMDATAIMPORT_MESSAGE")%>	
		</div>
		<%
		Else
		%>
		<div id="fileUploaderDiv" class="" style="margin-top: 10px;">
			<div id="filenameSublabelDiv" class="" style="">Using the Browse button, choose the CSV file you wish to upload.</div>
			<div id="filenameDiv" class="" style="margin-top: 10px;">
				<input type="file" size=50 maxlength=1024 id="selectedFileName" name="selectedFileName" value="" style="width: 400px;">
			</div>
			<div id="samplefileDiv" class="" style="color: #333; font-size: 10px; margin-top: 2px;">Need a <a href="./security_user_export_to_excel.asp?template=1" onMouseOver="window.status='';return true;" onMouseOut="window.status='';return true;">sample CSV file</a>?&nbsp;&nbsp;
		</div>
		<div id="formControlsDiv" class="" style="margin-top: 30px;">
			<table width=100% cellpadding=0 cellspacing=0 border=0 ID="Table1">
				<tr>
					<td width=100%><img src="./../images/spacer.gif" height=1 width=5 border=0></td>
					<td><input type=button name="btnCancel" value="Cancel" id="btnCancel" onclick="self.close();"></td>
					<td><img src="./../images/spacer.gif" height=1 width=5 border=0></td>
					<td align=right><input type=submit name="btnCommit" value=" Submit " id="btnCommit"></td>
				</tr>
			</table>
		</div>
		<%
		End If
		Session.Contents.Remove("SECURITYUSER_CUSTOMDATAIMPORT_SUCCESS")
		Session.Contents.Remove("SECURITYUSER_CUSTOMDATAIMPORT_MESSAGE")
		%>
		<script language="javascript">
			//printEvaluator();
		</script>
	</div>

	</form>
</div>
</body>
</html>