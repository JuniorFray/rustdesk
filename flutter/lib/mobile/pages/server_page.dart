// ARQUIVO MODIFICADO — AcessoRemoto (baseado no RustDesk 1.4.6)
import 'package:flutter/material.dart';
import 'package:flutter_hbb/common.dart';
import 'package:flutter_hbb/models/platform_model.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../../models/server_model.dart';

const _kGreen   = Color(0xFF2ECC71);
const _kBlue    = Color(0xFF2980B9);
const _kOrange  = Color(0xFFE67E22);
const _kGray    = Color(0xFFBDC3C7);
const _kDark    = Color(0xFF2C3E50);
const _kBgLight = Color(0xFFF0F4F8);

class ServerPage extends StatefulWidget {
  const ServerPage({Key? key}) : super(key: key);
  @override
  State<ServerPage> createState() => _ServerPageState();
}

class _ServerPageState extends State<ServerPage> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: gFFI.serverModel,
      child: const _EasySharePage(),
    );
  }
}

class _EasySharePage extends StatelessWidget {
  const _EasySharePage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final server = context.watch<ServerModel>();
    final bool hasMedia    = server.mediaOk;
    final bool hasInput    = server.inputOk;
    final bool allDone     = hasMedia && hasInput;

    return Scaffold(
      backgroundColor: _kBgLight,
      body: SafeArea(
        child: Column(
          children: [
            _Header(allDone: allDone),
            Expanded(
              child: allDone
                  ? _AllDoneView(server: server)
                  : _WizardView(server: server, hasMedia: hasMedia, hasInput: hasInput),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final bool allDone;
  const _Header({required this.allDone});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: allDone ? _kGreen : _kBlue,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      child: Column(
        children: [
          Icon(allDone ? Icons.check_circle : Icons.share_rounded, color: Colors.white, size: 48),
          const SizedBox(height: 8),
          Text(
            allDone ? 'Pronto para receber ajuda!' : 'Liberar Acesso Remoto',
            style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _AllDoneView extends StatelessWidget {
  final ServerModel server;
  const _AllDoneView({required this.server});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.verified_rounded, color: _kGreen, size: 80),
          const SizedBox(height: 20),
          const Text(
            'Tudo liberado!\nO técnico já pode se conectar.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 22, color: _kDark, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 30),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
            ),
            child: Column(
              children: [
                const Text('Seu código de acesso', style: TextStyle(fontSize: 14, color: Colors.black54)),
                const SizedBox(height: 8),
                Obx(() => Text(
                  server.serverId.text,
                  style: const TextStyle(fontSize: 38, fontWeight: FontWeight.bold, color: _kBlue, letterSpacing: 4),
                )),
                const SizedBox(height: 4),
                const Text('Informe este número para o técnico', style: TextStyle(fontSize: 13, color: Colors.black45)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            icon: const Icon(Icons.stop_circle_outlined, color: Colors.red),
            label: const Text('Encerrar acesso', style: TextStyle(color: Colors.red, fontSize: 16)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.red),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => bind.mainStopService(),
          ),
        ],
      ),
    );
  }
}

class _WizardView extends StatelessWidget {
  final ServerModel server;
  final bool hasMedia;
  final bool hasInput;
  const _WizardView({required this.server, required this.hasMedia, required this.hasInput});

  @override
  Widget build(BuildContext context) {
    final steps = <_StepData>[
      _StepData(
        index: 1,
        icon: Icons.screen_share_rounded,
        color: _kBlue,
        title: 'Compartilhar a Tela',
        description: 'Permita que o técnico veja a sua tela.\nToque no botão abaixo e confirme.',
        done: hasMedia,
        onTap: () => server.toggleService(),
        buttonLabel: 'Liberar visualização da tela',
      ),
      _StepData(
        index: 2,
        icon: Icons.touch_app_rounded,
        color: _kOrange,
        title: 'Controle por Toque',
        description: 'Permita que o técnico toque na tela por você.\nVocê sempre poderá parar quando quiser.',
        done: hasInput,
        onTap: () => server.toggleInput(),
        buttonLabel: 'Liberar controle por toque',
        locked: !hasMedia,
      ),
    ];

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: steps.length,
      itemBuilder: (context, i) => _StepCard(data: steps[i]),
    );
  }
}

class _StepCard extends StatelessWidget {
  final _StepData data;
  const _StepCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final bool locked = data.locked;
    final bool done   = data.done;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: locked ? 0.45 : 1.0,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: done ? _kGreen : (locked ? _kGray : data.color), width: 2),
          boxShadow: [if (!locked) BoxShadow(color: data.color.withOpacity(0.15), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: done ? _kGreen : (locked ? _kGray : data.color),
                    child: done
                        ? const Icon(Icons.check, color: Colors.white, size: 22)
                        : Text('${data.index}', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(data.title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: done ? _kGreen : _kDark)),
                  ),
                  Icon(data.icon, color: done ? _kGreen : (locked ? _kGray : data.color), size: 32),
                ],
              ),
              const SizedBox(height: 12),
              Text(data.description, style: TextStyle(fontSize: 15, color: locked ? Colors.black38 : Colors.black54, height: 1.5)),
              const SizedBox(height: 16),
              if (!done)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: Icon(locked ? Icons.lock_outline : data.icon, size: 20),
                    label: Text(locked ? 'Complete o passo anterior primeiro' : data.buttonLabel, style: const TextStyle(fontSize: 15)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: locked ? _kGray : data.color,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: locked ? 0 : 3,
                    ),
                    onPressed: locked ? null : data.onTap,
                  ),
                )
              else
                Row(children: const [
                  Icon(Icons.check_circle, color: _kGreen, size: 20),
                  SizedBox(width: 6),
                  Text('Liberado com sucesso!', style: TextStyle(color: _kGreen, fontWeight: FontWeight.w600, fontSize: 15)),
                ]),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepData {
  final int index;
  final IconData icon;
  final Color color;
  final String title;
  final String description;
  final bool done;
  final VoidCallback onTap;
  final String buttonLabel;
  final bool locked;
  const _StepData({
    required this.index, required this.icon, required this.color,
    required this.title, required this.description, required this.done,
    required this.onTap, required this.buttonLabel, this.locked = false,
  });
}
