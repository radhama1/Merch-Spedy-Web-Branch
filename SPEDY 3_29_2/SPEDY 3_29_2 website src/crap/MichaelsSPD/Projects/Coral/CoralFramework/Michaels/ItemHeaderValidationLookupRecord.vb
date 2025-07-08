
Namespace Michaels

    Public Class ItemHeaderValidationLookupRecord
        Private _dept As Integer = 0
        Private _deptValid As Boolean = False
        Private _USVendorNum As Integer = 0
        Private _USVendorType As String = String.Empty
        Private _USVendorNumValid As Boolean = False
        Private _canadianVendorNum As Integer = 0
        Private _canadianVendorType As String = String.Empty
        Private _canadianVendorNumValid As Boolean = False

        Public Sub New()

        End Sub

        Public Sub New(ByVal dept As Integer, ByVal USVendorNum As Integer, ByVal canadianVendorNum As Integer)
            _dept = dept
            _USVendorNum = USVendorNum
            _canadianVendorNum = canadianVendorNum
        End Sub

        Public Property Dept() As Integer
            Get
                Return _dept
            End Get
            Set(ByVal value As Integer)
                _dept = value
            End Set
        End Property
        Public Property DeptValid() As Boolean
            Get
                Return _deptValid
            End Get
            Set(ByVal value As Boolean)
                _deptValid = value
            End Set
        End Property
        Public Property USVendorNum() As Integer
            Get
                Return _USVendorNum
            End Get
            Set(ByVal value As Integer)
                _USVendorNum = value
            End Set
        End Property
        Public Property USVendorType() As String
            Get
                Return _USVendorType
            End Get
            Set(ByVal value As String)
                _USVendorType = value
            End Set
        End Property
        Public Property USVendorNumValid() As Boolean
            Get
                Return _USVendorNumValid
            End Get
            Set(ByVal value As Boolean)
                _USVendorNumValid = value
            End Set
        End Property
        Public Property CanadianVendorNum() As Integer
            Get
                Return _canadianVendorNum
            End Get
            Set(ByVal value As Integer)
                _canadianVendorNum = value
            End Set
        End Property
        Public Property CanadianVendorType() As String
            Get
                Return _canadianVendorType
            End Get
            Set(ByVal value As String)
                _canadianVendorType = value
            End Set
        End Property
        Public Property CanadianVendorNumValid() As Boolean
            Get
                Return _canadianVendorNumValid
            End Get
            Set(ByVal value As Boolean)
                _canadianVendorNumValid = value
            End Set
        End Property

    End Class

End Namespace


