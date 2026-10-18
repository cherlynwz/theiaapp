# THEIA — Aplicación móvil de pastelería

THEIA es una aplicación desarrollada en Flutter que permite consultar productos de pastelería, agregar artículos al carrito y realizar pedidos. Incluye secciones para clientes y administradores.

## Funciones principales

### Cliente
- Registro e inicio de sesión.
- Consulta de productos y categorías.
- Visualización del detalle de los productos.
- Carrito de compras.
- Registro y consulta de pedidos.
- Consulta del perfil.

### Administrador
- Panel de administración.
- Gestión de productos.
- Consulta de usuarios.
- Gestión de pedidos.
- Consulta de reportes.

## Tecnologías utilizadas

- Flutter y Dart para el desarrollo de la aplicación.
- Firebase Authentication para la autenticación de usuarios.
- Cloud Firestore para el almacenamiento de datos.
- Cloudinary para la carga de imágenes de productos.
- Provider para el manejo del estado del carrito.
- Git y GitHub para el control de versiones.

## Arquitectura por capas

El código se organiza por responsabilidades para facilitar su mantenimiento y las futuras mejoras.

| Parte | Responsabilidad |
| --- | --- |
| Presentación | Pantallas, estilos e interacción con el usuario. |
| Lógica | Coordinación de operaciones, manejo del carrito y sesión. |
| Datos | Acceso a Firebase y comunicación con servicios externos. |
| Modelos | Estructura de usuarios, productos y pedidos. |

Las pantallas solicitan operaciones a los servicios de lógica. Estos utilizan las clases de acceso a datos o los servicios externos según corresponda. Los modelos representan la información utilizada por la aplicación.

### Organización del código

- `lib/presentacion/pantallas/admin/`: pantallas del administrador.
- `lib/presentacion/pantallas/cliente/`: pantallas del cliente.
- `lib/presentacion/pantallas/`: inicio de sesión y registro.
- `lib/presentacion/estilos/`: estilos compartidos.
- `lib/presentacion/integraciones/`: integración con funciones de interacción, como WhatsApp.
- `lib/logica/`: servicios de autenticación, productos, pedidos, usuarios e imágenes; manejo del carrito y sesión.
- `lib/datos/dao/`: clases de acceso a Firebase Authentication y Cloud Firestore.
- `lib/datos/servicios/`: integración con Google y Cloudinary.
- `lib/modelos/`: modelos de usuario, producto y pedido.
- `lib/main.dart`: punto de entrada e inicialización de la aplicación.
- `lib/firebase_options.dart`: configuración de Firebase generada para las plataformas registradas.
- `assets/`: recursos gráficos de la aplicación.

## Ejecución del proyecto

Se requiere Flutter, Git y un dispositivo Android o emulador configurado.

1. Clonar el repositorio:

   ```bash
   git clone https://github.com/cherlynwz/theiaapp.git
   ```

2. Entrar a la carpeta del proyecto:

   ```bash
   cd theiaapp
   ```

3. Instalar las dependencias:

   ```bash
   flutter pub get
   ```

4. Verificar que la configuración de Firebase corresponda al entorno utilizado, incluidos los proveedores de autenticación y los permisos de Cloud Firestore.

5. Verificar el nombre de la cuenta y el preset de carga de Cloudinary utilizados por el servicio de imágenes.

6. Ejecutar la aplicación:

   ```bash
   flutter run
   ```

El acceso al repositorio requiere autorización mientras sea privado. El acceso a los datos depende de la configuración y los permisos de Firebase.

## Validación

Para ejecutar el análisis estático:

```bash
flutter analyze
```

Después de la reorganización por capas, el análisis terminó sin incidencias y se realizó una prueba manual de funcionamiento de la aplicación.

## Control de versiones

La rama `main` contiene la versión principal del proyecto. Las mejoras se desarrollan en ramas independientes y se revisan mediante Pull Requests antes de integrarse.

Se utilizan prefijos en los mensajes de los commits, como:
- `feat`: nuevas funcionalidades.
- `fix`: correcciones.
- `refactor`: reorganización del código.
- `docs`: cambios en la documentación.

Los tags permiten identificar entregas importantes. La etiqueta `v0.1.0` corresponde a la primera entrega con conexión a Firebase y documentación, anterior a la reorganización por capas.

## Estado del proyecto

Proyecto académico en desarrollo, conectado a Firebase y organizado mediante una arquitectura por capas. Se continúan realizando mejoras en sus funcionalidades y documentación.