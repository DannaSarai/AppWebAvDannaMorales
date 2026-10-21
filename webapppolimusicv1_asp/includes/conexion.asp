<%
' ============================================================
'  conexion.asp - Conexión ADODB reutilizable a BDD_PoliMusic
'  y funciones auxiliares comunes.
' ============================================================

' Constantes ADO (evita depender de adovbs.inc)
Const adCmdText = 1
Const adParamInput = 1
Const adInteger = 3
Const adVarChar = 200
Const adUseClient = 3

' Credenciales tomadas de BDD_PoliMusic.sql (login usr_polimusic)
Const DB_CONN_STRING = "Provider=MSOLEDBSQL19;Data Source=localhost;Initial Catalog=BDD_PoliMusic;User ID=usr_polimusic;Password=Politecnica1;Use Encryption for Data=Optional;"

' Carpeta de recursos (canciones e imágenes) dentro del sitio
Const RES_ROOT = "SongFilesAndImages_resources/"
Const SONG_DEFAULT = "SongFilesAndImages_resources/SongFiles/bensound-adventure.mp3"

Function AbrirConexion()
    Dim cn
    Set cn = Server.CreateObject("ADODB.Connection")
    cn.ConnectionTimeout = 15
    cn.CursorLocation = adUseClient   ' recordsets en cliente: permite varias consultas abiertas
    cn.Open DB_CONN_STRING
    Set AbrirConexion = cn
End Function

Sub CerrarConexion(cn)
    If IsObject(cn) Then
        If Not cn Is Nothing Then
            If cn.State <> 0 Then cn.Close
            Set cn = Nothing
        End If
    End If
End Sub

' Crea un comando parametrizado (evita inyección SQL)
Function CrearComando(cn, sql)
    Dim cmd
    Set cmd = Server.CreateObject("ADODB.Command")
    Set cmd.ActiveConnection = cn
    cmd.CommandType = adCmdText
    cmd.CommandText = sql
    Set CrearComando = cmd
End Function

Sub AgregarParam(cmd, tipo, tamano, valor)
    cmd.Parameters.Append cmd.CreateParameter(, tipo, adParamInput, tamano, valor)
End Sub

' HTML-encode tolerante a Null
Function H(valor)
    If IsNull(valor) Or IsEmpty(valor) Then
        H = ""
    Else
        H = Server.HTMLEncode(CStr(valor))
    End If
End Function

Function EsEntero(valor)
    EsEntero = False
    If IsNull(valor) Or IsEmpty(valor) Then Exit Function
    Dim re
    Set re = New RegExp
    re.Pattern = "^\d{1,9}$"
    EsEntero = re.Test(Trim(CStr(valor)))
End Function

Function ArchivoExiste(rutaRelativa)
    Dim fso
    Set fso = Server.CreateObject("Scripting.FileSystemObject")
    ArchivoExiste = fso.FileExists(Server.MapPath(rutaRelativa))
    Set fso = Nothing
End Function

' Convierte una ruta de la BD ("~/songFiles/x.mp3", "~/userImages/x.png", ...)
' a una URL relativa dentro de SongFilesAndImages_resources.
' Si el archivo no existe, devuelve el recurso por defecto de esa carpeta.
Function ResolverRecurso(ruta)
    Dim r, partes, carpeta, archivo, url, porDefecto
    r = ""
    If Not IsNull(ruta) Then r = Trim(CStr(ruta))
    If Left(r, 2) = "~/" Then r = Mid(r, 3)
    partes = Split(r, "/")
    carpeta = "" : archivo = ""
    If UBound(partes) >= 1 Then
        carpeta = LCase(partes(0))
        archivo = partes(UBound(partes))
    End If

    Select Case carpeta
        Case "songfiles"
            url = RES_ROOT & "SongFiles/" & archivo
            porDefecto = SONG_DEFAULT
        Case "userimages"
            url = RES_ROOT & "UserImages/" & archivo
            porDefecto = RES_ROOT & "UserImages/default.jpg"
        Case "playlistimages"
            url = RES_ROOT & "PlaylistImages/" & LCase(archivo)
            porDefecto = RES_ROOT & "PlaylistImages/default.jpg"
        Case Else
            url = ""
            porDefecto = RES_ROOT & "PlaylistImages/default.jpg"
    End Select

    If url <> "" And archivo <> "" Then
        If ArchivoExiste(url) Then
            ResolverRecurso = url
            Exit Function
        End If
    End If
    ResolverRecurso = porDefecto
End Function

' Portada decorativa para una canción (usa las portadas de playlist de los recursos)
Function PortadaCancion(idCancion)
    PortadaCancion = RES_ROOT & "PlaylistImages/playlist" & (((CLng(idCancion) - 1) Mod 5) + 1) & ".png"
End Function

' Lista de archivos .mp3 disponibles en SongFiles
Function ListarMp3()
    Dim fso, carpeta, f, lista
    lista = ""
    Set fso = Server.CreateObject("Scripting.FileSystemObject")
    If fso.FolderExists(Server.MapPath(RES_ROOT & "SongFiles")) Then
        Set carpeta = fso.GetFolder(Server.MapPath(RES_ROOT & "SongFiles"))
        For Each f In carpeta.Files
            If LCase(fso.GetExtensionName(f.Name)) = "mp3" Then
                If lista <> "" Then lista = lista & "|"
                lista = lista & f.Name
            End If
        Next
    End If
    Set fso = Nothing
    If lista = "" Then
        ListarMp3 = Array()
    Else
        ListarMp3 = Split(lista, "|")
    End If
End Function

' Mensajes flash entre redirecciones
Sub SetFlash(tipo, texto)
    Session("flash_tipo") = tipo
    Session("flash_texto") = texto
End Sub

Sub MostrarFlash()
    If Session("flash_texto") <> "" Then
        Response.Write "<div class=""flash flash-" & H(Session("flash_tipo")) & """ role=""status"">" & H(Session("flash_texto")) & "</div>"
        Session("flash_texto") = ""
        Session("flash_tipo") = ""
    End If
End Sub
%>
