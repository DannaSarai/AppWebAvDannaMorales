<%@ Language="VBScript" CodePage="65001" %>
<% Option Explicit %>
<!--#include file="includes/conexion.asp"-->
<!--#include file="includes/seguridad.asp"-->
<!--#include file="includes/layout.asp"-->
<!--#include file="includes/form_cancion.asp"-->
<%
' ============================================================
'  song_new.asp - Crear canción (solo admin)
' ============================================================
Response.Charset = "utf-8"
RequerirAdmin

Dim cn, cmd, rs, nombre, ruta, plays, selArtistas, selAlbumes, errorMsg, nuevoId, archivos
nombre = "" : plays = "0" : selArtistas = "," : selAlbumes = "," : errorMsg = ""
archivos = ListarMp3()
ruta = ""
If UBound(archivos) >= 0 Then ruta = "~/songFiles/" & archivos(0)

Set cn = AbrirConexion()

If Request.ServerVariables("REQUEST_METHOD") = "POST" Then
    nombre = Trim(Request.Form("nombre"))
    ruta = Trim(Request.Form("ruta"))
    plays = Trim(Request.Form("plays"))
    selArtistas = LeerSeleccion("artistas")
    selAlbumes = LeerSeleccion("albumes")

    If Not CSRFValido() Then
        errorMsg = "La sesión del formulario expiró. Intenta de nuevo."
    Else
        errorMsg = ValidarCancion(nombre, ruta, plays, "")
    End If

    If errorMsg = "" Then
        On Error Resume Next
        cn.BeginTrans
        Set cmd = CrearComando(cn, _
            "SET NOCOUNT ON; INSERT INTO TBL_SONG (SONG_NAME, SONG_PATH, PLAYS) VALUES (?, ?, ?); " & _
            "SELECT CAST(SCOPE_IDENTITY() AS INT) AS NEWID;")
        AgregarParam cmd, adVarChar, 50, nombre
        AgregarParam cmd, adVarChar, 255, ruta
        AgregarParam cmd, adInteger, 4, CLng(plays)
        Set rs = cmd.Execute
        If Err.Number = 0 Then
            nuevoId = CLng(rs("NEWID"))
            rs.Close
            GuardarRelaciones cn, nuevoId, selArtistas, selAlbumes
        End If

        If Err.Number = 0 Then
            cn.CommitTrans
            On Error GoTo 0
            CerrarConexion cn
            SetFlash "ok", "Canción """ & nombre & """ creada correctamente."
            Response.Redirect "crud_songs.asp"
            Response.End
        Else
            errorMsg = "No se pudo guardar la canción: " & Err.Description
            Err.Clear
            cn.RollbackTrans
        End If
        On Error GoTo 0
    End If
End If

AbrirPagina "Nueva canción", "new"
%>
<section class="panel narrow">
  <p class="eyebrow">Administración · Crear</p>
  <h1 class="page-title">Nueva canción</h1>
  <% If errorMsg <> "" Then %><div class="flash flash-error" role="alert"><%= H(errorMsg) %></div><% End If %>
  <% RenderFormCancion cn, "song_new.asp", 0, nombre, ruta, plays, selArtistas, selAlbumes, "Crear canción" %>
</section>
<%
CerrarConexion cn
CerrarPagina
%>
