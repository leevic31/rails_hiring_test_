require "test_helper"

class PollingLocationsControllerTest < ActionDispatch::IntegrationTest
    def setup
        @riding_one = ridings(:one)
        @polling_location_one = polling_locations(:one)
        @polling_location_two = polling_locations(:two)
        @polling_location_three = polling_locations(:three)
        @poll_assigned_to_polling_location_one = polls(:one)
        @unassigned_poll = polls(:unassigned)
        @poll_assigned_to_polling_location_three = polls(:three)
    end

    test "should not update polling location with duplicate title" do
        duplicate_attributes = {
            title: @polling_location_two.title,
            address: "new address",
            city: "new city",
            postal_code: "new postal code",
            poll_numbers: @polling_location_one.polls.map(&:number)
        }

        assert_no_difference 'PollingLocation.count' do
            patch riding_polling_locations_path(@riding_one), params: {
                polling_locations: {
                    @polling_location_one.id => duplicate_attributes
                }
            }
        end

        assert_response :unprocessable_entity
    end

    test "should update polling location with unique attributes" do
        unique_attributes = {
            title: "new title",
            address: "new address",
            city: "new city",
            postal_code: "a1a1a1",
            poll_numbers: @polling_location_one.polls.map(&:number)
        }

        patch riding_polling_locations_path(@riding_one), params: {
            polling_locations: {
                @polling_location_one.id => unique_attributes
            }
        }

        assert_redirected_to riding_polling_locations_path(@riding_one)
        @polling_location_one.reload

        assert_equal 'new title', @polling_location_one.title
    end

    test "should assign an unassigned poll with a polling location" do
        assert_nil @unassigned_poll.polling_location_id
        
        new_attributes = {
            title: @polling_location_one.title,
            address: @polling_location_one.address,
            city: @polling_location_one.city,
            postal_code: @polling_location_one.postal_code,
            poll_numbers: [@unassigned_poll.number]
        }

        patch riding_polling_locations_path(@riding_one), params: {
            polling_locations: {
                @polling_location_one.id => new_attributes
            }
        }

        @polling_location_one.reload
        @unassigned_poll.reload

        assert_includes @polling_location_one.polls, @unassigned_poll
        assert_equal @polling_location_one.id, @unassigned_poll.polling_location_id
    end

    test "should not allow duplicate poll associations within the same riding" do
        duplicate_poll = @poll_assigned_to_polling_location_three
        new_attributes = {
            title: @polling_location_one.title,
            address: @polling_location_one.address,
            city: @polling_location_one.city,
            postal_code: @polling_location_one.postal_code,
            poll_numbers: [duplicate_poll.number]
        }

        patch riding_polling_locations_path(@riding_one), params: {
            polling_locations: {
                @polling_location_one.id => new_attributes
            }
        }
        
        assert_response :unprocessable_entity
        assert_template :index
        assert_not_empty flash[:alert]
    end
end
