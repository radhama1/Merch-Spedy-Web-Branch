
Namespace Michaels

    Public Class NewItemBatchRecord

        Private _vendor As String
        Private _batch_type_desc As String
        Private _header_ID As String
        Private _ID As Long
        Private _dept As String
        Private _dateCreated As String
        Private _dateModified As String
        Private _valid As String
        Private _workflow_Stage As String
        Private _approval_Name As String
        Private _workflow_Stage_ID As String
        Private _stage_Type_ID As String
        Private _stage_Sequence As String
        Private _dept_ID As String
        Private _enabled As Boolean
        Private _item_Count As Integer
        Private _createdBy As Long

        Public Property Vendor() As String
            Get
                Return _vendor
            End Get
            Set(ByVal value As String)
                _vendor = value
            End Set
        End Property

        Public Property Batch_Type_Desc() As String
            Get
                Return _batch_type_desc
            End Get
            Set(ByVal value As String)
                _batch_type_desc = value
            End Set
        End Property

        Public Property Header_ID() As String
            Get
                Return _header_ID
            End Get
            Set(ByVal value As String)
                _header_ID = value
            End Set
        End Property

        Public Property ID() As String
            Get
                Return _ID
            End Get
            Set(ByVal value As String)
                _ID = value
            End Set
        End Property

        Public Property Dept() As String
            Get
                Return _dept
            End Get
            Set(ByVal value As String)
                _dept = value
            End Set
        End Property

        Public Property DateCreated() As String
            Get
                Return _dateCreated
            End Get
            Set(ByVal value As String)
                _dateCreated = value
            End Set
        End Property

        Public Property DateModified() As String
            Get
                Return _dateModified
            End Get
            Set(ByVal value As String)
                _dateModified = value
            End Set
        End Property

        Public Property Valid() As String
            Get
                Return _Valid
            End Get
            Set(ByVal value As String)
                _Valid = value
            End Set
        End Property

        Public Property Workflow_Stage() As String
            Get
                Return _workflow_Stage
            End Get
            Set(ByVal value As String)
                _workflow_Stage = value
            End Set
        End Property

        Public Property Approval_Name() As String
            Get
                Return _approval_Name
            End Get
            Set(ByVal value As String)
                _approval_Name = value
            End Set
        End Property

        Public Property Workflow_Stage_ID() As String
            Get
                Return _workflow_Stage_ID
            End Get
            Set(ByVal value As String)
                _workflow_Stage_ID = value
            End Set
        End Property

        Public Property Stage_Type_ID() As String
            Get
                Return _stage_Type_ID
            End Get
            Set(ByVal value As String)
                _stage_Type_ID = value
            End Set
        End Property

        Public Property Stage_Sequence() As String
            Get
                Return _stage_Sequence
            End Get
            Set(ByVal value As String)
                _stage_Sequence = value
            End Set
        End Property

        Public Property Dept_ID() As String
            Get
                Return _dept_ID
            End Get
            Set(ByVal value As String)
                _dept_ID = value
            End Set
        End Property

        Public Property Enabled() As String
            Get
                Return _enabled
            End Get
            Set(ByVal value As String)
                _enabled = value
            End Set
        End Property

        Public Property Item_Count() As Integer
            Get
                Return _item_Count
            End Get
            Set(ByVal value As Integer)
                _item_Count = value
            End Set
        End Property

        Public Property CreatedBy() As Long
            Get
                Return _createdBy
            End Get
            Set(ByVal value As Long)
                _createdBy = value
            End Set
        End Property

        ' Constructors
        Public Sub New()
            _vendor = String.Empty
            _batch_type_desc = String.Empty
            _header_ID = String.Empty
            _ID = Long.MinValue
            _dept = String.Empty
            _dateCreated = String.Empty
            _dateModified = String.Empty
            _Valid = String.Empty
            _workflow_Stage = String.Empty
            _approval_Name = String.Empty
            _workflow_Stage_ID = String.Empty
            _stage_Type_ID = String.Empty
            _stage_Sequence = String.Empty
            _dept_ID = String.Empty
            _enabled = True
            _item_Count = Integer.MinValue
            _createdBy = Long.MinValue

        End Sub

        Public Sub New(ByVal vendor As String, ByVal batch_Type_Desc As String, ByVal header_ID As String, ByVal ID As Long, _
            ByVal dept As String, ByVal dateCreated As String, ByVal dateModified As String, ByVal valid As String, _
            ByVal workflow_Stage As String, ByVal approval_Name As String, ByVal workflow_Stage_ID As String, _
            ByVal stage_Type_ID As String, ByVal stage_Sequence As String, ByVal dept_ID As String, _
            ByVal enabled As Boolean, ByVal item_Count As Integer, ByVal createdBy As Long)

            Me._vendor = vendor
            Me._batch_type_desc = batch_Type_Desc
            Me._header_ID = header_ID
            Me._ID = ID
            Me._dept = dept
            Me._dateCreated = dateCreated
            Me._dateModified = dateModified
            Me._valid = valid
            Me._workflow_Stage = workflow_Stage
            Me._approval_Name = approval_Name
            Me._workflow_Stage_ID = workflow_Stage_ID
            Me._stage_Type_ID = stage_Type_ID
            Me._stage_Sequence = stage_Sequence
            Me._dept_ID = dept_ID
            Me._enabled = enabled
            Me._item_Count = item_Count
            Me._createdBy = createdBy
        End Sub
    End Class

    Public Class IMBatchRecord
        Private _vendor As String
        Private _workflowID As Integer
        Private _batch_type_desc As String
        Private _header_ID As String
        Private _ID As Long
        Private _dept As String
        Private _dateCreated As String
        Private _dateModified As String
        Private _valid As String
        Private _workflow_Stage As String
        Private _approval_Name As String
        Private _workflow_Stage_ID As String
        Private _stage_Type_ID As String
        Private _stage_Sequence As String
        Private _dept_ID As String
        Private _enabled As Boolean
        Private _item_Count As Integer
        Private _stock_category As String
        Private _item_type_attribute As String
        Private _createdBy As Long

        Public Property Vendor() As String
            Get
                Return _vendor
            End Get
            Set(ByVal value As String)
                _vendor = value
            End Set
        End Property

        Public Property WorkflowID() As Integer
            Get
                Return _workflowID
            End Get
            Set(ByVal value As Integer)
                _workflowID = value
            End Set
        End Property

        Public Property Batch_Type_Desc() As String
            Get
                Return _batch_type_desc
            End Get
            Set(ByVal value As String)
                _batch_type_desc = value
            End Set
        End Property

        Public Property Header_ID() As String
            Get
                Return _header_ID
            End Get
            Set(ByVal value As String)
                _header_ID = value
            End Set
        End Property

        Public Property ID() As String
            Get
                Return _ID
            End Get
            Set(ByVal value As String)
                _ID = value
            End Set
        End Property

        Public Property Dept() As String
            Get
                Return _dept
            End Get
            Set(ByVal value As String)
                _dept = value
            End Set
        End Property

        Public Property DateCreated() As String
            Get
                Return _dateCreated
            End Get
            Set(ByVal value As String)
                _dateCreated = value
            End Set
        End Property

        Public Property DateModified() As String
            Get
                Return _dateModified
            End Get
            Set(ByVal value As String)
                _dateModified = value
            End Set
        End Property

        Public Property Valid() As String
            Get
                Return _valid
            End Get
            Set(ByVal value As String)
                _valid = value
            End Set
        End Property

        Public Property Workflow_Stage() As String
            Get
                Return _workflow_Stage
            End Get
            Set(ByVal value As String)
                _workflow_Stage = value
            End Set
        End Property

        Public Property Approval_Name() As String
            Get
                Return _approval_Name
            End Get
            Set(ByVal value As String)
                _approval_Name = value
            End Set
        End Property

        Public Property Workflow_Stage_ID() As String
            Get
                Return _workflow_Stage_ID
            End Get
            Set(ByVal value As String)
                _workflow_Stage_ID = value
            End Set
        End Property

        Public Property Stage_Type_ID() As String
            Get
                Return _stage_Type_ID
            End Get
            Set(ByVal value As String)
                _stage_Type_ID = value
            End Set
        End Property

        Public Property Stage_Sequence() As String
            Get
                Return _stage_Sequence
            End Get
            Set(ByVal value As String)
                _stage_Sequence = value
            End Set
        End Property

        Public Property Dept_ID() As String
            Get
                Return _dept_ID
            End Get
            Set(ByVal value As String)
                _dept_ID = value
            End Set
        End Property

        Public Property Enabled() As String
            Get
                Return _enabled
            End Get
            Set(ByVal value As String)
                _enabled = value
            End Set
        End Property

        Public Property Item_Count() As Integer
            Get
                Return _item_Count
            End Get
            Set(ByVal value As Integer)
                _item_Count = value
            End Set
        End Property

        Public Property Stock_Category() As String
            Get
                Return _stock_category
            End Get
            Set(ByVal value As String)
                _stock_category = value
            End Set
        End Property

        Public Property Item_Type_Attribute() As String
            Get
                Return _item_type_attribute
            End Get
            Set(ByVal value As String)
                _item_type_attribute = value
            End Set
        End Property

        Public Property CreatedBy() As Long
            Get
                Return _createdBy
            End Get
            Set(ByVal value As Long)
                _createdBy = value
            End Set
        End Property

        ' Constructors
        Public Sub New()
            _vendor = String.Empty
            _batch_type_desc = String.Empty
            _header_ID = String.Empty
            _ID = Long.MinValue
            _dept = String.Empty
            _dateCreated = String.Empty
            _dateModified = String.Empty
            _valid = String.Empty
            _workflow_Stage = String.Empty
            _approval_Name = String.Empty
            _workflow_Stage_ID = String.Empty
            _stage_Type_ID = String.Empty
            _stage_Sequence = String.Empty
            _dept_ID = String.Empty
            _enabled = True
            _item_Count = Integer.MinValue
            _createdBy = Long.MinValue

        End Sub

        Public Sub New(ByVal vendor As String, ByVal batch_Type_Desc As String, ByVal header_ID As String, ByVal ID As Long, _
            ByVal dept As String, ByVal dateCreated As String, ByVal dateModified As String, ByVal valid As String, _
            ByVal workflow_Stage As String, ByVal approval_Name As String, ByVal workflow_Stage_ID As String, _
            ByVal stage_Type_ID As String, ByVal stage_Sequence As String, ByVal dept_ID As String, _
            ByVal enabled As Boolean, ByVal item_Count As Integer, ByVal createdBy As Long)

            Me._vendor = vendor
            Me._batch_type_desc = batch_Type_Desc
            Me._header_ID = header_ID
            Me._ID = ID
            Me._dept = dept
            Me._dateCreated = dateCreated
            Me._dateModified = dateModified
            Me._valid = valid
            Me._workflow_Stage = workflow_Stage
            Me._approval_Name = approval_Name
            Me._workflow_Stage_ID = workflow_Stage_ID
            Me._stage_Type_ID = stage_Type_ID
            Me._stage_Sequence = stage_Sequence
            Me._dept_ID = dept_ID
            Me._enabled = enabled
            Me._item_Count = item_Count
            Me._createdBy = createdBy
        End Sub

    End Class


End Namespace





