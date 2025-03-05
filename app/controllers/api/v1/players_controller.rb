class Api::V1::PlayersController < ApplicationController 
  skip_before_action :authenticate_player!, only: [:create, :login]

  def create
    # Verify reCAPTCHA token from front end
    unless RecaptchaV3Verifier.verify(params[:recaptcha_token], 0.5)
      puts params[:recaptcha_token]
      return render json: { error: "reCAPTCHA verification failed" }, status: :unauthorized
    end

    @player = Player.new(player_params)

    if @player.save
      token = JsonWebToken.encode(player_id: @player.id)
      render json: { success: true, token: token }, 
      status: :ok
    else
      render json: { error: @player.errors }, 
      status: :bad_request
    end
  end

  def login
    @player = Player.find_by(username: params[:player][:username])

    return render json: { error: 'Player not found.' },
    status: :not_found unless @player

    unless @player&.authenticate(params[:player][:password])
      return render json: {
        error: 'Invalid username or password.'
      }, status: :unauthorized 
    end

    token = JsonWebToken.encode(player_id: @player.id)

    render json: { success: true, token: token }
  end

  def logout
    if current_player.is_guest
      #Session expiration or logging out deletes 
      current_player.destroy!
      render json: { success: true }, 
      status: :ok
    else
      render json: { message: 'Logged out.' }, 
      status: :ok
    end
  end

  def authenticated
    render json: { authenticated: true }
  end

  def convert_to_registered
    return render json: { error: 'This account is already registered.' },
    status: :forbidden unless current_player.is_guest

    if params[:player][:password].length < 6
      return render json: { error: 'Password must be at least 6 characters long.' },
      status: :bad_request
    end

    begin
      current_player.update!(username: params[:player][:username], password: params[:player][:password], is_guest: false)
      
      render json: { success: true }, 
      status: :ok
    rescue ActiveRecord::RecordInvalid  => e
      render json: { error: current_player.errors.full_messages },
      status: :bad_request
    end
  end

  def update_password
    return render json: { error: "Invalid username or password." },
    status: :unauthorized unless current_player&.authenticate(params[:player][:password])

    begin
      current_player.update!(password: params[:player][:new_password])
      render json: { success: true },
      status: :ok
    rescue ArgumentError => e
      render json: { error: e.message },
      status: :bad_request
    end
  end

  def destroy
    return render json: { error: "Invalid username or password." }, 
    status: :unauthorized unless current_player&.authenticate(params[:player][:password])

    current_player.force_delete = true #Allows for registered player deletion 
    
    if current_player&.destroy
      render json: { success: true }
    else
      render json: { success: false }
    end
  end

  def show
    @player = current_player
    render 'api/players/show'
  end

  def index_leaderboard_by_rounds
    @players = Player.order(max_round_reached: :desc)
    render 'api/players/index_leaderboard',
    status: :ok
  end

  private

  def player_params
    params.require(:player).permit(:username, :password, :password_confirmation, :is_guest, :new_password )
  end
end
