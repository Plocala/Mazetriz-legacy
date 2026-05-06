# 🧩 Mazetriz (Legacy)

[![Status: Archived](https://img.shields.io/badge/Status-Archived-lightgrey.svg)](https://github.com/Plocala/Mazetriz-legacy)
[![itch.io](https://img.shields.io/badge/Play%20on-itch.io-FA5C5C?logo=itchio&logoColor=white)](https://vagariante-games.itch.io/mazetriz)
[![LÖVE](https://img.shields.io/badge/Made%20with-LÖVE-8A2BE2?logo=love2d&logoColor=white)](https://love2d.org)

> ⚠️ **Este repositório está arquivado e não receberá mais atualizações.**
> 
> Ela contém o **código original e bagunçado** do meu primeiro jogo em LÖVE2D – um monólito enorme, cheio de bugs e má organização. Ele foi mantido apenas como registro histórico e prova do meu aprendizado.

---

## 🎮 Sobre o jogo

**Mazetriz** é um experimento que mistura **Tetris** com **roguelike espacial**. Durante uma game jam, eu quis criar algo que desafiasse tanto o raciocínio rápido quanto a estratégia de sobrevivência. O resultado foi um protótipo funcional, mas tecnicamente… bem, você está olhando para ele 😅

- 👾 **Jogabilidade**: encaixe peças (como no Tetris) enquanto enfrenta inimigos e coleta power-ups.
- 🚀 **Tema**: espaço, labirintos gerados proceduralmente (daí o nome).
- 🐛 **Estado atual**: jogável, mas com bugs conhecidos e performance instável.

👉 **Jogue agora (versão publicada)**: [vagariante-games.itch.io/mazetriz](https://vagariante-games.itch.io/mazetriz)

---

## 🗂️ Por que este código é um "legacy horror"

Este foi o **meu primeiro projeto completo em LÖVE2D**. Na época eu:

- Não usava modularização (tudo em um ou dois arquivos).
- Abusava de variáveis globais.
- Não tinha controle de estados (menu, jogo, game over).
- Ignorava boas práticas de performance.
- Tinha bugs que eu simplesmente "aceitava" porque não sabia como resolver.

**Resumindo:** é um `main.lua` enorme, com lógica emaranhada e pouca legibilidade. Não use isso como referência de código limpo – use como **exemplo de como NÃO fazer** (e de como se pode evoluir).

---

## 🔄 O que vem agora?

Este repositório foi **arquivado** para dar lugar a uma **reescrita completa** do jogo. O novo projeto (com mesmo nome `Mazetriz`) será:

- ✅ Código modular e organizado.
- ✅ Documentação clara.
- ✅ Arquitetura com separação de estados e sistemas.
- ✅ Correção dos bugs mais críticos.
- ✅ Manutenível e expansível.

🔗 **Novo repositório (em desenvolvimento)**: [github.com/Plocala/Mazetriz](https://github.com/Plocala/Mazetriz) (ainda vazio – aguarde!)

---

## 📜 Licença

Este código legado está sob a licença **MIT**. Sinta-se à vontade para estudá-lo, rir dele ou usar trechos – mas por favor, não diga que eu não avisei sobre a bagunça 😄

---

## 🙏 Agradecimento

Agradeço a mim mesmo do passado por ter começado. E a você, visitante, por entender que todo mundo tem um primeiro projeto meio caótico. O importante é melhorar.

— [Plocala](https://github.com/Plocala)
