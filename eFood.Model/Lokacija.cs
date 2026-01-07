using System;
using System.Collections.Generic;
using System.Text;

namespace eFood.Model
{
    public class Lokacija
    {
        public int LokacijaId { get; set; }      

        public int KorisnikId { get; set; }    

        public double Latitude { get; set; }     
        public double Longitude { get; set; }    
        public DateTime Vrijeme { get; set; }
        public virtual Korisnik Korisnik { get; set; }

    }
}
