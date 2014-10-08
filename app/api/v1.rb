class V1 < Grape::API

  prefix 'butler'

  version 'v1', using: :path
  format :json

  mount Butler::V1::Base
end
