using Actime.Model;
using Actime.Model.SearchObjects;

namespace Actime.Services
{
    public interface IService<T, TSearch>
        where T : class
        where TSearch : BaseSearchObject
    {
        Task<PagedResult<T>> GetAsync(TSearch search);
        Task<T?> GetByIdAsync(int id);
    }
}
