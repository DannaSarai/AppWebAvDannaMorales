<%
' ============================================================
'  form_cancion.asp - Formulario compartido para crear/editar
'  canciones (TBL_SONG + relaciones TBL_PLAYER y TBL_TRACKLIST)
' ============================================================

' Lee checkboxes múltiples y devuelve ",1,3," (solo enteros válidos)
Function LeerSeleccion(campo)
    Dim i, v, s
    s = ","
    For i = 1 To Request.Form(campo).Count
        v = Request.Form(campo)(i)
        If EsEntero(v) Then s = s & CLng(v) & ","
    Next
    LeerSeleccion = s
End Function

Function EstaSeleccionado(lista, id)
    EstaSeleccionado = (InStr(lista, "," & CLng(id) & ",") > 0)
End Function

Function RutaPermitida(ruta, rutaOriginal)
    Dim archivos, i
    RutaPermitida = False
    If ruta <> "" And ruta = rutaOriginal Then
        RutaPermitida = True
        Exit Function
    End If
    archivos = ListarMp3()
    For i = 0 To UBound(archivos)
        If ruta = "~/songFiles/" & archivos(i) Then
            RutaPermitida = True
            Exit Function
        End If
    Next
End Function

Function ValidarCancion(nombre, ruta, plays, rutaOriginal)
    Dim e
    e = ""
    If nombre = "" Then
        e = "El nombre de la canción es obligatorio."
    ElseIf Len(nombre) > 50 Then
        e = "El nombre no puede superar 50 caracteres."
    ElseIf Not RutaPermitida(ruta, rutaOriginal) Then
        e = "Selecciona un archivo de audio válido."
    ElseIf Not EsEntero(plays) Then
        e = "Las reproducciones deben ser un número entero mayor o igual a 0."
    End If
    ValidarCancion = e
End Function

' Reemplaza artistas y álbumes de la canción (dentro de la transacción del llamador)
Sub GuardarRelaciones(cn, idCancion, selArtistas, selAlbumes)
    Dim cmd, ids, i
    Set cmd = CrearComando(cn, "DELETE FROM TBL_PLAYER WHERE ID_SONG = ?; DELETE FROM TBL_TRACKLIST WHERE ID_SONG = ?;")
    AgregarParam cmd, adInteger, 4, idCancion
    AgregarParam cmd, adInteger, 4, idCancion
    cmd.Execute , , 128   ' adExecuteNoRecords

    ids = Split(selArtistas, ",")
    For i = 0 To UBound(ids)
        If ids(i) <> "" Then
            Set cmd = CrearComando(cn, "INSERT INTO TBL_PLAYER (ID_SONG, ID_ARTIST) SELECT ?, ID_ARTIST FROM TBL_ARTIST WHERE ID_ARTIST = ?")
            AgregarParam cmd, adInteger, 4, idCancion
            AgregarParam cmd, adInteger, 4, CLng(ids(i))
            cmd.Execute , , 128
        End If
    Next

    ids = Split(selAlbumes, ",")
    For i = 0 To UBound(ids)
        If ids(i) <> "" Then
            Set cmd = CrearComando(cn, "INSERT INTO TBL_TRACKLIST (ID_ALBUM, ID_SONG) SELECT ID_ALBUM, ? FROM TBL_ALBUM WHERE ID_ALBUM = ?")
            AgregarParam cmd, adInteger, 4, idCancion
            AgregarParam cmd, adInteger, 4, CLng(ids(i))
            cmd.Execute , , 128
        End If
    Next
End Sub

Sub RenderFormCancion(cn, accion, idCancion, nombre, ruta, plays, selArtistas, selAlbumes, textoBoton)
    Dim rs, archivos, i, opcion, existe
    archivos = ListarMp3()
%>
<form method="post" action="<%= accion %>" class="form form-song" novalidate>
  <%= CampoCSRF() %>
  <% If idCancion > 0 Then %><input type="hidden" name="id" value="<%= idCancion %>"><% End If %>

  <div class="grid-2">
    <div>
      <label for="nombre">Nombre de la canción *</label>
      <input type="text" id="nombre" name="nombre" maxlength="50" required value="<%= H(nombre) %>">
    </div>
    <div>
      <label for="plays">Reproducciones</label>
      <input type="number" id="plays" name="plays" min="0" step="1" required value="<%= H(plays) %>">
    </div>
  </div>

  <label for="ruta">Archivo de audio (SongFiles) *</label>
  <select id="ruta" name="ruta" required>
    <%
    existe = False
    For i = 0 To UBound(archivos)
        opcion = "~/songFiles/" & archivos(i)
        If opcion = ruta Then existe = True
    %>
      <option value="<%= H(opcion) %>" <% If opcion = ruta Then Response.Write "selected" %>><%= H(archivos(i)) %></option>
    <%
    Next
    If Not existe And ruta <> "" Then
    %>
      <option value="<%= H(ruta) %>" selected><%= H(ruta) %> (no existe en SongFiles: se reproduce el audio de respaldo)</option>
    <% End If %>
  </select>
  <p class="hint">Los archivos se leen de <code>SongFilesAndImages_resources/SongFiles</code>. Copia ahí nuevos .mp3 para que aparezcan.</p>

  <div class="grid-2">
    <fieldset>
      <legend>Artistas (TBL_PLAYER)</legend>
      <div class="check-list">
      <%
      Set rs = cn.Execute("SELECT ID_ARTIST, ARTIST_NAME, ARTIST_LASTNAME FROM TBL_ARTIST ORDER BY ARTIST_NAME, ARTIST_LASTNAME")
      Do While Not rs.EOF
      %>
        <label class="check">
          <input type="checkbox" name="artistas" value="<%= rs("ID_ARTIST") %>" <% If EstaSeleccionado(selArtistas, rs("ID_ARTIST")) Then Response.Write "checked" %>>
          <span><%= H(rs("ARTIST_NAME")) %> <%= H(rs("ARTIST_LASTNAME")) %></span>
        </label>
      <%
          rs.MoveNext
      Loop
      rs.Close
      %>
      </div>
    </fieldset>
    <fieldset>
      <legend>Álbumes (TBL_TRACKLIST)</legend>
      <div class="check-list">
      <%
      Set rs = cn.Execute("SELECT ID_ALBUM, TITLE_ALBUM, RELEASE_YEAR FROM TBL_ALBUM ORDER BY TITLE_ALBUM")
      Do While Not rs.EOF
      %>
        <label class="check">
          <input type="checkbox" name="albumes" value="<%= rs("ID_ALBUM") %>" <% If EstaSeleccionado(selAlbumes, rs("ID_ALBUM")) Then Response.Write "checked" %>>
          <span><%= H(rs("TITLE_ALBUM")) %> <small class="muted">(<%= H(rs("RELEASE_YEAR")) %>)</small></span>
        </label>
      <%
          rs.MoveNext
      Loop
      rs.Close
      Set rs = Nothing
      %>
      </div>
    </fieldset>
  </div>

  <div class="form-actions">
    <a href="crud_songs.asp" class="btn btn-ghost">Cancelar</a>
    <button type="submit" class="btn btn-primary"><%= H(textoBoton) %></button>
  </div>
</form>
<%
End Sub
%>
