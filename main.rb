#!/usr/bin/env ruby

require './voyageur'
require './reseau'
require './train'
require './mission'
require './ligne'

s_vc = Station.new(0, "Versailles Chantiers", 3)
s_jej = Station.new(1, "Jouy en Josas", 1)
s_mp = Station.new(2, "Massy Palaiseau", 2)

v_vc_jej = Voie.new(0, "Versailles Chantiers => Jouy en Josas", s_vc, s_jej)
v_jej_mp = Voie.new(1, "Jouy en Josas => Massy Palaiseau", s_jej, s_mp)

t_z20501 = Train.new(0, "Z20501 4 Caisses US", 606)

s_vc.voies = [v_vc_jej]
s_jej.voies = [v_jej_mp]

ligne_v = Ligne.new(
    0, "Transilien V",
    [
        s_vc,
        s_jej,
        s_mp
    ],
    [
        v_vc_jej,
        v_jej_mp
    ],
    [
        t_z20501
    ],
    [
        Mission.new(
            0, "MAVA01",
            t_z20501,
            [0, 0, 1, 1, 2], # Etapes
            [30, 5, 1, 5], # Temps
            s_vc,
            10
        )
    ]
)

if __FILE__ == $0
    srand(0)
    for _ in 1..51 do
        ligne_v.rafraichir
    end
end