/*
 * man.exe -- forwards "man <args>" to "wsl.exe -e man <args>".
 *
 * Windows has no man, and nvim's :Man / K / man picker look for an *.exe named
 * "man" on PATH (libuv won't run .cmd/.bat shims). This lets them read the man
 * pages installed in WSL. The argument string is passed through untouched, so
 * quoting is preserved; stdin/stdout/stderr and the exit code are forwarded.
 * MANPAGER / MANWIDTH reach WSL through the WSLENV variable (see winman.lua).
 *
 * Build: gcc -O2 -o man.exe man.c   (done automatically by lua/config/winman.lua)
 */
#include <windows.h>
#include <wchar.h>
#include <stdlib.h>

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

    const wchar_t prefix[] = L"wsl.exe -e man";
    size_t len = wcslen(prefix) + wcslen(rest) + 1;
    wchar_t *full = (wchar_t *)malloc(len * sizeof(wchar_t));
    if (!full) return 1;
    wcscpy(full, prefix);
    wcscat(full, rest);

    STARTUPINFOW si;
    PROCESS_INFORMATION pi;
    ZeroMemory(&si, sizeof si);
    si.cb = sizeof si;
    si.dwFlags = STARTF_USESTDHANDLES;
    si.hStdInput = GetStdHandle(STD_INPUT_HANDLE);
    si.hStdOutput = GetStdHandle(STD_OUTPUT_HANDLE);
    si.hStdError = GetStdHandle(STD_ERROR_HANDLE);

    if (!CreateProcessW(NULL, full, NULL, NULL, TRUE, CREATE_NO_WINDOW,
                        NULL, NULL, &si, &pi)) {
        return 127; /* wsl.exe not found */
    }
    WaitForSingleObject(pi.hProcess, INFINITE);
    DWORD code = 1;
    GetExitCodeProcess(pi.hProcess, &code);
    CloseHandle(pi.hProcess);
    CloseHandle(pi.hThread);
    free(full);
    return (int)code;
}
