
Namespace Michaels

    Public Class ItemValidationLookupBase


        ' Item ERRORS

        Protected _itemErrors As Integer = 0

        Public Property ItemErrors() As Integer
            Get
                Return _itemErrors
            End Get
            Set(ByVal value As Integer)
                _itemErrors = value
            End Set
        End Property

        Public Function HasError(ByVal itemError As ItemValidationErrors) As Boolean
            If ((Me.ItemErrors And itemError) = itemError) Then
                Return True
            Else
                Return False
            End If
        End Function

        ' UPC ERRORS

        Protected _upcErrors As List(Of ItemUPCValidationError) = Nothing

        Public Sub AddUPCValidationError(ByVal Sequence As Integer, ByVal upc As String, ByVal upcExists As Boolean, ByVal dupBatch As Boolean, ByVal dupWorkflow As Boolean)
            AddUPCValidationError(New ItemUPCValidationError(Sequence, upc, upcExists, dupBatch, dupWorkflow))
        End Sub

        Public Sub AddUPCValidationError(ByRef upcError As ItemUPCValidationError)
            If _upcErrors Is Nothing Then _upcErrors = New List(Of ItemUPCValidationError)
            _upcErrors.Add(upcError)
        End Sub

        Public Function UPCExists(ByVal upc As String) As Boolean
            If _upcErrors IsNot Nothing Then
                For Each upcError As ItemUPCValidationError In _upcErrors
                    If upcError.UPC = upc Then
                        Return upcError.UPCExists
                    End If
                Next
            End If
            Return False
        End Function

        Public Function DupBatch(ByVal upc As String) As Boolean
            If _upcErrors IsNot Nothing Then
                For Each upcError As ItemUPCValidationError In _upcErrors
                    If upcError.UPC = upc Then
                        Return upcError.DupBatch
                    End If
                Next
            End If
            Return False
        End Function

        Public Function DupWorkflow(ByVal upc As String) As Boolean
            If _upcErrors IsNot Nothing Then
                For Each upcError As ItemUPCValidationError In _upcErrors
                    If upcError.UPC = upc Then
                        Return upcError.DupWorkflow
                    End If
                Next
            End If
            Return False
        End Function

        'PMO200141 GTIN14 Enhancements changes
        Protected _innergtinErrors As List(Of ItemInnerGTINValidationError) = Nothing

        Public Sub AddInnerGTINValidationError(ByVal Sequence As Integer, ByVal Innergtin As String, ByVal InnerGTINExists As Boolean, ByVal InnerGTINdupBatch As Boolean, ByVal InnerGTINdupWorkflow As Boolean)
            AddInnerGTINValidationError(New ItemInnerGTINValidationError(Sequence, Innergtin, InnerGTINExists, InnerGTINdupBatch, InnerGTINdupWorkflow))
        End Sub

        Public Sub AddInnerGTINValidationError(ByRef innergtinErrors As ItemInnerGTINValidationError)
            If _innergtinErrors Is Nothing Then _innergtinErrors = New List(Of ItemInnerGTINValidationError)
            _innergtinErrors.Add(innergtinErrors)
        End Sub

        Public Function InnerGTINExists(ByVal gtin As String) As Boolean
            If _innergtinErrors IsNot Nothing Then
                For Each innergtinErrors As ItemInnerGTINValidationError In _innergtinErrors
                    If innergtinErrors.InnerGTIN = gtin Then
                        Return innergtinErrors.InnerGTIN
                    End If
                Next
            End If
            Return False
        End Function

        Public Function InnerGTINDupBatch(ByVal gtin As String) As Boolean
            If _innergtinErrors IsNot Nothing Then
                For Each innergtinErrors As ItemInnerGTINValidationError In _innergtinErrors
                    If innergtinErrors.InnerGTIN = gtin Then
                        Return innergtinErrors.InnerGTINDupBatch
                    End If
                Next
            End If
            Return False
        End Function

        Public Function InnerGTINDupWorkflow(ByVal gtin As String) As Boolean
            If _innergtinErrors IsNot Nothing Then
                For Each innergtinErrors As ItemInnerGTINValidationError In _innergtinErrors
                    If innergtinErrors.InnerGTIN = gtin Then
                        Return innergtinErrors.InnerGTINDupWorkflow
                    End If
                Next
            End If
            Return False
        End Function

        Protected _casegtinErrors As List(Of ItemCaseGTINValidationError) = Nothing

        Public Sub AddCaseGTINValidationError(ByVal Sequence As Integer, ByVal Casegtin As String, ByVal CaseGTINExists As Boolean, ByVal CaseGTINdupBatch As Boolean, ByVal CaseGTINdupWorkflow As Boolean)
            AddCaseGTINValidationError(New ItemCaseGTINValidationError(Sequence, Casegtin, CaseGTINExists, CaseGTINdupBatch, CaseGTINdupWorkflow))
        End Sub

        Public Sub AddCaseGTINValidationError(ByRef casegtinErrors As ItemCaseGTINValidationError)
            If _casegtinErrors Is Nothing Then _casegtinErrors = New List(Of ItemCaseGTINValidationError)
            _casegtinErrors.Add(casegtinErrors)
        End Sub

        Public Function CaseGTINExists(ByVal gtin As String) As Boolean
            If _casegtinErrors IsNot Nothing Then
                For Each casegtinErrors As ItemCaseGTINValidationError In _casegtinErrors
                    If casegtinErrors.CaseGTIN = gtin Then
                        Return casegtinErrors.CaseGTIN
                    End If
                Next
            End If
            Return False
        End Function

        Public Function CaseGTINDupBatch(ByVal gtin As String) As Boolean
            If _casegtinErrors IsNot Nothing Then
                For Each casegtinErrors As ItemCaseGTINValidationError In _casegtinErrors
                    If casegtinErrors.CaseGTIN = gtin Then
                        Return casegtinErrors.CaseGTINDupBatch
                    End If
                Next
            End If
            Return False
        End Function

        Public Function CaseGTINDupWorkflow(ByVal gtin As String) As Boolean
            If _casegtinErrors IsNot Nothing Then
                For Each casegtinErrors As ItemCaseGTINValidationError In _casegtinErrors
                    If casegtinErrors.CaseGTIN = gtin Then
                        Return casegtinErrors.CaseGTINDupWorkflow
                    End If
                Next
            End If
            Return False
        End Function

    End Class

End Namespace

