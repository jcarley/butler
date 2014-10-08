require 'rails_helper'

RSpec.describe Butler::V1::Users do

  describe "POST create" do

    it "creates a new user" do
      payload = {
        contribution: {
          file_name: 'sample.mov',
          file_path: 'path',
          status: 'in-progress',
          buckets: [{region: 'us-west', location: 'portland'}, {region: 'us-east', location: 'virgina'}],
          foo: {bar: 'yes', bash: 'shellshock' }
        }
      }
      post "api/butler/v1/users", payload
      puts response.body
    end
  end
end

