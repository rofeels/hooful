#encoding: utf-8
class Zipcode < ActiveRecord::Base
  attr_accessible :beopjeongdong_code, :sido, :sigungu, :eupmyeondong, :ri, :is_san, :jibun_major, :jibun_minor, :doro_code, :doro_name, :is_underground, :building_no_major, :building_no_minor, :building_name, :building_name_2, :building_management_no, :eupmyeondong_serial, :hangjeongdong_code, :hangjeondong_name
  
  def self.search_dong(dong)
  	Zipcode.group("sigungu").where("eupmyeondong like ?", "%#{dong}%").order("sido ASC")
  end
  
end
