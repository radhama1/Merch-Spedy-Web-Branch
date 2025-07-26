<%
'==============================================================================
' CLASS: cls_SecurityActivityLog
' Generated using CodeSmith on Tuesday, October 17, 2006
' By ken.wallace
'==============================================================================
'
' This object represents properties and methods for interacting with the dbo.Security_Activity_Log table.  
'
'	:: Properties
'	ID = CLng(m_ID)
'	Activity_User_ID = CInt(m_Activity_User_ID)
'	Activity_Type = CInt(m_Activity_Type)
'	Activity_Summary = CStr(m_Activity_Summary)
'	Reference_ID = CInt(m_Reference_ID)
'	Reference_Type = CInt(m_Reference_Type)
'	Activity_Date = CDate(m_Activity_Date)
'
'	:: Methods
'	Load(p_ID)
'	Save()
'	Delete()
'
'==============================================================================
Class cls_SecurityActivityLog
	'Private, class member variable
	Private m_ID
	Private m_Activity_User_ID
	Private m_Activity_Type
	Private m_Activity_Summary
	Private m_Reference_ID
	Private m_Reference_Type
	Private m_Activity_Date
	Private utils

	Private Sub Class_Initialize()
		Set utils = New cls_UtilityLibrary
	End Sub

	Private Sub Class_Terminate()
		Set utils = Nothing
	End Sub

	'Read the current ID value
	Public Property Get ID()
		ID = m_ID
	End Property
	'store a new ID value
	Public Property Let ID(p_Data)
		m_ID = p_Data
	End Property

	'Read the current Activity_User_ID value
	Public Property Get Activity_User_ID()
		Activity_User_ID = m_Activity_User_ID
	End Property
	'store a new Activity_User_ID value
	Public Property Let Activity_User_ID(p_Data)
		m_Activity_User_ID = p_Data
	End Property

	'Read the current Activity_Type value
	Public Property Get Activity_Type()
		Activity_Type = m_Activity_Type
	End Property
	'store a new Activity_Type value
	Public Property Let Activity_Type(p_Data)
		m_Activity_Type = p_Data
	End Property

	'Read the current Activity_Summary value
	Public Property Get Activity_Summary()
		Activity_Summary = m_Activity_Summary
	End Property
	'store a new Activity_Summary value
	Public Property Let Activity_Summary(p_Data)
		m_Activity_Summary = p_Data
	End Property

	'Read the current Reference_ID value
	Public Property Get Reference_ID()
		Reference_ID = m_Reference_ID
	End Property
	'store a new Reference_ID value
	Public Property Let Reference_ID(p_Data)
		m_Reference_ID = p_Data
	End Property

	'Read the current Reference_Type value
	Public Property Get Reference_Type()
		Reference_Type = m_Reference_Type
	End Property
	'store a new Reference_Type value
	Public Property Let Reference_Type(p_Data)
		m_Reference_Type = p_Data
	End Property

	'Read the current Activity_Date value
	Public Property Get Activity_Date()
		Activity_Date = m_Activity_Date
	End Property
	'store a new Activity_Date value
	Public Property Let Activity_Date(p_Data)
		m_Activity_Date = p_Data
	End Property


	'Loads this object's values by loading a record based on the given ID
	Public Function Load(p_ID)
		Dim SQLStr, rs

		SQLStr = "sp_Security_Activity_Log_Select '0" & CLng(p_ID) & "'"
		Set rs = utils.LoadRSFromDB(SQLStr)

		if rs.recordcount = 1 then
			m_ID = SmartValues(rs("ID"), "CLng")
			m_Activity_User_ID = SmartValues(rs("Activity_User_ID"), "CInt")
			m_Activity_Type = SmartValues(rs("Activity_Type"), "CInt")
			m_Activity_Summary = SmartValues(rs("Activity_Summary"), "CStr")
			m_Reference_ID = SmartValues(rs("Reference_ID"), "CLng")
			m_Reference_Type = SmartValues(rs("Reference_Type"), "CInt")
			m_Activity_Date = SmartValues(rs("Activity_Date"), "CDate")

			Load = true
		else
			Select Case rs.recordcount
				Case -1, 0
					Session.Value("LASTOBJECTLOADERROR") = "Error loading class cls_Security_Activity_Log [Load]: Item was not found."
				Case else
					Session.Value("LASTOBJECTLOADERROR") = "Error loading class cls_Security_Activity_Log [Load]: Item was not unique."
			End Select
			Response.Write vbCrLf & vbCrLf & "<!--" & Session.Value("LASTOBJECTLOADERROR") & "-->" & vbCrLf & vbCrLf
		
			Load = false
		end if
	End Function

    Public Function Save()
		Dim SQLStr, rs

		SQLStr = "sp_Security_Activity_Log_InsertUpdate @ID = '0" & m_ID & "'"
		SQLStr = SQLStr & ", @Activity_Date = '" & CDate(Now()) & "'"
		SQLStr = SQLStr & ", @Activity_User_ID = '0" & checkQueryID(Session.Value("UserID"), 0) & "'"
		if Len(m_Activity_Type) > 0 then SQLStr = SQLStr & ", @Activity_Type = '" & m_Activity_Type & "'"
		if Len(m_Activity_Summary) > 0 then SQLStr = SQLStr & ", @Activity_Summary = '" & utils.FormatDBStringForInsert(m_Activity_Summary) & "'"
		if Len(m_Reference_ID) > 0 then SQLStr = SQLStr & ", @Reference_ID = " & m_Reference_ID & ""
		if Len(m_Reference_Type) > 0 then SQLStr = SQLStr & ", @Reference_Type = " & m_Reference_Type & ""
		
		Set rs = utils.LoadRSFromDB(SQLStr)
		m_ID = SmartValues(rs(0), "CLng")
		
		Save =  m_ID
    End Function    
	
	Public Function Delete()
		Dim SQLStr
        SQLStr = "sp_Security_Activity_Log_Delete '0" & CLng(m_ID) & "'"
		utils.RunSQL SQLStr
	End Function

End Class
%>
