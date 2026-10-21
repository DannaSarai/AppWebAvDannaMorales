<%
' ============================================================
'  canciones.asp - Consultas compartidas de canciones
'  Artistas vía TBL_PLAYER/TBL_ARTIST, álbumes vía TBL_TRACKLIST/TBL_ALBUM
' ============================================================

Function SqlCanciones(filtro)
    SqlCanciones = _
        "SELECT s.ID_SONG, s.SONG_NAME, s.SONG_PATH, ISNULL(s.PLAYS, 0) AS PLAYS, " & _
        "  ISNULL((SELECT STRING_AGG(a.ARTIST_NAME + ISNULL(' ' + a.ARTIST_LASTNAME, ''), ', ') " & _
        "          FROM TBL_PLAYER p JOIN TBL_ARTIST a ON a.ID_ARTIST = p.ID_ARTIST " & _
        "          WHERE p.ID_SONG = s.ID_SONG), '') AS ARTISTS, " & _
        "  ISNULL((SELECT STRING_AGG(al.TITLE_ALBUM, ', ') " & _
        "          FROM TBL_TRACKLIST t JOIN TBL_ALBUM al ON al.ID_ALBUM = t.ID_ALBUM " & _
        "          WHERE t.ID_SONG = s.ID_SONG), '') AS ALBUMS " & _
        "FROM TBL_SONG s " & filtro & " ORDER BY s.ID_SONG"
End Function

' Filtro de búsqueda por nombre de canción, artista o álbum (1 parámetro repetido 3 veces)
Function FiltroBusqueda()
    FiltroBusqueda = _
        "WHERE s.SONG_NAME LIKE ? " & _
        "   OR EXISTS (SELECT 1 FROM TBL_PLAYER p JOIN TBL_ARTIST a ON a.ID_ARTIST = p.ID_ARTIST " & _
        "              WHERE p.ID_SONG = s.ID_SONG AND (a.ARTIST_NAME + ISNULL(' ' + a.ARTIST_LASTNAME, '')) LIKE ?) " & _
        "   OR EXISTS (SELECT 1 FROM TBL_TRACKLIST t JOIN TBL_ALBUM al ON al.ID_ALBUM = t.ID_ALBUM " & _
        "              WHERE t.ID_SONG = s.ID_SONG AND al.TITLE_ALBUM LIKE ?)"
End Function

' Escapa comodines de LIKE para buscar el texto literal
Function PatronLike(texto)
    Dim t
    t = Replace(texto, "[", "[[]")
    t = Replace(t, "%", "[%]")
    t = Replace(t, "_", "[_]")
    PatronLike = "%" & t & "%"
End Function

Function ObtenerIdQuery(nombre)
    ObtenerIdQuery = 0
    If EsEntero(Request(nombre)) Then ObtenerIdQuery = CLng(Request(nombre))
End Function
%>
