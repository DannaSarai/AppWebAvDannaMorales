<%
' ============================================================
'  seguridad.asp - Protección de páginas por sesión y rol
'  USER_TYPE: 0 = usuario normal, 1 = administrador
' ============================================================

' Evita que el navegador muestre páginas protegidas desde caché tras el logout
Response.Expires = -1
Response.CacheControl = "no-cache, no-store"
Response.AddHeader "Pragma", "no-cache"

Function HaySesion()
    HaySesion = (CStr(Session("username")) <> "")
End Function

Function EsAdmin()
    EsAdmin = False
    If HaySesion() Then
        If CStr(Session("rol")) = "1" Then EsAdmin = True
    End If
End Function

Sub RequerirLogin()
    If Not HaySesion() Then
        Response.Redirect "login.asp"
        Response.End
    End If
End Sub

' Valida el rol en el servidor: solo admin puede acceder al CRUD
Sub RequerirAdmin()
    RequerirLogin
    If Not EsAdmin() Then
        Session("flash_tipo") = "error"
        Session("flash_texto") = "Acceso denegado: esa sección es solo para administradores."
        Response.Redirect "songs.asp"
        Response.End
    End If
End Sub

' Token anti-CSRF para formularios POST
Function TokenCSRF()
    If CStr(Session("csrf")) = "" Then
        Dim i, t
        Randomize
        t = ""
        For i = 1 To 32
            t = t & Hex(Int(Rnd * 16))
        Next
        Session("csrf") = t
    End If
    TokenCSRF = Session("csrf")
End Function

Function CSRFValido()
    CSRFValido = (CStr(Session("csrf")) <> "" And Request.Form("csrf") = CStr(Session("csrf")))
End Function

Function CampoCSRF()
    CampoCSRF = "<input type=""hidden"" name=""csrf"" value=""" & TokenCSRF() & """>"
End Function
%>
