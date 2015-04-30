class Team < ActiveRecord::Base
  # get modules to help with some functionality
  include QuizHelpers::Validations
  include Activeable
  
  #Relationships
  belongs_to :organization
  belongs_to :division
  has_many :student_teams
  has_many :students, through: :student_teams
  has_many :quiz_teams
  has_many :quizzes, through: :quiz_teams
  has_many :team_coaches
  has_many :coaches, through: :team_coaches

  accepts_nested_attributes_for :coaches
  accepts_nested_attributes_for :student_teams,
  reject_if: proc {|attr| attr['student_id'].blank?}
  accepts_nested_attributes_for :organization
  accepts_nested_attributes_for :team_coaches

  #Validations
  validates_presence_of :division_id, :name, :organization_id
  validates_uniqueness_of :name, case_sensitive: false

  
  #Scopes
  scope :alphabetical, -> {order("name")}
  scope :for_division, -> (division) { where(division_id: division.id)}

  #Methods
  validate :division_is_active_in_system
  validate :organization_is_active_in_system

  # Callbacks
  before_destroy :verify_that_there_are_no_scored_quizzes_for_team_this_year

  # Methods
  # Returns active teams that are not at capacity
  def self.not_at_capacity(organization=nil, division=nil)
    tmp = Array.new
    if organization && division #if organization and division are provided
      teams = organization.teams.active.alphabetical.for_division(division)
    elsif organization && !division #if only organization is provided
      teams = organization.teams.active.alphabetical
    else
      teams = Team.active.alphabetical.all
    end
    unless teams.empty?
      teams.each do |team|
        tmp << team if team.current_students.size < 5
      end    
    end 
    tmp
  end

  def scored_quizzes_this_year
    quizzes = Array.new
    scored_events = QuizYear.new.completed_events
    scored_events.each do |event|
      tmp = event.quizzes.select{|q| q.teams.include?(self)}
      quizzes << tmp
    end
    quizzes.flatten!
  end

  def current_students
    self.student_teams.current.map{|st| st.student}
  end

  private
  def division_is_active_in_system
    if(:division.nil? || :division.blank?)
      self.division = Division.all.where(:id => self.division_id)
    end
    is_active_in_system(:division)
  end

  def organization_is_active_in_system
    is_active_in_system(:organization)
  end

  def verify_that_there_are_no_scored_quizzes_for_team_this_year
    unless self.scored_quizzes_this_year.empty?
      errors.add(:base, "Team cannot be deleted because it has participated in scored quizzes.")
      return false
    end
    return true
  end

end
