# typed: true
# frozen_string_literal: true

module ApiHelper # included in API controllers

  def api_ok(obj)
    { "status": 200, "data": obj }
  end

  def api_error(errors)
    { "status": 400, "data": errors }
  end

end
