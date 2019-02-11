reset;

option solver gurobi;

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


#quantité de produit sur les routes
var qte_route {ROUTES} integer >=0;
#ici la quantité présente sur les points de passage(pays producteur, comptoirs, républiques)
var qte_presente{PCR} integer >=0;


#le profit est donc la quantité présente dans les républiques à la base que l'on multiplie par le prix, dont on soustrait le prix d'achat et le coût de distribution suivant les routes prise.
maximize profit:
  sum{r in Republiques} (qte_presente[r]*prix_vente - qte_presente[r]*prix_achat) - (sum { (x,y) in ROUTES}(qte_route[x,y] * cout_distribution[x,y])) ;



#la quantité présente actuelle avant chaque point de passage doit être égale à la quantité sur la routes sur la quelle nous sommes
subject to quantite_recue_quantite_transportee {p in PCR : p not in Producteurs} :
  qte_presente[p] =  sum{(x,p) in ROUTES} qte_route[x,p] ;

#permet d'assurer que la quantité sortante des comptoirs ne soit pas supérieur à la quantité présente dans les comptoirs
subject to quantite_sortante_comptoirs { c in Comptoirs } :
  (sum { (c,y) in ROUTES } qte_route [c,y] ) <= qte_presente[c];

#permet de satisfaire la demande des familles des républiques
subject to satisfaction_famille_dans_repu{rep in Republiques}:
  qte_presente[rep]>=satisfaction[rep];

#le nombre de produits sortant des comptoirs ou pays producteurs ne doivent pas dépasser la capacité max des points de passage
subject to capcites_max{p in PCR: p not in Republiques} :
  sum{(p,y) in ROUTES}qte_route[p,y] <= capacites_limites[p];



  data;
  set PCR:= Chine Java Tana Trebizonde Tunis Famagouste Candie Alexandrie Venise Genes;
  set Producteurs:= Chine Java;
  set Republiques:=Venise Genes;
  set Comptoirs:= Tana Trebizonde Tunis Famagouste Candie Alexandrie;



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

  param : ROUTES : cout_distribution:=
   Chine Tana 0.5
   Chine Trebizonde 0.5
   Chine Tunis  0.9
   Chine Famagouste 0.2
   Chine Alexandrie 0.9
   Java Trebizonde  0.3
   Java Tunis 0.5
   Java Famagouste  0.9
   Java Candie  0.7
   Java Alexandrie  0.5
   Tana Venise  0.8
   Trebizonde Venise  0.7
   Tunis  Venise  0.9
   Famagouste Venise  1.0
   Candie Venise  0.6
   Alexandrie Venise  0.7
   Tana  Genes 0.3
   Trebizonde  Genes 0.5
   Tunis Genes 0.7
   Alexandrie  Genes  0.5
   Chine Venise 1.1
   Chine Genes  1.2
   Java Venise  1.0
   Java Genes 1.1;
