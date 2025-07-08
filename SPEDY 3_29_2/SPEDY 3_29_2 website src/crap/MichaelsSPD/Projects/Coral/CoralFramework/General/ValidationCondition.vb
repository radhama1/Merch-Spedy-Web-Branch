
Imports NovaLibra.Common
Imports NovaLibra.Common.Utilities

Public Class ValidationCondition
    Private _ID As Integer = Integer.MinValue
    Private _conditionType As ValidationConditionType = ValidationConditionType.Unknown
    Private _field1 As Integer = Integer.MinValue
    Private _field2 As Integer = Integer.MinValue
    Private _field3 As Integer = Integer.MinValue
    Private _value1 As String = String.Empty
    Private _value2 As String = String.Empty
    Private _value3 As String = String.Empty
    Private _conditionOperator As String = String.Empty
    Private _conjunction As String = String.Empty
    Private _conditionSet As ValidationConditionSet = Nothing

    Public Sub New()

    End Sub

    Public Sub New(ByRef conditionSet As ValidationConditionSet)
        _conditionSet = conditionSet
    End Sub

    Protected Overrides Sub Finalize()
        _conditionSet = Nothing
        MyBase.Finalize()
    End Sub

    Public Property ID() As Integer
        Get
            Return _ID
        End Get
        Set(ByVal value As Integer)
            _ID = value
        End Set
    End Property

    Public Property ConditionType() As ValidationConditionType
        Get
            Return _conditionType
        End Get
        Set(ByVal value As ValidationConditionType)
            _conditionType = value
        End Set
    End Property

    Public Property Field1() As Integer
        Get
            Return _field1
        End Get
        Set(ByVal value As Integer)
            _field1 = value
        End Set
    End Property

    Public ReadOnly Property Field1IsValid() As Boolean
        Get
            Return (_field1 <> Integer.MinValue)
        End Get
    End Property

    Public Property Field2() As Integer
        Get
            Return _field2
        End Get
        Set(ByVal value As Integer)
            _field2 = value
        End Set
    End Property

    Public ReadOnly Property Field2IsValid() As Boolean
        Get
            Return (_field2 <> Integer.MinValue)
        End Get
    End Property

    Public Property Field3() As Integer
        Get
            Return _field3
        End Get
        Set(ByVal value As Integer)
            _field3 = value
        End Set
    End Property

    Public ReadOnly Property Field3IsValid() As Boolean
        Get
            Return (_field3 <> Integer.MinValue)
        End Get
    End Property

    Public Property Value1() As String
        Get
            Return _value1
        End Get
        Set(ByVal value As String)
            _value1 = value
        End Set
    End Property

    Public Property Value2() As String
        Get
            Return _value2
        End Get
        Set(ByVal value As String)
            _value2 = value
        End Set
    End Property

    Public Property Value3() As String
        Get
            Return _value3
        End Get
        Set(ByVal value As String)
            _value3 = value
        End Set
    End Property

    Public Property ConditionOperator() As String
        Get
            Return _conditionOperator
        End Get
        Set(ByVal value As String)
            _conditionOperator = value
        End Set
    End Property

    Public Property Conjunction() As String
        Get
            Return _conjunction
        End Get
        Set(ByVal value As String)
            _conjunction = value
        End Set
    End Property

    Public ReadOnly Property ConjunctionAND() As Boolean
        Get
            Return (_conjunction.ToUpper() <> "OR")
        End Get
    End Property

    Public ReadOnly Property ConjunctionOR() As Boolean
        Get
            Return (_conjunction.ToUpper() = "OR")
        End Get
    End Property

    Public Property ConditionSet() As ValidationConditionSet
        Get
            Return _conditionSet
        End Get
        Set(ByVal value As ValidationConditionSet)
            _conditionSet = value
        End Set
    End Property

End Class
