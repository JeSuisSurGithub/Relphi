class Mission
    attr_reader :id, :nom

    def initialize(id, n, train, idsvs, tsvs, sd, d)
        @id = id
        @nom = n
        @train = train
        @id_stations_voies = idsvs
        @tps_stations_voies = tsvs

        @station_debut = sd
        @etape = @station_debut

        # Décalage en temps avant le début de la mission
        @tps_total = -d

        # Il est à -1 sinon quand il y a un décalage "on perd une minute d'activité"
        @tps_etape = -1

        @idx_etapes = 0

        if !dormant?()
            @tps_etape = 0
            puts "[#{m2hm(@tps_total)}] Mission commencée à #{@etape.nom}"
        end
    end

    def dormant?
        return @tps_total < 0
    end

    def fini?
        return @idx_etapes == (@id_stations_voies.length - 1)
    end

    def station?
        return @idx_etapes.even?
    end

    def id_stations_desservies
        # Tout les id de stations ou l'on est pas encore passé par
        @id_stations_voies.select.with_index { |_, idx| idx.even? && idx > @idx_etapes }
    end

    def dechargement
        cpt = 0
        if station?()
            @train.voyageurs.delete_if do |voyageur|
                if voyageur.id_station_arrivee == @etape.id
                    @etape.voyageurs << voyageur # Hmmmm les enlever?
                    cpt += 1
                    true
                else
                    false
                end
            end
        end
        if cpt > 0
            puts "[#{m2hm(@tps_total)}] Déchargé #{cpt} voyageurs"
        end
    end

    def chargement
        cpt = 0
        if station?()
            @etape.voyageurs.delete_if do |voyageur|
                if @train.voyageurs.size < @train.capacite &&
                    id_stations_desservies.include?(voyageur.id_station_arrivee)
                    @train.voyageurs << voyageur
                    cpt += 1
                    true
                else
                    false
                end
            end
        end
        if cpt > 0
            puts "[#{m2hm(@tps_total)}] Chargé #{cpt} voyageurs"
        end
    end

    def echange_voyageurs
        dechargement()
        chargement()
    end

    def rafraichir
        # Si la mission est finie
        if fini?()
            dechargement()
            puts "[#{m2hm(@tps_total)}] Mission finie"
            return
        end

        # Si la mission va commencer
        if @tps_total == -1
            puts "[#{m2hm(@tps_total + 1)}] Mission commencée à #{@etape.nom}"
        end
        @tps_total += 1

        # Si la mission a commencé
        if !dormant?()
            # Si etape actuelle finie
            if (@tps_etape + 1) >= @tps_stations_voies[@idx_etapes]
                @tps_etape = 0

                if station?()
                    puts "[#{m2hm(@tps_total)}] Station #{@etape.nom} quittée"
                    @etape = de_id(@etape.voies, @id_stations_voies[@idx_etapes])
                    @idx_etapes += 1
                else
                    @etape = @etape.station_arrivee
                    puts "[#{m2hm(@tps_total)}] Entrée en station #{@etape.nom}"
                    @idx_etapes += 1
                    echange_voyageurs()
                end
            else
                if station?()
                    echange_voyageurs()
                end
                @tps_etape += 1
            end
        end
    end

    def to_s
        res =
            "[Mission] Mission: #{id} | #{@nom}\n" \
            "[Mission] Train utilisé:\n" \
            "\t#{@train}"

        etape = @station_debut
        for idx_etape in 0..(@id_stations_voies.length - 1)
            if idx_etape.even?
                if idx_etape == (@id_stations_voies.length - 1)
                    res += "[Mission] Terminus\n"
                else
                    res += "[Mission] Temps d'attente: #{@tps_stations_voies[idx_etape]}min\n"
                end

                res += "\t #{etape}"

                if idx_etape != (@id_stations_voies.length - 1)
                    etape = de_id(etape.voies, @id_stations_voies[idx_etape])
                end
            else
                res +=
                    "[Mission] Temps de trajet: #{@tps_stations_voies[idx_etape]}min\n" \
                    "\t #{etape}"
                etape = etape.station_arrivee
            end
        end

        if !dormant?()
            res += "[Mission] Temps de parcours total #{@tps_total}min\n"
            if station?()
                res +=
                    "[Mission] Station actuelle:\n" \
                    "#{etape}" \
                    "[Mission] Temps en station #{@tps_etape}min\n"
            else
                res +=
                    "[Mission] Actuellement sur le trajet entre:\n" \
                    "#{etape}" \
                    "[Mission] Temps du trajet #{@tps_etape}min\n"
            end
        else
            res += "[Mission] Début dans #{-@tps_total}min"
        end

        return res
    end

    def de_id(lst, id)
        for el in lst
            if el.id == id
                return el
            end
        end
        raise "de_id: Aucun élément d'id #{id} dans #{lst.inspect}"
    end

    def m2hm(min)
        return "#{(min / 60).to_s.rjust(2, "0")}:#{(min % 60).to_s.rjust(2, "0")}"
    end

    private :de_id, :m2hm
end