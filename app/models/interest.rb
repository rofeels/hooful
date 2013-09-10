#encoding: utf-8
class Interest
  include Mongoid::Document
  include Mongoid::Timestamps
  field :name, type: String
  field :active, type: Integer
  field :code, type: String
  field :display, type: String
  field :order, type: Integer

  scope :activate, where(active: 1).asc(:order)

  def self.load(mCode)
    Interest.where(:code => mCode).first
  end

  def self.getIcon
	  @return_string = ""
    @interests = Interest.activate
    @interests.each do |interest|
      @return_string +="\n<li class=\"interest\"><a href=\"/c/#{interest.code}\">#{interest.name}</a></li>"
      end
    @return_string
  end

  def self.getMainIconOld
	  @return_string = ""
    @interests = Interest.activate
	  @interests.each do |interest|
      @count = Interest.count_category(interest.code)
		  @return_string +="\n<li class=\"interest #{interest.code}\" code=\"#{interest.code}\"><div class=\"title\">#{interest.name}</div><div class=\"wrap\"></div><div class=\"overwrap\"><div class=\"wrapfull\"></div><div class=\"wraptitle\">#{interest.name}</div><div class=\"wrapinfo\"><div class=\"wrapline\"><span class=\"icon like\"></span><span class=\"text\">#{@count[:person]}</span></div><div class=\"wrapline\"><span class=\"icon count\"></span><span class=\"text\">#{@count[:meet]}</span></div><div class=\"wrapline\"><span class=\"icon talk\"></span><span class=\"text\">#{@count[:talk]}</span></div></div><div class=\"wrapenter\"><a href=\"/c/#{interest.code}\">들어가기</a></div></div></li>"
    end
	  @return_string
  end

  def self.getMainIcon
	  @return_string = ""
    @interests = Interest.activate
	  @interests.each do |interest|
      @count = Interest.count_category(interest.code)
		  @return_string +="\n<li class=\"#{interest.display} interest #{interest.code}\" code=\"#{interest.code}\"><div class=\"title\">#{interest.name}<div class=\"arrow\"></div></div></li>"
    end
	  @return_string
  end

  def self.getIntroIcon
	  @return_string = ""
    @interests = Interest.activate
    @interests.each do |interest|
		  @return_string +="\n<li class=\"interest #{interest.code}\" code=\"#{interest.code}\"><div class=\"image\"></div></li>"
      end
    @return_string
  end

  def self.getIcon
	  @return_string = ""
    @interests = Interest.all
    @interests.each do |interest|
      @return_string +="\n<li class=\"interest #{interest.code}\" category=\"#{interest.code}\"><div class=\"title\">#{interest.name}</div><div class=\"wrap\"></div><div class=\"overwrap\"><div class=\"wrapfull\"><div class=\"wraptitle\">#{interest.name}</div></div></div></li>"
      end
    @return_string
  end

  def self.getIconRegister(cate)
	  @return_string = ""
    @interests = Interest.all
    @interests.each do |interest|
      @return_string +="\n<dl class=\"interest"+ (cate[interest.code].to_i == 1 ? " set":"") +"\" category=\"#{interest.code}\"><dt class=\"title\">#{interest.name}</dt><dd class=\"#{interest.code}\"><div class=\"wrap\"></div><div class=\"overwrap\"><div class=\"wrapfull\"><i class=\"check\"></i></div></div></dd></dl>"
      end
    @return_string
  end

  def self.getIconUser(cate)
	  @return_string = ""
    @interests = Interest.all
    @interests.each do |interest|
      @return_string +="\n<li class=\"interest #{interest.code}"+ (cate[interest.code].to_i == 1 ? " set":"") +"\" category=\"#{interest.code}\"><div class=\"title\">#{interest.name}</div><div class=\"wrap\"></div><div class=\"overwrap\"><div class=\"wrapfull\"></div><div class=\"wraptitle\">#{interest.name}</div></div></li>"
      end
    @return_string
  end

  def self.getIcon_nolink
	  @return_string = ""
    @interests = Interest.activate
    @interests.each do |interest|
      @return_string +="\n<li class=\"interest\"><i class=\"#{interest.code}\"></i>#{interest.name}</li>"
      end
    @return_string
  end

  def self.count_category(cate)
    @result = Hash.new

    @arrayS = Array.wrap(nil)
	  @arrayS += Array.wrap("mCategory" => /.*#{cate}.*/)
    @cmeet = Meet.where("$or" => @arrayS)
    @cGroup = 0
    @cPerson = 0

    @cmeet.each do |cmeet|
      cgroup = Group.where(:mCode => cmeet.mCode)
        cgroup.each do |group|
          @cGroup += GroupTalk.where(:group_id => group._id).count
        end
    end

    @cPerson = User.find(:all, :conditions=> ["category like ?", '%"'+cate+'":"1"%']).count

    @result[:meet] = @cmeet.count
    @result[:talk] = @cGroup
    @result[:person] = @cPerson
    @result
  end

end