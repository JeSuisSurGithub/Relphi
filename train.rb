class Train
    attr_reader :id, :nom, :capacite
    attr_accessor :voyageurs

    def initialize(id, n, c)
        @id = id
        @nom = n
        @capacite = c
        @voyageurs = []
    end

    def to_s
        "[Train] #{@id} | #{@nom} | #{@capacite} places | #{@voyageurs.length} voyageurs\n"
    end
end