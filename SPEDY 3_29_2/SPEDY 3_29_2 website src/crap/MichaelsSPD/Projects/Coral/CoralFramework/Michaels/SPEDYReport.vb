
Namespace Michaels

    Public Class SPEDYReport
        Private _ID As Long = Long.MinValue
        Private _reportName As String = String.Empty
        Private _reportSummary As String = String.Empty
        Private _reportConstant As String = String.Empty
        Private _reportSQL As String = String.Empty
        Private _enabled As Boolean = True
        Private _dateRangeLabel As String = String.Empty
        Private _isViewable As Boolean = False
        Private _isEmailable As Boolean = False

        Public Property ID() As Long
            Get
                Return _ID
            End Get
            Set(ByVal value As Long)
                _ID = value
            End Set
        End Property
        Public Property ReportName() As String
            Get
                Return _reportName
            End Get
            Set(ByVal value As String)
                _reportName = value
            End Set
        End Property
        Public Property ReportSummary() As String
            Get
                Return _reportSummary
            End Get
            Set(ByVal value As String)
                _reportSummary = value
            End Set
        End Property
        Public Property ReportConstant() As String
            Get
                Return _reportConstant
            End Get
            Set(ByVal value As String)
                _reportConstant = value
            End Set
        End Property
        Public Property ReportSQL() As String
            Get
                Return _reportSQL
            End Get
            Set(ByVal value As String)
                _reportSQL = value
            End Set
        End Property
        Public Property Enabled() As Boolean
            Get
                Return _enabled
            End Get
            Set(ByVal value As Boolean)
                _enabled = value
            End Set
        End Property

        Public Property DateRangeLabel() As String
            Get
                Return _dateRangeLabel
            End Get
            Set(value As String)
                _dateRangeLabel = value
            End Set
        End Property

        Public Property IsViewable() As Boolean
            Get
                Return _isViewable
            End Get
            Set(value As Boolean)
                _isViewable = value
            End Set
        End Property

        Public Property IsEmailable() As Boolean
            Get
                Return _isEmailable
            End Get
            Set(value As Boolean)
                _isEmailable = value
            End Set
        End Property

        Public ReadOnly Property UsesStartDateParam() As Boolean
            Get
                If _reportSQL.IndexOf("@startDate") >= 0 Then
                    Return True
                Else
                    Return False
                End If
            End Get
        End Property
        Public ReadOnly Property UsesEndDateParam() As Boolean
            Get
                If _reportSQL.IndexOf("@endDate") >= 0 Then
                    Return True
                Else
                    Return False
                End If
            End Get
        End Property
        Public ReadOnly Property UsesDeptParam() As Boolean
            Get
                If _reportSQL.IndexOf("@dept") >= 0 Then
                    Return True
                Else
                    Return False
                End If
            End Get
        End Property
        Public ReadOnly Property UsesStageParam() As Boolean
            Get
                If _reportSQL.IndexOf("@stage") >= 0 Then
                    Return True
                Else
                    Return False
                End If
            End Get
        End Property
        Public ReadOnly Property UsesVendorParam() As Boolean
            Get
                If _reportSQL.IndexOf("@vendor") >= 0 Then
                    Return True
                Else
                    Return False
                End If
            End Get
        End Property
        Public ReadOnly Property UsesVendorFilterParam() As Boolean
            Get
                If _reportSQL.IndexOf("@vendorFilter") >= 0 Then
                    Return True
                Else
                    Return False
                End If
            End Get
        End Property
        Public ReadOnly Property UsesStatusParam() As Boolean
            Get
                If _reportSQL.IndexOf("@itemStatus") >= 0 Then
                    Return True
                Else
                    Return False
                End If
            End Get
        End Property
        Public ReadOnly Property UsesSKUParam() As Boolean
            Get
                If _reportSQL.IndexOf("@sku") >= 0 Then
                    Return True
                Else
                    Return False
                End If
            End Get
        End Property
        Public ReadOnly Property UsesSKUGroupParam() As Boolean
            Get
                If _reportSQL.IndexOf("@itemGroup") >= 0 Then
                    Return True
                Else
                    Return False
                End If
            End Get
        End Property
        Public ReadOnly Property UsesStockCategoryParam() As Boolean
            Get
                If _reportSQL.IndexOf("@stockCategory") >= 0 Then
                    Return True
                Else
                    Return False
                End If
            End Get
        End Property
        Public ReadOnly Property UsesItemTypeParam() As Boolean
            Get
                If _reportSQL.IndexOf("@itemType") >= 0 Then
                    Return True
                Else
                    Return False
                End If
            End Get
        End Property

        Public ReadOnly Property UsesApproverParam() As Boolean
            Get
                If _reportSQL.IndexOf("@approver") >= 0 Then
                    Return True
                Else
                    Return False
                End If
            End Get
        End Property

        Public ReadOnly Property UsesWorkflowParam() As Boolean
            Get
                If _reportSQL.IndexOf("@workflowID") >= 0 Then
                    Return True
                Else
                    Return False
                End If
            End Get
        End Property

        Public ReadOnly Property UsesHoursParam() As Boolean
            Get
                If _reportSQL.IndexOf("@hours") >= 0 Then
                    Return True
                Else
                    Return False
                End If
            End Get
        End Property

        Public ReadOnly Property UsesMSSOrSPEDYParam() As Boolean
            Get
                If _reportSQL.IndexOf("@mssOrSpedy") >= 0 Then
                    Return True
                Else
                    Return False
                End If
            End Get
        End Property

        Public ReadOnly Property UsesPLIFrenchParam() As Boolean
            Get
                If _reportSQL.IndexOf("@pliFrench") >= 0 Then
                    Return True
                Else
                    Return False
                End If
            End Get
        End Property

        Public ReadOnly Property UsesPOStockCategoryParam() As Boolean
            Get
                If _reportSQL.IndexOf("@poStockCategory") >= 0 Then
                    Return True
                Else
                    Return False
                End If
            End Get
        End Property

        Public ReadOnly Property UsesPOStatusParam() As Boolean
            Get
                If _reportSQL.IndexOf("@poStatus") >= 0 Then
                    Return True
                Else
                    Return False
                End If
            End Get
        End Property

        Public ReadOnly Property UsesPOTypeParam() As Boolean
            Get
                If _reportSQL.IndexOf("@poType") >= 0 Then
                    Return True
                Else
                    Return False
                End If
            End Get
        End Property

        Public ReadOnly Property UsesPOStageParam() As Boolean
            Get
                If _reportSQL.IndexOf("@poStage") >= 0 Then
                    Return True
                Else
                    Return False
                End If
            End Get
        End Property

    End Class

End Namespace


