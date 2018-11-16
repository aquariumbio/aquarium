class AqFile {

  constructor(content) {
    this.content = content;
    this.arrange();
  }

  arrange() {

    this.operation_types = [];
    this.libraries = [];
    this.sample_types = [];
    this.object_types = [];   

    aq.each(this.content, cat => {
      aq.each(cat, member => {
        if ( member.library ) {
          this.libraries.push(member.library);
        } else {
          this.operation_types.push(member.operation_type);
          aq.each(member.sample_types, st => this.sample_types.push(st));
          aq.each(member.object_types, ot => this.object_types.push(ot));
        }
      });
    })

    return this;

  }

};

