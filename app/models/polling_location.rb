class PollingLocation < ApplicationRecord
  belongs_to :riding
  has_many :polls

  validates :title, presence: true
  validates :address, presence: true
  validates :city, presence: true
  validates :postal_code, presence: true
  validate :validate_postal_code

  validates :title, uniqueness: { scope: [:address, :city, :postal_code, :riding_id], message: "Polling locations must be unique in each riding" }
  
  after_validation :format_postal_code

  def format_postal_code
    self.postal_code = self.postal_code.upcase.scan(/[A-Z0-9]/).insert(3, ' ').join if self.postal_code.present?
  end

  def validate_postal_code
    unless self.postal_code.present? && /[ABCEGHJKLMNPRSTVXY]\d[ABCEGHJ-NPRSTV-Z][ ]?\d[ABCEGHJ-NPRSTV-Z]\d/.match?(self.postal_code.upcase)
      errors.add(:postal_code, "must be valid")
    end
  end
end
