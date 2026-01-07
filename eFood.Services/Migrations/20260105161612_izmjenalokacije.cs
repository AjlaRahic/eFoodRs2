using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace eFood.Services.Migrations
{
    public partial class izmjenalokacije : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.UpdateData(
                table: "Korisnici",
                keyColumn: "Id",
                keyValue: 1001,
                columns: new[] { "LozinkaHash", "LozinkaSalt" },
                values: new object[] { "d2YmixLUHfSs9fa66/aaViQxS/s=", "7YVh6Qc9YOL4EPC+MQ9nqg==" });

            migrationBuilder.UpdateData(
                table: "Korisnici",
                keyColumn: "Id",
                keyValue: 1002,
                columns: new[] { "LozinkaHash", "LozinkaSalt" },
                values: new object[] { "CA5gLeKf8VqNCvvWalhRtusM+bU=", "aBxt6rFJFVvS0JpzLBKkvw==" });

            migrationBuilder.UpdateData(
                table: "Korisnici",
                keyColumn: "Id",
                keyValue: 1007,
                columns: new[] { "LozinkaHash", "LozinkaSalt" },
                values: new object[] { "UlOsiOQzt89P/Q0AZyki5nrYiFs=", "sduagOCKzCt2Vio4UQqLYg==" });

            migrationBuilder.UpdateData(
                table: "Korisnici",
                keyColumn: "Id",
                keyValue: 1111,
                columns: new[] { "LozinkaHash", "LozinkaSalt" },
                values: new object[] { "ovpGYjeuNsuTT/J4tTnPa08u2cc=", "A+sydmr3pYPxfETzGvTiqw==" });

            migrationBuilder.UpdateData(
                table: "Lokacija",
                keyColumn: "LokacijaId",
                keyValue: 6001,
                columns: new[] { "Latitude", "Longitude" },
                values: new object[] { 43.258200000000002, 17.889700000000001 });
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
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
                keyValue: 6001,
                columns: new[] { "Latitude", "Longitude" },
                values: new object[] { 43.344999999999999, 17.814 });
        }
    }
}
