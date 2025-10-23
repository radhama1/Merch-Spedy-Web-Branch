<%@ Control Language="vb" AutoEventWireup="false" CodeFile="DisplayContent.ascx.vb" Inherits="DisplayContent" %>
<TABLE id="Table1" cellSpacing="0" cellPadding="0" border="0">
	<TR>
		<TD class="bodyText" style="color:#999;">
		<!-- <a href="default.asp" class="navTrail">Home</a>&nbsp;&gt;&nbsp;<%=strNavTrail%> -->
		</td>
	</TR>
	<tr>
		<td valign="top">
			<table width="100%" cellpadding="0" cellspacing="0" border="0">
				<tr>
					<td colspan="2"><img src="./images/spacer.gif" width="1" height="10"></td>
				</tr>
				<tr>
					<td colspan="2" class="bodyText">
						<div id="contentSummaryDiv" class="bodyText">
							<%=strTopicSummary.Replace("http://spd.michaels.com/", "/")%>
						</div>
					</td>
				</tr>
				<tr>
					<td colspan="2"><img src="./images/spacer.gif" width="1" height="10"></td>
				</tr>
				<%
					'Write LINK doctype
					if intTopicType = 4 and not bolOpenInNewWindow then
						Response.Redirect(strLinkURL)
					elseif intTopicType = 4 and bolOpenInNewWindow then
					%>
				<tr>
					<td colspan="2"><img src="./images/spacer.gif" width="1" height="10"></td>
				</tr>
				<tr>
					<td colspan="2" class="bodyText">
						<div id="contentWebLinkDiv" class="bodyText">
							<a href="<%=strLinkURL%>" onClick="javascript:getLink();return false;"><img src="images/icon-popup.gif" border="0" width="13" height="13" alt="Open this page in a new window."></a>&nbsp;&nbsp;<a href="<%=strLinkURL%>" onClick="javascript:getLink();return false;" ><b><%=strTopicName%></b></a>
						</div>
						<script language="javascript">
							<!--
								function launchLinkWin(myLoc, myName, myWidth, myHeight)
								{
										var myFeatures = "directories=no,dependent=no,width=" + myWidth + ",height=" + myHeight + ",hotkeys=no,location=yes,menubar=yes,resizable=yes,screenX=10,screenY=10,scrollbars=yes,titlebar=yes,toolbar=yes,status=yes";
										var newWin = window.open(myLoc, myName, myFeatures);
										newWin.focus();
								}
								function getLink()
								{
									launchLinkWin("<%=strLinkURL%>", "newLinkWin<%=TopicID%>", 800, 600)
								}
								getLink();
							//-->
						</script>
					</td>
				</tr>
				<tr>
					<td colspan="2"><img src="./images/spacer.gif" width="1" height="10"></td>
				</tr>
				<%
					'Write FILE doctype
					elseif intTopicType = 3 then
					%>
				<tr>
					<td colspan="2"><img src="./images/spacer.gif" width="1" height="10"></td>
				</tr>
				<tr>
					<td colspan="2" class="bodyText">
						<div id="contentFileLinkDiv" class="bodyText">
							<script language="javascript">
								<!--
									function launchFileWin(myLoc, myName, myWidth, myHeight)
									{
											var myFeatures = "directories=no,dependent=no,width=" + myWidth + ",height=" + myHeight + ",hotkeys=no,location=no,menubar=no,resizable=yes,screenX=10,screenY=10,scrollbars=yes,titlebar=no,toolbar=no,status=no";
											var newWin = window.open(myLoc, myName, myFeatures);
											newWin.focus();
									}
									function getFile()
									{
										launchFileWin("getfile.asp?tid=<%=TopicID%>&fn=<%=Server.URLEncode(strTopicName)%>", "newFileWin<%=TopicID%>", 800, 600, "hotkeys=no,location=no,menubar=no,resizable=yes,screenX=10,screenY=10,scrollbars=yes,titlebar=no,toolbar=no,status=yes");
									}
								//-->
							</script>
							<table width="100%" cellpadding="0" cellspacing="0" border="0">
								<tr>
									<td valign="top" class="subheaderText" style="TEXT-ALIGN: left">
										<b>File Download</I></b>
									</td>
								</tr>
								<tr>
									<td valign="top" class="bodyText">
										Click the links below to View or Download this file.
									</td>
								</tr>
								<tr>
									<td><img src="./images/spacer.gif" width="1" height="5" border="0"></td>
								</tr>
								<tr>
									<td>
										<table width="100%" cellpadding="0" cellspacing="0" border="0">
											<tr>
												<td>
													<table cellpadding="0" cellspacing="0" border="0">
														<%
															if Len(strFilename) > 0 then
																Select Case Mid(LCase(strFilename), InStrRev(strFilename, "."), Len(strFilename))
																	Case ".pdf", ".doc", ".xls", ".gif", ".jpg", ".htm", ".html"
															%>
														<tr>
															<td><img src="./images/spacer.gif" width="1" height="1" border="0"></td>
														</tr>
														<tr>
															<td><img src="./images/spacer.gif" width="10" height="1" border="0"></td>
															<td valign="top"><a href="javascript:void(0);getFile();"><img src="./images/icon-popup.gif" border="0"></a></td>
															<td><img src="./images/spacer.gif" width="5" height="1" border="0"></td>
															<td class="bodyText">
																<a href="getfile.asp?tid=<%=TopicID%>&amp;fn=<%=Server.URLEncode(strTopicName)%>" onClick="javascript:getFile();return false;" style="TEXT-DECORATION: none">
																	Open&nbsp;in&nbsp;New&nbsp;Window</a>
															</td>
														</tr>
														<tr>
															<td><img src="./images/spacer.gif" width="1" height="1" border="0"></td>
														</tr>
														<%
																End Select
															end if
															%>
														<tr>
															<td><img src="./images/spacer.gif" width="10" height="1" border="0"></td>
															<td valign="top"><a href="getfile_contents.asp?tid=<%=TopicID%>&amp;dl=1" ><img src="./images/icodownl.gif" border="0"></a></td>
															<td><img src="./images/spacer.gif" width="5" height="1" border="0"></td>
															<td class="bodyText">
																<a href="getfile_contents.asp?tid=<%=TopicID%>&amp;dl=1" style="TEXT-DECORATION: none">
																	Download</a>
															</td>
														</tr>
													</table>
												</td>
												<td><img src="./images/spacer.gif" width="10" height="1" border="0"></td>
												<td bgcolor="#cccccc"><img src="./images/spacer.gif" width="1" height="1" border="0"></td>
												<td><img src="./images/spacer.gif" width="10" height="1" border="0"></td>
												<td width="100%" valign="top">
													<table cellpadding="0" cellspacing="0" border="0">
														<%
															if Len(strTopicName) > 0 then
															%>
														<tr>
															<td valign="top" class="bodyText">
																File&nbsp;Name:
															</td>
															<td><img src="./images/spacer.gif" width="5" height="1" border="0"></td>
															<td valign="top" class="bodyText">
																<a href="getfile.asp?tid=<%=TopicID%>" style="TEXT-DECORATION: none"><b>
																		<%=strFileName%>
																	</b></a>
															</td>
														</tr>
														<%
															end if
															if dblFileSize > 0  then
															%>
														<tr>
															<td valign="top" class="bodyText">
																File&nbsp;Size:
															</td>
															<td><img src="./images/spacer.gif" width="5" height="1" border="0"></td>
															<td valign="top" class="bodyText">
																<%=FormatNumber(dblFileSize/1024,0,0,0,-1)%>
																KB&nbsp;&nbsp;(<%=FormatNumber(dblFileSize,0,0,0,-1)%>
																bytes)
															</td>
														</tr>
														<%
															end if
															if Len(strFileName) > 0 then
															%>
														<tr>
															<td valign="top" class="bodyText">
																File&nbsp;Type:
															</td>
															<td><img src="./images/spacer.gif" width="5" height="1" border="0"></td>
															<td valign="top" class="bodyText">
																<%=strFileType%>
															</td>
														</tr>
														<%end if%>
													</table>
												</td>
											</tr>
										</table>
									</td>
								</tr>
							</table>
						</div>
					</td>
				</tr>
				<tr>
					<td colspan="2"><img src="./images/spacer.gif" width="1" height="20"></td>
				</tr>
				<%end if%>
			</table>
		</td>
		<td><img src="./images/spacer.gif" width="10" height="1"></td>
	</tr>
	</TD></TR>
</TABLE>
