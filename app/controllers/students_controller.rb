class StudentsController < ApplicationController
  before_action :set_student, only: [:show, :edit, :update, :destroy, :toggle]

  # GET /students
  # GET /students.json
  def index
    @students = Student.all
    @active_students = Student.active.alphabetical
    @inactive_students = Student.inactive.alphabetical
  end

  # GET /students/1
  # GET /students/1.json
  def show
    @student_teams = StudentTeam.all
    @organization_students = OrganizationStudent.all
  end

  # GET /students/new
  def new
    @student = Student.new
    @inactive_students = Student.inactive.alphabetical
  end

  # GET /students/1/edit
  def edit
    @organizations = Organization.active.all
  end

  # POST /students
  # POST /students.json
  def create
    @student = Student.new(student_params)

    respond_to do |format|
      if @student.save
        respond_to do |format|
          format.html { redirect_to @student, notice: "#{@student.name} has been created." }
          @active_teams = Team.all.active
          format.js
        # format.html { redirect_to @student, notice: 'Student was successfully created.' }
        # format.json { render action: 'show', status: :created, location: @student }
      end
      else
        format.html { render action: 'new' }
        format.json { render json: @student.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /students/1
  # PATCH/PUT /students/1.json
  def update
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
    @student_team = @student.current_student_team
    if params[:status] == 'inactive'
      @student_team.active = false
    else
      @student_team.active = true
    end
    @student_team.save!
    @student_team = nil
    @active_teams = Team.all.active
  end

  # DELETE /students/1
  # DELETE /students/1.json
  def destroy
    @student.destroy
    respond_to do |format|
      format.html { redirect_to students_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_student
      @student = Student.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def student_params
      params.require(:student).permit(:first_name, :last_name, :grade, :captain, :active, :team_id, :organization_id)
    end
end
