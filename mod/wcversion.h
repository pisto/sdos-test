#ifndef __WCVERSION_H__
#define __WCVERSION_H__

extern const char* WCREVISION;

constexpr int WC_VERSION_MAJOR = 0;
constexpr int WC_VERSION_MINOR = 8;
constexpr int WC_VERSION_PATCH = 0;

#undef major
#undef minor
#undef patch

struct clientversion
{
    constexpr clientversion(int major, int minor, int patch = 0)
        : major(major), minor(minor), patch(patch) {}
    constexpr clientversion() : major(), minor(), patch() {}

    constexpr int num() const
    {
        return major * 10000 + minor * 100 + patch;
    }

    constexpr bool operator>(const clientversion &cv) const
    {
        return num() > cv.num();
    }

    constexpr bool operator>=(const clientversion &cv) const
    {
        return num() >= cv.num();
    }

    constexpr bool operator<(const clientversion &cv) const
    {
        return num() < cv.num();
    }

    constexpr bool operator<=(const clientversion &cv) const
    {
        return num() <= cv.num();
    }

    constexpr bool operator==(const clientversion &cv) const
    {
        return num() == cv.num();
    }

    constexpr bool operator!=(const clientversion &cv) const
    {
        return num() != cv.num();
    }

#ifndef STANDALONE
    bool operator!=(const char *val) const
    {
        size_t c = 0;
        const char *p = val;

        while (*p)
        {
            if (*p++ == '.')
                ++c;
        }

        switch (c)
        {
            case 1: return shortstr() != val;
            case 2: return str() != val;
            default: return true;
        }
    }

    mod::strtool str() const
    {
        mod::strtool tmp;
        tmp << major << "." << minor << "." << patch;
        return tmp;
    }

    mod::strtool shortstr() const
    {
        mod::strtool tmp;
        tmp << major << "." << minor;
        return tmp;
    }
#endif

    int major;
    int minor;
    int patch;
};

static inline clientversion parseclientversion(const char *version)
{
    const char *p = version;
    clientversion ver;

    ver.major = atoi(p);

    while (*p && *p++ != '.');
    if (!*p) return ver;

    ver.minor = atoi(p);

    while (*p && *p++ != '.');
    if (!*p) return ver;

    ver.patch = atoi(p);
    return ver;
}

inline const char *getwcrevision()
{
    return WCREVISION[0] == '$' ? "unknown" : WCREVISION;
}

constexpr clientversion CLIENTVERSION(WC_VERSION_MAJOR, WC_VERSION_MINOR, WC_VERSION_PATCH);

#endif //__WCVERSION_H__
