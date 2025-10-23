<%@ LANGUAGE=VBSCRIPT%>
<%
'==============================================================================
' Author: Ken Wallace, Principal - Ken Wallace Design
'==============================================================================
Option Explicit
Response.Buffer = True
Response.Expires = -1441 

Dim objConn, objRec, SQLStr, connStr
Dim i, CategoryID
Dim xmlSource, xslStyleSheet
Dim objStylesheetParam

CategoryID = Trim(Request("cid"))
if IsNumeric(CategoryID) then
	CategoryID = CInt(CategoryID)
else
	CategoryID = 0
end if

Set objConn = Server.CreateObject("ADODB.Connection")
Set objRec = Server.CreateObject("ADODB.RecordSet")

connStr = Application.Value("connStr")
objConn.Open connStr

SQLStr = "sp_repository_content_by_catID_showdefault_lang " & CategoryID
objRec.Open SQLStr, objConn, adOpenStatic, adLockReadOnly, adCmdText
if not objRec.EOF then
	'Output the XML
'	Response.ContentType = "text/xml"
'	Response.Write "<?xml version=""1.0""?>"
'	Response.Write "<?xml-stylesheet type=""text/xsl"" href=""content_details_sortby_filename.xsl""?>"
'	Response.Write ConvertRStoXML2(objRec, "content", "item", 0, 0)
	
	Set xmlSource = Server.CreateObject("MSXML2.FreeThreadedDOMDocument")
	Set xslStyleSheet = Server.CreateObject("MSXML2.FreeThreadedDOMDocument")
	Set objStylesheetParam = Server.CreateObject("MSXML2.FreeThreadedDOMDocument")

	'Load Source XML Document into memory
	xmlSource.async = false
	xmlSource.loadXML(ConvertRStoXML2(objRec, "content", "item", 1, 0))
'	Response.Write xmlSource.xml

	'Load XSL Stylesheet into memory
	xslStyleSheet.async = false
	xslStyleSheet.Load Server.MapPath("content_details.xsl")

	' Change sorting param so the content is sorted correctly...
	Set objStylesheetParam = xslStyleSheet.selectSingleNode("/xsl:stylesheet/xsl:param[@name='sort_column']")
	objStylesheetParam.setAttribute "select", "'Date_Created'"

	' Write out the transformed document
	Response.Write xmlSource.transformNode(xslStyleSheet)
end if
objRec.Close
Call DB_CleanUp

%>
<!--#include file="./include/ConvertRStoXML2.asp"-->
<%

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