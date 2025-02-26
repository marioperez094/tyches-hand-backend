class ApplicationController < ActionController::API
  before_action :authenticate_player!

  private 

  def authenticate_player!
    header = request.headers['Authorization']

    unless header 
      return render json: { error: 'Unauthorized' }, status: :unauthorized
    end

    token = header.split(' ').last if header
    return unless token 

    decoded = JsonWebToken.decode(token)
    @current_player = Player.find_by(id: decoded[:player_id]) if decoded

    unless @current_player
      return render json: { error: 'Player not found.' }, status: :unauthorized
    end
  rescue JWT::DecodeError
    render json: { error: "Invalid token" }, status: :unauthorized
  end

  def current_player
    @current_player
  end
end
