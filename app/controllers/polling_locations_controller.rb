class PollingLocationsController < ApplicationController
    before_action :set_riding

    def index
        @polling_locations = @riding.polling_locations.includes(:polls)
    end

    def update
        ActiveRecord::Base.transaction do
            params[:polling_locations].each do |id, location_params|
                polling_location = PollingLocation.find(id)
                polling_location.update!(location_params.permit(:title, :address, :city, :postal_code))
            end
        end
        redirect_to riding_polling_locations_path(@riding), notice: 'Polling locations successfully updated.'
    rescue ActiveRecord::RecordInvalid => e
        @polling_locations = @riding.polling_locations.includes(:polls)
        flash.now[:alert] = e.record.errors.full_messages.join(", ")
        render :index
    end

    private

    def set_riding
        @riding = Riding.find(params[:riding_id])
    end
end
