using eFood.Model;
using eFood.Model.Requests;
using eFood.Model.SearchObjects;
using eFood.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Text;
using eFood.Services.RabbitMQ;


namespace eFood.API.Controllers
{
    [Route("[controller]")]
    public class NarudzbaController : BaseCRUDController<Model.Narudzba, NarudzbaSearchObject, NarudzbaInsertRequest, NarudzbaUpdateRequest>
    {
        protected readonly INarudzbaService _service;
        private readonly IMailProducer _mailProducer;
        public NarudzbaController(IMailProducer mailProducer, ILogger<BaseController<Model.Narudzba, NarudzbaSearchObject>> logger, INarudzbaService service)
         : base(logger, service)
        {
            _service = service ?? throw new ArgumentNullException(nameof(service));
            _mailProducer = mailProducer;
        }

        public class EmailModel
        {
            public string Sender { get; set; }
            public string Recipient { get; set; }
            public string Subject { get; set; }
            public string Content { get; set; }
        }



        [HttpPost("checkout")]
        public async Task<ActionResult<int>> Checkout([FromBody] NarudzbaCheckoutRequest request)
        {
            var narudzba = await _service.Checkout(request);
            return Ok(narudzba.Id);

        }

        [HttpPost("checkoutFromCart")]
        
        public async Task<ActionResult<int>> CheckoutFromCart([FromBody] CheckoutFromCartRequest req)
        {
            if (req == null || req.KorisnikId <= 0)
                return BadRequest("Neispravan zahtjev.");

            var id = await _service.CheckoutFromCart(req.KorisnikId, req.StatusId, req.PaymentId, req.DatumNarudzbe);
            return Ok(id);
        }



        [HttpPut("{id}/activate")]
        public virtual async Task<Narudzba> Activate(int id)
        {
            return await _service.Activate(id);
        }

        [HttpPut("{id}/hide")]
        public virtual async Task<Narudzba> Hide(int id)
        {
            return await _service.Hide(id);
        }

        [HttpGet("{id}/allowedActions")]
        public virtual async Task<List<string>> AllowedActions(int id)
        {
            return await _service.AllowedActions(id);
        }
        [HttpPut("DodijeliDostavljaca")]
        public async Task<IActionResult> DodijeliDostavljaca(
    [FromBody] NarudzbaDostavljacInsertRequest request)
        {
            await _service.DodijeliDostavljaca(request);
            return Ok();
        }

        [HttpGet("dostavljac/{dostavljacId}")]
        public async Task<ActionResult<List<Narudzba>>> GetNarudzbeZaDostavljaca(int dostavljacId)
        {
            var result = await _service.GetNarudzbeZaDostavljacaAsync(dostavljacId);
            return Ok(result);
        }
        [HttpPost("{id}/zavrsi")]
        public async Task<IActionResult> ZavrsiNarudzbu(int id)
        {
            await _service.ZavrsiNarudzbu(id);
            return Ok();
        }
    }
}
