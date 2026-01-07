using AutoMapper;
using eFood.Model.Requests;
using eFood.Model.SearchObjects;
using eFood.Services;
using Microsoft.AspNetCore.Mvc;

namespace eFood.API.Controllers
{
    [Route("[controller]")]
    // [AllowAnonymous]
    public class JeloController : BaseCRUDController<Model.Jelo, JeloSearchObject, JeloUpsertRequest, JeloUpsertRequest>
    {
      

        private readonly IMapper _mapper;
        public JeloController(ILogger<BaseController<Model.Jelo, JeloSearchObject>> logger, IJeloService service, IMapper mapper) : base(logger, service)
        {
            _mapper = mapper;
        }
    


        [HttpGet("preporuceno")]
        public List<Model.Jelo> GetPreporucenaJela(int korisnikId)
        {
            return (_service as IJeloService).GetPreporucenaJela(korisnikId);
        }
    }
}
