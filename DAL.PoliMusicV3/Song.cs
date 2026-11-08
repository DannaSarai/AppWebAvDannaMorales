using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DAL.PoliMusicV3
{
    public class Song
    {
        private string strConnectionString;

        private const string SELECT_SONGS =
            "SELECT S.[ID_SONG], S.[SONG_NAME], S.[SONG_PATH], ISNULL(S.[PLAYS], 0) AS [PLAYS], " +
            "  ISNULL((SELECT STRING_AGG(A.[ARTIST_NAME] + ISNULL(' ' + A.[ARTIST_LASTNAME], ''), ', ') " +
            "          FROM [TBL_PLAYER] P INNER JOIN [TBL_ARTIST] A ON A.[ID_ARTIST] = P.[ID_ARTIST] " +
            "          WHERE P.[ID_SONG] = S.[ID_SONG]), '') AS [ARTISTS], " +
            "  ISNULL((SELECT STRING_AGG(AL.[TITLE_ALBUM], ', ') " +
            "          FROM [TBL_TRACKLIST] T INNER JOIN [TBL_ALBUM] AL ON AL.[ID_ALBUM] = T.[ID_ALBUM] " +
            "          WHERE T.[ID_SONG] = S.[ID_SONG]), '') AS [ALBUMS] " +
            "FROM [TBL_SONG] S ";

        public Song(string strConnString)
        {
            strConnectionString = strConnString;
        }

        public int Save(EntityLayer.PoliMusicV3.Song song)
        {
            using (SqlConnection con = new SqlConnection(strConnectionString))
            {
                using (SqlCommand cmd = new SqlCommand())
                {
                    cmd.CommandText = "INSERT INTO [TBL_SONG]([SONG_NAME], [SONG_PATH], [PLAYS]) VALUES(@SONG_NAME, @SONG_PATH, @PLAYS)";
                    cmd.Parameters.AddWithValue("@SONG_NAME", song.SongName);
                    cmd.Parameters.AddWithValue("@SONG_PATH", song.SongPath);
                    cmd.Parameters.AddWithValue("@PLAYS", song.Plays);
                    cmd.Connection = con;
                    con.Open();
                    return cmd.ExecuteNonQuery();
                }
            }
        }

        public DataTable Read()
        {
            DataTable dtSong = new DataTable();
            using (SqlConnection con = new SqlConnection(strConnectionString))
            {
                using (SqlCommand cmd = new SqlCommand(SELECT_SONGS + "ORDER BY S.[ID_SONG]", con))
                {
                    using (SqlDataAdapter sda = new SqlDataAdapter(cmd))
                    {
                        sda.Fill(dtSong);
                        return dtSong;
                    }
                }
            }
        }

        public DataTable Search(string text)
        {
            DataTable dtSong = new DataTable();
            using (SqlConnection con = new SqlConnection(strConnectionString))
            {
                using (SqlCommand cmd = new SqlCommand("", con))
                {
                    cmd.CommandText = SELECT_SONGS +
                        "WHERE S.[SONG_NAME] LIKE @TEXT " +
                        "   OR EXISTS (SELECT 1 FROM [TBL_PLAYER] P INNER JOIN [TBL_ARTIST] A ON A.[ID_ARTIST] = P.[ID_ARTIST] " +
                        "              WHERE P.[ID_SONG] = S.[ID_SONG] AND (A.[ARTIST_NAME] + ISNULL(' ' + A.[ARTIST_LASTNAME], '')) LIKE @TEXT) " +
                        "   OR EXISTS (SELECT 1 FROM [TBL_TRACKLIST] T INNER JOIN [TBL_ALBUM] AL ON AL.[ID_ALBUM] = T.[ID_ALBUM] " +
                        "              WHERE T.[ID_SONG] = S.[ID_SONG] AND AL.[TITLE_ALBUM] LIKE @TEXT) " +
                        "ORDER BY S.[ID_SONG]";
                    string pattern = text.Replace("[", "[[]").Replace("%", "[%]").Replace("_", "[_]");
                    cmd.Parameters.AddWithValue("@TEXT", "%" + pattern + "%");
                    using (SqlDataAdapter sda = new SqlDataAdapter(cmd))
                    {
                        sda.Fill(dtSong);
                        return dtSong;
                    }
                }
            }
        }

        public int Update(EntityLayer.PoliMusicV3.Song song)
        {
            using (SqlConnection con = new SqlConnection(strConnectionString))
            {
                using (SqlCommand cmd = new SqlCommand())
                {
                    cmd.CommandText = "UPDATE [TBL_SONG] SET [SONG_NAME] = @SONG_NAME, [SONG_PATH] = @SONG_PATH, [PLAYS] = @PLAYS WHERE [ID_SONG] = @ID_SONG";
                    cmd.Parameters.AddWithValue("@ID_SONG", song.ID);
                    cmd.Parameters.AddWithValue("@SONG_NAME", song.SongName);
                    cmd.Parameters.AddWithValue("@SONG_PATH", song.SongPath);
                    cmd.Parameters.AddWithValue("@PLAYS", song.Plays);
                    cmd.Connection = con;
                    con.Open();
                    return cmd.ExecuteNonQuery();
                }
            }
        }

        public int AddPlay(int idSong)
        {
            object returnValue;
            using (SqlConnection con = new SqlConnection(strConnectionString))
            {
                using (SqlCommand cmd = new SqlCommand())
                {
                    cmd.CommandText = "UPDATE [TBL_SONG] SET [PLAYS] = ISNULL([PLAYS], 0) + 1 OUTPUT INSERTED.[PLAYS] WHERE [ID_SONG] = @ID_SONG";
                    cmd.Parameters.AddWithValue("@ID_SONG", idSong);
                    cmd.Connection = con;
                    con.Open();
                    returnValue = cmd.ExecuteScalar();
                    return (returnValue == null) ? -1 : (int)returnValue;
                }
            }
        }

        public int Delete(int idSong)
        {
            using (SqlConnection con = new SqlConnection(strConnectionString))
            {
                con.Open();
                using (SqlTransaction tran = con.BeginTransaction())
                {
                    using (SqlCommand cmd = new SqlCommand("", con, tran))
                    {
                        cmd.CommandText =
                            "DELETE [TBL_PLAYER] WHERE [ID_SONG] = @ID_SONG; " +
                            "DELETE [TBL_TRACKLIST] WHERE [ID_SONG] = @ID_SONG; " +
                            "DELETE [TBL_PLAYLIST_SONG] WHERE [ID_SONG] = @ID_SONG; " +
                            "DELETE [TBL_SONG] WHERE [ID_SONG] = @ID_SONG;";
                        cmd.Parameters.AddWithValue("@ID_SONG", idSong);
                        int rows = cmd.ExecuteNonQuery();
                        tran.Commit();
                        return rows;
                    }
                }
            }
        }
    }

}
