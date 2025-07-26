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

Dim objConn, connStr, i
Dim objRec, objRec2, SQLStr
Dim elementID, Website_Template_ID
Dim Element_ShortTitle, Element_CustomHTMLTitle, DisplayInNav, DisplayInSearchResults

elementID = Request("tid")
if IsNumeric(elementID) then
	elementID = CInt(elementID)
else
%>
<script language="javascript">
	parent.window.close();
</script>
<%
end if

Set objConn = Server.CreateObject("ADODB.Connection")
Set objRec = Server.CreateObject("ADODB.RecordSet")
connStr = Application.Value("connStr")
objConn.Open connStr

Dim newNavString
SQLStr = "sp_websites_admin_climbladder " & elementID & ", " & CInt(Session.Value("websiteID")) & ", 1"
Set objRec = objConn.Execute(SQLStr)
if not objRec.EOF then
	if not IsNull(objRec(0)) then
		newNavString = Trim(objRec(0))
	end if
end if
objRec.Close

if Request.Form.Count > 0 then

	SQLStr = "sp_websites_admin_content_by_elementID " & elementID & ", " & Session.Value("websiteID") & ", 1"
	objRec.Open SQLStr, objConn, adOpenStatic, adLockOptimistic, adCmdText
	if not objRec.EOF then
	
		if len(Trim(Request.Form("Element_ShortTitle"))) > 0 then
			objRec("Element_ShortTitle") = Trim(Request.Form("Element_ShortTitle"))
		end if
		if len(Trim(Request.Form("Element_CustomHTMLTitle"))) > 0 then
			objRec("Element_CustomHTMLTitle") = Trim(Request.Form("Element_CustomHTMLTitle"))
		end if
		objRec("DisplayInNav") = CBool(Request.Form("DisplayInNav"))
		objRec("DisplayInSearchResults") = CBool(Request.Form("DisplayInSearchResults"))
		objRec.Update
	
	end if
	objRec.Close

	Website_Template_ID = CInt(Trim(Request.Form("Website_Template_ID")))
	if Website_Template_ID <> 0 then
		SQLStr = "SELECT * FROM Website_Template_Element WHERE Website_Element_ID = '0" & elementID & "'"
		objRec.Open SQLStr, objConn, adOpenKeyset, adLockOptimistic, adCmdText

			if objRec.EOF then
				objRec.AddNew
			end if
	
			objRec("Website_Template_ID") = Website_Template_ID
			objRec("Website_Element_ID") = elementID
	
		objRec.Update
		objRec.Close
	else
		SQLStr = "DELETE FROM Website_Template_Element WHERE Website_Element_ID = '0" & elementID & "'"
		Set objRec = objConn.Execute(SQLStr)
	end if
	
%>
<script language="javascript">
//	var myFrameSetRef = new Object(parent.window.opener.parent.parent.frames['DetailFrameWrapper'].frames['DetailFrame']);
//	if (typeof(myFrameSetRef == 'object'))
//	{
//		myFrameSetRef.document.location = "./website_details.asp?open=<%=newNavString%>";
//	}
	
	//we're all done, so leave...
	parent.window.close();
</script>
<%
else
	SQLStr = "sp_websites_admin_content_by_elementID " & elementID & ", " & Session.Value("websiteID") & ", 1"
	objRec.Open SQLStr, objConn, adOpenStatic, adLockOptimistic, adCmdText
	if not objRec.EOF then
	
		if not IsNull(objRec("Element_ShortTitle")) then
			Element_ShortTitle = objRec("Element_ShortTitle")
		end if
		if not IsNull(objRec("Element_CustomHTMLTitle")) then
			Element_CustomHTMLTitle = objRec("Element_CustomHTMLTitle")
		end if
		
		DisplayInNav = CBool(objRec("DisplayInNav"))
		DisplayInSearchResults = CBool(objRec("DisplayInSearchResults"))
	
	end if
	objRec.Close
	
	Website_Template_ID = 0
	SQLStr = "sp_websites_template_returnWebsiteTemplateID_by_websiteElementID " & elementID
	objRec.Open SQLStr, objConn, adOpenStatic, adLockOptimistic, adCmdText
	if not objRec.EOF then
		if not IsNull(objRec("Website_Template_ID")) then
			Website_Template_ID = objRec("Website_Template_ID")
		end if
	end if
	objRec.Close
end if
%>
<html>
<head>
	<title>Settings</title>
</head>
<body bgcolor="cccccc" topmargin=5 leftmargin=5 marginheight=5 marginwidth=5>

<form name="theForm" action="element_settings.asp" method=POST>
<table width=100% cellpadding=0 cellspacing=0 border=0>
	<tr>
		<td>
			<table cellpadding=0 cellspacing=0 border=0>
				<tr>
					<td colspan=3>
						<font style="font-family:Arial, Helvetica;font-size:12px;color:#000000">
						Navigation Name
						</font>
					</td>
				</tr>
				<tr><td colspan=3><input type="text" name="Element_ShortTitle" value="<%=Element_ShortTitle%>" size=30 maxlength=500 style="width: 250px;"></td></tr>
				<tr><td><img src="./images/spacer.gif" height=10 width=1></td></tr>
				<tr>
					<td colspan=3>
						<font style="font-family:Arial, Helvetica;font-size:12px;color:#000000">
						Custom HTML Title
						</font>
					</td>
				</tr>
				<tr><td colspan=3><input type="text" name="Element_CustomHTMLTitle" value="<%=Element_CustomHTMLTitle%>" size=30 maxlength=500 style="width: 250px;"></td></tr>
				<tr><td><img src="./images/spacer.gif" height=10 width=1></td></tr>
				<tr>
					<td colspan=3>
						<font style="font-family:Arial, Helvetica;font-size:12px;color:#000000">
						Template
						</font>
					</td>
				</tr>
				<tr>
					<td colspan=3>
						<select name="Website_Template_ID" style="width: 250px;">
							<option value="0">-- Unassigned -- 
							<%
							SQLStr = "sp_websites_template_list_current"
							objRec.Open SQLStr, objConn, adOpenForwardOnly, adLockReadOnly, adCmdText
							if not objRec.EOF then
								Do until objRec.EOF
								%>
							<option value="<%=objRec("ID")%>"<%if Website_Template_ID = CInt(objRec("ID")) then Response.Write " SELECTED"%>><%=objRec("Template_Name")%>
								<%
									objRec.MoveNext
								Loop
							end if
							objRec.Close
							%>
						</select>
					</td>
				</tr>
				<tr><td><img src="./images/spacer.gif" height=10 width=1></td></tr>
				<tr>
					<td><input type=checkbox name="DisplayInNav" value="1"<%if DisplayInNav then Response.Write " CHECKED" end if%>></td>
					<td><img src="./../images/spacer.gif" height=1 width=5 border=0></td>
					<td nowrap>
						<font style="font-family:Arial, Helvetica;font-size:12px;color:#000000">
						<a href="javascript: void(0); document.theForm.DisplayInNav.click();" style="color:#000000;text-decoration:none;">Display in Site Navigation</a>
						</font>
					</td>
				</tr>
				<tr>
					<td><input type=checkbox name="DisplayInSearchResults" value="1"<%if DisplayInSearchResults then Response.Write " CHECKED" end if%>></td>
					<td><img src="./../images/spacer.gif" height=1 width=5 border=0></td>
					<td nowrap>
						<font style="font-family:Arial, Helvetica;font-size:12px;color:#000000">
						<a href="javascript: void(0); document.theForm.DisplayInSearchResults.click();" style="color:#000000;text-decoration:none;">Display in Search Results</a>
						</font>
					</td>
				</tr>
			</table>
		</td>
	</tr>
	<tr><td><img src="./images/spacer.gif" height=10 width=1></td></tr>
	<tr>
		<td align=center>
			<table cellpadding=0 cellspacing=0 border=0>
				<tr>
					<td><input type=button name="btnCancel" value="Cancel" onClick="javascript: void(0); parent.window.close();"></td>
					<td><img src="./../images/spacer.gif" height=1 width=20 border=0></td>
					<td align=right><input type=button name="btnCommit" value="Save and Close" onClick="document.theForm.btnCommit.disabled=true;document.theForm.btnCommit.value='Working...';document.theForm.btnCancel.disabled=true;document.theForm.submit();"></td>
				</tr>
			</table>
		</td>
	</tr>
</table>
<input type=hidden name="tid" value="<%=elementID%>">
</form>

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