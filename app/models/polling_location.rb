class PollingLocation < ApplicationRecord
  belongs_to :riding
  has_many :polls

  validates :title, presence: true
  validates :address, presence: true
  validates :city, presence: true
  validates :postal_code, presence: true
  validate :validate_postal_code

  validates :title, uniqueness: { scope: [:address, :city, :postal_code, :riding_id], message: "Polling locations must be unique in each riding" }
  validate :unique_poll_associations_within_riding

  after_validation :format_postal_code

  def format_postal_code
    self.postal_code = self.postal_code.upcase.scan(/[A-Z0-9]/).insert(3, ' ').join if self.postal_code.present?
  end

  def validate_postal_code
    unless self.postal_code.present? && /[ABCEGHJKLMNPRSTVXY]\d[ABCEGHJ-NPRSTV-Z][ ]?\d[ABCEGHJ-NPRSTV-Z]\d/.match?(self.postal_code.upcase)
      errors.add(:postal_code, "must be valid")
    end
  end

  def should_destroy?
    polls.empty?
  end

  private

  def unique_poll_associations_within_riding
    conflicting_locations = PollingLocation.where(riding_id: self.riding_id).where.not(id: self.id)
  
    conflicting_locations.each do |location|
      shared_polls = location.poll_ids & self.poll_ids
      if shared_polls.any?
        errors.add(:base, "Polling locations can't share the same poll within the same riding: #{shared_polls.join(', ')}")
      end
    end
  end
end
