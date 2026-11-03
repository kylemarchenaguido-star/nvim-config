/*
 * man.exe -- forwards "man <args>" to "wsl.exe -e env PATH=<clean> man <args>",
 * with a small on-disk cache of the answers.
 *
 * Windows has no man, and nvim's :Man / K / man picker look for an *.exe named
 * "man" on PATH (libuv won't run .cmd/.bat shims). This lets them read the man
 * pages installed in WSL. The argument string is passed through untouched, so
 * quoting is preserved; stdin/stderr and the exit code are forwarded.
 * MANPAGER / MANWIDTH reach WSL through the WSLENV variable (see winman.lua).
 *
 * Why it is not a plain forwarder:
 *  - WSL appends the whole Windows PATH (dozens of /mnt/c/... dirs) and man
 *    searches each one over the slow 9P mount: ~1s per call. A clean PATH makes
 *    the same lookup ~20ms. ~/.manpath still adds the user's pages.
 *  - one :Man makes ~7 sequential calls and every wsl.exe launch costs ~150ms,
 *    so successful lookups/renders are cached in
 *    %LOCALAPPDATA%\nvim-data\man-cache (3 days; keyed on args + MANWIDTH).
 *    A cache hit never starts WSL. Searches (-k, -f, apropos, whatis) and
 *    failures are never cached, so newly installed pages show up.
 *
 * Build: gcc -O2 -o man.exe man.c   (done automatically by lua/config/winman.lua)
 */
#include <windows.h>
#include <wchar.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define CACHE_TTL_100NS (3ULL * 24 * 3600 * 10000000ULL)

static unsigned long long fnv1a(const void *p, size_t n, unsigned long long h)
{
    const unsigned char *b = (const unsigned char *)p;
    while (n--) { h ^= *b++; h *= 1099511628211ULL; }
    return h;
}

static int cacheable(const wchar_t *rest)
{
    if (wcsstr(rest, L" -k") || wcsstr(rest, L" -f") ||
        wcsstr(rest, L"apropos") || wcsstr(rest, L"whatis"))
        return 0;
    /* -l <file>: only Linux paths are stable enough to cache */
    const wchar_t *l = wcsstr(rest, L" -l ");
    if (l && l[4] != L'/') return 0;
    return 1;
}

/* fills dir and file; returns 1 on success */
static int cache_paths(const wchar_t *rest, wchar_t *dir, wchar_t *file, size_t cap)
{
    wchar_t base[MAX_PATH];
    DWORD n = GetEnvironmentVariableW(L"LOCALAPPDATA", base, MAX_PATH);
    if (n == 0 || n >= MAX_PATH) return 0;

    wchar_t width[64] = L"", pager[64] = L"";
    GetEnvironmentVariableW(L"MANWIDTH", width, 64);
    GetEnvironmentVariableW(L"MANPAGER", pager, 64);

    unsigned long long h = 1469598103934665603ULL;
    h = fnv1a(rest, wcslen(rest) * sizeof(wchar_t), h);
    h = fnv1a(L"\x01", sizeof(wchar_t), h);
    h = fnv1a(width, wcslen(width) * sizeof(wchar_t), h);
    h = fnv1a(L"\x01", sizeof(wchar_t), h);
    h = fnv1a(pager, wcslen(pager) * sizeof(wchar_t), h);

    swprintf(dir, cap, L"%ls\\nvim-data\\man-cache", base);
    swprintf(file, cap, L"%ls\\%016llx", dir, h);
    return 1;
}

static void write_all(HANDLE out, const char *buf, DWORD len)
{
    while (len) {
        DWORD w = 0;
        if (!WriteFile(out, buf, len, &w, NULL) || w == 0) return;
        buf += w;
        len -= w;
    }
}

/* returns 1 if a fresh cache entry was found and written to stdout */
static int serve_from_cache(const wchar_t *file)
{
    WIN32_FILE_ATTRIBUTE_DATA a;
    if (!GetFileAttributesExW(file, GetFileExInfoStandard, &a)) return 0;

    FILETIME now;
    GetSystemTimeAsFileTime(&now);
    ULARGE_INTEGER t, m;
    t.LowPart = now.dwLowDateTime;            t.HighPart = now.dwHighDateTime;
    m.LowPart = a.ftLastWriteTime.dwLowDateTime; m.HighPart = a.ftLastWriteTime.dwHighDateTime;
    if (t.QuadPart > m.QuadPart && t.QuadPart - m.QuadPart > CACHE_TTL_100NS) return 0;

    HANDLE f = CreateFileW(file, GENERIC_READ, FILE_SHARE_READ, NULL, OPEN_EXISTING, 0, NULL);
    if (f == INVALID_HANDLE_VALUE) return 0;
    HANDLE out = GetStdHandle(STD_OUTPUT_HANDLE);
    char buf[65536];
    DWORD got;
    while (ReadFile(f, buf, sizeof buf, &got, NULL) && got > 0)
        write_all(out, buf, got);
    CloseHandle(f);
    return 1;
}

static void store_in_cache(const wchar_t *dir, const wchar_t *file, const char *data, size_t len)
{
    wchar_t tmp[2 * MAX_PATH];
    CreateDirectoryW(dir, NULL);
    swprintf(tmp, 2 * MAX_PATH, L"%ls.%lu.tmp", file, (unsigned long)GetCurrentProcessId());
    HANDLE f = CreateFileW(tmp, GENERIC_WRITE, 0, NULL, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL);
    if (f == INVALID_HANDLE_VALUE) return;
    write_all(f, data, (DWORD)len);
    CloseHandle(f);
    if (!MoveFileExW(tmp, file, MOVEFILE_REPLACE_EXISTING))
        DeleteFileW(tmp);
}

int main(void)
{
    const wchar_t *cmdline = GetCommandLineW();
    const wchar_t *rest = cmdline;

    /* skip argv[0], which may be quoted */
    if (*rest == L'"') {
        rest++;
        while (*rest && *rest != L'"') rest++;
        if (*rest) rest++;
    } else {
        while (*rest && *rest != L' ' && *rest != L'\t') rest++;
    }

    wchar_t cdir[MAX_PATH], cfile[2 * MAX_PATH];
    int use_cache = cacheable(rest) && cache_paths(rest, cdir, cfile, 2 * MAX_PATH);
    if (use_cache && serve_from_cache(cfile)) return 0;

    const wchar_t prefix[] = L"wsl.exe -e env PATH=/usr/local/bin:/usr/bin:/bin man";
    size_t len = wcslen(prefix) + wcslen(rest) + 1;
    wchar_t *full = (wchar_t *)malloc(len * sizeof(wchar_t));
    if (!full) return 1;
    wcscpy(full, prefix);
    wcscat(full, rest);

    HANDLE rd = NULL, wr = NULL;
    if (use_cache) {
        SECURITY_ATTRIBUTES sa = { sizeof sa, NULL, TRUE };
        if (!CreatePipe(&rd, &wr, &sa, 0)) {
            use_cache = 0;
        } else {
            SetHandleInformation(rd, HANDLE_FLAG_INHERIT, 0);
        }
    }

    STARTUPINFOW si;
    PROCESS_INFORMATION pi;
    ZeroMemory(&si, sizeof si);
    si.cb = sizeof si;
    si.dwFlags = STARTF_USESTDHANDLES;
    si.hStdInput = GetStdHandle(STD_INPUT_HANDLE);
    si.hStdOutput = use_cache ? wr : GetStdHandle(STD_OUTPUT_HANDLE);
    si.hStdError = GetStdHandle(STD_ERROR_HANDLE);

    if (!CreateProcessW(NULL, full, NULL, NULL, TRUE, CREATE_NO_WINDOW,
                        NULL, NULL, &si, &pi)) {
        return 127; /* wsl.exe not found */
    }

    char *data = NULL;
    size_t dlen = 0, dcap = 0;
    int bad = 0; /* set if buffering failed: never cache a partial page */
    if (use_cache) {
        CloseHandle(wr); /* so ReadFile sees EOF when the child exits */
        HANDLE out = GetStdHandle(STD_OUTPUT_HANDLE);
        char buf[65536];
        DWORD got;
        while (ReadFile(rd, buf, sizeof buf, &got, NULL) && got > 0) {
            write_all(out, buf, got); /* stream to nvim as it arrives */
            if (!bad) {
                if (dlen + got > dcap) {
                    dcap = (dlen + got) * 2;
                    char *nd = (char *)realloc(data, dcap);
                    if (!nd) { bad = 1; continue; }
                    data = nd;
                }
                memcpy(data + dlen, buf, got);
                dlen += got;
            }
        }
        CloseHandle(rd);
    }

    WaitForSingleObject(pi.hProcess, INFINITE);
    DWORD code = 1;
    GetExitCodeProcess(pi.hProcess, &code);
    CloseHandle(pi.hProcess);
    CloseHandle(pi.hThread);

    if (use_cache && !bad && code == 0 && data && dlen > 0)
        store_in_cache(cdir, cfile, data, dlen);

    free(data);
    free(full);
    return (int)code;
}
