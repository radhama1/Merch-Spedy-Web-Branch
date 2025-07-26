Imports System.Text

Namespace Michaels

    Public Class ItemMaintItemDetailRecordList
        ' private fields
        Private _totalRecords As Integer
        Private _listRecords As ArrayList

        ' constructors
        Public Sub New()
            _totalRecords = 0
            _listRecords = New ArrayList
        End Sub

        ' public properties
        Public Property TotalRecords() As Integer
            Get
                Return _totalRecords
            End Get
            Set(ByVal value As Integer)
                _totalRecords = value
            End Set
        End Property

        Public Property ListRecords() As ArrayList
            Get
                Return _listRecords
            End Get
            Set(ByVal value As ArrayList)
                _listRecords = value
            End Set
        End Property

        Public ReadOnly Property RecordCount() As Integer
            Get
                Return _listRecords.Count
            End Get
        End Property

        Public Property Item(ByVal index As Integer) As ItemMaintItemDetailFormRecord
            Get
                Dim rec As ItemMaintItemDetailFormRecord = Nothing
                If _listRecords.Count >= 0 And index >= 0 And index < _listRecords.Count Then
                    rec = _listRecords(index)
                End If
                Return rec
            End Get
            Set(ByVal value As ItemMaintItemDetailFormRecord)
                If _listRecords.Count >= 0 And index >= 0 And index < _listRecords.Count Then
                    _listRecords(index) = value
                End If
            End Set
        End Property

        Public ReadOnly Property ItemByID(ByVal ID As Integer) As ItemMaintItemDetailFormRecord
            Get
                Dim rec As ItemMaintItemDetailFormRecord = Nothing
                For i As Integer = 0 To _listRecords.Count - 1
                    If CType(_listRecords(i), ItemMaintItemDetailFormRecord).ID = ID Then
                        rec = _listRecords(i)
                    End If
                Next
                Return rec
            End Get
        End Property

        ' methods

        Public Sub AddAdditionalUPC(ByVal ID As Integer, ByVal UPC As String)
            Dim formRec As ItemMaintItemDetailFormRecord = ItemByID(ID)
            If formRec IsNot Nothing Then formRec.AdditionalUPCRecs.Add(New ItemMasterVendorUPCRecord(UPC))
        End Sub

        Public Sub AddAdditionalCOO(ByVal ID As Integer, ByVal countryOfOrigin As String, ByVal countryOfOriginName As String)
            Dim formRec As ItemMaintItemDetailFormRecord = ItemByID(ID)
            If formRec IsNot Nothing Then formRec.AdditionalCOORecs.Add(New ItemMasterVendorCountryRecord(countryOfOrigin, countryOfOriginName))
        End Sub

        Public Function GetRecordIDs() As String
            Dim i As Integer
            Dim sb As New StringBuilder("")
            Dim id As String
            If Not _listRecords Is Nothing Then
                For i = 0 To _listRecords.Count - 1
                    If i > 0 Then sb.Append(",")
                    sb.Append(Me.Item(i).ID.ToString())
                Next
            End If
            id = sb.ToString()
            sb = Nothing
            Return id
        End Function

        Public Sub ClearList()
            _listRecords.Clear()
        End Sub

        ' destructors
        Protected Overrides Sub Finalize()
            If Not _listRecords Is Nothing Then
                _listRecords.Clear()
            End If
            _listRecords = Nothing
            MyBase.Finalize()
        End Sub

    End Class

End Namespace

