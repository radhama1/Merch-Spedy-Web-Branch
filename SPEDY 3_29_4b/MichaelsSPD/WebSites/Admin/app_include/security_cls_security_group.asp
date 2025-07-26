<%
'==============================================================================
' CLASS: cls_Security_Group
' Generated using CodeSmith on Thursday, September 08, 2005
' By ken.wallace
'==============================================================================
'
' This object represents properties and methods for interacting with 
' table DriversEdDirect_Dev.dbo.Security_Group.  
'
'==============================================================================
Class cls_Security_Group
	'Private, class member variable
	Private m_ID
	Private m_Group_Name
	Private m_Group_Summary
	Private m_Is_Role
	Private m_System_Role
	Private m_SortOrder
	Private m_Start_Date
	Private m_End_Date
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
	
	'Read the current Group_Name value
	Public Property Get Group_Name()
		Group_Name = CStr(m_Group_Name)
	End Property
	'store a new Group_Name value
	Public Property Let Group_Name(p_Data)
		m_Group_Name = p_Data
	End Property
	
	'Read the current Group_Summary value
	Public Property Get Group_Summary()
		Group_Summary = CStr(m_Group_Summary)
	End Property
	'store a new Group_Summary value
	Public Property Let Group_Summary(p_Data)
		m_Group_Summary = p_Data
	End Property
	
	'Read the current Is_Role value
	Public Property Get Is_Role()
		Is_Role = CBool(m_Is_Role)
	End Property
	'store a new Is_Role value
	Public Property Let Is_Role(p_Data)
		m_Is_Role = p_Data
	End Property
	
	'Read the current System_Role value
	Public Property Get System_Role()
		System_Role = CBool(m_System_Role)
	End Property
	'store a new System_Role value
	Public Property Let System_Role(p_Data)
		m_System_Role = p_Data
	End Property
	
	'Read the current SortOrder value
	Public Property Get SortOrder()
		SortOrder = CStr(m_SortOrder)
	End Property
	'store a new SortOrder value
	Public Property Let SortOrder(p_Data)
		m_SortOrder = p_Data
	End Property
	
	'Read the current Start_Date value
	Public Property Get Start_Date()
		Start_Date = CDate(m_Start_Date)
	End Property
	'store a new Start_Date value
	Public Property Let Start_Date(p_Data)
		m_Start_Date = p_Data
	End Property
	
	'Read the current End_Date value
	Public Property Get End_Date()
		End_Date = CDate(m_End_Date)
	End Property
	'store a new End_Date value
	Public Property Let End_Date(p_Data)
		m_End_Date = p_Data
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

		SQLStr = "SELECT * FROM Security_Group WHERE ID = '0" & CLng(p_ID) & "'"
		Set rs = utils.LoadRSFromDB(SQLStr)

		Select Case rs.recordcount
			Case 1
				m_ID = SmartValues(rs("ID"), "CInt")
				m_Group_Name = SmartValues(rs("Group_Name"), "CStr")
				m_Group_Summary = SmartValues(rs("Group_Summary"), "CStr")
				m_Is_Role = SmartValues(rs("Is_Role"), "CBool")
				m_System_Role = SmartValues(rs("System_Role"), "CBool")
				m_SortOrder = SmartValues(rs("SortOrder"), "CStr")
				m_Start_Date = SmartValues(rs("Start_Date"), "CDate")
				m_End_Date = SmartValues(rs("End_Date"), "CDate")
				m_Date_Last_Modified = SmartValues(rs("Date_Last_Modified"), "CDate")
				m_Date_Created = SmartValues(rs("Date_Created"), "CDate")
				Load = m_ID
			Case -1, 0
				err.raise 2, "cls_Security_Group", "Error loading class cls_Security_Group [Load]: Item was not found."
			Case else
				err.raise 3, "cls_Security_Group", "Error loading class cls_Security_Group [Load]: Item was not unique."			
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

		if tempxmldoc.selectNodes("//Security_Group[@ID = '" & CStr(p_ID) & "']").length > 0 then

			for each tempxmlattribute in tempxmldoc.selectSingleNode("//Security_Group[@ID = '" & CStr(p_ID) & "']").attributes
				'Response.Write tempxmlattribute.nodeName & ": " & tempxmlattribute.nodeValue & "<br>"
				if tempxmlattribute.nodeName = "ID" then m_ID = SmartValues(tempxmlattribute.nodeValue, "CInt")
				if tempxmlattribute.nodeName = "Group_Name" then m_Group_Name = SmartValues(tempxmlattribute.nodeValue, "CStr")
				if tempxmlattribute.nodeName = "Group_Summary" then m_Group_Summary = SmartValues(tempxmlattribute.nodeValue, "CStr")
				if tempxmlattribute.nodeName = "Is_Role" then m_Is_Role = SmartValues(tempxmlattribute.nodeValue, "CBool")
				if tempxmlattribute.nodeName = "System_Role" then m_System_Role = SmartValues(tempxmlattribute.nodeValue, "CBool")
				if tempxmlattribute.nodeName = "SortOrder" then m_SortOrder = SmartValues(tempxmlattribute.nodeValue, "CStr")
				if tempxmlattribute.nodeName = "Start_Date" then m_Start_Date = SmartValues(utils.FixXMLDateTime(tempxmlattribute.nodeValue, 0), "CDate")
				if tempxmlattribute.nodeName = "End_Date" then m_End_Date = SmartValues(utils.FixXMLDateTime(tempxmlattribute.nodeValue, 0), "CDate")
				if tempxmlattribute.nodeName = "Date_Last_Modified" then m_Date_Last_Modified = SmartValues(utils.FixXMLDateTime(tempxmlattribute.nodeValue, 0), "CDate")
				if tempxmlattribute.nodeName = "Date_Created" then m_Date_Created = SmartValues(utils.FixXMLDateTime(tempxmlattribute.nodeValue, 0), "CDate")
			next

		end if
		
		Set tempxmldoc = Nothing
		Set tempxmlattribute = Nothing
	End Function
	
	Public Function Save()
		Dim SQLStr
		SQLStr = "sp_Security_Group_InsertUpdate " & _
		SQLStr = SQLStr & " @ID = " & m_ID & ", "
		SQLStr = SQLStr & " @Group_Name = " & m_Group_Name & ", "
		SQLStr = SQLStr & " @Group_Summary = " & m_Group_Summary & ", "
		SQLStr = SQLStr & " @Is_Role = " & m_Is_Role & ", "
		SQLStr = SQLStr & " @System_Role = " & m_System_Role & ", "
		SQLStr = SQLStr & " @SortOrder = " & m_SortOrder & ", "
		SQLStr = SQLStr & " @Start_Date = " & m_Start_Date & ", "
		SQLStr = SQLStr & " @End_Date = " & m_End_Date & ", "
		SQLStr = SQLStr & " @Date_Last_Modified = " & m_Date_Last_Modified & ", "
		SQLStr = SQLStr & " @Date_Created = " & m_Date_Created & ", "
		SQLStr = SQLStr & " " & m_ID & " OUTPUT "
		utils.LoadRSFromDB SQLStr
		Save =  m_ID
	End Function	
	
	Public Function Delete()
		Dim SQLStr
		SQLStr = "DELETE FROM Security_Group WHERE [ID] = '0" & CLng(p_ID) & "'"
		'utils.RunSQL SQLStr
	End Function

End Class
%>