using Actime.Model.Entities;
using Actime.Model.Requests;
using Actime.Model.SearchObjects;

namespace Actime.Services.Interfaces
{
    public interface IGalleryImageService : ICrudService<GalleryImage, GalleryImageSearchObject, GalleryImageInsertRequest, GalleryImageInsertRequest>
    {
        Task<IEnumerable<GalleryImage>> GetByUserIdAsync(int userId);
        Task<IEnumerable<GalleryImage>> GetByOrganizationIdAsync(int organizationId);
    }
}
