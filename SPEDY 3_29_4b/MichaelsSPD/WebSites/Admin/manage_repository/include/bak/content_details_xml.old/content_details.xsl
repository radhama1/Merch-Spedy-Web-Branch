<?xml version="1.0"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:param name="sort_column" select="'Date_Created'" />
<xsl:output method="html"/>
<xsl:template match="/">
	<html>
	<head>
		<title>Cool XSLT App</title>
		<script language="javascript" src="./include/selectrow.js"></script><!--row highlighting-->
		<script language="JavaScript" SRC="./include/lockScroll.js"></script><!--Locked Headers Code-->
		<link rel="stylesheet" type="text/css" href="./include/rowcolors.css"/>
	</head>
	<body topmargin="0" leftmargin="0" rightmargin="0" marginheight="0" marginwidth="0">
	<table width="100%" cellpadding="0" cellspacing="0" border="0">
		<form name="theForm" action="boo.asp" method="POST">
		<tr>
			<td width="100%">
				<table cellpadding="0" cellspacing="0" onSelectStart="return false" width="100%" border="0">
					<xsl:for-each select="content/item">
						<xsl:sort select="*[name()=$sort_column]" data-type="text"/>
						<tr onDblClick="checkHighlight(true)" OnClick="checkHighlight(false)" style="line-height:16px; overflow: hidden;">
							<xsl:if test="(position() mod 2 = 0)">
							<xsl:attribute name="bgcolor">#ececec</xsl:attribute>
							</xsl:if>	
							<td><img src="./images/spacer.gif" height="1" width="5" /></td>
							<td><img src="./images/spacer.gif" height="1" width="16" /></td>
							<td><img src="./images/spacer.gif" height="1" width="2" /></td>
							<td valign="top" nowrap="true" style="width: 282px; overflow: hidden;">
								<font style="font-family:Arial, Helvetica;font-size:11px;">
								<xsl:value-of select="Topic_NavName"/>
								</font>
							</td>
							<td><img src="./images/spacer.gif" height="1" width="10" /></td>
							<td valign="top" nowrap="true" style="width: 100px; overflow: hidden;">
								<font style="font-family:Arial, Helvetica;font-size:11px;">
								</font>
							</td>
							<td><img src="./images/spacer.gif" height="1" width="10" /></td>
							<td valign="top" nowrap="true" style="width: 300px; overflow: hidden;">
								<font style="font-family:Arial, Helvetica;font-size:11px;">
								<xsl:value-of select="Type1_FileName"/>
								</font>
							</td>
							<td><img src="./images/spacer.gif" height="1" width="10" /></td>
							<td valign="top" nowrap="true" style="width: 150px; overflow: hidden;">
								<font style="font-family:Arial, Helvetica;font-size:11px;">
								<xsl:value-of select="Date_Last_Modified"/>
								</font>
							</td>
							<td><img src="./images/spacer.gif" height="1" width="10" /></td>
							<td valign="top" nowrap="true" style="width: 150px; overflow: hidden;">
								<font style="font-family:Arial, Helvetica;font-size:11px;">
								<xsl:value-of select="Date_Created"/>
								</font>
							</td>
							<td width="100%"><img src="./images/spacer.gif" height="1" width="5" /></td>
						</tr>
					</xsl:for-each>
				</table>
			</td>
		</tr>
		</form>
	</table>
	<script language="javascript">
	parent.frames["DetailFrameHdr"].document.location = "content_details_header.asp";
	</script>
	</body>
	</html>
</xsl:template>
</xsl:stylesheet>