class ApplicationController < ActionController::API
   include Response

   def not_found(exception)
        json_response({ status: 404, "#{exception.message}": "page not found"})
   end
end
