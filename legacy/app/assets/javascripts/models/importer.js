class Importer {

  constructor(content) {
    this.content = content;
    this.arrange();
    this.find_existing();
  }

  arrange() {

    this.operation_types = [];
    this.libraries = [];
    this.sample_types = [];
    this.object_types = [];   
    this.config = this.content.config;

    aq.each(this.content.components, member => {
      if ( member.library ) {
        this.libraries.push(member.library);        
      } else {
        this.operation_types.push(member.operation_type);
        aq.each(member.sample_types, st => {
          if ( aq.where(this.sample_types, est => est.name == st.name ).length == 0 ) {
            this.sample_types.push(st)
          }
        });
        aq.each(member.object_types, ot => {
          if ( aq.where(this.object_types, eot => eot.name == ot.name ).length == 0 ) {
            this.object_types.push(ot)
          }
        });        
      }
    });

    return this;

  }

  find_existing_aux(components, model) {

    aq.each(components, comp => {

      let where = { name: comp.name };
      if ( comp.category ) {
        where.category = comp.category;
      }

      model
        .where(where)
        .then(existing_comps => {
          if ( existing_comps.length >= 1 ) {
            comp.existing = existing_comps[0];
          } else {
            comp.existing = null;
          }
          AQ.update();
        })

    });

  }

  find_existing() {
    this.find_existing_aux(this.operation_types, AQ.OperationType);
    this.find_existing_aux(this.libraries, AQ.Library);
    this.find_existing_aux(this.sample_types, AQ.SampleType);
    this.find_existing_aux(this.object_types, AQ.ObjectType);
  }

};


