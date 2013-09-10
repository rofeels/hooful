class LogInterest
  include Mongoid::Document
  include Mongoid::Timestamps
  field :userid, type: String
  field :interest, type: Hash
  field :state, type: Integer
  
  # 1. 로그생성 - DB입력
  def self.savelog(userid,interestchange)
    LogInterest.where(:userid => userid).update_all(:state => 0)
    create! do |interest|		
        interest.userid = userid
        interest.interest = interestchange
        interest.state = 1
    end
  end

  def self.allCount
    @Interest = Interest.where(active: 1).asc(:_id)
    @total = 0
    @Interest.each do |aint|
        @total += LogInterest.where("state" => "1", "interest.#{aint.code}" =>"1").count
    end
    @total
  end
end
