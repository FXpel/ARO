/**********************************************************************
 * plusCourteChaine
 *
 ***********************************************************************/

/* Ce program fédétruk
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
  Calcule les tableaux d et pred comme expliqu´e dans le polycopi´e
*/
void plusCourteChaine(tGraphe graphe, tNomSommet s){
  int i, indexS;
  tNumeroSommet x; tNumeroSommet y;
  tNomSommet nomParcours;
  int d[MAX_SOMMETS]; tNumeroSommet pred[MAX_SOMMETS]; tTabCouleurs couleur;
  /* allocation de la file */
  tFileSommets file = fileSommetsAlloue();
  /* Colorier tous les sommet sauf s en bleu*/
  for(i=0;i<grapheNbSommets(graphe);i++) {
  	tNumeroSommet nbParcours = i;
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
  /* initialisation de d et pred pour s */
  d[indexS] = 0;
  pred[indexS] = -1;
  /* Colorier s en vert et l'enfiler */
  couleur[indexS] = VERT;
  fileSommetsEnfile(file,indexS);
  /* boucle while */
  while (!fileSommetsEstVide(file)) {
    x = fileSommetsDefile(file);
    for (i=0; i<grapheNbVoisinsSommet(graphe,x); i++) {
      y = grapheVoisinSommetNumero(graphe,x,i);
      if (couleur[y]==BLEU) {
        couleur[y]=VERT;
        fileSommetsEnfile(file,y);
        d[y] = d[x] + 1;
        pred[y] = x;
      }
    }
    /*colorier x en rouge*/
    couleur[x]=ROUGE;
  }
  /* free */
  fileSommetsLibere(file);
  /* imprime les tableaux d et pred pour plus de lisibilité
  */
  grapheRecupNomSommet(graphe,indexS,nomParcours);
  printf("Tableaux pred et d pour le sommet %s.\n", nomParcours);
  for (i=0; i<grapheNbSommets(graphe); i++) {
    grapheRecupNomSommet(graphe,i,nomParcours);
    printf("----------------------------------------------------------\n");
    printf("Tableau pred (%i : %s) : %i\n", i,nomParcours,pred[i]);
    printf("Tableau d (%i : %s) : %i\n", i,nomParcours,d[i]);
  }
}


int main(int argc, char *argv[]) {

  int n,m;
  tGraphe graphe;
  int nbSommets; double proba;
  char * nomSommet;

  nomSommet = malloc(10*sizeof(char));

  if (argc<2) {
    halt("Usage : %s FichierGraphe\n", argv[0]);
  }

  graphe = grapheAlloue();

  if (strcmp(argv[1],"alea") == 0) {
    nbSommets = atoi(argv[2]);
    proba = atof(argv[3]);
    grapheAleatoire(graphe, nbSommets, 0,proba);
  } else {
    grapheChargeFichier(graphe,  argv[1]);
  }

  n = grapheNbSommets(graphe);
  m = grapheNbArcs(graphe);

  printf("Fonction plusCourteChaine pour n=%i et m=%i.\n",n,m);

  nbSommets = nbSommets/2;
  sprintf(nomSommet, "S%d", nbSommets);
  plusCourteChaine(graphe, nomSommet);

  grapheLibere(graphe);

  exit(EXIT_SUCCESS);
}
