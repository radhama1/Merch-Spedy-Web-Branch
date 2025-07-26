<%@ LANGUAGE=VBSCRIPT%>
<%
'==============================================================================
' Author: Ken Wallace, Principal - Ken Wallace Design
'==============================================================================
Option Explicit
Response.Buffer = True
Response.Expires = -1441
%>
<!--#include file="./../app_include/stripHTML.asp"-->
<!--#include file="./../app_include/SmartValues.asp"-->
<!--#include file="./../app_include/checkQueryID.asp"-->
<%
Dim objConn, objRec, SQLStr, connStr
Dim showDetail
Dim Tax_ID
Dim selectedTab

selectedTab = Trim(Request("tab"))
if IsNumeric(selectedTab) and Trim(selectedTab) <> "" then
	selectedTab = CInt(selectedTab)
else
	if IsNumeric(Session.Value("TAXWIZARD_EDITPANE_SELECTEDTAB")) and Trim(Session.Value("TAXWIZARD_EDITPANE_SELECTEDTAB")) <> "" then
		selectedTab = Session.Value("TAXWIZARD_EDITPANE_SELECTEDTAB")
	else
		selectedTab = 1
	end if
end if
Session.Value("TAXWIZARD_EDITPANE_SELECTEDTAB") = selectedTab

showDetail = CBool(checkQueryID(Request("showdetail"), 0))
Tax_ID = CInt(checkQueryID(Request("tid"), 0))

Set objConn = Server.CreateObject("ADODB.Connection")
Set objRec = Server.CreateObject("ADODB.RecordSet")

function writeTabImgSuffix(tabOrdinal)
	Dim strImgSuffix
	strImgSuffix = "_off"

	'pass the zero-based ordinal of the requested tab
	if IsNumeric(tabOrdinal) and not IsNull(tabOrdinal) and tabOrdinal <> "" then
		if CInt(selectedTab) = CInt(tabOrdinal) then
			strImgSuffix = "_on"
		end if
	end if

	writeTabImgSuffix = strImgSuffix
end function

connStr = Application.Value("connStr")
objConn.Open connStr
%>
<html>
<head>
	<title>View All Content</title>
	<style type="text/css">
	<!--
		A {text-decoration: none; color: #000000; cursor: hand;}
		A:HOVER {text-decoration: underline; color: #0000ff; cursor: hand;}
		.rover {background-color: #ffff99}
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
		}
  	//-->
	</style>
	<script language="javascript" src="../app_include/selectrow.js"></script><!--row highlighting-->
	<script language="javascript" src="../app_include/lockscroll.js"></script><!--locked headers code-->
	<script language=javascript>
	<!--
	
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
	
	var boolShowFrameNextClick = false;
	var rowLayout = "200,*";
		
	function toggleFrameSize(boolShow)
	{
		if (boolShow == true)
		{
			resizeFrame(rowLayout, 'MainTaxWizardListFrame', parent.parent.frames);
			boolShowFrameNextClick = false;
			resizeBar.src = "./images/resize_frame_3_dn.gif";
		}
		else
		{
			rowLayout = parent.parent.frames.document.getElementById('MainTaxWizardListFrame').rows;
			resizeFrame('*,10', 'MainTaxWizardListFrame', parent.parent.frames);
			boolShowFrameNextClick = true;
			resizeBar.src = "./images/resize_frame_3_up.gif";
		}
	}
	
	function closeFrame()
	{
		resizeFrame('*,0', 'MainTaxWizardListFrame', parent.parent.frames);
		boolFrameClosed = true;
	}
	
	function switchTab(tabID)
	{
		document.location = "tax_wizard_details_header.asp?tab=" + tabID + "&showdetail=1&tid=<%=Tax_ID%>";
	}
	
	function loadDetailsScreen(tabID)
	{
		var targetLocation = "";

		switch(tabID)
		{
			case 1:
				targetLocation = "tax_wizard_questions_frm.asp?tid=<%=Tax_ID%>";
				break;

			default:
				targetLocation = "./../app_include/blank_cccccc.html";
		}
		parent.frames["EditPaneDetailsFrame"].document.location = targetLocation;		
	}
	
	//-->
	</script>
	<style type="text/css">
	<!--
		A {text-decoration: none; cursor: hand;}
		A:HOVER {text-decoration: underline; cursor: hand;}
		BODY
		{
			cursor: default;
		}
		.navTab
		{
			cursor: hand;
		}
		.titleText
		{
			font-family: Arial, Helvetica, Sans-Serif;
			font-size: 16px;
			font-weight: bold;
			line-height: 18px;
			color: #fff;
		}
	//-->
	</style>
</head>
<body bgcolor="333333" topmargin=0 leftmargin=0 rightmargin=0 marginheight=0 marginwidth=0 onLoad="loadDetailsScreen(<%=selectedTab%>)"><!-- oncontextmenu="return false;">-->

<%
if showDetail and Tax_ID > 0 then
	SQLStr = "sp_SPEDY_TaxWizard_GetRecord " & Tax_ID
	objRec.Open SQLStr, objConn, adOpenStatic, adLockReadOnly, adCmdText
	if not objRec.EOF then
%>
<table cellpadding=0 cellspacing=0 onSelectStart="return false" border=0 width=100%>
	<tr><td bgcolor=ffffff><img src="./images/spacer.gif" height=1 width=1></td></tr>
	<tr><td bgcolor=cccccc><img src="./images/spacer.gif" height=1 width=1></td></tr>
	<tr><td bgcolor=cccccc width=100% align=center valign=top><a href="javascript: void(0);" onClick="toggleFrameSize(boolShowFrameNextClick); return false;" title="Show/Hide Details for Tax UDA <%=SmartValues(objRec("Tax_UDA_Number"), "CInt")%>"><img id="resizeBar" name="resizeBar" src="./images/resize_frame_3_dn.gif" border=0></a></td></tr>
	<tr><td bgcolor=cccccc><img src="./images/spacer.gif" height=2 width=1></td></tr>
	<tr>
		<td>
			<table width=100% cellpadding=0 cellspacing=0 border=0>
				<tr>
					<td>
						<table cellpadding=0 cellspacing=0 border=0>
							<tr bgcolor=333333>
								<td><img src="./images/spacer.gif" height=28 width=20 border=0></td>
								<td>
									<div id="editpane_page_title" name="editpane_page_title" class="titleText">
									Tax UDA&nbsp;#<%=SmartValues(objRec("Tax_UDA_Number"), "CInt")%> - <%=SmartValues(objRec("Tax_UDA_Description"), "CStr")%>
									</div>
								</td>
							</tr>
						</table>
					</td>
				</tr>
				<tr>
					<td>
						<table width=100% cellpadding=0 cellspacing=0 border=0>
							<tr bgcolor=333333>
								<td><img src="./images/spacer.gif" height=1 width=20 border=0></td>
								<td><a href="tax_wizard_details_header.asp?tab=1&showdetail=1&tid=<%=Tax_ID%>" onClick="switchTab(1); return false;"><img name="navTab" class="navTab" id="itemlistTab" src="./images/tab_spedy_taxquestions<%=writeTabImgSuffix(1)%>.gif" height=12 width=100 border=0 alt="tax questions" onMouseOver="window.status='';return true;" onMouseOut="window.status='';return true;"></a></td>
								<td><img src="./images/spacer.gif" height=1 width=4 border=0></td>
								<td width=100%><img src="./images/spacer.gif" height=1 width=20 border=0></td>
							</tr>
						</table>
					</td>
				</tr>
			</table>
		</td>
	</tr>
</table>


<%
	end if
	objRec.Close
end if
%>

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

%>