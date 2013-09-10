class Fbevent
  include Mongoid::Document
  include Mongoid::Timestamps
  field :type, type: String
  field :userid, type: String
  field :fuid, type: String
  field :feed_id, type: String
  field :friends, type: String
  field :friends_cnt, type: String
  field :point, type: Integer
  validates_presence_of :type, :userid, :fuid, :message => "is empty"

  def self.load
		fb = all.desc(:_id)
  end

  def self.create_event(params)
    valid = true
    errormsg = ""
    fb = Fbevent.new
    fb.type = params[:type]
    fb.userid = params[:userid]
    fb.fuid = params[:fuid]
    fb.feed_id = params[:feed_id]
    fb.friends = params[:friends]
    fb.friends_cnt = params[:friends_cnt]
    fb.point = params[:point]

    if fb.valid?
        fb.save
      else
        valid = false
        returnmsg = ""
        fb.errors.full_messages.each do |msg|
          returnmsg += msg+"\n"
        end
        errormsg += returnmsg
      end
  end

  def self.ranking
	  map = %Q{
		function() {
      var feed, friend;
      feed = (this.type == '100') ? 60 : 0;
      friend = (this.type == '200') ? this.friends_cnt * 40 : 0;
      emit(this.userid, {feeds: feed, friends: friend});
	  }
    }
	  reduce = %Q{
		function(key, values) {
		 var result = {total:0, feed: 0, feed_cnt: 0, friend: 0, friend_cnt: 0};
		  values.forEach(function(value) {
			result.feed += value.feeds;
			result.friend += value.friends;
      result.total += (value.feeds+value.friends);
      if(value.feeds) result.feed_cnt += 1;
      if(value.friends) result.friend_cnt += 1;
		  });	
		  return result;
		}
	  }
	 
	  Fbevent.collection.map_reduce(map, reduce, {:out => {:inline => 1}, :raw => true})["results"]
  end

end
