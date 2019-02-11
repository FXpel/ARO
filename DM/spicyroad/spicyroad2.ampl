###### INSTRUCTIONS DE DÉBUT ######

reset;

option solver './minos';


###### ENSEMBLES #######

#Chaque ville correspond à un sommet dans le graphe
set VILLES;

#Les départs correspondent aux pays producteurs
set DEPARTS within VILLES;

#Les arrivées correspondent aux républiques
set ARRIVEES within VILLES;

#Les comptoirs correspondent aux villes par lesquelles peuvent transiter les sacs entre pays producteurs et républiques
set COMPTOIRS within VILLES;

#Les préférences sont indicées par les républiques, on y trouve les comptoirs que chaque république préfère pour des raisons historiques
set PREF{ARRIVEES} within VILLES;

#Chaque route correspond à un arc reliant deux villes dans le graphe
set ROUTES within { x in VILLES, y in VILLES : x <> y};


###### PARAMÈTRES ######

#Le prix de vente d'un sac en unités monétaires, 2.5 dans le sujet
param prix_vente >=0;

#Le coût de production d'un sac en unités monétaires, 0.3 dans le sujet
param cout_production >=0;

#A chaque route correspond un coût de distribution
param cout_distribution {ROUTES} >= 0;

#Le débit max de chaque ville correspond au nombre maximum de marchandises pouvant y transiter, ou pour les fournisseurs, pouvant y être produites
param debit_max {VILLES} >= 0;

#Chaque république a un certain nombre de marchandises à vendre
param ventes_min {ARRIVEES} >=0;

#À chaque route est associée un facteur de pertes
param pertes{ROUTES} >= 0;


###### VARIABLES ######

#Ceci représente la quantité de marchandises envoyées sur chaque route, cela correspond à la valeur de chaque arc de notre graphe
var quantite_transportee {ROUTES} integer >=0 ;

#Ceci représente la quantité reçue par chaque ville non productrice, cela correspond donc à la somme des marchandises reçues multipliées par un facteur
#de pertes pour chaque route
var quantite_recue {VILLES} integer >=0 ;

subject to definition_quantite_recue {v in VILLES : v not in DEPARTS} :
  quantite_recue[v] = ( sum{(x,v) in ROUTES} pertes[x,v]*quantite_transportee[x,v] );

#Ceci correspond à la quantité de sacs d'épices produite par les pays producteurs d'épices, il s'agit de la somme des quantités de sacs envoyées
var quantite_produite {DEPARTS} integer >= 0;

subject to definition_quantite_produite {d in DEPARTS}:
  quantite_produite[d] = ( sum{ (d,x) in ROUTES} quantite_transportee[d,x]);

#Ceci correspond au chiffre d'affaires généré par la vente de sacs dans les républiques. 
var chiffre_affaires >=0;

subject to definition_chiffre_affaires:
 chiffre_affaires = (sum {a in ARRIVEES} quantite_recue[a] * prix_vente);

#Ceci correspond au coût de production total des sacs d'épices, c'est à dire la quantité de marchandises produites par pays producteur
#multiplié par le coût de producion
var cout_production_total >=0;

subject to definition_cout_production_total:
  cout_production_total = (sum {d in DEPARTS} quantite_produite[d]*cout_production);

#Ceci correspond aux coûts de distribution totaux, c'est à dire le nombre de marchandises transportées par route, en tenant compte des pertes
#multipliées par le coût de transport des marchandises sur la route
var cout_distribution_total >=0;

subject to definition_cout_distribution_total:
  cout_distribution_total = (sum{(x,y) in ROUTES} pertes[x,y]*quantite_transportee[x,y]*cout_distribution[x,y]);


###### QUANTITÉ À MAXIMISER #######

#On a le choix entre minimiser les coûts ou maximiser le profit généré par la vente de sacs pour obtenir le transit optimal de sacs d'épices
#Ici nous faisons le choix d'optimiser le profit généré
#Le profit est obtenu par la quantité d'argent obtenue par la vente des sacs, auquel on retire les coûts de production et les coûts de distribution

maximize profit :
  chiffre_affaires - ( cout_production_total + cout_distribution_total );


###### CONTRAINTES À SATISFAIRE ######

#Par cette contrainte, on oblige la quantité de sacs sortants d'un comptoir à être inférieure ou égale à la quantité de sacs reçue

subject to quantite_sortante { c in COMPTOIRS } :
  (sum { (c,y) in ROUTES } quantite_transportee [c,y] ) <= quantite_recue[c];

#chaque république a des besoins à satisfaire, 

subject to besoins_a_satisfaire {a in ARRIVEES} :
  quantite_recue[a] >= ventes_min[a];

#Pour les pays producteurs on a un maximum de production, pour les comptoirs on a un débit maximum de marchandises capables de sortir :
#on réunit ces deux contraintes en une seule

subject to debit_sortant {v in VILLES : v not in ARRIVEES} :
  sum { (v,y) in ROUTES } quantite_transportee [v,y] <= debit_max [v];

#chaque capitale doit recevoir au moins la moitié de ses marchandises des comptoirs qu'elle préfère pour des raisons historiques
#ici on fait le choix de tenir compte des pertes, cela n'était pas précisé sur le sujet

subject to preference {a in ARRIVEES} :
  (2 * (sum {(x,a) in ROUTES : x in PREF[a]} pertes[x,a]*quantite_transportee[x,a])) >= quantite_recue[a]; 


###### JEU DE DONNÉES ######

data 'datasetQ2.data';


###### INSTRUCTIONS ANNEXES ######

solve;

#On observe les quantités transportées sur chaque axe

display quantite_transportee;

display quantite_recue;

#On observe les valeurs marginales des contraintes de demande et de débit sortant, pour le débit sortant on observe les valeurs pour la Chine et Java
#parce que cela représente leur capacité de production

display besoins_a_satisfaire;

display debit_sortant;
