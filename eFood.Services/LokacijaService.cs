using AutoMapper;
using eFood.Model;
using eFood.Model.Requests;
using eFood.Model.SearchObjects;
using eFood.Services.Database;
using Microsoft.EntityFrameworkCore;
using Microsoft.ML;
using Org.BouncyCastle.Asn1.Ocsp;
using System.Linq;
using System.Threading.Tasks;

namespace eFood.Services
{
    public class LokacijaService : BaseCRUDService<Model.Lokacija, Database.Lokacija, LokacijaSearchObject, LokacijaInsertRequest, LokacijaUpdateRequest>, ILokacijaService
    {
        public LokacijaService(EFoodContext context, IMapper mapper) : base(context, mapper) { }

        public override IQueryable<Database.Lokacija> AddInclude(IQueryable<Database.Lokacija> query, LokacijaSearchObject? search = null)
        {
            return query.Include(x => x.Korisnik);
        }


        public async Task<bool> InsertAsync(LokacijaInsertRequest request)
        {
            
            var narudzba = await _context.Narudzbas
                .FirstOrDefaultAsync(x => x.DostavljacId == request.DostavljacId
                                       && x.StatusNarudzbeId == 6);

            if (narudzba == null)
                return false; 

            var lokacija = new Database.Lokacija
            {
                KorisnikId = request.DostavljacId,
                Latitude = request.Latitude,
                Longitude = request.Longitude,
                Vrijeme = DateTime.Now
            };

            _context.Lokacijas.Add(lokacija);
            await _context.SaveChangesAsync();

            return true; 
        }


        public async Task<Model.Lokacija?> GetZadnjaLokacijaPoDostavljacuAsync(int dostavljacId)
        {
            var entity = await _context.Lokacijas
                .Where(x => x.KorisnikId == dostavljacId)
                .OrderByDescending(x => x.Vrijeme)
                .FirstOrDefaultAsync();

            return entity == null ? null : _mapper.Map<Model.Lokacija>(entity);
        }

        public async Task<List<Model.Lokacija>> GetSveLokacijePoNarudzbiAsync(int narudzbaId)
        {
            
            var narudzba = await _context.Narudzbas.FindAsync(narudzbaId);
            if (narudzba == null) return new List<Model.Lokacija>();

            var lokacije = await _context.Lokacijas
                .Where(x => x.KorisnikId == narudzba.DostavljacId)
                .OrderBy(x => x.Vrijeme)
                .ToListAsync();

            return _mapper.Map<List<Model.Lokacija>>(lokacije);
        }
        public async Task<Model.Narudzba> GetNarudzbaPoIdAsync(int id)
        {
            
            var nar = await _context.Narudzbas
                .Include(n => n.Korisnik) 
                .FirstOrDefaultAsync(n => n.Id == id);

            if (nar == null)
                throw new Exception("Narudzba nije pronađena");

            return _mapper.Map<Model.Narudzba>(nar);
        }

        public async Task<Model.Lokacija> GetZadnjaLokacijaPoKorisnikuAsync(int korisnikId)
        {
            var lokacija = await _context.Lokacijas
                .Where(l => l.KorisnikId == korisnikId)
                .OrderByDescending(l => l.Vrijeme)
                .FirstOrDefaultAsync();

            if (lokacija == null)
                throw new Exception("Lokacija korisnika nije pronađena");

           
            return new Model.Lokacija
            {
                LokacijaId = lokacija.LokacijaId,
                KorisnikId = lokacija.KorisnikId,
                Latitude = lokacija.Latitude,
                Longitude = lokacija.Longitude,
                Vrijeme = lokacija.Vrijeme

            };
        }
        
    }
    }
