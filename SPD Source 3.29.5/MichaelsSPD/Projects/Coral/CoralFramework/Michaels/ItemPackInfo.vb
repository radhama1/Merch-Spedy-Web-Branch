
Namespace Michaels

    Public Structure ItemPackInfo

        Private _isPack As Boolean
        Private _isPackWithDisplayer As Boolean
        Private _isPackWithDisplayPack As Boolean
        Private _isPackParent As Boolean

        Public Property IsPack() As Boolean
            Get
                Return _isPack
            End Get
            Set(ByVal value As Boolean)
                _isPack = value
            End Set
        End Property

        Public Property IsPackWithDisplayer() As Boolean
            Get
                Return _isPackWithDisplayer
            End Get
            Set(ByVal value As Boolean)
                _isPackWithDisplayer = value
            End Set
        End Property

        Public Property IsPackWithDisplayPack() As Boolean
            Get
                Return _isPackWithDisplayPack
            End Get
            Set(ByVal value As Boolean)
                _isPackWithDisplayPack = value
            End Set
        End Property

        Public Property IsPackParent() As Boolean
            Get
                Return _isPackParent
            End Get
            Set(ByVal value As Boolean)
                _isPackParent = value
            End Set
        End Property

    End Structure

End Namespace

