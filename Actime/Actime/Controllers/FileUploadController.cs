using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Actime.Controllers
{
    [ApiController]
    [Route("[controller]")]
    [Authorize]
    public class FileUploadController : ControllerBase
    {
        private readonly IWebHostEnvironment _environment;
        private readonly string[] _allowedExtensions = { ".jpg", ".jpeg", ".png", ".gif", ".webp" };
        private const long MaxFileSize = 5 * 1024 * 1024; // 5MB

        public FileUploadController(IWebHostEnvironment environment)
        {
            _environment = environment;
        }

        [HttpPost("profile")]
        public async Task<IActionResult> UploadProfileImage(IFormFile file)
        {
            return await UploadFile(file, "profiles");
        }

        [HttpPost("organization")]
        public async Task<IActionResult> UploadOrganizationLogo(IFormFile file)
        {
            return await UploadFile(file, "organizations");
        }

        [HttpPost("gallery")]
        public async Task<IActionResult> UploadGalleryImage(IFormFile file)
        {
            return await UploadFile(file, "gallery");
        }

        private async Task<IActionResult> UploadFile(IFormFile? file, string folder)
        {
            if (file == null || file.Length == 0)
            {
                return BadRequest(new { message = "Nije odabrana datoteka." });
            }

            if (file.Length > MaxFileSize)
            {
                return BadRequest(new { message = "Datoteka je prevelika. Maksimalna veličina je 5MB." });
            }

            var extension = Path.GetExtension(file.FileName).ToLowerInvariant();
            if (!_allowedExtensions.Contains(extension))
            {
                return BadRequest(new { message = "Nepodržani format datoteke. Dozvoljeni formati: JPG, PNG, GIF, WEBP." });
            }

            var uploadsFolder = Path.Combine(_environment.WebRootPath, "uploads", folder);
            Directory.CreateDirectory(uploadsFolder);

            var uniqueFileName = $"{Guid.NewGuid()}{extension}";
            var filePath = Path.Combine(uploadsFolder, uniqueFileName);

            using (var stream = new FileStream(filePath, FileMode.Create))
            {
                await file.CopyToAsync(stream);
            }

            var imageUrl = $"/uploads/{folder}/{uniqueFileName}";

            return Ok(new { imageUrl });
        }

        [HttpDelete]
        public IActionResult DeleteImage([FromQuery] string imageUrl)
        {
            if (string.IsNullOrEmpty(imageUrl))
            {
                return BadRequest(new { message = "URL slike nije specificiran." });
            }

            // Ensure the URL starts with /uploads/ to prevent directory traversal
            if (!imageUrl.StartsWith("/uploads/"))
            {
                return BadRequest(new { message = "Nevažeći URL slike." });
            }

            var relativePath = imageUrl.TrimStart('/');
            var filePath = Path.Combine(_environment.WebRootPath, relativePath);

            // Additional security check - ensure we're still within wwwroot
            var fullPath = Path.GetFullPath(filePath);
            var wwwrootPath = Path.GetFullPath(_environment.WebRootPath);
            if (!fullPath.StartsWith(wwwrootPath))
            {
                return BadRequest(new { message = "Nevažeći URL slike." });
            }

            if (System.IO.File.Exists(filePath))
            {
                System.IO.File.Delete(filePath);
                return Ok(new { message = "Slika je uspješno obrisana." });
            }

            return NotFound(new { message = "Slika nije pronađena." });
        }
    }
}
