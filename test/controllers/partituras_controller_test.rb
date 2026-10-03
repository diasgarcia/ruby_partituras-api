require "test_helper"

class PartiturasControllerTest < ActionDispatch::IntegrationTest
  setup do
    @partitura = partituras(:one)
  end

  test "GET /partituras deve listar todas as partituras no formato resumido com status 200" do
    # Arrange (cenário com fixtures carregadas)

    # Act
    get partituras_url, as: :json

    # Assert
    assert_response :ok

    json = response.parsed_body
    assert_kind_of Array, json
    assert_not_empty json

    first_item = json.first
    assert first_item.key?("id")
    assert first_item.key?("titulo")
    assert first_item.key?("autor")
    assert first_item.key?("avaliacao")

    # Campos detalhados NÃO devem estar na listagem
    assert_not first_item.key?("arranjador")
    assert_not first_item.key?("bpm")
    assert_not first_item.key?("tonalidade")
    assert_not first_item.key?("dataCriacao")
  end

  test "GET /partituras/:id deve retornar detalhes da partitura com status 200" do
    # Arrange
    partitura_alvo = @partitura

    # Act
    get partitura_url(partitura_alvo), as: :json

    # Assert
    assert_response :ok

    json = response.parsed_body
    assert_equal partitura_alvo.id, json["id"]
    assert_equal partitura_alvo.titulo, json["titulo"]
    assert_equal partitura_alvo.autor, json["autor"]
    assert_equal partitura_alvo.arranjador, json["arranjador"]
    assert_equal partitura_alvo.bpm, json["bpm"]
    assert_equal partitura_alvo.avaliacao, json["avaliacao"]
    assert_equal partitura_alvo.tonalidade, json["tonalidade"]
    assert_equal partitura_alvo.data_criacao.to_s, json["dataCriacao"]
  end

  test "GET /partituras/:id com ID inexistente deve retornar 404 Not Found" do
    # Arrange
    id_inexistente = 999_999

    # Act
    get partitura_url(id: id_inexistente), as: :json

    # Assert
    assert_response :not_found

    json = response.parsed_body
    assert_equal "partitura não encontrada", json["message"]
  end

  test "POST /partituras com dados válidos deve criar partitura e retornar 201 Created sem corpo" do
    # Arrange
    payload = {
      titulo: "Lagrimas Novas",
      autor: "Compositor Inédito",
      arranjador: "Arranjador Teste",
      bpm: 75,
      avaliacao: 4,
      tonalidade: "E"
    }

    # Act & Assert
    assert_difference("Partitura.count", 1) do
      post partituras_url, params: payload, as: :json
    end

    assert_response :created
    assert_empty response.body

    criada = Partitura.find_by(titulo: "Lagrimas Novas")
    assert_not_nil criada
    assert_equal "E", criada.tonalidade
    assert_equal Date.current, criada.data_criacao
  end

  test "POST /partituras com dados inválidos deve retornar 400 Bad Request" do
    # Arrange
    payload_invalido = {
      titulo: "",
      autor: ""
    }

    # Act & Assert
    assert_no_difference("Partitura.count") do
      post partituras_url, params: payload_invalido, as: :json
    end

    assert_response :bad_request

    json = response.parsed_body
    assert json.key?("message")
  end

  test "POST /partituras duplicada deve retornar 400 Bad Request" do
    # Arrange
    payload_duplicado = {
      titulo: @partitura.titulo,
      autor: @partitura.autor,
      arranjador: "Outro",
      bpm: 100,
      tonalidade: "C"
    }

    # Act & Assert
    assert_no_difference("Partitura.count") do
      post partituras_url, params: payload_duplicado, as: :json
    end

    assert_response :bad_request

    json = response.parsed_body
    assert_includes json["errors"], "já existe uma partitura com esse nome e esse autor"
  end

  test "PUT /partituras/:id com dados válidos deve atualizar e retornar 204 No Content sem corpo" do
    # Arrange
    data_original = @partitura.data_criacao
    payload_atualizacao = {
      titulo: "Asturias (Versão Atualizada)",
      autor: "Isaac Albéniz",
      arranjador: "Julian Bream",
      bpm: 125,
      avaliacao: 5,
      tonalidade: "Em"
    }

    # Act
    put partitura_url(@partitura), params: payload_atualizacao, as: :json

    # Assert
    assert_response :no_content
    assert_empty response.body

    @partitura.reload
    assert_equal "Asturias (Versão Atualizada)", @partitura.titulo
    assert_equal "Julian Bream", @partitura.arranjador
    assert_equal 125, @partitura.bpm
    # Data de criação não deve ser alterada
    assert_equal data_original, @partitura.data_criacao
  end

  test "PUT /partituras/:id com ID inexistente deve retornar 404 Not Found" do
    # Arrange
    id_inexistente = 999_999
    payload = {
      titulo: "Inexistente",
      autor: "Inexistente",
      arranjador: "Arr",
      bpm: 100,
      tonalidade: "C"
    }

    # Act
    put partitura_url(id: id_inexistente), params: payload, as: :json

    # Assert
    assert_response :not_found

    json = response.parsed_body
    assert_equal "partitura não encontrada", json["message"]
  end

  test "PUT /partituras/:id com título e autor de outra partitura deve retornar 400 Bad Request" do
    # Arrange
    outra = partituras(:two)
    payload_conflitante = {
      titulo: outra.titulo,
      autor: outra.autor,
      arranjador: "Arr",
      bpm: 100,
      tonalidade: "Am"
    }

    # Act
    put partitura_url(@partitura), params: payload_conflitante, as: :json

    # Assert
    assert_response :bad_request

    json = response.parsed_body
    assert_includes json["errors"], "já existe uma partitura com esse nome e esse autor"
  end

  test "DELETE /partituras/:id existente deve remover e retornar 204 No Content sem corpo" do
    # Arrange
    partitura_alvo = @partitura

    # Act & Assert
    assert_difference("Partitura.count", -1) do
      delete partitura_url(partitura_alvo), as: :json
    end

    assert_response :no_content
    assert_empty response.body
  end

  test "DELETE /partituras/:id inexistente deve retornar 404 Not Found" do
    # Arrange
    id_inexistente = 999_999

    # Act
    delete partitura_url(id: id_inexistente), as: :json

    # Assert
    assert_response :not_found

    json = response.parsed_body
    assert_equal "partitura não encontrada", json["message"]
  end
end
