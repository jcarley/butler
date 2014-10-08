module Butler
  module V1
    class Users < Grape::API

      resource :users do
        params do
          group :contribution, type: Hash do
            requires :file_name
            requires :file_path
            optional :buckets, type: Array
            group :foo, type: Hash do
              requires :bar
            end
          end
        end
        post do

          # strong_params = StrongParameters.new(route, :contribution)
          # attrs = strong_params.permit!(params)

          attrs = attributes_for_group(:contribution)
          puts "Attrs: #{attrs}"

        end
      end
    end
  end
end
