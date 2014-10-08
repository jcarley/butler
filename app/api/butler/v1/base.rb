module Butler
  module V1
    class Base < Grape::API
      mount Users
    end
  end
end

