Brevi istruzioni per abilitare autocompletamento e debugging per Lua

- Installare le estensioni raccomandate (vedi `.vscode/extensions.json`).
- Esempio per installare dalla riga di comando:

```bash
code --install-extension sumneko.lua
code --install-extension tangzx.emmylua
code --install-extension yinfei.luahelper
```

- Impostazioni workspace in `.vscode/settings.json` già configurate per `sumneko.lua`.
- Per debuggare apri il file Lua da eseguire e avvia la configurazione "Launch current Lua file (EmmyLua)" nel pannello Run/Debug.

- Se preferisci un altro debugger, puoi modificare `.vscode/launch.json` e scegliere il `type` corrispondente all'estensione installata.

Se vuoi, posso:
- installare le estensioni per te (se mi autorizzi a eseguire comandi),
- adattare le impostazioni alla versione di Lua che usi (es. 5.1, 5.3, 5.4),
- creare configurazioni di debug aggiuntive (es. argomenti, env vars).
