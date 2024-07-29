# frozen_string_literal: true

module JsonResponse
  def response_format(type, data, status)
    json_response = {
      status: type
    }.merge(data)

    render json: json_response, status:
  end
end
