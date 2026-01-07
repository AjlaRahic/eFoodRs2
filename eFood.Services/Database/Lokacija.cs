using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eFood.Services.Database
{
    public partial class Lokacija
    {
        public int LokacijaId { get; set; }      // Primarni ključ

        public int KorisnikId { get; set; }    // FK → Korisnik (uloga: Dostavljač)

        public double Latitude { get; set; }     // Geografska širina
        public double Longitude { get; set; }    // Geografska dužina

        public DateTime Vrijeme { get; set; }
        public virtual Korisnici Korisnik { get; set; }
    }
}
