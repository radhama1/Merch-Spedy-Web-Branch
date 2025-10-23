<%
'==============================================================================
' CLASS: cls_FilterPane
' Generated Monday, February 5, 2007
' By Oscar.Treto
'==============================================================================
'
'	:: Properties
'	ID
'	Class_HTML
'
'	:: Methods
'
'==============================================================================
Class cls_FilterPane
	'Private, class member variable
	Private m_ApplicationPath
	Private m_ID
	Private m_Class_HTML
	Private m_Style_HTML
	Private m_Type_ID
	Private m_DataSet_Type
	Private utils
	Public QuestionSet
	Public ChoiceSet

	Private Sub Class_Initialize()
		Set QuestionSet		= New cls_FilterPaneQuestionSet
		Set ChoiceSet		= New cls_FilterPaneChoiceSet
		Set m_DataSet_Type	= New cls_FilterPaneChoiceSetType
		Set utils			= New cls_UtilityLibrary
		
		m_ApplicationPath	= "./"
		m_Type_ID			= m_DataSet_Type.LIST
		m_Class_HTML		= "filterVerbs"
		m_Style_HTML		= ""
		
	End Sub

	Private Sub Class_Terminate()
		Set QuestionSet		= Nothing
		Set ChoiceSet		= Nothing
		Set m_DataSet_Type	= Nothing
		Set utils			= Nothing
	End Sub
	
	'Get the ApplicationPath value
	Public Property Get ApplicationPath()
		ApplicationPath = m_ApplicationPath
	End Property
	'store a new ApplicationPath value
	Public Property Let ApplicationPath(p_Data)
		QuestionSet.ApplicationPath = p_Data
		ChoiceSet.ApplicationPath	= p_Data
		m_ApplicationPath			= p_Data
	End Property
	
	'Read the current ID value
	Public Property Get ID()
		ID = m_ID
	End Property
	'store a new ID value
	Public Property Let ID(p_Data)
		QuestionSet.ID	= p_Data
		ChoiceSet.ID	= p_Data
		m_ID			= p_Data
	End Property

	'Read the current Class_HTML value
	Public Property Get Class_HTML()
		Class_HTML = m_Class_HTML
	End Property
	'store a new Class_HTML value
	Public Property Let Class_HTML(p_Data)
		m_Class_HTML = p_Data
	End Property

	'Read the current Style_HTML value
	Public Property Get Style_HTML()
		Style_HTML = m_Style_HTML
	End Property
	'store a new Style_HTML value
	Public Property Let Style_HTML(p_Data)
		m_Style_HTML = p_Data
	End Property
	
	'Read the current Type_ID value
	Public Property Get Type_ID()
		Type_ID = m_Type_ID
	End Property
	'store a new Type_ID value
	Public Property Let Type_ID(p_Data)
		QuestionSet.Type_ID = p_Data
		ChoiceSet.Type_ID	= p_Data
		m_Type_ID			= p_Data
	End Property
	
	Public Function Display()
			
		'Begin Column
		Response.Write "<td valign=top class=""" & m_Class_HTML & """ style=""" & m_Style_HTML & """>" & vbcrlf
		
		'Display the Pane Type
		Response.write "<input type=hidden id=""Pane_Type_" & m_ID & """ name=""Pane_Type_" & m_ID & """ value=""" & m_Type_ID & """>" & vbcrlf
					
		'Display the Questions
		QuestionSet.Display()
		
		'Display the Choices
		ChoiceSet.Display()
						
		'End Column
		Response.Write "</td>" & vbcrlf
		
	End Function
	
End Class
%>
