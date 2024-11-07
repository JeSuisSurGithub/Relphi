class Ligne
    def initialize(n, vs, vv, vt, vm)
        @nom = n
        @v_station = vs
        @v_voie = vv
        @v_train = vt
        @v_mission = vm
    end

    def passer1min
        for idx in 0..(@v_station.length - 1) do
            @v_station[idx].passer1min(idx, @v_station.length)
        end
        for mission in @v_mission do
            mission.passer1min(@v_station, @v_train)
        end
    end

    def inspect
        #puts "[LIGNE]: Ligne: #{@nom}"
        #puts "[LIGNE]: Stations constituantes:"
        #for station in @v_station do
        #    station.inspect
        #end
        #puts "[LIGNE]: Voies constituantes:"
        #for voie in @v_voie do
        #    voie.inspect
        #end
        #puts "[LIGNE]: Parc de matériel roulant:"
        #for train in @v_train do
        #    train.inspect
        #end
        puts "[LIGNE]: Listes des missions:"
        for mission in @v_mission do
            mission.statut(@v_station, @v_voie, @v_train)
        end
    end
end

class Station
    attr_reader :nom, :df_affluence

    def voyageurs
        @v_voyageurs
    end

    def initialize(n, dfa)
        @nom = n
        @df_affluence = dfa
        @v_voyageurs = []
    end

    def passer1min(is, ns)
        for i in 0..(@df_affluence - 1)
            @v_voyageurs << Voyageur.new(is, ((0..ns).to_a  - [is]).sample)
        end
    end

    def inspect
        puts "[STATION]: #{@nom}, #{@v_voyageurs.length} voyageurs"
    end
end

class Voie
    attr_reader :nom
    def initialize(n)
        @nom = n
    end

    def inspect
        puts "[VOIE]: #{@nom}"
    end
end

class Train
    attr_reader :nom, :capacite

    def voyageurs()
        @v_voyageurs
    end

    def initialize(n, c)
        @nom = n
        @capacite = c
        @v_voyageurs = []
    end

    def inspect
        puts "[TRAIN]: #{@nom}, #{@capacite} places, #{@v_voyageurs.length} voyageurs"
    end
end

class Voyageur
    attr_reader :idx_station_depart, :idx_station_arrivee

    def initialize(isd, isa)
        @idx_station_depart = isd
        @idx_station_arrivee = isa
    end

    def station_depart(vs)
        return vs[@idx_station_depart]
    end

    def station_arrivee(vs)
        return vs[@idx_station_arrivee]
    end
end

class Mission
    attr_reader :nom

    def attente_station
        @v_attente
    end

    def attente_trajet
        @v_temps_trajet
    end

    def initialize(n, it, iv, vis, va, vtt, d)
        @nom = n
        @idx_train = it
        @idx_voie = iv
        @v_idx_station = vis
        @v_attente = va
        @v_temps_trajet = vtt

        @progression = -d
        @idx_station = -1
        @tps_etape = -1
        @en_station = false

        @idx_fin = vis.length - 1
    end

    def train(vt)
        return vt[@idx_train]
    end

    def voie(vv)
        return vv[@idx_voie]
    end

    def stations(vs)
        return v_idx_station.map { |idx| vs[idx] }
    end

    def echange_voyageurs(vs, vt)
        train = vt[@idx_train]
        station = vs[@v_idx_station[@idx_station]]

        # Déchargement
        train.voyageurs.delete_if do |voyageur|
            if voyageur.idx_station_arrivee == @v_idx_station[@idx_station]
                station.voyageurs << voyageur
                true
            else
                false
            end
        end

        # Chargement
        station.voyageurs.delete_if do |voyageur|
            if train.voyageurs.size < train.capacite &&
                @v_idx_station.include?(voyageur.idx_station_arrivee)
                train.voyageurs << voyageur
                true
            else
                false
            end
        end

        puts "Echange voyageurs..."
    end

    def passer1min(vs, vt)
        @progression += 1
        # Si la mission est finie
        if @idx_station == @idx_fin
            # Déchargement
            vt[@idx_train].voyageurs.delete_if do |voyageur|
                if voyageur.idx_station_arrivee == @v_idx_station[@idx_station]
                    vs[@v_idx_station[@idx_station]].voyageurs << voyageur
                    true
                else
                    false
                end
            end
            return
        end
        # Si la mission va commencer
        if @progression == 1 and @idx_station == -1 and @tps_etape == -1
            @idx_station = 0
            @tps_etape = 0
            @en_station = true
            puts "Mission commencée"
        end
        # Si la mission a commencé
        if @progression >= 0
            @tps_etape += 1
            if @en_station
                # Quitter la station
                if @tps_etape >= @v_attente[@idx_station]
                    @tps_etape = 0
                    @en_station = false
                    puts "Station quittée"
                else
                    echange_voyageurs(vs, vt)
                end
            else
                # Entrée en station
                if @tps_etape >= @v_temps_trajet[@idx_station]
                    @tps_etape = 0
                    @en_station = true
                    @idx_station += 1
                    puts "Entrée en station"
                else
                    # Rien faire sur le chemin pour la modélisation actuelle
                end
            end
        end
    end

    def statut(vs, vv, vt)
        puts "[MISSION]: Mission: #{@nom}"
        puts "[MISSION]: Train utilisé: "
        vt[@idx_train].inspect
        #puts "[MISSION]: Voie empruntée: "
        #vv[@idx_voie].inspect
        #puts "[MISSION]: Arrets: "
        #for idx in 0..(@v_idx_station.length - 1)
        #    vs[@v_idx_station[idx]].inspect
        #    puts "[MISSION]: Temps d'attente: #{@v_attente[idx]}min"
        #    if idx < @v_temps_trajet.length
        #        puts "[MISSION]: Temps de trajet jusqu'à la prochaine station: #{@v_temps_trajet[idx]}min"
        #    else
        #        puts "[MISSION]: Terminus"
        #    end
        #end
        puts "[MISSION]: Temps de parcours #{@progression}min"
        if @en_station
            puts "[MISSION]: Station actuelle: "
            vs[@v_idx_station[@idx_station]].inspect
            puts "[MISSION]: Temps en station #{@tps_etape}min"
        else
            puts "[MISSION]: En direction de: "
            vs[@v_idx_station[@idx_station + 1]].inspect
            puts "[MISSION]: Temps depuis le départ de la station précédente #{@tps_etape}min"
        end
    end
end


ligne_v = Ligne.new(
    "V",
    [Station.new("Versailles Chantiers", 2), Station.new("Jouy en Josas", 1), Station.new("Massy Palaiseau", 2)],
    [Voie.new("Voie 1"), Voie.new("Voie 2")],
    [Train.new("Z20501 4 Caisses US", 606)],
    [Mission.new(
        "MAVA1",
        0,
        0,
        [0, 2],
        [30],
        [5],
        0
    )
    ]
)

srand(0)
for i in 0..44
    ligne_v.passer1min
end
ligne_v.inspect