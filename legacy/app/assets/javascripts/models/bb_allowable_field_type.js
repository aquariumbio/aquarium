AQ.AllowableFieldType.record_methods.upgrade = function() {
  if ( this.object_type ) {
    this.object_type = AQ.ObjectType.record(this.object_type);
  }
  if ( this.sample_type ) {
    this.sample_type = AQ.SampleType.record(this.sample_type);
  }
}