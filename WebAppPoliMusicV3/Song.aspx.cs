using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace WebAppPoliMusicV3
{
    public partial class Song : System.Web.UI.Page
    {
        string strConnString = ConfigurationManager.ConnectionStrings["BDD_PoliMusicConnectionString"].ConnectionString;
        const string DEFAULT_SONG = "~/SongFiles/bensound-adventure.mp3";
        const string DEFAULT_PHOTO = "~/UserImages/default.jpg";

        protected void Page_Load(object sender, EventArgs e)
        {
            EntityLayer.PoliMusicV3.User user = Session[EntityLayer.PoliMusicV3.Util.Constants.USER] as EntityLayer.PoliMusicV3.User;

            if (Request.HttpMethod == "POST" && Request.Form["action"] == "play")
            {
                RegisterPlay(user);
                return;
            }

            if (user == null)
            {
                FormsAuthentication.SignOut();
                Response.Redirect("~/Login", true);
                return;
            }

            if (!Page.IsPostBack)
            {
                ShowUser(user);
                BindSongs(string.Empty);
            }
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            BindSongs(txtSearch.Text);
        }

        protected void btnClear_Click(object sender, EventArgs e)
        {
            txtSearch.Text = string.Empty;
            BindSongs(string.Empty);
        }

        protected void gvSongs_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            if (e.Row.RowType == DataControlRowType.DataRow)
            {
                e.Row.Cells[2].Attributes["data-label"] = "Artista";
                e.Row.Cells[3].Attributes["data-label"] = "Álbum";
                e.Row.Cells[4].Attributes["data-label"] = "Reproducciones";
                if (string.IsNullOrEmpty(e.Row.Cells[2].Text) || e.Row.Cells[2].Text == "&nbsp;")
                {
                    e.Row.Cells[2].Text = "Artista desconocido";
                }
                if (string.IsNullOrEmpty(e.Row.Cells[3].Text) || e.Row.Cells[3].Text == "&nbsp;")
                {
                    e.Row.Cells[3].Text = "Sin álbum";
                }
            }
        }

        private void ShowUser(EntityLayer.PoliMusicV3.User user)
        {
            litWelcomeName.Text = Server.HtmlEncode(user.UserName);
            litUserName.Text = Server.HtmlEncode(user.UserName);
            litEmail.Text = Server.HtmlEncode(user.Email);
            imgUser.ImageUrl = ExistingFileOrDefault(user.Photo, DEFAULT_PHOTO);
            imgUser.AlternateText = "Foto de " + user.UserName;
            if (user.UserType == EntityLayer.PoliMusicV3.Util.Constants.ID_USER_ADMIN)
            {
                litRole.Text = "<span class=\"pm-role admin\">ADMIN</span>";
            }
            else
            {
                litRole.Text = "<span class=\"pm-role\">USER</span>";
            }
        }

        private void BindSongs(string search)
        {
            DataTable dtSongs = new BLL.PoliMusicV3.Song(strConnString).Search(search);
            gvSongs.DataSource = dtSongs;
            gvSongs.DataBind();
            if (gvSongs.HeaderRow != null)
            {
                gvSongs.HeaderRow.TableSection = TableRowSection.TableHeader;
            }

            int totalPlays = 0;
            foreach (DataRow row in dtSongs.Rows)
            {
                totalPlays += Convert.ToInt32(row["PLAYS"]);
            }
            litTotalSongs.Text = dtSongs.Rows.Count.ToString();
            litTotalPlays.Text = totalPlays.ToString();

            if (!string.IsNullOrWhiteSpace(search))
            {
                litResult.Text = dtSongs.Rows.Count + " resultado(s) para &ldquo;" + Server.HtmlEncode(search.Trim()) + "&rdquo;";
            }
            else
            {
                litResult.Text = "Pulsa &#9654; en cualquier canción para escucharla.";
            }
        }

        private void RegisterPlay(EntityLayer.PoliMusicV3.User user)
        {
            Response.Clear();
            Response.ContentType = "application/json";
            int idSong;
            if (user == null)
            {
                Response.StatusCode = 401;
                Response.Write("{\"ok\":false}");
            }
            else if (!int.TryParse(Request.Form["id"], out idSong))
            {
                Response.StatusCode = 400;
                Response.Write("{\"ok\":false}");
            }
            else
            {
                int plays = new BLL.PoliMusicV3.Song(strConnString).AddPlay(idSong);
                if (plays < 0)
                {
                    Response.StatusCode = 404;
                    Response.Write("{\"ok\":false}");
                }
                else
                {
                    Response.Write("{\"ok\":true,\"plays\":" + plays + "}");
                }
            }
            Response.End();
        }

        private string ExistingFileOrDefault(string virtualPath, string defaultPath)
        {
            try
            {
                if (!string.IsNullOrEmpty(virtualPath) && virtualPath.StartsWith("~/") && File.Exists(Server.MapPath(virtualPath)))
                {
                    return ResolveUrl(virtualPath);
                }
            }
            catch (HttpException)
            {

            }
            return ResolveUrl(defaultPath);
        }

        protected string SongUrl(object songPath)
        {
            return ExistingFileOrDefault(Convert.ToString(songPath), DEFAULT_SONG);
        }

        protected string CoverUrl(object idSong)
        {
            int id = Convert.ToInt32(idSong);
            return ResolveUrl("~/PlaylistImages/playlist" + (((id - 1) % 5 + 5) % 5 + 1) + ".png");
        }
    }
}
