Safe Fall App 👵📱
Aplicativo móvel desenvolvido em Flutter com o objetivo de detectar possíveis quedas de pessoas em tempo real utilizando a câmera do dispositivo, com notificações automáticas via SMS para um responsável cadastrado.

🚀 Funcionalidades
📸 Captura automática de imagens com a câmera a cada 15 segundos.
🧍‍♂️ Detecção de pose utilizando o Google ML Kit para identificar quedas.
🚨 Envio de SMS de alerta via Twilio ao responsável cadastrado.
🧑‍🦱 Cadastro de usuário com nome e foto facial.
👥 Cadastro de responsável com número de telefone.
🛠 Simulação manual de queda (útil para testes).
🛠 Tecnologias Utilizadas
Flutter
Google ML Kit (Pose Detection)
Twilio API
Camera
Secure Storage (para dados sensíveis)
Shared Preferences (para persistência local)
Image Picker
📂 Estrutura de Telas
monitoring_screen.dart
Tela principal do app.
Utiliza a câmera para capturar imagens.
Detecta poses suspeitas (ex: cabeça abaixo do joelho).
Envia SMS via Twilio em caso de possível queda.
register_face_screen.dart
Tela de cadastro do usuário.
Captura foto facial.
Salva nome e imagem em armazenamento local.
responsible_screen.dart
Tela para cadastrar o responsável.
Armazena nome e telefone no FlutterSecureStorage.
Formato de telefone com máscara (ex: (11) 91234-5678).
🧪 Como Funciona a Detecção de Queda?
A detecção de queda é feita com base na posição da cabeça em relação ao joelho utilizando o modelo de pose do ML Kit. Se o joelho for detectado acima da cabeça, o app interpreta isso como uma possível queda.

🔐 Segurança
Informações sensíveis como número de telefone do responsável são armazenadas com flutter_secure_storage.
A imagem facial e nome são armazenados localmente com shared_preferences e path_provider.
📲 Simulador de Queda
Caso você queira testar o sistema sem de fato cair, basta usar o botão "Simular Queda" na tela de monitoramento. O app enviará um SMS como se uma queda real tivesse sido detectada.

☁️ Configuração do Twilio
Certifique-se de substituir as credenciais abaixo por suas próprias credenciais da Twilio Console:

final String accountSid = 'SUA_ACCOUNT_SID';
final String authToken = 'SEU_AUTH_TOKEN';
final String fromNumber = '+1XXXXXXXXXX'; // Número fornecido pela Twilio


📷 Permissões Necessárias
Adicione estas permissões no AndroidManifest.xml:

xml
Copiar
Editar
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.INTERNET"/>
🧑‍💻 Como Rodar o Projeto
Instale as dependências:

bash
Copiar
Editar
flutter pub get
Conecte um dispositivo físico ou emulador com câmera funcional.

Rode o app:

bash
Copiar
Editar
flutter run
📌 Melhorias Futuras
Reconhecimento facial para identificar quem caiu.

Envio de localização GPS junto com o alerta.

Armazenamento de histórico de quedas.

Notificação via WhatsApp ou push notifications.

👨‍💻 Desenvolvedor
Vinícius Martins


Projeto acadêmico com fins de estudo e aprimoramento profissional em detecção de eventos com IA, automação e desenvolvimento mobile.

