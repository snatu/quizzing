class Coach < ActiveRecord::Base
  # get modules to help with some functionality
  include QuizHelpers::Validations
  include Activeable

  #Relationships
  belongs_to :user  # note that singular relation needs to be written as singular
  belongs_to :organization
  has_many :team_coaches
  has_many :teams, through: :team_coaches

  # Allow user to be nested within coach
  accepts_nested_attributes_for :user, reject_if: ->(user) { user[:username].blank? }, allow_destroy: true


  # validations 
  validates_presence_of :first_name, :last_name
  validates_format_of :phone, with: /\A(\d{10}|\(?\d{3}\)?[-. ]\d{3}[-.]\d{4})\z/, allow_nil: :true, message: "should be 10 digits (area code needed) and delimited with dashes only"
  validate :organization_is_active_in_system, on: :create

  # scopes
  scope :alphabetical, -> {order("last_name","first_name")}
  scope :active, -> {where(active: true)}
  scope :inactive, -> {where(active: false)}

  
  # callbacks
  before_save :reformat_phone
  before_destroy :is_never_destroyable
  before_update :deactive_user_if_coach_made_inactive

  # methods
  def name
    return "#{last_name}, #{first_name}"
  end

  def proper_name
    return "#{first_name} #{last_name}"
  end

  private
  def organization_is_active_in_system
    is_active_in_system(:organization)
  end

  def user_is_active_in_system
    is_active_in_system(:user)
  end

  def deactive_user_if_coach_made_inactive
    if !self.active && !self.user.nil?
      self.user.active = false
      self.user.save
    end
  end

end
