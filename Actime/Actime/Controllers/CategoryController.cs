using Actime.Model.Common;
using Actime.Model.Entities;
using Actime.Model.Requests;
using Actime.Model.SearchObjects;
using Actime.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Actime.Controllers
{
    public class CategoryController : BaseCrudController<Model.Entities.Category, TextSearchObject, CategoryRequest, CategoryRequest>
    {
        public CategoryController(ICategoryService categoryService) : base(categoryService)
        {
        }

        [Authorize(Roles = "Admin")]
        public override Task<Category> Create([FromBody] CategoryRequest request)
        {
            return base.Create(request);
        }

        [AllowAnonymous]
        public override Task<PagedResult<Category>> Get([FromQuery] TextSearchObject? search = null)
        {
            return base.Get(search);
        }

        [AllowAnonymous]
        public override Task<Category?> GetById(int id)
        {
            return base.GetById(id);
        }
    }
}
