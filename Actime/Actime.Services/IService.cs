using Actime.Model;
using Actime.Model.SearchObjects;

namespace Actime.Services
{
    public interface IService<T, TSearch> where T : class where TSearch : BaseSearchObject
    {
        Task<PagedResult<T>> Get(TSearch search);
        Task<T> GetById(int id);
    }
}
