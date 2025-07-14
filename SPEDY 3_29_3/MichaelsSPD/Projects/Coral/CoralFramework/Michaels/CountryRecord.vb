
Namespace Michaels

    Public Class CountryRecord
        Private _country As CountryOfOrigin

        Public Sub New()
            _country.CountryName = String.Empty
            _country.CountryCode = String.Empty
        End Sub
        Public Sub New(ByVal countryName As String, ByVal countryCode As String)
            _country.CountryName = countryName
            _country.CountryCode = countryCode
        End Sub

        Public Property CountryName() As String
            Get
                Return _country.CountryName
            End Get
            Set(ByVal value As String)
                _country.CountryName = value
            End Set
        End Property
        Public Property CountryCode() As String
            Get
                Return _country.CountryCode
            End Get
            Set(ByVal value As String)
                _country.CountryCode = value
            End Set
        End Property
    End Class

End Namespace
