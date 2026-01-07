using AutoMapper;
using eFood.Services.Database;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eFood.Services.NarudzbeStateMachine
{
    public class ActiveNarudzbaState : BaseNarudzbaState
    {
        public ActiveNarudzbaState(EFoodContext context, IMapper mapper, IServiceProvider serviceProvider) : base(context, mapper, serviceProvider)
        {
        }

        public override async Task<Model.Narudzba> Hide(int id)
        {
            var set = _context.Set<Database.Narudzba>();
            var entity = await set.FindAsync(id);

            entity.StateMachine = "draft";

            await _context.SaveChangesAsync();
            return _mapper.Map<Model.Narudzba>(entity);
        }
        //public async Task<Model.Narudzba> Finish(int id)
        //{
        //    var set = _context.Set<Database.Narudzba>();
        //    var entity = await set.FindAsync(id);

        //    if (entity == null)
        //        throw new Exception("Narudzba ne postoji");

        //    entity.StateMachine = "sent";   
        //    entity.StatusNarudzbeId = 4;            

        //    await _context.SaveChangesAsync();
        //    return _mapper.Map<Model.Narudzba>(entity);
        //}
        public override async Task<List<string>> AllowedActions()
        {
            var list = await base.AllowedActions();
            list.Add("Hide");
            list.Add("Finish");
            return list;
        }
    }
}
