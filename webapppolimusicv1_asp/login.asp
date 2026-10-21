<%@ Language="VBScript" CodePage="65001" %>
<% Option Explicit %>
<!--#include file="includes/conexion.asp"-->
<!--#include file="includes/seguridad.asp"-->
<%
Response.Charset = "utf-8"

' Si ya hay sesión, ir directo a la lista de canciones
If HaySesion() Then
    Response.Redirect "songs.asp"
    Response.End
End If

Dim usuario, clave, errorMsg
usuario = ""
errorMsg = ""

If Request.ServerVariables("REQUEST_METHOD") = "POST" Then
    usuario = Trim(Request.Form("username"))
    clave = Request.Form("password")

    If usuario = "" Or clave = "" Then
        errorMsg = "Ingresa tu usuario y contraseña."
    ElseIf Len(usuario) > 50 Or Len(clave) > 50 Then
        errorMsg = "Usuario o contraseña incorrectos."
    Else
        Dim cn, cmd, rs
        Set cn = AbrirConexion()
        Set cmd = CrearComando(cn, "SELECT ID_USER, USERNAME, PASSWORD, EMAIL, USER_PHOTO, USER_TYPE FROM TBL_USER WHERE USERNAME = ?")
        AgregarParam cmd, adVarChar, 50, usuario
        Set rs = cmd.Execute

        errorMsg = "Usuario o contraseña incorrectos."
        If Not rs.EOF Then
            ' Comparación binaria (sensible a mayúsculas) de la contraseña
            If StrComp(CStr(rs("PASSWORD")), clave, vbBinaryCompare) = 0 Then
                Session.Timeout = 30
                Session("userId")   = CLng(rs("ID_USER"))
                Session("username") = CStr(rs("USERNAME"))
                Session("rol")      = CInt(rs("USER_TYPE"))
                Session("email")    = CStr(rs("EMAIL"))
                Session("foto")     = ResolverRecurso(rs("USER_PHOTO"))
                Session("csrf")     = ""
                errorMsg = ""
            End If
        End If
        rs.Close
        Set rs = Nothing
        CerrarConexion cn

        If errorMsg = "" Then
            Response.Redirect "songs.asp"
            Response.End
        End If
    End If
End If
%>
<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Iniciar sesión · PoliMusic</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Orbitron:wght@600;800&family=Space+Grotesk:wght@400;500;700&display=swap">
<link rel="stylesheet" href="css/styles.css">
</head>
<body class="login-body">
<canvas id="starfield" aria-hidden="true"></canvas>
<div class="nebula" aria-hidden="true"></div>

<main class="login-wrap">
  <section class="login-card">
    <div class="orbit" aria-hidden="true">
      <span class="brand-planet big"></span>
      <span class="moon"></span>
    </div>
    <h1 class="login-title">Poli<strong>Music</strong></h1>
    <p class="login-sub">Inicia sesión para viajar por tu galaxia musical</p>

    <% If errorMsg <> "" Then %>
      <div class="flash flash-error" role="alert"><%= H(errorMsg) %></div>
    <% End If %>

    <form method="post" action="login.asp" class="form" autocomplete="on">
      <label for="username">Usuario</label>
      <input type="text" id="username" name="username" maxlength="50" required autofocus value="<%= H(usuario) %>">

      <label for="password">Contraseña</label>
      <div class="pwd-field">
        <input type="password" id="password" name="password" maxlength="50" required>
        <button type="button" class="pwd-toggle" aria-label="Mostrar contraseña">👁</button>
      </div>

      <button type="submit" class="btn btn-primary btn-block">Entrar</button>
    </form>

    <div class="login-avatars" aria-hidden="true">
      <img src="SongFilesAndImages_resources/UserImages/default.jpg" alt="">
      <img src="SongFilesAndImages_resources/UserImages/root.png" alt="">
      <img src="SongFilesAndImages_resources/PlaylistImages/playlist1.png" alt="">
      <img src="SongFilesAndImages_resources/PlaylistImages/playlist3.png" alt="">
    </div>
  </section>
</main>
<script src="js/app.js"></script>
</body>
</html>
