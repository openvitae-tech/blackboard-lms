class AddNeoAiModuleIdToCourseModules < ActiveRecord::Migration[8.0]
  def change
    add_column :course_modules, :neo_ai_module_id, :string
  end
end
