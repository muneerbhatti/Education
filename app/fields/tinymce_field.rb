require "administrate/field/base"

class TinymceField < Administrate::Field::Base
  def to_s
    data.to_s
  end
end
