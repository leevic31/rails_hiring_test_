require "test_helper"

class PollingLocationsControllerTest < ActionDispatch::IntegrationTest
    def setup
        @riding_one = ridings(:one)
        @polling_location_one = polling_locations(:one)
        @polling_location_two = polling_locations(:two)
    end

    test "should not update polling location with duplicate title" do
        duplicate_attributes = {
            title: @polling_location_two.title,
            address: "new address",
            city: "new city",
            postal_code: "new postal code"
        }

        assert_no_difference 'PollingLocation.count' do
            patch riding_polling_locations_path(@riding_one), params: {
                polling_locations: {
                    @polling_location_one.id => duplicate_attributes
                }
            }
        end

        assert_response :success
    end

    test "should update polling location with unique attributes" do
        unique_attributes = {
            title: "new title",
            address: "new address",
            city: "new city",
            postal_code: "a1a1a1"
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
end
