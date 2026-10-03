class CreatePartituras < ActiveRecord::Migration[8.1]
  def change
    create_table :partituras do |t|
      t.string :titulo, null: false
      t.string :autor, null: false
      t.string :arranjador, null: false
      t.integer :bpm
      t.string :tonalidade, limit: 10, null: false
      t.integer :avaliacao
      t.date :data_criacao, null: false, default: -> { "CURRENT_DATE" }

      t.check_constraint "bpm > 0", name: "check_bpm_positive"
      t.check_constraint "avaliacao >= 1 AND avaliacao <= 5", name: "check_avaliacao_range"
      t.check_constraint "tonalidade IN ('C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B', 'Cm', 'C#m', 'Dm', 'D#m', 'Em', 'Fm', 'F#m', 'Gm', 'G#m', 'Am', 'A#m', 'Bm')", name: "check_tonalidade_sigla"
    end

    add_index :partituras, [ :titulo, :autor ]
  end
end
