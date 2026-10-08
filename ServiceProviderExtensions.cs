using System;
using Microsoft.Extensions.DependencyInjection;

namespace DotNative.Share;

public static class ShareServiceProviderExtensions
{
#if NET10_0_OR_GREATER
    extension(IServiceProvider services)
    {
        /// <summary>Resolves the registered plugin using the provider's DI lifetime.</summary>
        public IShare Share => services.GetRequiredService<IShare>();
    }
#else
    /// <summary>Resolves the registered plugin using the provider's DI lifetime.</summary>
    public static IShare Share(this IServiceProvider services) =>
        services.GetRequiredService<IShare>();
#endif
}
