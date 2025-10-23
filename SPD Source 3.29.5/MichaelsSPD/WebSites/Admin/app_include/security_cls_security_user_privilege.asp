<%
'==============================================================================
' CLASS: cls_Security_User_Privilege
' Generated using CodeSmith on Friday, October 14, 2005
' By ken.wallace
'==============================================================================
'
' This object represents properties and methods for interacting with 
' table DriversEdDirect_Dev.dbo.Security_User_Privilege.  
'
'==============================================================================
Class cls_Security_User_Privilege
	'Private, class member variable
	Private m_ID
	Private m_User_ID
	Private m_Privilege_ID
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
	'Read the current User_ID value
	Public Property Get User_ID()
		User_ID = CInt(m_User_ID)
	End Property
	'store a new User_ID value
	Public Property Let User_ID(p_Data)
		m_User_ID = p_Data
	End Property
	'Read the current Privilege_ID value
	Public Property Get Privilege_ID()
		Privilege_ID = CInt(m_Privilege_ID)
	End Property
	'store a new Privilege_ID value
	Public Property Let Privilege_ID(p_Data)
		m_Privilege_ID = p_Data
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

		SQLStr = "SELECT * FROM Security_User_Privilege WHERE ID = '0" & CLng(p_ID) & "'"
		Set rs = utils.LoadRSFromDB(SQLStr)

		Select Case rs.recordcount
			Case 1
				m_ID = SmartValues(rs("ID"), "CInt")
				m_User_ID = SmartValues(rs("User_ID"), "CInt")
				m_Privilege_ID = SmartValues(rs("Privilege_ID"), "CInt")
				m_Date_Last_Modified = SmartValues(rs("Date_Last_Modified"), "CDate")
				m_Date_Created = SmartValues(rs("Date_Created"), "CDate")
				Load = m_ID
			Case -1, 0
				err.raise 2, "cls_Security_User_Privilege", "Error loading class cls_Security_User_Privilege [Load]: Item was not found."
			Case else
				err.raise 3, "cls_Security_User_Privilege", "Error loading class cls_Security_User_Privilege [Load]: Item was not unique."			
		end Select
	End Function

'	'Loads this object's values by loading a record based on the given ID and the current security context
'	Public Function LoadFromCurrentContext(ByRef p_CurrentContextXMLObject, p_ID)
'		Dim tempxmldoc, tempxmlattribute
'		Set tempxmldoc = Server.CreateObject("MSXML2.FreeThreadedDOMDocument")
'		Set tempxmlattribute = Server.CreateObject("MSXML2.FreeThreadedDOMDocument")
'
'		tempxmldoc.async = False
'		tempxmldoc.validateOnParse = False
'		tempxmldoc.preserveWhitespace = True
'		tempxmldoc.resolveExternals = False
'		tempxmldoc.load p_CurrentContextXMLObject
'
'		if tempxmldoc.selectNodes("//Security_User_Privilege[@ID = '" & CStr(p_ID) & "']").length > 0 then
'			for each tempxmlattribute in tempxmldoc.selectSingleNode("//Security_User_Privilege[@ID = '" & CStr(p_ID) & "']").attributes
'				'Response.Write tempxmlattribute.nodeName & ": " & tempxmlattribute.nodeValue & "<br>"
'				if tempxmlattribute.nodeName = "ID" then m_ID = SmartValues(tempxmlattribute.nodeValue, "CInt")
'				if tempxmlattribute.nodeName = "User_ID" then m_User_ID = SmartValues(tempxmlattribute.nodeValue, "CInt")
'				if tempxmlattribute.nodeName = "Privilege_ID" then m_Privilege_ID = SmartValues(tempxmlattribute.nodeValue, "CInt")
'				if tempxmlattribute.nodeName = "Date_Last_Modified" then m_Date_Last_Modified = SmartValues(utils.FixXMLDateTime(tempxmlattribute.nodeValue, 0), "CDate")
'				if tempxmlattribute.nodeName = "Date_Created" then m_Date_Created = SmartValues(utils.FixXMLDateTime(tempxmlattribute.nodeValue, 0), "CDate")
'			next
'		end if
'		
'		Set tempxmldoc = Nothing
'		Set tempxmlattribute = Nothing
'	End Function

    Public Function Save()
		Dim SQLStr

		SQLStr = "sp_Security_User_Privilege_InsertUpdate " & _
		SQLStr = SQLStr & " @ID = " & m_ID & ", "
		SQLStr = SQLStr & " @User_ID = " & m_User_ID & ", "
		SQLStr = SQLStr & " @Privilege_ID = " & m_Privilege_ID & ", "
		SQLStr = SQLStr & " @Date_Last_Modified = " & m_Date_Last_Modified & ", "
		SQLStr = SQLStr & " @Date_Created = " & m_Date_Created & ", "
		SQLStr = SQLStr & " " & m_ID & " OUTPUT "
		
		utils.LoadRSFromDB SQLStr
		Save =  m_ID
    End Function    
	
	Public Function Delete()
		Dim SQLStr
        SQLStr = "DELETE FROM Security_User_Privilege WHERE [ID] = '0" & CLng(p_ID) & "'"
		utils.RunSQL SQLStr
	End Function

End Class
%>