class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
  $App_Name = "here is the global variable"
end
