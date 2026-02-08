using Actime;
using Actime.Hubs;
using Actime.Model.Settings;
using Actime.Services.Database;
using Actime.Services.Interfaces;
using Actime.Services.Services;
using EasyNetQ;
using Mapster;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using System.Text;

// Load .env file if exists (for local development)
// Try multiple possible locations for .env file
var possibleEnvPaths = new[]
{
    Path.Combine(AppContext.BaseDirectory, "..", "..", "..", "..", ".env"),  // From bin/Debug/net8.0
    Path.Combine(Directory.GetCurrentDirectory(), "..", ".env"),              // From Actime folder
    Path.Combine(Directory.GetCurrentDirectory(), ".env")                      // Current directory
};

foreach (var envPath in possibleEnvPaths)
{
    var fullPath = Path.GetFullPath(envPath);
    if (File.Exists(fullPath))
    {
        DotNetEnv.Env.Load(fullPath);
        Console.WriteLine($"Loaded .env from: {fullPath}");
        break;
    }
}

var builder = WebApplication.CreateBuilder(args);

//NOTE: Explore lifetimes: https://learn.microsoft.com/en-us/dotnet/core/extensions/dependency-injection#service-lifetimes
builder.Services.AddMapster();
builder.Services.AddTransient<ICityService, CityService>();
builder.Services.AddTransient<ICountryService, CountryService>();
builder.Services.AddTransient<ICategoryService, CategoryService>();
builder.Services.AddTransient<IAddressService, AddressService>();
builder.Services.AddTransient<ILocationService, LocationService>();
builder.Services.AddTransient<IJwtService, JwtService>();
builder.Services.AddTransient<IUserService, UserService>();
builder.Services.AddTransient<IOrganizationService, OrganizationService>();
builder.Services.AddTransient<IEventService, EventService>();
builder.Services.AddTransient<IFavoriteService, FavoriteService>();
builder.Services.AddTransient<IMembershipService, MembershipService>();
builder.Services.AddTransient<INotificationService, NotificationService>();
builder.Services.AddTransient<IParticipationService, ParticipationService>();
builder.Services.AddTransient<IReportService, ReportService>();
builder.Services.AddTransient<IReviewService, ReviewService>();
builder.Services.AddTransient<IScheduleService, ScheduleService>();
builder.Services.AddTransient<IGalleryImageService, GalleryImageService>();
builder.Services.AddTransient<IPaymentService, PaymentService>();
builder.Services.AddScoped<IAuthService, AuthService>();
builder.Services.AddScoped<IEmailService, EmailService>();

builder.Services.AddSingleton<IEventRecommenderService, EventRecommenderService>();


builder.Services.AddHostedService<EventRecommenderBackgroundService>();

builder.Services.Configure<JwtSettings>(builder.Configuration.GetSection("JwtSettings"));
builder.Services.Configure<EmailSettings>(builder.Configuration.GetSection("EmailSettings"));
builder.Services.Configure<StripeSettings>(builder.Configuration.GetSection("StripeSettings"));
builder.Services.Configure<RabbitMqSettings>(builder.Configuration.GetSection("RabbitMqSettings"));

var rabbitMqSettings = builder.Configuration
    .GetSection("RabbitMqSettings")
    .Get<RabbitMqSettings>();

builder.Services.AddEasyNetQ(rabbitMqSettings!.GetConnectionString());

builder.Services.AddDbContext<ActimeContext>(options =>
    options.UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection")));

// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
    c.AddSecurityDefinition("Bearer", new Microsoft.OpenApi.Models.OpenApiSecurityScheme
    {
        Name = "Authorization",
        Type = Microsoft.OpenApi.Models.SecuritySchemeType.Http,
        Scheme = "bearer",
        BearerFormat = "JWT",
        In = Microsoft.OpenApi.Models.ParameterLocation.Header,
        Description = "Unesi: Bearer {tvoj_token}"
    });

    c.AddSecurityRequirement(new Microsoft.OpenApi.Models.OpenApiSecurityRequirement
    {
        {
            new Microsoft.OpenApi.Models.OpenApiSecurityScheme
            {
                Reference = new Microsoft.OpenApi.Models.OpenApiReference
                {
                    Type = Microsoft.OpenApi.Models.ReferenceType.SecurityScheme,
                    Id = "Bearer"
                }
            },
            Array.Empty<string>()
        }
    });
});
builder.Services.AddIdentity<User, IdentityRole<int>>(options =>
{
    options.User.RequireUniqueEmail = true;

    // Relaxed password requirements for easier testing/development
    options.Password.RequireDigit = false;
    options.Password.RequireLowercase = false;
    options.Password.RequireUppercase = false;
    options.Password.RequireNonAlphanumeric = false;
    options.Password.RequiredLength = 4;
    options.Password.RequiredUniqueChars = 1;
})
.AddEntityFrameworkStores<ActimeContext>()
.AddDefaultTokenProviders();

var jwtSettings = builder.Configuration.GetSection("JwtSettings").Get<JwtSettings>()!;

// Validate required configuration
if (string.IsNullOrWhiteSpace(jwtSettings.SecretKey))
{
    throw new InvalidOperationException(
        "JwtSettings:SecretKey is not configured. " +
        "Please set JwtSettings__SecretKey environment variable or add it to .env file. " +
        "Example: JwtSettings__SecretKey=YourSuperSecretKeyThatIsAtLeast32CharactersLong!");
}

builder.Services.Configure<JwtSettings>(builder.Configuration.GetSection("JwtSettings"));

builder.Services.AddAuthentication(options =>
{
    options.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
    options.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
})
.AddJwtBearer(options =>
{
    options.TokenValidationParameters = new TokenValidationParameters
    {
        ValidateIssuer = true,
        ValidateAudience = true,
        ValidateLifetime = true,
        ValidateIssuerSigningKey = true,
        ValidIssuer = jwtSettings.Issuer,
        ValidAudience = jwtSettings.Audience,
        IssuerSigningKey = new SymmetricSecurityKey(
            Encoding.UTF8.GetBytes(jwtSettings.SecretKey)),
        ClockSkew = TimeSpan.Zero
    };

    // Return JSON error responses instead of HTML/plain text
    options.Events = new JwtBearerEvents
    {
        OnChallenge = context =>
        {
            // Skip the default behavior
            context.HandleResponse();

            context.Response.StatusCode = 401;
            context.Response.ContentType = "application/json";

            var result = System.Text.Json.JsonSerializer.Serialize(new
            {
                message = "Neautorizovan pristup. Molimo prijavite se."
            });

            return context.Response.WriteAsync(result);
        },
        OnForbidden = context =>
        {
            context.Response.StatusCode = 403;
            context.Response.ContentType = "application/json";

            var result = System.Text.Json.JsonSerializer.Serialize(new
            {
                message = "Nemate dozvolu za pristup ovom resursu."
            });

            return context.Response.WriteAsync(result);
        }
    };
});

builder.Services.AddAuthorization();
builder.Services.AddControllers()
    .ConfigureApiBehaviorOptions(options =>
    {
        options.InvalidModelStateResponseFactory = context =>
        {
            var errors = context.ModelState
                .Where(e => e.Value?.Errors.Count > 0)
                .ToDictionary(
                    kvp => kvp.Key,
                    kvp => kvp.Value!.Errors.Select(e => e.ErrorMessage).ToArray()
                );

            return new Microsoft.AspNetCore.Mvc.BadRequestObjectResult(new
            {
                message = "Validacija nije uspjela",
                errors = errors
            });
        };
    });
builder.Services.AddHealthChecks();

builder.Services.AddSignalR();

// CORS for SignalR (Flutter app)
builder.Services.AddCors(options =>
{
    options.AddPolicy("SignalRPolicy", policy =>
    {
        policy.AllowAnyOrigin()
              .AllowAnyHeader()
              .AllowAnyMethod();
    });
});

//builder.Services.AddAutoMapper(typeof(MappingProfile));

var app = builder.Build();

using (var scope = app.Services.CreateScope())
{
    var services = scope.ServiceProvider;

    var db = services.GetRequiredService<ActimeContext>();
    await db.Database.MigrateAsync();

    await SeedData.Initialize(db, services);
}

// Add global exception handler to return JSON errors
app.UseExceptionHandler(errorApp =>
{
    errorApp.Run(async context =>
    {
        context.Response.StatusCode = 500;
        context.Response.ContentType = "application/json";

        var error = context.Features.Get<Microsoft.AspNetCore.Diagnostics.IExceptionHandlerFeature>();
        if (error != null)
        {
            var result = System.Text.Json.JsonSerializer.Serialize(new
            {
                message = error.Error.Message
            });

            await context.Response.WriteAsync(result);
        }
    });
});

app.UseSwagger();
app.UseSwaggerUI();

app.UseStaticFiles();

app.UseCors("SignalRPolicy");

// HTTPS redirection disabled for development (using HTTP only to avoid self-signed certificate issues)
// app.UseHttpsRedirection();

app.UseAuthentication();
app.UseAuthorization();

app.MapControllers();
app.MapHealthChecks("/health");
app.MapHub<NotificationHub>("/notificationHub");

app.Run();
