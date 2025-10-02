using Actime.Model.Common;
using Actime.Model.SearchObjects;
using Actime.Services.Database;
using Actime.Services.Interfaces;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;

namespace Actime.Services.Services
{
    public class BaseService<T, TSearch, TEntity> : IService<T, TSearch> where T : class where TSearch : BaseSearchObject, new() where TEntity : class
    {
        protected readonly ActimeContext _context;
        protected readonly IMapper _mapper;

        public BaseService(ActimeContext context, IMapper mapper)
        {
            _context = context ?? throw new ArgumentNullException(nameof(context));
            _mapper = mapper ?? throw new ArgumentNullException(nameof(mapper));
        }

        public virtual async Task<PagedResult<T>> GetAsync(TSearch search)
        {
            search ??= new TSearch();

            var query = _context.Set<TEntity>().AsQueryable();
            query = ApplyFilter(query, search);
            query = ApplySorting(query, search);

            int? totalCount = search.IncludeTotalCount ? await query.CountAsync() : null;

            if (!search.RetrieveAll)
            {
                if (search.Page.HasValue && search.PageSize.HasValue)
                {
                    //NOTE: Skip - 1, or not? Depends on whether the page is 0 or 1 based.
                    int skip = search.Page.Value * search.PageSize.Value;
                    query = query.Skip(skip).Take(search.PageSize.Value);
                }
                else if (search.PageSize.HasValue)
                {
                    query = query.Take(search.PageSize.Value);
                }
            }

            var list = await query.ToListAsync();
            var result = _mapper.Map<List<T>>(list);

            return new PagedResult<T>
            {
                Items = result,
                TotalCount = totalCount ?? result.Count
            };
        }

        protected virtual IQueryable<TEntity> ApplyFilter(IQueryable<TEntity> query, TSearch search)
        {
            return query;
        }

        protected virtual IQueryable<TEntity> ApplySorting(IQueryable<TEntity> query, TSearch search)
        {
            if (!string.IsNullOrWhiteSpace(search.SortBy))
            {
                query = search.SortDescending
                    ? query.OrderByDescending(e => EF.Property<object>(e, search.SortBy))
                    : query.OrderBy(e => EF.Property<object>(e, search.SortBy));
            }

            return query;
        }

        public virtual async Task<T?> GetByIdAsync(int id)
        {
            var entity = await _context.Set<TEntity>().FindAsync(id);

            if (entity == null)
                return null;

            return _mapper.Map<T>(entity);
        }
    }
}