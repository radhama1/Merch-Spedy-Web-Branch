Imports System
Imports System.Data
Imports System.Data.SqlClient
Imports system.Collections.generic
Imports NovaLibra.Common.Utilities
Imports NovaLibra.Coral.BusinessFacade.Michaels
Imports NovaLibra.Coral.Data
Imports NovaLibra.Coral.Data.Utilities
Imports Models = NovaLibra.Coral.SystemFrameworks.Michaels

Partial Class LookUpStages
    Inherits System.Web.UI.Page

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

        ' quick security check
        If Session("UserID") Is Nothing OrElse Not IsNumeric(Session("UserID")) OrElse Session("UserID") <= 0 Then
            Response.Clear()
            '            Response.Write("<option value='-1'>Session Timed Out. Please Log in again.</option>")
            Response.Write("-2|$|0|$|Session Timed Out. Please Log in again.")
            Response.End()
        End If

        Dim batchID As String = Request("BatchID")
        Dim currentStage As Integer = Request("StageID")
        Dim Stages As List(Of Models.WorkflowStage)
        Dim i As Integer
        Dim strTemp As String = String.Empty

        ' OLD
        ' Stages = BatchesData.GetDisApprovalBatchStages(batchID, "A")

        ' Check if any Stages were returned
        ' Yes: Get reverse sort of data to determine Previous Stage
        ' NO:  Get previous Stage from DB

        ' If Stages.Count > 0 Then
        Dim revStages As List(Of Models.WorkflowStage)
        revStages = BatchesData.GetDisApprovalBatchStages(batchID, "D")

        ' New IF for disapproval based on Seq

        ' Check if any Stages were returned
        ' Yes: Get reverse sort of data to determine Previous Stage
        ' NO:  Get previous Stage from DB

        If revStages.Count > 0 Then
            ' Look for record that matches current stage (happens when Disapprovals occur). If found set to next record
            Dim found As Boolean = False
            For i = 0 To revStages.Count - 1
                If found Then
                    strTemp = revStages(i).ID & "|$|1|$|Previous Stage (" & revStages(i).StageName & ")|%|"
                    Exit For
                End If
                ' Find Approved Stage that matches current Stage
                If revStages(i).ID = currentStage Then    ' Previous Stage is next record
                    found = True
                End If
            Next
            ' Following code handles situation when no disapprovals happened (where current stage is not listed in the history)
            ' Grab the most recent record (which only contains approval or create steps) as the stage to go to
            If Not found Then
                strTemp = revStages(0).ID & "|$|1|$|Previous Stage (" & revStages(0).StageName & ")|%|"
            End If
            revStages.Clear()
            revStages = Nothing

        Else    ' Following happens if history is messed up for some reason (no approvals or created or uploaded)
            Dim StagesDict As Dictionary(Of Integer, Models.WorkflowStage)
            Dim objData As NovaLibra.Coral.Data.Michaels.BatchData = New NovaLibra.Coral.Data.Michaels.BatchData
            StagesDict = objData.GetStageListDict()
            If StagesDict.Count > 0 Then
                Dim curStage As Models.WorkflowStage = StagesDict(currentStage)
                Dim preStage As Models.WorkflowStage = StagesDict(curStage.PreviousStage)
                strTemp = CStr(preStage.ID) & "|$|1|$|Previous Stage (" & preStage.StageName & ")"
            Else
                strTemp = "-2|$|0|$|Error Getting Default Previous Stage info"
            End If
            StagesDict.Clear()
            StagesDict = Nothing
        End If

        Response.Clear()
        Response.Write(strTemp)

        ' OLD Show Stages based on History
        ' ----------------------------------------
        ' New Get Stages based on Prior Seq # and display those
        Stages = BatchesData.GetDisApprovalBatchStages(batchID, "S")

        For i = 0 To Stages.Count - 1
            If Stages(i).ID <> currentStage Then        ' for seq based this will always be true but not nec if history based
                Response.Write(Stages(i).ID & "|$|0|$|" & Stages(i).StageName)
                If i < Stages.Count - 1 Then Response.Write("|%|") ' Tack on Record sep if not last record
            Else
                Exit For
            End If
        Next
        Stages.Clear()
        Stages = Nothing

        Response.End()

    End Sub
End Class
