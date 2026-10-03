class PartiturasController < ApplicationController
  before_action :set_partitura, only: %i[show update destroy]

  # GET /partituras
  def index
    @partituras = Partitura.order(:id)
    render json: @partituras
  end

  # GET /partituras/:id
  def show
    render json: @partitura.as_json(detailed: true)
  end

  # POST /partituras
  def create
    @partitura = Partitura.create!(partitura_params)
    head :created
  end

  # PUT /partituras/:id
  def update
    @partitura.update!(partitura_params)
    head :no_content
  end

  # DELETE /partituras/:id
  def destroy
    @partitura.destroy!
    head :no_content
  end

  private

  def set_partitura
    @partitura = Partitura.find(params[:id])
  end

  def partitura_params
    if params[:partitura].present?
      params.require(:partitura).permit(:titulo, :autor, :arranjador, :bpm, :avaliacao, :tonalidade)
    else
      params.permit(:titulo, :autor, :arranjador, :bpm, :avaliacao, :tonalidade)
    end
  end
end
