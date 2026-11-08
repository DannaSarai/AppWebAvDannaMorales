using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BLL.PoliMusicV3
{
    public class Song
    {
        private string strConnectionString;
        public Song(string strConnString)
        {
            strConnectionString = strConnString;
        }
        public int Save(EntityLayer.PoliMusicV3.Song song)
        {
            return new DAL.PoliMusicV3.Song(strConnectionString).Save(song);
        }
        public DataTable Read()
        {
            return new DAL.PoliMusicV3.Song(strConnectionString).Read();
        }
        public DataTable Search(string text)
        {
            if (string.IsNullOrWhiteSpace(text))
            {
                return Read();
            }
            return new DAL.PoliMusicV3.Song(strConnectionString).Search(text.Trim());
        }
        public int Update(EntityLayer.PoliMusicV3.Song song)
        {
            return new DAL.PoliMusicV3.Song(strConnectionString).Update(song);
        }
        public int AddPlay(int idSong)
        {
            return new DAL.PoliMusicV3.Song(strConnectionString).AddPlay(idSong);
        }
        public int Delete(int idSong)
        {
            return new DAL.PoliMusicV3.Song(strConnectionString).Delete(idSong);
        }
    }

}
