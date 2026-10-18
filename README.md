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
- Firebase para los servicios y datos conectados a la nube.
- Cloudinary para la carga de imágenes de productos.
- Git y GitHub para el control de versiones.

## Organización del código

- `lib/Admin/`: pantallas del administrador.
- `lib/Cliente/`: pantallas del cliente.
- `lib/BaseDatos/`: clases de acceso a datos.
- `lib/Modelos/`: modelos de la aplicación.
- `lib/Servicios/`: servicios y manejo de sesión y carrito.
- `lib/Styles/`: estilos compartidos.
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

4. Verificar que los servicios de Firebase y la configuración de Cloudinary correspondan al entorno que se utilizará.

5. Ejecutar la aplicación:

   ```bash
   flutter run
   ```

El acceso al repositorio requiere autorización mientras sea privado. El acceso a los datos depende de la configuración y los permisos de Firebase.

## Control de versiones

La rama `main` contiene la versión principal del proyecto. Las mejoras se desarrollan en ramas independientes y se revisan antes de integrarse.

Los commits describen los cambios realizados y los tags permiten identificar entregas importantes.

## Estado del proyecto

Proyecto académico en desarrollo, con conexión a Firebase y mejoras continuas en sus funcionalidades.