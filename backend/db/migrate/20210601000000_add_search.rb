# typed: false
class AddSearch < ActiveRecord::Migration[4.2]
  # Updates for search
  def change
    # TODO
    #
    # # TABLES
    #
    # samples
    #   search_text
    #   item_ids
    #
    # field_type_sorts
    #   id
    #   ftype (string, number, url, sample)
    #   sort (1, 2, 3, 4)
    #
    # # VIEWS
    #
    # # VIEW_SAMPLES => BASED ON SAMPLES
    # ;
    # create view view_samples as
    # select s.id, s.name, s.description, s.created_at, s.item_ids,
    # st.name as 'sample_type',
    # u.name as 'user_name', u.login,
    # ft.id as 'ft_id',
    # ft.ftype as 'ft_type',
    # fts.sort as 'ft_sort',
    # ft.name as 'ft_name',
    # fv.id as 'fv_id',
    # fv.value as 'fv_value',
    # fv.child_sample_id,
    # ss.name as 'child_sample_name'
    # from samples s
    # inner join sample_types st on st.id = s.sample_type_id
    # inner join users u on u.id = s.user_id
    # left join field_types ft on ft.parent_id = s.sample_type_id and ft.parent_class = 'SampleType'
    # left join field_type_sorts fts on fts.ftype = ft.ftype
    # left join field_values fv on fv.parent_id = s.id and fv.parent_class = 'Sample' and fv.field_type_id = ft.id
    # left join samples ss on ss.id = fv.child_sample_id
    # ;
    #
    # # VIEW_INVENTORIES => BASED ON SAMPLES
    #
    # create view view_inventories as
    # select s.id,
    # i.id as 'item_id', i.location as 'item_location', i.created_at as 'item_date',
    # ot.id as 'item_type_id', ot.name as 'item_type',
    # pa.collection_id, pa.row, pa.column,
    # ii.location as 'collection_location', ii.created_at as 'collection_date',
    # ott.id as 'collection_type_id', ott.name as 'collection_type'
    # from samples s
    # inner join items i on i.sample_id = s.id
    # inner join object_types ot on ot.id =i.object_type_id
    # left join part_associations pa on pa.part_id = i.id
    # left join items ii on ii.id = pa.collection_id
    # left join object_types ott on ott.id = ii.object_type_id
    # ;
    #
  end
end
