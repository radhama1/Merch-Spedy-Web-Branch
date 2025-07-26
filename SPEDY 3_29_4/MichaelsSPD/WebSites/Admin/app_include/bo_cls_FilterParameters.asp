<%
'==============================================================================
' CLASS: cls_FilterParameters
' Generated Monday, February 5, 2007
' By Oscar.Treto
'==============================================================================
'
'	:: Properties
'	Count
'	Parameters
'	GetParameter
'
'	:: Methods
'	AddQuestion(p_PaneQuestion)
'	AddNewQuestion()
'	RemoveAll
'
'==============================================================================
Class cls_FilterParameters
	'Private, class member variable
	Private m_ID
	Private m_Name
	Private m_ParameterSet

	Private Sub Class_Initialize()
		Set m_ParameterSet	= Server.CreateObject("Scripting.Dictionary")
		m_Name = ""
	End Sub

	Private Sub Class_Terminate()
		Set m_ParameterSet	= Nothing
	End Sub
	
	'Read the current ID value
	Public Property Get ID()
		ID = m_ID
	End Property
	'store a new ID value
	Public Property Let ID(p_Data)
		m_ID = p_Data
	End Property
	
	'Read the current Name value
	Public Property Get Name()
		Name = m_Name
	End Property
	'store a new Name value
	Public Property Let Name(p_Data)
		m_Name = p_Data
	End Property
		
	'Get the Count value
	Public Property Get Count()
		Count = m_ParameterSet.Count
	End Property
	
	Public Property Get Parameters()
		Set Parameters = m_ParameterSet
	End Property
	
	'Gets a parameter
	Public Property Get GetParameter(p_Key)
		if m_ParameterSet.Exists(p_Key) then
			Set GetParameter = m_ParameterSet.Item(p_Key)
		else
			Set GetParameter = Nothing
		end if
	End Property
	
	'Removes all objects from the dictionary
	Public Function RemoveAll()
		m_ParameterSet.RemoveAll()
	End Function
	
	'Adds a new parameter object
	Public Function AddNewParameter(p_Parameter_ID, p_Parameter_Str)
		Dim ParameterObj
		
		Set ParameterObj = New cls_FilterParameter
		ParameterObj.ID = CStr(m_ParameterSet.Count + 1)
		ParameterObj.Parameter_ID = SmartValues(p_Parameter_ID, "CStr")
		if IsNull(p_Parameter_Str) then
			ParameterObj.Parameter_Str = ""
		elseif Len(Trim(SmartValues(p_Parameter_Str, "CStr"))) > 0 then
			ParameterObj.Parameter_Str = p_Parameter_Str
		end if
		
		m_ParameterSet.Add CStr(m_ParameterSet.Count + 1), ParameterObj
		
		Set ParameterObj = Nothing
	End Function
	
End Class
%>
