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




data;
set VILLES:= Chine Java Tana Trebizonde Tunis Famagouste Candie Alexandrie Venise Genes;
set DEPARTS:= Chine Java;
set ARRIVEES:= Venise Genes;
param : ROUTES : cout_distribution :=
  Chine Tana 0.5
  Chine Trebizonde 0.5
  Chine Tunis 0.9
  Chine Famagouste 0.2
  Chine Alexandrie 0.9
  Chine Venise 1.1
  Chine Genes 1.2
  Java Trebizonde 0.3
  Java Tunis 0.5
  Java Famagouste 0.9
  Java Candie 0.7
  Java Alexandrie 0.5
  Java Venise 1.0
  Java Genes 1.1
  Tana Venise 0.8
  Tana Genes 0.3
  Trebizonde Venise 0.7
  Trebizonde Genes 0.5
  Tunis Venise 0.9
  Tunis Genes 0.7
  Famagouste Venise 1.0
  Candie Venise 0.6
  Alexandrie Venise 0.7
  Alexandrie Genes 0.5
;
param : debit_max :=
Chine 15000
Java 20000
Tana 2800
Trebizonde 3000
Tunis 2000
Famagouste 2200
Candie 4000
Alexandrie 3300
;
param : ventes_min:=
Venise 13500
Genes 9900
;
