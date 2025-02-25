class ApplicationController < ActionController::API
  before_action :authenticate_player!

  private 

  def authenticate_player!
    header = request.headers['Authorization']
    token = header.split(' ').last if header
    decoded = JsonWebToken.decode(token)
    @current_player = Player.find(decoded[:player_id]) if decoded
  rescue ActiveRecord::RecordNotFound, JWT::DecodeError
    render json: { error: 'Unauthorized' }, status: :unauthorized
  end

  def current_player
    @current_player
  end
end
