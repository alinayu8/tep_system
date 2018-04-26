class Order < ApplicationRecord
  before_validation :set_dates

  belongs_to :user

  if sync_to_salesforce? then 
    belongs_to :teacher, foreign_key: :teacher_id, primary_key: :sfid
  else 
    belongs_to :teacher
  end
  
  has_many :order_items
  has_many :items, through: :order_items
  
  #allow orderitems to be nested within orders
  accepts_nested_attributes_for :order_items, reject_if: ->(oi) { oi[:quantity].blank? }

  # ####### COMMENT OUT IF RUNNING LOCALLY #######
  # # this item is synced to Salesforce POS Transactions using Heroku Connect
  # self.table_name = "salesforce.contact"
  # self.primary_key = "sfid"
  # alias_attribute :first_name, :firstname
  # alias_attribute :last_name, :lastname
  # alias_attribute :school_id, :accountid
  # # alias_attribute :email, :email
  # # alias_attribute :phone, :phone

  # # filter POS Transactions for Incoming POS Transactions 
  # Teacher.where("title NOT ILIKE ? OR title IS NULL", "%teacher%").delete_all
  # ##############################################

  #Validations
  validates_presence_of :user, :teacher
  validates_date :shopping_date, on_or_before: lambda { Date.current }, allow_blank: true
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

  #Methods
  def self.set_uploaded
    self.not_uploaded.update_all(:uploaded => true)
  end
  
  # def self.to_csv
  #   attributes = %w{teacher_id  shopping_date uploaded}

  #   CSV.generate(headers: true) do |csv|
  #     csv << attributes

  #     all.each do |order|
  #       csv << attributes.map{ |attr| order.send(attr) }
  #     end
  #   end
  # end

  private 
  # set date_entered to today and shopping_date to today if not given
  def set_dates 
    if self.date_entered.nil?
      self.date_entered = Date.current
    end 
    if self.shopping_date.nil?
      self.shopping_date = self.date_entered
    end
    return true
  end
end
