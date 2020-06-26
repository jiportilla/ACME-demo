# Ejemplo del Sistema de Gestión de Modelos (Model Management System MMS) para actualizaciones de modelos cognitivos de inteligencia artificial

Este ejemplo le ayuda a aprender cómo desarrollar un servicio de IBM Edge Application Manager que utiliza el Sistema de gestión de modelos (MMS) para las actualizaciones de modelos cognitivos de inteligencia artificial. Puede usar el MMS para implementar y actualizar los modelos de aprendizaje de máquina que utilicen los servicios de Edge que se ejecutan en sus dispositivos perimetrales (nodos de margen).

Este es un ejemplo simple de uso y actualización de un servicio cognitivo de Edge.

- [Introducción al sistema de gestión de modelos](#introduccion)
- [Condiciones previas para utilizar el ejemplo del servicio cognitivo Edge con MMS](docs/preconditions.md)
- [Uso del ejemplo cognitivo con MMS con pólizas de implementación](docs/using-image-mms-policy.md)
- [Más detalles de MMS](docs/mms-details.md)

## <a id=introduccion> </a> Introducción

El Sistema de Gestión de Modelos (MMS) le permite tener ciclos de vida independientes para su código y sus datos. Si bien los servicios, patrones y pólizas de IEAM le permiten administrar los ciclos de vida de los componentes de su código, el MMS realiza un servicio análogo para sus modelos cognitivos y otros archivos de datos. Esto puede ser útil para actualizar de forma remota la configuración de sus servicios Edge en el entorno. También puede permitirle entrenar y actualizar continuamente sus modelos cognitivos en centros de datos poderosos, y luego publicar dinámicamente versiones nuevas de los modelos a sus dispositivos en el entorno. El MMS le permite administrar el ciclo de vida de los modelos cognitivos y los archivos de datos en su dispositivo perimetral, de forma remota e independiente de sus actualizaciones de código fuente. En general, el MMS proporciona capacidades para que pueda enviar de forma segura cualquier archivo de datos desde y hacia sus dispositivos de margen.

Este documento lo guiará a través del proceso de uso del Sistema de gestión de modelos para enviar un archivo del modelo cognitivo a sus nodos del margen. También muestra cómo sus dispositivos pueden detectar la llegada de una nueva versión del modelo cognitivo y luego utilizar el contenido de ese archivo.



Ver más ejemplos en: [Ejemplos Horizon](https://github.com/open-horizon/examples/)
