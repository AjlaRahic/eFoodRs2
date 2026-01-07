using eFood.Model;
using eFood.Model.Requests;
using eFood.Model.SearchObjects;
using eFood.Services;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace eFood.API.Controllers
{
    [Route("[controller]")]

    public class LokacijaController : BaseCRUDController<Model.Lokacija, LokacijaSearchObject, LokacijaInsertRequest, LokacijaUpdateRequest>
    {
        private readonly ILokacijaService _lokacijaService;

        public LokacijaController(
            ILogger<BaseCRUDController<Model.Lokacija, LokacijaSearchObject, LokacijaInsertRequest, LokacijaUpdateRequest>> logger,
            ILokacijaService service
        ) : base(logger, service)
        {
            _lokacijaService = service;
        }


        [HttpPost("insert")]
        public async Task<IActionResult> InsertLokacija([FromBody] LokacijaInsertRequest request)
        {
            var success = await _lokacijaService.InsertAsync(request);
            if (!success)
                return BadRequest("Nema aktivne narudžbe ili narudžba nije 'U toku'. Lokacija nije snimljena.");

            return Ok("Lokacija snimljena.");
        }

        
        [HttpGet("zadnja/{dostavljacId}")]
        public async Task<IActionResult> GetZadnjaLokacija(int dostavljacId)
        {
            var lokacija = await _lokacijaService.GetZadnjaLokacijaPoDostavljacuAsync(dostavljacId);
            if (lokacija == null)
                return NotFound("Dostavljač nema lokacija.");

            return Ok(lokacija);
        }
        [HttpGet("narudzba/{id}/lokacijaKorisnika")]
        public async Task<IActionResult> GetLokacijaKorisnika(int id)
        {
            
            var narudzba = await _lokacijaService.GetNarudzbaPoIdAsync(id); 

            if (narudzba == null)
                return NotFound("Narudžba ne postoji.");

            
            var lokacija = await _lokacijaService.GetZadnjaLokacijaPoKorisnikuAsync(narudzba.KorisnikId);

            if (lokacija == null)
                return NotFound("Lokacija korisnika nije pronađena.");

           
            return Ok(new
            {
                latitude = lokacija.Latitude,
                longitude = lokacija.Longitude
            });


         
        }
    }
}
