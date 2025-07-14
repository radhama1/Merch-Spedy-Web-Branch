<%
'==============================================================================
' CLASS: cls_FilterPaneChoice
' Generated Monday, February 5, 2007
' By Oscar.Treto
'==============================================================================
'
'	:: Properties
'	ID
'	Is_Default
'	Value
'	Text
'
'	:: Methods
'
'==============================================================================
Class cls_FilterPaneChoice
	'Private, class member variable
	Private m_ID
	Private m_Is_Default
	Private m_Value
	Private m_Text
	Private m_DataSet_Type
	Private utils
	
	Private Sub Class_Initialize()
		m_Is_Default		= False
		m_Value				= ""
		m_Text				= ""
		Set m_DataSet_Type	= New cls_FilterPaneChoiceSetType
		Set utils			= New cls_UtilityLibrary
	End Sub

	Private Sub Class_Terminate()
		Set m_DataSet_Type	= Nothing
		Set utils			= Nothing
	End Sub

	'Read the current ID value
	Public Property Get ID()
		ID = m_ID
	End Property
	'store a new ID value
	Public Property Let ID(p_Data)
		m_ID = p_Data
	End Property
	
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

	Public Function Display(p_Choice_Type, p_PaneNumber)
		
		Dim rs, selected, thisFilterID
		selected = ""
		thisFilterID = checkQueryID(Request("Filter_ID"), 0)
						
		Select Case p_Choice_Type
		
			Case m_DataSet_Type.TEXT
			
				if thisFilterID = 0 then
					Response.Write " value=""" & m_Value & """ "
				else
					Set rs = utils.LoadRSFromDB("sp_Filter_Choice_Select_By_FilterID_Ordinal '0" & thisFilterID & "', '0" & p_PaneNumber & "'")
					
					if NOT rs.EOF then
						Response.Write " value=""" & rs("Value") & """ "
					else
						Response.Write " value=""" & m_Value & """ "
					end if
					
					Set rs = nothing
					
				end if
		
				'Response.Write " value=""" & m_Value & """ "
				
			Case m_DataSet_Type.DATE_TIME
			
			Case m_DataSet_Type.LIST, m_DataSet_Type.DB_LOOKUP
			
				Set rs = utils.LoadRSFromDB("sp_Filter_Choice_Select_By_FilterID_Ordinal_Value '0" & thisFilterID & "', '0" & p_PaneNumber & "','" & m_Value & "'")
				
				if Not rs.EOF then
					selected = " selected "
				end if
					
				if m_Is_Default then
					Response.Write "<option value=""" & m_Value & """ selected>" & m_Text & "</option>" & vbcrlf
				else
					Response.Write "<option value=""" & m_Value & """" & selected & ">" & m_Text & "</option>" & vbcrlf
				end if
		
				Set rs = nothing
		End Select 
		
	End Function
	
End Class
%>
