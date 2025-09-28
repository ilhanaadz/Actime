using Microsoft.AspNetCore.Mvc;

namespace Actime.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class AuthController
    {
        private readonly ILogger<AuthController> _logger;
        private readonly IConfiguration _config;

        public AuthController(ILogger<AuthController> logger, IConfiguration configuration)
        {
            _logger = logger ?? throw new ArgumentNullException(nameof(logger));
            _config = configuration ?? throw new ArgumentNullException(nameof(configuration));
        }
    }
}
