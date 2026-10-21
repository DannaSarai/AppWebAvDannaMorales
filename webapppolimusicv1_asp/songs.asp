<%@ Language="VBScript" CodePage="65001" %>
<% Option Explicit %>
<!--#include file="includes/conexion.asp"-->
<!--#include file="includes/seguridad.asp"-->
<!--#include file="includes/canciones.asp"-->
<!--#include file="includes/layout.asp"-->
<%
Response.Charset = "utf-8"
RequerirLogin

Dim cn, cmd, rs, rsPl, idPlaylist, tituloPlaylist, totalCanciones, totalPlays
Set cn = AbrirConexion()

' Playlists visibles: públicas (TYPE = 0) o del usuario logueado
Set cmd = CrearComando(cn, _
    "SELECT p.ID_PLAYLIST, p.TITLE, p.PHOTO, p.TYPE, COUNT(ps.ID_SONG) AS TOTAL " & _
    "FROM TBL_PLAYLIST p LEFT JOIN TBL_PLAYLIST_SONG ps ON ps.ID_PLAYLIST = p.ID_PLAYLIST " & _
    "WHERE p.TYPE = 0 OR p.ID_USER = ? " & _
    "GROUP BY p.ID_PLAYLIST, p.TITLE, p.PHOTO, p.TYPE ORDER BY p.ID_PLAYLIST")
AgregarParam cmd, adInteger, 4, CLng(Session("userId"))
Set rsPl = cmd.Execute

' Filtro opcional por playlist (solo si es visible para el usuario)
idPlaylist = ObtenerIdQuery("playlist")
tituloPlaylist = ""
If idPlaylist > 0 Then
    Set cmd = CrearComando(cn, "SELECT TITLE FROM TBL_PLAYLIST WHERE ID_PLAYLIST = ? AND (TYPE = 0 OR ID_USER = ?)")
    AgregarParam cmd, adInteger, 4, idPlaylist
    AgregarParam cmd, adInteger, 4, CLng(Session("userId"))
    Set rs = cmd.Execute
    If rs.EOF Then
        idPlaylist = 0
    Else
        tituloPlaylist = rs("TITLE")
    End If
    rs.Close
End If

If idPlaylist > 0 Then
    Set cmd = CrearComando(cn, SqlCanciones("WHERE EXISTS (SELECT 1 FROM TBL_PLAYLIST_SONG ps WHERE ps.ID_SONG = s.ID_SONG AND ps.ID_PLAYLIST = ?)"))
    AgregarParam cmd, adInteger, 4, idPlaylist
Else
    Set cmd = CrearComando(cn, SqlCanciones(""))
End If
Set rs = cmd.Execute

AbrirPagina "Song List", "songs"
%>
<section class="hero">
  <div class="hero-text">
    <p class="eyebrow">Sesión iniciada</p>
    <h2 class="welcome">¡Te damos la bienvenida, <span class="glow"><%= H(Session("username")) %></span>!</h2>
    <p class="muted">
      <% If EsAdmin() Then %>
        Como administrador puedes reproducir y además <a href="crud_songs.asp">gestionar el catálogo</a>.
      <% Else %>
        Elige una canción de la lista y deja que suene entre las estrellas.
      <% End If %>
    </p>
  </div>
  <img class="hero-avatar" src="<%= H(Session("foto")) %>" alt="Foto de perfil de <%= H(Session("username")) %>">
</section>

<% If Not rsPl.EOF Then %>
<section class="playlists" aria-labelledby="pl-title">
  <h3 id="pl-title" class="section-title">Constelaciones <span class="muted">(playlists)</span></h3>
  <div class="pl-row">
    <a class="pl-card <% If idPlaylist = 0 Then Response.Write "active" %>" href="songs.asp">
      <span class="pl-all" aria-hidden="true">✦</span>
      <span class="pl-name">Todas</span>
      <span class="pl-count">Catálogo completo</span>
    </a>
    <% Do While Not rsPl.EOF %>
    <a class="pl-card <% If CLng(rsPl("ID_PLAYLIST")) = idPlaylist Then Response.Write "active" %>" href="songs.asp?playlist=<%= rsPl("ID_PLAYLIST") %>">
      <img src="<%= H(ResolverRecurso(rsPl("PHOTO"))) %>" alt="">
      <span class="pl-name"><%= H(rsPl("TITLE")) %></span>
      <span class="pl-count"><%= rsPl("TOTAL") %> canciones · <% If CInt(rsPl("TYPE")) = 0 Then Response.Write "Pública" Else Response.Write "Privada" %></span>
    </a>
    <%   rsPl.MoveNext
       Loop %>
  </div>
</section>
<% End If %>

<section class="panel" aria-labelledby="songlist-title">
  <div class="panel-head">
    <h1 id="songlist-title" class="page-title">Song List</h1>
    <% If tituloPlaylist <> "" Then %>
      <span class="chip">Playlist: <%= H(tituloPlaylist) %></span>
    <% End If %>
  </div>

  <% If rs.EOF Then %>
    <p class="empty">No hay canciones para mostrar.</p>
  <% Else %>
  <div class="table-wrap">
  <table class="song-table" id="songTable">
    <thead>
      <tr>
        <th scope="col" class="col-num">#</th>
        <th scope="col">Canción</th>
        <th scope="col">Artista</th>
        <th scope="col">Álbum</th>
        <th scope="col" class="col-num">Reproducciones</th>
        <th scope="col" class="col-play"><span class="sr-only">Reproducir</span></th>
      </tr>
    </thead>
    <tbody>
    <%
    Dim n, artistas, albumes
    n = 0
    totalCanciones = 0 : totalPlays = 0
    Do While Not rs.EOF
        n = n + 1
        artistas = rs("ARTISTS") : If artistas = "" Then artistas = "Artista desconocido"
        albumes = rs("ALBUMS")   : If albumes = "" Then albumes = "Sin álbum"
        totalCanciones = totalCanciones + 1
        totalPlays = totalPlays + CLng(rs("PLAYS"))
    %>
      <tr data-id="<%= rs("ID_SONG") %>"
          data-src="<%= H(ResolverRecurso(rs("SONG_PATH"))) %>"
          data-title="<%= H(rs("SONG_NAME")) %>"
          data-artist="<%= H(artistas) %>"
          data-cover="<%= H(PortadaCancion(rs("ID_SONG"))) %>">
        <td class="col-num" data-label="#"><span class="idx"><%= n %></span></td>
        <td data-label="Canción">
          <div class="song-cell">
            <img src="<%= H(PortadaCancion(rs("ID_SONG"))) %>" alt="" loading="lazy">
            <span class="song-name"><%= H(rs("SONG_NAME")) %></span>
          </div>
        </td>
        <td data-label="Artista"><%= H(artistas) %></td>
        <td data-label="Álbum"><%= H(albumes) %></td>
        <td class="col-num" data-label="Reproducciones"><span class="plays"><%= rs("PLAYS") %></span></td>
        <td class="col-play">
          <button type="button" class="play-btn" aria-label="Reproducir <%= H(rs("SONG_NAME")) %>">
            <span class="ico-play" aria-hidden="true"></span>
          </button>
        </td>
      </tr>
    <%
        rs.MoveNext
    Loop
    %>
    </tbody>
  </table>
  </div>
  <p class="table-foot muted"><%= totalCanciones %> canciones · <span id="totalPlays"><%= totalPlays %></span> reproducciones en total</p>
  <% End If %>
</section>

<!-- Reproductor fijo -->
<div class="player" id="player" data-csrf="<%= TokenCSRF() %>" hidden>
  <img class="player-cover" id="playerCover" src="SongFilesAndImages_resources/PlaylistImages/default.jpg" alt="">
  <div class="player-info">
    <span class="player-title" id="playerTitle">—</span>
    <span class="player-artist" id="playerArtist">—</span>
  </div>
  <div class="player-controls">
    <button type="button" class="ctrl" id="btnPrev" aria-label="Anterior">⏮</button>
    <audio id="audio" controls preload="none"></audio>
    <button type="button" class="ctrl" id="btnNext" aria-label="Siguiente">⏭</button>
  </div>
</div>
<%
rs.Close : Set rs = Nothing
rsPl.Close : Set rsPl = Nothing
CerrarConexion cn
CerrarPagina
%>
