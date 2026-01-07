using eFood.Model;
using eFood.Model.Requests;
using eFood.Model.SearchObjects;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eFood.Services
{
    public interface ILokacijaService:ICRUDService<Model.Lokacija,LokacijaSearchObject,LokacijaInsertRequest,LokacijaUpdateRequest>
    {
        Task<bool> InsertAsync(LokacijaInsertRequest request);
        Task<Lokacija?> GetZadnjaLokacijaPoDostavljacuAsync(int dostavljacId);
        Task<List<Model.Lokacija>> GetSveLokacijePoNarudzbiAsync(int narudzbaId);
        Task<Narudzba> GetNarudzbaPoIdAsync(int id);
        Task<Lokacija> GetZadnjaLokacijaPoKorisnikuAsync(int korisnikId);

    }
}
