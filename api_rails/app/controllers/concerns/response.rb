module Response
  def json_response(object, status = :ok, data = :data)
    render json: object, status: status, data: data
  end
end
