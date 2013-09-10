#encoding: utf-8
class Upfile
  require 'RMagick'

  # aws accoutn data
  @@BUCKET = "hoofulimg"
  AWS::S3::DEFAULT_HOST.replace "s3-ap-northeast-1.amazonaws.com" 
  AWS::S3::Base.establish_connection!(
    :access_key_id     => 'AKIAIKNA32CMDL6KU2RA',
    :secret_access_key => 'HlKnKA9/etPNVOsAxFww/57YgGDDm9nYCURGjXnu'
  )

# 1. 파일업로드 - 공통
  def self.fileUpload(file,code,location)
    # filename and file setting
    split_name = file.original_filename.split(".")

    time_now = Time.now.strftime("%Y%m%d%H%M%S%L").to_s
    virtual_name = "#{time_now}_#{code}.#{split_name.last.downcase}"
    file_name = File.basename(file.original_filename).gsub(/[^\w._-]/, '')

    file_path = @@BUCKET.to_s + "/" + location
    AWS::S3::S3Object.store(virtual_name,file, file_path, :access => :public_read, 'Cache-Control' => 'max-age=604800')
    url = AWS::S3::S3Object.url_for(virtual_name, file_path, :authenticated => false)
    # editorpic , coverpic 은 thumb 없으므로 추가 코드가 필요 엄슴.

    thumb = Magick::Image.read(url).first
    case location
		when 'meetpic'
		  thumb = thumb.crop_resized(250, 250)
		  AWS::S3::S3Object.store(virtual_name.to_s,thumb.to_blob, file_path+"/thumb", :access => :public_read, 'Cache-Control' => 'max-age=604800')
		when 'userpic'
		  thumb = thumb.resize_to_fit(37, 37)
		  AWS::S3::S3Object.store(virtual_name.to_s,thumb.to_blob, file_path+"/thumb", :access => :public_read, 'Cache-Control' => 'max-age=604800')
		when 'coverpic'
		when 'editorpic'
		when 'tohooful'
    end

    filename = Hash.new
    filename[:name] = file_name
    filename[:vname] = virtual_name   
    return filename
  end
	

end
