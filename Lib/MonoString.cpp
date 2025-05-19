#include <cstring>
#include <string>
#include <cstdint>
#include <vector>
#include <locale>
#include <codecvt>
#include "MonoString.h"

static inline uint16_t byteswap_ushort(uint16_t number) {
#if defined(_MSC_VER) && _MSC_VER > 1310
    return _byteswap_ushort(number);
#elif defined(__GNUC__)
    return __builtin_bswap16(number);
#else
    return (number >> 8) | (number << 8);
#endif
}
std::string utf16le_to_utf8(const std::u16string &u16str) {
    if (u16str.empty()) { return std::string(); }
    const char16_t *p = u16str.data();
    std::u16string::size_type len = u16str.length();
    if (p[0] == 0xFEFF) {
        p += 1;
        len -= 1;
    }

    std::string u8str;
    u8str.reserve(len * 3);

    for (std::u16string::size_type i = 0; i < len; ++i) {
        char16_t u16char = p[i];
        if (u16char < 0x80) {
            u8str.push_back(static_cast<char>(u16char));
        } else if (u16char < 0x800) {
            u8str.push_back(static_cast<char>((u16char >> 6) | 0xC0)); 
            u8str.push_back(static_cast<char>((u16char & 0x3F) | 0x80));
        } else if (u16char >= 0xD800 && u16char <= 0xDBFF) { 
            uint32_t highSur = u16char;
            uint32_t lowSur = p[++i];
            uint32_t codePoint = ((highSur - 0xD800) << 10) | (lowSur - 0xDC00) + 0x10000;
            u8str.push_back(static_cast<char>((codePoint >> 18) | 0xF0));
            u8str.push_back(static_cast<char>(((codePoint >> 12) & 0x3F) | 0x80));
            u8str.push_back(static_cast<char>(((codePoint >> 6) & 0x3F) | 0x80));
            u8str.push_back(static_cast<char>((codePoint & 0x3F) | 0x80));
        } else {
            u8str.push_back(static_cast<char>((u16char >> 12) | 0xE0));
            u8str.push_back(static_cast<char>(((u16char >> 6) & 0x3F) | 0x80));
            u8str.push_back(static_cast<char>((u16char & 0x3F) | 0x80));
        }
    }

    return u8str;
}
std::u16string utf8_to_utf16le(const std::string &u8str, bool addbom, bool *ok) {
    std::u16string u16str;
    if (addbom) {
        u16str.push_back(0xFEFF);
    }

    const unsigned char *p = reinterpret_cast<const unsigned char *>(u8str.data());
    std::string::size_type len = u8str.length();

    for (std::string::size_type i = 0; i < len; ++i) {
        uint32_t ch = p[i];
        if ((ch & 0x80) == 0) {
            u16str.push_back(static_cast<char16_t>(ch));
        } else if ((ch & 0xE0) == 0xC0) {
            uint32_t c2 = p[++i];
            u16str.push_back(static_cast<char16_t>(((ch & 0x1F) << 6) | (c2 & 0x3F)));
        } else if ((ch & 0xF0) == 0xE0) {
            uint32_t c2 = p[++i];
            uint32_t c3 = p[++i];
            u16str.push_back(static_cast<char16_t>(((ch & 0x0F) << 12) | ((c2 & 0x3F) << 6) | (c3 & 0x3F)));
        } else if ((ch & 0xF8) == 0xF0) {
            uint32_t c2 = p[++i];
            uint32_t c3 = p[++i];
            uint32_t c4 = p[++i];
            uint32_t codePoint = ((ch & 0x07) << 18) | ((c2 & 0x3F) << 12) | ((c3 & 0x3F) << 6) | (c4 & 0x3F);
            codePoint -= 0x10000;
            u16str.push_back(static_cast<char16_t>((codePoint >> 10) + 0xD800));
            u16str.push_back(static_cast<char16_t>((codePoint & 0x3FF) + 0xDC00));
        }
    }

    if (ok != nullptr) {
        *ok = true;
    }

    return u16str;
}

void MonoString::setMonoString(const char *s) {
    if (s == nullptr) {
        return;
    }
    std::string str(s);
    length = strlen(s);
    std::u16string basicString = utf8_to_utf16le(str);
    const char16_t *cStr = basicString.c_str();
    memcpy(getChars(), cStr, length * sizeof(char16_t));
}

void MonoString::setMonoString(std::string s) {
    length = s.length();
    std::u16string basicString = utf8_to_utf16le(s);
    const char16_t *str = basicString.c_str();
    memcpy(getChars(), str, length * sizeof(char16_t));
}

const char *MonoString::toChars() {
    std::u16string ss((char16_t *) getChars(), 0, getLength());
    std::string str = utf16le_to_utf8(ss);
    return str.c_str();
}

std::string MonoString::toString() {
    std::u16string ss((char16_t *) getChars(), 0, getLength());
    return utf16le_to_utf8(ss);
}

std::string utf16be_to_utf8(const std::u16string &u16str) {
    if (u16str.empty()) { return std::string(); }
    const char16_t *p = u16str.data();
    std::u16string::size_type len = u16str.length();
    if (p[0] == 0xFEFF) {
        p += 1;
        len -= 1;
    }

    std::string u8str;
    u8str.reserve(len * 3);

    for (std::u16string::size_type i = 0; i < len; ++i) {
        char16_t u16char = byteswap_ushort(p[i]); 
 
        if (u16char < 0x80) {
            u8str.push_back(static_cast<char>(u16char));
        } else if (u16char < 0x800) {
            u8str.push_back(static_cast<char>((u16char >> 6) | 0xC0));
            u8str.push_back(static_cast<char>((u16char & 0x3F) | 0x80));
        } else if (u16char >= 0xD800 && u16char <= 0xDBFF) {
            uint32_t highSur = u16char;
            uint32_t lowSur = byteswap_ushort(p[++i]); 
            uint32_t codePoint = ((highSur - 0xD800) << 10) | (lowSur - 0xDC00) + 0x10000;
            u8str.push_back(static_cast<char>((codePoint >> 18) | 0xF0));
            u8str.push_back(static_cast<char>(((codePoint >> 12) & 0x3F) | 0x80));
            u8str.push_back(static_cast<char>(((codePoint >> 6) & 0x3F) | 0x80));
            u8str.push_back(static_cast<char>((codePoint & 0x3F) | 0x80));
        } else {
            u8str.push_back(static_cast<char>((u16char >> 12) | 0xE0));
            u8str.push_back(static_cast<char>(((u16char >> 6) & 0x3F) | 0x80));
            u8str.push_back(static_cast<char>((u16char & 0x3F) | 0x80));
        }
    }

    return u8str;
}