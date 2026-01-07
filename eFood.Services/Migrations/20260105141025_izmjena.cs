using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace eFood.Services.Migrations
{
    public partial class izmjena : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DeleteData(
                table: "Narudzba",
                keyColumn: "Id",
                keyValue: 6020);

            migrationBuilder.UpdateData(
                table: "Korisnici",
                keyColumn: "Id",
                keyValue: 1001,
                columns: new[] { "LozinkaHash", "LozinkaSalt" },
                values: new object[] { "eyEfMdOPO6Xy/khdCNyacUh/0Rk=", "MyyOfGeuMBjs7D5CjtgsRg==" });

            migrationBuilder.UpdateData(
                table: "Korisnici",
                keyColumn: "Id",
                keyValue: 1002,
                columns: new[] { "LozinkaHash", "LozinkaSalt" },
                values: new object[] { "bSIWhFHeTsbegd8IhoNJE4ZrzEo=", "uknjqNcjw+QpZKR+CdXDlQ==" });

            migrationBuilder.UpdateData(
                table: "Korisnici",
                keyColumn: "Id",
                keyValue: 1007,
                columns: new[] { "LozinkaHash", "LozinkaSalt" },
                values: new object[] { "6MGfKdMYGA6HuOR+qWKJSS26JDE=", "JaX2r7tOJUtoUSAh5vFpuw==" });

            migrationBuilder.UpdateData(
                table: "Korisnici",
                keyColumn: "Id",
                keyValue: 1111,
                columns: new[] { "LozinkaHash", "LozinkaSalt" },
                values: new object[] { "buLUe5GvNPIBPxV7b9OaWFRgzSA=", "pwLhuoGk9LMATPLujrMARA==" });

            migrationBuilder.UpdateData(
                table: "Lokacija",
                keyColumn: "LokacijaId",
                keyValue: 6000,
                columns: new[] { "KorisnikId", "Latitude", "Longitude" },
                values: new object[] { 1111, 43.343800000000002, 17.812000000000001 });

            migrationBuilder.UpdateData(
                table: "Lokacija",
                keyColumn: "LokacijaId",
                keyValue: 6001,
                columns: new[] { "Latitude", "Longitude" },
                values: new object[] { 43.344999999999999, 17.814 });

            migrationBuilder.UpdateData(
                table: "Lokacija",
                keyColumn: "LokacijaId",
                keyValue: 6002,
                columns: new[] { "KorisnikId", "Latitude", "Longitude" },
                values: new object[] { 1007, 43.356000000000002, 17.82 });

            migrationBuilder.InsertData(
                table: "Lokacija",
                columns: new[] { "LokacijaId", "KorisniciId", "KorisnikId", "Latitude", "Longitude", "Vrijeme" },
                values: new object[] { 6003, null, 1001, 43.258000000000003, 17.684000000000001, new DateTime(2025, 12, 16, 15, 50, 0, 0, DateTimeKind.Unspecified) });

            migrationBuilder.UpdateData(
                table: "Narudzba",
                keyColumn: "Id",
                keyValue: 6000,
                columns: new[] { "DatumNarudzbe", "KorisnikId", "StateMachine" },
                values: new object[] { new DateTime(2025, 12, 16, 16, 5, 0, 0, DateTimeKind.Unspecified), 1002, "active" });

            migrationBuilder.InsertData(
                table: "Narudzba",
                columns: new[] { "Id", "DatumNarudzbe", "DostavljacId", "KorisnikId", "PaymentId", "StateMachine", "StatusNarudzbeId" },
                values: new object[] { 2001, new DateTime(2025, 12, 16, 16, 10, 0, 0, DateTimeKind.Unspecified), null, 1002, null, "active", 3 });

            migrationBuilder.UpdateData(
                table: "Restorans",
                keyColumn: "RestoranId",
                keyValue: 3111,
                column: "Adresa",
                value: "Rondo bb");

            migrationBuilder.InsertData(
                table: "StavkeNarudzbe",
                columns: new[] { "Id", "Cijena", "JeloId", "Kolicina", "NarudzbaId" },
                values: new object[] { 7100, 30, 5000, 2, 2001 });
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DeleteData(
                table: "Lokacija",
                keyColumn: "LokacijaId",
                keyValue: 6003);

            migrationBuilder.DeleteData(
                table: "StavkeNarudzbe",
                keyColumn: "Id",
                keyValue: 7100);

            migrationBuilder.DeleteData(
                table: "Narudzba",
                keyColumn: "Id",
                keyValue: 2001);

            migrationBuilder.UpdateData(
                table: "Korisnici",
                keyColumn: "Id",
                keyValue: 1001,
                columns: new[] { "LozinkaHash", "LozinkaSalt" },
                values: new object[] { "1MoYJAcPQOtYyz9OBK9wG9N3nHY=", "lPf72fCGZZhJkHT3ukZ/Yg==" });

            migrationBuilder.UpdateData(
                table: "Korisnici",
                keyColumn: "Id",
                keyValue: 1002,
                columns: new[] { "LozinkaHash", "LozinkaSalt" },
                values: new object[] { "VNIxQMCKAL4N7JOropv2QVKb5gU=", "GflW7/WyV1XaGsEVme+7lQ==" });

            migrationBuilder.UpdateData(
                table: "Korisnici",
                keyColumn: "Id",
                keyValue: 1007,
                columns: new[] { "LozinkaHash", "LozinkaSalt" },
                values: new object[] { "cgJgJ6rNwv2Cuv1AU3yLgxeDdJM=", "qIp2QsbSrY4JhKRrfeNHyg==" });

            migrationBuilder.UpdateData(
                table: "Korisnici",
                keyColumn: "Id",
                keyValue: 1111,
                columns: new[] { "LozinkaHash", "LozinkaSalt" },
                values: new object[] { "+TYU3JJkMsqf5McMX5sY0ojQDqA=", "4WkUg1xdPAANlZ+BPX8VSg==" });

            migrationBuilder.UpdateData(
                table: "Lokacija",
                keyColumn: "LokacijaId",
                keyValue: 6000,
                columns: new[] { "KorisnikId", "Latitude", "Longitude" },
                values: new object[] { 1001, 43.856299999999997, 18.4131 });

            migrationBuilder.UpdateData(
                table: "Lokacija",
                keyColumn: "LokacijaId",
                keyValue: 6001,
                columns: new[] { "Latitude", "Longitude" },
                values: new object[] { 44.817599999999999, 20.456900000000001 });

            migrationBuilder.UpdateData(
                table: "Lokacija",
                keyColumn: "LokacijaId",
                keyValue: 6002,
                columns: new[] { "KorisnikId", "Latitude", "Longitude" },
                values: new object[] { 1001, 43.348599999999998, 17.8123 });

            migrationBuilder.UpdateData(
                table: "Narudzba",
                keyColumn: "Id",
                keyValue: 6000,
                columns: new[] { "DatumNarudzbe", "KorisnikId", "StateMachine" },
                values: new object[] { new DateTime(2025, 12, 14, 16, 0, 0, 0, DateTimeKind.Unspecified), 1001, "poslano" });

            migrationBuilder.InsertData(
                table: "Narudzba",
                columns: new[] { "Id", "DatumNarudzbe", "DostavljacId", "KorisnikId", "PaymentId", "StateMachine", "StatusNarudzbeId" },
                values: new object[] { 6020, new DateTime(2025, 12, 22, 16, 0, 0, 0, DateTimeKind.Unspecified), null, 1001, null, "active", 2 });

            migrationBuilder.UpdateData(
                table: "Restorans",
                keyColumn: "RestoranId",
                keyValue: 3111,
                column: "Adresa",
                value: "Mostar");
        }
    }
}
