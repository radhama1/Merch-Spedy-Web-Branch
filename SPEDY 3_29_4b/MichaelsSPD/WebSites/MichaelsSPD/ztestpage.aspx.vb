
Partial Class ztestpage
    Inherits System.Web.UI.Page

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        TextBox1.Text = "test"
        TextBox1.Enabled = False
        DropDownList1.Items.Add(New ListItem("1", "1"))
        DropDownList1.Items.Add(New ListItem("2", "2"))
        DropDownList1.Items.Add(New ListItem("3", "3"))
        DropDownList1.SelectedValue = 3
        DropDownList1.Enabled = False
    End Sub

    Protected Sub Button1_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles Button1.Click
        Dim i As Integer
        i = 1
        i = 2
        Dim val As String
        val = DropDownList1.SelectedValue
        val = TextBox1.Text
        i = 3

    End Sub
End Class
