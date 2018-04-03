class Order < ApplicationRecord
  accepts_nested_attributes_for :tasks, reject_if: ->(task) { task[:name].blank? }, allow_destroy: true
  #Relationships
  belongs_to :user
  belongs_to :teacher

  #Validations
  validates_presence_of :user, :teacher, :date_entered
  validates_date :shopping_date, on_or_before: lambda { Date.current }
  #validates_date :date_entered, on: lambda { Date.current }, on: :create #questionable
  validates_date :date_entered, on_or_before: lambda { Date.current }
  validates_date :date_entered, on_or_after: :shopping_date

  #Scopes
  scope :for_shopping_date, ->(date) { where(shopping_date: date) }
  scope :for_date_entered, ->(date) { where(date_entered: date) }
  scope :for_teacher, ->(teacher_id) { where(teacher_id: teacher_id) }
  scope :shop_chronological, -> { order(shopping_date: :desc ) } 
  scope :enter_chronological, -> { order(date_entered: :desc ) } 

  scope :uploaded, -> { where(uploaded: true) }
  scope :not_uploaded, -> { where(uploaded: false) }
end
