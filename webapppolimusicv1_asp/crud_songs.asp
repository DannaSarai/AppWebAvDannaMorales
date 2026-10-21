<%@ Language="VBScript" CodePage="65001" %>
<% Option Explicit %>
<!--#include file="includes/conexion.asp"-->
<!--#include file="includes/seguridad.asp"-->
<!--#include file="includes/canciones.asp"-->
<!--#include file="includes/layout.asp"-->
<%
' ============================================================
'  crud_songs.asp - Panel de administración: leer y buscar
' ============================================================
Response.Charset = "utf-8"
RequerirAdmin

Dim cn, cmd, rs, q, patron, total
q = Trim(Request.QueryString("q"))
If Len(q) > 50 Then q = Left(q, 50)

Set cn = AbrirConexion()
If q <> "" Then
    patron = PatronLike(q)
    Set cmd = CrearComando(cn, SqlCanciones(FiltroBusqueda()))
    AgregarParam cmd, adVarChar, 160, patron
    AgregarParam cmd, adVarChar, 160, patron
    AgregarParam cmd, adVarChar, 160, patron
Else
    Set cmd = CrearComando(cn, SqlCanciones(""))
End If
Set rs = cmd.Execute
total = rs.RecordCount

AbrirPagina "Gestionar canciones", "crud"
%>
<section class="panel">
  <div class="panel-head">
    <div>
      <p class="eyebrow">Administración</p>
      <h1 class="page-title">Gestionar canciones</h1>
    </div>
    <a href="song_new.asp" class="btn btn-primary">+ Nueva canción</a>
  </div>

  <form method="get" action="crud_songs.asp" class="search-bar" role="search">
    <label for="q" class="sr-only">Buscar canciones</label>
    <input type="search" id="q" name="q" maxlength="50" placeholder="Buscar por canción, artista o álbum…" value="<%= H(q) %>">
    <button type="submit" class="btn btn-primary">Buscar</button>
    <% If q <> "" Then %><a href="crud_songs.asp" class="btn btn-ghost">Limpiar</a><% End If %>
  </form>

  <p class="muted result-count">
    <% If q <> "" Then %>
      <%= total %> resultado(s) para “<%= H(q) %>”
    <% Else %>
      <%= total %> canciones en el catálogo
    <% End If %>
  </p>

  <% If rs.EOF Then %>
    <p class="empty">No se encontraron canciones.</p>
  <% Else %>
  <div class="table-wrap">
  <table class="song-table admin-table">
    <thead>
      <tr>
        <th scope="col" class="col-num">ID</th>
        <th scope="col">Canción</th>
        <th scope="col">Artista</th>
        <th scope="col">Álbum</th>
        <th scope="col" class="col-num">Reproducciones</th>
        <th scope="col">Acciones</th>
      </tr>
    </thead>
    <tbody>
    <% Do While Not rs.EOF %>
      <tr>
        <td class="col-num" data-label="ID"><%= rs("ID_SONG") %></td>
        <td data-label="Canción">
          <div class="song-cell">
            <img src="<%= H(PortadaCancion(rs("ID_SONG"))) %>" alt="" loading="lazy">
            <span class="song-name"><%= H(rs("SONG_NAME")) %></span>
          </div>
        </td>
        <td data-label="Artista"><%= H(rs("ARTISTS")) %></td>
        <td data-label="Álbum"><%= H(rs("ALBUMS")) %></td>
        <td class="col-num" data-label="Reproducciones"><%= rs("PLAYS") %></td>
        <td data-label="Acciones">
          <div class="actions">
            <a class="btn btn-sm btn-ghost" href="song_view.asp?id=<%= rs("ID_SONG") %>">Ver</a>
            <a class="btn btn-sm btn-ghost" href="song_edit.asp?id=<%= rs("ID_SONG") %>">Editar</a>
            <a class="btn btn-sm btn-danger" href="song_delete.asp?id=<%= rs("ID_SONG") %>">Eliminar</a>
          </div>
        </td>
      </tr>
    <%   rs.MoveNext
       Loop %>
    </tbody>
  </table>
  </div>
  <% End If %>
</section>
<%
rs.Close : Set rs = Nothing
CerrarConexion cn
CerrarPagina
%>
