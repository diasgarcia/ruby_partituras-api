class Partitura < ApplicationRecord
  TONALIDADES = %w[
    C C# D D# E F F# G G# A A# B
    Cm C#m Dm D#m Em Fm F#m Gm G#m Am A#m Bm
  ].freeze

  before_validation :set_data_criacao, on: :create

  validates :titulo, presence: { message: "título é obrigatório" }
  validates :autor, presence: { message: "autor é obrigatório" }
  validates :arranjador, presence: { message: "arranjador é obrigatório" }
  validates :bpm, numericality: { greater_than: 0, only_integer: true }, allow_nil: true
  validates :bpm, presence: { message: "bpm é obrigatório" }, on: :update
  validates :tonalidade, presence: { message: "tonalidade é obrigatória" }
  validates :tonalidade, inclusion: { in: TONALIDADES, message: "tonalidade inválida" }, if: -> { tonalidade.present? }
  validates :avaliacao, numericality: { greater_than_or_equal_to: 1, less_than_or_equal_to: 5, only_integer: true }, allow_nil: true

  validate :validar_duplicidade_na_criacao, on: :create
  validate :validar_duplicidade_na_atualizacao, on: :update

  # Normaliza valores que venham no formato do enum Java (ex: C_SHARP -> C#)
  def tonalidade=(value)
    normalized = value.is_a?(String) ? value.gsub("_SHARP", "#") : value
    super(normalized)
  end

  # Representação JSON preservando o contrato externo da API original
  def as_json(options = nil)
    options ||= {}
    if options[:detailed]
      {
        id: id,
        titulo: titulo,
        autor: autor,
        arranjador: arranjador,
        bpm: bpm,
        avaliacao: avaliacao,
        dataCriacao: data_criacao,
        tonalidade: tonalidade
      }
    else
      {
        id: id,
        titulo: titulo,
        autor: autor,
        avaliacao: avaliacao
      }
    end
  end

  private

  def set_data_criacao
    self.data_criacao ||= Date.current
  end

  # No Spring original (AdicionarPartituraValidator):
  # parituraRepository.existsByTitulo(...) && parituraRepository.existsByAutor(...)
  def validar_duplicidade_na_criacao
    return if titulo.blank? || autor.blank?

    if Partitura.exists?(titulo: titulo) && Partitura.exists?(autor: autor)
      errors.add(:base, "já existe uma partitura com esse nome e esse autor")
    end
  end

  # No Spring original (AtualizarPartituraValidator):
  # parituraRepository.existsByTituloAndAutorAndIdNot(titulo, autor, id)
  def validar_duplicidade_na_atualizacao
    return if titulo.blank? || autor.blank?

    if Partitura.where.not(id: id).exists?(titulo: titulo, autor: autor)
      errors.add(:base, "já existe uma partitura com esse nome e esse autor")
    end
  end
end
