/**********************************************************************
 * parcoursEnProfondeur
 *
 ***********************************************************************/

/* parcoursEnProfondeur
*/

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <sys/wait.h>
#include <sys/time.h>

#include "graphe.h"

/* Couleurs */
typedef enum {ROUGE=0, BLEU=1, VERT=2} tCouleur;
typedef tCouleur tTabCouleurs[MAX_SOMMETS];

/* Crée le fichier pour graphviz */
void graphe2visu(tGraphe graphe, char *outfile) {
  FILE *fic;
  char commande[80];
  char dotfile[80]; /* le fichier dot pour cr ́eer le ps */
  char nomSommet1[80];
  char nomSommet2[80];
  tArc arc;
  int orig;
  int dest;
  int i;
  int ret;
  /* on va cr ́eer un fichier pour graphviz, dans le fichier "outfile".dot */
  strcpy(dotfile, outfile);
  strcat(dotfile, ".dot");
  fic = fopen(dotfile, "w");
  if (fic==NULL)
    halt ("Ouverture du fichier %s en  ́ecriture impossible\n", dotfile);
  /*
  on parcourt le graphe pour en tirer les informations
  n ́ecessaires pour graphviz.
  Pour  ́ecrire dans le fichier, on utilise fprintf (qui s’utilise
  comme printf mais on mettant en plus fic comme premier param`etre).
  Ex :
  fprintf(fic, "graph {\n");
  ou
  fprintf(fic, "  %s -> %s\n", origine, destination);
  */
  if (grapheEstOriente(graphe)) {
    fprintf(fic, "digraph {\n");
    for (i=0; i<grapheNbArcs(graphe); i++) {
      arc = grapheRecupArcNumero(graphe, i);
      orig = arc.orig;
      dest = arc.dest;
      grapheRecupNomSommet(graphe, orig, nomSommet1);
      grapheRecupNomSommet(graphe, dest, nomSommet2);
      fprintf(fic, "%s -> %s;\n", nomSommet1, nomSommet2);
    }
    fprintf(fic, "}\n");
  } else {
    fprintf(fic, "graph {\n");
    for (i=0; i<grapheNbArcs(graphe); i++) {
      arc = grapheRecupArcNumero(graphe, i);
      orig = arc.orig;
      dest = arc.dest;
      grapheRecupNomSommet(graphe, orig, nomSommet1);
      grapheRecupNomSommet(graphe, dest, nomSommet2);
      fprintf(fic, "%s -- %s;\n", nomSommet1, nomSommet2);
    }
    fprintf(fic, "}\n");
  }
  fclose(fic);
  sprintf(commande, "dot -Tps %s -o %s", dotfile, outfile);
  ret = system(commande);
  if (WEXITSTATUS(ret))
    halt("La commande suivante a  ́echou ́e\n%s\n", commande);
    /*perror("La commande a échoué");
    exit(EXIT_FAILURE);*/
}

/*
  Algo de Bellman
*/
void bellmanCetteSacrePute(tGraphe graphe, tNomSommet s){
  int i, indexS, found, timoleon;
  tNumeroSommet x; tNumeroSommet y;
  tNomSommet nomParcours;
  tNumeroSommet* tableauNul;
  tTabCouleurs couleur;
  /* allocation du tableau nul*/
  timoleon = grapheNbSommets(graphe)-1;
  tableauNul = (tNumeroSommet*)malloc(sizeof(tNumeroSommet)*MAX_SOMMETS);
  /* allocation de la pile */
  tPileSommets pile = pileSommetsAlloue();
  /* Colorier tous les sommet sauf s en bleu*/
  for(i=0;i<grapheNbSommets(graphe);i++) {
  	tNumeroSommet nbParcours = i;
  	grapheRecupNomSommet(graphe,nbParcours,nomParcours);
  	if(strcmp(s,nomParcours) != 0) {
      couleur[i] = BLEU;
	  } else {
      couleur[i] = -1;
      indexS = i;
    }
  }
  /* Vider la pile */
  while (!pileSommetsEstVide(pile)) {
    pileSommetsDepile(pile);
  }
  /* Colorier s en vert et l'empiler */
  couleur[indexS] = VERT;
  pileSommetsEmpile(pile,indexS);
  /* boucle while */
  while (!pileSommetsEstVide(pile)) {
    printf("%i - %i - %i - %i - %i\n", couleur[0],couleur[1],couleur[2],couleur[3],couleur[4]);
    found = 0;
    x = pileSommetsTete(pile);
    /*si x a un voisin bleu y, colorier y en vert et l'empiler*/
    for (i=0; i<grapheNbVoisinsSommet(graphe,x); i++) {
      y = grapheVoisinSommetNumero(graphe,x,i);
      /* a delete*/
      grapheRecupNomSommet(graphe,y,nomParcours);
      printf("NUMERO SOMMET %s\n",nomParcours);
      if (couleur[y]==BLEU) {
        couleur[y]=VERT;
        pileSommetsEmpile(pile,y);
        found = 1;
        break;
      }
    }
    printf("---\n");
    /*si x n'a pas de voisin bleu, le colorier en rouge puis le dépiler*/
    if (!found) {
      couleur[x]=ROUGE;
      tableauNul[timoleon] = x;
      timoleon--;
      pileSommetsDepile(pile);
    }
  }
  /* free */
  pileSommetsLibere(pile);
  grapheRecupNomSommet(graphe,indexS,nomParcours);
  for (i=0; i<grapheNbSommets(graphe); i++) {
   grapheRecupNomSommet(graphe,tableauNul[i],nomParcours);
   printf("%s\n",nomParcours);
  }
}


int main(int argc, char *argv[]) {

  tGraphe graphe;

  if (argc<2) {
    halt("Usage : %s FichierGraphe\n", argv[0]);
  }

  graphe = grapheAlloue();
  grapheChargeFichier(graphe, argv[1]);

  bellmanCetteSacrePute(graphe, "A");

  grapheLibere(graphe);

  exit(EXIT_SUCCESS);
}
