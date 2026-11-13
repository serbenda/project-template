# Arquitectura

> Cómo está hecho, a vista de pájaro. Se actualiza cuando cambia una pieza o un flujo, no cada commit.
> Las razones de cada elección están en [decisiones/](decisiones/).

## Piezas

```mermaid
flowchart LR
  U[Usuario] --> W[Web]
  W --> D[(Datos)]
```

| Pieza | Qué hace | Tecnología | Carpeta |
|---|---|---|---|
| Web | Interfaz | HTML, CSS y JS sin framework | `index.html`, `css/`, `js/` |

## Flujo de datos
<!-- De dónde vienen los datos, por dónde pasan y dónde acaban. Marca qué es dato externo no confiable. -->

## Fuentes externas
| Fuente | Qué aporta | Licencia | Si falla… |
|---|---|---|---|
| | | | |

## Convenciones del código
<!-- Lo que no se deduce leyendo el código: dónde va cada cosa, nombres, patrones obligatorios. -->
