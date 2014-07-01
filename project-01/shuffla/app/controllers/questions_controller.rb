class QuestionsController < ApplicationController
  def new
    # once the user has answered X questions, user will be redirected to the Game Summary page (stats)
    if Game.last.questions.count == 7
      @game_id = Game.last.id #pull Game ID for the following view to pull up statistics
      redirect_to game_path(id:@game_id)
    else
      @game = Game.where(:user_id => @current_user.id).last

      @artists = RSpotify::Artist.find(Game.artist_id)
      raise params.inspect
      @selected_artist = @artists.first
      @selected_artist_uri = @selected_artist.uri.gsub!('spotify:artist:','')

      @tracks_array = @selected_artist.top_tracks(:US)
      @choices_tracks = []
      @choices_tracks = @tracks_array.sample(4)
      @selected_track = @choices_tracks.sample

      @question = Question.new
      @question.save

      @question_id = @question.id # Pass current object's ID into an instance variable to be accessible in the Create view
    end
  end

  def create 
    @question = Question.find params[:question_id]
    @question.game_id = params[:game_id]
    @question.finish_at = Time.now
    if params[:answer_selection] == params[:answer]
      @question.correct = true 
    else
      @question.correct = false 
    end
    @question.duration = @question.finish_at - @question.created_at
    @question.save

    redirect_to new_question_path
  end

  private

  def question_params
    params.require(:question).permit(:correct, :artist_id, :finish_at)
  end

  def prefix_chopper(uri)
    uri.gsub!('spotify:track:','')
  end
end