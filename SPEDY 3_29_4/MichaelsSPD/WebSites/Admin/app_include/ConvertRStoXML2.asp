<%
'==============================================================================
' Author: Ken Wallace, Principal - Ken Wallace Design
'==============================================================================

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
''Function:  ConvertRStoXML2()
''Purpose:  Converts a ADO recordset to XML
''Parameters:
''  objRS:						The ADO Recordset object
''  strTopLevelNodeName:		The descriptive name for the top-level node (E.g. customers)
''  strRowNodeName:				The descriptive name for the nodes (E.g. customer)
''  boolIncludePI:				Boolean:  Output a Processing Instruction or not
''	boolExportAsObject:			Export the result XML data as an object, rather than a string
''Return:
''  The XML string or XML object, depending on boolExportAsObject
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

Function ConvertRStoXML2(objRS, strTopLevelNodeName, strRowNodeName, boolIncludePI, boolExportAsObject)
	Dim objXMLDom
	Dim objXMLRoot
	Dim objattTabOrder
	Dim objPI
	Dim Field
 
	Dim aryRows, intCurRowIdx, intCurFieldIdx, intNumFields, intNumRows
	Dim objXMLRow, objXMLField, objXMLFieldName, objXMLFieldValue, objXMLNodeList
	
	'Instantiate the Microsoft XMLDOM.
	Set objXMLDom = Server.CreateObject("MSXML2.FreeThreadedDOMDocument")
	objXMLDom.preserveWhiteSpace = True

	'Create the root element and append it to the XML document.
	Set objXMLRoot = objXMLDom.createElement(strTopLevelNodeName)
	objXMLDom.appendChild objXMLRoot

	'Create the Row and Field elements
	Set objXMLRow = objXMLDom.CreateElement(strRowNodeName)

	'Build the template row by adding all the field names from the Recordset
	For Each Field in objRS.Fields
'		Call objXMLField.SetAttribute("name", Field.Name)
		Set objXMLField = objXMLDom.createElement(Field.Name)
		objXMLRow.appendChild objXMLField

		'Copy the field to give it a new memory address (copy all its children too)
		Set objXMLField = objXMLField.cloneNode(True)
	Next

	'Convert our Recordset to the multi-dimensional array and calculate its bounds
	aryRows = objRS.getRows()

	intNumFields = UBound(aryRows)
	intNumRows = UBound(aryRows, 2)


	'Iterate through the array of data and build the Rows
	For intCurRowIdx = 0 To intNumRows
		'Retrieve all the Field nodes within the Row
		Set objXMLNodeList = objXMLRow.ChildNodes
		
		'Add the data for the fields.
		'We know there's only one child for each Field (the FieldValue node) so the FirstChild property will work fine
		For intCurFieldIdx = 0 To intNumFields
			Set objXMLField = objXMLNodeList.item(intCurFieldIdx)
			
			'xml doesn't do nulls
			If Not IsNull(aryRows(intCurFieldIdx, intCurRowIdx)) Then
				objXMLField.text = aryRows(intCurFieldIdx, intCurRowIdx)
			End If
		Next

		'Build the populated Row
		objXMLRoot.appendChild objXMLRow

		'Copy the current row to give it a new memory address (copy children too)
		Set objXMLRow = objXMLRow.CloneNode(True)
	Next	

	if boolIncludePI then
		Set objPI = objXMLDom.createProcessingInstruction("xml", "version='1.0'")
		objXMLDom.insertBefore objPI, objXMLDom.childNodes(0)
	end if

	if boolExportAsObject then
		Set ConvertRStoXML2 = objXMLDom	'Allows transformations
	else
		ConvertRStoXML2 = objXMLDom.xml
	end if

	'Clean up...
	Set aryRows = Nothing
	Set objXMLDom = Nothing
	Set objXMLRoot = Nothing
	Set objXMLField = Nothing
	Set objattTabOrder = Nothing
	Set objPI = Nothing
End Function
%>