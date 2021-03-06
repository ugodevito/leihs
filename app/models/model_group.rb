# == Schema Information
#
# Table name: model_groups
#
#  id         :integer(4)      not null, primary key
#  type       :string(255)
#  name       :string(255)
#  created_at :datetime
#  updated_at :datetime
#  delta      :boolean(1)      default(TRUE)
#

class ModelGroup < ActiveRecord::Base

  has_many :model_links
  has_many :models, :through => :model_links, :uniq => true
  has_and_belongs_to_many :inventory_pools

  validates_presence_of :name

##################################################

  has_dag_links :link_class_name => 'ModelGroupLink'

  def self_and_descendant_ids
    ([id] + descendant_ids).flatten.uniq # OPTIMIZE flatten and unique really needed?
  end
  
  # NOTE is now chainable for named_scopes
  def all_models
    ids = descendant_ids << id
    models.by_categories(ids)
  end

  named_scope :roots, :joins => "LEFT JOIN model_group_links AS mgl ON mgl.descendant_id = model_groups.id",
                      :conditions => "mgl.descendant_id IS NULL"

################################################
# Edge Label
  def label(parent = nil)
    r = nil
    if parent
      l = links_as_descendant.first(:conditions => {:ancestor_id => parent.id})
      r = l.try(:label)
    end
    r || name
  end

  def set_label(parent, label)
    l = links_as_child.first(:conditions => {:ancestor_id => parent.id})
    l.update_attributes(:label => label) if l
  end

##################################################
# aliases for Ext.Tree

  def text(parent_id = 0)
    parent = (parent_id.to_i.zero? ? nil : ModelGroup.find(parent_id))
    # "#{label(parent)} (#{models.size})" # TODO intersection with current_user.models
    label(parent)
    #"#{label(parent)} (id #{id})" # TODO temp
  end
  
  def leaf
    leaf?
  end

################################################

  def to_s
    name
  end

  # compares two objects in order to sort them
  def <=>(other)
    self.name <=> other.name
  end


end

