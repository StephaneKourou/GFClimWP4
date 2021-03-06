// modele join croissance et mortalite
// effet logg effet climat effet dmax
// effet alea espece sur Gmax  ( oo, clim et logg) et  le logit (oo,clim et logg)
// paramètre wood density spécifique sur K 
// parametre dmax dur Dopt
// Interaction Logg*clima avec effet aléatoire sur gmax et Logit
//    logacc_mu_cr[n1] = (oo_Gmax+
//                        cr_Gesp[rgEsp_cr[n1]]+
//                        cr_dmax*dbhmax_cr[n1]+
//                        (cr_clim+cr_Clesp[rgEsp_cr[n1]])*clim_cr[n1] +
//                        (cr_logg+cr_Loesp[rgEsp_cr[n1]])*logg_cr[n1] +
//                        (cr_int+cr_Inesp[rgEsp_cr[n1]])*logg_cr[n1]*clim_cr[n1])*
//                        exp((-0.5)*pow(log(dbh_cr[n1]/(dbhmax_cr[n1]*Dopt))/(Ks*WD_cr[n1]),2)); 
//
//    logit_mo[n2]= oo_logit+
//                  mo_Ooesp[rgEsp_mo[n2]]+
//                  onto*dbh_mo[n2]/dbhmax_mo[n2]+
//                  onto_sq*pow(dbh_mo[n2]/dbhmax_mo[n2],2)+
//                  (mo_clim+mo_Clesp[rgEsp_mo[n2]])*clim_mo[n2]+
//                  (mo_logg+mo_Loesp[rgEsp_mo[n2]])*logg_mo[n2]+
//                  (mo_int+mo_Inesp[rgEsp_mo[n2]])*clim_mo[n2]*logg_mo[n2]; // logit(mort reussie) 





data {                           // Data block
  int<lower=0> Ncr;               // Sample size pop1 : accroissement observes
  int<lower=0> Nmo;              // Sample size pop evenements de survie ou de mort
  int <lower=0> Nt;              // longueur liste des arbres
  int <lower=0> Nesp;            // longueur liste des especes
  vector<lower=0> [Ncr] Acc_cr;     // accroissement entre n-1 et n
  vector<lower=0> [Nmo] Acc_mo;  // accroissement entre n-2 et n-2 suivi d'un evenement de survie ou de mort
  vector [Ncr] clim_cr;             // covariable climat n-1 modele de croissance
  vector [Nmo] clim_vig;          // covariable climat n-2 calcul pred accroissement avant un evenement de survie
  vector [Nmo] clim_mo;            // covariable climat n-1 calcul logit d'un evenement de survie
  vector [Ncr] logg_cr;             // covariable exploitation modele de croissance
  vector [Nmo] logg_mo;          // covariable exploitation pred accroissement avant un evenement de survie
  vector<lower=0> [Ncr] dbh_cr;     // covariable diametre initial modele croissance
  vector<lower=0> [Nmo] dbh_mo;   // covariable diametre n-1 calcul proba mort avant un evenement de mort/survie
  vector<lower=0> [Nmo] dbh_vig; // covariable diametre n-2 calcul pred accroissement avant un evenement de survie
  vector<lower=0> [Nmo] dbhmax_mo;   // diametre max de l'espèces par foret (une donnée par observation)
  vector<lower=0> [Ncr] dbhmax_cr;   // diametre max de l'espèces par foret (une donnée par observation)
  vector<lower=0> [Nmo] WD_mo;   // densite bois de l'espèces (une donnée par observation)
  vector<lower=0> [Ncr] WD_cr;   // densite bois de l'espèces (une donnée par observation)
  int<lower=0,upper=1> morts[Nmo];// vecteur de 0 = evenement de survie et de 1 = evenement de mort
  int rgEsp_cr [Ncr];              // rang d'espece dans la liste des especes pour modele accroissement
  int rgEsp_mo [Nmo];           // rang d'espece dans la liste des especes pour modele de mortalite
}

 

parameters {
  real <lower=0.2,upper=2.5> Ks;       // Parameter croissance
  real <lower=0,upper=1> Dopt;    // Parameter croissance, borne à 1 fois le dmax de l'espèce pour une site donné
  real <lower=0.01> oo_Gmax;  // Parameter croissance : ordonnee a l'origine de Gmax
  real  cr_clim;           // Parameter croissance
  real  cr_logg;           // Parameter croissance
  real  cr_dmax;             
  real  cr_int;           // Parameter croissance
  real <lower=0> sigma;     // variance modèle de croissance
  real <lower=0> cr_sigGesp;     // variance effet alea espece sur Gmax
  real <lower=0> cr_sigClesp;     // variance effet alea espece sur Gmax
  real <lower=0> cr_sigLoesp;     // variance effet alea espece sur Gmax
  real <lower=0> cr_sigInesp;     // variance effet alea espece sur Gmax
  vector [Nesp] cr_Gesp;     //effet aleatoire especes sur Gmax : a declare ici et non dans la partie modele car il entre dans le calcul de transformed parameters
  vector [Nesp] cr_Clesp;     //effet aleatoire especes croissance sur Clim
  vector [Nesp] cr_Loesp;     //effet aleatoire especes croisance sur Logg 
  vector [Nesp] cr_Inesp;     //effet aleatoire especes croisance sur Logg 
  real  oo_logit;               // Parameter mortalite : ordonnee a l'origine du logit
  real  vig;               // Parameter mortalite
  real <upper=0> onto;      // Parameter mortalite
  real <lower=0> onto_sq;   // Parameter mortalite
  real  mo_clim;             // Parameter mortalite
  real  mo_logg;           // Parameter mortalite
  real  mo_int;           // Parameter mortalite
  real <lower=0> mo_sigOoesp;     // variance effet alea espece sur mortalite
  real <lower=0> mo_sigClesp;     // variance effet alea espece sur mortalite clim
  real <lower=0> mo_sigLoesp;     // variance effet alea espece sur mortalite logg
  real <lower=0> mo_sigInesp;     // variance effet alea espece sur mortalite logg
  vector [Nesp] mo_Ooesp;     //effet aleatoire especes mortalite : a declare ici et non dans la partie modele car il entre dans le calcul de transformed parameters
  vector [Nesp] mo_Clesp;     //effet aleatoire especes mortalite sur Clim 
  vector [Nesp] mo_Loesp;     //effet aleatoire especes mortalite sur Logg
  vector [Nesp] mo_Inesp;     //effet aleatoire especes mortalite sur Logg
}

transformed parameters {    // Transformed parameters block
  vector [Ncr] logacc_mu_cr;            
  vector [Nmo] logit_mo;        // nombre reel=logit(proba mort)    
  vector [Nmo] logacc_mu_mo;          // prediction log(accroisssement) (donnees mortalite) = logacc_pred
  vector [Nmo] vig_mo;           // vigueur = log(acc_obs/acc_pred)

// modele d'acroissement
  for(n1 in 1:Ncr) {
    logacc_mu_cr[n1] = (oo_Gmax+cr_Gesp[rgEsp_cr[n1]]+
                        cr_dmax*dbhmax_cr[n1]+
                       (cr_clim+cr_Clesp[rgEsp_cr[n1]])*clim_cr[n1]+
                       (cr_logg+cr_Loesp[rgEsp_cr[n1]])*logg_cr[n1]+
                       (cr_int+cr_Inesp[rgEsp_cr[n1]])*clim_cr[n1]*logg_cr[n1])*
                       exp((-0.5)*pow(log(dbh_cr[n1]/(dbhmax_cr[n1]*Dopt))/(Ks*WD_cr[n1]),2));
// obligation de faire un boucle sinon erreur de la fonction pow()
  }

// modele mortalite : data_survie
  for(n2 in 1:Nmo) {
    logacc_mu_mo[n2] = (oo_Gmax+cr_Gesp[rgEsp_mo[n2]]+
                     cr_dmax*dbhmax_mo[n2]+
                     (cr_clim+cr_Clesp[rgEsp_mo[n2]])*clim_vig[n2]+
                     (cr_logg+cr_Loesp[rgEsp_mo[n2]])*logg_mo[n2]+
                     (cr_int+cr_Inesp[rgEsp_mo[n2]])*clim_vig[n2]*logg_mo[n2])*
                     exp((-0.5)*pow(log(dbh_vig[n2]/dbhmax_mo[n2]/Dopt)/(Ks*WD_mo[n2]),2)); 
    
    vig_mo[n2]=log(Acc_mo[n2]+1)-logacc_mu_mo[n2];
    
    logit_mo[n2]= oo_logit+
                  mo_Ooesp[rgEsp_mo[n2]]+
                  vig*vig_mo[n2]+
                  onto*dbh_mo[n2]/dbhmax_mo[n2]+
                  onto_sq*pow(dbh_mo[n2]/dbhmax_mo[n2],2)+
                  (mo_clim+mo_Clesp[rgEsp_mo[n2]])*clim_mo[n2]+
                  (mo_logg+mo_Loesp[rgEsp_mo[n2]])*logg_mo[n2]+
                  (mo_int+mo_Inesp[rgEsp_mo[n2]])*clim_mo[n2]*logg_mo[n2]; // logit(mort reussie) 
  }
} 

model {                            // Model block
  oo_Gmax ~ normal(0,100);       // priors
  Ks ~ normal(0,100);         // priors
  Dopt ~ normal(0,100);       // priors
  cr_clim ~ normal(0,100);    // priors
  cr_logg ~ normal(0,100);    // priors
  cr_int ~ normal(0,100);    // priors
  oo_logit ~ normal(0,100);    // priors
  vig ~ normal(0,100);         // priors
  onto ~ normal(0,100);        // priors
  onto_sq ~ normal(0,100);    // priors
  mo_clim ~ normal(0,100);   // priors
  mo_logg ~ normal(0,100);   // priors
  mo_int ~ normal(0,100);   // priors
  sigma ~ normal(0,5);       // priors toncature min sur 0
  cr_sigGesp ~ normal(0,3);       // priors toncature min sur 0, cf stan_paracou30ncl_pLogg_jo5_c4i4_postnonspe.png
  cr_sigClesp ~ normal(0,5);       // priors toncature min sur 0
  cr_sigLoesp ~ normal(0,2);      // priors toncature min sur 0
  cr_sigInesp ~ normal(0,2);       // priors toncature min sur 0
  mo_sigOoesp ~ normal(0,5);       // priors toncature min sur 0
  mo_sigClesp ~ normal(0,3);       // priors toncature min sur 0 cf stan_paracou30ncl_pLogg_jo5_c4i4_postnonspe.png
  mo_sigLoesp ~ normal(0,5);       // priors toncature min sur 0
  mo_sigInesp ~ normal(0,5);       // priors toncature min sur 0

  for(nesp in 1:Nesp){                // priors
    cr_Gesp[nesp]~normal(0,cr_sigGesp);
    cr_Clesp[nesp]~normal(0,cr_sigClesp);
    cr_Loesp[nesp]~normal(0,cr_sigLoesp);
    cr_Inesp[nesp]~normal(0,cr_sigInesp);
    mo_Ooesp[nesp]~normal(0,mo_sigOoesp);
    mo_Clesp[nesp]~normal(0,mo_sigClesp);
    mo_Loesp[nesp]~normal(0,mo_sigLoesp);
    mo_Inesp[nesp]~normal(0,mo_sigInesp);
  }

 for(n1 in 1:Ncr)
   log(Acc_cr[n1]+1)~normal(logacc_mu_cr[n1],sigma);       // likelihood
// log(Acc1 +1)~normal(cr_mu1,sigma) ; /// prends 2.5 fois plus de temps qu'avec la boucle !!
  
  for(n2 in 1:Nmo)
    morts[n2]~bernoulli_logit(logit_mo[n2]); // proba de realisation de l'evenement de mort ou de survie
    //  surv2~bernoulli_logit(logit_mo2);
  

}


//generated quantities {        // Generated quantities block. 
//  vector [N1] predacc1 ;      // prediction acroissement
//  vector [N1] resacc1 ;      // prediction acroissement
//  vector [Nmo] predmort;      // prediction survie

//  for(n1 in 1:N1) {
//   predacc1[n1]=exp(lcr_mu1[n1])-1;       
//   resacc1[n1]=Acc1[n1] - predacc1[n1];
//  }
//  resacc1 = Acc1 - predacc1;
//   
//  for(n2 in 1:Nmo){
//    if (morts[n2]==0) predmort[n2]=1/(1+exp((logit_mo[n2])));  // proba survie 
//      else predmort[n2]=1/(1+exp(-(logit_mo[n2]))); // proba mort 
//  }
//}
