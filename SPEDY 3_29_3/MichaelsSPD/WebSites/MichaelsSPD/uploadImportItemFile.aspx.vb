Imports System
Imports System.Configuration
Imports System.Data
Imports System.IO
Imports Microsoft.VisualBasic

Imports C1.C1Excel

'Imports SoftArtisans.OfficeWriter.ExcelWriter

Imports NovaLibra.Common
Imports NovaLibra.Common.Utilities
Imports NovaLibra.Coral.BusinessFacade
Imports NovaLibra.Coral.BusinessFacade.Michaels
Imports NLData = NovaLibra.Coral.Data
Imports NovaLibra.Coral.SystemFrameworks
Imports Models = NovaLibra.Coral.SystemFrameworks.Michaels

Partial Class uploadImportItemFile
    Inherits System.Web.UI.Page

    Private UserID As Integer = 0
    Private ImportItemID As Long = 0

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

        If Session("UserID") Is Nothing OrElse Not IsNumeric(Session("UserID")) OrElse Session("UserID") <= 0 Then
            Response.Redirect("closeform.aspx")
        Else
            UserID = CInt(Session("UserID"))
        End If

        If Request("ID") Is Nothing OrElse Not IsNumeric(Request("ID")) OrElse Request("ID") <= 0 Then
            Response.Redirect("closeform.aspx")
        Else
            ImportItemID = CLng(Request("ID"))
        End If

    End Sub

    Protected Sub btnSubmit_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnSubmit.Click

        Dim saved As Boolean = False

        Try

            Dim file As HttpPostedFile = Request.Files.Item("importFile")

            If Not file Is Nothing Then

                If (file.ContentType.ToLower().StartsWith("image")) Then

                    Dim img As System.Drawing.Image = System.Drawing.Image.FromStream(file.InputStream)
                    Dim imgRec As New NovaLibra.Coral.SystemFrameworks.Michaels.FileRecord

                    imgRec.File_Name = GetFileName(file.FileName)
                    imgRec.File_Data = imageToByteArray(img)
                    imgRec.File_Size = imgRec.File_Data.Length
                    imgRec.Image_Width_Pixels = img.Width
                    imgRec.Image_Height_Pixels = img.Height

                    'Save the image
                    Dim objMichaelsFile As New NovaLibra.Coral.BusinessFacade.Michaels.MichaelsFile()
                    Dim imageID As Long = objMichaelsFile.SaveRecord(imgRec, UserID)
                    objMichaelsFile = Nothing

                    'Save a xref to the image
                    If imageID > 0 Then

                        Dim objMichaelsItemFile As New NovaLibra.Coral.BusinessFacade.Michaels.MichaelsItemFile()

                        'Add new image xref
                        objMichaelsItemFile.AddRecord(Models.ItemTypeString.ITEM_TYPE_IMPORT, ImportItemID, imageID, Models.ItemFileType.Image, UserID)

                        'Completed the save process
                        saved = True

                        objMichaelsItemFile = Nothing

                    End If

                End If

            End If

        Catch ex As Exception

        End Try


        fileImportPanel.Visible = False

        'Display appropriate message
        If saved Then

            Dim jScript As String = "<script language=""javascript"">window.opener.location='importdetail.aspx?HID=" & ImportItemID & "';window.close();</script>"

            If Not ClientScript.IsClientScriptBlockRegistered("WindowScript") Then
                ClientScript.RegisterClientScriptBlock(Me.GetType(), "WindowScript", jScript, False)
            End If

        Else
            fileImportError.Visible = True
        End If

    End Sub

    Public Shared Function imageToByteArray(ByVal imageIn As System.Drawing.Image) As Byte()

        Dim ms As New MemoryStream()
        imageIn.Save(ms, System.Drawing.Imaging.ImageFormat.Jpeg)
        Return ms.ToArray()

    End Function

    Private Function GetFileName(ByVal str As String) As String

        Dim retStr As String = str

        If Not retStr Is Nothing AndAlso retStr <> String.Empty Then

            If str.Contains("\") Then

                retStr = str.Substring(str.LastIndexOf("\") + 1)

            End If

        End If

        Return retStr

    End Function




End Class
