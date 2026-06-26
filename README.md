# App Etiquetado Box - canal de actualizaciones

Este repositorio publica el manifiesto y los paquetes que consulta la aplicacion al arrancar.

## Archivos principales

- `version.json`: manifiesto remoto que lee la aplicacion.
- `App_Etiquetado_Box_vX.Y_update.zip`: paquete ZIP de actualizacion.
- `CHANGELOG_vX.Y.txt`: mejoras de la version publicada.

## Funcionamiento

La aplicacion consulta:

`https://raw.githubusercontent.com/irodriguezfino/app-etiquetado-box-updates/main/version.json`

Si `version.json` contiene una version superior a la instalada, descarga el ZIP indicado en `package_url`, comprueba el `sha256` y aplica la actualizacion al cerrar la app.

## Publicar una version nueva

1. Actualizar `APP_VERSION` en `app_etiquetado_box.py`.
2. Generar el ejecutable/paquete con `crear_instalador_completo.bat`.
3. Preparar el manifiesto:

```powershell
python preparar_actualizacion_github.py 1.41 "instalador\App_Etiquetado_Box_v1.41_update.zip" --notes "- Mejora concreta 1`n- Correccion concreta 2"
```

4. Copiar los archivos generados en esta carpeta al repositorio local de GitHub si se trabaja fuera del proyecto.
5. Hacer commit y push a `main`.

No hace falta OneDrive sincronizado ni rutas locales en los equipos cliente.
