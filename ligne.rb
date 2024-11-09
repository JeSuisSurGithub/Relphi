class Ligne
    def initialize(id, n, vs, vv, vt, vm)
        @id = id
        @nom = n
        @stations = vs
        @voies = vv
        @trains = vt
        @missions = vm
    end

    def rafraichir
        for idx in 0..(@stations.length - 1) do
            @stations[idx].rafraichir(idx, @stations.length)
        end
        for mission in @missions do
            mission.rafraichir
        end
    end

    def to_s
        res =
            "[Ligne] #{@nom}\n" \
            "[Ligne] Stations constituantes:\n"
        for station in @stations do
            res += "\t" + station.to_s
        end
        res += "[Ligne] Voies constituantes:\n"
        for voie in @voies do
            res += "\t" + voie.to_s
        end
        res += "[Ligne] Parc de matériel roulant:\n"
        for train in @trains do
            res += "\t" + train.to_s
        end
        res += "[Ligne] Listes des missions:\n"
        for mission in @missions do
            res += mission.to_s
        end
        return res
    end
end

