<%
'==============================================================================
' CLASS: cls_FilterParameter
' Generated Monday, February 5, 2007
' By Oscar.Treto
'==============================================================================
'
'	:: Properties
'
'	:: Methods
'
'==============================================================================
Class cls_FilterParameter
	'Private, class member variable
	Private m_ID
	Private m_Parameter_ID
	Private m_Parameter_Str
	
	Private Sub Class_Initialize()
		m_Parameter_ID	= 0
		m_Parameter_Str	= "[SELECTED_VALUES]"
	End Sub

	Private Sub Class_Terminate()

	End Sub
	
	'Read the current ID value
	Public Property Get ID()
		ID = m_ID
	End Property
	'store a new ID value
	Public Property Let ID(p_Data)
		m_ID = p_Data
	End Property

	'Read the current Parameter_ID value
	Public Property Get Parameter_ID()
		Parameter_ID = m_Parameter_ID
	End Property
	'store a new Parameter_ID value
	Public Property Let Parameter_ID(p_Data)
		m_Parameter_ID = p_Data
	End Property

	'Read the current Parameter_Str value
	Public Property Get Parameter_Str()
		Parameter_Str = m_Parameter_Str
	End Property
	'store a new Parameter_Str value
	Public Property Let Parameter_Str(p_Data)
		m_Parameter_Str = p_Data
	End Property

End Class
%>
