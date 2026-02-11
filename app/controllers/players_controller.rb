class PlayersController < ApplicationController
  def new
    @profile = nil
  end

  def create
    @profile = PlayerProfileService.new(params[:player_name]).call
  rescue JSON::ParserError
    @error_message = "AIからの応答の解析中にエラーが発生しました。もう一度お試しください。"
  rescue OpenAI::Error
    @error_message = "AIサービスとの通信中にエラーが発生しました。"
  ensure
    render :new, status: :ok
  end
end
