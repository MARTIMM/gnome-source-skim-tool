
---
# Administration of Gio

## Class modules

Below is a list from the new gnome site. The names are presented without a leading 'G' as on the old site. Indents are showing the inheritance of one class with another. A star shows what is implemented.

The File structure is created as an interface but the Raku implementation is defined as being a class.
```
GObject                                         Gnome::GObject::Object
                                                Gnome::Gio::*
  AppInfoMonitor
  AppLaunchContext
  Application                                   *
  ApplicationCommandLine                        *
  InputStream
      FilterInputStream
          BufferedInputStream
              DataInputStream
          ConverterInputStream
      FileInputStream
      MemoryInputStream
      UnixInputStream
  OutputStream
      FilterOutputStream
          BufferedOutputStream
          ConverterOutputStream
          DataOutputStream
      FileOutputStream
      MemoryOutputStream
      UnixOutputStream
  BytesIcon
  Cancellable
  CharsetConverter
  Credentials
  DBusActionGroup
  DBusAuthObserver
  DBusConnection
  DBusInterfaceSkeleton
  MenuModel                                     *
      DBusMenuModel
      Menu                                      *
  DBusMessage
  DBusMethodInvocation
  DBusObjectManagerClient
  DBusObjectManagerServer
  DBusObjectProxy
  DBusObjectSkeleton
  DBusProxy
  DBusServer
  DebugControllerDBus
  DesktopAppInfo
  Emblem
  EmblemedIcon
  FileEnumerator
  IOStream
      FileIOStream
      SimpleIOStream
      SocketConnection
          TcpConnection
              TcpWrapperConnection
          UnixConnection
      TlsConnection
  FileIcon                                      *
  FileInfo
  FileMonitor
  FilenameCompleter
  GObject.TypeModule
      IOModule
  InetAddress
  InetAddressMask
  SocketAddress
      InetSocketAddress
          ProxyAddress
      NativeSocketAddress
      UnixSocketAddress
  ListStore                                     *
  MenuAttributeIter                             *
  MenuItem                                      *
  MenuLinkIter                                  *
  MountOperation
  VolumeMonitor
      NativeVolumeMonitor
  NetworkAddress
  NetworkService
  Notification                                  *
  Permission                                    *
      SimplePermission                          *
  PropertyAction
  SocketAddressEnumerator
      ProxyAddressEnumerator
  Resolver
      ThreadedResolver
  Settings
  SettingsBackend
  SimpleAction                                  *
  SimpleActionGroup                             *
  SimpleAsyncResult                             *
  SimpleProxyResolver
  Socket
  SocketClient
  SocketControlMessage
      UnixCredentialsMessage
      UnixFDMessage
  SocketListener
      SocketService
          ThreadedSocketService
  Subprocess
  SubprocessLauncher
  Task                                          *
  TestDBus
  ThemedIcon
  TlsCertificate
  TlsDatabase
  TlsInteraction
  TlsPassword
  UnixFDList
  UnixMountMonitor
  Vfs
  ZlibCompressor
  ZlibDecompressor
```



## Role modules

```
GInterface
|                                               Gnome::Gio::*
├── GAction                                     R-Action
├── GActionGroup                                R-ActionGroup
├── GActionMap                                  R-ActionMap
├── GAsyncResult                                R-AsyncResult
├── GListModel                                  R-ListModel
├── GFile                                       File  (created as if a class!)
├──
├──

```

## Type modules

Types, constants, standalone functions, etc. generated from gnome sources
`Gnome::Gio::\*`

```
Gnome::N::TopLevelClassSupport
|   Gnome::Gio::*
├── T-action
├── T-file
├── T-ioenums
├── T-menuattributeiter
├── T-menumodel
├── T-simpleasyncresult

```
