Imports System
Imports System.Configuration
Imports System.Data
Imports System.IO

Imports Microsoft.VisualBasic

Imports NovaLibra.Common
Imports NovaLibra.Common.Utilities
Imports NovaLibra.Coral.BusinessFacade
Imports NLData = NovaLibra.Coral.Data
Imports NovaLibra.Coral.SystemFrameworks
Imports Models = NovaLibra.Coral.SystemFrameworks.Michaels

Partial Class uploaditemfile
    Inherits MichaelsBasePage

    Public Const FILE_TYPES_IMAGE As String = "bmp,gif,jpg,jpeg,png,tif,tiff"
    Public Const FILE_TYPES_MSDS As String = "pdf"

    Private _refreshParent As Boolean = False
    Private _sendToDefault As Boolean = False
    Private _updateImage As Boolean = False

    Public Property RefreshParent() As Boolean
        Get
            Return _refreshParent
        End Get
        Set(ByVal value As Boolean)
            _refreshParent = value
        End Set
    End Property
    Public Property SendToDefault() As Boolean
        Get
            Return _sendToDefault
        End Get
        Set(ByVal value As Boolean)
            _sendToDefault = value
        End Set
    End Property
    Public Property UpdateImage() As Boolean
        Get
            Return _updateImage
        End Get
        Set(ByVal value As Boolean)
            _updateImage = value
        End Set
    End Property
    Public Property FileID() As String
        Get
            Return newfileid.Value
        End Get
        Set(ByVal value As String)
            newfileid.Value = value
        End Set
    End Property

    Private UserID As Integer = 0
    Private _itemType As String = String.Empty
    Private _itemID As Long = 0
    Private _fileType As Models.ItemFileType = Models.ItemFileType.Image

#Region "Page Events"

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

        If Session("UserID") Is Nothing OrElse Not IsNumeric(Session("UserID")) OrElse Session("UserID") <= 0 Then
            Response.Redirect("closeform.aspx")
        Else
            UserID = CInt(Session("UserID"))
        End If

        If Not IsPostBack Then
            If Request("itemid") Is Nothing OrElse Not IsNumeric(Request("itemid")) OrElse Request("itemid") <= 0 Then
                Response.Redirect("closeform.aspx")
            Else
                fileitemtype.Value = Request("itemtype")
                fileitemid.Value = Request("itemid")
                filefiletype.Value = Request("filetype")
                fileupdateimage.Value = Request("updateimage")
                If fileitemtype.Value <> Models.ItemTypeString.ITEM_TYPE_DOMESTIC And fileitemtype.Value <> Models.ItemTypeString.ITEM_TYPE_IMPORT Then
                    Me.fileUploadPanel.Visible = False
                    Me.fileParamsError.Visible = True
                End If
            End If
        End If

        _itemType = fileitemtype.Value
        _itemID = DataHelper.SmartValues(fileitemid.Value, "long", False)
        If filefiletype.Value = "MSDS" Then
            _fileType = Models.ItemFileType.MSDS
        Else
            _fileType = Models.ItemFileType.Image
        End If
        _updateImage = fileupdateimage.Value

        ' S E C U R I T Y CHECK
        If _itemType = Models.ItemTypeString.ITEM_TYPE_IMPORT Then
            ' IMPORT ("I")
            Dim objM As New NovaLibra.Coral.BusinessFacade.Michaels.MichaelsImportItemDetail()
            Dim objRec As Models.ImportItemRecord = objM.GetRecord(_itemID)
            If Not objRec Is Nothing Then ValidateUser(objRec.Batch_ID)
            objRec = Nothing
            objM = Nothing
            If Not UserCanEdit Then Response.Redirect("closeform.aspx")
        Else
            ' DOMESTIC ("D")
            Dim objM As New NovaLibra.Coral.BusinessFacade.Michaels.MichaelsItemDetail()
            Dim objRec As Models.ItemRecord = objM.GetRecord(_itemID)
            If Not objRec Is Nothing Then ValidateUser(objRec.BatchID)
            objRec = Nothing
            objM = Nothing
            If Not UserCanEdit Then Response.Redirect("closeform.aspx")
        End If
        ' END S E C U R I T Y CHECK

        ' HEADER LABEL
        If _itemType = Models.ItemTypeString.ITEM_TYPE_IMPORT Then
            ' IMPORT ("I")
            UploadTitle.Text = "Upload Import Item "
        Else
            ' DOMESTIC ("D")
            UploadTitle.Text = "Upload Item "
        End If
        If _fileType = Models.ItemFileType.MSDS Then
            UploadTitle.Text = UploadTitle.Text & "MSDS Sheet (" & GetFileTypesString(_fileType) & ")"
            Page.Title = UploadTitle.Text
            UploadTitle.Text = "<img src=""images/app_icons/icon_pdf_small.gif"" alt="""" align=""absmiddle"" />&nbsp;" & UploadTitle.Text
        Else
            UploadTitle.Text = UploadTitle.Text & "Image (" & GetFileTypesString(_fileType) & ")"
            Page.Title = UploadTitle.Text
            UploadTitle.Text = "<img src=""images/app_icons/icon_jpg_small_on.gif"" alt="""" align=""absmiddle"" />&nbsp;" & UploadTitle.Text
        End If

        btnSubmit.Attributes.Add("onclick", "return validateForm();")

        CheckForStartupScripts()
    End Sub

#End Region

#Region "Scripts"
    Private Sub CheckForStartupScripts()
        Dim startupScriptKey As String = "__uploaditemfile_"
        If Not Me.Page.ClientScript.IsStartupScriptRegistered(startupScriptKey) Then
            CreateStartupScripts(startupScriptKey)
        End If
    End Sub

    Private Sub CreateStartupScripts(ByVal startupScriptKey As String)

        Dim sb As New StringBuilder("")

        sb.Length = 0
        sb.Append("" & vbCrLf)
        sb.Append("<script language=""javascript"" type=""text/javascript"">" & vbCrLf)
        sb.Append("<!--" & vbCrLf)

        sb.Append("var validFileTypes = '" & GetFileTypes(_fileType) & "';" & vbCrLf)

        sb.Append("//-->" & vbCrLf)
        sb.Append("</script>" & vbCrLf)

        Me.ClientScript.RegisterStartupScript(Me.GetType(), startupScriptKey, sb.ToString())
    End Sub

#End Region

    Protected Sub btnSubmit_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnSubmit.Click

        Dim saved As Boolean = False
        Dim showGeneralError As Boolean = False

        Try

            Dim file As HttpPostedFile = Request.Files.Item("uploadFile")

            If Not file Is Nothing Then

                If _fileType = Models.ItemFileType.Image Then

                    If IsValidFileType(file.FileName) Then

                        Dim img As System.Drawing.Image = System.Drawing.Image.FromStream(file.InputStream)
                        Dim imgRec As New NovaLibra.Coral.SystemFrameworks.Michaels.FileRecord

                        If img.PixelFormat = 8207 Then
                            fileUploadPanel.Visible = False
                            fileImageTypeError.Visible = True
                        Else
                            imgRec.File_Name = GetFileName(file.FileName)
                            imgRec.File_Data = ImageToByteArray(img)
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
                                objMichaelsItemFile.AddRecord(_itemType, _itemID, imageID, _fileType, UserID)

                                'Completed the save process
                                saved = True
                                newfileid.Value = imageID.ToString()

                                objMichaelsItemFile = Nothing

                                ' audit
                                Dim objFA As New NovaLibra.Coral.BusinessFacade.Michaels.MichaelsFieldAuditing()
                                Dim audit As New Models.AuditRecord()
                                If _itemType = "I" Then
                                    audit.SetupAudit(Models.MetadataTable.Import_Items, _itemID, Models.AuditRecordType.Update, UserID)
                                Else
                                    audit.SetupAudit(Models.MetadataTable.Items, _itemID, Models.AuditRecordType.Update, UserID)
                                End If
                                audit.AddAuditField("Image_ID", imageID)
                                objFA.SaveAuditRecord(audit)
                                objFA = Nothing
                                audit = Nothing

                            Else
                                showGeneralError = True
                            End If

                        End If
                    Else
                        fileUploadPanel.Visible = False
                        fileTypeError.Visible = True
                        fileTypeErrorLabel.InnerText = GetFileTypesString(_fileType)
                    End If

                ElseIf _fileType = NovaLibra.Coral.SystemFrameworks.Michaels.ItemFileType.MSDS Then

                    If IsValidFileType(file.FileName) Then

                        Dim fileRec As New NovaLibra.Coral.SystemFrameworks.Michaels.FileRecord

                        fileRec.File_Name = GetFileName(file.FileName)
                        fileRec.File_Data = FileToByteArray(file)
                        fileRec.File_Size = fileRec.File_Data.Length
                        fileRec.Image_Width_Pixels = 0
                        fileRec.Image_Height_Pixels = 0

                        'Save the image
                        Dim objMichaelsFile As New NovaLibra.Coral.BusinessFacade.Michaels.MichaelsFile()
                        Dim fileID As Long = objMichaelsFile.SaveRecord(fileRec, UserID)
                        objMichaelsFile = Nothing

                        'Save a xref to the image
                        If fileID > 0 Then

                            Dim objMichaelsItemFile As New NovaLibra.Coral.BusinessFacade.Michaels.MichaelsItemFile()

                            'Add new image xref
                            objMichaelsItemFile.AddRecord(_itemType, _itemID, fileID, _fileType, UserID)

                            'Completed the save process
                            saved = True
                            newfileid.Value = fileID.ToString()

                            objMichaelsItemFile = Nothing

                            ' audit
                            Dim objFA As New NovaLibra.Coral.BusinessFacade.Michaels.MichaelsFieldAuditing()
                            Dim audit As New Models.AuditRecord()
                            If _itemType = "I" Then
                                audit.SetupAudit(Models.MetadataTable.Import_Items, _itemID, Models.AuditRecordType.Update, UserID)
                            Else
                                audit.SetupAudit(Models.MetadataTable.Items, _itemID, Models.AuditRecordType.Update, UserID)
                            End If
                            audit.AddAuditField("MSDS_ID", fileID)
                            objFA.SaveAuditRecord(audit)
                            objFA = Nothing
                            audit = Nothing
                        Else
                            showGeneralError = True
                        End If
                    Else
                        fileUploadPanel.Visible = False
                        fileTypeError.Visible = True
                        fileTypeErrorLabel.InnerText = GetFileTypesString(_fileType)
                    End If
                End If

            End If

        Catch ex As Exception

        End Try


        fileUploadPanel.Visible = False

        'Display appropriate message
        If saved Then
            Dim func As String
            If _fileType = Models.ItemFileType.MSDS Then
                func = "updateParentMSDS"
            Else
                func = "updateParentImage"
            End If
            Dim script As String = "" & vbCrLf & "<script language=""javascript"" type=""text/javascript"">" & vbCrLf & "<!--" & vbCrLf & func & "(" & _itemID & ", " & FileID & ");" & vbCrLf & "//-->" & vbCrLf & "<" & "/" & "script>" & vbCrLf

            If UpdateImage And Not ClientScript.IsStartupScriptRegistered("WindowScript") Then
                ClientScript.RegisterStartupScript(Me.GetType(), "WindowScript", script, False)
            End If
            Me.fileUploadSuccess.Visible = True

        Else
            If showGeneralError Then
                fileUploadError.Visible = True
            End If
        End If

    End Sub

    Public Shared Function ImageToByteArray(ByVal imageIn As System.Drawing.Image) As Byte()
        Dim ba() As Byte
        Dim ms As New MemoryStream()
        imageIn.Save(ms, System.Drawing.Imaging.ImageFormat.Jpeg)
        ba = ms.ToArray()
        ms.Dispose()
        ms = Nothing
        Return ba
    End Function

    Public Shared Function FileToByteArray(ByVal file As HttpPostedFile) As Byte()
        Dim bytearr() As Byte
        ReDim bytearr(file.ContentLength)
        file.InputStream.Read(bytearr, 0, file.ContentLength)
        Return bytearr
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

    Public Function GetFileTypes() As String
        If _fileType = Models.ItemFileType.MSDS Then
            Return FILE_TYPES_MSDS
        Else
            Return FILE_TYPES_IMAGE
        End If
    End Function

    Public Function GetFileTypes(ByVal fileType As Models.ItemFileType) As String
        If fileType = Models.ItemFileType.MSDS Then
            Return FILE_TYPES_MSDS
        Else
            Return FILE_TYPES_IMAGE
        End If
    End Function

    Private Function GetFileTypesString(ByVal fileType As Models.ItemFileType) As String
        Dim types As String
        Dim arr() As String
        Dim retValue As String = String.Empty
        types = GetFileTypes(fileType)
        arr = types.Split(",")
        For i As Integer = 0 To arr.Length - 1
            If retValue <> String.Empty Then retValue += ", "
            retValue += "*." & arr(i)
        Next
        Return retValue
    End Function

    Private Function IsValidFileType(ByVal fileName As String) As Boolean
        Dim isValid As Boolean = False
        Dim validFileTypes As String = GetFileTypes()
        Dim arr() As String, fileext As String = "", i As Integer, index As Integer
        If fileName <> String.Empty Then
            index = fileName.LastIndexOf(".")
            If (index >= 0) Then
                fileext = fileName.Substring(index + 1).ToLower()
            End If
        End If
        If validFileTypes <> String.Empty And fileext <> String.Empty Then
            arr = validFileTypes.Split(",")
            For i = 0 To arr.Length - 1
                If arr(i) = fileext Then
                    isValid = True
                    Exit For
                End If
            Next
        End If
        Return isValid
    End Function


End Class
