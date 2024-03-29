class StudentsController < ApplicationController
  before_action :set_student, only: [:show, :edit, :update, :destroy, :toggle]

  # GET /students
  # GET /students.json
  def index
    if(current_user.role == "coach")
      @students = current_user.coach.organization.students
    else
      @students = Student.all
    end
    @juniors = IndivStanding.for_juniors.map{|j| j.student}.sort_by! {|n| n.last_name}
    @seniors = IndivStanding.for_seniors.map{|j| j.student}.sort_by! {|n| n.last_name}
    @seniorb = IndivStanding.for_seniorb.map{|j| j.student}.sort_by! {|n| n.last_name}
    @junior_standings = IndivStanding.for_juniors(5)
    @senior_standings = IndivStanding.for_seniors(5)
    @seniorb_standings = IndivStanding.for_seniorb(5)
  end

  # GET /students/1
  # GET /students/1.json
  def show
    @student_division = @student.current_team.division
    @student_standing = IndivStanding.for_indiv(@student)
    if @student_standing.nil?
      @student_standing = NullIndivStanding.new
    end
    @quiz_year = QuizYear.new
    @year_quizzer = YearQuizzer.new(@student)
    @accuracy_percentage = (@year_quizzer.total_accuracy*100.0).round(1)
    @top_standings = IndivStanding.for_juniors(3)
    @year_quizzes = YearQuizzer.find_scored_events_for_year(@quiz_year).map
    @x_axis = @year_quizzes.map {|e| e.start_date.strftime('%b')} #x-values
    @events = @year_quizzes.map{ |e| EventQuizzer.new(@student, e)}
    @performance = @events.map{|p| p.total_points}
    # @top_student = IndivStanding.find_top_student(@student).first.student
    if @student_division.class != NullDivision
      @top_student = IndivStanding.find_top_student(@student).student
      @top_scores = EventSummary.for_division(@student_division).chronological.map{|e| e.max_student_points}
      @average_scores = EventSummary.for_division(@student_division).chronological.map{|e| e.avg_student_points}
      @top_four = IndivStanding.show_top_four(@student)
      @chart = LazyHighCharts::HighChart.new('graph') do |f|
        f.title(:text => "Student Performance")
        f.xAxis(:categories => @x_axis)
        f.series(:name => @student.proper_name + " Performance", :color => "#0d47a1", :yAxis => 0, :data => @performance)
        f.series(:name => "Top " + @student.current_team.division.name.capitalize[0...-1] + " Student Scores", :color => "#00bcd4", :yAxis => 0, :data => @top_scores)
        f.series(:name => "Average Score for Event", :yAxis => 0, :color => "#a6b8ba", :data => @average_scores)
        f.yAxis [
          {:title => {:text => "Quiz Scores", :margin => 70}, :min => 0, :max => 540 }
        ]
        f.chart({:defaultSeriesType=>"line"})
      end
    end 

    # @win_chart = LazyHighCharts::HighChart.new('graph') do |f|
    #   f.xAxis(:categories => @x_axis)
    #   f.series(:name => @student.first_name + " First Place Wins", :color => "#00bcd4", :data => @performance)
    #   f.yAxis [
    #     {:title => {:text => "Wins", :margin => 70}, :min => 0, :max => 540 }
    #   ]
    #   f.chart({:defaultSeriesType=>"column"})
    # end 
  end

  # GET /students/new
  def new
    if(current_user.role == "guest")
      redirect_to login_url and return
    end
    @student = Student.new
    # authorize! :new, @student
    @inactive_students = Student.inactive.alphabetical

  end

  # GET /students/1/edit
  def edit
    if(current_user.role == "guest")
      redirect_to login_url and return
    end
    #@organizations = Organization.active.all
    if @student.current_student_team.is_a? NullStudentTeam
      @student_team = StudentTeam.new
      #@collection = @student.current_organization.teams.active.alphabetical
      @collection = Team.not_at_capacity(@student, @student.current_organization)
      @team_id = -1
    else
      @student_team = @student.current_student_team
      #@collection = @student.current_organization.teams.active.alphabetical.for_division(@student.current_team.division)
      @collection = Team.not_at_capacity(@student, @student.current_organization, @student.current_team.division)
      @team_id = @student.current_team.id
    end
  end

  # POST /students
  # POST /students.json
  def create
    if(current_user.role == "guest")
      redirect_to login_url and return
    end
    @student = Student.new(student_params)
    # authorize! :create, @student
    if @student.save
      respond_to do |format|
        @student.add_to_organization(current_user)
        format.html { redirect_to @student, notice: "#{@student.name} has been created." }
        #format.json { render action: 'show', status: :created, location: @student }
        @active_teams = Team.all.active
        @divisions = Division.all.active
        format.js
      end
    else
        format.html { render action: 'new' }
        format.json { render json: @student.errors, status: :unprocessable_entity }
    end
  end
  


  # PATCH/PUT /students/1
  # PATCH/PUT /students/1.json
  def update
    if(current_user.role == "guest")
      redirect_to login_url and return
    end
    respond_to do |format|
      if @student.update(student_params)
        format.html { redirect_to @student, notice: 'Student was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @student.errors, status: :unprocessable_entity }
      end
    end
  end

  def toggle
    if(current_user.role == "guest")
      redirect_to login_url and return
    end
    @student_team = @student.current_student_team
    if params[:status] == 'inactive'
      @student_team.active = false
    else
      @student_team.active = true
    end
    @student_team.save!
    @student_team = nil
    @active_teams = Team.all.active
    @divisions = Division.all.active
  end

  # DELETE /students/1
  # DELETE /students/1.json
  def destroy
    if(current_user.role == "guest")
      redirect_to login_url and return
    end
    @student.destroy
    respond_to do |format|
      format.html { redirect_to students_url }
      format.json { head :no_content }
    end
  end

  def toggle_student
    @student = Student.find(params[:id])
    @student.active = params[:active] unless params[:active].nil?
    @student.save!
    @junior_students = IndivStanding.for_juniors.map{|j| j.student}.sort_by! {|n| n.first_name}
    @senior_students = IndivStanding.for_seniors.map{|j| j.student}.sort_by! {|n| n.first_name}
    @seniorb_students = IndivStanding.for_seniorb.map{|j| j.student}.sort_by! {|n| n.first_name}
    @changed = IndivStanding.find_by("student_id = ?", @student.id).division_id
  end

  # def create_student_team
    
  # end

  # def update_student_team
    
  # end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_student
      @student = Student.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def student_params
      params.require(:student).permit(:first_name, :last_name, :grade, :is_captain, :active, :organization_ids, :team_id)
    end
end
