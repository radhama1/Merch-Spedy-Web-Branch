<%@ LANGUAGE=VBSCRIPT%>
<%
'==============================================================================
' Author: Ken Wallace, Principal - Ken Wallace Design
'==============================================================================
Option Explicit
%>
<!--#include file="./../../app_include/_globalInclude.asp"-->
<%
Response.Buffer = True
Response.Expires = -1441
%>
<html>
<head>
	<title>Choose File</title>
	<script language=javascript>
	<!--
		function doSubmit()
		{
			document.theForm.submit();
		}

	//-->
	</script>
</head>
<body bgcolor="cccccc" topmargin=0 leftmargin=0 marginheight=0 marginwidth=0>

<table width=100% cellpadding=0 cellspacing=0 border=0>
	<form name="theForm" action="document_file_work.asp" method="POST" enctype="multipart/form-data">
	<tr>
		<td><img src="./images/spacer.gif" height=1 width=20></td>
		<td width=100%>
			<table width=100% cellpadding=0 cellspacing=0 border=0>
				<tr><td><img src="./images/spacer.gif" height=10 width=1 border=0></td></tr>
				<tr>
					<td>
						<font style="font-family:Arial, Helvetica;font-size:20px;color:#666666">
						<b>Choose File</b>
						</font>
					</td>
				</tr>
				<tr>
					<td>
						<font style="font-family:Arial, Helvetica;font-size:10px;color:#000000">
						Type a filename (including fully qualified path) or click "Browse" to select your file.
						</font>
					</td>
				</tr>
				<tr><td><img src="./images/spacer.gif" height=20 width=1 border=0></td></tr>
				<tr>
					<td>
						<font style="font-family:Arial, Helvetica;font-size:12px;color:#000000">
						<b>Local File Path</b>
						</font>
					</td>
				</tr>
				<tr>
					<td width=100%><input type="file" size=56 maxlength=255 name="selectedFileName" value=""></td>
				</tr>
				<tr>
					<td>
						<font style="font-family:Arial, Helvetica;font-size:10px;color:#333333">
						Example: C:\temp\yourfile.zip
						</font>
					</td>
				</tr>
				<!--
				<tr><td><img src="./images/spacer.gif" height=10 width=1></td></tr>
				<tr>
					<td>
						<table cellpadding=0 cellspacing=0 border=0>
						<tr>
							<td><font style="font-family:Arial, Helvetica;font-size:10px;color:#333333">Create Low Resolution PDF</font></td>
							<td><input type=checkbox name="ConvertPDF" id="ConvertPDF"></td>
						</tr>
						</table>
					</td>
				</tr>
				-->
				<tr><td><img src="./images/spacer.gif" height=30 width=1></td></tr>
				<tr>
					<td>
						<table cellpadding=0 cellspacing=0 border=0>
							<tr>
								<td nowrap=true><input type=button name="undoMe" value=" Cancel " onClick="javascript:self.close();"></td>
								<td width=100%><img src="./images/spacer.gif" height=1 width=20></td>
								<td nowrap=true><td><input type=button name="DoItMan1" value="  Upload Selected File  " onclick="this.disabled = true; this.value='Please Wait...'; doSubmit()"></td></td>
							</tr>
						</table>
					</td>
				</tr>
				<tr></tr>
			</table>
		</td>
		<td><img src="./images/spacer.gif" height=1 width=20></td>
	</tr>
	</form>
</table>

</body>
</html>