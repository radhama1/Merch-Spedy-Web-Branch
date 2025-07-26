<%@ LANGUAGE=VBSCRIPT%>
<%
'==============================================================================
' Author: Ken Wallace, Principal - Ken Wallace Design
'==============================================================================
Option Explicit
Response.Buffer = True
Response.Expires = -1441

%>
<!--#include file="./../../app_include/_globalInclude.asp"-->
<%
Dim fieldID
dim wfName, wfsName

wfName = Request.QueryString("p1")
wfsName = Request.QueryString("p2")
%>
<html>
<head>
	<title></title>
	<style type="text/css">
	<!--
		A {text-decoration: none;}
		.titleA	{
		    text-align:center; 
		    color:LightYellow; 
		    font-size:1em; 
		    font-family: Verdana, Arial;
		}
		.titleB {
		    text-align:center; 
		    color:WhiteSmoke; 
		    font-size:1em; 
		    font-family: Verdana, Arial;
		}
		
	//-->
	
	</style>
</head>
<body bgcolor="cccccc" link=0000ff vlink=0000ff topmargin=0 leftmargin=0 marginheight=0 marginwidth=0>
<!--<table width=100% cellpadding=0 cellspacing=0 border=1 align=center>
    
-->
   <div style="background-color:#333333; height:40px; padding:10px 0 10px 0; text-align:center">
        <span class="titleA" >Specify Edit / View Field Specs For:&nbsp;</span>
        <span class="titleB" ><%=wfName %> - <%=wfsName %></span>
    </div>
<!--	    </td>
	</tr>
</table>
-->
</body>
</html>