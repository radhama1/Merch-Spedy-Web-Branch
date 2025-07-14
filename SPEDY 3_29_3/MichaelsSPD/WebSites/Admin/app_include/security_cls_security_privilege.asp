<%
'==============================================================================
' CLASS: cls_Security_Privilege
' Generated using CodeSmith on Friday, October 14, 2005
' By ken.wallace
'==============================================================================
'
' This object represents properties and methods for interacting with 
' table DriversEdDirect_Dev.dbo.Security_Privilege.  
'
'==============================================================================
Class cls_Security_Privilege
	'Private, class member variable
	Private m_ID
	Private m_Parent_Privilege_ID
	Private m_Scope_ID
	Private m_Privilege_Name
	Private m_Privilege_ShortName
	Private m_Privilege_Summary
	Private m_Constant
	Private m_Advanced
	Private m_SortOrder
	Private m_Date_Last_Modified
	Private m_Date_Created
	Private utils

	Private Sub Class_Initialize()
		Set utils = New cls_Security_UtilityLibrary
	End Sub

	Private Sub Class_Terminate()
		Set utils = Nothing
	End Sub

	'Read the current ID value
	Public Property Get ID()
		ID = CInt(m_ID)
	End Property
	'store a new ID value
	Public Property Let ID(p_Data)
		m_ID = p_Data
	End Property
	'Read the current Parent_Privilege_ID value
	Public Property Get Parent_Privilege_ID()
		Parent_Privilege_ID = CInt(m_Parent_Privilege_ID)
	End Property
	'store a new Parent_Privilege_ID value
	Public Property Let Parent_Privilege_ID(p_Data)
		m_Parent_Privilege_ID = p_Data
	End Property
	'Read the current Scope_ID value
	Public Property Get Scope_ID()
		Scope_ID = CInt(m_Scope_ID)
	End Property
	'store a new Scope_ID value
	Public Property Let Scope_ID(p_Data)
		m_Scope_ID = p_Data
	End Property
	'Read the current Privilege_Name value
	Public Property Get Privilege_Name()
		Privilege_Name = CStr(m_Privilege_Name)
	End Property
	'store a new Privilege_Name value
	Public Property Let Privilege_Name(p_Data)
		m_Privilege_Name = p_Data
	End Property
	'Read the current Privilege_ShortName value
	Public Property Get Privilege_ShortName()
		Privilege_ShortName = CStr(m_Privilege_ShortName)
	End Property
	'store a new Privilege_ShortName value
	Public Property Let Privilege_ShortName(p_Data)
		m_Privilege_ShortName = p_Data
	End Property
	'Read the current Privilege_Summary value
	Public Property Get Privilege_Summary()
		Privilege_Summary = CStr(m_Privilege_Summary)
	End Property
	'store a new Privilege_Summary value
	Public Property Let Privilege_Summary(p_Data)
		m_Privilege_Summary = p_Data
	End Property
	'Read the current Constant value
	Public Property Get Constant()
		Constant = CStr(m_Constant)
	End Property
	'store a new Constant value
	Public Property Let Constant(p_Data)
		m_Constant = p_Data
	End Property
	'Read the current Advanced value
	Public Property Get Advanced()
		Advanced = CBool(m_Advanced)
	End Property
	'store a new Advanced value
	Public Property Let Advanced(p_Data)
		m_Advanced = p_Data
	End Property
	'Read the current SortOrder value
	Public Property Get SortOrder()
		SortOrder = CStr(m_SortOrder)
	End Property
	'store a new SortOrder value
	Public Property Let SortOrder(p_Data)
		m_SortOrder = p_Data
	End Property
	'Read the current Date_Last_Modified value
	Public Property Get Date_Last_Modified()
		Date_Last_Modified = CDate(m_Date_Last_Modified)
	End Property
	'store a new Date_Last_Modified value
	Public Property Let Date_Last_Modified(p_Data)
		m_Date_Last_Modified = p_Data
	End Property
	'Read the current Date_Created value
	Public Property Get Date_Created()
		Date_Created = CDate(m_Date_Created)
	End Property
	'store a new Date_Created value
	Public Property Let Date_Created(p_Data)
		m_Date_Created = p_Data
	End Property

	' Returns a list of ALL privileges, or optionally, returns a list 
	' of all privileges within a given context in a variety of formats
	Public Function All(p_ContextScope, p_outputType)
		Dim SQLStr, rs, arrayout, xmlout

		Const OUTPUT_ARRAY = 0			' Returns an array of object id's
		Const OUTPUT_CONSTANTARRAY = 3	' Returns an array of object constant's
		Const OUTPUT_DICTIONARY = 4		' returns a dictionary, whose keys are the 
										'   object id's and values are object references
		Const OUTPUT_RECORDSET = 1		' Returns a recordset
		Const OUTPUT_XML = 2			' returns an xml document
		
		Select Case LCase(p_outputType)
			Case OUTPUT_ARRAY, OUTPUT_CONSTANTARRAY, OUTPUT_RECORDSET, OUTPUT_XML, OUTPUT_DICTIONARY
				p_outputType = p_outputType
			Case "output_array"
				p_outputType = OUTPUT_ARRAY
			Case "output_constantarray"
				p_outputType = OUTPUT_CONSTANTARRAY
			Case "output_recordset"
				p_outputType = OUTPUT_RECORDSET
			Case "output_xml"
				p_outputType = OUTPUT_XML
			Case "output_dictionary"
				p_outputType = OUTPUT_DICTIONARY
		End Select
		
		if p_outputType = OUTPUT_XML then		
			Set xmlout = Server.CreateObject("MSXML2.FreeThreadedDOMDocument")
			xmlout.async = False
			xmlout.validateOnParse = False
			xmlout.preserveWhitespace = True
			xmlout.resolveExternals = False
			xmlout.loadXML("<?xml version='1.0'?><Root></Root>")
			SQLStr = "sp_security_list_privileges_by_scopeConstant_return_xml '" & p_ContextScope & "'"
			xmlout.selectSingleNode("//Root").appendChild utils.loadXMLFromRS(SQLStr, "Security_Privileges").selectSingleNode("//Security_Privileges")
			Set All = xmlout
			Set xmlout = Nothing
		elseif p_outputType = OUTPUT_RECORDSET then
			SQLStr = "sp_security_list_privileges_by_scopeConstant '" & p_ContextScope & "'"
			Set All = utils.LoadRSFromDB(SQLStr)
		elseif p_outputType = OUTPUT_CONSTANTARRAY then
			SQLStr = "sp_security_list_privileges_by_scopeConstant_return_constantarray '" & p_ContextScope & "'"
			Set rs = utils.LoadRSFromDB(SQLStr)
			if not rs.EOF then
				arrayout = rs("Output_Array")
			end if
			All = arrayout
			Set rs = Nothing
		elseif p_outputType = OUTPUT_DICTIONARY then
			Dim tmpDictionaryOut
			Set tmpDictionaryOut = Server.CreateObject("Scripting.Dictionary")
			SQLStr = "sp_security_list_privileges_by_scopeConstant_return '" & p_ContextScope & "'"
			Set rs = utils.LoadRSFromDB(SQLStr)
			if not rs.EOF then
				Do Until rs.EOF
					Set tmpObject = New cls_Security_Privilege
					tmpObject.Load(rs("ID"))
					tmpDictionaryOut.Add rs("ID"), tmpObject
					Set tmpObject = Nothing
					rs.MoveNext
				Loop
			end if
			All = tmpDictionaryOut
			Set rs = Nothing
			Set tmpDictionaryOut = Nothing
		else ' output the array
			SQLStr = "sp_security_list_privileges_by_scopeConstant_return_array '" & p_ContextScope & "'"
			Set rs = utils.LoadRSFromDB(SQLStr)
			if not rs.EOF then
				arrayout = rs("Output_Array")
			end if
			All = arrayout
			Set rs = Nothing
		end if
	End Function

	'Loads this object's values by loading a record based on the given ID
	Public Function Load(p_ID)
		Dim SQLStr, rs

		SQLStr = "SELECT * FROM Security_Privilege WHERE ID = '0" & CLng(p_ID) & "'"
		Set rs = utils.LoadRSFromDB(SQLStr)

		Select Case rs.recordcount
			Case 1
				m_ID = SmartValues(rs("ID"), "CInt")
				m_Parent_Privilege_ID = SmartValues(rs("Parent_Privilege_ID"), "CInt")
				m_Scope_ID = SmartValues(rs("Scope_ID"), "CInt")
				m_Privilege_Name = SmartValues(rs("Privilege_Name"), "CStr")
				m_Privilege_ShortName = SmartValues(rs("Privilege_ShortName"), "CStr")
				m_Privilege_Summary = SmartValues(rs("Privilege_Summary"), "CStr")
				m_Constant = SmartValues(rs("Constant"), "CStr")
				m_Advanced = SmartValues(rs("Advanced"), "CBool")
				m_SortOrder = SmartValues(rs("SortOrder"), "CStr")
				m_Date_Last_Modified = SmartValues(rs("Date_Last_Modified"), "CDate")
				m_Date_Created = SmartValues(rs("Date_Created"), "CDate")
				Load = m_ID
			Case -1, 0
				err.raise 2, "cls_Security_Privilege", "Error loading class cls_Security_Privilege [Load]: Item was not found."
			Case else
				err.raise 3, "cls_Security_Privilege", "Error loading class cls_Security_Privilege [Load]: Item was not unique."			
		end Select
	End Function

	'Loads this object's values by loading a record based on the given ID and the current security context
	Public Function LoadFromCurrentContext(ByRef p_CurrentContextXMLObject, p_ID)
		Dim tempxmldoc, tempxmlattribute
		Set tempxmldoc = Server.CreateObject("MSXML2.FreeThreadedDOMDocument")
		Set tempxmlattribute = Server.CreateObject("MSXML2.FreeThreadedDOMDocument")

		tempxmldoc.async = False
		tempxmldoc.validateOnParse = False
		tempxmldoc.preserveWhitespace = True
		tempxmldoc.resolveExternals = False
		tempxmldoc.load p_CurrentContextXMLObject

		if tempxmldoc.selectNodes("//Security_Privilege[@ID = '" & CStr(p_ID) & "']").length > 0 then
			for each tempxmlattribute in tempxmldoc.selectSingleNode("//Security_Privilege[@ID = '" & CStr(p_ID) & "']").attributes
				'Response.Write tempxmlattribute.nodeName & ": " & tempxmlattribute.nodeValue & "<br>"
				if tempxmlattribute.nodeName = "ID" then m_ID = SmartValues(tempxmlattribute.nodeValue, "CInt")
				if tempxmlattribute.nodeName = "Parent_Privilege_ID" then m_Parent_Privilege_ID = SmartValues(tempxmlattribute.nodeValue, "CInt")
				if tempxmlattribute.nodeName = "Scope_ID" then m_Scope_ID = SmartValues(tempxmlattribute.nodeValue, "CInt")
				if tempxmlattribute.nodeName = "Privilege_Name" then m_Privilege_Name = SmartValues(tempxmlattribute.nodeValue, "CStr")
				if tempxmlattribute.nodeName = "Privilege_ShortName" then m_Privilege_ShortName = SmartValues(tempxmlattribute.nodeValue, "CStr")
				if tempxmlattribute.nodeName = "Privilege_Summary" then m_Privilege_Summary = SmartValues(tempxmlattribute.nodeValue, "CStr")
				if tempxmlattribute.nodeName = "Constant" then m_Constant = SmartValues(tempxmlattribute.nodeValue, "CStr")
				if tempxmlattribute.nodeName = "Advanced" then m_Advanced = SmartValues(tempxmlattribute.nodeValue, "CBool")
				if tempxmlattribute.nodeName = "SortOrder" then m_SortOrder = SmartValues(tempxmlattribute.nodeValue, "CStr")
				if tempxmlattribute.nodeName = "Date_Last_Modified" then m_Date_Last_Modified = SmartValues(utils.FixXMLDateTime(tempxmlattribute.nodeValue, 0), "CDate")
				if tempxmlattribute.nodeName = "Date_Created" then m_Date_Created = SmartValues(utils.FixXMLDateTime(tempxmlattribute.nodeValue, 0), "CDate")
			next
		end if
		
		Set tempxmldoc = Nothing
		Set tempxmlattribute = Nothing
	End Function

    Public Function Save()
		Dim SQLStr

		SQLStr = "sp_Security_Privilege_InsertUpdate " & _
		SQLStr = SQLStr & " @ID = " & m_ID & ", "
		SQLStr = SQLStr & " @Parent_Privilege_ID = " & m_Parent_Privilege_ID & ", "
		SQLStr = SQLStr & " @Scope_ID = " & m_Scope_ID & ", "
		SQLStr = SQLStr & " @Privilege_Name = " & m_Privilege_Name & ", "
		SQLStr = SQLStr & " @Privilege_ShortName = " & m_Privilege_ShortName & ", "
		SQLStr = SQLStr & " @Privilege_Summary = " & m_Privilege_Summary & ", "
		SQLStr = SQLStr & " @Constant = " & m_Constant & ", "
		SQLStr = SQLStr & " @Advanced = " & m_Advanced & ", "
		SQLStr = SQLStr & " @SortOrder = " & m_SortOrder & ", "
		SQLStr = SQLStr & " @Date_Last_Modified = " & m_Date_Last_Modified & ", "
		SQLStr = SQLStr & " @Date_Created = " & m_Date_Created & ", "
		SQLStr = SQLStr & " " & m_ID & " OUTPUT "
		
		utils.LoadRSFromDB SQLStr
		Save =  m_ID
    End Function    
	
	Public Function Delete()
		Dim SQLStr
        SQLStr = "DELETE FROM Security_Privilege WHERE [ID] = '0" & CLng(p_ID) & "'"
		utils.RunSQL SQLStr
	End Function

End Class
%>