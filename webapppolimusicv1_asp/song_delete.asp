<%@ Language="VBScript" CodePage="65001" %>
<% Option Explicit %>
<!--#include file="includes/conexion.asp"-->
<!--#include file="includes/seguridad.asp"-->
<!--#include file="includes/canciones.asp"-->
<!--#include file="includes/layout.asp"-->
<%
' ============================================================
'  song_delete.asp - Eliminar canción (solo admin)
'  GET: confirmación · POST: borra relaciones y la canción
' ============================================================
Response.Charset = "utf-8"
RequerirAdmin

Dim cn, cmd, rs, id, nombre, errorMsg
id = ObtenerIdQuery("id")
Set cn = AbrirConexion()

Set cmd = CrearComando(cn, SqlCanciones("WHERE s.ID_SONG = ?"))
AgregarParam cmd, adInteger, 4, id
Set rs = cmd.Execute
If rs.EOF Then
    rs.Close
    CerrarConexion cn
    SetFlash "error", "La canción solicitada no existe."
    Response.Redirect "crud_songs.asp"
    Response.End
End If
nombre = rs("SONG_NAME")

errorMsg = ""
If Request.ServerVariables("REQUEST_METHOD") = "POST" Then
    If Not CSRFValido() Then
        errorMsg = "La sesión del formulario expiró. Intenta de nuevo."
    Else
        On Error Resume Next
        cn.BeginTrans
        ' Primero las tablas que referencian a TBL_SONG (llaves foráneas)
        Set cmd = CrearComando(cn, _
            "DELETE FROM TBL_PLAYER WHERE ID_SONG = ?; " & _
            "DELETE FROM TBL_TRACKLIST WHERE ID_SONG = ?; " & _
            "DELETE FROM TBL_PLAYLIST_SONG WHERE ID_SONG = ?; " & _
            "DELETE FROM TBL_SONG WHERE ID_SONG = ?;")
        AgregarParam cmd, adInteger, 4, id
        AgregarParam cmd, adInteger, 4, id
        AgregarParam cmd, adInteger, 4, id
        AgregarParam cmd, adInteger, 4, id
        cmd.Execute , , 128
        If Err.Number = 0 Then
            cn.CommitTrans
            On Error GoTo 0
            rs.Close
            CerrarConexion cn
            SetFlash "ok", "Canción """ & nombre & """ eliminada."
            Response.Redirect "crud_songs.asp"
            Response.End
        Else
            errorMsg = "No se pudo eliminar: " & Err.Description
            Err.Clear
            cn.RollbackTrans
        End If
        On Error GoTo 0
    End If
End If

AbrirPagina "Eliminar canción", "crud"
%>
<section class="panel narrow danger-zone">
  <p class="eyebrow">Administración · Eliminar #<%= id %></p>
  <h1 class="page-title">¿Eliminar esta canción?</h1>
  <% If errorMsg <> "" Then %><div class="flash flash-error" role="alert"><%= H(errorMsg) %></div><% End If %>

  <div class="detail-head">
    <img class="detail-cover" src="<%= H(PortadaCancion(id)) %>" alt="">
    <div>
      <h2><%= H(nombre) %></h2>
      <p class="muted"><%= H(rs("ARTISTS")) %> · <%= H(rs("ALBUMS")) %></p>
      <p class="muted"><%= rs("PLAYS") %> reproducciones</p>
    </div>
  </div>
  <p>Se eliminará la canción y sus vínculos con artistas, álbumes y playlists. Esta acción no se puede deshacer.</p>

  <form method="post" action="song_delete.asp?id=<%= id %>" class="form-actions">
    <%= CampoCSRF() %>
    <a href="crud_songs.asp" class="btn btn-ghost">Cancelar</a>
    <button type="submit" class="btn btn-danger">Sí, eliminar</button>
  </form>
</section>
<%
rs.Close
CerrarConexion cn
CerrarPagina
%>
