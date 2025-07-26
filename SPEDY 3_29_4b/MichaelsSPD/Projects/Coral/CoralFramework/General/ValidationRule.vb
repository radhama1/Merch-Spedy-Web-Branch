
Imports NovaLibra.Common
Imports NovaLibra.Common.Utilities

Public Class ValidationRule
    Private _ID As Integer = Integer.MinValue
    Private _validationRule As String = String.Empty
    Private _metadataColumnID As Integer = Integer.MinValue
    Private _conditionSets As ArrayList

    Public Sub New()
        init()
    End Sub

    Public Sub New(ByVal validationRule As Integer, ByVal metadataColumnID As Integer)
        _validationRule = validationRule
        _metadataColumnID = metadataColumnID
        init()
    End Sub

    Public Sub New(ByVal ID As Integer, ByVal validationRule As Integer, ByVal metadataColumnID As Integer)
        _ID = ID
        _validationRule = validationRule
        _metadataColumnID = metadataColumnID
        init()
    End Sub

    Protected Overrides Sub Finalize()
        If Not _conditionSets Is Nothing Then
            _conditionSets.Clear()
        End If
        _conditionSets = Nothing
        MyBase.Finalize()
    End Sub

    Private Sub init()
        _conditionSets = New ArrayList
    End Sub

    Public Property ID() As Integer
        Get
            Return _ID
        End Get
        Set(ByVal value As Integer)
            _ID = value
        End Set
    End Property

    Public Property ValidationRule() As String
        Get
            Return _validationRule
        End Get
        Set(ByVal value As String)
            _validationRule = value
        End Set
    End Property

    Public Property MetadataColumnID() As Integer
        Get
            Return _metadataColumnID
        End Get
        Set(ByVal value As Integer)
            _metadataColumnID = value
        End Set
    End Property

    Public Property ConditionSet(ByVal index As Integer) As ValidationConditionSet
        Get
            Dim obj As ValidationConditionSet = Nothing
            If index >= 0 AndAlso index < _conditionSets.Count Then
                obj = CType(_conditionSets.Item(index), ValidationConditionSet)
            End If
            Return obj
        End Get
        Set(ByVal value As ValidationConditionSet)
            If index >= 0 AndAlso index < _conditionSets.Count Then
                _conditionSets.Item(index) = value
            End If
        End Set
    End Property

    Public ReadOnly Property ConditionSets() As ArrayList
        Get
            Return _conditionSets
        End Get
    End Property

    Public ReadOnly Property ConditionSetCount() As Integer
        Get
            Return _conditionSets.Count
        End Get
    End Property

    Public Sub AddConditionSet(ByRef conditionSet As ValidationConditionSet)
        _conditionSets.Add(conditionSet)
    End Sub

    Public Function GetConditionSet(ByVal conditionSetID As Integer) As ValidationConditionSet
        Dim conditionSet As ValidationConditionSet = Nothing
        For i As Integer = 0 To _conditionSets.Count - 1 Step 1
            If CType(_conditionSets.Item(i), ValidationConditionSet).ID = conditionSetID Then
                conditionSet = CType(_conditionSets.Item(i), ValidationConditionSet)
                Exit For
            End If
        Next
        Return conditionSet
    End Function

End Class

