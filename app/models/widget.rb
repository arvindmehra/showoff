class Widget
  include ActiveModel::Model

  attr_accessor :name, :kind, :description, :id
  validates :name, presence: true
  validates :kind, presence: true
  validates :description, presence: true

  def persisted?
    self.id.present?
  end

end
