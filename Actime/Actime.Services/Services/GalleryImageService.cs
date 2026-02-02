using Actime.Model.Requests;
using Actime.Model.SearchObjects;
using Actime.Services.Database;
using Actime.Services.Interfaces;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;

namespace Actime.Services.Services
{
    public class GalleryImageService : BaseCrudService<Model.Entities.GalleryImage, GalleryImageSearchObject, Database.GalleryImage, GalleryImageInsertRequest, GalleryImageInsertRequest>, IGalleryImageService
    {
        public GalleryImageService(ActimeContext context, IMapper mapper) : base(context, mapper)
        {
        }

        protected override IQueryable<GalleryImage> ApplyFilter(IQueryable<GalleryImage> query, GalleryImageSearchObject search)
        {
            if (search.UserId.HasValue)
            {
                query = query.Where(x => x.UserId == search.UserId.Value);
            }

            if (search.OrganizationId.HasValue)
            {
                query = query.Where(x => x.OrganizationId == search.OrganizationId.Value);
            }

            return base.ApplyFilter(query, search);
        }

        public async Task<IEnumerable<Model.Entities.GalleryImage>> GetByUserIdAsync(int userId)
        {
            var entities = await _context.Set<GalleryImage>()
                .Where(x => x.UserId == userId)
                .OrderByDescending(x => x.CreatedAt)
                .ToListAsync();

            return _mapper.Map<IEnumerable<Model.Entities.GalleryImage>>(entities);
        }

        public async Task<IEnumerable<Model.Entities.GalleryImage>> GetByOrganizationIdAsync(int organizationId)
        {
            var entities = await _context.Set<GalleryImage>()
                .Where(x => x.OrganizationId == organizationId)
                .OrderByDescending(x => x.CreatedAt)
                .ToListAsync();

            return _mapper.Map<IEnumerable<Model.Entities.GalleryImage>>(entities);
        }
    }
}
