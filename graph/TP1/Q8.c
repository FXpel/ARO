/**********************************************************************
 *afficheVoisins.c
 *
 ***********************************************************************/

/* Ce program prend un nom de graphe en entrée, le charge,
   et affiche :
   - la liste des sommets sans voisin
   - la liste des sommets qui on le plus de voisins
*/

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <sys/wait.h>

#include "graphe.h"

void graphe2visu(tGraphe graphe, char *outfile) {
  FILE *fic;
  char commande[80];
  char dotfile[80]; /* le fichier dot pour cr ́eer le ps */
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
  fclose(fic);
  sprintf(commande, "dot -Tps %s -o %s", dotfile, outfile);
  ret = system(commande);
  if (WEXITSTATUS(ret))
    halt("La commande suivante a  ́echou ́e\n%s\n", commande);
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
