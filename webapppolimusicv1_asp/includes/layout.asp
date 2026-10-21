<%
' ============================================================
'  layout.asp - Cabecera (navegación) y pie comunes
' ============================================================

Sub AbrirPagina(titulo, seccion)
%><!DOCTYPE html>
<html lang="es">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title><%= H(titulo) %> · PoliMusic</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Orbitron:wght@600;800&family=Space+Grotesk:wght@400;500;700&display=swap">
<link rel="stylesheet" href="css/styles.css">
</head>
<body>
<canvas id="starfield" aria-hidden="true"></canvas>
<div class="nebula" aria-hidden="true"></div>

<header class="topbar">
  <a class="brand" href="songs.asp" aria-label="PoliMusic, inicio">
    <span class="brand-planet" aria-hidden="true"></span>
    <span class="brand-text">Poli<strong>Music</strong></span>
  </a>
  <button class="nav-toggle" type="button" aria-label="Abrir menú" aria-expanded="false" aria-controls="mainnav">
    <span></span><span></span><span></span>
  </button>
  <nav id="mainnav" class="mainnav">
    <a href="songs.asp" class="<% If seccion = "songs" Then Response.Write "active" %>">Song List</a>
    <% If EsAdmin() Then %>
    <a href="crud_songs.asp" class="<% If seccion = "crud" Then Response.Write "active" %>">Gestionar canciones</a>
    <a href="song_new.asp" class="<% If seccion = "new" Then Response.Write "active" %>">+ Nueva</a>
    <% End If %>
    <div class="user-chip">
      <img src="<%= H(Session("foto")) %>" alt="Foto de <%= H(Session("username")) %>">
      <div class="user-meta">
        <span class="user-name"><%= H(Session("username")) %></span>
        <span class="user-email"><%= H(Session("email")) %></span>
        <span class="role-badge <% If EsAdmin() Then Response.Write "admin" %>"><% If EsAdmin() Then Response.Write "Admin" Else Response.Write "Usuario" %></span>
      </div>
    </div>
    <a href="logout.asp" class="btn btn-ghost btn-sm logout">Cerrar sesión</a>
  </nav>
</header>

<main class="container">
<%
    MostrarFlash
End Sub

Sub CerrarPagina()
%>
</main>
<footer class="site-footer">
  <p>PoliMusic · un pequeño universo de canciones · ASP Clásico + SQL Server</p>
</footer>
<script src="js/app.js"></script>
</body>
</html>
<%
End Sub
%>
