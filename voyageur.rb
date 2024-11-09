class Voyageur
    attr_reader :id_station_depart, :id_station_arrivee

    def initialize(idsd, idsa)
        @id_station_depart = idsd
        @id_station_arrivee = idsa
    end
end