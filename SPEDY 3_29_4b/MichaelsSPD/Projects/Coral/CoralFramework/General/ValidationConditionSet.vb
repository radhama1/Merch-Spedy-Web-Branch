
Imports NovaLibra.Common
Imports NovaLibra.Common.Utilities

Public Class ValidationConditionSet
    Private _ID As Integer = Integer.MinValue
    Private _ruleType As ValidationRuleType = ValidationRuleType.TypeCustom
    Private _errorText As String = String.Empty
    Private _conditions As ArrayList
    Private _stages As ArrayList
    Private _rule As ValidationRule = Nothing
    Private _errorSeverity As ValidationRuleSeverityType = ValidationRuleSeverityType.typeUnknown

    Public Sub New()
        init()
    End Sub

    Public Sub New(ByVal ruleType As ValidationRuleType, ByVal errorText As String, ByVal errorSeverity As ValidationRuleSeverityType)
        _ruleType = ruleType
        _errorText = errorText
        init()
    End Sub

    Public Sub New(ByVal ID As Integer, ByVal ruleType As ValidationRuleType, ByVal errorText As String, ByVal errorSeverity As ValidationRuleSeverityType)
        _ID = ID
        _ruleType = ruleType
        _errorText = errorText
        init()
    End Sub

    Public Sub New(ByVal ID As Integer, ByVal ruleType As ValidationRuleType, ByVal errorText As String, ByRef rule As ValidationRule, ByVal errorSeverity As ValidationRuleSeverityType)
        _ID = ID
        _ruleType = ruleType
        _errorText = errorText
        init()
        _rule = rule
        _errorSeverity = errorSeverity
    End Sub

    Protected Overrides Sub Finalize()
        If Not _conditions Is Nothing Then
            _conditions.Clear()
        End If
        _conditions = Nothing
        If Not _stages Is Nothing Then
            _stages.Clear()
        End If
        _stages = Nothing
        MyBase.Finalize()
    End Sub

    Private Sub init()
        _conditions = New ArrayList
        _stages = New ArrayList
    End Sub

    Public Property ID() As Integer
        Get
            Return _ID
        End Get
        Set(ByVal value As Integer)
            _ID = value
        End Set
    End Property

    Public Property RuleType() As ValidationRuleType
        Get
            Return _ruleType
        End Get
        Set(ByVal value As ValidationRuleType)
            _ruleType = value
        End Set
    End Property

    Public Property ErrorText() As String
        Get
            Return _errorText
        End Get
        Set(ByVal value As String)
            _errorText = value
        End Set
    End Property

    Public Property ErrorSeverity() As ValidationRuleSeverityType
        Get
            Return _errorSeverity
        End Get
        Set(ByVal value As ValidationRuleSeverityType)
            _errorSeverity = value
        End Set
    End Property

    ' Conditions

    Public Property Condition(ByVal index As Integer) As ValidationCondition
        Get
            Dim obj As ValidationCondition = Nothing
            If index >= 0 AndAlso index < _conditions.Count Then
                obj = CType(_conditions.Item(index), ValidationCondition)
            End If
            Return obj
        End Get
        Set(ByVal value As ValidationCondition)
            If index >= 0 AndAlso index < _conditions.Count Then
                _conditions.Item(index) = value
            End If
        End Set
    End Property

    Public ReadOnly Property Conditions() As ArrayList
        Get
            Return _conditions
        End Get
    End Property

    Public ReadOnly Property ConditionCount() As Integer
        Get
            Return _conditions.Count
        End Get
    End Property

    Public Sub AddCondition(ByRef condition As ValidationCondition)
        _conditions.Add(condition)
    End Sub

    ' Stages

    Public Property Stage(ByVal index As Integer) As Integer
        Get
            Dim value As Integer = 0
            If index >= 0 AndAlso index < _stages.Count Then
                value = _stages.Item(index)
            End If
            Return value
        End Get
        Set(ByVal value As Integer)
            If index >= 0 AndAlso index < _stages.Count Then
                _stages.Item(index) = value
            End If
        End Set
    End Property

    Public ReadOnly Property Stages() As ArrayList
        Get
            Return _stages
        End Get
    End Property

    Public ReadOnly Property StageCount() As Integer
        Get
            Return _stages.Count
        End Get
    End Property

    Public Sub AddStage(ByVal stage As Integer)
        _stages.Add(stage)
    End Sub

    Public Function StageExists(ByVal stage As Integer) As Boolean
        Dim found As Boolean = False
        For i As Integer = 0 To _stages.Count - 1 Step 1
            If _stages.Item(i) = stage Then
                found = True
                Exit For
            End If
        Next
        Return found
    End Function

    Public Property Rule() As ValidationRule
        Get
            Return _rule
        End Get
        Set(ByVal value As ValidationRule)
            _rule = value
        End Set
    End Property

End Class
