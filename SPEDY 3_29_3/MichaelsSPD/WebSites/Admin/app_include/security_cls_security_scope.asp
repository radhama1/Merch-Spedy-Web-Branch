<%
'==============================================================================
' CLASS: cls_Security_Scope
' Generated using CodeSmith on Thursday, October 20, 2005
' By ken.wallace
'==============================================================================
'
' This object represents properties and methods for interacting with the dbo.Security_Scope table.  
'
'==============================================================================
Class cls_Security_Scope
	'Private, class member variable
	Private m_ID
	Private m_Parent_Scope_ID
	Private m_Scope_Name
	Private m_Scope_Summary
	Private m_Constant
	Private m_SortOrder
	Private m_Display
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
	'Read the current Parent_Scope_ID value
	Public Property Get Parent_Scope_ID()
		Parent_Scope_ID = CInt(m_Parent_Scope_ID)
	End Property
	'store a new Parent_Scope_ID value
	Public Property Let Parent_Scope_ID(p_Data)
		m_Parent_Scope_ID = p_Data
	End Property
	'Read the current Scope_Name value
	Public Property Get Scope_Name()
		Scope_Name = CStr(m_Scope_Name)
	End Property
	'store a new Scope_Name value
	Public Property Let Scope_Name(p_Data)
		m_Scope_Name = p_Data
	End Property
	'Read the current Scope_Summary value
	Public Property Get Scope_Summary()
		Scope_Summary = CStr(m_Scope_Summary)
	End Property
	'store a new Scope_Summary value
	Public Property Let Scope_Summary(p_Data)
		m_Scope_Summary = p_Data
	End Property
	'Read the current Constant value
	Public Property Get Constant()
		Constant = CStr(m_Constant)
	End Property
	'store a new Constant value
	Public Property Let Constant(p_Data)
		m_Constant = p_Data
	End Property
	'Read the current SortOrder value
	Public Property Get SortOrder()
		SortOrder = CStr(m_SortOrder)
	End Property
	'store a new SortOrder value
	Public Property Let SortOrder(p_Data)
		m_SortOrder = p_Data
	End Property
	'Read the current Display value
	Public Property Get Display()
		Display = CBool(m_Display)
	End Property
	'store a new Display value
	Public Property Let Display(p_Data)
		m_Display = p_Data
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

	'Loads this object's values by loading a record based on the given ID
	Public Function Load(p_ID)
		Dim SQLStr, rs

		SQLStr = "SELECT * FROM Security_Scope WHERE ID = '0" & CLng(p_ID) & "'"
		Set rs = utils.LoadRSFromDB(SQLStr)

		Select Case rs.recordcount
			Case 1
				m_ID = SmartValues(rs("ID"), "CInt")
				m_Parent_Scope_ID = SmartValues(rs("Parent_Scope_ID"), "CInt")
				m_Scope_Name = SmartValues(rs("Scope_Name"), "CStr")
				m_Scope_Summary = SmartValues(rs("Scope_Summary"), "CStr")
				m_Constant = SmartValues(rs("Constant"), "CStr")
				m_SortOrder = SmartValues(rs("SortOrder"), "CStr")
				m_Display = SmartValues(rs("Display"), "CBool")
				m_Date_Last_Modified = SmartValues(rs("Date_Last_Modified"), "CDate")
				m_Date_Created = SmartValues(rs("Date_Created"), "CDate")
				Load = m_ID
			Case -1, 0
				err.raise 2, "cls_Security_Scope", "Error loading class cls_Security_Scope [Load]: Item was not found."
			Case else
				err.raise 3, "cls_Security_Scope", "Error loading class cls_Security_Scope [Load]: Item was not unique."			
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

		if tempxmldoc.selectNodes("//Security_Scope[@ID = '" & CStr(p_ID) & "']").length > 0 then
			for each tempxmlattribute in tempxmldoc.selectSingleNode("//Security_Scope[@ID = '" & CStr(p_ID) & "']").attributes
				'Response.Write tempxmlattribute.nodeName & ": " & tempxmlattribute.nodeValue & "<br>"
				if tempxmlattribute.nodeName = "ID" then m_ID = SmartValues(tempxmlattribute.nodeValue, "CInt")
				if tempxmlattribute.nodeName = "Parent_Scope_ID" then m_Parent_Scope_ID = SmartValues(tempxmlattribute.nodeValue, "CInt")
				if tempxmlattribute.nodeName = "Scope_Name" then m_Scope_Name = SmartValues(tempxmlattribute.nodeValue, "CStr")
				if tempxmlattribute.nodeName = "Scope_Summary" then m_Scope_Summary = SmartValues(tempxmlattribute.nodeValue, "CStr")
				if tempxmlattribute.nodeName = "Constant" then m_Constant = SmartValues(tempxmlattribute.nodeValue, "CStr")
				if tempxmlattribute.nodeName = "SortOrder" then m_SortOrder = SmartValues(tempxmlattribute.nodeValue, "CStr")
				if tempxmlattribute.nodeName = "Display" then m_Display = SmartValues(tempxmlattribute.nodeValue, "CBool")
				if tempxmlattribute.nodeName = "Date_Last_Modified" then m_Date_Last_Modified = SmartValues(utils.FixXMLDateTime(tempxmlattribute.nodeValue, 0), "CDate")
				if tempxmlattribute.nodeName = "Date_Created" then m_Date_Created = SmartValues(utils.FixXMLDateTime(tempxmlattribute.nodeValue, 0), "CDate")
			next
		end if
		
		Set tempxmldoc = Nothing
		Set tempxmlattribute = Nothing
	End Function

    Public Function Save()
		Dim SQLStr

		SQLStr = "sp_Security_Scope_InsertUpdate " & _
		SQLStr = SQLStr & " @ID = " & m_ID & ", "
		SQLStr = SQLStr & " @Parent_Scope_ID = " & m_Parent_Scope_ID & ", "
		SQLStr = SQLStr & " @Scope_Name = " & m_Scope_Name & ", "
		SQLStr = SQLStr & " @Scope_Summary = " & m_Scope_Summary & ", "
		SQLStr = SQLStr & " @Constant = " & m_Constant & ", "
		SQLStr = SQLStr & " @SortOrder = " & m_SortOrder & ", "
		SQLStr = SQLStr & " @Display = " & m_Display & ", "
		SQLStr = SQLStr & " @Date_Last_Modified = " & m_Date_Last_Modified & ", "
		SQLStr = SQLStr & " @Date_Created = " & m_Date_Created & ", "
		SQLStr = SQLStr & " " & m_ID & " OUTPUT "
		
		utils.LoadRSFromDB SQLStr
		Save =  m_ID
    End Function    
	
	Public Function Delete()
		Dim SQLStr
        SQLStr = "DELETE FROM Security_Scope WHERE [ID] = '0" & CLng(p_ID) & "'"
		utils.RunSQL SQLStr
	End Function

End Class
%>