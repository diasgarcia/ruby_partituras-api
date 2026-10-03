class ApplicationController < ActionController::API
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  rescue_from ActiveRecord::RecordInvalid, with: :record_invalid
  rescue_from ActionController::ParameterMissing, with: :parameter_missing

  private

  def record_not_found
    render json: { message: "partitura não encontrada" }, status: :not_found
  end

  def record_invalid(exception)
    render json: {
      message: exception.record.errors.full_messages.to_sentence,
      errors: exception.record.errors.full_messages
    }, status: :bad_request
  end

  def parameter_missing(exception)
    render json: { message: exception.message }, status: :bad_request
  end
end
