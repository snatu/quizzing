module Contexts
  module QuizContexts

    def create_quizzes
      @quiz1 = FactoryGirl.create(:quiz)
      @quiz2 = FactoryGirl.create(:quiz, room_num: 2)
      @quiz3 = FactoryGirl.create(:quiz, room_num: 3, division_id: 2)
      @quiz4 = FactoryGirl.create(:quiz, event_id: 2, round_num: 2)
      @quiz_inactive = FactoryGirl.create(:quiz, active: false)
      
    end
    
    def destroy_quizzes
      @quiz1.destroy
      @quiz2.destroy
      @quiz3.destroy
      @quiz4.destroy
      @quiz_inactive.destroy
    end
  
  end
end