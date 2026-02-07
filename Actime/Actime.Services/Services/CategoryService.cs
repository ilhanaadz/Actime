using Actime.Model.Common;
using Actime.Model.Requests;
using Actime.Model.SearchObjects;
using Actime.Services.Database;
using Actime.Services.Interfaces;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;

namespace Actime.Services.Services
{
    public class CategoryService : BaseCrudService<Model.Entities.Category, TextSearchObject, Category, CategoryRequest, CategoryRequest>, ICategoryService
    {
        public CategoryService(ActimeContext context, IMapper mapper) : base(context, mapper)
        {
        }

        public override async Task<PagedResult<Model.Entities.Category>> GetAsync(TextSearchObject search)
        {
            var result = await base.GetAsync(search);

            foreach (var category in result.Items)
            {
                var organizationsCount = _context.Organizations.Count(o => o.CategoryId == category.Id);
                category.OrganizationsCount = organizationsCount;
            }

            return result;
        }

        protected override IQueryable<Category> ApplyFilter(IQueryable<Category> query, TextSearchObject search)
        {
            if (!string.IsNullOrWhiteSpace(search.Text))
            {
                query = query.Where(c => c.Name.ToLower().Contains(search.Text.Trim().ToLower()));
            }

            return base.ApplyFilter(query, search);
        }

        protected override async Task OnCreating(Category entity, CategoryRequest request)
        {
            var exists = await _context.Categories
                .AnyAsync(c => c.Name.ToLower() == entity.Name.ToLower());

            if (exists)
            {
                throw new InvalidOperationException($"Category with name '{entity.Name}' already exists.");
            }

            await base.OnCreating(entity, request);
        }

        protected override async Task<bool> OnDeleting(Category entity)
        {
            var hasOrganizations = await _context.Organizations
                .AnyAsync(o => o.CategoryId == entity.Id);

            if (hasOrganizations)
            {
                throw new InvalidOperationException(
                    "Cannot delete category because it has associated organizations. " +
                    "Please move or delete all organizations first.");
            }

            return await base.OnDeleting(entity);
        }
    }
}