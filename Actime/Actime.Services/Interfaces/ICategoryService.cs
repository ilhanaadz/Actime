using Actime.Model.Requests;
using Actime.Model.SearchObjects;

namespace Actime.Services.Interfaces
{
    public interface ICategoryService : ICrudService<Model.Entities.Category, TextSearchObject, CategoryRequest, CategoryRequest>
    {
    }
}
