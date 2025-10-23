
Namespace Michaels

    Public Structure CountryOfOrigin

        Private _countryCode As String
        Private _countryName As String

        Public Property CountryCode() As String
            Get
                Return _countryCode
            End Get
            Set(ByVal value As String)
                _countryCode = value
            End Set
        End Property

        Public Property CountryName() As String
            Get
                Return _countryName
            End Get
            Set(ByVal value As String)
                _countryName = value
            End Set
        End Property

        Public Sub SetValues(ByVal countryCode, ByVal countryName)
            _countryCode = countryCode
            _countryName = countryName
        End Sub

    End Structure

End Namespace

