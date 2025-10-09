using Actime.Model.Requests;
using Actime.Model.SearchObjects;
using Actime.Services.Database;
using Actime.Services.Interfaces;
using MapsterMapper;

namespace Actime.Services.Services
{
    public class CategoryService : BaseCrudService<Model.Entities.Category, TextSearchObject, Category, CategoryRequest, CategoryRequest>, ICategoryService
    {
        public CategoryService(ActimeContext context, IMapper mapper) : base(context, mapper)
        {
        }

        protected override IQueryable<Category> ApplyFilter(IQueryable<Category> query, TextSearchObject search)
        {
            if (!string.IsNullOrWhiteSpace(search.Text))
            {
                query = query.Where(c => c.Name.ToLower().Contains(search.Text.Trim().ToLower()));
            }

            return base.ApplyFilter(query, search);
        }
    }
}