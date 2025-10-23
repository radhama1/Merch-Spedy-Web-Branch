Imports System
Imports System.Data
Imports System.Data.SqlClient
Imports NovaLibra.Common.Utilities
Imports NovaLibra.Coral.Data
Imports Models = NovaLibra.Coral.SystemFrameworks.Michaels

Partial Class detailexcel
    Inherits System.Web.UI.Page

    Protected Sub Page_Init(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Init
        ' init the page
    End Sub

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

        Page.EnableViewState = False

        ' quick security check
        If Session("UserID") Is Nothing OrElse Not IsNumeric(Session("UserID")) OrElse Session("UserID") <= 0 Then
            Response.Redirect("login.aspx")
        End If
        Dim userID As Long = DataHelper.SmartValues(Session("UserID"), "long", False)

        Dim itemHeaderID As Long = DataHelper.SmartValues(Request("hid"), "long", False)



        Me.Page.Title = ConfigurationManager.AppSettings("ApplicationName")
        Response.ContentType = "application/vnd.ms-excel"
        Dim dateNow As Date = Now()
        Response.AddHeader("content-disposition", "attachment;filename=Michaels Report " & dateNow.ToString("yyyyMMdd") & ".xls")


        ' setup grid
        Dim objGridItem As GridItem
        Dim sql As String

        ItemGrid.ExcelMode = True

        ' SETUP COLUMNS
        Dim reader As DBReader = Nothing
        sql = "select ID" & _
            ", isnull(Column_Name, '') as Column_Name" & _
            ", Column_Ordinal" & _
            ", Column_Generic_Type" & _
            ", isnull(Column_Format, 'string') as Column_Format" & _
            ", isnull(Column_Format_String, '') as Column_Format_String" & _
            ", Fixed_Column" & _
            ", Allow_Sort" & _
            ", Allow_Filter" & _
            ", Allow_AjaxEdit" & _
            ", Default_UserDisplay" & _
            ", Display_Name " & _
            ", Max_Length " & _
            " from ColumnDisplayName" & _
            " where [Display] = 1" & _
            " order by Column_Ordinal"
        Try
            reader = New DBReader(Utilities.ApplicationHelper.GetAppConnection())
            reader.CommandText = sql
            reader.CommandType = CommandType.Text
            reader.Open()
            Do While reader.Read()
                objGridItem = ItemGrid.AddGridItem(reader("Column_Ordinal"), reader("Display_Name"), reader("Column_Name"), reader("Column_Generic_Type"), reader("Column_Format"))
                objGridItem.FixedColumn = DataHelper.SmartValues(reader("Fixed_Column"), "Boolean")
                objGridItem.SortColumn = DataHelper.SmartValues(reader("Allow_Sort"), "Boolean")
                objGridItem.FilterColumn = DataHelper.SmartValues(reader("Allow_Filter"), "Boolean")
            Loop
        Catch sqlex As SqlException
            'Logger.LogError(sqlex)
            Throw sqlex
        Catch ex As Exception
            'Logger.LogError(ex)
            Throw ex
        Finally
            If Not reader Is Nothing Then
                reader.Close()
                reader.Dispose()
            End If
        End Try

        ' *******************************************
        ' TODO: FINISH THIS WITH SORTING/FILTERING **
        ' *******************************************

        Dim objMichaels As New NovaLibra.Coral.BusinessFacade.Michaels.MichaelsItemDetail()
        Dim gridItemList As Models.ItemList = objMichaels.GetList(itemHeaderID, 0, 0, String.Empty, userID)
        objMichaels = Nothing

        ItemGrid.RecordCount = gridItemList.TotalRecords

        ItemGrid.DataSource = gridItemList.ListRecords
        ItemGrid.DataBind()
    End Sub

End Class
