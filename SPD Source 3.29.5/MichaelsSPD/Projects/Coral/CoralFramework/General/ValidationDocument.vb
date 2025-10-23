
Imports NovaLibra.Common
Imports NovaLibra.Common.Utilities

Public Class ValidationDocument
    Private _ID As Integer = Integer.MinValue
    Private _type As ValidationDocumentType = ValidationDocumentType.DocumentTypeUnknown
    Private _workflowID As Integer = Integer.MinValue
    Private _metadataTableID As Integer = Integer.MinValue
    Private _document As String = String.Empty
    Private _rules As ArrayList = Nothing
    Private _rulesHash As Hashtable = Nothing

    Public Sub New()
        init()
    End Sub

    Protected Overrides Sub Finalize()
        If Not _rulesHash Is Nothing Then
            _rulesHash.Clear()
            _rulesHash = Nothing
        End If
        If Not _rules Is Nothing Then
            _rules.Clear()
            _rules = Nothing
        End If
        MyBase.Finalize()
    End Sub

    Private Sub init()
        _rules = New ArrayList
        _rulesHash = New Hashtable
    End Sub

    Public Property ID() As Integer
        Get
            Return _ID
        End Get
        Set(ByVal value As Integer)
            _ID = value
        End Set
    End Property

    Public Property DocumentType() As ValidationDocumentType
        Get
            Return _type
        End Get
        Set(ByVal value As ValidationDocumentType)
            _type = value
        End Set
    End Property

    Public Property WorkflowID() As Integer
        Get
            Return _workflowID
        End Get
        Set(ByVal value As Integer)
            _workflowID = value
        End Set
    End Property

    Public Property MetadataTableID() As Integer
        Get
            Return _metadataTableID
        End Get
        Set(ByVal value As Integer)
            _metadataTableID = value
        End Set
    End Property

    Public Property Document() As String
        Get
            Return _document
        End Get
        Set(ByVal value As String)
            _document = value
        End Set
    End Property

    Public Property Rule(ByVal index As Integer) As ValidationRule
        Get
            Dim obj As ValidationRule = Nothing
            If index >= 0 AndAlso index < _rules.Count Then
                obj = CType(_rules.Item(index), ValidationRule)
            End If
            Return obj
        End Get
        Set(ByVal value As ValidationRule)
            If index >= 0 AndAlso index < _rules.Count Then
                _rules.Item(index) = value
            End If
        End Set
    End Property

    Public ReadOnly Property Rules() As ArrayList
        Get
            Return _rules
        End Get
    End Property

    Public ReadOnly Property RuleCount() As Integer
        Get
            Return _rules.Count
        End Get
    End Property

    Public Sub AddRule(ByRef rule As ValidationRule)
        _rules.Add(rule)
        If _rulesHash.Contains(rule.ID) Then
            _rulesHash.Remove(rule.ID)
        End If
        _rulesHash.Add(rule.ID, rule)
    End Sub

    Public Function GetRule(ByVal ruleID As Integer) As ValidationRule
        Dim rule As ValidationRule = Nothing
        If _rulesHash.Contains(ruleID) Then
            rule = CType(_rulesHash.Item(ruleID), ValidationRule)
        End If
        Return rule
    End Function

End Class
