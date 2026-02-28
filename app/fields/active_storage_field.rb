require "administrate/field/base"

class ActiveStorageField < Administrate::Field::Base
  def to_s
    data.attached? ? "Image attached" : "No image"
  end
end
