using Actime.Model.SearchObjects;
using Actime.Services.Database;
using Actime.Services.Interfaces;
using MapsterMapper;

namespace Actime.Services.Services
{
    public class BaseCrudService<T, TSearch, TEntity, TInsert, TUpdate> : BaseService<T, TSearch, TEntity>, ICrudService<T, TSearch, TInsert, TUpdate>
        where T : class
        where TSearch : BaseSearchObject
        where TEntity : class
        where TInsert : class
        where TUpdate : class
    {
        public BaseCrudService(ActimeContext context, IMapper mapper) : base(context, mapper)
        {
        }

        public async Task<bool> DeleteAsync(int id)
        {
            var entity = await _context.Set<TEntity>().FindAsync(id);
            if (entity == null)
                return false;

            var canBeDeleted = await OnDeleting(entity);
            if (!canBeDeleted)
                return false;

            _context.Set<TEntity>().Remove(entity);
            await _context.SaveChangesAsync();
            await OnDeleted(entity);

            return true;
        }

        protected virtual Task<bool> OnDeleting(TEntity entity) => Task.FromResult(true);

        protected virtual Task OnDeleted(TEntity entity) => Task.CompletedTask;

        public async Task<T> CreateAsync(TInsert request)
        {
            var entity = _mapper.Map<TEntity>(request);
            await OnCreating(entity, request);

            _context.Set<TEntity>().Add(entity);
            await _context.SaveChangesAsync();
            await OnCreated(entity);

            return _mapper.Map<T>(entity);
        }

        protected virtual Task OnCreating(TEntity entity, TInsert request) => Task.CompletedTask;

        protected virtual Task OnCreated(TEntity entity) => Task.CompletedTask;

        public async Task<T?> UpdateAsync(int id, TUpdate request)
        {
            var entity = await _context.Set<TEntity>().FindAsync(id);
            if (entity == null)
                return null;

            await OnUpdating(entity, request);

            _mapper.Map(request, entity);
            await _context.SaveChangesAsync();
            await OnUpdated(entity);

            return _mapper.Map<T>(entity);
        }

        protected virtual Task OnUpdating(TEntity entity, TUpdate request) => Task.CompletedTask;

        protected virtual Task OnUpdated(TEntity entity) => Task.CompletedTask;
    }
}