<p align="right"><a href="README.md">Read in English (US)</a></p>

# sober-fps-unlock

Remove o teto de ~240 FPS do [Sober](https://sober.vinegarhq.org/) (cliente
Roblox pra Linux) travando o `FramerateCap` no arquivo de configurações do
Sober com o atributo imutável do sistema de arquivos.

## Por que isso é necessário

O cliente Roblox do Sober fica reescrevendo `GlobalBasicSettings_13.xml`
(via substituição atômica) toda vez que abre, resetando o `FramerateCap`
pro padrão — mesmo se você editar o arquivo na mão ou deixar ele como
somente-leitura (`chmod`), já que uma substituição atômica não confere as
permissões do arquivo que está sendo substituído. As FastFlags da
comunidade (`DFIntTaskSchedulerTargetFps`,
`FFlagTaskSchedulerLimitTargetFpsTo240`) que funcionavam pra isso em
outras plataformas são ignoradas silenciosamente no Sober atualmente.

Deixar o arquivo **imutável** (`chattr +i`) bloqueia a substituição no
nível do sistema de arquivos, o que o jogo não consegue contornar mesmo
com o sudo já segurando o arquivo aberto -- ele só mantém o valor que
você definiu.

## Testado em

- **Distro:** Linux Mint 22.3 (Zena)
- **Kernel:** 6.8.0-117-lowlatency
- **Sessão gráfica:** X11, Cinnamon (`X-Cinnamon`)
- **CPU:** Intel Xeon E5-2683 v4
- **GPU:** NVIDIA GeForce RTX 3050 6GB (driver proprietário 595.84)
- **Sober:** 1.7.1 (Flathub, `org.vinegarhq.Sober`, runtime `org.gnome.Platform`)
- **Sistema de arquivos:** ext4 (precisa suportar o atributo imutável)

## Requisitos

- Linux com sistema de arquivos que suporte o atributo imutável (ext4, a
  maioria dos sistemas de arquivos Linux suporta)
- Acesso a `sudo`
- Sober instalado via Flatpak, aberto pelo menos uma vez (pro arquivo de
  configuração existir)

## Uso

```bash
./sober-fps-unlock.sh                # trava o FramerateCap em 10000
./sober-fps-unlock.sh --fps 500      # trava num valor específico
./sober-fps-unlock.sh --undo          # destrava o arquivo (chattr -i)
```

Não bota `sudo` na frente do comando inteiro -- o script chama `sudo`
internamente só na etapa do `chattr`. Rodar o script inteiro como root
faz ele procurar no diretório home do root em vez do seu, e não vai
achar o arquivo de configuração.

Você vai precisar fechar e reabrir o Sober pra mudança valer. Confere
seu FPS de verdade no jogo com `Shift+F5`.

Se quiser trocar o valor de novo depois, roda `--undo` primeiro, edita
normal (ou só roda o script de novo com um `--fps` novo), não precisa
fazer mais nada.

## Notas

- Isso edita um arquivo de configuração local e não modifica o código do
  jogo, a memória ou o tráfego de rede do Roblox. É o mesmo tipo de ajuste
  que desativar v-sync ou editar um arquivo de configuração gráfica.
- Isso afeta o cliente Sober globalmente, não uma experiência específica
  -- não toca nem contorna nada que o próprio desenvolvedor de um jogo
  configurou.
- Se uma atualização futura do Sober mudar o nome/local do arquivo de
  configurações ou como ele aplica o limite de FPS, esse script pode
  precisar de ajuste.

## Licença

MIT

---

## Modo de instalação e execução passo a passo

1. **Garante que o Sober já foi aberto pelo menos uma vez** (pro arquivo
   de configurações existir de verdade). Se você nunca abriu:
   ```bash
   flatpak install flathub org.vinegarhq.Sober
   flatpak run org.vinegarhq.Sober
   ```
   depois fecha ele de novo.
2. **Clona esse repositório:**
   ```bash
   git clone https://github.com/ddkznx/sober-fps-unlock.git
   cd sober-fps-unlock
   ```
3. **Deixa o script executável** (só precisa se você baixou o arquivo
   direto em vez de clonar -- `git clone` já preserva isso):
   ```bash
   chmod +x sober-fps-unlock.sh
   ```
4. **Roda** (sem `sudo` antes do comando -- o script pede sua senha
   sozinho, só na etapa que precisa):
   ```bash
   ./sober-fps-unlock.sh
   ```
   Isso trava o `FramerateCap` em 10000. Pra escolher outro valor:
   ```bash
   ./sober-fps-unlock.sh --fps 500
   ```
5. **Fecha o Sober completamente se estiver aberto**, e abre de novo.
6. **Confere seu FPS no jogo** com `Shift+F5` -- não deve mais estar
   travado perto de 240.
7. **Pra desfazer depois** (destravar o arquivo e voltar o Sober padrão):
   ```bash
   ./sober-fps-unlock.sh --undo
   ```
