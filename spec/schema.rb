ActiveRecord::Schema.define(:version => 0) do
  create_table :people, :force => true do |t|
    t.string  :full_name
    t.integer :type_id
    t.integer :special_type_id
  end

  create_table :person_types, :force => true do |t|
    t.string :type_name
    t.string :special_person_type
  end
end
