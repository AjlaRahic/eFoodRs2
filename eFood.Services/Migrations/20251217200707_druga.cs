using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace eFood.Services.Migrations
{
    public partial class druga : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.InsertData(
                table: "Drzava",
                columns: new[] { "Id", "Naziv" },
                values: new object[,]
                {
                    { 2000, "Bosna i Hercegovina" },
                    { 2001, "Italija" }
                });

            migrationBuilder.InsertData(
                table: "Kategorija",
                columns: new[] { "KategorijaId", "Naziv", "Opis" },
                values: new object[,]
                {
                    { 4000, "Pizza", "top" },
                    { 4001, "Rostilj", "top" },
                    { 4002, "Pasta", "top" },
                    { 4003, "Desert", "top" }
                });

            migrationBuilder.InsertData(
                table: "Korisnici",
                columns: new[] { "Id", "DrzavaId", "Email", "GradId", "Ime", "KorisnickoIme", "LozinkaHash", "LozinkaSalt", "Prezime", "Telefon" },
                values: new object[,]
                {
                    { 1001, null, "ajlarahic@gmail.com", null, "Ajla", "admin", "6CkDF/EMSFa8sAJDqKSRZ1lEiS4=", "dqM5G7yR5b2rmX3pO8OgwQ==", "Rahic", "066455778" },
                    { 1002, null, "lejlaboskailo@gmail.com", null, "Lejla", "mobile", "hPApkP6EzuQ2I8khWSd6elwOaTQ=", "pmPAq6AxdTXKK/aKmjawyQ==", "Boskailo", "066455778" },
                    { 1007, null, "medisa@gmail.com", null, "Medisa", "korisnik", "bpTEXMau5N87xfCYHPYr7OTSwwo=", "vN/ZVgjvfGBZn8n+5WYTpg==", "Šatara", "066455778" },
                    { 1111, null, "šejma@gmail.com", null, "Šejma", "dostavljac", "em5L1tPRQRmza3d6uVE1Td4tNUo=", "TBcJlE90FV8FTC5IXaQHwA==", "Tinjak", "066455778" }
                });

            migrationBuilder.InsertData(
                table: "Prilozi",
                columns: new[] { "PrilogId", "NazivPriloga" },
                values: new object[,]
                {
                    { 4878, "Senf" },
                    { 4898, "Majoneza" }
                });

            migrationBuilder.InsertData(
                table: "Status",
                columns: new[] { "Id", "Naziv" },
                values: new object[] { 8010, "poslano" });

            migrationBuilder.InsertData(
                table: "Uloge",
                columns: new[] { "Id", "Naziv", "Opis" },
                values: new object[,]
                {
                    { 1, "Admin", "Upravljanje sistemom" },
                    { 2, "Korisnik", "Pregled podataka" },
                    { 3, "Dostavljac", "Dostava narudzbe" }
                });

            migrationBuilder.InsertData(
                table: "Grad",
                columns: new[] { "Id", "DrzavaId", "Naziv" },
                values: new object[,]
                {
                    { 3000, 2000, "Sarajevo" },
                    { 3010, 2000, "Mostar" }
                });

            migrationBuilder.InsertData(
                table: "Jelo",
                columns: new[] { "JeloId", "Cijena", "KategorijaId", "Naziv", "Opis", "Slika", "StateMachine" },
                values: new object[,]
                {
                    { 5000, 15m, 4000, "Margarita", "top", null, "active" },
                    { 5001, 15m, 4000, "Funghi", "top", null, "active" },
                    { 5002, 15m, 4003, "Cheesecake", "top", null, "active" },
                    { 5004, 15m, 4001, "Cevapi", "top", null, "cancelled" },
                    { 5005, 15m, 4002, "Makaroni", "top", null, "active" }
                });

            migrationBuilder.InsertData(
                table: "KorisniciUloge",
                columns: new[] { "KorisnikUlogaId", "DatumIzmjene", "KorisnikId", "UlogaId" },
                values: new object[,]
                {
                    { 1, new DateTime(2025, 12, 17, 16, 0, 0, 0, DateTimeKind.Unspecified), 1001, 1 },
                    { 2, new DateTime(2025, 12, 17, 17, 0, 0, 0, DateTimeKind.Unspecified), 1002, 2 },
                    { 5, new DateTime(2025, 12, 17, 16, 0, 0, 0, DateTimeKind.Unspecified), 1111, 3 }
                });

            migrationBuilder.InsertData(
                table: "Lokacija",
                columns: new[] { "LokacijaId", "KorisniciId", "KorisnikId", "Latitude", "Longitude", "Vrijeme" },
                values: new object[,]
                {
                    { 6000, null, 1001, 43.856299999999997, 18.4131, new DateTime(2025, 12, 16, 16, 0, 0, 0, DateTimeKind.Unspecified) },
                    { 6001, null, 1002, 44.817599999999999, 20.456900000000001, new DateTime(2025, 12, 16, 16, 0, 0, 0, DateTimeKind.Unspecified) },
                    { 6002, null, 1001, 43.348599999999998, 17.8123, new DateTime(2025, 12, 17, 16, 0, 0, 0, DateTimeKind.Unspecified) }
                });

            migrationBuilder.InsertData(
                table: "Narudzba",
                columns: new[] { "Id", "DatumNarudzbe", "KorisnikId", "PaymentId", "StateMachine", "StatusNarudzbeId" },
                values: new object[] { 6000, new DateTime(2025, 12, 14, 16, 0, 0, 0, DateTimeKind.Unspecified), 1001, null, "poslano", 8010 });

            migrationBuilder.InsertData(
                table: "Dojmovi",
                columns: new[] { "Id", "JeloId", "KorisnikId", "Ocjena", "Opis" },
                values: new object[,]
                {
                    { 8000, 5000, 1002, 5, "odlicna dostava" },
                    { 8001, 5000, 1002, 2, "odlicna dostava" },
                    { 8002, 5000, 1002, 2, "odlicna dostava" },
                    { 8003, 5000, 1002, 5, "odlicna dostava" },
                    { 8004, 5000, 1002, 3, "dostava ok" },
                    { 8005, 5000, 1002, 3, "dostava ok" },
                    { 8006, 5000, 1002, 2, "odlicna dostava" },
                    { 9007, 5000, 1001, 2, "odlicna dostava" },
                    { 9008, 5000, 1001, 2, "odlicna dostava" },
                    { 9009, 5000, 1001, 2, "odlicna dostava" },
                    { 9019, 5000, 1001, 3, "dostava" },
                    { 9100, 5000, 1001, 2, "odlicna dostava" },
                    { 9101, 5000, 1007, 5, "odlicna dostava" },
                    { 9102, 5000, 1007, 5, "odlicna dostava" },
                    { 9103, 5000, 1007, 2, "odlicna dostava" },
                    { 9106, 5001, 1001, 5, "odlicna dostava" },
                    { 9107, 5002, 1001, 2, "odlicna dostava" },
                    { 9108, 5004, 1002, 2, "odlicna dostava" },
                    { 9109, 5002, 1001, 4, "odlicna dostava" },
                    { 9110, 5002, 1002, 3, "odlicna dostava" },
                    { 9111, 5004, 1001, 2, "odlicna dostava" },
                    { 9112, 5005, 1001, 2, "odlicna dostava" },
                    { 9113, 5005, 1001, 3, "odlicna dostava" },
                    { 9114, 5005, 1002, 4, "odlicna dostava" },
                    { 9115, 5005, 1002, 2, "odlicna dostava" },
                    { 9116, 5005, 1007, 2, "odlicna dostava" },
                    { 9140, 5001, 1007, 5, "odlicna dostava" },
                    { 9150, 5001, 1007, 2, "odlicna dostava" },
                    { 9156, 5001, 1002, 2, "odlicna dostava" }
                });

            migrationBuilder.InsertData(
                table: "Korpa",
                columns: new[] { "KorpaId", "Cijena", "JeloId", "KategorijaId", "Kolicina", "KorisnikId", "PrilogId", "PriloziPrilogId" },
                values: new object[] { 7898, 30.00m, 5000, 4000, 2, 1002, 4898, null });

            migrationBuilder.InsertData(
                table: "Restorans",
                columns: new[] { "RestoranId", "Adresa", "Email", "GradId", "NazivRestorana", "Telefon" },
                values: new object[] { 3111, "Mostar", "restoran@gmail.com", 3010, "eHrana", "066111111" });

            migrationBuilder.InsertData(
                table: "StavkeNarudzbe",
                columns: new[] { "Id", "Cijena", "JeloId", "Kolicina", "NarudzbaId" },
                values: new object[] { 7000, 30, 5000, 2, 6000 });
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DeleteData(
                table: "Dojmovi",
                keyColumn: "Id",
                keyValue: 8000);

            migrationBuilder.DeleteData(
                table: "Dojmovi",
                keyColumn: "Id",
                keyValue: 8001);

            migrationBuilder.DeleteData(
                table: "Dojmovi",
                keyColumn: "Id",
                keyValue: 8002);

            migrationBuilder.DeleteData(
                table: "Dojmovi",
                keyColumn: "Id",
                keyValue: 8003);

            migrationBuilder.DeleteData(
                table: "Dojmovi",
                keyColumn: "Id",
                keyValue: 8004);

            migrationBuilder.DeleteData(
                table: "Dojmovi",
                keyColumn: "Id",
                keyValue: 8005);

            migrationBuilder.DeleteData(
                table: "Dojmovi",
                keyColumn: "Id",
                keyValue: 8006);

            migrationBuilder.DeleteData(
                table: "Dojmovi",
                keyColumn: "Id",
                keyValue: 9007);

            migrationBuilder.DeleteData(
                table: "Dojmovi",
                keyColumn: "Id",
                keyValue: 9008);

            migrationBuilder.DeleteData(
                table: "Dojmovi",
                keyColumn: "Id",
                keyValue: 9009);

            migrationBuilder.DeleteData(
                table: "Dojmovi",
                keyColumn: "Id",
                keyValue: 9019);

            migrationBuilder.DeleteData(
                table: "Dojmovi",
                keyColumn: "Id",
                keyValue: 9100);

            migrationBuilder.DeleteData(
                table: "Dojmovi",
                keyColumn: "Id",
                keyValue: 9101);

            migrationBuilder.DeleteData(
                table: "Dojmovi",
                keyColumn: "Id",
                keyValue: 9102);

            migrationBuilder.DeleteData(
                table: "Dojmovi",
                keyColumn: "Id",
                keyValue: 9103);

            migrationBuilder.DeleteData(
                table: "Dojmovi",
                keyColumn: "Id",
                keyValue: 9106);

            migrationBuilder.DeleteData(
                table: "Dojmovi",
                keyColumn: "Id",
                keyValue: 9107);

            migrationBuilder.DeleteData(
                table: "Dojmovi",
                keyColumn: "Id",
                keyValue: 9108);

            migrationBuilder.DeleteData(
                table: "Dojmovi",
                keyColumn: "Id",
                keyValue: 9109);

            migrationBuilder.DeleteData(
                table: "Dojmovi",
                keyColumn: "Id",
                keyValue: 9110);

            migrationBuilder.DeleteData(
                table: "Dojmovi",
                keyColumn: "Id",
                keyValue: 9111);

            migrationBuilder.DeleteData(
                table: "Dojmovi",
                keyColumn: "Id",
                keyValue: 9112);

            migrationBuilder.DeleteData(
                table: "Dojmovi",
                keyColumn: "Id",
                keyValue: 9113);

            migrationBuilder.DeleteData(
                table: "Dojmovi",
                keyColumn: "Id",
                keyValue: 9114);

            migrationBuilder.DeleteData(
                table: "Dojmovi",
                keyColumn: "Id",
                keyValue: 9115);

            migrationBuilder.DeleteData(
                table: "Dojmovi",
                keyColumn: "Id",
                keyValue: 9116);

            migrationBuilder.DeleteData(
                table: "Dojmovi",
                keyColumn: "Id",
                keyValue: 9140);

            migrationBuilder.DeleteData(
                table: "Dojmovi",
                keyColumn: "Id",
                keyValue: 9150);

            migrationBuilder.DeleteData(
                table: "Dojmovi",
                keyColumn: "Id",
                keyValue: 9156);

            migrationBuilder.DeleteData(
                table: "Drzava",
                keyColumn: "Id",
                keyValue: 2001);

            migrationBuilder.DeleteData(
                table: "Grad",
                keyColumn: "Id",
                keyValue: 3000);

            migrationBuilder.DeleteData(
                table: "KorisniciUloge",
                keyColumn: "KorisnikUlogaId",
                keyValue: 1);

            migrationBuilder.DeleteData(
                table: "KorisniciUloge",
                keyColumn: "KorisnikUlogaId",
                keyValue: 2);

            migrationBuilder.DeleteData(
                table: "KorisniciUloge",
                keyColumn: "KorisnikUlogaId",
                keyValue: 5);

            migrationBuilder.DeleteData(
                table: "Korpa",
                keyColumn: "KorpaId",
                keyValue: 7898);

            migrationBuilder.DeleteData(
                table: "Lokacija",
                keyColumn: "LokacijaId",
                keyValue: 6000);

            migrationBuilder.DeleteData(
                table: "Lokacija",
                keyColumn: "LokacijaId",
                keyValue: 6001);

            migrationBuilder.DeleteData(
                table: "Lokacija",
                keyColumn: "LokacijaId",
                keyValue: 6002);

            migrationBuilder.DeleteData(
                table: "Prilozi",
                keyColumn: "PrilogId",
                keyValue: 4878);

            migrationBuilder.DeleteData(
                table: "Prilozi",
                keyColumn: "PrilogId",
                keyValue: 4898);

            migrationBuilder.DeleteData(
                table: "Restorans",
                keyColumn: "RestoranId",
                keyValue: 3111);

            migrationBuilder.DeleteData(
                table: "StavkeNarudzbe",
                keyColumn: "Id",
                keyValue: 7000);

            migrationBuilder.DeleteData(
                table: "Grad",
                keyColumn: "Id",
                keyValue: 3010);

            migrationBuilder.DeleteData(
                table: "Jelo",
                keyColumn: "JeloId",
                keyValue: 5000);

            migrationBuilder.DeleteData(
                table: "Jelo",
                keyColumn: "JeloId",
                keyValue: 5001);

            migrationBuilder.DeleteData(
                table: "Jelo",
                keyColumn: "JeloId",
                keyValue: 5002);

            migrationBuilder.DeleteData(
                table: "Jelo",
                keyColumn: "JeloId",
                keyValue: 5004);

            migrationBuilder.DeleteData(
                table: "Jelo",
                keyColumn: "JeloId",
                keyValue: 5005);

            migrationBuilder.DeleteData(
                table: "Korisnici",
                keyColumn: "Id",
                keyValue: 1002);

            migrationBuilder.DeleteData(
                table: "Korisnici",
                keyColumn: "Id",
                keyValue: 1007);

            migrationBuilder.DeleteData(
                table: "Korisnici",
                keyColumn: "Id",
                keyValue: 1111);

            migrationBuilder.DeleteData(
                table: "Narudzba",
                keyColumn: "Id",
                keyValue: 6000);

            migrationBuilder.DeleteData(
                table: "Uloge",
                keyColumn: "Id",
                keyValue: 1);

            migrationBuilder.DeleteData(
                table: "Uloge",
                keyColumn: "Id",
                keyValue: 2);

            migrationBuilder.DeleteData(
                table: "Uloge",
                keyColumn: "Id",
                keyValue: 3);

            migrationBuilder.DeleteData(
                table: "Drzava",
                keyColumn: "Id",
                keyValue: 2000);

            migrationBuilder.DeleteData(
                table: "Kategorija",
                keyColumn: "KategorijaId",
                keyValue: 4000);

            migrationBuilder.DeleteData(
                table: "Kategorija",
                keyColumn: "KategorijaId",
                keyValue: 4001);

            migrationBuilder.DeleteData(
                table: "Kategorija",
                keyColumn: "KategorijaId",
                keyValue: 4002);

            migrationBuilder.DeleteData(
                table: "Kategorija",
                keyColumn: "KategorijaId",
                keyValue: 4003);

            migrationBuilder.DeleteData(
                table: "Korisnici",
                keyColumn: "Id",
                keyValue: 1001);

            migrationBuilder.DeleteData(
                table: "Status",
                keyColumn: "Id",
                keyValue: 8010);
        }
    }
}
