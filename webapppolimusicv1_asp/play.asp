<%@ Language="VBScript" CodePage="65001" %>
<% Option Explicit %>
<!--#include file="includes/conexion.asp"-->
<!--#include file="includes/seguridad.asp"-->
<%
' ============================================================
'  play.asp - Incrementa PLAYS de una canción (llamado por fetch)
'  POST: id, csrf  ->  JSON { ok, plays }
' ============================================================
Response.Charset = "utf-8"
Response.ContentType = "application/json"

If Not HaySesion() Then
    Response.Status = "401 Unauthorized"
    Response.Write "{""ok"":false,""error"":""sin sesion""}"
    Response.End
End If

If Request.ServerVariables("REQUEST_METHOD") <> "POST" Or Not CSRFValido() Then
    Response.Status = "400 Bad Request"
    Response.Write "{""ok"":false,""error"":""solicitud invalida""}"
    Response.End
End If

If Not EsEntero(Request.Form("id")) Then
    Response.Status = "400 Bad Request"
    Response.Write "{""ok"":false,""error"":""id invalido""}"
    Response.End
End If

Dim cn, cmd, rs, plays
Set cn = AbrirConexion()
Set cmd = CrearComando(cn, _
    "SET NOCOUNT ON; " & _
    "UPDATE TBL_SONG SET PLAYS = ISNULL(PLAYS, 0) + 1 WHERE ID_SONG = ?; " & _
    "SELECT PLAYS FROM TBL_SONG WHERE ID_SONG = ?;")
AgregarParam cmd, adInteger, 4, CLng(Request.Form("id"))
AgregarParam cmd, adInteger, 4, CLng(Request.Form("id"))
Set rs = cmd.Execute

If rs.EOF Then
    Response.Status = "404 Not Found"
    Response.Write "{""ok"":false,""error"":""no existe""}"
Else
    plays = CLng(rs("PLAYS"))
    Response.Write "{""ok"":true,""plays"":" & plays & "}"
End If
rs.Close
Set rs = Nothing
CerrarConexion cn
%>
