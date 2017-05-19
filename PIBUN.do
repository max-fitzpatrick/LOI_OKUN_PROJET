*Loi d'Okun
*Analyse de données trimestrielles américaines de 1948 à 2016
*Max Fitzpatrick
*M1 Banque Finance 2016/2017
*Université de Bordeaux
*--------------------------------------------
*--------------------------------------------
*Importer les données
*--------------------------------------------
import excel "D:\ECONOMETRIE_FITZPATRICK\PROJET_M1\PIBUN.xlsx", sheet("Sheet1") firstrow
generate temps = tq(1948q2) + number - 1
tsset temps, quarterly
label variable un "Chomage (Δ%)"
label variable pib "PIB (Δ%)"
label variable temps "Temps (trimestre)"
*--------------------------------------------
*Présenter les données
*--------------------------------------------
global ylist un
global xlist pib
describe $ylist $xlist
summarize $ylist $xlist
summarize $ylist, detail
summarize $xlist, detail
stem un
stem pib
*--------------------------------------------
* Exploration graphique des séries
*--------------------------------------------
twoway (line un temps), title(L'évolution du chomage (Δ%) dans le temps) legend(on)
twoway (line pib temps), title(L'évolution du PIB (Δ%) dans le temps) legend(on)
twoway (line un pib temps), title(L'évolution du chomage (Δ%) et du PIB (Δ%) dans le temps) legend(on)
twoway (scatter un pib), title(Nuage de points du chomage (Δ%) et du PIB (Δ%)) legend(on)
twoway (scatter un pib) (lfit un pib), ytitle(Chomage (Δ%)) xtitle(PIB (Δ%)) title(Nuage de points avec une droite de régression) legend(on)
*--------------------------------------------
* Corrélation
*--------------------------------------------
correlate un pib
*--------------------------------------------
*Vérification de la stationnarité des variables
*--------------------------------------------
*Tester la variable un (chômage)
corrgram un
ac un
pac un
varsoc un, lutstat
reg un L.un L2.un L3.un L4.un
predict res_un, r
dfuller res_un, noconstant regress
dfuller un, lags(4) trend regress
dfuller un, lags(4) regress
dfuller un, lags(4) nocons regress

*Tester la variable pib
corrgram pib
ac pib
pac pib
varsoc pib, lutstat
reg un L.pib
predict res_pib, r
dfuller res_pib, noconstant regress
dfuller pib, lags(1) trend regress
dfuller pib, lags(1) regress
*--------------------------------------------
*Test de cointégration
*--------------------------------------------
*Vu que nos deux séries sont I(0) en niveau
*Il n'y a pas besoin de faire un test de cointégration
*Car elles ne peuvent pas etre cointégrées
*--------------------------
*Identification de sous-périodes avec swald test, cusum, et Chow test
*--------------------------
reg un pib
sbsingle
*Identification d'une sous-période de 1 à 46 (1948q2-1959q3)
reg un pib if number>46
sbsingle
*Identification d'une période de 47 à 222 (1959q4-2003q3)
*Identification d'une période de 223 à 274(2003q4-2016q3)
*Ainsi nous avons 3 sous-périodes à modéliser
cusum6 un pib, cs(cusum) lw(lower) uw(upper)
*Confirmation de ces périodes avec le cusum²
*Vérification avec test de Chow
*scalar F = [(scr-(scr1+scr2))/(scr1+scr2)]*(n-2*k)/k
*Vérification du premier point de rupture en 47
reg un pib
scalar scr = e(rss)
scalar N = e(N)
reg un pib in 1/46
scalar scr1 = e(rss)
scalar N1 = e(N)
reg un pib if number>46
scalar scr2 = e(rss)
scalar N2 = e(N)
scalar F = [(scr-(scr1+scr2))/(scr1+scr2)]*112
display F
*Vérification du deuxième point de rupture en 223
reg un pib if number>46
scalar scr = e(rss)
scalar N = e(N)
reg un pib in 47/222
scalar scr1 = e(rss)
scalar N1 = e(N)
reg un pib if number>222
scalar scr2 = e(rss)
scalar N2 = e(N)
scalar F = [(scr-(scr1+scr2))/(scr1+scr2)]*135
display F
*--------------------------
*Régression pour la période 1
*--------------------------
twoway (scatter un pib in 1/46) (lfit un pib in 1/46), ytitle(Chomage (Δ%)) xtitle(PIB (Δ%)) title(Nuage de points avec une droite de régression) subtitle(Pour la période 1948q2 - 1959q3) legend(on)
reg un pib in 1/46
predict res in 1/46, r
gen yhat = _b[_cons]+_b[pib]*pib in 1/46
twoway (scatter un yhat in 1/46), ytitle(Chomage (Δ%) observé) xtitle(Chomage (Δ%) estimé) title(Nuage de points avec chomage observé et estimé) subtitle(Pour la période 1948q2 - 1959q3) legend(on)
acprplot pib, lowess
avplot pib
estat ic
estat vce
*Hétéroscédasticité identifiée, il faut une régression "robust"
drop res
reg un pib in 1/46, robust
predict res in 1/46, r

*Espérance
ttest res==0
*Normalité
kdensity res, normal
histogram res, kdensity normal
pnorm res
qnorm res
swilk res
sktest res
*Homoscédasticité
rvfplot, yline(0)
estat imtest
estat hettest
estat archlm
*Multicolinéarité
vif
*Indépendance/autocorrélation
ac res
pac res
dwstat
estat bgodfrey
estat durbinalt, force
correlate res pib in 1/46
*Goodness of fit
ovtest
linktest

*--------------------------
*Régression pour la période 2
*--------------------------
drop res
drop yhat
twoway (scatter un pib in 47/222) (lfit un pib in 47/222), ytitle(Chomage (Δ%)) xtitle(PIB (Δ%)) title(Nuage de points avec une droite de régression) subtitle(Pour la période 1959q4 - 2003q3) legend(on)
reg un pib in 47/222
predict res in 47/222, r
gen yhat = _b[_cons]+_b[pib]*pib in 47/222
twoway (scatter un yhat in 47/222), ytitle(Chomage (Δ%) observé) xtitle(Chomage (Δ%) estimé) title(Nuage de points avec chomage observé et estimé) subtitle(Pour la période 1949q4 - 2003q3) legend(on)
acprplot pib, lowess
avplot pib
estat ic
estat vce
*Homoscédasticité
rvfplot, yline(0)
estat imtest
estat hettest
*Hétéroscédasticité identifiée, il faut une régression robust
drop res
reg un pib in 47/222, robust
predict res in 47/222, r

*Espérance
ttest res==0
*Normalité
kdensity res, normal
histogram res, kdensity normal
pnorm res
qnorm res
swilk res
sktest res
*Homoscédasticité
rvfplot, yline(0)
estat imtest
estat hettest
estat archlm
*Multicolinéarité
vif
*Indépendance/autocorrélation
ac res
pac res
dwstat
estat bgodfrey
estat durbinalt, force
correlate res pib in 47/222
*Goodness of fit
ovtest
linktest


*--------------------------
*Régression pour la période 3
*--------------------------
drop res
drop yhat
twoway (scatter un pib if number>222) (lfit un pib if number>222), ytitle(Chomage (Δ%)) xtitle(PIB (Δ%)) title(Nuage de points avec une droite de régression) subtitle(Pour la période 2003q4 - 2016q3) legend(on)
reg un pib if number>222
predict res if number>222, r
gen yhat = _b[_cons]+_b[pib]*pib if number>222
twoway (scatter un yhat if number>222), ytitle(Chomage (Δ%) observé) xtitle(Chomage (Δ%) estimé) title(Nuage de points avec chomage observé et estimé) subtitle(Pour la période 2003q4 - 2016q3) legend(on)
acprplot pib, lowess
avplot pib
estat ic
estat vce

*Espérance
ttest res==0
*Normalité
kdensity res, normal
histogram res, kdensity normal
pnorm res
qnorm res
swilk res
sktest res
*Homoscédasticité
rvfplot, yline(0)
estat imtest
estat hettest
estat archlm
*Multicolinéarité
vif
*Indépendance/autocorrélation
ac res
pac res
dwstat
estat bgodfrey
estat durbinalt
correlate res pib if number>222
*Goodness of fit
ovtest
linktest
