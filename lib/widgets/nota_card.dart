import 'package:flutter/material.dart';

import '../app/utils/formato.dart';
import '../models/nota.dart';

/// Tarjeta de nota para las listas.
class NotaCard extends StatelessWidget {
  const NotaCard({
    super.key,
    required this.nota,
    this.onTap,
    this.onAlternarRevisada,
    this.autor,
  });

  final Nota nota;
  final VoidCallback? onTap;

  /// Si es `null` no se muestra la casilla (p. ej. notas públicas).
  final VoidCallback? onAlternarRevisada;
  final String? autor;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final esquema = tema.colorScheme;
    final secundario = tema.textTheme.bodySmall?.copyWith(
      color: esquema.onSurfaceVariant,
    );
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 12, 16, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (onAlternarRevisada != null)
                Checkbox(
                  value: nota.revisada,
                  onChanged: (_) => onAlternarRevisada!(),
                  semanticLabel: nota.revisada
                      ? 'Marcar como pendiente'
                      : 'Marcar como revisada',
                )
              else
                const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (nota.prioritaria)
                          Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Icon(
                              Icons.flag,
                              size: 18,
                              color: esquema.tertiary,
                              semanticLabel: 'Prioritaria',
                            ),
                          ),
                        Expanded(
                          child: Text(
                            nota.titulo,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: tema.textTheme.titleMedium?.copyWith(
                              decoration: nota.revisada
                                  ? TextDecoration.lineThrough
                                  : null,
                              color: nota.revisada
                                  ? esquema.onSurfaceVariant
                                  : null,
                            ),
                          ),
                        ),
                        if (nota.valor != null)
                          Text(
                            Formato.valor(nota.valor!),
                            style: tema.textTheme.titleSmall?.copyWith(
                              color: esquema.primary,
                            ),
                          ),
                      ],
                    ),
                    if (nota.descripcion != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        nota.descripcion!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: tema.textTheme.bodyMedium,
                      ),
                    ],
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          Formato.fechaCorta(nota.fechaNota),
                          style: secundario,
                        ),
                        if (nota.clasificador != null)
                          _Etiqueta(texto: nota.clasificador!),
                        if (autor != null)
                          Text('por $autor', style: secundario),
                        if (autor == null && nota.publica)
                          Icon(
                            Icons.public,
                            size: 16,
                            color: esquema.onSurfaceVariant,
                            semanticLabel: 'Pública',
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Etiqueta extends StatelessWidget {
  const _Etiqueta({required this.texto});

  final String texto;

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: esquema.secondaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        texto,
        style: Theme.of(context).textTheme.labelSmall
            ?.copyWith(color: esquema.onSecondaryContainer),
      ),
    );
  }
}
