<%@ LANGUAGE=VBSCRIPT%>
<%
'==============================================================================
' Author: Ken Wallace, Principal - Ken Wallace Design
' Modified for use by Nova Libra Inc by Ken Wallace 06-02-2005
'==============================================================================
Option Explicit
Response.Buffer = True
Response.Expires = -1441
%>
<!--#include file="./SmartValues.asp"-->
<!--#include file="./checkQueryID.asp"-->
<%
Dim strFormAction
Dim strFormElements, arFormElements, thisFormElement
Dim arThisFormElement, thisFormElementName, thisFormElementValue

strFormAction = SmartValues(Request("formaction"), "CStr")
strFormElements = SmartValues(Request("formelements"), "CStr")
arFormElements = Split(strFormElements, ";")

%>
<html>
<head>
	<title></title>
	<script type="text/javascript" language="javascript">
	
	</script>
</head>
<body bgcolor="ffffff" topmargin=0 leftmargin=0 marginheight=0 marginwidth=0 onLoad="document.theForm.submit();">

<form name="theForm" method="POST" action="<%=strFormAction%>">
	<%
	for each thisFormElement in arFormElements
		thisFormElement = SmartValues(thisFormElement, "CStr")
		arThisFormElement = Split(thisFormElement, ",")
		
		if Len(Trim(thisFormElement)) <= 0 then exit for
		
		thisFormElementName = SmartValues(arThisFormElement(0), "CStr")
		thisFormElementValue = SmartValues(arThisFormElement(1), "CStr")
	%>
	<input type="hidden" name="<%=thisFormElementName%>" value="<%=thisFormElementValue%>">
	<%
	next
	%>
</form>

</body>
</html>
