def of_id(liste, id)
    for el in liste
        if el.id == id
            return el
        end
    end
    raise "of_id: could not find id #{id} in #{liste.inspect}"
end

class Mission
    attr_reader :id, :train, :tps_total, :tps_etape, :station

    def initialize(id, n, train, idsvs, tsvs, sv, d)
        @id = id
        @nom = n
        @train = train
        @id_stations_voies = idsvs
        @tps_stations_voies = tsvs

        # Décalage en temps avant le début de la mission
        # La mission est "dormante" si progression est négatif
        @tps_total = -d
        @etape = sv
        @station_depart = @etape
        @tps_etape = -1

        # Station ou voie
        @station = false

        # Si cpt_etapes == id_stations_voies.length c'est fini?
        @cpt_etapes = 0

        self.commencer
        if !self.dormant?
            @tps_etape = 0
        end
    end

    def dormant?
        return @tps_total < 0
    end

    def fini?
        return @cpt_etapes == (@id_stations_voies.length - 1)
    end

    def id_stations_desservies
        # Tout les id de stations ou l'on est pas passé par
        (@id_stations_voies.select.with_index { |_, idx| idx.even? && idx > @cpt_etapes })
    end

    def commencer
        if @tps_total == 0
            @station = true
            @cpt_etapes = 0
            puts "[#{tps_total}min] Mission commencée à #{@etape.nom}"
        end
    end

    def dechargement
        cpt = 0
        if @station
            @train.voyageurs.delete_if do |voyageur|
                if voyageur.id_station_arrivee == @etape.id
                    @etape.voyageurs << voyageur
                    cpt += 1
                    true
                else
                    false
                end
            end
        end
        if cpt > 0
            puts "[#{tps_total}min] Déchargé #{cpt} voyageurs"
        end
    end

    def chargement
        cpt = 0
        if @station
            @etape.voyageurs.delete_if do |voyageur|
                if @train.voyageurs.size < @train.capacite &&
                    self.id_stations_desservies.include?(voyageur.id_station_arrivee)
                    @train.voyageurs << voyageur
                    cpt += 1
                    true
                else
                    false
                end
            end
        end
        if cpt > 0
            puts "[#{tps_total}min] Chargé #{cpt} voyageurs"
        end
    end

    def echange_voyageurs
        self.dechargement
        self.chargement
    end

    def rafraichir
        etait_dormant = self.dormant?
        @tps_total += 1
        # Si la mission est finie
        if self.fini?
            self.dechargement
            puts "[#{tps_total}min] Mission finie"
            return
        end
        # Si la mission va commencer
        if etait_dormant
            self.commencer
        end
        # Si la mission a commencé
        if !self.dormant?
            etape_fini = (@tps_etape + 1) >= @tps_stations_voies[@cpt_etapes]
            if @station
                # Quitter la station
                if etape_fini
                    puts "[#{tps_total}min] Station #{@etape.nom} quittée"
                    @etape = of_id(@etape.voies, @id_stations_voies[@cpt_etapes])
                    @tps_etape = 0
                    @station = false
                    @cpt_etapes += 1
                else
                    self.echange_voyageurs
                    @tps_etape += 1
                end
            else
                # Entrée en station
                if etape_fini
                    @etape = @etape.station_arrivee
                    puts "[#{tps_total}min] Entrée en station #{@etape.nom}"
                    @tps_etape = 0
                    @station = true
                    @cpt_etapes += 1
                    self.echange_voyageurs
                else
                    @tps_etape += 1
                end
            end
        end
    end

    def to_s
        res =
            "[Mission] Mission: #{@nom}\n" \
            "[Mission] Train utilisé:\n" \
            "\t#{@train}"

        station_voie = @station_depart
        for idx_etape in 0..(@id_stations_voies.length - 1)
            if idx_etape.even?
                if idx_etape != (@id_stations_voies.length - 1)
                    res += "[Mission] Temps d'attente: #{@tps_stations_voies[idx_etape]}min\n"
                else
                    res += "[Mission] Terminus\n"
                end
                res += "\t" + station_voie.to_s
                if idx_etape != (@id_stations_voies.length - 1)
                    station_voie = of_id(station_voie.voies, @id_stations_voies[idx_etape])
                end
            else
                res += "[Mission] Temps de trajet: #{@tps_stations_voies[idx_etape]}min\n"
                res += "\t"  + station_voie.to_s
                station_voie = station_voie.station_arrivee
            end
        end
        if !self.dormant?
            res += "[Mission] Temps de parcours total #{@tps_total}min\n"
            if @station
                res += "[Mission] Station actuelle:\n"
                res += @etape.to_s
                res += "[Mission] Temps en station #{@tps_etape}min\n"
            else
                res += "[Mission] Actuellement sur le trajet entre:\n"
                res += @etape.to_s
                res += "[Mission] Temps du trajet #{@tps_etape}min\n"
            end
        else
            res += "[Mission] Début dans #{-@tps_total}min"
        end
        return res
    end
end