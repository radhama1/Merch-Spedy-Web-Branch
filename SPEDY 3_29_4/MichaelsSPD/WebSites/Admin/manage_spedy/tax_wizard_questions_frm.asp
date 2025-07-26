<%@ LANGUAGE=VBSCRIPT%>
<%
'==============================================================================
' Author: Ken Wallace, Principal - Ken Wallace Design
'==============================================================================
Option Explicit
%>
<!--#include file="./../app_include/_globalInclude.asp"-->
<%
Response.Buffer = True
Response.Expires = -1441


%>
<html>
<head>
	<title>Tax Wizard Questions Frameset</title>
	<style type="text/css">
	<!--
		BODY
		{
			scrollbar-face-color: "#cccccc"; 
			scrollbar-highlight-color: "#cccccc"; 
			scrollbar-shadow-color: "#cccccc";
			scrollbar-3dlight-color: "#cccccc"; 
			scrollbar-arrow-color: "#000000";
			scrollbar-track-color: "#FFFFFF";
			scrollbar-darkshadow-color: "#cccccc";
		}
	//-->
	</style>
</head>
	<%
	If Request("tid") <> "" And IsNumeric(Request("tid")) Then
	%>
	<frameset id="TaxWizardDetailsWrapperFrameset" rows="1,15,*,27,25" border="0" topmargin=0 leftmargin=0 rightmargin=0 bottommargin=0 marginheight=0 marginwidth=0>
		<frame name="blankheaderframe2" src="../app_include/blank_666666.html" scrolling="no" noresize>
		<frameset cols="1,*,1,15" border="0" topmargin=0 leftmargin=0 rightmargin=0 bottommargin=0 marginheight=0 marginwidth=0>
			<frame name="edge_separator" src="../app_include/blank_666666.html" scrolling="no" noresize>
			<frame name="DetailFrameHdr" src="../app_include/blank_999999.html" scrolling="no" noresize><!-- Detail View Header -->
			<frame name="edge_separator" src="../app_include/blank_666666.html" scrolling="no" noresize>
			<frame name="edge_separator" src="../app_include/blank_999999.html" scrolling="no" noresize>
		</frameset>
		<frame name="DetailFrame" src="tax_wizard_questions.asp?tid=<%=Request("tid")%>" scrolling="yes" noresize><!-- Detail View Content -->
		<frame name="PagingNavFrame" src="../app_include/blank_cccccc.html" scrolling="no" frameborder=no noresize>
		<frame name="DetailOptionsFrame" src="tax_wizard_questions_footer.asp?tid=<%=Request("tid")%>" scrolling="no" noresize>
	</frameset>
	<%
	Else
	%>
	<frameset rows="2,*" border="0" topmargin=0 leftmargin=0 rightmargin=0 bottommargin=0 marginheight=0 marginwidth=0>
		<frame name="blankheader" src="../app_include/blank_cccccc.html" scrolling="no" noresize>
		<frame name="DetailFrame" src="../app_include/blank_cccccc.html" scrolling="no" noresize>
	</frameset>
	<%
	End If
	%>

</html>
