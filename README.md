# DotNative.Share

Opens the native system share UI with text and an optional subject.

```csharp
builder.Services.AddShare();
await services.Share
    .ShareTextAsync("Hello from DotNative", "A greeting");
```

| Platform | Status |
| --- | --- |
| Android | `ACTION_SEND` chooser |
| iOS | `UIActivityViewController` |
| macOS | `NSSharingServicePicker` |
| Windows | Not implemented |
| Linux | Not implemented |

The operation completes when the share sheet closes. It does not report whether
the user completed a share or whether the destination delivered the content.
This release shares text only; files and rich attachments are not included.

## Service access

Import `DotNative.Share` to access the plugin through `IServiceProvider`:

```csharp
using DotNative.Share;

var plugin = services.Share;
```

The getter calls `GetRequiredService<IShare>()` on every access, preserving
DI lifetimes and the usual missing-registration error. Register the plugin with
`AddShare(...)` before building the provider.

A `net10.0` application uses the property syntax with C# 14 or later. A
`net9.0` application uses only the method equivalent:

```csharp
var plugin = services.Share();
```

The package contains separate `net9.0` and `net10.0` assemblies. NuGet selects
the assembly matching the application target framework. `NET10_0_OR_GREATER`
selects the property; the `#else` branch selects the method.

Build and pack both targets with .NET 10 SDK. A source build using .NET 9 SDK
builds only `net9.0`; it does not produce the .NET 10 assembly.
