set PAYS; #Pays producteurs
set Republiques; #Pays de destinations
set Comptoirs; #Comptoirs de la mer noire
set Fournisseurs = PAYS union Comptoirs; #Pays qui fournissent ceux de la republiques
set Recepteurs = Comptoirs union Republiques; #Pays qui ont des taxes de passage pour les produits
set Routes;

param cout_distribution{Routes} >=0;
param prix_achat>=0;
param capacité_de_production{PAYS}; #capacité de production des PAYS
param valeur>=0;
param prix_vente >=0; #2.5 unité
param satisfaction{Republiques}; #nombre de vente minimale par République
param limites_comptoirs{Comptoirs}>=0;
param route_dispo{Fournisseurs,Recepteurs};

var route_possible{Fournisseurs,Recepteurs} binary;


#ici la quantité p
var qte_présente{Fournisseurs}>=0;

maximize profit:
  sum{p in PAYS,r in Recepteurs, f in Fournisseurs} prix_vente*qte_présente[f] - (0.3*qte_présente[f] + cout_distribution[f,r]);

subject to est_une_route_possible{r in RECEPTEURS}:
  sum{f in Fournisseurs} route_possible[f,r]=1;

subject to cout_de_distrib_selon_les_chemins{rt in Routes,r in RECEPTEURS}:
  sum{f in Fournisseurs} cout_distribution[rt]*route_dispo[f,r]>0;

subject to capacite_de_production_pays{p in PAYS}:
  sum{f in Fournisseurs} qte_présente[f]<=capacité_de_production[p];

subject to satisfaction_famille_dans_repu{rep in Republiques}:
  sum{f in Fournisseurs} qte_présente[f]>=satisfaction[rep];

subject to limite_qte_comptoirs{p in PAYS, c in Comptoirs} :
  qte_présente[p] <= limites_comptoirs[c];
