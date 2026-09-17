# Catálogo de ubicación del registro

Fuente: https://www.gob.mx/cms/uploads/attachment/file/1098439/Estructura_Municipal_Ago2026.pdf
Edición: agosto de 2026. El archivo JSON incluye el SHA-256 del PDF utilizado.

Se extrajeron las 2,478 filas de las 32 entidades del documento, conservando las claves de entidad y municipio, así como los acentos. Las 16 alcaldías de Ciudad de México están incluidas en ese total.

Convenciones de presentación y almacenamiento:
- La entidad 15 se presenta y guarda como `Estado de México` (el PDF dice `México`).
- Las partículas interiores `De`, `Del`, `La`, `Las`, `Los`, `El` y `Y` se escriben en minúscula; se respeta la primera palabra del nombre.
- El formulario y la validación del registro comparten este catálogo local. No dependen de una consulta externa al registrar una cuenta.
- La validación obligatoria se activa en el registro público. No modifica las ubicaciones de cuentas existentes ni los flujos de edición de perfiles.

Para actualizar el catálogo, extraer las filas de la siguiente edición y verificar las claves únicas, los 32 estados, los totales y los nombres con acentos antes de sustituir el JSON. No mezclar ediciones sin revisar altas y cambios de nombre.

En Oaxaca, las claves 208 y 209 se distinguen como San Juan Mixtepec - Distrito 08 y Distrito 26; las claves 318 y 319 como San Pedro Mixtepec - Distrito 22 y Distrito 26. El PDF principal omite esos distritos. Se contrastaron con los anuarios de INEGI incluidos en `disambiguation_sources` para mantener opciones y valores inequívocos.
