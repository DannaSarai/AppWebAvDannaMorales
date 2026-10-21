<%@ Language="VBScript" CodePage="65001" %>
<% Option Explicit %>
<!--#include file="includes/conexion.asp"-->
<!--#include file="includes/seguridad.asp"-->
<!--#include file="includes/canciones.asp"-->
<!--#include file="includes/layout.asp"-->
<!--#include file="includes/form_cancion.asp"-->
<%
' ============================================================
'  song_edit.asp - Actualizar canción (solo admin)
' ============================================================
Response.Charset = "utf-8"
RequerirAdmin

Dim cn, cmd, rs, id, nombre, ruta, rutaOriginal, plays, selArtistas, selAlbumes, errorMsg
id = ObtenerIdQuery("id")
If id = 0 Then
    SetFlash "error", "Canción no válida."
    Response.Redirect "crud_songs.asp"
    Response.End
End If

Set cn = AbrirConexion()

' Datos actuales
Set cmd = CrearComando(cn, "SELECT SONG_NAME, SONG_PATH, ISNULL(PLAYS, 0) AS PLAYS FROM TBL_SONG WHERE ID_SONG = ?")
AgregarParam cmd, adInteger, 4, id
Set rs = cmd.Execute
If rs.EOF Then
    rs.Close
    CerrarConexion cn
    SetFlash "error", "La canción solicitada no existe."
    Response.Redirect "crud_songs.asp"
    Response.End
End If
nombre = rs("SONG_NAME") : rutaOriginal = rs("SONG_PATH") : ruta = rutaOriginal : plays = CStr(rs("PLAYS"))
rs.Close

selArtistas = ","
Set cmd = CrearComando(cn, "SELECT ID_ARTIST FROM TBL_PLAYER WHERE ID_SONG = ?")
AgregarParam cmd, adInteger, 4, id
Set rs = cmd.Execute
Do While Not rs.EOF : selArtistas = selArtistas & rs("ID_ARTIST") & "," : rs.MoveNext : Loop
rs.Close

selAlbumes = ","
Set cmd = CrearComando(cn, "SELECT ID_ALBUM FROM TBL_TRACKLIST WHERE ID_SONG = ?")
AgregarParam cmd, adInteger, 4, id
Set rs = cmd.Execute
Do While Not rs.EOF : selAlbumes = selAlbumes & rs("ID_ALBUM") & "," : rs.MoveNext : Loop
rs.Close

errorMsg = ""
If Request.ServerVariables("REQUEST_METHOD") = "POST" Then
    nombre = Trim(Request.Form("nombre"))
    ruta = Trim(Request.Form("ruta"))
    plays = Trim(Request.Form("plays"))
    selArtistas = LeerSeleccion("artistas")
    selAlbumes = LeerSeleccion("albumes")

    If Not CSRFValido() Then
        errorMsg = "La sesión del formulario expiró. Intenta de nuevo."
    Else
        errorMsg = ValidarCancion(nombre, ruta, plays, rutaOriginal)
    End If

    If errorMsg = "" Then
        On Error Resume Next
        cn.BeginTrans
        Set cmd = CrearComando(cn, "UPDATE TBL_SONG SET SONG_NAME = ?, SONG_PATH = ?, PLAYS = ? WHERE ID_SONG = ?")
        AgregarParam cmd, adVarChar, 50, nombre
        AgregarParam cmd, adVarChar, 255, ruta
        AgregarParam cmd, adInteger, 4, CLng(plays)
        AgregarParam cmd, adInteger, 4, id
        cmd.Execute , , 128
        If Err.Number = 0 Then GuardarRelaciones cn, id, selArtistas, selAlbumes

        If Err.Number = 0 Then
            cn.CommitTrans
            On Error GoTo 0
            CerrarConexion cn
            SetFlash "ok", "Canción """ & nombre & """ actualizada."
            Response.Redirect "crud_songs.asp"
            Response.End
        Else
            errorMsg = "No se pudo actualizar la canción: " & Err.Description
            Err.Clear
            cn.RollbackTrans
        End If
        On Error GoTo 0
    End If
End If

AbrirPagina "Editar canción", "crud"
%>
<section class="panel narrow">
  <p class="eyebrow">Administración · Editar #<%= id %></p>
  <h1 class="page-title">Editar canción</h1>
  <% If errorMsg <> "" Then %><div class="flash flash-error" role="alert"><%= H(errorMsg) %></div><% End If %>
  <% RenderFormCancion cn, "song_edit.asp?id=" & id, id, nombre, ruta, plays, selArtistas, selAlbumes, "Guardar cambios" %>
</section>
<%
CerrarConexion cn
CerrarPagina
%>
