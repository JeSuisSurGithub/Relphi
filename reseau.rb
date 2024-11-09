class Station
    attr_reader :id, :nom
    attr_accessor :voyageurs, :voies

    def initialize(id, n, dfa)
        @id = id
        @nom = n
        @df_affluence = dfa
        @voyageurs = []
        @voies = []
    end

    def rafraichir(is, ns)
        # Arrivée de nouveau voyageurs
        for i in 0..(@df_affluence - 1)
            @voyageurs << Voyageur.new(is, ((0..ns).to_a  - [is]).sample)
        end
    end

    def to_s
        "[Station] #{@id} | #{@nom} | " \
        "#{@df_affluence} voyageurs / rafraichissement | " \
        "#{@voyageurs.length} voyageurs | " \
        "#{@voies.length} voies\n"
    end
end

class Voie
    attr_reader :id, :nom, :station_depart, :station_arrivee

    def initialize(id, n, sd, sa)
        @id = id
        @nom = n
        @station_depart = sd
        @station_arrivee = sa
    end

    def to_s
        "[Voie] #{@id} | #{@nom}\n"
    end
end