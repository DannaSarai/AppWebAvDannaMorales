<%@ Language="VBScript" CodePage="65001" %>
<% Option Explicit %>
<%
' Destruye la sesión y vuelve al login
Session.Contents.RemoveAll
Session.Abandon
Response.Expires = -1
Response.Redirect "login.asp"
%>
