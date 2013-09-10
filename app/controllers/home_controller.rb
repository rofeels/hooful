class HomeController < ApplicationController

  def intro
	redirect_to "/home"
=begin
	if session[:user_id]
		redirect_to "/home"
	else
		@category_intro_icon = Interest.getIntroIcon
    @likes = LogInterest.allCount
    @meets = Meet.allCount
    @tmpIntro = ["4","9"]
		#@randNo = Random.rand(2)+3
    @randNo = @tmpIntro[rand(@tmpIntro.length)]
		render :layout => 'intro'
	end
=end
  end

  def index
    #@category_icon = Interest.getMainIcon
    @user = User.info(session[:user_id])
  end

  def search
    
  end

  def test
  @meet
	Meet.all.desc(:created_at).each do |meet|
	#meet.destroy
		@meet = "#{@meet} #{meet.mCode}"
	end
		
	render :text => Digest::SHA2.hexdigest("hooful5")

=begin    app = FbGraph::Application.new(FACEBOOK_KEY, :secret => FACEBOOK_SECRET)
    result = app.debug_token session[:user].fbauth
    @result = nil
    if result.error.nil?
      me = FbGraph::User.me(session[:user].fbauth).fetch
      #render :json => me.fetch.work[0].employer.name
      render :json => me.to_json
    else
      render :json => result.error
    end
=end
  end

  def fbtest
		render :layout => 'intro'
  end
end
