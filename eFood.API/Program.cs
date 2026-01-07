using AutoMapper;
using eFood.API;
using eFood.Model.Requests;
using eFood.Model.SearchObjects;
using eFood.Services;
using eFood.Services.Database;
using eFood.Services.NarudzbeStateMachine;
using eFood.Services.RabbitMQ;
using eFood.Services.Reports;

using Microsoft.AspNetCore.Authentication;
using Microsoft.EntityFrameworkCore;
using Microsoft.OpenApi.Models;
using Newtonsoft.Json.Serialization;

var builder = WebApplication.CreateBuilder(args);

// --- SERVICES --- //

// Scoped services for business logic
builder.Services.AddScoped<IDrzavaService, DrzavaService>();
builder.Services.AddScoped<IDojmoviService, DojmoviService>();
builder.Services.AddScoped<IGradService, GradService>();
builder.Services.AddScoped<IKorisniciService, KorisniciService>();
builder.Services.AddScoped<IUlogaService, UlogaService>();
builder.Services.AddScoped<IKategorijaService, KategorijaService>();
builder.Services.AddScoped<IJeloService, JeloService>();
builder.Services.AddScoped<INarudzbaService, NarudzbaService>();
builder.Services.AddScoped<IStatusNarudzbeService, StatusNarudzbeService>();
builder.Services.AddScoped<IStavkeNarudzbeService, StavkeNarudzbeService>();
builder.Services.AddScoped<IUplataService, UplataService>();
builder.Services.AddScoped<IReportService, ReportService>();
builder.Services.AddScoped<IRestoranService, RestoranService>();
builder.Services.AddScoped<IKorisniciUloga, KorisniciUlogaService>();
builder.Services.AddScoped<IKorpaService, KorpaService>();
builder.Services.AddScoped<IPriloziService, PriloziService>();
builder.Services.AddSingleton<IMailProducer, MailProducer>();
builder.Services.AddScoped<ILokacijaService, LokacijaService>();

// State machine services for orders
builder.Services.AddScoped<BaseNarudzbaState>();
builder.Services.AddScoped<InitialNarudzbaState>();
builder.Services.AddScoped<DraftNarudzbeState>();
builder.Services.AddScoped<ActiveNarudzbaState>();

// --- CONTROLLERS & JSON --- //
builder.Services.AddControllers()
    .AddNewtonsoftJson(options =>
    {
        options.SerializerSettings.ContractResolver = new DefaultContractResolver
        {
            NamingStrategy = new CamelCaseNamingStrategy()
        };
        options.SerializerSettings.ReferenceLoopHandling = Newtonsoft.Json.ReferenceLoopHandling.Ignore;
    });

// --- SWAGGER --- //
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
    c.AddSecurityDefinition("Basic", new OpenApiSecurityScheme
    {
        Type = SecuritySchemeType.Http,
        Scheme = "basic"
    });

    c.AddSecurityRequirement(new OpenApiSecurityRequirement
    {
        {
            new OpenApiSecurityScheme
            {
                Reference = new OpenApiReference
                {
                    Type = ReferenceType.SecurityScheme,
                    Id = "Basic"
                }
            },
            new string[]{}
        }
    });
});

// --- DATABASE --- //
var cs = builder.Configuration.GetConnectionString("Default") ??
         builder.Configuration.GetConnectionString("DefaultConnection") ??
         Environment.GetEnvironmentVariable("ConnectionStrings__Default") ??
         Environment.GetEnvironmentVariable("ConnectionStrings__DefaultConnection");

Console.WriteLine("Connection string: " + cs);

builder.Services.AddDbContext<EFoodContext>(options =>
    options.UseSqlServer(cs, sql =>
    {
        sql.EnableRetryOnFailure();
        sql.CommandTimeout(30);
    })
);

// --- AUTOMAPPER --- //
builder.Services.AddAutoMapper(typeof(IKorisniciService).Assembly);

// --- AUTHENTICATION --- //
builder.Services.AddAuthentication("BasicAuthentication")
    .AddScheme<AuthenticationSchemeOptions, BasicAuthenticationHandler>("BasicAuthentication", null);



// --- CORS --- //
builder.Services.AddCors(options =>
{
    options.AddDefaultPolicy(builder =>
    {
        builder
            .SetIsOriginAllowed(_ => true) // dopušta sve origin-e
            .AllowAnyHeader()
            .AllowAnyMethod()
            .AllowCredentials();
    });
});

// --- BUILD APP --- //
var app = builder.Build();

// --- MIDDLEWARE --- //
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();
app.UseStaticFiles();
app.UseRouting();

app.UseCors(); // ➡️ važno za SignalR + Flutter

app.UseAuthentication();
app.UseAuthorization();

app.MapControllers();


using (var scope = app.Services.CreateScope())
{
    var dataContext = scope.ServiceProvider.GetRequiredService<EFoodContext>();
    try
    {
        dataContext.Database.Migrate();
    }
    catch (Exception ex)
    {
        Console.WriteLine("DB migration failed: " + ex.Message);
    }
}
app.Run();
