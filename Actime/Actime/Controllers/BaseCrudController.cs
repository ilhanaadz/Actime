using Actime.Model.SearchObjects;
using Actime.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace Actime.Controllers
{
    public class BaseCrudController<T, TSearch, TInsert, TUpdate> : BaseController<T, TSearch>
        where T : class
        where TSearch : BaseSearchObject, new()
        where TInsert : class
        where TUpdate : class
    {
        protected readonly ICrudService<T, TSearch, TInsert, TUpdate> _crudService;

        public BaseCrudController(ICrudService<T, TSearch, TInsert, TUpdate> crudService) : base(crudService)
        {
            _crudService = crudService ?? throw new ArgumentNullException(nameof(crudService));
        }

        [HttpPost]
        public virtual async Task<T> Create([FromBody] TInsert request) => await _crudService.CreateAsync(request);

        [HttpPut("{id}")]
        public virtual async Task<T?> Update(int id, [FromBody] TUpdate request) => await _crudService.UpdateAsync(id, request);

        [HttpDelete("{id}")]
        public virtual async Task<bool> Delete(int id) => await _crudService.DeleteAsync(id);
    }
}