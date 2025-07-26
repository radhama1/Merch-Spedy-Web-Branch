Imports System
Imports System.Data
Imports System.Data.SqlClient
Imports Microsoft.VisualBasic
Imports NovaLibra.Common
Imports NovaLibra.Common.Utilities
Imports NovaLibra.Coral.SystemFrameworks.Michaels

Namespace Michaels

    Public Class DepartmentData
        Public Function GetDepartments() As List(Of DepartmentRecord)
            Dim departments As List(Of DepartmentRecord) = New List(Of DepartmentRecord)
            Dim objRecord As DepartmentRecord
            Dim sql As String = "usp_SPD_Departments_GetRecords"
            Dim reader As DBReader = Nothing
            Dim conn As DBConnection = Nothing
            Try
                conn = Utilities.ApplicationHelper.GetAppConnection()
                reader = New DBReader(conn)
                reader.CommandText = sql
                reader.CommandType = CommandType.StoredProcedure
                reader.Open()
                While reader.Read
                    With reader
                        objRecord = New DepartmentRecord
                        objRecord.Dept = DataHelper.SmartValues(.Item("DEPT"), "integer", False)
                        objRecord.DeptName = DataHelper.SmartValues(.Item("DEPT_NAME"), "string", True)
                        objRecord.DeptDesc = DataHelper.SmartValues(.Item("DEPT"), "string", False) & " - " & objRecord.DeptName
                    End With
                    departments.Add(objRecord)
                End While
            Catch ex As Exception
                Logger.LogError(ex)
                Throw ex
            Finally
                If Not reader Is Nothing Then
                    reader.Dispose()
                    reader = Nothing
                End If
                If Not conn Is Nothing Then
                    conn.Dispose()
                    conn = Nothing
                End If
            End Try
            Return departments
        End Function

        Public Function GetDepartmentsByUserID(ByVal User_ID As Integer) As List(Of DepartmentRecord)

            Dim departments As List(Of DepartmentRecord) = New List(Of DepartmentRecord)
            Dim objRecord As DepartmentRecord
            Dim sql As String = "usp_SPD_Departments_GetRecords_By_UserID"
            Dim reader As DBReader = Nothing
            Dim conn As DBConnection = Nothing
            Try
                conn = Utilities.ApplicationHelper.GetAppConnection()
                reader = New DBReader(conn)
                reader.Command.Parameters.Add("@User_ID", SqlDbType.BigInt).Value = User_ID
                reader.CommandText = sql
                reader.CommandType = CommandType.StoredProcedure
                reader.Open()
                While reader.Read
                    With reader
                        objRecord = New DepartmentRecord
                        objRecord.Dept = DataHelper.SmartValues(.Item("DEPT"), "integer", False)
                        objRecord.DeptName = DataHelper.SmartValues(.Item("DEPT_NAME"), "string", True)
                        objRecord.DeptDesc = DataHelper.SmartValues(.Item("DEPT"), "string", False) & " - " & objRecord.DeptName
                    End With
                    departments.Add(objRecord)
                End While
            Catch ex As Exception
                Logger.LogError(ex)
                Throw ex
            Finally
                If Not reader Is Nothing Then
                    reader.Dispose()
                    reader = Nothing
                End If
                If Not conn Is Nothing Then
                    conn.Dispose()
                    conn = Nothing
                End If
            End Try

            Return departments

        End Function

        Public Function GetDepartmentRecord(ByVal dept As Integer) As NovaLibra.Coral.SystemFrameworks.Michaels.DepartmentRecord
            Dim objRecord As DepartmentRecord = New DepartmentRecord()
            Dim sql As String = "select * from SPD_Fineline_Dept where [DEPT] = @dept"
            Dim reader As DBReader = Nothing
            Dim conn As DBConnection = Nothing
            Dim objParam As System.Data.SqlClient.SqlParameter
            Try
                conn = Utilities.ApplicationHelper.GetAppConnection()
                reader = New DBReader(conn)
                objParam = New System.Data.SqlClient.SqlParameter("@dept", SqlDbType.Float)
                objParam.Value = dept
                reader.Command.Parameters.Add(objParam)
                reader.CommandText = sql
                reader.CommandType = CommandType.Text
                reader.Open()
                If reader.Read() Then
                    With reader
                        objRecord.Dept = DataHelper.SmartValues(.Item("DEPT"), "integer", False)
                        objRecord.DeptName = DataHelper.SmartValues(.Item("DEPT_NAME"), "string", True)
                    End With
                End If
            Catch ex As Exception
                Logger.LogError(ex)
                objRecord.Dept = -1
                Throw ex
            Finally
                If Not reader Is Nothing Then
                    reader.Dispose()
                    reader = Nothing
                End If
                If Not conn Is Nothing Then
                    conn.Dispose()
                    conn = Nothing
                End If
            End Try
            Return objRecord
        End Function

        Public Function GetClassRecords(ByVal dept As Integer) As List(Of NovaLibra.Coral.SystemFrameworks.Michaels.FineLineClass)
            Dim ClassRecords As List(Of FineLineClass) = New List(Of FineLineClass)
            Dim objRecord As FineLineClass
            Dim sql As String = "usp_SPD_FinelineClass_GetRecords"
            Dim reader As DBReader = Nothing
            Dim conn As DBConnection = Nothing
            Dim objParam As System.Data.SqlClient.SqlParameter
            Try
                conn = Utilities.ApplicationHelper.GetAppConnection()
                reader = New DBReader(conn)
                objParam = New System.Data.SqlClient.SqlParameter("@DeptNo", SqlDbType.Int)
                objParam.Value = dept
                reader.Command.Parameters.Add(objParam)
                reader.CommandText = sql
                reader.CommandType = CommandType.StoredProcedure
                reader.Open()
                While reader.Read
                    With reader
                        objRecord = New FineLineClass
                        objRecord.DeptNo = DataHelper.SmartValues(.Item("DEPT"), "integer", False)
                        objRecord.ClassNo = DataHelper.SmartValues(.Item("CLASS"), "integer", False)
                        objRecord.ClassName = DataHelper.SmartValues(.Item("CLASS_NAME"), "string", True)
                        objRecord.ClassDesc = DataHelper.SmartValues(.Item("CLASS"), "string", False) & " - " & objRecord.ClassName
                    End With
                    ClassRecords.Add(objRecord)
                End While
            Catch ex As Exception
                Logger.LogError(ex)
                Throw ex
            Finally
                If Not reader Is Nothing Then
                    reader.Dispose()
                    reader = Nothing
                End If
                If Not conn Is Nothing Then
                    conn.Dispose()
                    conn = Nothing
                End If
            End Try
            Return ClassRecords
        End Function

        Public Function GetSubClassRecords(ByVal dept As Integer, ByVal classNo As Integer) As List(Of NovaLibra.Coral.SystemFrameworks.Michaels.FineLineSubClass)
            Dim ClassRecords As List(Of FineLineSubClass) = New List(Of FineLineSubClass)
            Dim objRecord As FineLineSubClass
            Dim sql As String = "usp_SPD_FinelineSubClass_GetRecords"
            Dim reader As DBReader = Nothing
            Dim conn As DBConnection = Nothing
            Dim objParam As System.Data.SqlClient.SqlParameter
            Try
                conn = Utilities.ApplicationHelper.GetAppConnection()
                reader = New DBReader(conn)

                objParam = New System.Data.SqlClient.SqlParameter("@DeptNo", SqlDbType.Int)
                objParam.Value = dept
                reader.Command.Parameters.Add(objParam)
                objParam = New System.Data.SqlClient.SqlParameter("@ClassNo", SqlDbType.Int)
                objParam.Value = classNo
                reader.Command.Parameters.Add(objParam)

                reader.CommandText = sql
                reader.CommandType = CommandType.StoredProcedure
                reader.Open()
                While reader.Read
                    With reader
                        objRecord = New FineLineSubClass
                        objRecord.DeptNo = DataHelper.SmartValues(.Item("DEPT"), "integer", False)
                        objRecord.ClassNo = DataHelper.SmartValues(.Item("CLASS"), "integer", False)
                        objRecord.SubClassNo = DataHelper.SmartValues(.Item("SUBCLASS"), "integer", False)
                        objRecord.SubClassName = DataHelper.SmartValues(.Item("SUBCLASS_NAME"), "string", True)
                        objRecord.SubClassDesc = DataHelper.SmartValues(.Item("SUBCLASS"), "string", False) & " - " & objRecord.SubClassName
                    End With
                    ClassRecords.Add(objRecord)
                End While
            Catch ex As Exception
                Logger.LogError(ex)
                Throw ex
            Finally
                If Not reader Is Nothing Then
                    reader.Dispose()
                    reader = Nothing
                End If
                If Not conn Is Nothing Then
                    conn.Dispose()
                    conn = Nothing
                End If
            End Try
            Return ClassRecords
        End Function

    End Class

End Namespace
