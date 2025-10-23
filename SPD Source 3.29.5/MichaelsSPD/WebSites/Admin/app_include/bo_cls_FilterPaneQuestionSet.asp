<%
'==============================================================================
' CLASS: cls_FilterPaneQuestionSet
' Generated Monday, February 5, 2007
' By Oscar.Treto
'==============================================================================
'
'	:: Properties
'	Name
'	Class_HTML
'	Style_HTML
'	Count
'	Questions
'	GetQuestion
'
'	:: Methods
'	AddQuestion(p_PaneQuestion)
'	AddNewQuestion()
'	Remove
'	RemoveAll
'
'==============================================================================
Class cls_FilterPaneQuestionSet
	'Private, class member variable
	Private m_ApplicationPath
	Private m_ID
	Private m_Class_HTML
	Private m_Style_HTML
	Private m_Type_ID
	Private utils
	Private m_DataSet_Type
	Private m_QuestionSet

	Private Sub Class_Initialize()
		Set m_DataSet_Type	= New cls_FilterPaneChoiceSetType
		Set m_QuestionSet	= Server.CreateObject("Scripting.Dictionary")
		Set utils			= New cls_UtilityLibrary
		
		m_ApplicationPath	= "./"
		m_ID				= ""
		m_Class_HTML		= "formElements"
		m_Style_HTML		= "width: 200px;"
		m_Type_ID			= m_DataSet_Type.LIST
	End Sub

	Private Sub Class_Terminate()
		Set m_DataSet_Type	= Nothing
		Set m_QuestionSet	= Nothing
		Set utils			= Nothing
	End Sub
	
	'Get the ApplicationPath value
	Public Property Get ApplicationPath()
		ApplicationPath = m_ApplicationPath
	End Property
	'store a new ApplicationPath value
	Public Property Let ApplicationPath(p_Data)
		m_ApplicationPath = p_Data
	End Property
	
	'Read the current ID value
	Public Property Get ID()
		ID = m_ID
	End Property
	'store a new ID value
	Public Property Let ID(p_Data)
		m_ID = p_Data
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
		m_Type_ID = p_Data
	End Property
		
	'Get the Count value
	Public Property Get Count()
		Count = m_QuestionSet.Count
	End Property
	
	Public Property Get Questions()
		Set Questions = m_QuestionSet
	End Property
	
	'Gets a question
	Public Property Get GetQuestion(p_Key)
		if m_QuestionSet.Exists(p_Key) then
			Set GetQuestion = m_QuestionSet.Item(p_Key)
		else
			Set GetQuestion = Nothing
		end if
	End Property
	
	'Adds an existing question object
	Public Function AddQuestion(p_PaneQuestion)
		p_PaneQuestion.PaneNumber = m_ID
		p_PaneQuestion.Value = CStr(m_QuestionSet.Count + 1)
		m_QuestionSet.Add CStr(m_QuestionSet.Count + 1), p_PaneQuestion
	End Function
	
	'Adds a new question object
	Public Function AddNewQuestion()
		Dim QuestionObj
		
		Set QuestionObj = New cls_FilterPaneQuestion
		QuestionObj.PaneNumber = m_ID
		QuestionObj.Value = CStr(m_QuestionSet.Count + 1)
		QuestionObj.FilterParameters.ID = CStr(m_QuestionSet.Count + 1)
		QuestionObj.FilterParameters.Name = "QS_" & m_ID & "_PS_" & CStr(m_QuestionSet.Count + 1)
		m_QuestionSet.Add CStr(m_QuestionSet.Count + 1), QuestionObj
		
		Set AddNewQuestion = m_QuestionSet.Item(CStr(m_QuestionSet.Count))
		Set QuestionObj = Nothing
	End Function
	
	'Removes all object from the dictionary
	Public Function RemoveAll()
		m_QuestionSet.RemoveAll()
	End Function
	
	Public Function Display()
	
		Dim Counter, CurQuestion
		
		'Initialize Variables
		Counter = 0
	
		'Begin Display of Questions
		Response.Write	"<select name=""Select_Questions_" & m_ID & """ class=""" & m_Class_HTML & """ onchange=""toggleChoiceDiv('Div_Choices_" & m_ID & "',this.value, " & m_Type_ID & ");"" style=""" & m_Style_HTML & """>" & vbcrlf
		
		'Display Each Question
		Do Until Counter >= m_QuestionSet.Count
		
			Counter	= Counter + 1
			
			if m_QuestionSet.Exists(CStr(Counter)) then
				Set CurQuestion = m_QuestionSet.Item(CStr(Counter))
				CurQuestion.Display()
				Set CurQuestion = Nothing
			end if
				
		Loop
		
		'End Display of Questions
		Response.Write "</select>" & vbcrlf
		
	End Function

End Class
%>
