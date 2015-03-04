module Contexts
  module QuizContexts

    def create_quizzes
      @quiz1 = FactoryGirl.create(:quiz)
      @quiz2 = FactoryGirl.create(:quiz, room_num: 2, round_num: 2)
      @quiz3 = FactoryGirl.create(:quiz, room_num: 3, division_id: 2, round_num: 3)
      @quiz4 = FactoryGirl.create(:quiz, event_id: 2, round_num: 4)
      @quiz_inactive = FactoryGirl.create(:quiz, active: false, round_num: 5)
      
    end
    
    def delete_quizzes
      @quiz1.delete
      @quiz2.delete
      @quiz3.delete
      @quiz4.delete
      @quiz_inactive.delete
    end
  
  end
end
