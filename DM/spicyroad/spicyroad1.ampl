reset;

option solver 'gurobi';

#Chaque ville correspond à un sommet dans le graphe
set VILLES;
set DEPARTS within VILLES;
set ARRIVEES within VILLES;

#Chaque route correspond à un arc reliant deux villes dans le graphe
set ROUTES within { x in VILLES, y in VILLES : x <> y};

#A chaque route correspond un coût de distribution
param cout_distribution {ROUTES} >= 0;

#Le débit max de chaque ville correspond au nombre maximum de marchandises pouvant y transiter, ou pour les fournisseurs, pouvant y être produites
param debit_max {VILLES} >= 0;

#Chaque république a un certain nombre de marchandises à vendre
param ventes_min {ARRIVEES} >=0;

var quantite_transportee {ROUTES} integer;

var quantite_recue {VILLES} integer;

subject to definition {v in VILLES : v not in DEPARTS} :
  quantite_recue[v] = ( sum{(x,v) in ROUTES} quantite_transportee[x,v] );

maximize profit :
  (sum {y in ARRIVEES} quantite_recue[y] * 2.5) - (sum { (x,y) in ROUTES : x in DEPARTS } quantite_transportee [x,y] * 0.3) - (sum { (x,y) in ROUTES } quantite_transportee [x,y] * cout_distribution [x,y]);

#on doit respecter la loi de conservation (il y a autant de ressources qui sortent d'une ville que de ressources qui en sort)
subject to loi_conservation
  { c in VILLES : c not in DEPARTS and c not in ARRIVEES } :
  quantite_recue[c] = sum { (c,y) in ROUTES } quantite_transportee [c,y];

#chaque république a des besoins à satisfaire
subject to besoins_a_satisfaire {arrivee in ARRIVEES} :
  quantite_recue[arrivee] >= ventes_min[arrivee];

#chacun des comptoirs a un débit limité
subject to debit_limite {c in VILLES : c not in ARRIVEES} :
  sum { (c,y) in ROUTES } quantite_transportee [c,y] <= debit_max [c];



solve;

display quantite_recue;

display quantite_transportee;
