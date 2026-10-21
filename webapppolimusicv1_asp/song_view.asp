<%@ Language="VBScript" CodePage="65001" %>
<% Option Explicit %>
<!--#include file="includes/conexion.asp"-->
<!--#include file="includes/seguridad.asp"-->
<!--#include file="includes/canciones.asp"-->
<!--#include file="includes/layout.asp"-->
<%
' ============================================================
'  song_view.asp - Leer el detalle de una canción (solo admin)
' ============================================================
Response.Charset = "utf-8"
RequerirAdmin

Dim cn, cmd, rs, rsPl, id
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

Set cmd = CrearComando(cn, _
    "SELECT p.TITLE, p.PHOTO, u.USERNAME FROM TBL_PLAYLIST_SONG ps " & _
    "JOIN TBL_PLAYLIST p ON p.ID_PLAYLIST = ps.ID_PLAYLIST JOIN TBL_USER u ON u.ID_USER = p.ID_USER " & _
    "WHERE ps.ID_SONG = ? ORDER BY p.TITLE")
AgregarParam cmd, adInteger, 4, id
Set rsPl = cmd.Execute

AbrirPagina rs("SONG_NAME"), "crud"
%>
<section class="panel narrow detail">
  <p class="eyebrow">Administración · Detalle #<%= id %></p>
  <div class="detail-head">
    <img class="detail-cover" src="<%= H(PortadaCancion(id)) %>" alt="">
    <div>
      <h1 class="page-title"><%= H(rs("SONG_NAME")) %></h1>
      <p class="muted"><%= H(rs("ARTISTS")) %></p>
      <audio controls preload="none" src="<%= H(ResolverRecurso(rs("SONG_PATH"))) %>"></audio>
    </div>
  </div>

  <dl class="detail-list">
    <dt>Artista(s)</dt><dd><%= H(rs("ARTISTS")) %></dd>
    <dt>Álbum(es)</dt><dd><%= H(rs("ALBUMS")) %></dd>
    <dt>Reproducciones</dt><dd><%= rs("PLAYS") %></dd>
    <dt>Ruta en BD</dt><dd><code><%= H(rs("SONG_PATH")) %></code></dd>
    <dt>Playlists</dt>
    <dd>
      <% If rsPl.EOF Then %>
        <span class="muted">No aparece en ninguna playlist.</span>
      <% Else %>
        <div class="mini-pl">
        <% Do While Not rsPl.EOF %>
          <span class="chip"><img src="<%= H(ResolverRecurso(rsPl("PHOTO"))) %>" alt=""><%= H(rsPl("TITLE")) %> · <%= H(rsPl("USERNAME")) %></span>
        <%   rsPl.MoveNext
           Loop %>
        </div>
      <% End If %>
    </dd>
  </dl>

  <div class="form-actions">
    <a href="crud_songs.asp" class="btn btn-ghost">Volver</a>
    <a href="song_edit.asp?id=<%= id %>" class="btn btn-primary">Editar</a>
    <a href="song_delete.asp?id=<%= id %>" class="btn btn-danger">Eliminar</a>
  </div>
</section>
<%
rs.Close : rsPl.Close
CerrarConexion cn
CerrarPagina
%>
