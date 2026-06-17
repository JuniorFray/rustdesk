// ARQUIVO MODIFICADO — AcessoRemoto (baseado no RustDesk 1.4.6)
// Tela inicial reescrita: ID grande, botão único "Compartilhar Tela", visual limpo

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hbb/common.dart';
import 'package:flutter_hbb/mobile/pages/server_page.dart';
import 'package:flutter_hbb/mobile/pages/settings_page.dart';
import 'package:flutter_hbb/models/platform_model.dart';
import 'package:flutter_hbb/models/server_model.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

// ─── Cores ───────────────────────────────────────────────────────────────────
const _kBlue   = Color(0xFF2980B9);
const _kGreen  = Color(0xFF27AE60);
const _kDark   = Color(0xFF2C3E50);
const _kBgLight = Color(0xFFF0F4F8);

// ═════════════════════════════════════════════════════════════════════════════
class HomePage extends StatefulWidget {
  static const String routeName = '/';
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Mantém o ServerModel atualizado
  @override
  void initState() {
    super.initState();
    // Garante que o servidor está inicializado
    WidgetsBinding.instance.addPostFrameCallback((_) {
      gFFI.serverModel.updatePasswordModel();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: gFFI.serverModel,
      child: Scaffold(
        backgroundColor: _kBgLight,
        // AppBar minimalista — só configurações no canto
        appBar: AppBar(
          backgroundColor: _kBlue,
          elevation: 0,
          title: const Text(
            'Acesso Remoto',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings_outlined, color: Colors.white, size: 28),
              tooltip: 'Configurações',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsPage()),
              ),
            ),
          ],
        ),
        body: const _EasyHomeBody(),
      ),
    );
  }
}

// ─── Corpo principal ──────────────────────────────────────────────────────────
class _EasyHomeBody extends StatelessWidget {
  const _EasyHomeBody({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final server = context.watch<ServerModel>();
    final allPermsOk = server.mediaOk && server.inputOk && server.floatingWindowOk;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── Bloco do ID ──────────────────────────────────────────────────
          _IdCard(server: server),
          const SizedBox(height: 28),

          // ── Botão principal de compartilhamento ──────────────────────────
          _ShareButton(server: server, allPermsOk: allPermsOk),
          const SizedBox(height: 20),

          // ── Status de conexão ────────────────────────────────────────────
          _ConnectionStatus(server: server),
          const SizedBox(height: 28),

          // ── Dica visual ──────────────────────────────────────────────────
          if (!allPermsOk) const _PermissionHint(),
        ],
      ),
    );
  }
}

// ─── Card do ID ───────────────────────────────────────────────────────────────
class _IdCard extends StatelessWidget {
  final ServerModel server;
  const _IdCard({required this.server});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          const Text(
            'Seu código de acesso',
            style: TextStyle(fontSize: 16, color: Colors.black54),
          ),
          const SizedBox(height: 10),
          Obx(() {
            final id = server.serverId.text;
            return Text(
              id.isEmpty ? '...' : id,
              style: const TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.bold,
                color: _kBlue,
                letterSpacing: 5,
              ),
            );
          }),
          const SizedBox(height: 6),
          const Text(
            'Informe este número para o técnico',
            style: TextStyle(fontSize: 14, color: Colors.black38),
          ),
          const SizedBox(height: 14),
          // Botão copiar
          OutlinedButton.icon(
            icon: const Icon(Icons.copy_rounded, size: 18),
            label: const Text('Copiar código', style: TextStyle(fontSize: 15)),
            style: OutlinedButton.styleFrom(
              foregroundColor: _kBlue,
              side: const BorderSide(color: _kBlue),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            onPressed: () {
              final id = server.serverId.text;
              if (id.isNotEmpty) {
                Clipboard.setData(ClipboardData(text: id));
                showToast('Código copiado!');
              }
            },
          ),
        ],
      ),
    );
  }
}

// ─── Botão principal ──────────────────────────────────────────────────────────
class _ShareButton extends StatelessWidget {
  final ServerModel server;
  final bool allPermsOk;
  const _ShareButton({required this.server, required this.allPermsOk});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: Icon(
          allPermsOk ? Icons.screen_share_rounded : Icons.lock_open_rounded,
          size: 30,
        ),
        label: Text(
          allPermsOk ? 'Compartilhamento Ativo' : 'Liberar Acesso Remoto',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: allPermsOk ? _kGreen : _kBlue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 4,
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ServerPage()),
          );
        },
      ),
    );
  }
}

// ─── Status de conexão ────────────────────────────────────────────────────────
class _ConnectionStatus extends StatelessWidget {
  final ServerModel server;
  const _ConnectionStatus({required this.server});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final conns = server.clients;
      if (conns.isEmpty) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.black12),
          ),
          child: Row(
            children: const [
              Icon(Icons.signal_wifi_statusbar_null_outlined, color: Colors.black38, size: 24),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Aguardando conexão do técnico...',
                  style: TextStyle(fontSize: 15, color: Colors.black45),
                ),
              ),
            ],
          ),
        );
      }

      return Column(
        children: conns.map((c) => _ClientTile(client: c)).toList(),
      );
    });
  }
}

// ─── Tile de cliente conectado ────────────────────────────────────────────────
class _ClientTile extends StatelessWidget {
  final dynamic client;
  const _ClientTile({required this.client});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF7EE),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _kGreen.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.person_rounded, color: _kGreen, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Técnico conectado',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _kDark),
                ),
                Text(
                  client?.name ?? '',
                  style: const TextStyle(fontSize: 13, color: Colors.black45),
                ),
              ],
            ),
          ),
          // Botão encerrar conexão
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade400,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            ),
            onPressed: () => gFFI.serverModel.sendLoginResponse(client, false),
            child: const Text('Encerrar', style: TextStyle(fontSize: 14)),
          ),
        ],
      ),
    );
  }
}

// ─── Dica de permissões pendentes ────────────────────────────────────────────
class _PermissionHint extends StatelessWidget {
  const _PermissionHint();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFFCC02)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Icon(Icons.info_outline_rounded, color: Color(0xFFF39C12), size: 24),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Toque em "Liberar Acesso Remoto" e siga os 3 passos para que o técnico possa te ajudar.',
              style: TextStyle(fontSize: 14, color: Color(0xFF7D6608), height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}
