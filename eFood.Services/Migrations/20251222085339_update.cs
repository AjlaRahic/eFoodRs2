using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace eFood.Services.Migrations
{
    public partial class update : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.UpdateData(
                table: "Korisnici",
                keyColumn: "Id",
                keyValue: 1001,
                columns: new[] { "LozinkaHash", "LozinkaSalt" },
                values: new object[] { "lO3TUAEECymLyrLL3NsecbsHsXM=", "9jrKqeg8QQ2gzYBZMnzn7w==" });

            migrationBuilder.UpdateData(
                table: "Korisnici",
                keyColumn: "Id",
                keyValue: 1002,
                columns: new[] { "LozinkaHash", "LozinkaSalt" },
                values: new object[] { "M4By4WvKLzOYj1op2BaWqF7Ln5Y=", "daqTFVmj6cSLQbCgJl0fHA==" });

            migrationBuilder.UpdateData(
                table: "Korisnici",
                keyColumn: "Id",
                keyValue: 1007,
                columns: new[] { "LozinkaHash", "LozinkaSalt" },
                values: new object[] { "8wFYgUzIURKTyMIKjC16j3dzd8I=", "AsO8Y5IJQZalFH7bDlDLkQ==" });

            migrationBuilder.UpdateData(
                table: "Korisnici",
                keyColumn: "Id",
                keyValue: 1111,
                columns: new[] { "LozinkaHash", "LozinkaSalt" },
                values: new object[] { "FFZFAd8clfoK67hlqyjIJ1e26G4=", "448i+5S52hVzHMefCUON1w==" });

            migrationBuilder.InsertData(
                table: "Narudzba",
                columns: new[] { "Id", "DatumNarudzbe", "DostavljacId", "KorisnikId", "PaymentId", "StateMachine", "StatusNarudzbeId" },
                values: new object[] { 6020, new DateTime(2025, 12, 22, 16, 0, 0, 0, DateTimeKind.Unspecified), null, 1001, null, "active", 2 });

            migrationBuilder.UpdateData(
                table: "Status",
                keyColumn: "Id",
                keyValue: 8010,
                column: "Naziv",
                value: "Poslano");
        }

        protected override void Down(MigrationBuilder migrationBuilder)
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
                values: new object[] { "x0Bfnv8LI5SjZwJ4yL8454QaGwA=", "I7QYa5d2kKwzzXnVlzvvQw==" });

            migrationBuilder.UpdateData(
                table: "Korisnici",
                keyColumn: "Id",
                keyValue: 1002,
                columns: new[] { "LozinkaHash", "LozinkaSalt" },
                values: new object[] { "LmaiQnRphFX+fZLHtedSOMwxJ9Y=", "5z6nl4cuTyGdPjmgO+Y2tA==" });

            migrationBuilder.UpdateData(
                table: "Korisnici",
                keyColumn: "Id",
                keyValue: 1007,
                columns: new[] { "LozinkaHash", "LozinkaSalt" },
                values: new object[] { "y9JBoZHvM0DhEqy690kOhR7HJ6k=", "TwLUEL5MUzSIhF/Kv6BE6w==" });

            migrationBuilder.UpdateData(
                table: "Korisnici",
                keyColumn: "Id",
                keyValue: 1111,
                columns: new[] { "LozinkaHash", "LozinkaSalt" },
                values: new object[] { "JelFhDkn9AX7Tb/NeaiHEyjidjs=", "iGwtJFNUtUT9EquuFDa3+w==" });

            migrationBuilder.UpdateData(
                table: "Status",
                keyColumn: "Id",
                keyValue: 8010,
                column: "Naziv",
                value: "poslano");
        }
    }
}
