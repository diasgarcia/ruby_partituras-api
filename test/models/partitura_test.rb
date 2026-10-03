require "test_helper"

class PartituraTest < ActiveSupport::TestCase
  test "partitura válida deve ser salva" do
    # Arrange
    partitura = Partitura.new(
      titulo: "Nova Música",
      autor: "Novo Compositor",
      arranjador: "Arranjador X",
      bpm: 100,
      tonalidade: "C",
      avaliacao: 4
    )

    # Act
    salvo = partitura.save

    # Assert
    assert salvo
    assert_equal Date.current, partitura.data_criacao
  end

  test "deve ser inválida quando título não for informado" do
    # Arrange
    partitura = Partitura.new(titulo: nil, autor: "Compositor", arranjador: "Arr", tonalidade: "C")

    # Act
    valido = partitura.valid?

    # Assert
    assert_not valido
    assert_includes partitura.errors[:titulo], "título é obrigatório"
  end

  test "deve ser inválida quando autor não for informado" do
    # Arrange
    partitura = Partitura.new(titulo: "Música", autor: nil, arranjador: "Arr", tonalidade: "C")

    # Act
    valido = partitura.valid?

    # Assert
    assert_not valido
    assert_includes partitura.errors[:autor], "autor é obrigatório"
  end

  test "deve ser inválida quando arranjador não for informado" do
    # Arrange
    partitura = Partitura.new(titulo: "Música", autor: "Compositor", arranjador: nil, tonalidade: "C")

    # Act
    valido = partitura.valid?

    # Assert
    assert_not valido
    assert_includes partitura.errors[:arranjador], "arranjador é obrigatório"
  end

  test "deve ser inválida quando bpm for menor ou igual a zero" do
    # Arrange
    partitura = Partitura.new(
      titulo: "Música Zero",
      autor: "Compositor",
      arranjador: "Arr",
      bpm: 0,
      tonalidade: "D"
    )

    # Act
    valido = partitura.valid?

    # Assert
    assert_not valido
    assert partitura.errors[:bpm].present?
  end

  test "deve ser inválida quando avaliação for menor que 1" do
    # Arrange
    partitura = Partitura.new(
      titulo: "Música Baixa",
      autor: "Compositor",
      arranjador: "Arr",
      avaliacao: 0,
      tonalidade: "D"
    )

    # Act
    valido = partitura.valid?

    # Assert
    assert_not valido
    assert partitura.errors[:avaliacao].present?
  end

  test "deve ser inválida quando avaliação for maior que 5" do
    # Arrange
    partitura = Partitura.new(
      titulo: "Música Alta",
      autor: "Compositor",
      arranjador: "Arr",
      avaliacao: 6,
      tonalidade: "D"
    )

    # Act
    valido = partitura.valid?

    # Assert
    assert_not valido
    assert partitura.errors[:avaliacao].present?
  end

  test "deve aceitar tonalidade válida e normalizar notação do enum Java" do
    # Arrange
    partitura = Partitura.new(
      titulo: "Música Sharp",
      autor: "Compositor",
      arranjador: "Arr",
      bpm: 90,
      tonalidade: "C_SHARP"
    )

    # Act
    valido = partitura.valid?

    # Assert
    assert_equal "C#", partitura.tonalidade
    assert valido
  end

  test "deve rejeitar tonalidade fora das 24 permitidas" do
    # Arrange
    partitura = Partitura.new(
      titulo: "Música Inválida",
      autor: "Compositor",
      arranjador: "Arr",
      tonalidade: "XYZ"
    )

    # Act
    valido = partitura.valid?

    # Assert
    assert_not valido
    assert_includes partitura.errors[:tonalidade], "tonalidade inválida"
  end

  test "deve invalidar na criação quando título e autor já existirem" do
    # Arrange
    existente = partituras(:one)
    nova_partitura = Partitura.new(
      titulo: existente.titulo,
      autor: existente.autor,
      arranjador: "Outro",
      bpm: 90,
      tonalidade: "C"
    )

    # Act
    valido = nova_partitura.valid?(:create)

    # Assert
    assert_not valido
    assert_includes nova_partitura.errors[:base], "já existe uma partitura com esse nome e esse autor"
  end

  test "deve invalidar na atualização quando título e autor já pertencerem a outra partitura" do
    # Arrange
    partitura_alvo = partituras(:two)
    outra_partitura = partituras(:one)
    partitura_alvo.titulo = outra_partitura.titulo
    partitura_alvo.autor = outra_partitura.autor

    # Act
    valido = partitura_alvo.valid?(:update)

    # Assert
    assert_not valido
    assert_includes partitura_alvo.errors[:base], "já existe uma partitura com esse nome e esse autor"
  end

  test "deve serializar no formato de resumo por padrão com apenas 4 campos" do
    # Arrange
    partitura = partituras(:one)
    chaves_esperadas = %i[id titulo autor avaliacao].sort

    # Act
    json = partitura.as_json

    # Assert
    assert_equal chaves_esperadas, json.keys.sort
    assert_equal partitura.id, json[:id]
    assert_equal partitura.titulo, json[:titulo]
    assert_equal partitura.autor, json[:autor]
    assert_equal partitura.avaliacao, json[:avaliacao]
  end

  test "deve serializar no formato detalhado com 8 campos e dataCriacao em camelCase" do
    # Arrange
    partitura = partituras(:one)
    chaves_esperadas = %i[id titulo autor arranjador bpm avaliacao dataCriacao tonalidade].sort

    # Act
    json = partitura.as_json(detailed: true)

    # Assert
    assert_equal chaves_esperadas, json.keys.sort
    assert_equal partitura.id, json[:id]
    assert_equal "2026-01-01", json[:dataCriacao].to_s
    assert_equal "Em", json[:tonalidade]
  end
end
