Imports System
Imports System.Data
Imports System.Data.SqlClient
Imports System.Text
Imports System.Xml
Imports System.Xml.XPath

Imports NovaLibra.Common
Imports NovaLibra.Common.Utilities
Imports NovaLibra.Coral.Data
imports NovaLibra.Coral.Data.Utilities
Imports NovaLibra.Coral.BusinessFacade

Partial Class detailsettings
    Inherits System.Web.UI.Page

    Private _objData As New DataSet
    Private _colCount As Integer = 10

    Public ReadOnly Property ColumnReader() As DataSet
        Get
            Return _objData
        End Get
    End Property

    Public Property ColumnCount() As Integer
        Get
            Return _colCount
        End Get
        Set(ByVal value As Integer)
            _colCount = value
        End Set
    End Property

    Private _userColumns As XmlDocument = Nothing
    Private _userColumnsXML As String = ""

    Public Function ColumnEnabledByUser(ByVal columnID As Integer, ByVal defaultDisplay As Boolean) As Boolean
        Dim retValue As Boolean = True
        If _userColumnsXML <> "" AndAlso _userColumnsXML <> "<UserEnabledColumns />" Then
            If Not _userColumns Is Nothing AndAlso Not _userColumns.SelectNodes("//EnabledColumn[@ColumnID = """ & columnID & """]").Count > 0 Then
                retValue = False
            End If
        Else
            retValue = defaultDisplay
        End If
        Return retValue
    End Function

    Protected Sub Page_Init(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Init
        ' init the page
    End Sub

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

        ' quick security check
        If Session("UserID") Is Nothing OrElse Not IsNumeric(Session("UserID")) Then
            Response.Redirect("closesettingsform.aspx")
        End If

        If Not IsPostBack And Not IsCallback Then
            ' make sure __doPostBack is generated
            ClientScript.GetPostBackEventReference(Me, String.Empty)

            ' column xml
            _userColumns = New XmlDocument()
            _userColumnsXML = UserEnabledColumns
            If _userColumnsXML = "" Then
                _userColumnsXML = DBRecords.LoadUserEnabledColumns(Session("UserID"))
                UserEnabledColumns = _userColumnsXML
            End If
            _userColumns.LoadXml(_userColumnsXML)

            Dim objReader As DBReader = Nothing
            Dim SQLStr As String
            Dim filterID As Integer
            Dim selectedID As Integer = 0
            Dim cnt As Integer
            Try
                ' field count
                SQLStr = "SELECT COUNT(*) AS RecordCount FROM ColumnDisplayName WHERE Display = 1 AND Is_Custom = 0"
                objReader = DataUtilities.GetDBReader(SQLStr)
                If objReader.HasRows And objReader.Read() Then
                    cnt = objReader("RecordCount")
                    cnt = cnt / 3
                    ColumnCount = cnt
                End If
                objReader.Dispose()
                objReader = Nothing

                ' fields
                SQLStr = "SELECT * FROM ColumnDisplayName WHERE Display = 1 AND Is_Custom = 0 ORDER BY Column_Ordinal, [ID]"
                _objData.Tables.Add(DataUtilities.FillTable(SQLStr))

                ' saved filters
                SQLStr = "SELECT ID, Filter_Name, Show_At_Startup FROM SavedFilter WHERE User_ID = '0" & Session("UserID") & "' ORDER BY Filter_Name"
                objReader = DataUtilities.GetDBReader(SQLStr)
                SelectStartupFilter.Items.Clear()
                SelectStartupFilter.Items.Add(New ListItem("", "0"))
                If objReader.HasRows Then
                    Do While objReader.Read()
                        filterID = DataHelper.SmartValues(objReader("ID"), "Integer")
                        SelectStartupFilter.Items.Add(New ListItem(DataHelper.SmartValues(objReader("Filter_Name"), "String"), filterID.ToString()))
                        If (DataHelper.SmartValues(objReader("Show_At_Startup"), "Boolean") = True) Then
                            selectedID = filterID
                        End If
                    Loop
                End If
                SelectStartupFilter.SelectedValue = selectedID.ToString()
                objReader.Close()
                objReader.Dispose()
                objReader = Nothing
            Catch sqlex As SqlException
                Logger.LogError(sqlex)
                Throw sqlex
            Catch ex As Exception
                Logger.LogError(ex)
                Throw (ex)
            Finally
                If Not objReader Is Nothing Then
                    objReader.Close()
                    objReader.Dispose()
                    objReader = Nothing
                End If
            End Try
        End If

    End Sub

    Protected Sub Page_Unload(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Unload
        If Not _objData Is Nothing Then
            _objData = Nothing
        End If
        _userColumns = Nothing
    End Sub

    Private Property DefaultEnabledColumns() As String
        Get
            Dim o As Object = Session("DefaultEnabledColumns")
            If Not o Is Nothing Then
                Return CType(o, String)
            Else
                Return ""
            End If
        End Get
        Set(ByVal value As String)
            Session("DefaultEnabledColumns") = value
        End Set
    End Property

    Private Property UserEnabledColumns() As String
        Get
            Dim o As Object = Session("UserEnabledColumns")
            If Not o Is Nothing Then
                Return CType(o, String)
            Else
                Return ""
            End If
        End Get
        Set(ByVal value As String)
            Session("UserEnabledColumns") = value
        End Set
    End Property

    Private Property UserStartupFilter() As Integer
        Get
            Dim o As Object = Session("UserStartupFilter")
            If Not o Is Nothing And IsNumeric(o) Then
                Return CType(o, String)
            Else
                Return 0
            End If
        End Get
        Set(ByVal value As Integer)
            Session("UserStartupFilter") = value
        End Set
    End Property

    Protected Sub btnCommit_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnCommit.Click
        ' save settings
        Dim SQLStr As String = ""
        Dim conn As DBConnection = Nothing
        Dim cmd As DBCommand = Nothing
        Try
            conn = ApplicationHelper.GetAppConnection()
            conn.Open()
            cmd = New DBCommand(conn, "", CommandType.Text)
            Dim columns As String = "", str As String = ""
            ' save user enabled columns
            cmd.CommandText = "delete from UserEnabledColumns where [User_ID] = @userID"
            cmd.Parameters.Add("@userID", SqlDbType.Int).Value = Session("UserID")
            cmd.ExecuteNonQuery()
            If Request.Form("chk_EnabledCols").Length > 0 Then

                Dim arr As String() = Request.Form("chk_EnabledCols").Split(",")
                For i As Integer = LBound(arr) To UBound(arr)
                    If IsNumeric(arr(i)) Then
                        If columns <> "" Then
                            columns += ", "
                        End If
                        columns += Integer.Parse(arr(i).Trim()).ToString()
                    End If
                Next
                If columns <> "" Then
                    str = "0"
                Else
                    str = "0, " & columns
                End If
                cmd.CommandText = "insert into UserEnabledColumns ([User_ID], ColumnDisplayName_ID) " & _
                    " select @userID, [ID] from ColumnDisplayName " & _
                    " where [ID] in (" & str & ") and Is_Custom = 0"
                cmd.ExecuteNonQuery()
            End If
            _userColumnsXML = DBRecords.LoadUserEnabledColumns(columns)
            UserEnabledColumns = _userColumnsXML
            ' save startup filter
            cmd.CommandText = "update SavedFilter set Show_At_Startup = 0 where [User_ID] = @userID"
            'cmd.Parameters.Add("@userID", SqlDbType.Int).Value = Session("UserID")
            cmd.ExecuteNonQuery()
            If SelectStartupFilter.SelectedValue <> "0" And IsNumeric(SelectStartupFilter.SelectedValue) Then
                cmd.CommandText = "update SavedFilter set Show_At_Startup = 1 where [User_ID] = @userID and [id] = @id"
                'cmd.Parameters.Clear()
                'cmd.Parameters.Add("@userID", SqlDbType.Int).Value = Session("UserID")
                cmd.Parameters.Add("@id", SqlDbType.Int).Value = DataHelper.SmartValues(SelectStartupFilter.SelectedValue, "Integer")
                cmd.ExecuteNonQuery()
                UserStartupFilter = DataHelper.SmartValues(SelectStartupFilter.SelectedValue, "Integer")
            Else
                UserStartupFilter = 0
            End If

            cmd.Dispose()
            cmd = Nothing
            conn.Close()
            conn.Dispose()
            conn = Nothing


        Catch ex As Exception
            If conn IsNot Nothing Then
                conn.Close()
                conn.Dispose()
                conn = Nothing
            End If
            If cmd IsNot Nothing Then
                cmd.Dispose()
                cmd = Nothing
            End If
        End Try
        ' redirect
        Response.Redirect("detailsettingsclose.aspx")
    End Sub
End Class
