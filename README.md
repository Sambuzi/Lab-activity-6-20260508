**Overview del progetto**

- Descrizione: questo progetto mostra un semplice comportamento di aggregazione per foot-bots simulati con ARGoS. Ogni robot decide se fermarsi o continuare a muoversi in base al numero di vicini fermi rilevati dal sensore Range-and-Bearing (RAB). L'obiettivo didattico è studiare come semplici regole locali portino alla formazione di raggruppamenti collettivi.

**Contenuto della cartella**
- [aggregation.lua](aggregation.lua): controller Lua che implementa la logica di aggregazione (stati, conteggio RAB, random-walk, Bernoulli decision).
- [test-aggregation.argos](test-aggregation.argos): configurazione ARGoS (arena, robot, medium RAB, visualizzazione).

**Obiettivo e comportamento atteso**
- Obiettivo: osservare la comparsa di addensamenti (cluster) di robot fermi a partire da regole locali.
- Comportamento atteso: con parametri opportuni i robot formano gruppi stabili; con parametri meno adatti si ottengono piccoli ammassi temporanei o uno stato diffusamente mescolato.

**Come funziona**
- Ogni robot ha due stati: MOVING (si muove) e STOPPED (fermo).
- I robot pubblicano sul medium RAB un flag (0 o 1) che indica se sono fermi.
- Alla fase di step, ciascun robot conta quanti vicini fermi vede entro un raggio `MAXRANGE` (funzione `CountRAB()`).
- La probabilità di fermarsi (Ps) e di ripartire (Pw) è calcolata come funzioni lineari di `N` (numero di vicini fermi):
	- Ps = min(PS_MAX, S + ALPHA * N)
	- Pw = max(PW_MIN, W - BETA * N)
- La decisione probabilistica è centralizzata nella funzione `Bernoulli(p)`.

**Requisiti**
- ARGoS 3.x installato e nel PATH (`argos3` o `argos3 -c` a seconda della tua versione).
- Interprete Lua per eventuale validazione (`luac` usato per il check di sintassi).

**Eseguire la simulazione**
1. Posizionati nella cartella del progetto:

```bash
cd "/.../.../.../Lab activity 6-20260508"
```

2. Lancia ARGoS:

```bash
argos3 -c test-aggregation.argos
```

Nota: il comando `argos3` può variare a seconda dell'installazione (es. `argos3 -c` o `argos3 -c <file>` è lo standard per ARGoS 3).

**Controlli rapidi e validazione**
- Verificare sintassi Lua (non esegue nulla, solo check):

```bash
luac -p aggregation.lua
```

- Se `luac` non produce output, la sintassi è ok.

**Parametri principali e come tararli**
- `S`, `W`: probabilità base di stop/start. Aumentandole aumenti la probabilità indipendente dai vicini.
- `PS_MAX`, `PW_MIN`: limiti per evitare probabilità fuori scala.
- `ALPHA`, `BETA`: guadagni che modulano Ps/Pw in funzione del numero di vicini fermi `N`. Aumentando `ALPHA` la probabilità di fermarsi cresce più rapidamente con `N` (clusterizzazione più forte). Aumentando `BETA` la probabilità di ripartire decresce più rapidamente con `N` (stabilità dei cluster).
- `MAXRANGE`: raggio di considerazione per `CountRAB()` (unità: metri nel codice attuale). Se pensi siano cm, ricordati di convertire (es. 30 cm = 0.30 m).
- `MAX_VELOCITY`, `PROX_THRESHOLD`: influenzano il comportamento di movimento e l'evitamento ostacoli.


