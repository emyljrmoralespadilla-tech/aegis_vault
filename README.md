# Evidencia de Gestión de Versiones con Git

## 1. Integración mediante Rebase

Para integrar los cambios realizados en las diferentes ramas del proyecto se utilizó `git rebase` con el fin de mantener un historial más limpio y evitar la creación de commits de merge innecesarios.

Comando utilizado:

```bash
git fetch origin
git rebase origin/main
```

---

## 2. Simulación de Commit Corrupto

Con el objetivo de demostrar la capacidad de recuperación ante errores críticos, se creó intencionalmente un commit que introducía un fallo en la aplicación.

Commit realizado:

```text
feat: introduce critical bug for recovery test
```

Este commit simuló una modificación defectuosa que provocaba un comportamiento incorrecto en la aplicación.

---

## 3. Recuperación de la Rama

Para restaurar el estado funcional del proyecto se utilizó el comando:

```bash
git revert HEAD
```

Lo anterior generó un nuevo commit que anuló los cambios realizados por el commit defectuoso sin perder el historial del repositorio.

Commit generado:

```text
Revert "feat: introduce critical bug for recovery test"
```

---

## 4. Compactación del Historial (Squash)

Una vez finalizado el desarrollo, se realizó un rebase interactivo para consolidar todos los commits de trabajo en un único commit.

Comando utilizado:

```bash
git rebase -i HEAD~5
```

Durante el proceso se combinaron los commits de desarrollo, pruebas y correcciones utilizando la opción `squash`.

---

## 5. Commit Final

Después de la compactación, el historial quedó resumido en un único commit bajo el estándar Conventional Commits:

```text
feat(security): implement secure storage and geiger proximity alert
```

---

## 6. Actualización del Repositorio Remoto

Debido a la reescritura del historial, fue necesario actualizar la rama remota utilizando:

```bash
git push origin <rama> --force
```

Este procedimiento garantizó que el repositorio remoto reflejara el historial consolidado de la rama de trabajo.
