# This is an autogenerated file for dynamic methods in AllowableFieldType
# Please rerun rake rails_rbi:models[AllowableFieldType] to regenerate.

# typed: strong
module AllowableFieldType::ActiveRelation_WhereNot
  sig { params(opts: T.untyped, rest: T.untyped).returns(T.self_type) }
  def not(opts, *rest); end
end

module AllowableFieldType::GeneratedAttributeMethods
  extend T::Sig

  sig { returns(ActiveSupport::TimeWithZone) }
  def created_at; end

  sig { params(value: T.any(DateTime, Date, Time, ActiveSupport::TimeWithZone)).void }
  def created_at=(value); end

  sig { returns(T::Boolean) }
  def created_at?; end

  sig { returns(T.nilable(Integer)) }
  def field_type_id; end

  sig { params(value: T.nilable(Integer)).void }
  def field_type_id=(value); end

  sig { returns(T::Boolean) }
  def field_type_id?; end

  sig { returns(Integer) }
  def id; end

  sig { params(value: Integer).void }
  def id=(value); end

  sig { returns(T::Boolean) }
  def id?; end

  sig { returns(T.nilable(Integer)) }
  def object_type_id; end

  sig { params(value: T.nilable(Integer)).void }
  def object_type_id=(value); end

  sig { returns(T::Boolean) }
  def object_type_id?; end

  sig { returns(T.nilable(Integer)) }
  def sample_type_id; end

  sig { params(value: T.nilable(Integer)).void }
  def sample_type_id=(value); end

  sig { returns(T::Boolean) }
  def sample_type_id?; end

  sig { returns(ActiveSupport::TimeWithZone) }
  def updated_at; end

  sig { params(value: T.any(DateTime, Date, Time, ActiveSupport::TimeWithZone)).void }
  def updated_at=(value); end

  sig { returns(T::Boolean) }
  def updated_at?; end
end

module AllowableFieldType::GeneratedAssociationMethods
  extend T::Sig

  sig { returns(::FieldType) }
  def field_type; end

  sig { params(value: ::FieldType).void }
  def field_type=(value); end

  sig { returns(::ObjectType) }
  def object_type; end

  sig { params(value: ::ObjectType).void }
  def object_type=(value); end

  sig { returns(::SampleType) }
  def sample_type; end

  sig { params(value: ::SampleType).void }
  def sample_type=(value); end
end

module AllowableFieldType::CustomFinderMethods
  sig { params(limit: Integer).returns(T::Array[AllowableFieldType]) }
  def first_n(limit); end

  sig { params(limit: Integer).returns(T::Array[AllowableFieldType]) }
  def last_n(limit); end

  sig { params(args: T::Array[T.any(Integer, String)]).returns(T::Array[AllowableFieldType]) }
  def find_n(*args); end

  sig { params(id: Integer).returns(T.nilable(AllowableFieldType)) }
  def find_by_id(id); end

  sig { params(id: Integer).returns(AllowableFieldType) }
  def find_by_id!(id); end
end

class AllowableFieldType < ActiveRecord::Base
  include AllowableFieldType::GeneratedAttributeMethods
  include AllowableFieldType::GeneratedAssociationMethods
  extend AllowableFieldType::CustomFinderMethods
  extend T::Sig
  extend T::Generic

  sig { returns(AllowableFieldType::ActiveRecord_Relation) }
  def self.all; end

  sig { params(block: T.nilable(T.proc.void)).returns(AllowableFieldType::ActiveRecord_Relation) }
  def self.unscoped(&block); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.void)).returns(AllowableFieldType::ActiveRecord_Relation) }
  def self.select(*args, &block); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.void)).returns(AllowableFieldType::ActiveRecord_Relation) }
  def self.order(*args, &block); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.void)).returns(AllowableFieldType::ActiveRecord_Relation) }
  def self.reorder(*args, &block); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.void)).returns(AllowableFieldType::ActiveRecord_Relation) }
  def self.group(*args, &block); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.void)).returns(AllowableFieldType::ActiveRecord_Relation) }
  def self.limit(*args, &block); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.void)).returns(AllowableFieldType::ActiveRecord_Relation) }
  def self.offset(*args, &block); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.void)).returns(AllowableFieldType::ActiveRecord_Relation) }
  def self.joins(*args, &block); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.void)).returns(AllowableFieldType::ActiveRecord_Relation) }
  def self.where(*args, &block); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.void)).returns(AllowableFieldType::ActiveRecord_Relation) }
  def self.rewhere(*args, &block); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.void)).returns(AllowableFieldType::ActiveRecord_Relation) }
  def self.preload(*args, &block); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.void)).returns(AllowableFieldType::ActiveRecord_Relation) }
  def self.eager_load(*args, &block); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.void)).returns(AllowableFieldType::ActiveRecord_Relation) }
  def self.includes(*args, &block); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.void)).returns(AllowableFieldType::ActiveRecord_Relation) }
  def self.from(*args, &block); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.void)).returns(AllowableFieldType::ActiveRecord_Relation) }
  def self.lock(*args, &block); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.void)).returns(AllowableFieldType::ActiveRecord_Relation) }
  def self.readonly(*args, &block); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.void)).returns(AllowableFieldType::ActiveRecord_Relation) }
  def self.or(*args, &block); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.void)).returns(AllowableFieldType::ActiveRecord_Relation) }
  def self.having(*args, &block); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.void)).returns(AllowableFieldType::ActiveRecord_Relation) }
  def self.create_with(*args, &block); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.void)).returns(AllowableFieldType::ActiveRecord_Relation) }
  def self.distinct(*args, &block); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.void)).returns(AllowableFieldType::ActiveRecord_Relation) }
  def self.references(*args, &block); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.void)).returns(AllowableFieldType::ActiveRecord_Relation) }
  def self.none(*args, &block); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.void)).returns(AllowableFieldType::ActiveRecord_Relation) }
  def self.unscope(*args, &block); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.void)).returns(AllowableFieldType::ActiveRecord_Relation) }
  def self.except(*args, &block); end

  sig { params(args: T.untyped).returns(AllowableFieldType) }
  def self.find(*args); end

  sig { params(args: T.untyped).returns(T.nilable(AllowableFieldType)) }
  def self.find_by(*args); end

  sig { params(args: T.untyped).returns(AllowableFieldType) }
  def self.find_by!(*args); end

  sig { returns(T.nilable(AllowableFieldType)) }
  def self.first; end

  sig { returns(AllowableFieldType) }
  def self.first!; end

  sig { returns(T.nilable(AllowableFieldType)) }
  def self.second; end

  sig { returns(AllowableFieldType) }
  def self.second!; end

  sig { returns(T.nilable(AllowableFieldType)) }
  def self.third; end

  sig { returns(AllowableFieldType) }
  def self.third!; end

  sig { returns(T.nilable(AllowableFieldType)) }
  def self.third_to_last; end

  sig { returns(AllowableFieldType) }
  def self.third_to_last!; end

  sig { returns(T.nilable(AllowableFieldType)) }
  def self.second_to_last; end

  sig { returns(AllowableFieldType) }
  def self.second_to_last!; end

  sig { returns(T.nilable(AllowableFieldType)) }
  def self.last; end

  sig { returns(AllowableFieldType) }
  def self.last!; end

  sig { params(conditions: T.untyped).returns(T::Boolean) }
  def self.exists?(conditions = nil); end

  sig { params(args: T.untyped).returns(T::Boolean) }
  def self.any?(*args); end

  sig { params(args: T.untyped).returns(T::Boolean) }
  def self.many?(*args); end

  sig { params(args: T.untyped).returns(T::Boolean) }
  def self.none?(*args); end

  sig { params(args: T.untyped).returns(T::Boolean) }
  def self.one?(*args); end

  sig { params(attributes: T.untyped, block: T.untyped).returns(AllowableFieldType) }
  def self.create(attributes = nil, &block); end

  sig { params(attributes: T.untyped, block: T.untyped).returns(AllowableFieldType) }
  def self.create!(attributes = nil, &block); end

  sig { params(attributes: T.untyped, block: T.untyped).returns(AllowableFieldType) }
  def self.new(attributes = nil, &block); end
end

class AllowableFieldType::ActiveRecord_Relation < ActiveRecord::Relation
  include AllowableFieldType::ActiveRelation_WhereNot
  include AllowableFieldType::CustomFinderMethods
  include Enumerable
  extend T::Sig
  extend T::Generic
  Elem = type_member(fixed: AllowableFieldType)

  sig { returns(AllowableFieldType::ActiveRecord_Relation) }
  def all; end

  sig { params(block: T.nilable(T.proc.void)).returns(AllowableFieldType::ActiveRecord_Relation) }
  def unscoped(&block); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.void)).returns(AllowableFieldType::ActiveRecord_Relation) }
  def select(*args, &block); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.void)).returns(AllowableFieldType::ActiveRecord_Relation) }
  def order(*args, &block); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.void)).returns(AllowableFieldType::ActiveRecord_Relation) }
  def reorder(*args, &block); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.void)).returns(AllowableFieldType::ActiveRecord_Relation) }
  def group(*args, &block); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.void)).returns(AllowableFieldType::ActiveRecord_Relation) }
  def limit(*args, &block); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.void)).returns(AllowableFieldType::ActiveRecord_Relation) }
  def offset(*args, &block); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.void)).returns(AllowableFieldType::ActiveRecord_Relation) }
  def joins(*args, &block); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.void)).returns(AllowableFieldType::ActiveRecord_Relation) }
  def where(*args, &block); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.void)).returns(AllowableFieldType::ActiveRecord_Relation) }
  def rewhere(*args, &block); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.void)).returns(AllowableFieldType::ActiveRecord_Relation) }
  def preload(*args, &block); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.void)).returns(AllowableFieldType::ActiveRecord_Relation) }
  def eager_load(*args, &block); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.void)).returns(AllowableFieldType::ActiveRecord_Relation) }
  def includes(*args, &block); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.void)).returns(AllowableFieldType::ActiveRecord_Relation) }
  def from(*args, &block); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.void)).returns(AllowableFieldType::ActiveRecord_Relation) }
  def lock(*args, &block); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.void)).returns(AllowableFieldType::ActiveRecord_Relation) }
  def readonly(*args, &block); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.void)).returns(AllowableFieldType::ActiveRecord_Relation) }
  def or(*args, &block); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.void)).returns(AllowableFieldType::ActiveRecord_Relation) }
  def having(*args, &block); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.void)).returns(AllowableFieldType::ActiveRecord_Relation) }
  def create_with(*args, &block); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.void)).returns(AllowableFieldType::ActiveRecord_Relation) }
  def distinct(*args, &block); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.void)).returns(AllowableFieldType::ActiveRecord_Relation) }
  def references(*args, &block); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.void)).returns(AllowableFieldType::ActiveRecord_Relation) }
  def none(*args, &block); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.void)).returns(AllowableFieldType::ActiveRecord_Relation) }
  def unscope(*args, &block); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.void)).returns(AllowableFieldType::ActiveRecord_Relation) }
  def except(*args, &block); end

  sig { params(args: T.untyped).returns(AllowableFieldType) }
  def find(*args); end

  sig { params(args: T.untyped).returns(T.nilable(AllowableFieldType)) }
  def find_by(*args); end

  sig { params(args: T.untyped).returns(AllowableFieldType) }
  def find_by!(*args); end

  sig { returns(T.nilable(AllowableFieldType)) }
  def first; end

  sig { returns(AllowableFieldType) }
  def first!; end

  sig { returns(T.nilable(AllowableFieldType)) }
  def second; end

  sig { returns(AllowableFieldType) }
  def second!; end

  sig { returns(T.nilable(AllowableFieldType)) }
  def third; end

  sig { returns(AllowableFieldType) }
  def third!; end

  sig { returns(T.nilable(AllowableFieldType)) }
  def third_to_last; end

  sig { returns(AllowableFieldType) }
  def third_to_last!; end

  sig { returns(T.nilable(AllowableFieldType)) }
  def second_to_last; end

  sig { returns(AllowableFieldType) }
  def second_to_last!; end

  sig { returns(T.nilable(AllowableFieldType)) }
  def last; end

  sig { returns(AllowableFieldType) }
  def last!; end

  sig { params(conditions: T.untyped).returns(T::Boolean) }
  def exists?(conditions = nil); end

  sig { params(args: T.untyped).returns(T::Boolean) }
  def any?(*args); end

  sig { params(args: T.untyped).returns(T::Boolean) }
  def many?(*args); end

  sig { params(args: T.untyped).returns(T::Boolean) }
  def none?(*args); end

  sig { params(args: T.untyped).returns(T::Boolean) }
  def one?(*args); end

  sig { override.params(block: T.proc.params(e: AllowableFieldType).void).returns(T::Array[AllowableFieldType]) }
  def each(&block); end

  sig { params(level: T.nilable(Integer)).returns(T::Array[AllowableFieldType]) }
  def flatten(level); end

  sig { returns(T::Array[AllowableFieldType]) }
  def to_a; end

  sig do
    type_parameters(:U).params(
        blk: T.proc.params(arg0: Elem).returns(T.type_parameter(:U)),
    )
    .returns(T::Array[T.type_parameter(:U)])
  end
  def map(&blk); end
end

class AllowableFieldType::ActiveRecord_AssociationRelation < ActiveRecord::AssociationRelation
  include AllowableFieldType::ActiveRelation_WhereNot
  include AllowableFieldType::CustomFinderMethods
  include Enumerable
  extend T::Sig
  extend T::Generic
  Elem = type_member(fixed: AllowableFieldType)

  sig { returns(AllowableFieldType::ActiveRecord_AssociationRelation) }
  def all; end

  sig { params(block: T.nilable(T.proc.void)).returns(AllowableFieldType::ActiveRecord_AssociationRelation) }
  def unscoped(&block); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.void)).returns(AllowableFieldType::ActiveRecord_AssociationRelation) }
  def select(*args, &block); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.void)).returns(AllowableFieldType::ActiveRecord_AssociationRelation) }
  def order(*args, &block); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.void)).returns(AllowableFieldType::ActiveRecord_AssociationRelation) }
  def reorder(*args, &block); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.void)).returns(AllowableFieldType::ActiveRecord_AssociationRelation) }
  def group(*args, &block); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.void)).returns(AllowableFieldType::ActiveRecord_AssociationRelation) }
  def limit(*args, &block); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.void)).returns(AllowableFieldType::ActiveRecord_AssociationRelation) }
  def offset(*args, &block); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.void)).returns(AllowableFieldType::ActiveRecord_AssociationRelation) }
  def joins(*args, &block); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.void)).returns(AllowableFieldType::ActiveRecord_AssociationRelation) }
  def where(*args, &block); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.void)).returns(AllowableFieldType::ActiveRecord_AssociationRelation) }
  def rewhere(*args, &block); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.void)).returns(AllowableFieldType::ActiveRecord_AssociationRelation) }
  def preload(*args, &block); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.void)).returns(AllowableFieldType::ActiveRecord_AssociationRelation) }
  def eager_load(*args, &block); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.void)).returns(AllowableFieldType::ActiveRecord_AssociationRelation) }
  def includes(*args, &block); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.void)).returns(AllowableFieldType::ActiveRecord_AssociationRelation) }
  def from(*args, &block); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.void)).returns(AllowableFieldType::ActiveRecord_AssociationRelation) }
  def lock(*args, &block); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.void)).returns(AllowableFieldType::ActiveRecord_AssociationRelation) }
  def readonly(*args, &block); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.void)).returns(AllowableFieldType::ActiveRecord_AssociationRelation) }
  def or(*args, &block); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.void)).returns(AllowableFieldType::ActiveRecord_AssociationRelation) }
  def having(*args, &block); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.void)).returns(AllowableFieldType::ActiveRecord_AssociationRelation) }
  def create_with(*args, &block); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.void)).returns(AllowableFieldType::ActiveRecord_AssociationRelation) }
  def distinct(*args, &block); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.void)).returns(AllowableFieldType::ActiveRecord_AssociationRelation) }
  def references(*args, &block); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.void)).returns(AllowableFieldType::ActiveRecord_AssociationRelation) }
  def none(*args, &block); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.void)).returns(AllowableFieldType::ActiveRecord_AssociationRelation) }
  def unscope(*args, &block); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.void)).returns(AllowableFieldType::ActiveRecord_AssociationRelation) }
  def except(*args, &block); end

  sig { params(args: T.untyped).returns(AllowableFieldType) }
  def find(*args); end

  sig { params(args: T.untyped).returns(T.nilable(AllowableFieldType)) }
  def find_by(*args); end

  sig { params(args: T.untyped).returns(AllowableFieldType) }
  def find_by!(*args); end

  sig { returns(T.nilable(AllowableFieldType)) }
  def first; end

  sig { returns(AllowableFieldType) }
  def first!; end

  sig { returns(T.nilable(AllowableFieldType)) }
  def second; end

  sig { returns(AllowableFieldType) }
  def second!; end

  sig { returns(T.nilable(AllowableFieldType)) }
  def third; end

  sig { returns(AllowableFieldType) }
  def third!; end

  sig { returns(T.nilable(AllowableFieldType)) }
  def third_to_last; end

  sig { returns(AllowableFieldType) }
  def third_to_last!; end

  sig { returns(T.nilable(AllowableFieldType)) }
  def second_to_last; end

  sig { returns(AllowableFieldType) }
  def second_to_last!; end

  sig { returns(T.nilable(AllowableFieldType)) }
  def last; end

  sig { returns(AllowableFieldType) }
  def last!; end

  sig { params(conditions: T.untyped).returns(T::Boolean) }
  def exists?(conditions = nil); end

  sig { params(args: T.untyped).returns(T::Boolean) }
  def any?(*args); end

  sig { params(args: T.untyped).returns(T::Boolean) }
  def many?(*args); end

  sig { params(args: T.untyped).returns(T::Boolean) }
  def none?(*args); end

  sig { params(args: T.untyped).returns(T::Boolean) }
  def one?(*args); end

  sig { override.params(block: T.proc.params(e: AllowableFieldType).void).returns(T::Array[AllowableFieldType]) }
  def each(&block); end

  sig { params(level: T.nilable(Integer)).returns(T::Array[AllowableFieldType]) }
  def flatten(level); end

  sig { returns(T::Array[AllowableFieldType]) }
  def to_a; end

  sig do
    type_parameters(:U).params(
        blk: T.proc.params(arg0: Elem).returns(T.type_parameter(:U)),
    )
    .returns(T::Array[T.type_parameter(:U)])
  end
  def map(&blk); end
end

class AllowableFieldType::ActiveRecord_Associations_CollectionProxy < ActiveRecord::Associations::CollectionProxy
  include AllowableFieldType::CustomFinderMethods
  include Enumerable
  extend T::Sig
  extend T::Generic
  Elem = type_member(fixed: AllowableFieldType)

  sig { returns(AllowableFieldType::ActiveRecord_AssociationRelation) }
  def all; end

  sig { params(block: T.nilable(T.proc.void)).returns(AllowableFieldType::ActiveRecord_AssociationRelation) }
  def unscoped(&block); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.void)).returns(AllowableFieldType::ActiveRecord_AssociationRelation) }
  def select(*args, &block); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.void)).returns(AllowableFieldType::ActiveRecord_AssociationRelation) }
  def order(*args, &block); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.void)).returns(AllowableFieldType::ActiveRecord_AssociationRelation) }
  def reorder(*args, &block); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.void)).returns(AllowableFieldType::ActiveRecord_AssociationRelation) }
  def group(*args, &block); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.void)).returns(AllowableFieldType::ActiveRecord_AssociationRelation) }
  def limit(*args, &block); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.void)).returns(AllowableFieldType::ActiveRecord_AssociationRelation) }
  def offset(*args, &block); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.void)).returns(AllowableFieldType::ActiveRecord_AssociationRelation) }
  def joins(*args, &block); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.void)).returns(AllowableFieldType::ActiveRecord_AssociationRelation) }
  def where(*args, &block); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.void)).returns(AllowableFieldType::ActiveRecord_AssociationRelation) }
  def rewhere(*args, &block); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.void)).returns(AllowableFieldType::ActiveRecord_AssociationRelation) }
  def preload(*args, &block); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.void)).returns(AllowableFieldType::ActiveRecord_AssociationRelation) }
  def eager_load(*args, &block); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.void)).returns(AllowableFieldType::ActiveRecord_AssociationRelation) }
  def includes(*args, &block); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.void)).returns(AllowableFieldType::ActiveRecord_AssociationRelation) }
  def from(*args, &block); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.void)).returns(AllowableFieldType::ActiveRecord_AssociationRelation) }
  def lock(*args, &block); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.void)).returns(AllowableFieldType::ActiveRecord_AssociationRelation) }
  def readonly(*args, &block); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.void)).returns(AllowableFieldType::ActiveRecord_AssociationRelation) }
  def or(*args, &block); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.void)).returns(AllowableFieldType::ActiveRecord_AssociationRelation) }
  def having(*args, &block); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.void)).returns(AllowableFieldType::ActiveRecord_AssociationRelation) }
  def create_with(*args, &block); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.void)).returns(AllowableFieldType::ActiveRecord_AssociationRelation) }
  def distinct(*args, &block); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.void)).returns(AllowableFieldType::ActiveRecord_AssociationRelation) }
  def references(*args, &block); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.void)).returns(AllowableFieldType::ActiveRecord_AssociationRelation) }
  def none(*args, &block); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.void)).returns(AllowableFieldType::ActiveRecord_AssociationRelation) }
  def unscope(*args, &block); end

  sig { params(args: T.untyped, block: T.nilable(T.proc.void)).returns(AllowableFieldType::ActiveRecord_AssociationRelation) }
  def except(*args, &block); end

  sig { params(args: T.untyped).returns(AllowableFieldType) }
  def find(*args); end

  sig { params(args: T.untyped).returns(T.nilable(AllowableFieldType)) }
  def find_by(*args); end

  sig { params(args: T.untyped).returns(AllowableFieldType) }
  def find_by!(*args); end

  sig { returns(T.nilable(AllowableFieldType)) }
  def first; end

  sig { returns(AllowableFieldType) }
  def first!; end

  sig { returns(T.nilable(AllowableFieldType)) }
  def second; end

  sig { returns(AllowableFieldType) }
  def second!; end

  sig { returns(T.nilable(AllowableFieldType)) }
  def third; end

  sig { returns(AllowableFieldType) }
  def third!; end

  sig { returns(T.nilable(AllowableFieldType)) }
  def third_to_last; end

  sig { returns(AllowableFieldType) }
  def third_to_last!; end

  sig { returns(T.nilable(AllowableFieldType)) }
  def second_to_last; end

  sig { returns(AllowableFieldType) }
  def second_to_last!; end

  sig { returns(T.nilable(AllowableFieldType)) }
  def last; end

  sig { returns(AllowableFieldType) }
  def last!; end

  sig { params(conditions: T.untyped).returns(T::Boolean) }
  def exists?(conditions = nil); end

  sig { params(args: T.untyped).returns(T::Boolean) }
  def any?(*args); end

  sig { params(args: T.untyped).returns(T::Boolean) }
  def many?(*args); end

  sig { params(args: T.untyped).returns(T::Boolean) }
  def none?(*args); end

  sig { params(args: T.untyped).returns(T::Boolean) }
  def one?(*args); end

  sig { override.params(block: T.proc.params(e: AllowableFieldType).void).returns(T::Array[AllowableFieldType]) }
  def each(&block); end

  sig { params(level: T.nilable(Integer)).returns(T::Array[AllowableFieldType]) }
  def flatten(level); end

  sig { returns(T::Array[AllowableFieldType]) }
  def to_a; end

  sig do
    type_parameters(:U).params(
        blk: T.proc.params(arg0: Elem).returns(T.type_parameter(:U)),
    )
    .returns(T::Array[T.type_parameter(:U)])
  end
  def map(&blk); end

  sig { params(records: T.any(AllowableFieldType, T::Array[AllowableFieldType])).returns(T.self_type) }
  def <<(*records); end

  sig { params(records: T.any(AllowableFieldType, T::Array[AllowableFieldType])).returns(T.self_type) }
  def append(*records); end

  sig { params(records: T.any(AllowableFieldType, T::Array[AllowableFieldType])).returns(T.self_type) }
  def push(*records); end

  sig { params(records: T.any(AllowableFieldType, T::Array[AllowableFieldType])).returns(T.self_type) }
  def concat(*records); end
end
