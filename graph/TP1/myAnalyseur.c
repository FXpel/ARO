/**********************************************************************
 *testAnalyseur.c
 *
 *  (François lemaire)  <Francois.Lemaire@lifl.fr>
 * Time-stamp: <2010-10-06 15:06:29 lemaire>
 ***********************************************************************/

/* Ce program prend un nom de graphe en entrée, le charge,
   et l'affiche de façon détaillée.
*/

#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include "graphe.h"

int main(int argc, char *argv[]) {
  int i;
  tNumeroSommet j=0;
  tNomSommet name;
  tGraphe graphe;
  int maxSommets;

  if (argc<2) {
    halt("Usage : %s FichierGraphe\n", argv[0]);
  }


  graphe = grapheAlloue();

  grapheChargeFichier(graphe,  argv[1]);

  grapheAffiche(graphe);
  printf("Sommets qui n'ont pas de voisins\n");
  printf("\n");
  for(i=0;i<grapheNbSommets(graphe);i++){
    if(!grapheNbVoisinsSommet(graphe,j)){
      grapheRecupNomSommet(graphe,j,name);
      printf("%s\n",name);
    }
    j++;
  }

  printf("\n");
  printf("Sommets qui ont le plus de voisins\n");
  j=0;
  maxSommets=grapheNbVoisinsSommet(graphe,j);
  for(i=0;i<grapheNbSommets(graphe);i++){
    if(grapheNbVoisinsSommet(graphe,j)>maxSommets)
      maxSommets=grapheNbVoisinsSommet(graphe,j);
  }
  j=0;
  for(i=0;i<grapheNbSommets(graphe);i++){
    if(grapheNbVoisinsSommet(graphe,j)==maxSommets){
      grapheRecupNomSommet(graphe,j,name);
      printf("%s\n",name);
    }
    j++;
  }
  grapheLibere(graphe);

  exit(EXIT_SUCCESS);
}
