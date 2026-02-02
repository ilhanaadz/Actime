using Actime.Model.Entities;
using Actime.Model.Requests;
using Actime.Model.SearchObjects;
using Actime.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace Actime.Controllers
{
    public class GalleryController : BaseCrudController<GalleryImage, GalleryImageSearchObject, GalleryImageInsertRequest, GalleryImageInsertRequest>
    {
        private readonly IGalleryImageService _galleryService;

        public GalleryController(IGalleryImageService galleryService) : base(galleryService)
        {
            _galleryService = galleryService;
        }

        [HttpGet("user/{userId}")]
        public async Task<IEnumerable<GalleryImage>> GetByUserId(int userId)
        {
            return await _galleryService.GetByUserIdAsync(userId);
        }

        [HttpGet("organization/{organizationId}")]
        public async Task<IEnumerable<GalleryImage>> GetByOrganizationId(int organizationId)
        {
            return await _galleryService.GetByOrganizationIdAsync(organizationId);
        }
    }
}
