# comm-gnome-theme-goldy-dark

Pacote do tema Gold Dark para GNOME, fornecendo estilos GTK3/GTK4 e um wallpaper exclusivo. Este repositório empacota a variante "Goldy-Dark" do projeto original para uso pela comunidade BigLinux.

## O que está incluído
- Arquivos do tema **Goldy-Dark** do projeto [L4ki/Goldy-Plasma-Themes](https://github.com/L4ki/Goldy-Plasma-Themes).
- Um script de instalação (`.install`) que aplica o tema e o esquema de cores escuro automaticamente durante a instalação/atualização via `pacman`.
- Wallpaper `goldy.heic` instalado em `/usr/share/backgrounds/comm-gnome-theme-goldy-dark/`.

## Dependências
- **Runtime:** `gtk3`, `gtk4`, `gnome-shell`, `gtk-engine-murrine`.
- **Build:** `git`.
- **Opcional:** 
    - `gnome-tweaks`: Para facilitar a gestão de temas e outras customizações.
    - `libheif`: Para que o sistema possa exibir o wallpaper no formato HEIC.

## Funcionamento
Durante a instalação, atualização ou remoção do pacote com o `pacman`, o script de automação será executado para o usuário gráfico ativo.

- **Na instalação (`pacman -S`):** O script faz um backup das suas configurações GTK atuais em `~/backup_customizations`, e então aplica o tema `Goldy-Dark` e o esquema de cores `prefer-dark` usando `gsettings`.
- **Na remoção (`pacman -R`):** O script restaura o último backup das suas configurações e reverte as chaves `gsettings` para o padrão do GNOME.
- **Na atualização (`pacman -Syu`):** O script reaplica a configuração para garantir que o tema continue funcionando corretamente.

## Créditos
- **Tema Original:** [L4ki](https://github.com/L4ki).
- **Empacotamento:** Comunidade BigLinux.
