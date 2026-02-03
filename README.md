# 👻 VanishChat

**Comunicação efêmera, segura e sem rastros.**

O VanishChat é um MVP de um sistema de mensagens focado em privacidade radical. O projeto utiliza uma arquitetura *Stateless* onde nenhum dado é persistido em bancos de dados; tudo existe apenas na memória RAM enquanto a conversa acontece.

---

## 🚀 Tecnologias e Arquitetura

### Backend (Dart & Google Cloud)
- **Dart Shelf:** Servidor HTTP e WebSocket customizado.
- **Google Cloud Run:** Deploy em infraestrutura serverless com auto-scaling e encerramento de container por inatividade (5 min).
- **Stateless Relay:** O servidor atua apenas como um roteador de mensagens, sem persistência em disco.

### Frontend (Flutter)
- **Riverpod:** Gerenciamento de estado robusto e reativo.
- **WebSockets:** Comunicação bidirecional em tempo real.
- **Criptografia E2EE (AES-GCM):** As mensagens são cifradas/decifradas nos dispositivos dos usuários. O servidor nunca tem acesso ao conteúdo limpo.

---

## 🛡️ Funcionalidades Principais

- **Zero Persistence:** Nenhuma mensagem é salva em banco de dados ou logs do servidor.
- **Salas Temporárias:** Crie uma sala com um código UUID de 6 dígitos e convide quem quiser.
- **Kill Switch:** Um botão de autodestruição que limpa a sala no servidor e encerra a sessão de todos os participantes instantaneamente.
- **Usernames Voláteis:** Escolha um nome ao entrar na sala; ele só existe para aquela sessão.

---

## 💡 Sobre o Projeto
Este projeto foi desenvolvido como um experimento técnico para explorar a viabilidade de sistemas de chat de baixa latência e alta privacidade utilizando o ecossistema Dart de ponta a ponta.

**Desenvolvido por Lucas Constantino** 🚀