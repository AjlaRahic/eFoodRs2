using eFood.Model;
using eFood.Services.Reports;
using eFood.Services.Reports;
using iText.IO.Font.Constants;
using iText.Kernel.Font;
using iText.Kernel.Pdf;
using iText.Layout;
using iText.Layout.Element;
using Microsoft.AspNetCore.Mvc;
using System.Collections.Generic;
using System.Reflection.Metadata;
using System.Threading.Tasks;
namespace eRestoran.Controllers
{
    [Route("[controller]")]
    public class ReportController : ControllerBase
    {
        private readonly IReportService reportService;
        public ReportController(IReportService _reportService)
        {
            reportService = _reportService;
        }

        [HttpGet("reportUplatePoKorisniku")]
        public ActionResult<UplatePoKorisniku> ReportUplatePoKorisniku()
        {
            var izvjestaj = reportService.ReportUplatePoKorisniku();
            return Ok(izvjestaj);
        }

        [HttpGet("reportPrometPoKorisniku")]
        public ActionResult<List<PrometPoKorisniku>> GetPrometPoKorisniku()
        {
            try
            {
                var promet = reportService.ReportPrometPoKorisniku();
                return Ok(promet);
            }
            catch (Exception ex)
            {
                return StatusCode(500, $"Greška na serveru: {ex.Message}");
            }
        }

        [HttpGet("print-promet")]
        public async Task<IActionResult> PrintIzvjestajOPrometu()
        {
            var promet = await Task.Run(() => reportService.ReportPrometPoKorisniku());

            using (var stream = new MemoryStream())
            {
                var writer = new iText.Kernel.Pdf.PdfWriter(stream);
                var pdf = new iText.Kernel.Pdf.PdfDocument(writer);
                var document = new iText.Layout.Document(pdf);
                PdfFont boldFont = PdfFontFactory.CreateFont(StandardFonts.HELVETICA_BOLD);
                var naslov = new iText.Layout.Element.Paragraph("Izvještaj o prometu po korisnicima")
                    .SetTextAlignment(iText.Layout.Properties.TextAlignment.CENTER)
                    .SetFontSize(18)
                    .SetFont(boldFont);
                document.Add(naslov);

                document.Add(new iText.Layout.Element.Paragraph("\n"));
                foreach (var item in promet)
                {
                    document.Add(new iText.Layout.Element.Paragraph(
                        $"{item.ImeKorisnika} - {item.DatumNarudzbe} - {item.NazivKategorije ?? "Bez kategorije"}"
                    ));
                }

                document.Close();

                return File(stream.ToArray(), "application/pdf", "IzvjestajPrometPoKorisnicima.pdf");
            }
        }
       

    }
}
