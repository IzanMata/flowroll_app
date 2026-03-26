Configura git con los datos del usuario si no están ya configurados:
- name: izanmata
- email: matadiazizan@gmail.com

Ejecuta: `git config user.name "izanmata"` y `git config user.email "matadiazizan@gmail.com"`

Luego revisa el estado del repositorio con `git status` y `git log --oneline -3`.

Si hay cambios sin commitear, haz un commit con un mensaje descriptivo que resuma los cambios.
Usa `git add` con los archivos específicos (nunca `git add -A` a ciegas si hay archivos sensibles).

Finalmente haz push con `git push` al remote configurado.
