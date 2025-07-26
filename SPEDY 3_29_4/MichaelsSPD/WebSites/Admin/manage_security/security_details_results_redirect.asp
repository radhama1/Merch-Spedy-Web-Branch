<%@ LANGUAGE=VBSCRIPT%>
<%
'==============================================================================
' Author: Ken Wallace, Principal - Ken Wallace Design
'==============================================================================
Option Explicit
Response.Buffer = True
Response.Expires = -1441 
%>
<!--#include file="./../app_include/checkQueryID.asp"-->
<!--#include file="./../app_include/smartValues.asp"-->
<!--#include file="./../app_include/smartStringConcat.asp"-->
<%
Dim querystring
Dim SmartStr, i

'Get only the items that are not empty to build the querystring
Set SmartStr = New StrConCatArray
if Request.Form.Count <= 0 then
	for i = 1 to Request.QueryString.Count
		if Len(Trim(SmartValues(Request.QueryString.Item(i), "CStr"))) > 0 then
			if i > 1 then
				SmartStr.Add("&" & Request.QueryString.Key(i) & "=" & Request.QueryString.Item(i))
			else
				SmartStr.Add(Request.QueryString.Key(i) & "=" & Request.QueryString.Item(i))
			end if
		end if
	next
else
	for i = 1 to Request.Form.Count
		if Len(Trim(SmartValues(Request.Form.Item(i), "CStr"))) > 0 then
			if i > 1 then
				SmartStr.Add("&" & Request.Form.Key(i) & "=" & Request.Form.Item(i))
			else
				SmartStr.Add(Request.Form.Key(i) & "=" & Request.Form.Item(i))
			end if
		end if
	next
end if
querystring = SmartStr.Value
Set SmartStr = Nothing

'Remove any & in the beginning of the querystring
if Len(querystring) > 0 then
	if left(querystring, 1) = "&" then
		querystring = right(querystring, len(querystring) - 1)
	end if
end if
Response.Redirect("security_user_details.asp?" & querystring)
%>