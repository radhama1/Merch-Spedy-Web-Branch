<%
'==============================================================================
' CLASS: cls_FilterPaneQuestion
' Generated Monday, February 5, 2007
' By Oscar.Treto
'==============================================================================
'
'	:: Properties
'	Is_Default
'	Value
'	Text
'
'	:: Methods
'
'==============================================================================
Class cls_FilterPaneQuestion
	'Private, class member variable
	Private m_Is_Default
	Private m_Value
	Private m_Text
	Private m_PaneNumber
	Private utils
	Public FilterParameters
	
	Private Sub Class_Initialize()
		m_Is_Default			= False
		m_Value					= ""
		m_Text					= ""
		m_PaneNumber			= 0
		Set utils				= New cls_UtilityLibrary
		Set FilterParameters	= New cls_FilterParameters
	End Sub

	Private Sub Class_Terminate()
		Set utils				= Nothing
		Set FilterParameters	= Nothing
	End Sub

	'Read the current Is_Default value
	Public Property Get Is_Default()
		Is_Default = m_Is_Default
	End Property
	'store a new Is_Default value
	Public Property Let Is_Default(p_Data)
		m_Is_Default = p_Data
	End Property
	
	'Read the current Value value
	Public Property Get Value()
		Value = m_Value
	End Property
	'store a new Value value
	Public Property Let Value(p_Data)
		m_Value = p_Data
	End Property

	'Read the current Text value
	Public Property Get Text()
		Text = m_Text
	End Property
	'store a new Text value
	Public Property Let Text(p_Data)
		m_Text = p_Data
	End Property
	
	'Read the current PaneNumber value
	Public Property Get PaneNumber()
		PaneNumber = m_PaneNumber
	End Property
	'store a new PaneNumber value
	Public Property Let PaneNumber(p_Data)
		m_PaneNumber = p_Data
	End Property
	
	Public Function Display()
	
		Dim rs, selected, thisFilterID
		
		selected = ""
		thisFilterID = checkQueryID(Request("Filter_ID"), 0)
		
		'response.Write "<!---sp_Filter_Question_Select_By_FilterID_Ordinal_Value '0" & thisFilterID & "', '0" & m_PaneNumber & "', '" & m_Value &  "'--->"
		
		if thisFilterID > 0 then
			Set rs = utils.LoadRSFromDB("sp_Filter_Question_Select_By_FilterID_Ordinal_Value '0" & thisFilterID & "', '0" & m_PaneNumber & "', '" & m_Value &  "'")
			if NOT rs.EOF then selected = " selected "
			Set rs = nothing
		end if
		
		Response.Write "<option value=""" & m_Value & """" & selected & ">" & m_Text & "</option>" & vbcrlf
		
	End Function

End Class
%>
