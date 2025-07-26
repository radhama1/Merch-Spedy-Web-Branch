<%
'==============================================================================
' Author: Ken Wallace, Principal - Ken Wallace Design
'==============================================================================

sub returnDataWithGetRows(tempConnStr, tempSQLStr, byref resultArray, byref resultDictionary)
'	On Error Resume Next

	'==============================================================================
	' Init Variables
	'==============================================================================
	Dim objGetRowsConn, objGetRowsRec, objTempDictionary, objTempArray
	Dim numCols, numRows, counter
   
	Set objGetRowsConn = Server.CreateObject("ADODB.Connection")
	Set objGetRowsRec = Server.CreateObject("ADODB.RecordSet")
	Set objTempDictionary = Server.CreateObject("Scripting.Dictionary")


	'==============================================================================
	' Open special DB connection
	'==============================================================================
	objGetRowsConn.Open tempConnStr


	'==============================================================================
	' Execute Our SQL Statement
	'==============================================================================
	Set objGetRowsRec = objGetRowsConn.Execute(tempSQLStr)

'	'==============================================================================
'	' Save the Recordset to an XML cache
'	'==============================================================================
'	Dim objXMLResultset
'	Set objXMLResultset = Server.CreateObject("MSXML2.FreeThreadedDOMDocument")
'
'	'Load Source XML Document into memory
'	objXMLResultset.async = false
'	objXMLResultset.loadXML(ConvertRStoXML2(objGetRowsRec, "Tree", "leaf", 1, 0))
'	objXMLResultset.save("c:\temp\test.xml")
'
'	Set objXMLResultset = Nothing


	'==============================================================================
	' Check the viability of the resultset returned from the DB.
	'==============================================================================
	If objGetRowsRec.EOF then
		'return some usable information, to prevent errors
		objTempDictionary.Add "RecordCount", 0
		objTempDictionary.Add "ColCount", 0
		Set resultDictionary = objTempDictionary
	
		'Pick up our toys...
		objGetRowsRec.Close
		objGetRowsConn.Close
		Set objGetRowsRec = Nothing
		Set objGetRowsConn = Nothing
		Set objTempDictionary = Nothing
		
		'and get the hell outta here
		exit sub
	end if


	'==============================================================================
	' Populate dictionary with field names and their respective ordinal positions
	'==============================================================================
	'While we're mucking with this anyway, save ColCount into a variable for later
	numCols = (objGetRowsRec.Fields.count) - 1
	
	'Add Column names to the Dictionary
	for counter = 0 to numCols
		'We add this twice, to enable us to grab the column name only by ordinal, or the opposite.
		objTempDictionary.Add objGetRowsRec(counter).Name, counter
		objTempDictionary.Add "COL_" & CStr(counter), objGetRowsRec(counter).Name
	next


	'==============================================================================
	' grab all the records
	'==============================================================================
	objTempArray = objGetRowsRec.GetRows()
	
	'Since it's handy now, save RecordCount into a variable for later
	numRows = UBound(objTempArray, 2)
	
	'Add RecordCount and ColCount to our Dictionary
	objTempDictionary.Add "RecordCount", CLng(numRows) + 1
	objTempDictionary.Add "ColCount", CLng(numCols)

	
	'==============================================================================
	' Return the recordset data array and also the fieldnames dictionary object
	'==============================================================================
	resultArray = objTempArray
	Set resultDictionary = objTempDictionary


	'==============================================================================
	' Pick up our toys
	'==============================================================================
	objGetRowsRec.close
	objGetRowsConn.close

	Set objGetRowsRec = Nothing
	Set objGetRowsConn = Nothing

	Set objTempDictionary = Nothing
end sub 

'==============================================================================
' Following is an example of how to use this subroutine
'==============================================================================
'	Dim connStr, SQLStr, arDataRows, dictDataCols, rowcounter
'	
'	connStr = Application.Value("connStr")
'	SQLStr = "select * from pubs.dbo.publishers where state='NY'"
'	Set dictDataCols = Server.CreateObject("Scripting.Dictionary")
'
'	Call returnDataWithGetRows(connStr, SQLStr, arDataRows, dictDataCols)
'
'	if dictDataCols("ColCount") > 0 and dictDataCols("RecordCount") > 0 then
'		response.write "<table border='1'><tr>" & vbcrlf
'		for rowcounter = 0 to dictDataCols("RecordCount")
'		      response.write "<tr>" & vbcrlf
'		      response.write "<td valign=top>" & arDataRows(dictDataCols("pubid"), rowcounter) & "</td>" & vbcrlf 
'		      response.write "<td valign=top>" & arDataRows(dictDataCols("Company Name"), rowcounter) & "</td>" & vbcrlf 
'		      response.write "<td valign=top>" & arDataRows(dictDataCols("address"), rowcounter) & "</td>" & vbcrlf 
'		      response.write "<td valign=top>" & arDataRows(dictDataCols("city"), rowcounter) & "</td>" & vbcrlf 
'		      response.write "<td valign=top>" & arDataRows(dictDataCols("state"), rowcounter) & "</td>" & vbcrlf 
'		      response.write "<td valign=top>" & arDataRows(dictDataCols("zip"), rowcounter) & "</td>" & vbcrlf 
'		      response.write "<td valign=top>" & arDataRows(dictDataCols("telephone"), rowcounter) & "</td>" & vbcrlf 
'		      response.write "<td valign=top>" & arDataRows(dictDataCols("fax"), rowcounter) & "</td>" & vbcrlf 
'		      response.write "<td valign=top>" & arDataRows(dictDataCols("comments"), rowcounter) & "</td>" & vbcrlf 
'		      response.write "</tr>" & vbcrlf
'		next
'		response.write "</table>" 
'	end if
'
'	Set arDataRows = Nothing
'	Set dictDataCols = Nothing
'
'==============================================================================
' end example
'==============================================================================
%>