
Namespace Michaels

    Public Class ItemMasterVendorUPCRecord
        Private _UPC As String = String.Empty
        'Private _primaryIndicator As Boolean = False

        Public Sub New()
        End Sub

        Public Sub New(ByVal UPCValue As String)
            Me._UPC = UPCValue
        End Sub

        'Public Sub New(ByVal counter As Integer, ByVal UPC As String)
        '    _counter = counter
        '    _UPC = UPC
        'End Sub

        'Public Property IsPrimary() As Boolean
        '    Get
        '        Return _primaryIndicator
        '    End Get
        '    Set(ByVal value As Boolean)
        '        _primaryIndicator = value
        '    End Set
        'End Property

        'Public Property Counter() As Integer
        '    Get
        '        Return _counter
        '    End Get
        '    Set(ByVal value As Integer)
        '        _counter = value
        '    End Set
        'End Property

        Public Property UPC() As String
            Get
                Return _UPC
            End Get
            Set(ByVal value As String)
                _UPC = value
            End Set
        End Property

        Public Function Clone() As ItemMasterVendorUPCRecord
            Return New ItemMasterVendorUPCRecord(Me.UPC)
        End Function
    End Class

End Namespace

