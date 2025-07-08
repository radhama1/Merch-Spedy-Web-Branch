
Namespace Michaels

    Public Class BatchRecord

        Private _ID As Long = Long.MinValue
        Private _VendorName As String = String.Empty
        Private _VendorNumber As Long = Long.MinValue
        Private _BatchTypeID As Integer = Integer.MinValue
        Private _WorkflowStageID As Integer = Integer.MinValue
        Private _WorkflowStageName As String = String.Empty
        Private _workflowStageType As WorkflowStageType = WorkflowStageType.General
        Private _FinelineDeptID As Integer = Integer.MinValue
        Private _Enabled As Boolean = True
        Private _IsValid As Integer = Integer.MinValue
        Private _BatchValid As Integer = Integer.MinValue

        Private _DateCreated As Date = Date.MinValue
        Private _CreatedUserName As String = String.Empty
        Private _DateLastModified As Date = Date.MinValue
        Private _UpdatedUserName As String = String.Empty

        Private _CreatedUser As Integer = Integer.MinValue
        Private _UpdateUser As Integer = Integer.MinValue
        ' FJL Apr 2010 used to determine new stage
        Private _WorkflowID As Integer = Integer.MinValue
        Private _EffectiveDate As String = String.Empty
        Private _BatchName As String = String.Empty
        Private _stockCategory As String = String.Empty
        Private _itemTypeAttribute As String = String.Empty
        Private _packType As String = String.Empty
        Private _packSKU As String = String.Empty

        Private _BatchTypeDesc As String = String.Empty

        Public Property ID() As Long
            Get
                Return _ID
            End Get
            Set(ByVal value As Long)
                _ID = value
            End Set
        End Property

        Public Property PackSKU() As String
            Get
                Return _packSKU
            End Get
            Set(ByVal value As String)
                _packSKU = value
            End Set
        End Property

        Public Property VendorName() As String
            Get
                Return _VendorName
            End Get
            Set(ByVal value As String)
                _VendorName = value
            End Set
        End Property

        Public Property VendorNumber() As String
            Get
                Return _VendorNumber
            End Get
            Set(ByVal value As String)
                _VendorNumber = value
            End Set
        End Property
        Public Property BatchTypeID() As Integer
            Get
                Return _BatchTypeID
            End Get
            Set(ByVal value As Integer)
                _BatchTypeID = value
            End Set
        End Property
        Public Property BatchTypeDesc() As String
            Get
                Return _BatchTypeDesc
            End Get
            Set(value As String)
                _BatchTypeDesc = value
            End Set
        End Property
        Public Property WorkflowStageID() As Integer
            Get
                Return _WorkflowStageID
            End Get
            Set(ByVal value As Integer)
                _WorkflowStageID = value
            End Set
        End Property
        Public Property FinelineDeptID() As Integer
            Get
                Return _FinelineDeptID
            End Get
            Set(ByVal value As Integer)
                _FinelineDeptID = value
            End Set
        End Property
        Public Property Enabled() As Boolean
            Get
                Return _Enabled
            End Get
            Set(ByVal value As Boolean)
                _Enabled = value
            End Set
        End Property
        Public Property IsValid() As Integer
            Get
                Return _IsValid
            End Get
            Set(ByVal value As Integer)
                _IsValid = value
            End Set
        End Property
        Public Property BatchValid() As Integer
            Get
                Return _BatchValid
            End Get
            Set(ByVal value As Integer)
                If value = Integer.MinValue Then
                    _BatchValid = -1
                Else
                    _BatchValid = value
                End If
            End Set
        End Property

        Public ReadOnly Property CreatedUserName() As String
            Get
                Return _CreatedUserName
            End Get
        End Property
        Public ReadOnly Property UpdatedUserName() As String
            Get
                Return _UpdatedUserName
            End Get
        End Property
        Public ReadOnly Property DateCreated() As Date
            Get
                Return _DateCreated
            End Get
        End Property

        Public ReadOnly Property DateLastModified() As Date
            Get
                Return _DateLastModified
            End Get
        End Property

        Public ReadOnly Property CreatedUser() As Integer
            Get
                Return _CreatedUser
            End Get
        End Property

        Public ReadOnly Property UpdateUser() As Integer
            Get
                Return _UpdateUser
            End Get
        End Property
        Public ReadOnly Property WorkflowStageName() As String
            Get
                Return _WorkflowStageName
            End Get
        End Property
        Public ReadOnly Property WorkflowStageType() As WorkflowStageType
            Get
                Return _workflowStageType
            End Get
        End Property

        Public Property WorkflowID() As Integer
            Get
                Return _WorkflowID
            End Get
            Set(ByVal value As Integer)
                _WorkflowID = value
            End Set
        End Property

        Public Property EffectiveDate() As String
            Get
                Return _EffectiveDate
            End Get
            Set(ByVal value As String)
                _EffectiveDate = value
            End Set
        End Property

        Public Property BatchName() As String
            Get
                Return _BatchName
            End Get
            Set(ByVal value As String)
                _BatchName = value
            End Set
        End Property

        Public Property StockCategory() As String
            Get
                Return _stockCategory
            End Get
            Set(ByVal value As String)
                _stockCategory = value
            End Set
        End Property

        Public Property ItemTypeAttribute() As String
            Get
                Return _itemTypeAttribute
            End Get
            Set(ByVal value As String)
                _itemTypeAttribute = value
            End Set
        End Property

        Public Property PackType() As String
            Get
                Return _packType
            End Get
            Set(ByVal value As String)
                _packType = UCase(value)
            End Set
        End Property

        Public Function IsPack() As Boolean
            If PackType.ToUpper().Trim() = "D" Or PackType.ToUpper().Trim() = "DP" Or PackType.ToUpper().Trim() = "SB" Then
                Return True
            Else
                Return False
            End If
        End Function

        Public Function IsDomesticBatch() As Boolean
            If BatchTypeID = BatchTypes.Domestic Then
                Return True
            Else
                Return False
            End If
        End Function

        Public Function IsImportBatch() As Boolean
            If BatchTypeID = BatchTypes.Import Then
                Return True
            Else
                Return False
            End If
        End Function

        Public Function IsDomesticPack() As Boolean
            If Me.IsPack AndAlso Me.IsDomesticBatch Then
                Return True
            Else
                Return False
            End If
        End Function

        Public Function IsImportPack() As Boolean
            If Me.IsPack AndAlso Me.IsImportBatch Then
                Return True
            Else
                Return False
            End If
        End Function

        Protected Friend Sub SetReadOnlyData(ByVal dateCreated As Date, _
            ByVal createdUserID As Integer, _
            ByVal dateLastModified As Date, _
            ByVal updateUserID As Integer, _
            ByVal createdUser As String, _
            ByVal updatedUser As String, _
            ByVal workflowName As String, _
            ByVal stageType As Integer)

            _DateCreated = dateCreated
            _CreatedUser = createdUserID
            _DateLastModified = dateLastModified
            _UpdateUser = updateUserID
            _CreatedUserName = createdUser
            _UpdatedUserName = updatedUser
            _WorkflowStageName = workflowName
            If Michaels.WorkflowStageType.IsDefined(GetType(Michaels.WorkflowStageType), stageType) Then
                _workflowStageType = CType(stageType, Michaels.WorkflowStageType)
            Else
                _workflowStageType = Michaels.WorkflowStageType.General
            End If

        End Sub

        Public Enum BatchTypes As Short
            Domestic = 1
            Import = 2
        End Enum

        Public Sub New()

        End Sub
    End Class

End Namespace

