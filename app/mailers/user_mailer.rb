# coding : utf-8
#encoding: UTF-8
require 'aws/ses'
class UserMailer < ActionMailer::Base
#  default :from => "hooful@hooful.com"
  #not yet
  def welcome_email(user, url)
    @time = Time.now
		timeN = @time
    @time = @time.year.to_s + ". "+@time.month.to_s + ". "+@time.day.to_s
		@time_lmt = "인증키는 " + timeN.year.to_s + ". "+timeN.month.to_s + ". "+(timeN.day.to_i+1).to_s + " " + timeN.hour.to_s + "시 " + (timeN.min.to_i-1).to_s + "분까지 유효합니다."
    @user = user
    @url  = url
#    mail(:from => "hooful@hooful.com", :to => user.userid, :subject => "Check this email to activate your Hooful account") do |format|
=begin
    mail(:from => "hooful@hooful.com", :to => user.userid, :subject => "후풀 인증 메일 입니다! :)") do |format|
		format.html {
			render :layout => 'welcome_email'
		}
		end
=end
		ses = AWS::SES::Base.new(
			:access_key_id     => 'AKIAIKNA32CMDL6KU2RA',
			:secret_access_key => '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'
		)
		template = File.read(Rails.root.join('app','views','layouts','welcome_email.html.erb'))
		template.gsub!(/\{TIME}+/, @time.to_s)
		template.gsub!(/\{USERNAME}+/, @user.name.to_s)
		template.gsub!(/\{TIME_LIMIT}+/, @time_lmt.to_s)
		template.gsub!(/\{URL}+/, @url.to_s)
#		m = Mail.new( :to        => user.userid, :from => '"Hooful" <hooful@hooful.com>', :html_body => template)
#		ses.send_raw_email(m)
#=begin
		ses.send_email :to        => user.userid,#'jon@example.com',
             :source    => '"Hooful" <hooful@hooful.com>',
						 :from => '"Hooful" <hooful@hooful.com>',
						 :return_path => 'hooful@hooful.com',
						 :reply_to => 'hooful@hooful.com',
             :subject   => '후풀 인증 메일 입니다.',
             :html_body => template
#=end
  end

  #send verification email : password
  def change_password(user, url)
    @time = Time.now
    @time = @time.year.to_s + ". "+@time.month.to_s + ". "+@time.day.to_s
    @user = user
    @url  = url

#    mail(:from => "hooful@hooful.com", :to => user.userid, :subject => "You requested a new Hooful password") do |format|
=begin
    mail(:from => "hooful@hooful.com", :to => user.userid, :subject => "후풀 비밀번호 변경 메일입니다 :)") do |format|
		format.html {
			render :layout => 'change_password'
		}
		end
=end
		ses = AWS::SES::Base.new(
			:access_key_id     => 'AKIAIKNA32CMDL6KU2RA',
			:secret_access_key => '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'
		)
		template = File.read(Rails.root.join('app','views','user_mailer','change_password.html.erb'))
		template.gsub!(/\{TIME}+/, @time.to_s)
		template.gsub!(/\{USERNAME}+/, @user.name.to_s)
		#template.gsub!(/\{TIME_LIMIT}+/, @time_lmt.to_s)
		template.gsub!(/\{URL}+/, @url.to_s)
#		m = Mail.new( :to        => user.userid, :from => '"Hooful" <hooful@hooful.com>', :html_body => template)
#		ses.send_raw_email(m)
#=begin
		ses.send_email :to        => user.userid,#'jon@example.com',
             :source    => '"Hooful" <hooful@hooful.com>',
						 :from => '"Hooful" <hooful@hooful.com>',
						 :return_path => 'hooful@hooful.com',
						 :reply_to => 'hooful@hooful.com',
             :subject   => '후풀 비밀번호 변경 메일입니다.',
             :html_body => template
  end
end
