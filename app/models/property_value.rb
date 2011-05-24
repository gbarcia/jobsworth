# encoding: UTF-8
###
# A PropertyValue is a potential value a property can take.
#
# Examples of PropertyValues include High, Medium, Low, In progress.
###
class PropertyValue < ActiveRecord::Base
  belongs_to  :property
  before_save :set_position
  
  has_many  :score_rules, 
            :as         => :controlled_by,
            :after_add  => :update_tasks_score

  has_many  :task_property_values,
            :foreign_key  => :property_value_id
  
  has_many  :tasks, 
            :through      => :task_property_values,
            :foreign_key  => :property_value_id,
            :class_name   => 'Task'

  ###
  # Returns an int to use for sorting tasks with
  # this property value.
  ###
  def sort_rank
    @sort_rank ||= (property.property_values.length - property.property_values.index(self))
  end

  def to_html
    src, val = ERB::Util.h(icon_url), ERB::Util.h(value)
    if self.icon_url.present?
      return "<img src='#{src}' class='tooltip' alt='#{val}' title='#{val}'/>".html_safe
    else
      return val
    end
  end

  def to_s
    value
  end

  #for tasklist grouping purpose (sort group by position)
  def position_to_s
    "0" * (4 - position.to_s.size) + position.to_s
  end

  private

  def update_tasks_score(new_score_rule)
    open_tasks = tasks.where(:status => AbstractTask::OPEN)
    open_tasks.each do |task| 
      task.update_score_with new_score_rule
      task.save
    end
  end

  def set_position
    return true unless self.position.nil?
    self.position = property.property_values.length
  end
end





# == Schema Information
#
# Table name: property_values
#
#  id          :integer(4)      not null, primary key
#  property_id :integer(4)
#  value       :string(255)
#  color       :string(255)
#  default     :boolean(1)
#  position    :integer(4)      not null
#  created_at  :datetime
#  updated_at  :datetime
#  icon_url    :string(1000)
#
# Indexes
#
#  index_property_values_on_property_id  (property_id)
#

