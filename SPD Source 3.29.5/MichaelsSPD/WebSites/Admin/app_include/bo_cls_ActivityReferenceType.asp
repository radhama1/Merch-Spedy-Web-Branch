<%
'==============================================================================
' CLASS: cls_ActivityReferenceType
' Generated using CodeSmith on Tuesday, October 17, 2006
' By ken.wallace
'==============================================================================
'
' This object represents properties and methods for interacting with the Activity Type class.  
'
'	:: Properties
'	Content_Category
'	Content_Document
'	Websites_Website
'	Websites_Document
'	Security_Login
'
'	SPEDY_Tax_UDA
'	SPEDY_Tax_Question
'==============================================================================
Class cls_ActivityReferenceType
	'Private, class member variable
	Private m_Content_Category
	Private m_Content_Document
	Private m_Websites_Website
	Private m_Websites_Document
	Private m_Security_Login
	
	Private m_SPEDY_Tax_UDA
	Private m_SPEDY_Tax_Question
	Private m_SPEDY_Workflow
	
	private m_Custom_Field
	private m_Validation_Rule

	Private Sub Class_Initialize()
		
		'Set Type IDs
		m_Content_Category = 1
		m_Content_Document = 2
		m_Websites_Website = 3
		m_Websites_Document = 4
		m_Security_Login = 5
		
		m_SPEDY_Tax_UDA = 6
		m_SPEDY_Tax_Question = 7
		m_SPEDY_Workflow = 8
		
		m_Custom_Field = 9
		m_Validation_Rule = 10
		
	End Sub

	Private Sub Class_Terminate()
		'Nothing To Do
	End Sub

	Public Property Get Content_Category()
		Content_Category = m_Content_Category
	End Property

	Public Property Get Content_Document()
		Content_Document = m_Content_Document
	End Property
	
	Public Property Get Websites_Website()
		Websites_Website = m_Websites_Website
	End Property

	Public Property Get Websites_Document()
		Websites_Document = m_Websites_Document
	End Property
	
	Public Property Get Security_Login()
		Security_Login = m_Security_Login
	End Property
	
	Public Property Get SPEDY_Tax_UDA()
		SPEDY_Tax_UDA = m_SPEDY_Tax_UDA
	End Property
	
	Public Property Get SPEDY_Tax_Question()
		SPEDY_Tax_Question = m_SPEDY_Tax_Question
	End Property
	
	Public Property Get SPEDY_Workflow()
	    SPEDY_Workflow = m_SPEDY_Workflow
	End Property
	
	Public Property Get Custom_Field()
	    Custom_Field = m_Custom_Field
	End Property
	
	Public Property Get Validation_Rule()
	    Validation_Rule = m_Validation_Rule
	End Property

End Class
%>
