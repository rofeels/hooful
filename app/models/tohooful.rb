#encoding: utf-8
class Tohooful
  include Mongoid::Document
  include Mongoid::Timestamps
  field :title, type: String
  field :type, type: String
  field :article, type: String
  field :email, type: String
  field :attach, type: String
  field :userid, type: String
  field :answer, type: String
  field :answerTime, type: String
	field :userAgent, type: String

  def self.create_question(params)
		@filename = nil
		if params[:attach]
			tmp = Upfile.fileUpload(params[:attach],"tohooful",'tohooful')
			@filename = tmp[:vname]
		end
    create! do |ask|
			#Notification.send("hooful_ask", params[:userid], "")
      ask.title = params[:title]
			ask.article = params[:article].to_s.gsub(/\n/, '<br>')
#      ask.article = params[:article]
      ask.email = params[:email]
      ask.type = "question"
      ask.userid = params[:userid]
      ask.attach = @filename.to_s#params[:attach]
      ask.answer = nil
      ask.answerTime = "답변대기중"
			ask.userAgent = params[:userAgent]
    end
  end

	def self.answer_question(params)
		@question = Tohooful.find(params[:qid])
		if @question
			@question.answer = params[:articleAdmin].to_s.gsub(/\n/, '<br>')
			@question.answerTime = Time.now.to_s[0..10]
			if @question.save
				Notification.send("customer_inquiry", @question.userid,"","")
				true
			else
				false
			end
		else
			false
		end

	end
  def self.load
	  meet = all.desc(:_id)
  end

  def self.get_question_detail(mcode)
	  review = Tohooful.where(:_id => mcode).first
  end
end
