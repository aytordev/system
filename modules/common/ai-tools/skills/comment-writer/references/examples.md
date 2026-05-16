# Comment Examples

## Request Change

```markdown
Buenísimo el enfoque. Acá separaría este cambio en otro commit porque mezcla la validación con el wiring de UI.

Eso le baja carga al reviewer y hace que el rollback sea más claro si falla la integración.
```

## Approve with a Note

```markdown
Está bien encaminado y el scope se entiende rápido.

Dejo aprobado. Para el próximo PR, agregá el link al anterior y al siguiente así la cadena queda navegable.
```

## Ask for Split

```markdown
Este PR supera el presupuesto de 400 líneas cambiadas, así que necesitamos dividirlo o justificar `size:exception`.

Mi sugerencia: primero foundation + tests, después integración, después docs. Así cada review tiene inicio y fin claros.
```
