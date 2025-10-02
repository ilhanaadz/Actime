using Actime.Model.Common;
using Actime.Model.SearchObjects;

namespace Actime.Services.Interfaces
{
    public interface IService<T, TSearch>
        where T : class
        where TSearch : BaseSearchObject
    {
        Task<PagedResult<T>> GetAsync(TSearch search);
        Task<T?> GetByIdAsync(int id);
    }
}
