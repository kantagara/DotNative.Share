using DotNative.Plugins;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.DependencyInjection.Extensions;

namespace DotNative.Share;

public interface IShare
{
    Task ShareTextAsync(
        string text,
        string? subject = null,
        CancellationToken cancellationToken = default
    );
}

public static class ShareServices
{
    public static IServiceCollection AddShare(this IServiceCollection services)
    {
        services.TryAddSingleton<IShare, ChannelShare>();
        return services;
    }
}

internal sealed class ChannelShare(IPlatformChannels channels) : IShare
{
    public Task ShareTextAsync(
        string text,
        string? subject = null,
        CancellationToken cancellationToken = default
    )
    {
        ArgumentException.ThrowIfNullOrWhiteSpace(text);
        if (text.Length > 256_000)
            throw new ArgumentOutOfRangeException(nameof(text));
        return channels
            .Get("dotnative.share")
            .InvokeAsync(
                "shareText",
                new Dictionary<string, object?> { ["text"] = text, ["subject"] = subject },
                cancellationToken
            );
    }
}
