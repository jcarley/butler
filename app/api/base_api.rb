class BaseApi < Grape::API
  helpers APIHelpers

  mount V1
end

