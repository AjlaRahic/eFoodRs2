using System;
using System.Collections.Generic;
using System.Text;

namespace eFood.Model.Requests
{
    public class LokacijaSignalRequest
    {
        public int DostavljacId { get; set; }
        public double Latitude { get; set; }
        public double Longitude { get; set; }
        public DateTime Datum { get; set; }

        // Samo za SignalR update, ne ide u bazu
        public int? NarudzbaId { get; set; }
    }
}
