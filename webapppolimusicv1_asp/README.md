# PoliMusic · ASP Clásico + SQL Server

Sitio de canciones en **ASP Clásico (VBScript)** conectado a `BDD_PoliMusic` (SQL Server 2025, `localhost`) con `ADODB.Connection`.

## Estructura

| Archivo | Función |
|---|---|
| `includes/conexion.asp` | Conexión ADODB reutilizable (`AbrirConexion`), comandos parametrizados, rutas de recursos |
| `includes/seguridad.asp` | `RequerirLogin`, `RequerirAdmin` (rol validado en el servidor), token CSRF |
| `includes/layout.asp` | Cabecera/navegación y pie comunes |
| `includes/canciones.asp` | Consulta de canciones (artista vía TBL_PLAYER/TBL_ARTIST, álbum vía TBL_TRACKLIST/TBL_ALBUM) y búsqueda |
| `includes/form_cancion.asp` | Formulario compartido de crear/editar y guardado de relaciones |
| `login.asp` / `logout.asp` | Inicio de sesión contra TBL_USER (guarda `username` y `rol`) / destruye la sesión |
| `songs.asp` | Página principal: bienvenida, "Song List", playlists y reproductor |
| `play.asp` | Endpoint POST que incrementa `PLAYS` al reproducir |
| `crud_songs.asp` | **Leer + Buscar** (por canción, artista o álbum) — solo admin |
| `song_view.asp` | **Leer** detalle — solo admin |
| `song_new.asp` | **Crear** — solo admin |
| `song_edit.asp` | **Actualizar** — solo admin |
| `song_delete.asp` | **Eliminar** (con confirmación) — solo admin |

## Ejecutar en IIS (localhost)

1. **Base de datos**: ejecuta `BDD_PoliMusic.sql` en SSMS (crea el login `usr_polimusic` / `Politecnica1`). SQL Server debe aceptar autenticación SQL (modo mixto).
2. **Activar ASP en IIS**: *Activar o desactivar las características de Windows* → Internet Information Services → Servicios World Wide Web → Características de desarrollo de aplicaciones → **ASP**.
3. **Crear la aplicación** (IIS Manager): *Default Web Site* → clic derecho → **Agregar aplicación** → Alias `polimusic`, Ruta física = esta carpeta (`webapppolimusicv1_asp`).
   O desde una consola **como administrador**:
   ```
   %windir%\system32\inetsrv\appcmd add app /site.name:"Default Web Site" /path:/polimusic /physicalPath:"C:\Users\danna\Documents\Octavo Semestre\WebAvanzadas\source\repos\AppWebAvDannaMorales\webapppolimusicv1_asp"
   ```
4. **Permisos de lectura**: como la carpeta está dentro de *Documentos*, dale lectura a IIS (consola como administrador):
   ```
   icacls "C:\Users\danna\Documents\Octavo Semestre\WebAvanzadas\source\repos\AppWebAvDannaMorales\webapppolimusicv1_asp" /grant "IIS_IUSRS:(OI)(CI)RX" "IUSR:(OI)(CI)RX"
   ```
5. Abre **http://localhost/polimusic/** (redirige a `login.asp`).

Proveedor usado: `MSOLEDBSQL19` (instalado). Si en otra máquina no existe, cambia `Provider=` en `includes/conexion.asp` por `MSOLEDBSQL` o `SQLOLEDB`.

Para ver errores ASP detallados al depurar: IIS Manager → ASP → Propiedades de depuración → *Enviar errores al explorador* = True.

## Pruebas

| Usuario | Contraseña | Puede |
|---|---|---|
| `userNormal` | `12345678` | Ver el listado y reproducir (las páginas CRUD redirigen con "Acceso denegado") |
| `Danna.Morales` | `12345678` | Rol normal (USER_TYPE = 0), igual que userNormal |
| `userAdmin` | `12345678` | Todo lo anterior + Gestionar canciones (crear, ver, editar, eliminar, buscar) |

Solo existe `bensound-adventure.mp3` en `SongFiles`; las canciones cuyo archivo no existe se reproducen con ese audio de respaldo. Para usar más audios, copia los `.mp3` a `SongFilesAndImages_resources/SongFiles` y aparecerán en el formulario.
