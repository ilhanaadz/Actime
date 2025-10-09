using Actime.Model.Requests;
using Actime.Model.SearchObjects;
using Actime.Services.Interfaces;

namespace Actime.Controllers
{
    public class CategoryController : BaseCrudController<Model.Entities.Category, TextSearchObject, CategoryRequest, CategoryRequest>
    {
        public CategoryController(ICategoryService categoryService) : base(categoryService)
        {
        }
    }
}
