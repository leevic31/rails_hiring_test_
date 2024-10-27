class PollingLocationsController < ApplicationController
    before_action :set_riding

    def index
        @polling_locations = @riding.polling_locations.includes(:polls)
    end

    def update
        ActiveRecord::Base.transaction do
            params[:polling_locations].each do |id, location_params|
                polling_location = PollingLocation.find(id)
                poll_numbers = location_params[:poll_numbers].reject(&:blank?).flat_map { |num| num.split(',').map(&:strip) }
                polls = Poll.where(number: poll_numbers, riding_id: polling_location.riding_id)
                conflicting_poll_ids = find_conflicting_poll_ids(polls.pluck(:id), polling_location.riding_id, polling_location.id)

                if conflicting_poll_ids.any?
                    conflicting_locations = Poll.where(id: conflicting_poll_ids).includes(:polling_location).map do |poll|
                        poll.polling_location.title
                    end
                    error_message = "Polling locations can't share the same poll within the same riding. #{conflicting_locations.join(', ')} has this poll already. Remove the poll from this location in order to re-assign it."
                    polling_location.errors.add(:base, error_message)
                    raise ActiveRecord::RecordInvalid.new(polling_location)
                end

                polling_location.update!(polling_location_params(location_params.except(:poll_numbers)))
                polling_location.polls = polls

                polling_location.destroy if polling_location.should_destroy?
            end
        end

        redirect_to riding_polling_locations_path(@riding), notice: 'Polling locations successfully updated.'
    rescue ActiveRecord::RecordInvalid => e
        @polling_locations = @riding.polling_locations.includes(:polls)     
        flash[:alert] ||= e.record.errors.full_messages.join(", ")
        render :index, status: :unprocessable_entity
    end

    private

    def set_riding
        @riding = Riding.find(params[:riding_id])
    end

    def polling_location_params(location_params)
        location_params.permit(:title, :address, :city, :postal_code, poll_numbers: [])
    end

    def find_conflicting_poll_ids(new_poll_ids, riding_id, current_location_id)
        Poll.where(id: new_poll_ids)
            .joins(:polling_location)
            .where(polling_locations: { riding_id: riding_id })
            .where.not(polling_locations: { id: current_location_id })
            .pluck(:id)
    end
end
