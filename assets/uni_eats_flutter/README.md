# 🍔 UniEats & 🌐 UniLink - Ecossistema Unificado

[![Flutter Version](https://img.shields.io/badge/Flutter-3.x-blue.svg?logo=flutter&logoColor=white)](https://flutter.dev)
[![Platform Android](https://img.shields.io/badge/Platform-Android-green.svg?logo=android&logoColor=white)](https://developer.android.com)
[![Platform iOS](https://img.shields.io/badge/Platform-iOS-black.svg?logo=apple&logoColor=white)](https://developer.apple.com/ios/)
[![License](https://img.shields.io/badge/License-Proprietary-gold.svg)](LICENSE)

O **UniEats** é um SaaS de Delivery Regionalizado de alta fidelidade visual (premium) e funcional, projetado com uma experiência rica para 5 módulos de atuação integrados: **Cliente**, **Restaurante/Lojista**, **Entregador/Motoboy**, **Assinante/Financeiro** e **Super Administrador**.

Este projeto foi unificado conceitualmente com a infraestrutura do **UniLink** — uma camada descentralizada de mensagens, pagamentos offline (*offline-first*) via rede Mesh (usando Bluetooth Low Energy/Wi-Fi Direct) e carteira digital com reatividade de cashback em tempo real.

---

## ✨ Recursos do Projeto

- 📱 **Single App / Multi-role (Hub unificado):** Alternância inteligente de módulos de acordo com o perfil de usuário do Firebase.
- 💳 **Mercado Pago & Carteira UniLink:** Módulo de checkout completo com simulação realista e gateway financeiro integrado.
- 🗺️ **Rastreio de Logística Ativo:** Mapa vetorial interativo com rotas simuladas em tempo real para os motoboys e acompanhamento do cliente.
- 🔒 **Navegação Segura (RouteGuard):** Proteção de rotas com base nas permissões e no status de assinatura do usuário.
- 🎨 **Aparência Ultra Premium:** Cores ricas em tons de grafite escuro, off-white e ouro velho para transmitir sofisticação.
- ⚡ **Pronto para GitHub e Exportação:** Configurações de Android e iOS revisadas com nomes amigáveis, livre de erros de dependência.

---

## 🛠️ Pré-requisitos & Instalação

### 1. Requisitos de Ambiente
Certifique-se de ter instalado em sua máquina ou dispositivo móvel:
- **Flutter SDK:** `>=3.0.0`
- **Dart SDK:** `>=3.0.0`
- **Android Studio** ou **VS Code** (com extensões Dart e Flutter)
- **Xcode** (necessário para compilação e teste no iOS)

### 2. Configurando o Firebase
O projeto já está estruturado para consumir o Firebase Auth e Firestore. Para conectar seu próprio banco de dados:
1. Crie um projeto no [Console do Firebase](https://console.firebase.google.com/).
2. Adicione as plataformas Android e iOS ao seu projeto Firebase.
3. Baixe o arquivo `google-services.json` (Android) e coloque em `android/app/`.
4. Baixe o arquivo `GoogleService-Info.plist` (iOS) e coloque em `ios/Runner/`.
5. Ative a Autenticação por E-mail/Senha e o Cloud Firestore no console.

### 3. Rodando o Projeto

```bash
# 1. Clone este repositório
git clone https://github.com/seu-usuario/uni-eats-flutter.git

# 2. Navegue até a pasta do projeto
cd uni-eats-flutter

# 3. Baixe as dependências do pubspec.yaml
flutter pub get

# 4. Verifique se o ambiente está correto
flutter doctor

# 5. Execute em um dispositivo conectado ou emulador
flutter run
```

---

## 📂 Organização de Pastas

```
lib/
├── core/
│   ├── routes/          # Interceptador e roteamento animado (RouteGenerator)
│   └── theme/           # Paleta de cores premium e tipografia elegante
├── features/
│   ├── auth/            # Login, Cadastro Multi-role e gerenciamento de conta
│   ├── cliente/         # Módulo Cliente, Cardápios e Tela do Mercado Pago
│   ├── lojista/         # Gestão de Restaurantes e Extrato Financeiro
│   ├── motoboy/         # Tela de rotas e carteira logística
│   └── shared/          # Hub unificado (ControlHub) e modelos de dados
└── main.dart            # Entrada principal com AuthGate reativo
```

---

## 🚀 Como Exportar e Publicar (Release)

### Android (Gerar APK / App Bundle)
```bash
# Limpar compilações anteriores
flutter clean

# Obter dependências atualizadas
flutter pub get

# Gerar o APK de Produção (encontrado em build/app/outputs/flutter-apk/app-release.apk)
flutter build apk --release

# Gerar o Android App Bundle (.aab) para a Google Play Store
flutter build appbundle --release
```

### iOS (Gerar arquivo .ipa para App Store)
```bash
# Gerar o arquivo build iOS
flutter build ipa --release
```
Depois, abra a pasta `ios/` no Xcode e faça o archive para envio ao TestFlight ou App Store Connect.

---

## 📜 Licença

Proprietário e confidencial. Todos os direitos reservados para **UniEats & UniLink**.
