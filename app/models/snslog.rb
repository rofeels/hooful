class Snslog
  include Mongoid::Document
  include Mongoid::Timestamps
  field :type, type: String
  
end

