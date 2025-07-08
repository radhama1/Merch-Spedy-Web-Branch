Imports NovaLibra.Common
Imports NovaLibra.Common.Utilities
Imports System.Configuration
Imports System.Net.Mail
Imports System.Collections.Generic

Partial Class imagedownloader
    Inherits System.Web.UI.Page

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        ' quick security check
        If Session("UserID") Is Nothing OrElse Not IsNumeric(Session("UserID")) OrElse Session("UserID") <= 0 Then
            Response.Redirect("login.aspx")
        End If
        hdnUserID.Value = Session("UserID")


        If Not IsPostBack Then
            Initialize()
        End If

    End Sub

    Private Sub Initialize()
        lblUserEmail.Text = Session("Email_Address")
        lblUserEmail2.Text = Session("Email_Address")

        Dim maxSKUSetting As NovaLibra.Coral.SystemFrameworks.Michaels.SettingsRecord = NovaLibra.Coral.Data.Michaels.SettingsData.GetByName("IMAGEDOWNLOADER.MAXIMUMSKUS")
        If maxSKUSetting.ID IsNot Nothing Then
            lblMaxSKUs.Text = maxSKUSetting.SettingValue
        End If

    End Sub


    Protected Sub btnClear_Click(ByVal sender As Object, ByVal e As EventArgs) Handles btnClear.Click
        txtSKUList.Text = ""
    End Sub

    <System.Web.Services.WebMethod> _
    Public Shared Function ValidateSKUs(ByVal skuList As String) As AjaxResponse
        Dim response As New AjaxResponse

        Try
            Dim maxSKUSetting As NovaLibra.Coral.SystemFrameworks.Michaels.SettingsRecord = NovaLibra.Coral.Data.Michaels.SettingsData.GetByName("IMAGEDOWNLOADER.MAXIMUMSKUS")
            Dim invalidSKUList As New StringBuilder("")

            If String.IsNullOrEmpty(skuList) Then
                response.Success = False
                response.Message = "No SKUs were specified in the SKU List.  Please specify the SKUs you want to retrieve images for."
                Return response
            Else
                'Parsre SKUs from the list
                Dim skus() As String = skuList.Split(New String() {Environment.NewLine}, StringSplitOptions.RemoveEmptyEntries)

                'Make sure the SKUs do not exceed the max sku setting
                If skus.Length > maxSKUSetting.SettingValue Then
                    response.Success = False
                    response.Message = "More than " & maxSKUSetting.SettingValue & " SKUs were specified.  Please remove extra SKUs from the list."
                    Return response
                End If

                'Loop throuth the skus, and make sure they are valid
                For Each s As String In skus
                    If IsNumeric(s) Then
                        'Verify sku exists in database
                        Dim sku As NovaLibra.Coral.SystemFrameworks.Michaels.ItemMasterRecord = NovaLibra.Coral.Data.Michaels.ItemMasterData.GetBySKU(s)
                        If String.IsNullOrEmpty(sku.Item) Then
                            'SKU was not found in SPEDY.  Add it to the invalid SKU List
                            invalidSKUList.Append(s & ",")
                        End If
                    Else
                        'SKU is not numeric, and thus invalid.  Add it to the invalid SKU list
                        invalidSKUList.Append(s & ",")
                    End If
                Next
            End If

            'Check to see if there are invalid SKUs in the list
            If invalidSKUList.Length > 0 Then
                'Remove trailing comma
                invalidSKUList.Length -= 1

                response.Success = False
                response.Message = "There are invalid SKUs in the SKU List.  Please remove them and resubmit the list.  Invalid SKUs:  " & invalidSKUList.ToString()
                Return response
            End If

            response.Success = True

        Catch ex As Exception
            response.Success = False
            response.Message = ex.Message
            Logger.LogError(ex)
        End Try

        Return response
    End Function

    <System.Web.Services.WebMethod> _
    Public Shared Sub EmailImages(ByVal skuList As String, ByVal emailAddress As String, ByVal userID As String)
        Try
            Dim imageList As New List(Of NovaLibra.Coral.SystemFrameworks.Michaels.ItemMaintImageRecord)
            Dim fileSize As Long = 0 'Running tally of size of all image files

            'Get Settings
            Dim imagePathSetting As NovaLibra.Coral.SystemFrameworks.Michaels.SettingsRecord = NovaLibra.Coral.Data.Michaels.SettingsData.GetByName("IMAGEDOWNLOADER.IMAGEPATH")

            'Loop through each SKU in the list, and get the associated images
            Dim skus() As String = skuList.Split(New String() {Environment.NewLine}, StringSplitOptions.RemoveEmptyEntries)
            For Each sku As String In skus
                'Compile a list of all the Images for each SKU
                Dim images As List(Of NovaLibra.Coral.SystemFrameworks.Michaels.ItemMaintImageRecord) = NovaLibra.Coral.Data.Michaels.MaintItemMasterData.GetImageInfoBySKU(sku)
                If images.Count > 0 Then
                    For Each i As NovaLibra.Coral.SystemFrameworks.Michaels.ItemMaintImageRecord In images
                        imageList.Add(i)
                    Next
                End If
            Next

            'Zip up images, and email them
            SendImageEmail(imageList, emailAddress)

        Catch ex As Exception
            Logger.LogError(ex)
        End Try

    End Sub

    Public Shared Sub SendImageEmail(ByVal imageList As List(Of NovaLibra.Coral.SystemFrameworks.Michaels.ItemMaintImageRecord), ByVal emailAddress As String)
        Dim compressedStream As System.IO.MemoryStream
        Dim memfile As System.IO.MemoryStream

        Try

            Dim maximumFileSizeSetting As NovaLibra.Coral.SystemFrameworks.Michaels.SettingsRecord = NovaLibra.Coral.Data.Michaels.SettingsData.GetByName("IMAGEDOWNLOADER.MAXIMUMFILESIZE")

            'Create Mail Message
            Dim message As New MailMessage()
            message.Subject = "SPEDY - Requested SKU Images"
            message.Body = "No images found for the SKUs you requested."        'Overwrite this body, if there are images.
            message.From = New MailAddress(ConfigurationManager.AppSettings("FromEmailAddress"))
            message.To.Add(emailAddress)
            message.IsBodyHtml = True

            'If there are images to send, change the message body, zip the images, and attach the zip file.
            If imageList.Count > 0 Then
                message.Body = "Attached are the SKU images you requested."

                Dim zFile As New Ionic.Zip.ZipFile()    ' Zip file
                Dim fileSize As Long = 0                ' Current Estimated FileSize for the images
                Dim skuVendor As String = ""            ' SKU/Vendor string used in file naming
                Dim imageIndex As Integer = 0           ' Current index counter for SKU/Vendor images
                Dim fileIndex As Integer = 1            ' Current index of Zip files

                For Each i As NovaLibra.Coral.SystemFrameworks.Michaels.ItemMaintImageRecord In imageList

                    'Reset the Index counter, if this is a new SKU/Vendor combination
                    If skuVendor <> i.MichaelsSKU & "_" & i.VendorNumber Then
                        skuVendor = i.MichaelsSKU & "_" & i.VendorNumber
                        imageIndex = 0
                    End If

                    'Increment index counter
                    imageIndex += 1

                    'Increment FileSize
                    fileSize += i.FileSize

                    'If Zip file would be too big with the current file, then attach current zip file to mail message and create a new zip file.
                    If fileSize >= maximumFileSizeSetting.SettingValue Then

                        'Create Zip file, and attach it to the mail message
                        compressedStream = New IO.MemoryStream()
                        zFile.Save(compressedStream)
                        compressedStream.Seek(0, IO.SeekOrigin.Begin)

                        'Add file as Attacment
                        Dim partialDataFile As New Attachment(compressedStream, "SPEDY_SKU_Images_" & DateTime.Now.Month & DateTime.Now.Day & DateTime.Now.Year & "_" & fileIndex & ".zip")
                        message.Attachments.Add(partialDataFile)
                        'Reset FileSize and Create new Zip
                        fileSize = i.FileSize
                        zFile = New Ionic.Zip.ZipFile()

                        fileIndex += 1
                    End If

                    'Add image to Zip file
                    zFile.AddEntry(skuVendor & "_" & imageIndex & ".jpg", i.FileData)
                Next

                'Attach any remaining images to the mail message with the current zip file
                compressedStream = New IO.MemoryStream()
                zFile.Save(compressedStream)
                compressedStream.Seek(0, IO.SeekOrigin.Begin)
                Dim dataFile As New Attachment(compressedStream, "SPEDY_SKU_Images_" & DateTime.Now.Month & DateTime.Now.Day & DateTime.Now.Year & "_" & fileIndex & ".zip")
                message.Attachments.Add(dataFile)

                'Dispose of Zip file
                zFile.Dispose()
            End If

            'Get SMTP Server
            Dim smtpServer As String = ""
            Dim environment As String = ConfigurationManager.AppSettings("Environment")
            Select Case environment
                Case "DEV"
                    smtpServer = ConfigurationManager.AppSettings("DEVSmtpServer")
                Case "BETA"
                    smtpServer = ConfigurationManager.AppSettings("BETASmtpServer")
                Case "PROD"
                    smtpServer = ConfigurationManager.AppSettings("PRODSmtpServer")
                Case "VENDOR"
                    smtpServer = ConfigurationManager.AppSettings("VENDORSmtpServer")
            End Select

            'Send email
            Dim client As New SmtpClient()
            client.Host = smtpServer
            client.Send(message)

        Catch ex As Exception
            Logger.LogError(ex)
        Finally
            If memfile IsNot Nothing Then
                memfile.Close()
            End If
            If compressedStream IsNot Nothing Then
                compressedStream.Close()
            End If
        End Try

    End Sub

End Class


<Serializable> _
Public Class AjaxResponse

    Private _message As String
    Private _success As Boolean

    Public Property Message As String
        Get
            Return _message
        End Get
        Set(value As String)
            _message = value
        End Set
    End Property

    Public Property Success As Boolean
        Get
            Return _success
        End Get
        Set(value As Boolean)
            _success = value
        End Set
    End Property
    
End Class
