reset;

#option solver gurobi;
option solver minos;

#ensemble qui contient les Pays producteurs, les comptoirs et les Républiques
set PCR;
#Pays producteurs qui se trouvent dans l'ensemble PCR
set Producteurs within PCR;
#Pays de destinations qui se trouvent dans l'ensemble PCR
set Republiques within PCR;
#Comptoirs où passent les produits qui se trouvent dans l'ensemble PCR
set Comptoirs within PCR;
#Ensemle des routes de transport possible des produits {x in PCR,y in PCR : x <> y} permet de ne pas avoir une route menant à elle même, par exemple Chine Chine;
set ROUTES within {x in PCR,y in PCR : x <> y};
#ensemble des comptoirs préférés suivant les républiques
set PREF{Republiques} within PCR;


#paramètre contenant le coup de distribution des prodtuis suivant les routes possibles
param cout_distribution{ROUTES} >=0;
#prix d'achat des produits à l'unité, ici 0.3
param prix_achat>=0;
#prix de vente des produits dans les républiques, ici 2.5 unité
param prix_vente >=0;
#nombre de vente minimale par République
param satisfaction{Republiques};
#limite de stockage des produits à chaque endroit avant d'entrer dans les républiques
param capacites_limites{PCR}>=0;
#pertes des marchandises par rapport aux routes
param pertes{ROUTES} >=0;


#quantité de produit sur les routes
var qte_route {ROUTES} integer >=0;
#quantité de produit acheté par les pays producteurs
var qte_produite{Producteurs} integer>=0;
#ici la quantité présente sur les points de passage(pays producteur, comptoirs, républiques)
var qte_presente{PCR} integer >=0;
#argent généré par la vente des produits
var vente_epice >=0;
#prix d'achat de l'ensemble des prodtuis
var prix_achat_global >=0;
#cout total du transport des produits pertess comprise
var cout_transport >=0;


maximize profit:
  vente_epice - ( prix_achat_global + cout_transport );


#préférence des républiques qui doivent avoir la moitié des produits passant par leurs comptoirs préférés d'où la vérification que si l'ont multiplie par 2 les produits présents sur les routes préférés on obtient alors un résultat équivalent aux produits présent.
subject to preference {r in Republiques} :
  (2 * (sum {(x,r) in ROUTES : x in PREF[r]} pertes[x,r]*qte_route[x,r])) == qte_presente[r];

#permet de calculer le cout de transport des produits, pertes possible comprises
subject to cout_transport_global:
  cout_transport = sum{(x,y) in ROUTES} (qte_route[x,y]*pertes[x,y]*cout_distribution[x,y]);

#permet de calculer le cout d'achat de tous les produits qui seront transporté
subject to cout_achat_final:
  prix_achat_global = sum {p in Producteurs} (qte_produite[p]*prix_achat);

#permet de calculer le chiffre d'affaire de la vente des épices
subject to vente_des_epices:
 vente_epice = sum {r in Republiques} (qte_presente[r] * prix_vente);

#permet de savoir le nombre de produit fournit par les pays producteurs
subject to quantite_produite_pays_producteurs {p in Producteurs}:
  qte_produite[p] =  sum{(p,y) in ROUTES} qte_route[p,y];


#la quantité présente actuelle avant chaque point de passage doit être égale à la quantité sur la routes sur la quelle nous sommes
subject to quantite_recue_quantite_transportee {p in PCR : p not in Producteurs} :
  qte_presente[p] =  sum{(x,p) in ROUTES}( qte_route[x,p]*pertes[x,p]) ;

#permet d'assurer que la quantité sortante des comptoirs ne soit pas supérieur à la quantité présente dans les comptoirs
subject to quantite_sortante_comptoirs { c in Comptoirs } :
  (sum { (c,y) in ROUTES } qte_route [c,y] ) <= qte_presente[c];

#pour satisfaire la demande des familles des républiques
subject to satisfaction_famille_dans_repu{rep in Republiques}:
  qte_presente[rep]>=satisfaction[rep];

#le nombre de produits sortant des comptoirs ou pays producteurs ne doivent pas dépasser la capacité max
subject to capcites_max{p in PCR: p not in Republiques} :
  sum{(p,y) in ROUTES}qte_route[p,y] <= capacites_limites[p];


  data;
  set PCR:= Chine Java Tana Trebizonde Tunis Famagouste Candie Alexandrie Venise Genes;
  set Producteurs:= Chine Java;
  set Republiques:=Venise Genes;
  set Comptoirs:= Tana Trebizonde Tunis Famagouste Candie Alexandrie;
  set PREF[Venise]:= Tunis Famagouste Candie Alexandrie;
  set PREF[Genes]:= Tana Trebizonde;


  param prix_vente=2.5;
  param prix_achat=0.3;
  param satisfaction:=
    Venise  13500
    Genes   9900 ;
  param capacites_limites:=
    Chine 15000
    Java  20000
    Tana  2800
    Trebizonde  3000
    Tunis 2000
    Famagouste  2200
    Candie  4000
    Alexandrie  3300;

  param : ROUTES : cout_distribution pertes:=
   Chine Tana 0.5 0.9
   Chine Trebizonde 0.5 0.9
   Chine Tunis  0.9 0.9
   Chine Famagouste 0.2 0.9
   Chine Alexandrie 0.9 0.9
   Java Trebizonde  0.3 0.9
   Java Tunis 0.5 0.9
   Java Famagouste  0.9 0.9
   Java Candie  0.7 0.9
   Java Alexandrie  0.5 0.9
   Tana Venise  0.8 0.9
   Trebizonde Venise  0.7 0.9
   Tunis  Venise  0.9 0.9
   Famagouste Venise  1.0 0.9
   Candie Venise  0.6 0.9
   Alexandrie Venise  0.7 0.9
   Tana  Genes 0.3  0.9
   Trebizonde  Genes 0.5  0.9
   Tunis Genes 0.7  0.9
   Alexandrie  Genes  0.5 0.9
   Chine Venise 1.1 0.6
   Chine Genes  1.2 0.6
   Java Venise  1.0 0.6
   Java Genes 1.1 0.6;
