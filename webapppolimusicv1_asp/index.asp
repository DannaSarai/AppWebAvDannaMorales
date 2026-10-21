<%@ Language="VBScript" CodePage="65001" %>
<% Option Explicit %>
<%
If CStr(Session("username")) <> "" Then
    Response.Redirect "songs.asp"
Else
    Response.Redirect "login.asp"
End If
%>
