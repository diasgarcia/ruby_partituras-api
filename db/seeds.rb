partituras = [
  { titulo: "Asturias (Leyenda)", autor: "Isaac Albéniz", arranjador: "Andrés Segovia", bpm: 120, tonalidade: "Em", avaliacao: 5 },
  { titulo: "Recuerdos de la Alhambra", autor: "Francisco Tárrega", arranjador: "Francisco Tárrega", bpm: 80, tonalidade: "Am", avaliacao: 5 },
  { titulo: "Romance Anônimo", autor: "Tradicional", arranjador: "Narciso Yepes", bpm: 88, tonalidade: "Em", avaliacao: 4 },
  { titulo: "Bachianinha No. 1", autor: "Paulinho Nogueira", arranjador: "Paulinho Nogueira", bpm: 140, tonalidade: "Am", avaliacao: 5 },
  { titulo: "Sons de Carrilhões", autor: "João Pernambuco", arranjador: "João Pernambuco", bpm: 92, tonalidade: "D", avaliacao: 5 },
  { titulo: "Bourrée em Mi Menor", autor: "J.S. Bach", arranjador: "Julian Bream", bpm: 100, tonalidade: "Em", avaliacao: 5 },
  { titulo: "Capricho Árabe", autor: "Francisco Tárrega", arranjador: "Francisco Tárrega", bpm: 72, tonalidade: "Dm", avaliacao: 5 },
  { titulo: "Choro N. 1", autor: "Heitor Villa-Lobos", arranjador: "Villa-Lobos", bpm: 96, tonalidade: "Em", avaliacao: 5 },
  { titulo: "Lágrima", autor: "Francisco Tárrega", arranjador: "Francisco Tárrega", bpm: 60, tonalidade: "D", avaliacao: 5 },
  { titulo: "Gran Vals", autor: "Francisco Tárrega", arranjador: "Francisco Tárrega", bpm: 116, tonalidade: "C", avaliacao: 4 },
  { titulo: "Prelude No. 1 em Mi Menor", autor: "Heitor Villa-Lobos", arranjador: "Heitor Villa-Lobos", bpm: 76, tonalidade: "Em", avaliacao: 5 },
  { titulo: "Prelude No. 4 em Mi Maior", autor: "Heitor Villa-Lobos", arranjador: "Heitor Villa-Lobos", bpm: 66, tonalidade: "E", avaliacao: 5 },
  { titulo: "Allemande (Suite BWV 997)", autor: "J.S. Bach", arranjador: "John Williams", bpm: 84, tonalidade: "Am", avaliacao: 5 },
  { titulo: "Chaconne (BWV 1004)", autor: "J.S. Bach", arranjador: "Andrés Segovia", bpm: 58, tonalidade: "Dm", avaliacao: 5 },
  { titulo: "Canarios", autor: "Gaspar Sanz", arranjador: "Narciso Yepes", bpm: 132, tonalidade: "Am", avaliacao: 4 },
  { titulo: "Pavana", autor: "Luis Milán", arranjador: "Emilio Pujol", bpm: 68, tonalidade: "C", avaliacao: 4 },
  { titulo: "Adelita", autor: "Francisco Tárrega", arranjador: "Francisco Tárrega", bpm: 63, tonalidade: "D", avaliacao: 4 },
  { titulo: "Malagueña", autor: "Francisco Tárrega", arranjador: "Andrés Segovia", bpm: 108, tonalidade: "Am", avaliacao: 4 },
  { titulo: "Mazurca em Sol Maior", autor: "Francisco Tárrega", arranjador: "Francisco Tárrega", bpm: 112, tonalidade: "G", avaliacao: 3 },
  { titulo: "Estudio en Mi Menor", autor: "Fernando Sor", arranjador: "Andrés Segovia", bpm: 70, tonalidade: "Em", avaliacao: 5 },
  { titulo: "Variations sur un thème de Mozart", autor: "Fernando Sor", arranjador: "Julian Bream", bpm: 100, tonalidade: "C", avaliacao: 5 },
  { titulo: "Fantasia No. 7", autor: "Mauro Giuliani", arranjador: "Mauro Giuliani", bpm: 90, tonalidade: "A", avaliacao: 4 },
  { titulo: "Etude Op. 35 No. 22", autor: "Fernando Sor", arranjador: "Andrés Segovia", bpm: 80, tonalidade: "G", avaliacao: 4 },
  { titulo: "Minueto em Sol", autor: "J.S. Bach", arranjador: "John Williams", bpm: 96, tonalidade: "G", avaliacao: 4 }
]

partituras.each do |attrs|
  Partitura.find_or_create_by!(titulo: attrs[:titulo], autor: attrs[:autor]) do |p|
    p.arranjador = attrs[:arranjador]
    p.bpm = attrs[:bpm]
    p.tonalidade = attrs[:tonalidade]
    p.avaliacao = attrs[:avaliacao]
    p.data_criacao = Date.current
  end
end
