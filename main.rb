require './reseau'
require './train'
require './voyageur'
require './ligne'
require './mission'

s_vc = Station.new(0, "Versailles Chantiers", 2)
s_jej = Station.new(1, "Jouy en Josas", 1)
s_mp = Station.new(2, "Massy Palaiseau", 2)
v_vcjej = Voie.new(0, "Versailles Chantiers => Jouy en Josas", s_vc, s_jej)
v_jejmp = Voie.new(1, "Jouy en Josas => Massy Palaiseau", s_jej, s_mp)
t_z20501 = Train.new(0, "Z20501 4 Caisses US", 606)

s_vc.voies = [v_vcjej]
s_jej.voies = [v_jejmp]

ligne_v = Ligne.new(
    0, "Transilien V",
    [
        s_vc,
        s_jej,
        s_mp
    ],
    [
        v_vcjej,
        v_jejmp
    ],
    [
        t_z20501
    ],
    [
        Mission.new(
            0, "MAVA1",
            t_z20501,
            [0, 0, 1, 1, 2],
            [30, 5, 1, 5],
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