/**********************************************************************
 * creePs
 *
 ***********************************************************************/

/* Ce program prend un nom de graphe en entrée, le charge,
   et crée le fichier .dot
*/

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <sys/wait.h>

#include "graphe.h"

/* Couleurs */
typedef enum {ROUGE=0, BLEU=1, VERT=2} tCouleur;
typedef tCouleur tTabCouleurs[MAX_SOMMETS];

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
  Parcours en largeur
*/
void parcoursLargeur(tGraphe graphe, tNomSommet s){
  int i; int indexS; tNumeroSommet x; tNumeroSommet y;
  tTabCouleurs couleur;
	tFileSommets file = fileSommetsAlloue();
  /* Colorier tous les sommet sauf s en bleu*/
  for(i=0;i<MAX_SOMMETS;i++) {
  	tNumeroSommet nbParcours = i;
  	tNomSommet nomParcours;
  	grapheRecupNomSommet(graphe,nbParcours,nomParcours);
  	if(strcmp(s,nomParcours) != 0) {
      couleur[i] = BLEU;
	  } else {
      indexS = i;
    }
  }
  /* Vider la file */
  while (!fileSommetsEstVide(file)) {
    fileSommetsDefile(file);
  }
  /* Colorier s en vert et l'enfiler */
  couleur[indexS] = VERT;
  fileSommetsEnfile(file,indexS);
  /*tant que la file n’est pas vide faire
    défiler x
    pour tout voisin y de x faire
      si y est bleu alors
        colorier y en vert et l’enfiler
      finsi
    fait
    colorier x en rouge
  fait
  */
  while (!fileSommetsEstVide(file)) {
    x = fileSommetsDefile(file);
    for (i=0; i<grapheNbVoisinsSommet(graphe,x); i++) {
      y = grapheVoisinSommetNumero(graphe,x,i);
      if (couleur[y]==BLEU) {
        couleur[y]=VERT;
        fileSommetsEnfile(file,y);
      }
    }
    /*colorier x en rouge*/
    couleur[x]=ROUGE;
  }
  fileSommetsLibere(file);
}


int main(int argc, char *argv[]) {

  tGraphe graphe;
  char* outfile;

  if (argc<2) {
    halt("Usage : %s FichierGraphe\n", argv[0]);
  }

  outfile = "visu.ps";

  graphe = grapheAlloue();
  grapheChargeFichier(graphe,  argv[1]);

  graphe2visu(graphe, outfile);

  grapheLibere(graphe);

  exit(EXIT_SUCCESS);
}
