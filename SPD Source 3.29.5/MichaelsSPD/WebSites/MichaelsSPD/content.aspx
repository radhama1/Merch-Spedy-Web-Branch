<%@ Register Tagprefix="CORAL" Tagname="Footer" Src="CORALControls/Footer.ascx" %>
<%@ Register Tagprefix="CORAL" Tagname="Header" Src="CORALControls/Header.ascx" %>
<%@ Register Tagprefix="CORAL" Tagname="Leftnav" Src="CORALControls/LeftNav.ascx" %>
<%@ Register Tagprefix="CORAL"  Tagname="Content" Src="CORALControls/DisplayContent.ascx" %>
<%@ Register Tagprefix="CORAL"  Tagname="PortalContent" Src="CORALControls/PortalContent.ascx" %>
<%@ Register Src="~/CORALControls/pageheader.ascx" TagName="pageheader" TagPrefix="uclayout" %>
<%@ page language="vb" autoeventwireup="false" CodeFile="content.aspx.vb" inherits="content" %>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML>
  <HEAD>
		<title> Item Data Management | <% if len(Content.strCustomHTMLTitle)>0 then %><% Response.Write(Content.strCustomHTMLTitle) %><% else %><% Response.Write(Content.strTopicName) %><% end if%>
		</title>
	    <meta http-equiv="X-UA-Compatible" content="IE=EmulateIE10" />
		<meta content="Microsoft Visual Studio .NET 7.1" name="GENERATOR">
		<meta content="Visual Basic .NET 7.1" name="CODE_LANGUAGE">
		<meta content="JavaScript" name="vs_defaultClientScript">
		<meta content="http://schemas.microsoft.com/intellisense/ie5" name="vs_targetSchema">
		<meta name="keywords" content='<%=Session("Website_Keywords") & Content.strDocumentKeywords %>'>
		<meta name="description" content='<%=Session("Website_Abstract") & Content.strDocumentAbstract %>'>
		<meta name="robots" content="all">
		<meta name="rating" content="general">
		<script language="javascript" type="text/javascript">
		function launchNewWin(myLoc, myName, myWidth, myHeight)
		{
				var myFeatures = "directories=no,dependent=no,width=" + myWidth + ",height=" + myHeight + ",hotkeys=no,location=no,menubar=yes,resizable=yes,screenX=100,screenY=100,scrollbars=yes,titlebar=no,toolbar=no,status=no";
				var newWin = window.open(myLoc, myName, myFeatures);
		}
		</script>
		<style type="text/css">
			@import url( global.css ); 
			</style>
	<link rel="stylesheet" href="css/styles.css" type="text/css">
</HEAD>
	<body>
	<div id="sitediv">
		<div id="bodydiv">
			<div id="header">
				<uclayout:pageheader ID="headerControl" RefreshOnUpload="false" runat="server" />
			</div>
			<div id="content">
				<div id="shadowtop"></div>
				<div id="main">
					<div class="spacer"></div>
						<form id="Form1" method="post" runat="server">
							<TABLE WIDTH=100% BORDER=0 CELLPADDING=0 CELLSPACING=0 valign=top>
								<TR><TD valign=top>
									<TABLE cellspacing=0 cellpadding=0 width="200" valign=top bgcolor=EBEBB9>
									<TR>
										<td><IMG SRC="images/spacer.gif" WIDTH=30 HEIGHT=1 ALT=""></td>
										<TD valign=top><BR>
											<CORAL:Leftnav id="LeftNav" runat="server" RecurseLevels="3" RecurseChildren="True" ClassDefault="SiteNavigation" ClassSelected="SiteNavigation_Selected" IconDefault="bullet_336699_off.gif" IconSelected="bullet_000000_on.gif" RootID="0"></CORAL:Leftnav>
										</TD>
									</TR>
									</TABLE>
								</TD><td valign=top WIDTH=100% align=left>
										<TABLE cellspacing=0 cellpadding=0 border=0 valign=top WIDTH=616>
										<TR>
											<td><IMG SRC="images/spacer.gif" WIDTH=16 HEIGHT=1 ALT=""></td>
											<TD width="600" valign=top align=left>
												<CORAL:CONTENT id="Content" runat="server"></CORAL:CONTENT>
												<!-- <CORAL:PORTALCONTENT id="PortalContent" runat="server" ListLinkDelimiter="" ListLinkClass="content_portalList_links" ListType="bullet" ListBodyClass="content_portalList_body" ListTitleClass="content_portalList_title" ContainerDivClass="" ShowEllipses="true" maxNumSubLinks="-1" ShowChildren="true" Scope="local"></CORAL:PORTALCONTENT> -->
											</TD>
										</TR>
										</TABLE>
									</TD>
								</TR>
							</TABLE>
							</form>

					</div>
				</div>
			</div>
		</div>
	</div>
</body>
</HTML>
