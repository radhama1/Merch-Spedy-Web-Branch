
Namespace Michaels

#Region "ItemMasterChangeRecord"

    Public Class IMChangeRecord
        Private _itemID As Integer
        Private _fieldName As String
        Private _countryOfOrigin As String
        Private _UPC As String
        Private _counter As Integer
        Private _effectiveDate As String
        Private _fieldValue As String
        Private _originalValue As String
        Private _changedByID As Integer
        Private _changedByName As String
        Private _changedDate As String
        Private _hasChanged As Boolean = False
        Private _dontSendToRMS As Boolean = False


        Public Sub New()
            _itemID = Integer.MinValue
            _fieldName = String.Empty
            _countryOfOrigin = String.Empty
            _UPC = String.Empty
            _effectiveDate = String.Empty
            _counter = 0
            _fieldValue = String.Empty
            _originalValue = String.Empty
            _changedByID = Integer.MinValue
            _changedByName = String.Empty
            _changedDate = String.Empty

        End Sub

        Public Sub New(ByVal itemID As Integer, ByVal SKU As String, ByVal fieldName As String, ByVal vendorNumber As Integer, ByVal COO As String, ByVal UPC As String, _
                       ByVal counter As Integer, ByVal effectiveDate As String, ByVal batchID As Integer, ByVal fieldValue As String, ByVal originalValue As String, _
                       ByVal changedByID As Integer, ByVal changedbyName As String, ByVal changedDate As String)

            _itemID = itemID
            _fieldName = fieldName
            _countryOfOrigin = COO
            _UPC = UPC
            _effectiveDate = effectiveDate
            _fieldValue = fieldValue
            _originalValue = originalValue
            _changedByID = changedByID
            _changedByName = changedbyName
            _changedDate = changedDate
            _counter = counter
        End Sub

        Public Property ItemID() As Integer
            Get
                Return _itemID
            End Get
            Set(ByVal value As Integer)
                _itemID = value
            End Set
        End Property

        Public Property FieldName() As String
            Get
                Return _fieldName
            End Get
            Set(ByVal value As String)
                _fieldName = value
            End Set
        End Property

        Public Property CountryOfOrigin() As String
            Get
                Return _countryOfOrigin
            End Get
            Set(ByVal value As String)
                _countryOfOrigin = value
            End Set
        End Property

        Public Property UPC() As String
            Get
                Return _UPC
            End Get
            Set(ByVal value As String)
                _UPC = value
            End Set
        End Property

        Public Property EffectiveDate() As String
            Get
                Return _effectiveDate
            End Get
            Set(ByVal value As String)
                _effectiveDate = value
            End Set
        End Property

        Public Property Counter() As Integer
            Get
                Return _counter
            End Get
            Set(ByVal value As Integer)
                _counter = value
            End Set
        End Property

        Public Property FieldValue() As String
            Get
                Return _fieldValue
            End Get
            Set(ByVal value As String)
                _fieldValue = value
            End Set
        End Property

        Public Property OriginalValue() As String
            Get
                Return _originalValue
            End Get
            Set(ByVal value As String)
                _originalValue = value
            End Set
        End Property

        Public Property ChangedByID() As Integer
            Get
                Return _changedByID
            End Get
            Set(ByVal value As Integer)
                _changedByID = value
            End Set
        End Property

        Public Property ChangedByName() As String
            Get
                Return _changedByName
            End Get
            Set(ByVal value As String)
                _changedByName = value
            End Set
        End Property

        Public Property ChangedDate() As String
            Get
                Return _changedDate
            End Get
            Set(ByVal value As String)
                _changedDate = value
            End Set
        End Property

        Public Property HasChanged() As Boolean
            Get
                Return _hasChanged
            End Get
            Set(ByVal value As Boolean)
                _hasChanged = value
            End Set
        End Property

        Public Property DontSendToRMS() As Boolean
            Get
                Return _dontSendToRMS
            End Get
            Set(ByVal value As Boolean)
                _dontSendToRMS = value
            End Set
        End Property

    End Class
#End Region


#Region "GridChangeRecordObjects"

    Public Class IMCellChangeRecord
        Private _fieldName As String = String.Empty
        Private _fieldValue As String = String.Empty
        Private _hasChanged As Boolean = False
        Private _counter As Integer = 0
        Private _dontSendToRMS As Boolean = False

        Public Sub New()

        End Sub

        Public Sub New(ByVal fieldName As String)
            _fieldName = fieldName
        End Sub

        Public Sub New(ByVal fieldName As String, ByVal fieldValue As String)
            _fieldName = fieldName
            _fieldValue = fieldValue
        End Sub

        Public Sub New(ByVal fieldName As String, ByVal fieldValue As String, ByVal hasChanged As Boolean)
            _fieldName = fieldName
            _fieldValue = fieldValue
            _hasChanged = hasChanged
        End Sub

        Public Sub New(ByVal fieldName As String, ByVal fieldValue As String, ByVal hasChanged As Boolean, ByVal counter As Integer)
            _fieldName = fieldName
            _fieldValue = fieldValue
            _hasChanged = hasChanged
            _counter = counter
        End Sub

        Public Property FieldName() As String
            Get
                Return _fieldName
            End Get
            Set(ByVal value As String)
                _fieldName = value
            End Set
        End Property

        Public Property FieldValue() As String
            Get
                Return _fieldValue
            End Get
            Set(ByVal value As String)
                _fieldValue = value
            End Set
        End Property

        Public Property HasChanged() As Boolean
            Get
                Return _hasChanged
            End Get
            Set(ByVal value As Boolean)
                _hasChanged = value
            End Set
        End Property

        Public Property Counter() As Integer
            Get
                Return _counter
            End Get
            Set(ByVal value As Integer)
                _counter = value
            End Set
        End Property

        Public Property DontSendToRMS() As Boolean
            Get
                Return _dontSendToRMS
            End Get
            Set(ByVal value As Boolean)
                _dontSendToRMS = value
            End Set
        End Property

    End Class


    Public Class IMRowChanges
        Private _ID As Integer
        Private _cellChanges As List(Of IMCellChangeRecord) = Nothing

        Public Sub New()
            _ID = Integer.MinValue
            _cellChanges = New List(Of IMCellChangeRecord)
        End Sub

        Public Sub New(ByVal ID As Integer)
            _ID = ID
            _cellChanges = New List(Of IMCellChangeRecord)
        End Sub

        Public Sub New(ByVal ID As Integer, ByRef CellChangeRecords As List(Of IMCellChangeRecord))
            _ID = ID
            _cellChanges = CellChangeRecords
        End Sub

        Public Property ID() As Integer
            Get
                Return _ID
            End Get
            Set(ByVal value As Integer)
                _ID = value
            End Set
        End Property

        Public Property RowRecords() As List(Of IMCellChangeRecord)
            Get
                Return _cellChanges
            End Get
            Set(ByVal value As List(Of IMCellChangeRecord))
                _cellChanges = value
            End Set
        End Property

        Public Function GetCellChange(ByVal fieldName As String) As IMCellChangeRecord
            Return GetCellChange(fieldName, 0)
        End Function

        Public Function GetCellChange(ByVal fieldName As String, ByVal counter As Integer) As IMCellChangeRecord
            Dim cellChange As IMCellChangeRecord = Nothing
            If _cellChanges.Count > 0 Then
                For i As Integer = 0 To _cellChanges.Count - 1 Step 1
                    If _cellChanges.Item(i).FieldName = fieldName And _cellChanges.Item(i).Counter = counter Then
                        cellChange = _cellChanges.Item(i)
                        Exit For
                    End If
                Next
            End If
            Return cellChange
        End Function

        Public Function ChangeExists(ByVal fieldName As String) As Boolean
            Return ChangeExists(fieldName, 0)
        End Function

        Public Function ChangeExists(ByVal fieldName As String, ByVal counter As Integer) As Boolean
            Dim ret As Boolean = False
            If _cellChanges.Count > 0 Then
                For i As Integer = 0 To _cellChanges.Count - 1 Step 1
                    If _cellChanges.Item(i).FieldName = fieldName And _cellChanges.Item(i).Counter = counter Then
                        ret = True
                        Exit For
                    End If
                Next
            End If
            Return ret
        End Function

        Public Sub MergeChangeRecords(ByRef rowChanges As IMRowChanges)
            MergeChangeRecords(rowChanges, False)
        End Sub

        Public Sub MergeChangeRecords(ByRef rowChanges As IMRowChanges, ByVal onlyIfChanged As Boolean)
            Dim cellList As List(Of IMCellChangeRecord) = rowChanges.RowRecords
            Dim cellChange As IMCellChangeRecord
            For i As Integer = 0 To cellList.Count - 1
                cellChange = cellList.Item(i)
                If Me.ChangeExists(cellChange.FieldName) Then Me.Remove(cellChange.FieldName)
                If onlyIfChanged Then
                    If cellChange.HasChanged Then Me.Add(cellChange)
                Else
                    Me.Add(cellChange)
                End If
            Next
        End Sub

        Public Sub Add(ByRef cellChange As IMCellChangeRecord)
            _cellChanges.Add(cellChange)
        End Sub

        Public Sub Remove(ByVal fieldName As String)
            If _cellChanges IsNot Nothing AndAlso _cellChanges.Count > 0 Then
                For i As Integer = _cellChanges.Count - 1 To 0 Step -1
                    If _cellChanges.Item(i).FieldName = fieldName Then
                        _cellChanges.RemoveAt(i)
                    End If
                Next
            End If
        End Sub

        Public Sub ClearChanges()
            _cellChanges.Clear()
        End Sub

        Public Sub Dispose()
            If _cellChanges IsNot Nothing Then
                _cellChanges.Clear()
            End If
            _cellChanges = Nothing
        End Sub

        Protected Overrides Sub Finalize()
            Me.Dispose()
            MyBase.Finalize()
        End Sub
    End Class


    Public Class IMTableChanges
        Private _tableRowChanges As List(Of IMRowChanges)

        Public Sub New()
            _tableRowChanges = New List(Of IMRowChanges)
        End Sub

        Public ReadOnly Property RowChanges() As List(Of IMRowChanges)
            Get
                Return _tableRowChanges
            End Get
        End Property

        Public Sub Add(ByRef RowChangeRecord As IMRowChanges)
            _tableRowChanges.Add(RowChangeRecord)
        End Sub

        Public Function GetRow(ByVal ID As Integer) As IMRowChanges
            Return GetRow(ID, False)
        End Function

        Public Function GetRow(ByVal ID As Integer, ByVal createNewIfNotFound As Boolean) As IMRowChanges
            For i As Integer = 0 To _tableRowChanges.Count() - 1
                If _tableRowChanges(i).ID = ID Then
                    Return _tableRowChanges(i)
                End If
            Next
            If createNewIfNotFound Then
                Dim rowChanges As New IMRowChanges(ID)
                _tableRowChanges.Add(rowChanges)
                Return rowChanges
            Else
                Return Nothing
            End If
        End Function

        Public Function GetItem(ByVal index As Integer) As IMRowChanges
            If index >= 0 AndAlso index < _tableRowChanges.Count Then
                Return _tableRowChanges(index)
            Else
                Return Nothing
            End If
        End Function

        Public Function Count() As Integer
            Return _tableRowChanges.Count
        End Function

        Public Sub ClearChanges()
            ClearChanges(False)
        End Sub

        Public Sub ClearChanges(ByVal clearRows As Boolean)
            For i As Integer = 0 To _tableRowChanges.Count - 1
                _tableRowChanges.Item(i).ClearChanges()
            Next
            If clearRows Then
                _tableRowChanges.Clear()
            End If
        End Sub

        Public Sub Dispose()
            For i As Integer = 0 To _tableRowChanges.Count() - 1
                _tableRowChanges(i).Dispose()
            Next
            _tableRowChanges.Clear()
            _tableRowChanges = Nothing
        End Sub

    End Class

#End Region

End Namespace

