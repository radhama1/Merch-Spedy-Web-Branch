<%@ LANGUAGE=VBSCRIPT%>
<%
'==============================================================================
' Author: Ken Wallace, Principal - Ken Wallace Design
'==============================================================================
Option Explicit
Response.Buffer = True
Response.Expires = -1441
%>
<!--#include file="./../app_include/_globalInclude.asp"-->
<%
Dim m_CurrentUserGUID, m_CurrentUserID, m_CurrentScopeConstant, m_CurrentPrivilegedObjectID

m_CurrentUserGUID				= SmartValues(Request("g"), "CStr")
m_CurrentUserID					= checkQueryID(Request("u"), checkQueryID(Session.Value("UserID"), 0))
m_CurrentScopeConstant			= SmartValues(Request("c"), "CStr")
m_CurrentPrivilegedObjectID		= checkQueryID(Request("o"), 0)

Dim Security
Set Security = New cls_Security

Security.CurrentUserID				= m_CurrentUserID
Security.CurrentScopeConstant		= m_CurrentScopeConstant
Security.CurrentPrivilegedObjectID	= m_CurrentPrivilegedObjectID

if Len(Trim(m_CurrentUserGUID)) > 0 Then
	Security.CurrentUserGUID		= m_CurrentUserGUID
end if

Security.Load()

Response.ContentType = "text/xml"

Response.Write Security.XMLSource

Response.Flush
Response.End

Set Security = Nothing
%>